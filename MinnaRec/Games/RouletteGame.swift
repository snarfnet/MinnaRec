import SwiftUI

fileprivate struct RouletteTopic {
    let emoji: String
    let shortJa: String
    let shortEn: String
    let ja: String
    let en: String
    var short: String { L.t(shortJa, shortEn) }
    var text: String { L.t(ja, en) }
}

fileprivate enum RouletteTopicSet: Int, CaseIterable {
    case memories, favorites, whatIf

    var title: String {
        switch self {
        case .memories: return L.t("思い出", "Memories")
        case .favorites: return L.t("好きなもの", "Favorites")
        case .whatIf: return L.t("もしも", "What if")
        }
    }

    var topics: [RouletteTopic] {
        switch self {
        case .memories: return [
            RouletteTopic(emoji: "🪀", shortJa: "遊び", shortEn: "Games", ja: "子どものころ、どんな遊びをしましたか？", en: "What games did you play as a child?"),
            RouletteTopic(emoji: "🛍️", shortJa: "初めての買い物", shortEn: "First buy", ja: "自分のお金で初めて買った物は？", en: "What was the first thing you bought with your own money?"),
            RouletteTopic(emoji: "🚂", shortJa: "旅行", shortEn: "A trip", ja: "思い出に残っている旅行は？", en: "Which trip do you remember best?"),
            RouletteTopic(emoji: "🏫", shortJa: "学校", shortEn: "School", ja: "学校で楽しかったことは？", en: "What did you enjoy at school?"),
            RouletteTopic(emoji: "🍱", shortJa: "お弁当", shortEn: "Lunch", ja: "思い出のお弁当やおやつは？", en: "A lunch or snack you remember?"),
            RouletteTopic(emoji: "🎐", shortJa: "夏休み", shortEn: "Summer", ja: "夏休みの思い出を教えてください", en: "Tell us about a summer vacation"),
            RouletteTopic(emoji: "💼", shortJa: "仕事", shortEn: "Work", ja: "初めての仕事はどんなでしたか？", en: "What was your first job like?"),
            RouletteTopic(emoji: "📺", shortJa: "テレビ", shortEn: "TV", ja: "夢中で見たテレビ番組は？", en: "A TV show you loved?"),
            RouletteTopic(emoji: "🎎", shortJa: "お祭り", shortEn: "Festivals", ja: "ふるさとのお祭りや行事は？", en: "A festival from your hometown?"),
            RouletteTopic(emoji: "🏠", shortJa: "家", shortEn: "Home", ja: "子どものころの家はどんなでしたか？", en: "What was your childhood home like?"),
            RouletteTopic(emoji: "🎒", shortJa: "通学路", shortEn: "Walk to school", ja: "学校への道で覚えていることは？", en: "What do you remember about the way to school?"),
            RouletteTopic(emoji: "💌", shortJa: "うれしかった", shortEn: "Happy moment", ja: "言われてうれしかった一言は？", en: "Kind words you still remember?"),
        ]
        case .favorites: return [
            RouletteTopic(emoji: "🍣", shortJa: "食べ物", shortEn: "Food", ja: "いちばん好きな食べ物は？", en: "What is your favorite food?"),
            RouletteTopic(emoji: "🌸", shortJa: "季節", shortEn: "Season", ja: "好きな季節とその理由は？", en: "Your favorite season, and why?"),
            RouletteTopic(emoji: "🍳", shortJa: "得意料理", shortEn: "Best dish", ja: "あなたの得意料理は？", en: "What dish do you make best?"),
            RouletteTopic(emoji: "🎤", shortJa: "歌", shortEn: "Song", ja: "好きな歌や歌手は？", en: "A favorite song or singer?"),
            RouletteTopic(emoji: "🐶", shortJa: "動物", shortEn: "Animal", ja: "好きな動物は？飼ったことは？", en: "A favorite animal? Ever had a pet?"),
            RouletteTopic(emoji: "🌼", shortJa: "花", shortEn: "Flower", ja: "好きな花は？", en: "What flower do you like?"),
            RouletteTopic(emoji: "🗾", shortJa: "名物", shortEn: "Local food", ja: "ふるさとの名物を教えてください", en: "A famous food from your hometown?"),
            RouletteTopic(emoji: "🎬", shortJa: "映画", shortEn: "Movie", ja: "心に残っている映画は？", en: "A movie that stayed with you?"),
            RouletteTopic(emoji: "☕️", shortJa: "飲み物", shortEn: "Drink", ja: "好きな飲み物は？", en: "What do you like to drink?"),
            RouletteTopic(emoji: "🧶", shortJa: "趣味", shortEn: "Hobby", ja: "好きなことや趣味は？", en: "What hobbies do you enjoy?"),
            RouletteTopic(emoji: "🌅", shortJa: "時間", shortEn: "Time of day", ja: "一日のうち好きな時間は？", en: "Your favorite time of day?"),
            RouletteTopic(emoji: "🍡", shortJa: "おやつ", shortEn: "Sweets", ja: "好きなおやつは？", en: "Your favorite sweet treat?"),
        ]
        case .whatIf: return [
            RouletteTopic(emoji: "💰", shortJa: "百万円", shortEn: "A fortune", ja: "もしも百万円もらったら？", en: "If you were given a small fortune?"),
            RouletteTopic(emoji: "🕰️", shortJa: "昔に戻る", shortEn: "Time travel", ja: "もしも昔に戻れたら、何歳に？", en: "If you could go back, what age would you pick?"),
            RouletteTopic(emoji: "✈️", shortJa: "どこへでも", shortEn: "Anywhere", ja: "もしもどこへでも行けたら？", en: "If you could go anywhere?"),
            RouletteTopic(emoji: "🦸", shortJa: "超能力", shortEn: "Superpower", ja: "もしも一つ超能力があったら？", en: "If you had one superpower?"),
            RouletteTopic(emoji: "🐦", shortJa: "生まれ変わり", shortEn: "Reborn", ja: "生まれ変わるなら何になりたい？", en: "If you were reborn, what would you be?"),
            RouletteTopic(emoji: "🍽️", shortJa: "最後のごはん", shortEn: "Dream meal", ja: "もしも何でも食べられるなら？", en: "If you could eat anything at all?"),
            RouletteTopic(emoji: "🏝️", shortJa: "無人島", shortEn: "Island", ja: "無人島に一つ持っていくなら？", en: "One thing to take to a desert island?"),
            RouletteTopic(emoji: "👑", shortJa: "一日王様", shortEn: "King for a day", ja: "もしも一日王様になったら？", en: "If you were king for a day?"),
            RouletteTopic(emoji: "🐱", shortJa: "動物と話す", shortEn: "Talk to animals", ja: "動物と話せたら何を聞く？", en: "If you could talk to animals, what would you ask?"),
            RouletteTopic(emoji: "🎓", shortJa: "習いごと", shortEn: "Learn", ja: "今から何でも習えるなら？", en: "If you could learn anything now?"),
            RouletteTopic(emoji: "📮", shortJa: "手紙", shortEn: "A letter", ja: "昔の自分に手紙を書くなら？", en: "A letter to your younger self?"),
            RouletteTopic(emoji: "🏡", shortJa: "夢の家", shortEn: "Dream home", ja: "どんな家に住んでみたい？", en: "What would your dream home be like?"),
        ]
        }
    }
}

