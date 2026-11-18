import SwiftUI

final class BingoGame: GameEngine {
    @Published private(set) var drawn: [Int] = []
    @Published var rolling = false
    /// 回している間に出すでたらめな数字
    @Published var flicker = 0
    private var pool: [Int] = []
    private var token = 0

    static let letters = ["B", "I", "N", "G", "O"]

    init() {
        super.init(id: .bingo)
        restart()
    }

    override var usesTeams: Bool { false }

    var last: Int? { drawn.last }
    var remaining: Int { pool.count }

    static func letter(_ n: Int) -> String { letters[min(4, (n - 1) / 15)] }

    static func label(_ n: Int) -> String { L.isJa ? "\(n)" : "\(letter(n))-\(n)" }

    func restart() {
        token += 1
        pool = Array(1...75).shuffled()
        drawn = []
        rolling = false
    }

    override func stop() {
        token += 1
        rolling = false
        super.stop()
    }

    override func prepareScreenshot() {
        showIntro = false
        for _ in 0..<18 {
            if let n = pool.popLast() { drawn.append(n) }
        }
    }

    func spin() {
        guard !rolling, !pool.isEmpty else { return }
        token += 1
        let t = token
        rolling = true
        Speech.stop()
        Sfx.drumroll(2)
        flickerStep(t, count: 0)
    }

    private func flickerStep(_ t: Int, count: Int) {
        guard t == token else { return }
        if count >= 20 {
            finish(t)
            return
        }
        flicker = Int.random(in: 1...75)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.flickerStep(t, count: count + 1)
        }
    }

    private func finish(_ t: Int) {
        guard t == token, let n = pool.popLast() else { return }
        drawn.append(n)
        rolling = false
        Sfx.drum()
        announce(n)
    }

    func announce(_ n: Int) {
        let text: String
        if L.isJa {
            text = "\(n)。\(n)"
        } else {
            let l = BingoGame.letter(n)
            text = "\(l) \(n). \(l) \(n)"
        }
        Speech.say(text, rate: 0.38)
    }

    func repeatLast() {
        if let n = last { announce(n) }
    }

    func undo() {
        guard !rolling, let n = drawn.popLast() else { return }
        pool.append(n)
        pool.shuffle()
    }

    override func stage() -> AnyView { AnyView(BingoStage(g: self)) }
    override func controls() -> AnyView { AnyView(BingoControls(g: self)) }
}

struct BingoStage: View {
    @ObservedObject var g: BingoGame

    var body: some View {
        HStack(spacing: 50) {
            ball
            board
        }
        .padding(.horizontal, 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var ball: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [.white, Theme.gold.opacity(0.55)], center: .topLeading, startRadius: 20, endRadius: 420))
                    .overlay(Circle().stroke(Theme.gold, lineWidth: 12))
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                ballText
            }
            .frame(width: 470, height: 470)
            .rotationEffect(.degrees(g.rolling ? Double(g.flicker % 7) * 4 - 12 : 0))

            Text(L.t("\(g.drawn.count)個目", "Ball \(g.drawn.count)") + "  ·  " + L.t("のこり\(g.remaining)", "\(g.remaining) left"))
                .font(.big(38))
                .foregroundStyle(Theme.sub)
        }
    }

    @ViewBuilder
    private var ballText: some View {
        if g.rolling {
            Text("\(g.flicker)")
                .font(.big(220))
                .foregroundStyle(Theme.ink.opacity(0.35))
        } else if let n = g.last {
            VStack(spacing: -20) {
                Text(BingoGame.letter(n))
                    .font(.big(90))
                    .foregroundStyle(Theme.accent)
                Text("\(n)")
                    .font(.big(240))
                    .foregroundStyle(Theme.ink)
                    .minimumScaleFactor(0.5)
            }
        } else {
            Text("?")
                .font(.big(240))
                .foregroundStyle(Theme.ink.opacity(0.25))
        }
    }

    private var board: some View {
        VStack(spacing: 10) {
            ForEach(0..<5, id: \.self) { row in
                boardRow(row)
            }
        }
        .padding(22)
        .background(RoundedRectangle(cornerRadius: 30).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Theme.ink.opacity(0.12), lineWidth: 3))
    }

    private func boardRow(_ row: Int) -> some View {
        HStack(spacing: 6) {
            Text(BingoGame.letters[row])
                .font(.big(40))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(Circle().fill(Theme.accent))
            ForEach(1...15, id: \.self) { col in
                cell(row * 15 + col)
            }
        }
    }

    private func cell(_ n: Int) -> some View {
        let hit = g.drawn.contains(n)
        let isLast = g.last == n && !g.rolling
        return Text("\(n)")
            .font(.big(26))
            .foregroundStyle(hit ? .white : Theme.ink.opacity(0.35))
            .frame(width: 48, height: 58)
            .background(RoundedRectangle(cornerRadius: 10).fill(isLast ? Theme.accent : (hit ? Theme.blue : Theme.bg)))
            .scaleEffect(isLast ? 1.15 : 1)
    }
}

struct BingoControls: View {
    @ObservedObject var g: BingoGame
    @State private var confirmRestart = false

    var body: some View {
        VStack(spacing: 12) {
            HostButton(title: g.remaining == 0 ? L.t("全部出ました", "All numbers called") : L.t("回す", "Draw"),
                       symbol: "arrow.triangle.2.circlepath", color: g.rolling || g.remaining == 0 ? Theme.hostCard : Theme.green, big: true) {
                g.spin()
            }
            HostButton(title: L.t("もう一度読む", "Say it again"), symbol: "speaker.wave.2.fill", color: Theme.blue) { g.repeatLast() }
            HostButton(title: L.t("ひとつ前に戻す", "Undo last"), symbol: "arrow.uturn.backward", color: Theme.hostCard) { g.undo() }
            HostButton(title: L.t("最初から", "Start over"), symbol: "arrow.counterclockwise", color: Theme.accent) { confirmRestart = true }
            if !g.drawn.isEmpty {
                Text(L.t("出た数字：", "Called: ") + g.drawn.suffix(8).reversed().map { BingoGame.label($0) }.joined(separator: ", "))
                    .font(.round(16))
                    .foregroundStyle(.white.opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .alert(L.t("最初からにしますか？", "Start a new game?"), isPresented: $confirmRestart) {
            Button(L.t("最初から", "Start over"), role: .destructive) { g.restart() }
            Button(L.t("やめる", "Cancel"), role: .cancel) {}
        }
    }
}
