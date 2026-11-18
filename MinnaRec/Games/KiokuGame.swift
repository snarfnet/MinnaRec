import SwiftUI

/// 覚えてね：絵をいくつか見せて隠し、何があったかを聞く
final class KiokuGame: GameEngine {
    struct Item: Equatable {
        let emoji: String
        let ja: String
        let en: String
        var name: String { L.t(ja, en) }
    }

    enum Phase { case show, question, answered }
    enum Kind { case missing, count, yesno }

    @Published var phase: Phase = .show
    @Published var level = 6
    @Published var shown: [Item] = []
    @Published var countdown = 10
    @Published var kind: Kind = .missing
    @Published var choices: [String] = []
    @Published var choiceEmoji: [String] = []
    @Published var answer = ""
    @Published var target: Item? = nil
    @Published var round = 0

    private var token = 0
    static let showSeconds = 10

    init() { super.init(id: .kioku) }

    private func later(_ sec: Double, _ t: Int, _ f: @escaping @MainActor () -> Void) {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(0, sec) * 1_000_000_000))
            guard let self, self.token == t else { return }
            f()
        }
    }

    override func begin() {
        super.begin()
        newRound()
    }

    override func stop() {
        token += 1
        super.stop()
    }

    func setLevel(_ n: Int) {
        level = n
        newRound()
    }

    func newRound() {
        shown = Array(KiokuGame.pool.shuffled().prefix(level))
        round += 1
        makeQuestion()
        showAgain()
        Speech.say(L.t("よく見て覚えてください", "Look closely and remember"))
    }

    /// 同じ絵をもう一度見せる
    func showAgain() {
        token += 1
        phase = .show
        countdown = KiokuGame.showSeconds
        countTick(token)
    }

    private func countTick(_ t: Int) {
        later(1, t) { [weak self] in
            guard let self, self.phase == .show else { return }
            self.countdown -= 1
            if self.countdown <= 0 {
                self.hide()
            } else {
                if self.countdown <= 3 { Sfx.tick() }
                self.countTick(t)
            }
        }
    }

    func hide() {
        token += 1
        phase = .question
        Sfx.drum()
        Speech.say(questionText)
    }

    func reveal() {
        guard phase == .question else { return }
        phase = .answered
        Sfx.fanfare()
        Speech.say(L.t("答えは、", "The answer is ") + answer)
    }

    private func makeQuestion() {
        let kinds: [Kind] = [.missing, .missing, .count, .yesno, .yesno]
        kind = kinds.randomElement() ?? .missing
        switch kind {
        case .missing:
            let absent = KiokuGame.pool.filter { !shown.contains($0) }.randomElement() ?? KiokuGame.pool[0]
            let opts = (Array(shown.shuffled().prefix(3)) + [absent]).shuffled()
            choices = opts.map { $0.name }
            choiceEmoji = opts.map { $0.emoji }
            answer = absent.name
            target = absent
        case .count:
            let n = shown.count
            let nums = [n - 1, n, n + 1, n + 2].filter { $0 > 0 }.shuffled()
            choices = nums.map { L.t("\($0)こ", "\($0)") }
            choiceEmoji = nums.map { _ in "" }
            answer = L.t("\(n)こ", "\(n)")
            target = nil
        case .yesno:
            let present = Bool.random()
            let item = present ? (shown.randomElement() ?? KiokuGame.pool[0])
                               : (KiokuGame.pool.filter { !shown.contains($0) }.randomElement() ?? KiokuGame.pool[0])
            target = item
            choices = [L.t("あった", "Yes"), L.t("なかった", "No")]
            choiceEmoji = ["⭕", "❌"]
            answer = present ? choices[0] : choices[1]
        }
    }

    var questionText: String {
        switch kind {
        case .missing: return L.t("なかったのはどれ？", "Which one was NOT there?")
        case .count: return L.t("絵はいくつありましたか？", "How many pictures were there?")
        case .yesno: return L.t("「\(target?.name ?? "")」はありましたか？", "Did you see the \(target?.name ?? "")?")
        }
    }

    override func prepareScreenshot() {
        showIntro = false
        shown = Array(KiokuGame.pool.prefix(6))
        level = 6
        makeQuestion()
        phase = .show
        countdown = 7
    }

    override func stage() -> AnyView { AnyView(KiokuStage(g: self)) }
    override func controls() -> AnyView { AnyView(KiokuControls(g: self)) }

    static let pool: [Item] = [
        Item(emoji: "🍎", ja: "りんご", en: "apple"),
        Item(emoji: "🐶", ja: "いぬ", en: "dog"),
        Item(emoji: "🚗", ja: "くるま", en: "car"),
        Item(emoji: "☂️", ja: "かさ", en: "umbrella"),
        Item(emoji: "🌸", ja: "さくら", en: "cherry blossom"),
        Item(emoji: "🎩", ja: "ぼうし", en: "hat"),
        Item(emoji: "📚", ja: "本", en: "books"),
        Item(emoji: "⏰", ja: "時計", en: "clock"),
        Item(emoji: "🍙", ja: "おにぎり", en: "rice ball"),
        Item(emoji: "🐟", ja: "さかな", en: "fish"),
        Item(emoji: "🔑", ja: "かぎ", en: "key"),
        Item(emoji: "🎈", ja: "風船", en: "balloon"),
        Item(emoji: "🍉", ja: "すいか", en: "watermelon"),
        Item(emoji: "🐱", ja: "ねこ", en: "cat"),
        Item(emoji: "🚲", ja: "自転車", en: "bicycle"),
        Item(emoji: "☕", ja: "コーヒー", en: "coffee"),
        Item(emoji: "🎸", ja: "ギター", en: "guitar"),
        Item(emoji: "🌻", ja: "ひまわり", en: "sunflower"),
        Item(emoji: "🍰", ja: "ケーキ", en: "cake"),
        Item(emoji: "🐘", ja: "ぞう", en: "elephant"),
        Item(emoji: "✏️", ja: "えんぴつ", en: "pencil"),
        Item(emoji: "👓", ja: "めがね", en: "glasses"),
        Item(emoji: "🧦", ja: "くつした", en: "socks"),
        Item(emoji: "🍌", ja: "バナナ", en: "banana"),
        Item(emoji: "🐸", ja: "かえる", en: "frog"),
        Item(emoji: "⛄", ja: "雪だるま", en: "snowman"),
        Item(emoji: "🎁", ja: "プレゼント", en: "present"),
        Item(emoji: "🍓", ja: "いちご", en: "strawberry"),
        Item(emoji: "🦆", ja: "あひる", en: "duck"),
        Item(emoji: "📞", ja: "電話", en: "telephone"),
        Item(emoji: "🥕", ja: "にんじん", en: "carrot"),
        Item(emoji: "🐢", ja: "かめ", en: "turtle"),
        Item(emoji: "🍵", ja: "お茶", en: "tea"),
        Item(emoji: "🧸", ja: "くまのぬいぐるみ", en: "teddy bear"),
        Item(emoji: "🍡", ja: "だんご", en: "dumplings"),
        Item(emoji: "🐔", ja: "にわとり", en: "chicken"),
        Item(emoji: "🚂", ja: "汽車", en: "steam train"),
        Item(emoji: "🎏", ja: "こいのぼり", en: "carp streamer"),
        Item(emoji: "🥒", ja: "きゅうり", en: "cucumber"),
        Item(emoji: "🌽", ja: "とうもろこし", en: "corn"),
    ]
}

