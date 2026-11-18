import SwiftUI

struct HLCard: Equatable {
    let value: Int   // 1〜13
    let suit: Int    // 0♠ 1♥ 2♦ 3♣

    static func random() -> HLCard { HLCard(value: Int.random(in: 1...13), suit: Int.random(in: 0...3)) }

    var face: String {
        switch value {
        case 1: return "A"
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "\(value)"
        }
    }
    var suitSymbol: String { ["♠", "♥", "♦", "♣"][suit] }
    var isRed: Bool { suit == 1 || suit == 2 }
}

final class HighLowGame: GameEngine {
    enum Outcome { case higher, lower, same }

    @Published var current = HLCard.random()
    @Published var next: HLCard?
    @Published var round = 1
    @Published var flipping = false
    private var token = 0

    init() { super.init(id: .highlow) }

    override var usesTeams: Bool { false }

    var outcome: Outcome? {
        guard let n = next else { return nil }
        if n.value > current.value { return .higher }
        if n.value < current.value { return .lower }
        return .same
    }

    override func begin() {
        super.begin()
        ask()
    }

    override func stop() {
        token += 1
        flipping = false
        super.stop()
    }

    override func prepareScreenshot() {
        showIntro = false
        current = HLCard(value: 6, suit: 1)
        next = HLCard(value: 11, suit: 0)
        round = 4
    }

    func ask() {
        Speech.say(L.t("いまは\(spoken(current))。次は大きい？小さい？", "This is \(spoken(current)). Will the next card be higher or lower?"))
    }

    private func spoken(_ c: HLCard) -> String {
        switch c.value {
        case 1: return L.t("エース、1", "an ace, one")
        case 11: return L.t("ジャック、11", "a jack, eleven")
        case 12: return L.t("クイーン、12", "a queen, twelve")
        case 13: return L.t("キング、13", "a king, thirteen")
        default: return "\(c.value)"
        }
    }

    func flip() {
        guard next == nil, !flipping else { return }
        token += 1
        let t = token
        flipping = true
        Speech.stop()
        Sfx.drumroll(1.4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self, self.token == t else { return }
            var n = HLCard.random()
            while n == self.current { n = HLCard.random() }
            self.next = n
            self.flipping = false
            Sfx.drum()
            switch self.outcome {
            case .higher: Speech.say(L.t("\(self.spoken(n))。大きい！", "\(self.spoken(n)). Higher!"))
            case .lower: Speech.say(L.t("\(self.spoken(n))。小さい！", "\(self.spoken(n)). Lower!"))
            default: Speech.say(L.t("\(self.spoken(n))。同じ！", "\(self.spoken(n)). The same!"))
            }
        }
    }

    func advance() {
        guard let n = next else { return }
        current = n
        next = nil
        round += 1
        ask()
    }

    func restart() {
        token += 1
        flipping = false
        current = HLCard.random()
        next = nil
        round = 1
        ask()
    }

    override func stage() -> AnyView { AnyView(HighLowStage(g: self)) }
    override func controls() -> AnyView { AnyView(HighLowControls(g: self)) }
}

private struct HLCardView: View {
    let card: HLCard?
    var highlight: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36)
                .fill(card == nil ? Theme.blue : Theme.card)
                .overlay(RoundedRectangle(cornerRadius: 36).stroke(highlight ? Theme.gold : Theme.ink.opacity(0.2), lineWidth: highlight ? 10 : 4))
                .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
            if let c = card {
                face(c)
            } else {
                back
            }
        }
        .frame(width: 330, height: 470)
    }

    private func face(_ c: HLCard) -> some View {
        let color = c.isRed ? Theme.accent : Theme.ink
        return VStack(spacing: 0) {
            Text(c.suitSymbol).font(.system(size: 90)).foregroundStyle(color)
            Text(c.face).font(.big(200)).foregroundStyle(color).minimumScaleFactor(0.5)
            Text(c.value == 1 || c.value > 10 ? "= \(c.value)" : " ")
                .font(.big(44)).foregroundStyle(Theme.sub)
        }
    }

    private var back: some View {
        VStack(spacing: 10) {
            Text("?").font(.big(220)).foregroundStyle(.white)
        }
        .frame(width: 290, height: 430)
        .background(RoundedRectangle(cornerRadius: 26).stroke(.white.opacity(0.6), lineWidth: 6))
    }
}

struct HighLowStage: View {
    @ObservedObject var g: HighLowGame

    var body: some View {
        VStack(spacing: 18) {
            Text(L.t("\(g.round)回目", "Round \(g.round)"))
                .font(.big(40))
                .foregroundStyle(Theme.sub)
            HStack(spacing: 60) {
                HLCardView(card: g.current)
                middle
                HLCardView(card: g.next, highlight: g.next != nil)
                    .rotation3DEffect(.degrees(g.flipping ? 12 : 0), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(g.flipping ? 1.05 : 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.4), value: g.next)
        .animation(.easeInOut(duration: 0.25).repeatCount(g.flipping ? 5 : 1, autoreverses: true), value: g.flipping)
    }

    @ViewBuilder
    private var middle: some View {
        VStack(spacing: 16) {
            switch g.outcome {
            case .higher?:
                resultText("⬆️", L.t("大きい！", "Higher!"), Theme.accent)
            case .lower?:
                resultText("⬇️", L.t("小さい！", "Lower!"), Theme.blue)
            case .same?:
                resultText("🟰", L.t("同じ！", "Same!"), Theme.green)
            case nil:
                Text(L.t("次は", "Next is")).font(.big(56)).foregroundStyle(Theme.ink)
                Text(L.t("大きい？", "higher?")).font(.big(76)).foregroundStyle(Theme.accent)
                Text(L.t("小さい？", "lower?")).font(.big(76)).foregroundStyle(Theme.blue)
            }
        }
        .frame(width: 420)
    }

    private func resultText(_ emoji: String, _ text: String, _ color: Color) -> some View {
        VStack(spacing: 10) {
            Text(emoji).font(.system(size: 130))
            Text(text).font(.big(90)).foregroundStyle(color).lineLimit(1).minimumScaleFactor(0.5)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

struct HighLowControls: View {
    @ObservedObject var g: HighLowGame

    var body: some View {
        VStack(spacing: 12) {
            if g.next == nil {
                HostButton(title: L.t("めくる", "Flip"), symbol: "rectangle.portrait.on.rectangle.portrait.angled.fill",
                           color: g.flipping ? Theme.hostCard : Theme.green, big: true) { g.flip() }
                HostButton(title: L.t("もう一度読む", "Read again"), symbol: "speaker.wave.2.fill", color: Theme.blue) { g.ask() }
            } else {
                HostButton(title: L.t("次へ", "Next"), symbol: "arrow.right", color: Theme.blue, big: true) { g.advance() }
            }
            HostButton(title: L.t("最初から", "Start over"), symbol: "arrow.counterclockwise", color: Theme.hostCard) { g.restart() }
        }
    }
}
