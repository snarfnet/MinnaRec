import SwiftUI

/// 手拍子リズム体操：拍ごとに動きの絵が切り替わる
final class RhythmGame: GameEngine {
    enum Move: Equatable {
        case clap, knee, banzai, shoulder, stomp

        var emoji: String {
            switch self {
            case .clap: return "👏"
            case .knee: return "🦵"
            case .banzai: return "🙌"
            case .shoulder: return "🤲"
            case .stomp: return "🦶"
            }
        }

        var label: String {
            switch self {
            case .clap: return L.t("手をたたく", "Clap")
            case .knee: return L.t("ひざをたたく", "Pat your knees")
            case .banzai: return L.t("ばんざい", "Hands up")
            case .shoulder: return L.t("肩をたたく", "Tap your shoulders")
            case .stomp: return L.t("足ぶみ", "Stomp")
            }
        }

        var short: String {
            switch self {
            case .clap: return L.t("手", "Clap")
            case .knee: return L.t("ひざ", "Knees")
            case .banzai: return L.t("ばんざい", "Up")
            case .shoulder: return L.t("肩", "Shoulders")
            case .stomp: return L.t("足", "Stomp")
            }
        }
    }

    static let patterns: [[Move]] = [
        [.clap, .clap, .knee, .knee],
        [.clap, .knee, .clap, .knee],
        [.clap, .clap, .clap, .banzai],
        [.knee, .knee, .clap, .shoulder],
        [.shoulder, .shoulder, .clap, .clap],
        [.stomp, .stomp, .clap, .clap],
    ]
    static let tempos: [Double] = [60, 80, 100]

    @Published var running = false
    @Published var bpm: Double = 60
    @Published var patternIndex = 0
    /// 始めてからの拍。負の間は「よーい」の数え
    @Published var beat = -4
    @Published var autoChange = true

    private var token = 0

    init() { super.init(id: .rhythm) }

    override var usesTeams: Bool { false }

    var pattern: [Move] { RhythmGame.patterns[patternIndex % RhythmGame.patterns.count] }

    static func name(of p: [Move]) -> String { p.map { $0.short }.joined(separator: "・") }

    var currentMove: Move? { beat >= 0 ? pattern[beat % 4] : nil }

    var nextMove: Move {
        let n = beat + 1
        if n < 0 { return pattern[0] }
        if autoChange && n > 0 && n % 16 == 0 {
            return RhythmGame.patterns[(patternIndex + 1) % RhythmGame.patterns.count][0]
        }
        return pattern[n % 4]
    }

    private func later(_ sec: Double, _ t: Int, _ f: @escaping @MainActor () -> Void) {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(0, sec) * 1_000_000_000))
            guard let self, self.token == t else { return }
            f()
        }
    }

    func play() {
        token += 1
        running = true
        beat = -5
        Speech.say(L.t("よーい", "Ready"))
        step(token)
    }

    func halt() {
        token += 1
        running = false
        beat = -4
    }

    override func stop() {
        halt()
        super.stop()
    }

    private func step(_ t: Int) {
        later(60 / bpm, t) { [weak self] in
            guard let self, self.running else { return }
            self.beat += 1
            if self.autoChange && self.beat > 0 && self.beat % 16 == 0 {
                self.patternIndex = (self.patternIndex + 1) % RhythmGame.patterns.count
            }
            self.sound()
            self.step(t)
        }
    }

    private func sound() {
        guard let m = currentMove else {
            Sfx.tick()
            return
        }
        switch m {
        case .clap: Sfx.clap()
        case .banzai: Sfx.ding()
        default: Sfx.drum()
        }
    }

    func setTempo(_ v: Double) {
        bpm = v
    }

    func setPattern(_ i: Int) {
        patternIndex = i
        if running {
            beat = -1
        }
    }

    override func prepareScreenshot() {
        showIntro = false
        running = true
        patternIndex = 0
        beat = 2
    }

    override func stage() -> AnyView { AnyView(RhythmStage(g: self)) }
    override func controls() -> AnyView { AnyView(RhythmControls(g: self)) }
}

