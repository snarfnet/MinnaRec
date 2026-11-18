import Foundation

/// `-screenshot <n>` で起動すると、その画面を開いた状態で止まる（App Store 用の撮影）
enum ScreenshotMode {
    static var shot: Int? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return Int(args[i + 1])
    }

    static var isActive: Bool { shot != nil }

    /// 撮る画面の順番。0 はメニュー
    static let plan: [(GameID?, Bool)] = [
        (nil, false),
        (.nenpyo, true),
        (.bingo, true),
        (.shouka, false),
        (.sugoroku, true),
        (.zoom, true),
        (.hataage, false),
        (.roulette, true),
    ]

    @MainActor
    static func apply(_ s: Session) {
        guard let n = shot, plan.indices.contains(n) else { return }
        Speech.stop()
        UserDefaults.standard.set(false, forKey: "speechOn")
        s.teams[0].score = 7
        if s.teams.count > 1 { s.teams[1].score = 5 }
        let (game, hidePanel) = plan[n]
        guard let game else { return }
        s.open(game)
        s.engine?.prepareScreenshot()
        s.panelHidden = hidePanel
    }
}
