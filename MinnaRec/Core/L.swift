import Foundation

/// 日本語・英語の切り替え。L.t("日本語", "English")
enum L {
    static var isJa: Bool = {
        if UserDefaults.standard.object(forKey: "langJa") != nil { return UserDefaults.standard.bool(forKey: "langJa") }
        return (Locale.preferredLanguages.first ?? "ja").hasPrefix("ja")
    }()

    static func t(_ ja: String, _ en: String) -> String { isJa ? ja : en }
}
