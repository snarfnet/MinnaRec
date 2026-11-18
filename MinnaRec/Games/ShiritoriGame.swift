import SwiftUI

/// お題ばくだん：お題に合うことばを言って次の人へ回す。いつ爆発するかはわからない
final class ShiritoriGame: GameEngine {
    enum Phase { case ready, burning, exploded }

    @Published var phase: Phase = .ready
    @Published var topicIndex = 0
    @Published var passes = 0
    @Published var flash = 0
    @Published var elapsed: Double = 0
    @Published var shake: CGFloat = 0

    let topics: [String]
    private var total: Double = 30
    private var token = 0
    static let maxTime: Double = 45

    init() {
        topics = ShiritoriGame.allTopics().shuffled()
        super.init(id: .shiritori)
    }

    override var usesTeams: Bool { false }

    var topic: String { topics[topicIndex % topics.count] }
    /// 導火線の残り（本当の残り時間は見せない）
    var fuseLeft: Double { max(0.08, 1 - elapsed / ShiritoriGame.maxTime) }

    private func later(_ sec: Double, _ t: Int, _ f: @escaping @MainActor () -> Void) {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(0, sec) * 1_000_000_000))
            guard let self, self.token == t else { return }
            f()
        }
    }

    override func begin() {
        super.begin()
        Speech.say(L.t("お題は、", "The topic is ") + topic)
    }

    func light() {
        guard phase != .burning else { return }
        token += 1
        phase = .burning
        passes = 0
        elapsed = 0
        total = Double.random(in: 15...45)
        Speech.say(L.t("お題は、\(topic)。スタート！", "Topic: \(topic). Go!"))
        tick(token)
    }

    private func tick(_ t: Int) {
        let remain = max(0, 1 - elapsed / total)
        let interval = 0.25 + 0.75 * remain
        later(interval, t) { [weak self] in
            guard let self, self.phase == .burning else { return }
            self.elapsed += interval
            Sfx.tick()
            if self.elapsed >= self.total {
                self.explode()
            } else {
                self.tick(t)
            }
        }
    }

    func explode() {
        token += 1
        phase = .exploded
        Speech.stop()
        Sfx.boom()
        shake += 1
    }

    func pass() {
        guard phase == .burning else { return }
        passes += 1
        flash += 1
        Sfx.ding()
    }

    func nextTopic() {
        token += 1
        phase = .ready
        topicIndex += 1
        passes = 0
        elapsed = 0
        Speech.say(L.t("次のお題は、", "Next topic: ") + topic)
    }

    func retry() {
        token += 1
        phase = .ready
        passes = 0
        elapsed = 0
    }

    override func stop() {
        token += 1
        super.stop()
    }

    override func prepareScreenshot() {
        showIntro = false
        phase = .burning
        elapsed = 14
        passes = 5
    }

    override func stage() -> AnyView { AnyView(ShiritoriStage(g: self)) }
    override func controls() -> AnyView { AnyView(ShiritoriControls(g: self)) }

    static func allTopics() -> [String] {
        let list: [(String, String)] = [
            ("「し」で始まることば", "Words that start with S"),
            ("「か」で始まることば", "Words that start with B"),
            ("「た」で始まることば", "Words that start with T"),
            ("赤いもの", "Red things"),
            ("白いもの", "White things"),
            ("丸いもの", "Round things"),
            ("くだもの", "Fruits"),
            ("野菜", "Vegetables"),
            ("動物", "Animals"),
            ("鳥", "Birds"),
            ("海の生き物", "Sea creatures"),
            ("花の名前", "Flowers"),
            ("駅の名前", "Train stations"),
            ("都道府県", "Countries"),
            ("お寿司のネタ", "Sandwich fillings"),
            ("台所にあるもの", "Things in a kitchen"),
            ("冷たいもの", "Cold things"),
            ("甘いもの", "Sweet things"),
            ("乗り物", "Ways to travel"),
            ("スポーツ", "Sports"),
            ("楽器", "Musical instruments"),
            ("季節の行事", "Holidays"),
            ("お祭りの屋台", "Fair food"),
            ("昔の遊び", "Old-time games"),
            ("身につけるもの", "Things you wear"),
        ]
        return list.map { L.t($0.0, $0.1) }
    }
}