final class RouletteGame: GameEngine {
    @Published fileprivate var set: RouletteTopicSet = .memories
    /// 円盤の回転（度、時計回り）
    @Published var angle: Double = 0
    @Published var spinning = false
    @Published var selected: Int?
    private var token = 0

    static let spinSeconds = 5.0

    init() { super.init(id: .roulette) }

    override var usesTeams: Bool { false }

    fileprivate var topics: [RouletteTopic] { set.topics }
    var count: Int { topics.count }
    var segment: Double { 360.0 / Double(count) }
    var setTitle: String { set.title }

    override func stop() {
        token += 1
        spinning = false
        super.stop()
    }

    override func prepareScreenshot() {
        showIntro = false
        selected = 2
        angle = -(Double(2) + 0.5) * segment
    }

    func nextSet() {
        guard !spinning else { return }
        let all = RouletteTopicSet.allCases
        set = all[(set.rawValue + 1) % all.count]
        selected = nil
    }

    /// 針（真上）の下にあるマス
    private func indexUnderPointer() -> Int {
        let a = (-angle).truncatingRemainder(dividingBy: 360)
        let r = a < 0 ? a + 360 : a
        return min(count - 1, Int(r / segment))
    }

    func spin() {
        guard !spinning else { return }
        token += 1
        let t = token
        spinning = true
        selected = nil
        Speech.stop()
        let target = Int.random(in: 0..<count)
        // 止める角度：そのマスの中ほど。今の位置から5〜6回転
        let inside = Double.random(in: 0.2...0.8)
        let desired = -((Double(target) + inside) * segment)
        var delta = (desired - angle).truncatingRemainder(dividingBy: 360)
        if delta > 0 { delta -= 360 }
        let spins = Double(Int.random(in: 5...6)) * 360
        withAnimation(.timingCurve(0.15, 0.65, 0.2, 1, duration: RouletteGame.spinSeconds)) {
            angle += delta - spins
        }
        Sfx.drumroll(RouletteGame.spinSeconds - 0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + RouletteGame.spinSeconds + 0.1) { [weak self] in
            guard let self, self.token == t else { return }
            self.spinning = false
            let i = self.indexUnderPointer()
            self.selected = i
            Sfx.drum()
            Speech.say(self.topics[i].text)
        }
    }

