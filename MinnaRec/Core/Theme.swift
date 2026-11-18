import SwiftUI

enum Theme {
    static let bg = Color(red: 0.99, green: 0.96, blue: 0.88)
    static let card = Color.white
    static let ink = Color(red: 0.12, green: 0.11, blue: 0.17)
    static let sub = Color(red: 0.40, green: 0.37, blue: 0.42)
    static let accent = Color(red: 0.86, green: 0.29, blue: 0.20)
    static let gold = Color(red: 0.95, green: 0.68, blue: 0.10)
    static let green = Color(red: 0.16, green: 0.58, blue: 0.36)
    static let blue = Color(red: 0.17, green: 0.40, blue: 0.78)
    static let hostBg = Color(red: 0.14, green: 0.15, blue: 0.20)
    static let hostCard = Color(red: 0.22, green: 0.23, blue: 0.29)

    /// 大きい画面（ステージ）の仮想サイズ。どの画面でもこの大きさで組んで拡大縮小する
    static let stageW: CGFloat = 1600
    static let stageH: CGFloat = 900
}

extension Font {
    /// 太く丸い字。ステージ用
    static func big(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
    static func round(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font { .system(size: size, weight: weight, design: .rounded) }
}

/// 1600×900 で組んだ中身を、画面に合わせて縮める
struct StageCanvas<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / Theme.stageW, geo.size.height / Theme.stageH)
            content
                .frame(width: Theme.stageW, height: Theme.stageH)
                .scaleEffect(s)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(Theme.bg)
        .ignoresSafeArea()
    }
}

/// ステージ上の白いカード
struct StageCard<Content: View>: View {
    var padding: CGFloat = 36
    let content: Content
    init(padding: CGFloat = 36, @ViewBuilder _ content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(RoundedRectangle(cornerRadius: 40).fill(Theme.card))
            .overlay(RoundedRectangle(cornerRadius: 40).stroke(Theme.ink.opacity(0.12), lineWidth: 3))
            .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }
}

/// 係の人の操作盤で使う大きいボタン
struct HostButton: View {
    let title: String
    var symbol: String? = nil
    var color: Color = Theme.blue
    var big = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let symbol { Image(systemName: symbol).font(.round(big ? 28 : 22)) }
                Text(title).font(.round(big ? 26 : 20)).lineLimit(1).minimumScaleFactor(0.6)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: big ? 76 : 58)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 16).fill(color))
        }
        .buttonStyle(.plain)
    }
}
