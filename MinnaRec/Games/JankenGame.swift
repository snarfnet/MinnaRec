import SwiftUI

/// じゃんけん大会：画面とじゃんけんして、勝った人が残る
final class JankenGame: GameEngine {
    enum Phase { case idle, calling, shown }

    struct Hand {
        let emoji: String
        let ja: String
        let en: String
        var name: String { L.t(ja, en) }
    }

    static let hands: [Hand] = [
        Hand(emoji: "✊", ja: "グー", en: "Rock"),
        Hand(emoji: "✌️", ja: "チョキ", en: "Scissors"),
        Hand(emoji: "✋", ja: "パー", en: "Paper"),
    ]

    @Published var phase: Phase = .idle
    @Published var handIndex = 0
    @Published var round = 0

    private var token = 0

    init() { super.init(id: .janken) }

    override var usesTeams: Bool { false }

    var hand: Hand { JankenGame.hands[handIndex] }
    /// 画面の手に勝つ手（グー→パー、チョキ→グー、パー→チョキ）
    var winner: Hand { JankenGame.hands[(handIndex + 2) % 3] }

    private func later(_ sec: Double, _ t: Int, _ f: @escaping @MainActor () -> Void) {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(0, sec) * 1_000_000_000))
            guard let self, self.token == t else { return }
            f()
        }
    }

    func play() {
        token += 1
        let t = token
        phase = .calling
        Sfx.drum()
        Speech.say(L.t("じゃんけん", "Rock, paper, scissors"), rate: 0.5, force: true)
        later(L.isJa ? 1.3 : 1.9, t) { [weak self] in
            guard let self else { return }
            self.handIndex = Int.random(in: 0..<3)
            self.round += 1
            self.phase = .shown
            Sfx.drum()
            Speech.say(L.t("ぽん！", "Go!"), rate: 0.5, force: true)
            self.later(1.3, t) { [weak self] in
                guard let self else { return }
                Speech.say(L.t("勝ったのは、\(self.winner.name)を出した人です", "\(self.winner.name) wins this time"))
            }
        }
    }

    func resetRounds() {
        token += 1
        round = 0
        phase = .idle
    }

    override func stop() {
        token += 1
        super.stop()
    }

    override func prepareScreenshot() {
        showIntro = false
        handIndex = 0
        round = 3
        phase = .shown
    }

    override func stage() -> AnyView { AnyView(JankenStage(g: self)) }
    override func controls() -> AnyView { AnyView(JankenControls(g: self)) }
}

struct JankenStage: View {
    @ObservedObject var g: JankenGame

    var body: some View {
        VStack(spacing: 20) {
            if g.round > 0 || g.phase == .calling {
                Text(L.t("第\(roundNumber)回戦", "Round \(roundNumber)"))
                    .font(.big(38)).foregroundStyle(Theme.sub)
            }
            switch g.phase {
            case .idle: idleView
            case .calling: callingView
            case .shown: shownView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: g.phase)
    }

    private var roundNumber: Int {
        let n = g.phase == .calling ? g.round + 1 : g.round
        return max(1, n)
    }

    private var idleView: some View {
        VStack(spacing: 30) {
            Text("✊ ✌️ ✋").font(.system(size: 200))
            StageText(L.t("準備はいいですか？", "Ready?"), size: 90)
        }
    }

    private var callingView: some View {
        VStack(spacing: 20) {
            Text("❓").font(.system(size: 260))
            StageText(L.t("じゃんけん…", "Rock, paper, scissors…"), size: 120, color: Theme.accent)
        }
        .transition(.scale.combined(with: .opacity))
    }

    private var shownView: some View {
        VStack(spacing: 14) {
            HStack(spacing: 40) {
                Text(g.hand.emoji).font(.system(size: 300))
                VStack(alignment: .leading, spacing: 4) {
                    StageText(L.t("ぽん！", "GO!"), size: 110, color: Theme.accent)
                    StageText(g.hand.name, size: 100)
                }
            }
            .transition(.scale(scale: 0.3).combined(with: .opacity))
            HStack(spacing: 20) {
                StageText(L.t("勝ち：", "Winner: "), size: 56, color: .white)
                Text(g.winner.emoji).font(.system(size: 90))
                StageText(L.t("\(g.winner.name)を出した人", "\(g.winner.name)"), size: 56, color: .white)
            }
            .padding(.horizontal, 40).padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 30).fill(Theme.green))
            StageText(L.t("勝った人は手をあげて！", "Winners, raise your hand!"), size: 54)
        }
    }
}

struct JankenControls: View {
    @ObservedObject var g: JankenGame

    var body: some View {
        VStack(spacing: 12) {
            HostButton(title: L.t("じゃんけん！", "Rock, paper, scissors!"), symbol: "hand.raised.fill", color: Theme.green, big: true) { g.play() }
                .disabled(g.phase == .calling)
                .opacity(g.phase == .calling ? 0.5 : 1)
            Text(L.t("回数：\(g.round)", "Rounds: \(g.round)"))
                .font(.round(18)).foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            HostButton(title: L.t("最初から", "Start over"), symbol: "arrow.counterclockwise", color: Theme.hostCard) { g.resetRounds() }
        }
    }
}
