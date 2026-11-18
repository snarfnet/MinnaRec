import SwiftUI
import UIKit
import AVFoundation

@main
struct MinnaRecApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var session = Session.shared

    var body: some Scene {
        WindowGroup {
            HostRootView()
                .environmentObject(session)
                .id(session.langJa)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        application.isIdleTimerDisabled = true
        return true
    }
}

/// プロジェクター・テレビ（HDMI / AirPlay）がつながると、Info.plist の設定でこれが呼ばれ、大きい画面にはゲームだけを出す
final class ExternalSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let root = StageView().environmentObject(Session.shared)
        window.rootViewController = UIHostingController(rootView: root)
        window.isHidden = false
        self.window = window
        Task { @MainActor in Session.shared.externalAttached = true }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        window = nil
        Task { @MainActor in Session.shared.externalAttached = false }
    }
}