struct KiokuStage: View {
    @ObservedObject var g: KiokuGame

    var body: some View {
        VStack(spacing: 24) {
            switch g.phase {
            case .show: showView
            case .question: questionView
            case .answered: answeredView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.4), value: g.phase)
    }

    private var columns: Int { g.shown.count <= 4 ? 4 : (g.shown.count <= 6 ? 3 : 4) }

    private func itemGrid(size: CGFloat, nameSize: CGFloat) -> some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 20), count: columns)
        return LazyVGrid(columns: cols, spacing: 18) {
            ForEach(Array(g.shown.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 4) {
                    Text(item.emoji).font(.system(size: size))
                    Text(item.name).font(.big(nameSize)).foregroundStyle(Theme.ink)
                        .lineLimit(1).minimumScaleFactor(0.5)
                }
            }
        }
        .padding(.horizontal, 120)
    }

    private var showView: some View {
        VStack(spacing: 14) {
            HStack {
                StageText(L.t("よく見て覚えてね！", "Look and remember!"), size: 56)
                Spacer()
                Text("\(g.countdown)")
                    .font(.big(90)).foregroundStyle(.white)
                    .frame(width: 150, height: 150)
                    .background(Circle().fill(g.countdown <= 3 ? Theme.accent : Theme.blue))
                    .contentTransition(.numericText())
                    .animation(.spring, value: g.countdown)
            }
            .padding(.horizontal, 80)
            itemGrid(size: g.shown.count <= 4 ? 210 : (g.shown.count <= 6 ? 160 : 140), nameSize: 40)
        }
    }

    private var questionView: some View {
        VStack(spacing: 26) {
            StageText(g.questionText, size: 80)
                .padding(.horizontal, 60)
            if g.kind == .yesno, let t = g.target {
                Text(t.emoji).font(.system(size: 220))
            }
            choiceRow(highlight: false)
        }
    }

    private var answeredView: some View {
        VStack(spacing: 20) {
            StageText(g.questionText, size: 54, color: Theme.sub)
            choiceRow(highlight: true)
            Text(L.t("出ていた絵", "The pictures were"))
                .font(.big(34)).foregroundStyle(Theme.sub)
            HStack(spacing: 18) {
                ForEach(Array(g.shown.enumerated()), id: \.offset) { _, item in
                    Text(item.emoji).font(.system(size: 90))
                }
            }
        }
    }

    private func choiceRow(highlight: Bool) -> some View {
        HStack(spacing: 26) {
            ForEach(Array(g.choices.enumerated()), id: \.offset) { i, ch in
                choiceCard(i, ch, highlight: highlight)
            }
        }
        .padding(.horizontal, 60)
    }

    private func choiceCard(_ i: Int, _ ch: String, highlight: Bool) -> some View {
        let right = highlight && ch == g.answer
        let emoji = g.choiceEmoji.indices.contains(i) ? g.choiceEmoji[i] : ""
        return VStack(spacing: 8) {
            Text("\(i + 1)")
                .font(.big(38)).foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(Circle().fill(right ? Theme.green : g.id.category.color))
            if !emoji.isEmpty {
                Text(emoji).font(.system(size: 110))
            }
            Text(ch).font(.big(48)).foregroundStyle(Theme.ink)
                .lineLimit(1).minimumScaleFactor(0.4)
        }
        .padding(20)
        .frame(maxWidth: 340)
        .background(RoundedRectangle(cornerRadius: 28).fill(right ? Theme.green.opacity(0.15) : Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(right ? Theme.green : Theme.ink.opacity(0.12), lineWidth: right ? 7 : 3))
        .opacity(highlight && !right ? 0.35 : 1)
    }
}