private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 34 * sin(amount * .pi * 10), y: 0))
    }
}

struct ShiritoriStage: View {
    @ObservedObject var g: ShiritoriGame

    var body: some View {
        VStack(spacing: 26) {
            topicHeader
            switch g.phase {
            case .ready: readyView
            case .burning: burningView
            case .exploded: explodedView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(ShakeEffect(amount: g.shake))
        .animation(.linear(duration: 0.8), value: g.shake)
    }

    private var topicHeader: some View {
        HStack(spacing: 24) {
            Text(L.t("お題", "Topic"))
                .font(.big(40)).foregroundStyle(.white)
                .padding(.horizontal, 26).padding(.vertical, 10)
                .background(Capsule().fill(g.id.category.color))
            StageText(g.topic, size: 84)
        }
        .padding(.horizontal, 60)
    }

    private var readyView: some View {
        VStack(spacing: 20) {
            Text("💣").font(.system(size: 260))
            StageText(L.t("準備ができたらスタート！", "Ready? Let's start!"), size: 56, color: Theme.sub)
        }
    }

    private var burningView: some View {
        VStack(spacing: 10) {
            bomb
            ZStack {
                Text(L.t("つぎ！ \(g.passes)人目", "Next! Player \(g.passes)"))
                    .font(.big(70))
                    .foregroundStyle(Theme.accent)
                    .id(g.flash)
                    .transition(.scale(scale: 1.6).combined(with: .opacity))
            }
            .frame(height: 100)
            .animation(.spring(response: 0.35), value: g.flash)
        }
    }

    private var bomb: some View {
        let width: CGFloat = 520
        let left = CGFloat(g.fuseLeft)
        let spark = Int(g.elapsed * 4) % 2 == 0
        return HStack(alignment: .top, spacing: 0) {
            Text("💣").font(.system(size: 260))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(red: 0.55, green: 0.38, blue: 0.20))
                    .frame(width: width * left, height: 20)
                Text("✨")
                    .font(.system(size: spark ? 100 : 78))
                    .offset(x: width * left - 50)
            }
            .frame(width: width, height: 120, alignment: .leading)
            .offset(x: -40, y: 30)
        }
        .animation(.linear(duration: 0.3), value: g.elapsed)
    }

    private var explodedView: some View {
        VStack(spacing: 14) {
            Text("💥").font(.system(size: 280))
            StageText(L.t("ドカーン！", "BOOM!"), size: 130, color: Theme.accent)
            StageText(L.t("爆弾を持っていた人、一言どうぞ！", "Whoever had it, say a few words!"), size: 54)
        }
    }
}

struct ShiritoriControls: View {
    @ObservedObject var g: ShiritoriGame

    var body: some View {
        VStack(spacing: 12) {
            switch g.phase {
            case .ready:
                HostButton(title: L.t("スタート", "Start"), symbol: "flame.fill", color: Theme.accent, big: true) { g.light() }
                HostButton(title: L.t("お題をかえる", "Change topic"), symbol: "shuffle", color: Theme.hostCard) { g.nextTopic() }
            case .burning:
                HostButton(title: L.t("次の人へ", "Pass it on"), symbol: "arrow.turn.up.right", color: Theme.green, big: true) { g.pass() }
                Text(L.t("回った人数：\(g.passes)", "Passes: \(g.passes)"))
                    .font(.round(18)).foregroundStyle(.white.opacity(0.8))
                HostButton(title: L.t("いますぐ爆発", "Explode now"), symbol: "burst.fill", color: Theme.hostCard) { g.explode() }
            case .exploded:
                HostButton(title: L.t("次のお題", "Next topic"), symbol: "arrow.right", color: Theme.green, big: true) { g.nextTopic() }
                HostButton(title: L.t("同じお題でもう一回", "Same topic again"), symbol: "arrow.clockwise", color: Theme.hostCard) { g.retry() }
            }
        }
    }
}
