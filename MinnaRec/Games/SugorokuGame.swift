import SwiftUI

fileprivate struct SugoSquare {
    enum Kind { case start, task, advance, rest, goal }
    let kind: Kind
    let ja: String
    let en: String
    var text: String { L.t(ja, en) }
    var emoji: String {
        switch kind {
        case .start: return "🏁"
        case .goal: return "🏆"
        case .advance: return "⏩"
        case .rest: return "☕️"
        case .task: return "⭐️"
        }
    }
}

fileprivate let sugoSquares: [SugoSquare] = [
    SugoSquare(kind: .start, ja: "スタート", en: "Start"),
    SugoSquare(kind: .task, ja: "好きな食べ物を一つ言う", en: "Name a food you love"),
    SugoSquare(kind: .task, ja: "肩を10回まわす", en: "Roll your shoulders 10 times"),
    SugoSquare(kind: .task, ja: "ふるさとの自慢を一言", en: "Say one thing you love about your hometown"),
    SugoSquare(kind: .task, ja: "みんなで拍手を10回", en: "Everyone claps 10 times"),
    SugoSquare(kind: .advance, ja: "2マス進む！", en: "Move ahead 2!"),
    SugoSquare(kind: .task, ja: "好きな歌を少し歌う", en: "Sing a little of a favorite song"),
    SugoSquare(kind: .task, ja: "子どものころの遊びを一つ", en: "Name a game you played as a child"),
    SugoSquare(kind: .task, ja: "両手をグーパー10回", en: "Open and close your hands 10 times"),
    SugoSquare(kind: .task, ja: "となりの人のいい所を一つ", en: "Say something nice about your neighbor"),
    SugoSquare(kind: .task, ja: "好きな季節とその理由", en: "Your favorite season, and why"),
    SugoSquare(kind: .task, ja: "ゆっくり深呼吸を3回", en: "Take 3 slow, deep breaths"),
    SugoSquare(kind: .task, ja: "得意料理を一つ教えて", en: "Tell us your best dish"),
    SugoSquare(kind: .rest, ja: "1回休み　お茶でひと休み", en: "Skip a turn — tea break"),
    SugoSquare(kind: .task, ja: "早口ことば「なまむぎ なまごめ なまたまご」", en: "Tongue twister: \"Red lorry, yellow lorry\""),
    SugoSquare(kind: .task, ja: "その場で足ぶみ20回", en: "March in place 20 times"),
    SugoSquare(kind: .task, ja: "思い出の旅行先を一つ", en: "A trip you still remember"),
    SugoSquare(kind: .advance, ja: "2マス進む！", en: "Move ahead 2!"),
    SugoSquare(kind: .task, ja: "チームで「えい、えい、おー！」", en: "Team cheer: \"Hip, hip, hooray!\""),
    SugoSquare(kind: .task, ja: "今日の楽しみを一つ", en: "Something you look forward to today"),
    SugoSquare(kind: .task, ja: "好きな動物のまねをする", en: "Act out your favorite animal"),
    SugoSquare(kind: .goal, ja: "ゴール！", en: "Goal!"),
]

final class SugorokuGame: GameEngine {
    @Published var positions: [Int] = []
    @Published var turn = 0
    @Published var dice = 1
    @Published var rolling = false
    @Published var moving = false
    /// 止まったマス（お題を大きく出す）
    @Published var landed: Int?
    @Published var resting: [Bool] = []
    @Published var finishOrder: [Int] = []
    private var token = 0

    static var goal: Int { sugoSquares.count - 1 }

    init() {
        super.init(id: .sugoroku)
        restart()
    }

    var teams: [Team] { Session.shared.teams }
    var busy: Bool { rolling || moving }
    var allDone: Bool { finishOrder.count >= teams.count }

    fileprivate func square(_ i: Int) -> SugoSquare { sugoSquares[max(0, min(sugoSquares.count - 1, i))] }

    private func syncTeams() {
        let n = teams.count
        if positions.count != n {
            positions = (0..<n).map { positions.indices.contains($0) ? positions[$0] : 0 }
            resting = (0..<n).map { resting.indices.contains($0) ? resting[$0] : false }
            finishOrder = finishOrder.filter { $0 < n }
            if turn >= n { turn = 0 }
        }
    }

    func restart() {
        token += 1
        positions = Array(repeating: 0, count: teams.count)
        resting = Array(repeating: false, count: teams.count)
        finishOrder = []
        turn = 0
        dice = 1
        rolling = false
        moving = false
        landed = nil
    }

    override func begin() {
        super.begin()
        syncTeams()
        announceTurn()
    }

