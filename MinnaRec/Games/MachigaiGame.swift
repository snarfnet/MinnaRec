import SwiftUI

/// まちがい探し：左右に絵文字の風景を並べ、右だけ3か所ちがう
final class MachigaiGame: GameEngine {
    struct Picture {
        let ja: String
        let en: String
        let cells: [String]
        let alts: [String]
        var title: String { L.t(ja, en) }
    }

    enum DiffKind { case replace, missing, small }

    struct Diff {
        let index: Int
        let kind: DiffKind
        let value: String
    }

    @Published var sceneIndex = 0
    @Published var diffs: [Diff] = []
    @Published var revealed = 0

    let scenes: [Picture]
    static let cols = 5
    static let rows = 4

    init() {
        scenes = MachigaiGame.allScenes().shuffled()
        super.init(id: .machigai)
        makeDiffs()
    }

    var scene: Picture { scenes[sceneIndex % scenes.count] }

    func makeDiffs() {
        let cells = scene.cells
        let candidates = cells.indices.filter { !cells[$0].isEmpty }.shuffled()
        var kinds: [DiffKind] = [.replace, .missing, .small, .replace].shuffled()
        var out: [Diff] = []
        for i in candidates.prefix(3) {
            let kind = kinds.removeFirst()
            switch kind {
            case .replace:
                let options = scene.alts.filter { $0 != cells[i] }
                out.append(Diff(index: i, kind: .replace, value: options.randomElement() ?? "❓"))
            case .missing:
                out.append(Diff(index: i, kind: .missing, value: ""))
            case .small:
                out.append(Diff(index: i, kind: .small, value: cells[i]))
            }
        }
        diffs = out
        revealed = 0
    }

    func diff(at i: Int) -> Diff? { diffs.first { $0.index == i } }

    func isRevealed(_ i: Int) -> Bool {
        guard let pos = diffs.firstIndex(where: { $0.index == i }) else { return false }
        return pos < revealed
    }

    func revealOne() {
        guard revealed < diffs.count else { return }
        revealed += 1
        Sfx.ding()
    }

    func revealAll() {
        revealed = diffs.count
        Sfx.fanfare()
    }

    func nextScene() {
        sceneIndex += 1
        makeDiffs()
        Speech.say(L.t("次の絵です。", "Next picture. ") + scene.title)
    }

    func reshuffle() {
        makeDiffs()
        Sfx.tick()
    }

    override func begin() {
        super.begin()
        Speech.say(L.t("ちがう所が3か所あります。", "There are three differences. ") + scene.title)
    }

    override func prepareScreenshot() {
        showIntro = false
        revealed = 1
    }

    override func stage() -> AnyView { AnyView(MachigaiStage(g: self)) }
    override func controls() -> AnyView { AnyView(MachigaiControls(g: self)) }

    static func split(_ s: String) -> [String] {
        var out = s.filter { $0 != " " }.map { String($0) }
        let need = cols * rows
        if out.count > need { out = Array(out.prefix(need)) }
        while out.count < need { out.append("") }
        return out
    }

