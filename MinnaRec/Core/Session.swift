import SwiftUI

struct Team: Identifiable, Equatable {
    let id: Int
    var score = 0

    static let colors: [Color] = [
        Color(red: 0.88, green: 0.22, blue: 0.22),
        Color(red: 0.55, green: 0.55, blue: 0.58),
        Color(red: 0.17, green: 0.42, blue: 0.82),
        Color(red: 0.15, green: 0.62, blue: 0.35),
    ]

    var color: Color { Team.colors[id % Team.colors.count] }
    var name: String {
        switch id {
        case 0: return L.t("赤組", "Red")
        case 1: return L.t("白組", "White")
        case 2: return L.t("青組", "Blue")
        default: return L.t("緑組", "Green")
        }
    }
}

/// アプリ全体の状態。iPad とプロジェクターの両方の画面がこれを見る
@MainActor
final class Session: ObservableObject {
    static let shared = Session()

    @Published var engine: GameEngine?
    @Published var teams: [Team] = (0..<2).map { Team(id: $0) }
    @Published var showScoreboard = true
    @Published var externalAttached = false
    @Published var panelHidden = false
    @Published var langJa: Bool = L.isJa {
        didSet {
            L.isJa = langJa
            UserDefaults.standard.set(langJa, forKey: "langJa")
        }
    }
    @Published var speechOn: Bool = UserDefaults.standard.object(forKey: "speechOn") as? Bool ?? true {
        didSet { UserDefaults.standard.set(speechOn, forKey: "speechOn") }
    }

    var teamCount: Int {
        get { teams.count }
        set {
            let n = max(1, min(4, newValue))
            if n > teams.count {
                teams += (teams.count..<n).map { Team(id: $0) }
            } else {
                teams = Array(teams.prefix(n))
            }
        }
    }

    func open(_ id: GameID) {
        engine?.stop()
        let e = id.make()
        engine = e
        panelHidden = false
        e.start()
    }

    func close() {
        engine?.stop()
        engine = nil
    }

    func addPoint(_ team: Int, _ delta: Int = 1) {
        guard teams.indices.contains(team) else { return }
        teams[team].score = max(0, teams[team].score + delta)
        if delta > 0 { Sfx.ding() }
    }

    func resetScores() {
        for i in teams.indices { teams[i].score = 0 }
    }
}

/// すべてのゲームの元。stage() は大きい画面、controls() は係の人の操作盤
@MainActor
class GameEngine: ObservableObject {
    let id: GameID
    /// はじめに遊び方を大きく見せる
    @Published var showIntro = true

    init(id: GameID) { self.id = id }

    /// チーム得点を下に出すか
    var usesTeams: Bool { true }
    /// 操作盤の「＋」ボタンで入る点（ヒントが少ないうちは高いなど）
    var pointValue: Int { 1 }
    /// 遊び方の画面で読み上げる文
    var introSpeech: String { ([id.title] + id.rules).joined(separator: "。") }

    func start() {}
    func stop() {
        Speech.stop()
        Synth.shared.stop()
    }
    func begin() { showIntro = false }
    /// App Store 用のスクリーンショットを撮るとき、見ばえのする途中の状態にする
    func prepareScreenshot() { begin() }

    func stage() -> AnyView { AnyView(EmptyView()) }
    func controls() -> AnyView { AnyView(EmptyView()) }
}
