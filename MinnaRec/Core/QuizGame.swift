import SwiftUI

enum QuizVisual {
    case none
    /// 大きい絵文字
    case emoji(String)
    /// 黒い影にした絵文字。答えを出すと色が戻る
    case silhouette(String)
    /// 大きく出す字（年号・漢字・式など）
    case big(String)
}

struct QuizItem {
    var prompt: String
    var visual: QuizVisual = .none
    var hints: [String] = []
    /// 選択肢（答えを含める）。空なら答えだけを見せる問題
    var choices: [String] = []
    var answer: String
    /// 答えのあとに出す一言
    var note: String = ""
}

enum QuizMode {
    /// 問題 → 答え
    case open
    /// 選択肢から選ぶ
    case choices
    /// ヒントを1つずつ出す
    case hints
    /// 大きく写したものが少しずつ引いていく
    case zoom
}

/// クイズ形式のゲームはすべてこれで動く
final class QuizGame: GameEngine {
    let mode: QuizMode
    let bank: [QuizItem]
    let perRound: Int

    @Published private(set) var items: [QuizItem] = []
    @Published var index = 0
    @Published var hintsShown = 0
    @Published var revealed = false
    @Published var finished = false
    /// ズームの段階（0 がいちばん大きい）
    @Published var zoomStep = 0
    private(set) var zoomAnchor: UnitPoint = .center

    static let zoomScales: [CGFloat] = [9, 5.5, 3.4, 2.1, 1.4, 1]

    init(id: GameID, items: [QuizItem], mode: QuizMode, perRound: Int = 10) {
        self.mode = mode
        self.bank = items
        self.perRound = perRound
        super.init(id: id)
        shuffle()
    }

    var current: QuizItem? { items.indices.contains(index) ? items[index] : nil }

    override var pointValue: Int {
        switch mode {
        case .hints:
            guard let c = current else { return 1 }
            return max(1, c.hints.count - max(0, hintsShown - 1))
        case .zoom:
            return max(1, QuizGame.zoomScales.count - 1 - zoomStep)
        default:
            return 1
        }
    }

    func shuffle() {
        items = bank.shuffled().prefix(perRound).map { item in
            var it = item
            it.choices = item.choices.shuffled()
            return it
        }
        index = 0
        finished = false
        resetQuestion()
    }

    private func resetQuestion() {
        revealed = false
        zoomStep = 0
        hintsShown = mode == .hints ? 1 : 0
        zoomAnchor = UnitPoint(x: .random(in: 0.25...0.75), y: .random(in: 0.25...0.75))
    }

    override func begin() {
        super.begin()
        readQuestion()
    }

    override func prepareScreenshot() {
        showIntro = false
        if mode == .zoom { zoomStep = 2 }
        if mode == .hints { hintsShown = 2 }
    }

    func readQuestion() {
        guard let c = current else { return }
        var text = c.prompt
        if mode == .hints, let h = c.hints.first { text += "。" + h }
        if mode == .choices {
            text += "。" + c.choices.enumerated().map { "\($0.offset + 1)、\($0.element)" }.joined(separator: "。")
        }
        Speech.say(text)
    }

    func nextHint() {
        guard let c = current else { return }
        if mode == .zoom {
            if zoomStep < QuizGame.zoomScales.count - 1 {
                zoomStep += 1
                Sfx.tick()
            }
            return
        }
        guard hintsShown < c.hints.count else { return }
        hintsShown += 1
        Sfx.tick()
        Speech.say(c.hints[hintsShown - 1])
    }

    func reveal() {
        guard let c = current, !revealed else { return }
        revealed = true
        if mode == .zoom { zoomStep = QuizGame.zoomScales.count - 1 }
        Sfx.fanfare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard self?.revealed == true else { return }
            Speech.say(L.t("答えは、", "The answer is ") + c.answer)
        }
    }

    func next() {
        Speech.stop()
        if index + 1 >= items.count {
            finished = true
            Sfx.fanfare()
            return
        }
        index += 1
        resetQuestion()
        readQuestion()
    }

    func previous() {
        guard index > 0 else { return }
        finished = false
        index -= 1
        resetQuestion()
    }

    override func stage() -> AnyView { AnyView(QuizStage(g: self)) }
    override func controls() -> AnyView { AnyView(QuizControls(g: self)) }
}

struct QuizStage: View {
    @ObservedObject var g: QuizGame

    var body: some View {
        if g.finished {
            FinishStage()
        } else if let c = g.current {
            VStack(spacing: 22) {
                Text(L.t("第\(g.index + 1)問", "Question \(g.index + 1)") + "  /  \(g.items.count)")
                    .font(.big(34))
                    .foregroundStyle(Theme.sub)

                visual(c)

                StageText(c.prompt, size: hasVisual(c) ? 58 : 84)
                    .padding(.horizontal, 60)

                if g.mode == .hints { hints(c) }
                if g.mode == .choices { choices(c) }
                if g.mode == .zoom && !g.revealed {
                    Text(L.t("いま当てたら \(g.pointValue)点！", "Guess now for \(g.pointValue) points!"))
                        .font(.big(40)).foregroundStyle(Theme.accent)
                }

                if g.revealed && g.mode != .choices {
                    answerBubble(c)
                } else if g.revealed, !c.note.isEmpty {
                    StageText(c.note, size: 38, color: Theme.sub)
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.45), value: g.revealed)
            .animation(.easeInOut(duration: 0.8), value: g.zoomStep)
            .animation(.easeOut, value: g.hintsShown)
        }
    }

    private func hasVisual(_ c: QuizItem) -> Bool {
        if case .none = c.visual { return false }
        return true
    }