    func readAgain() {
        if let i = selected { Speech.say(topics[i].text) }
    }

    override func stage() -> AnyView { AnyView(RouletteStage(g: self)) }
    override func controls() -> AnyView { AnyView(RouletteControls(g: self)) }
}

private let rouletteColors: [Color] = [
    Color(red: 0.93, green: 0.36, blue: 0.33), Color(red: 0.98, green: 0.70, blue: 0.22),
    Color(red: 0.36, green: 0.70, blue: 0.40), Color(red: 0.30, green: 0.55, blue: 0.88),
    Color(red: 0.62, green: 0.42, blue: 0.80), Color(red: 0.95, green: 0.52, blue: 0.68),
]

private struct RouletteSlice: Shape {
    let start: Double
    let end: Double

    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.move(to: c)
        p.addArc(center: c, radius: rect.width / 2, startAngle: .degrees(start), endAngle: .degrees(end), clockwise: false)
        p.closeSubpath()
        return p
    }
}

struct RouletteStage: View {
    @ObservedObject var g: RouletteGame

    private let size: CGFloat = 600

    var body: some View {
        HStack(spacing: 50) {
            wheelWithPointer
            topicCard
        }
        .padding(.horizontal, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var wheelWithPointer: some View {
        ZStack(alignment: .top) {
            wheel
                .rotationEffect(.degrees(g.angle))
                .padding(.top, 30)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 70))
                .foregroundStyle(Theme.ink)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
        .frame(width: size, height: size + 30)
    }

    private var wheel: some View {
        ZStack {
            ForEach(0..<g.count, id: \.self) { i in
                slice(i)
            }
            ForEach(0..<g.count, id: \.self) { i in
                label(i)
            }
            Circle().fill(.white).frame(width: 90, height: 90)
                .overlay(Circle().stroke(Theme.ink.opacity(0.3), lineWidth: 6))
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(Theme.ink.opacity(0.8), lineWidth: 10))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }

    private func slice(_ i: Int) -> some View {
        let start = Double(i) * g.segment - 90
        let isSel = g.selected == i
        return RouletteSlice(start: start, end: start + g.segment)
            .fill(rouletteColors[i % rouletteColors.count].opacity(g.selected == nil || isSel ? 1 : 0.55))
            .overlay(RouletteSlice(start: start, end: start + g.segment).stroke(.white, lineWidth: 4))
    }

    private func label(_ i: Int) -> some View {
        let mid = (Double(i) + 0.5) * g.segment
        let topic = g.topics[i]
        return VStack(spacing: 0) {
            Text(topic.emoji).font(.system(size: 46))
            Text(topic.short)
                .font(.big(22))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: 130)
        }
        .offset(y: -size * 0.33)
        .rotationEffect(.degrees(mid))
    }

    private var topicCard: some View {
        StageCard(padding: 40) {
            VStack(spacing: 22) {
                Text(L.t("お題：", "Topic: ") + g.setTitle)
                    .font(.big(34))
                    .foregroundStyle(Theme.sub)
                if let i = g.selected {
                    Text(g.topics[i].emoji).font(.system(size: 120))
                    StageText(g.topics[i].text, size: 70, color: Theme.ink)
                } else if g.spinning {
                    StageText(L.t("くるくる…", "Spinning..."), size: 80, color: Theme.sub)
                } else {
                    StageText(L.t("ルーレットを回します", "Let's spin the wheel"), size: 70, color: Theme.sub)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 440)
        }
        .animation(.spring(response: 0.4), value: g.selected)
    }
}

struct RouletteControls: View {
    @ObservedObject var g: RouletteGame

    var body: some View {
        VStack(spacing: 12) {
            HostButton(title: L.t("回す", "Spin"), symbol: "arrow.clockwise.circle.fill",
                       color: g.spinning ? Theme.hostCard : Theme.green, big: true) { g.spin() }
            HostButton(title: L.t("もう一度読む", "Read again"), symbol: "speaker.wave.2.fill", color: Theme.blue) { g.readAgain() }
            HostButton(title: L.t("お題を変える（いま：\(g.setTitle)）", "Change topics (now: \(g.setTitle))"),
                       symbol: "square.stack.3d.up.fill", color: Theme.hostCard) { g.nextSet() }
        }
    }
}