struct RhythmStage: View {
    @ObservedObject var g: RhythmGame

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
                if g.running, let m = g.currentMove {
                    moveView(m)
                } else if g.running {
                    countIn
                } else {
                    overview
                }
                beatRow
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if g.running && g.beat >= -1 {
                preview
            }
        }
    }

    private func moveView(_ m: RhythmGame.Move) -> some View {
        VStack(spacing: 6) {
            Text(m.emoji)
                .font(.system(size: 300))
                .scaleEffect(g.beat % 2 == 0 ? 1.0 : 1.08)
                .animation(.spring(response: 0.18, dampingFraction: 0.5), value: g.beat)
            StageText(m.label, size: 90)
        }
    }

    private var countIn: some View {
        VStack(spacing: 10) {
            StageText(L.t("よーい", "Get ready"), size: 120, color: Theme.accent)
            StageText(RhythmGame.name(of: g.pattern), size: 64, color: Theme.sub)
        }
    }

    private var overview: some View {
        VStack(spacing: 24) {
            StageText(RhythmGame.name(of: g.pattern), size: 70)
            HStack(spacing: 40) {
                ForEach(0..<4, id: \.self) { i in
                    VStack(spacing: 6) {
                        Text(g.pattern[i].emoji).font(.system(size: 160))
                        Text(g.pattern[i].short).font(.big(40)).foregroundStyle(Theme.ink)
                    }
                }
            }
            Text(L.t("テンポ \(Int(g.bpm))", "Tempo \(Int(g.bpm))"))
                .font(.big(36)).foregroundStyle(Theme.sub)
        }
    }

    private var beatRow: some View {
        HStack(spacing: 30) {
            ForEach(0..<4, id: \.self) { i in
                let on = g.running && g.beat >= 0 && g.beat % 4 == i
                let counting = g.running && g.beat < 0 && (g.beat + 4) == i
                Text("\(i + 1)")
                    .font(.big(64))
                    .foregroundStyle(on || counting ? Color.white : Theme.ink.opacity(0.5))
                    .frame(width: 110, height: 110)
                    .background(Circle().fill(on ? g.id.category.color : (counting ? Theme.gold : Theme.card)))
                    .overlay(Circle().stroke(Theme.ink.opacity(0.15), lineWidth: 3))
            }
        }
    }

    private var preview: some View {
        VStack(spacing: 0) {
            Text(L.t("つぎ", "Next")).font(.big(30)).foregroundStyle(Theme.sub)
            Text(g.nextMove.emoji).font(.system(size: 100))
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 26).fill(Theme.card))
        .padding(30)
    }
}

struct RhythmControls: View {
    @ObservedObject var g: RhythmGame

    var body: some View {
        VStack(spacing: 12) {
            if g.running {
                HostButton(title: L.t("ストップ", "Stop"), symbol: "stop.fill", color: Theme.accent, big: true) { g.halt() }
            } else {
                HostButton(title: L.t("スタート", "Start"), symbol: "play.fill", color: Theme.green, big: true) { g.play() }
            }
            caption(L.t("テンポ", "Tempo"))
            HStack(spacing: 8) {
                ForEach(RhythmGame.tempos, id: \.self) { t in
                    HostButton(title: "\(Int(t))", color: g.bpm == t ? Theme.green : Theme.hostCard) { g.setTempo(t) }
                }
            }
            HostButton(title: g.autoChange ? L.t("パターン自動切替：オン", "Auto change: on") : L.t("パターン自動切替：オフ", "Auto change: off"),
                       symbol: "repeat", color: g.autoChange ? Theme.blue : Theme.hostCard) { g.autoChange.toggle() }
            caption(L.t("パターン", "Pattern"))
            ForEach(0..<RhythmGame.patterns.count, id: \.self) { i in
                HostButton(title: RhythmGame.name(of: RhythmGame.patterns[i]),
                           color: g.patternIndex == i ? Theme.green : Theme.hostCard) { g.setPattern(i) }
            }
        }
    }

    private func caption(_ s: String) -> some View {
        Text(s).font(.round(16)).foregroundStyle(.white.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