struct KiokuControls: View {
    @ObservedObject var g: KiokuGame

    var body: some View {
        VStack(spacing: 12) {
            switch g.phase {
            case .show:
                HostButton(title: L.t("すぐ隠す", "Hide now"), symbol: "eye.slash.fill", color: Theme.gold, big: true) { g.hide() }
            case .question:
                HostButton(title: L.t("答えを見せる", "Show answer"), symbol: "eye.fill", color: Theme.accent, big: true) { g.reveal() }
                HostButton(title: L.t("もう一度見せる", "Show pictures again"), symbol: "arrow.counterclockwise", color: Theme.hostCard) { g.showAgain() }
            case .answered:
                HostButton(title: L.t("次の問題", "Next round"), symbol: "arrow.right", color: Theme.green, big: true) { g.newRound() }
            }
            Text(L.t("答え：", "Answer: ") + g.answer)
                .font(.round(17)).foregroundStyle(.white.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(L.t("絵の数", "Number of pictures"))
                .font(.round(16)).foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 8) {
                ForEach([4, 6, 8], id: \.self) { n in
                    HostButton(title: L.t("\(n)こ", "\(n)"), color: g.level == n ? Theme.green : Theme.hostCard) { g.setLevel(n) }
                }
            }
        }
    }
}