    static func allScenes() -> [Picture] {
        [
            Picture(ja: "海", en: "The Sea", cells: split("🌊🐟⛵🌊🐬 🐚🌊🐠🦀🌊 🐙🌊🐡⛵🐳 🏖️🦀🌊🐚🐟"), alts: split("🦈🦑🐢🦞🛥️🪸").filter { !$0.isEmpty }),
            Picture(ja: "畑", en: "The Farm", cells: split("🌽🥕🌽🐄🌻 🥬🍅🌽🥕🐓 🌻🐄🥔🍆🥕 🚜🌽🐓🍅🌻"), alts: split("🐖🐑🥒🌶️🐇🍓").filter { !$0.isEmpty }),
            Picture(ja: "台所", en: "The Kitchen", cells: split("🍳🥄🍴🍚🫖 🍵🔪🥢🍙🧂 🍶🥚🍳🍽️🥄 🍞🧈🥛🍵🍚"), alts: split("🥘🍲🧁🍮🥫🫕").filter { !$0.isEmpty }),
            Picture(ja: "公園", en: "The Park", cells: split("🌳🌸🌳🛝🐦 🌷🐕🌳⛲🌼 🪁🌳🐦🌷🌳 🌸🚲🌼🐕🌳"), alts: split("🐈🦋🌲🎈⚽🌹").filter { !$0.isEmpty }),
            Picture(ja: "動物園", en: "The Zoo", cells: split("🐘🦒🦁🐒🐼 🦓🐧🐻🦛🐘 🐊🦩🐒🦒🐧 🦁🐼🦓🐻🦘"), alts: split("🐯🐨🦏🐫🦉🐆").filter { !$0.isEmpty }),
            Picture(ja: "夜空", en: "The Night Sky", cells: split("🌙⭐✨⭐🌟 ⭐🪐⭐✨⭐ 🌟✨☄️⭐🌙 ⭐✨🌟⭐🛸"), alts: split("☀️🌕🚀🌈🦉💫").filter { !$0.isEmpty }),
            Picture(ja: "くだもの屋さん", en: "The Fruit Stand", cells: split("🍎🍊🍇🍌🍓 🍑🍍🍉🍐🍒 🍋🍎🥝🍈🍊 🍇🍌🍓🍑🥭"), alts: split("🍅🥥🫐🌰🥑🍆").filter { !$0.isEmpty }),
            Picture(ja: "夏祭り", en: "The Summer Festival", cells: split("🏮🎆🍡🏮🎐 👘🍧🏮🎏🥁 🍢🏮🎆🍭👘 🎐🥁🏮🍡🎇"), alts: split("🎈🎠🍙🦊🎎🪭").filter { !$0.isEmpty }),
            Picture(ja: "山", en: "The Mountains", cells: split("🏔️🌲🦌🌲🏕️ 🌲🐿️🍄🌲🦉 🍂🌲🐻🌲🍄 🦅🌲🏕️🐿️🌲"), alts: split("🐗🐇🌸🍁🦊⛺").filter { !$0.isEmpty }),
        ]
    }
}

struct MachigaiStage: View {
    @ObservedObject var g: MachigaiGame

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 30) {
                StageText(g.scene.title, size: 54)
                Text(L.t("あと \(g.diffs.count - g.revealed) か所", "\(g.diffs.count - g.revealed) left"))
                    .font(.big(44)).foregroundStyle(.white)
                    .padding(.horizontal, 26).padding(.vertical, 8)
                    .background(Capsule().fill(Theme.accent))
            }
            HStack(spacing: 50) {
                panel(right: false)
                panel(right: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.4), value: g.revealed)
    }

    private func panel(right: Bool) -> some View {
        VStack(spacing: 8) {
            Text(right ? L.t("右", "Right") : L.t("左", "Left"))
                .font(.big(30)).foregroundStyle(Theme.sub)
            grid(right: right)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 30).fill(Theme.card))
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Theme.ink.opacity(0.15), lineWidth: 4))
        }
    }

    private func grid(right: Bool) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<MachigaiGame.rows, id: \.self) { r in
                HStack(spacing: 0) {
                    ForEach(0..<MachigaiGame.cols, id: \.self) { c in
                        cell(r * MachigaiGame.cols + c, right: right)
                    }
                }
            }
        }
    }

    private func cell(_ i: Int, right: Bool) -> some View {
        let base = g.scene.cells.indices.contains(i) ? g.scene.cells[i] : ""
        var text = base
        var scale: CGFloat = 1
        if right, let d = g.diff(at: i) {
            switch d.kind {
            case .replace: text = d.value
            case .missing: text = ""
            case .small: scale = 0.5
            }
        }
        return ZStack {
            Text(text.isEmpty ? " " : text)
                .font(.system(size: 88))
                .scaleEffect(scale)
            if g.isRevealed(i) {
                Circle()
                    .stroke(Theme.accent, lineWidth: 9)
                    .frame(width: 126, height: 126)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 132, height: 118)
    }
}

struct MachigaiControls: View {
    @ObservedObject var g: MachigaiGame

    var body: some View {
        VStack(spacing: 12) {
            if g.revealed < g.diffs.count {
                HostButton(title: g.revealed == 0 ? L.t("1つめを見せる", "Show the first one") : L.t("次を見せる", "Show the next one"),
                           symbol: "circle.dashed", color: Theme.gold, big: true) { g.revealOne() }
                HostButton(title: L.t("全部見せる", "Show all"), symbol: "eye.fill", color: Theme.accent) { g.revealAll() }
            } else {
                HostButton(title: L.t("次の絵", "Next picture"), symbol: "arrow.right", color: Theme.green, big: true) { g.nextScene() }
            }
            HostButton(title: L.t("同じ絵で別のまちがい", "Same picture, new changes"), symbol: "shuffle", color: Theme.hostCard) { g.reshuffle() }
            if g.revealed < g.diffs.count {
                HostButton(title: L.t("とばす", "Skip"), symbol: "forward.fill", color: Theme.hostCard) { g.nextScene() }
            }
        }
    }
}