    @ViewBuilder
    private func visual(_ c: QuizItem) -> some View {
        switch c.visual {
        case .none:
            EmptyView()
        case .emoji(let e):
            if g.mode == .zoom {
                ZStack {
                    Text(e).font(.system(size: 300))
                        .scaleEffect(QuizGame.zoomScales[g.zoomStep], anchor: g.zoomAnchor)
                }
                .frame(width: 520, height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .background(RoundedRectangle(cornerRadius: 36).fill(Theme.card))
                .overlay(RoundedRectangle(cornerRadius: 36).stroke(Theme.ink.opacity(0.15), lineWidth: 4))
            } else {
                Text(e).font(.system(size: 260)).frame(height: 330)
            }
        case .silhouette(let e):
            Text(e).font(.system(size: 300))
                .brightness(g.revealed ? 0 : -1)
                .frame(height: 360)
        case .big(let t):
            StageCard(padding: 30) {
                Text(t)
                    .font(.big(t.count > 6 ? 110 : 150))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(minWidth: 400)
            }
        }
    }

    @ViewBuilder
    private func hints(_ c: QuizItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(c.hints.prefix(g.hintsShown).enumerated()), id: \.offset) { i, h in
                HStack(spacing: 18) {
                    Text(L.t("ヒント\(i + 1)", "Hint \(i + 1)"))
                        .font(.big(32)).foregroundStyle(.white)
                        .padding(.horizontal, 18).padding(.vertical, 8)
                        .background(Capsule().fill(g.id.category.color))
                    Text(h).font(.big(48)).foregroundStyle(Theme.ink)
                        .lineLimit(2).minimumScaleFactor(0.5)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .frame(maxWidth: 1400, alignment: .leading)
        if !g.revealed {
            Text(L.t("いま当てたら \(g.pointValue)点！", "Guess now for \(g.pointValue) points!"))
                .font(.big(36)).foregroundStyle(Theme.accent)
        }
    }

    @ViewBuilder
    private func choices(_ c: QuizItem) -> some View {
        let cols = [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)]
        LazyVGrid(columns: cols, spacing: 20) {
            ForEach(Array(c.choices.enumerated()), id: \.offset) { i, ch in
                let right = ch == c.answer
                HStack(spacing: 20) {
                    Text("\(i + 1)")
                        .font(.big(44)).foregroundStyle(.white)
                        .frame(width: 70, height: 70)
                        .background(Circle().fill(g.revealed && right ? Theme.green : g.id.category.color))
                    Text(ch).font(.big(46)).foregroundStyle(Theme.ink)
                        .lineLimit(2).minimumScaleFactor(0.45)
                    Spacer(minLength: 0)
                    if g.revealed && right {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundStyle(Theme.green)
                    }
                }
                .padding(.horizontal, 24)
                .frame(height: 112)
                .background(RoundedRectangle(cornerRadius: 26).fill(g.revealed && right ? Theme.green.opacity(0.15) : Theme.card))
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(g.revealed && right ? Theme.green : Theme.ink.opacity(0.12), lineWidth: g.revealed && right ? 6 : 3))
                .opacity(g.revealed && !right ? 0.35 : 1)
                .scaleEffect(g.revealed && right ? 1.04 : 1)
            }
        }
        .padding(.horizontal, 70)
    }

    private func answerBubble(_ c: QuizItem) -> some View {
        VStack(spacing: 10) {
            StageText(L.t("答え：", "Answer: ") + c.answer, size: 76, color: .white)
            if !c.note.isEmpty {
                StageText(c.note, size: 36, color: .white.opacity(0.92))
            }
        }
        .padding(.horizontal, 50).padding(.vertical, 22)
        .background(RoundedRectangle(cornerRadius: 34).fill(Theme.accent))
        .padding(.horizontal, 80)
        .transition(.scale.combined(with: .opacity))
    }
}

struct QuizControls: View {
    @ObservedObject var g: QuizGame

    var body: some View {
        VStack(spacing: 12) {
            if g.finished {
                HostButton(title: L.t("もう一回（問題を入れかえる）", "Play again (new questions)"), symbol: "arrow.clockwise", color: Theme.green, big: true) {
                    g.shuffle()
                    g.readQuestion()
                }
            } else if let c = g.current {
                if g.revealed {
                    HostButton(title: L.t("次の問題", "Next question"), symbol: "arrow.right", color: Theme.green, big: true) { g.next() }
                } else {
                    if g.mode == .hints && g.hintsShown < c.hints.count {
                        HostButton(title: L.t("次のヒント", "Next hint"), symbol: "lightbulb.fill", color: Theme.gold, big: true) { g.nextHint() }
                    }
                    if g.mode == .zoom && g.zoomStep < QuizGame.zoomScales.count - 1 {
                        HostButton(title: L.t("もっと見せる", "Zoom out"), symbol: "minus.magnifyingglass", color: Theme.gold, big: true) { g.nextHint() }
                    }
                    HostButton(title: L.t("答えを見せる", "Show answer"), symbol: "eye.fill", color: Theme.accent, big: true) { g.reveal() }
                }
                Text(L.t("答え：", "Answer: ") + c.answer)
                    .font(.round(17))
                    .foregroundStyle(.white.opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                HStack(spacing: 10) {
                    HostButton(title: L.t("前へ", "Back"), symbol: "arrow.left", color: Theme.hostCard) { g.previous() }
                    HostButton(title: L.t("もう一度読む", "Read again"), symbol: "speaker.wave.2.fill", color: Theme.hostCard) { g.readQuestion() }
                }
                if !g.revealed {
                    HostButton(title: L.t("とばす", "Skip"), symbol: "forward.fill", color: Theme.hostCard) { g.next() }
                }
            }
        }
    }
}