    override func stop() {
        token += 1
        rolling = false
        moving = false
        super.stop()
    }

    override func prepareScreenshot() {
        showIntro = false
        syncTeams()
        let demo = [9, 6, 12, 3]
        for i in positions.indices { positions[i] = demo[i % demo.count] }
        turn = 0
        dice = 4
        landed = positions[0]
    }

    private func announceTurn() {
        guard teams.indices.contains(turn) else { return }
        Speech.say(L.t("\(teams[turn].name)の番です", "\(teams[turn].name) team's turn"))
    }

    func roll() {
        syncTeams()
        guard !busy, !allDone, positions.indices.contains(turn) else { return }
        token += 1
        let t = token
        rolling = true
        landed = nil
        Speech.stop()
        Sfx.drumroll(1.2)
        rollStep(t, count: 0)
    }

    private func rollStep(_ t: Int, count: Int) {
        guard t == token else { return }
        if count >= 12 {
            rolling = false
            Sfx.drum()
            Speech.say(L.t("\(dice)", "\(dice)"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self else { return }
                self.move(t, steps: self.dice, thenLand: true)
            }
            return
        }
        var v = Int.random(in: 1...6)
        while v == dice { v = Int.random(in: 1...6) }
        dice = v
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.rollStep(t, count: count + 1)
        }
    }

    private func move(_ t: Int, steps: Int, thenLand: Bool) {
        guard t == token, positions.indices.contains(turn) else { return }
        moving = true
        stepOnce(t, left: steps, thenLand: thenLand)
    }

    private func stepOnce(_ t: Int, left: Int, thenLand: Bool) {
        guard t == token, positions.indices.contains(turn) else { return }
        if left <= 0 || positions[turn] >= SugorokuGame.goal {
            moving = false
            if thenLand { land(t) }
            return
        }
        positions[turn] += 1
        Sfx.tick()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.stepOnce(t, left: left - 1, thenLand: thenLand)
        }
    }

    private func land(_ t: Int) {
        let pos = positions[turn]
        let sq = square(pos)
        landed = pos
        switch sq.kind {
        case .goal:
            if !finishOrder.contains(turn) { finishOrder.append(turn) }
            Sfx.fanfare()
            let place = finishOrder.count
            Speech.say(L.t("\(teams[turn].name)、ゴール！\(place)着です", "\(teams[turn].name) team reaches the goal! Place \(place)"))
        case .advance:
            Sfx.ding()
            Speech.say(sq.text)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
                guard let self, t == self.token else { return }
                self.moving = true
                self.advanceTwo(t)
            }
        case .rest:
            resting[turn] = true
            Speech.say(sq.text)
        default:
            Speech.say(sq.text)
        }
    }

    /// 「2マス進む」の後は、着いたマスのお題をする（続けて進むことはない）
    private func advanceTwo(_ t: Int) {
        stepOnce(t, left: 2, thenLand: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak self] in
            guard let self, t == self.token, self.positions.indices.contains(self.turn) else { return }
            self.moving = false
            let pos = self.positions[self.turn]
            self.landed = pos
            let sq = self.square(pos)
            if sq.kind == .goal {
                self.land(t)
            } else if sq.kind == .task {
                Speech.say(sq.text)
            }
        }
    }

    func nextTeam() {
        syncTeams()
        guard !busy, !allDone else { return }
        landed = nil
        var next = turn
        for _ in 0..<(teams.count * 2) {
            next = (next + 1) % teams.count
            if finishOrder.contains(next) { continue }
            if resting[next] {
                resting[next] = false
                continue
            }
            break
        }
        turn = next
        announceTurn()
    }

    override func stage() -> AnyView { AnyView(SugorokuStage(g: self)) }
    override func controls() -> AnyView { AnyView(SugorokuControls(g: self)) }
}

struct SugorokuStage: View {
    @ObservedObject var g: SugorokuGame
    @EnvironmentObject var s: Session

    private let perRow = 11

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 12) {
                row(Array(0..<perRow))
                row(Array((perRow..<sugoSquares.count).reversed()))
            }
            HStack(spacing: 40) {
                diceView
                taskCard
            }
            .padding(.horizontal, 60)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: g.positions)
        .animation(.spring(response: 0.4), value: g.landed)
    }

    private func row(_ indices: [Int]) -> some View {
        HStack(spacing: 10) {
            ForEach(indices, id: \.self) { i in
                cell(i)
            }
        }
    }

    private func cell(_ i: Int) -> some View {
        let sq = g.square(i)
        let here = g.positions.indices.filter { g.positions[$0] == i }
        let isLanded = g.landed == i
        return VStack(spacing: 4) {
            Text(sq.kind == .task ? "\(i)" : sq.emoji)
                .font(.big(sq.kind == .task ? 34 : 40))
                .foregroundStyle(Theme.ink.opacity(0.7))
            pieces(here)
        }
        .frame(width: 118, height: 128)
        .background(RoundedRectangle(cornerRadius: 20).fill(cellColor(sq.kind)))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isLanded ? Theme.accent : Theme.ink.opacity(0.15), lineWidth: isLanded ? 7 : 3))
    }

    private func cellColor(_ k: SugoSquare.Kind) -> Color {
        switch k {
        case .start: return Theme.green.opacity(0.25)
        case .goal: return Theme.gold.opacity(0.45)
        case .advance: return Theme.blue.opacity(0.22)
        case .rest: return Color.brown.opacity(0.2)
        case .task: return Theme.card
        }
    }

    private func pieces(_ teamIDs: [Int]) -> some View {
        let first = Array(teamIDs.prefix(2))
        let second = Array(teamIDs.dropFirst(2).prefix(2))
        return VStack(spacing: 4) {
            HStack(spacing: 4) { ForEach(first, id: \.self) { piece($0) } }
            HStack(spacing: 4) { ForEach(second, id: \.self) { piece($0) } }
        }
        .frame(height: 70)
    }

    private func piece(_ team: Int) -> some View {
        let color = s.teams.indices.contains(team) ? s.teams[team].color : .gray
        return Circle()
            .fill(color)
            .frame(width: 32, height: 32)
            .overlay(Circle().stroke(.white, lineWidth: 3))
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            .scaleEffect(team == g.turn ? 1.15 : 1)
    }

    private var diceView: some View {
        VStack(spacing: 12) {
            if s.teams.indices.contains(g.turn) {
                Text(L.t("\(s.teams[g.turn].name)の番", "\(s.teams[g.turn].name)'s turn"))
                    .font(.big(40))
                    .foregroundStyle(s.teams[g.turn].color)
            }
            Image(systemName: "die.face.\(g.dice).fill")
                .font(.system(size: 190))
                .foregroundStyle(Theme.ink)
                .rotationEffect(.degrees(g.rolling ? Double(g.dice * 37 % 40) - 20 : 0))
                .scaleEffect(g.rolling ? 0.9 : 1)
        }
        .frame(width: 340)
    }

    @ViewBuilder
    private var taskCard: some View {
        StageCard(padding: 30) {
            VStack(spacing: 14) {
                if let i = g.landed {
                    let sq = g.square(i)
                    Text(sq.emoji).font(.system(size: 80))
                    StageText(sq.text, size: 64)
                } else if g.allDone {
                    StageText(L.t("みんなゴール！おめでとう！", "Everyone made it! Well done!"), size: 64, color: Theme.accent)
                } else if g.busy {
                    StageText(L.t("すすむよ…", "Moving..."), size: 64, color: Theme.sub)
                } else {
                    StageText(L.t("サイコロをふってください", "Roll the dice"), size: 64, color: Theme.sub)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 230)
        }
    }
}

struct SugorokuControls: View {
    @ObservedObject var g: SugorokuGame
    @EnvironmentObject var s: Session
    @State private var confirmRestart = false

    var body: some View {
        VStack(spacing: 12) {
            if s.teams.indices.contains(g.turn), !g.allDone {
                Text(L.t("いまは \(s.teams[g.turn].name)", "Now: \(s.teams[g.turn].name)"))
                    .font(.round(20, .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if g.allDone {
                HostButton(title: L.t("もう一回", "Play again"), symbol: "arrow.clockwise", color: Theme.green, big: true) { g.restart() }
            } else if g.landed == nil {
                HostButton(title: L.t("サイコロをふる", "Roll the dice"), symbol: "dice.fill", color: g.busy ? Theme.hostCard : Theme.green, big: true) { g.roll() }
            } else {
                HostButton(title: L.t("次のチーム", "Next team"), symbol: "arrow.right", color: g.busy ? Theme.hostCard : Theme.blue, big: true) { g.nextTeam() }
            }
            HostButton(title: L.t("最初から", "Start over"), symbol: "arrow.counterclockwise", color: Theme.hostCard) { confirmRestart = true }
        }
        .alert(L.t("最初からにしますか？", "Start over?"), isPresented: $confirmRestart) {
            Button(L.t("最初から", "Start over"), role: .destructive) { g.restart() }
            Button(L.t("やめる", "Cancel"), role: .cancel) {}
        }
    }
}
