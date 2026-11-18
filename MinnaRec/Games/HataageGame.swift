import SwiftUI

/// 旗あげ：右手が赤、左手が白。号令のとおりにあげたりさげたり
final class HataageGame: GameEngine {
    struct Flags: Equatable {
        var red = false
        var white = false
    }

    private struct Part {
        let red: Bool
        let up: Bool
        let negated: Bool
    }

    @Published var flags = Flags()
    @Published var command = ""
    @Published var showAnswer = true
    @Published var auto = false
    @Published var speed = 1
    @Published var count = 0
    @Published var trick = false

    private var token = 0
    static let rates: [Float] = [0.40, 0.50, 0.58]
    static let intervals: [Double] = [5.5, 4.0, 2.8]

    init() {
        super.init(id: .hataage)
        command = L.t("両方さげて、はじめましょう", "Both flags down to start")
    }

    override var usesTeams: Bool { false }

    var speedName: [String] { [L.t("ゆっくり", "Slow"), L.t("ふつう", "Normal"), L.t("はやい", "Fast")] }

    private func later(_ sec: Double, _ t: Int, _ f: @escaping @MainActor () -> Void) {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(0, sec) * 1_000_000_000))
            guard let self, self.token == t else { return }
            f()
        }
    }

    override func stop() {
        token += 1
        auto = false
        super.stop()
    }

    func resetFlags() {
        token += 1
        auto = false
        flags = Flags()
        count = 0
        trick = false
        command = L.t("両方さげて、はじめましょう", "Both flags down to start")
        showAnswer = true
        Speech.say(command)
    }

    func nextCommand() {
        token += 1
        generate()
        showAnswer = false
        count += 1
        Speech.say(command, rate: HataageGame.rates[speed])
        if auto { scheduleAuto(token) }
    }

    private func scheduleAuto(_ t: Int) {
        let interval = HataageGame.intervals[speed]
        later(interval * 0.65, t) { [weak self] in
            self?.showAnswer = true
        }
        later(interval, t) { [weak self] in
            guard let self, self.auto else { return }
            self.nextCommand()
        }
    }

    func toggleAuto() {
        auto.toggle()
        if auto {
            nextCommand()
        } else {
            token += 1
        }
    }

    func revealAnswer() {
        showAnswer = true
        Sfx.tick()
    }

    private func generate() {
        var parts: [Part] = []
        if Double.random(in: 0..<1) < 0.3 {
            let order = [true, false].shuffled()
            for isRed in order {
                parts.append(Part(red: isRed, up: Bool.random(), negated: Double.random(in: 0..<1) < 0.2))
            }
        } else {
            let isRed = Bool.random()
            let current = isRed ? flags.red : flags.white
            let up = Double.random(in: 0..<1) < 0.75 ? !current : current
            parts.append(Part(red: isRed, up: up, negated: Double.random(in: 0..<1) < 0.25))
        }
        for p in parts where !p.negated {
            if p.red { flags.red = p.up } else { flags.white = p.up }
        }
        trick = parts.contains { $0.negated }
        if L.isJa {
            command = parts.map { p -> String in
                let color = p.red ? "赤" : "白"
                let verb: String
                if p.up { verb = p.negated ? "あげない" : "あげて" } else { verb = p.negated ? "さげない" : "さげて" }
                return color + verb
            }.joined(separator: "、")
        } else {
            let text = parts.map { p -> String in
                let color = p.red ? "red" : "white"
                let verb = p.up ? "raise" : "lower"
                return p.negated ? "don't \(verb) \(color)" : "\(verb) \(color)"
            }.joined(separator: ", ")
            let head: String = text.prefix(1).uppercased()
            let rest = String(text.dropFirst())
            command = head + rest + "!"
        }
    }

    override func prepareScreenshot() {
        showIntro = false
        flags = Flags(red: true, white: false)
        command = L.t("赤あげて、白さげない", "Raise red, don't lower white!")
        trick = true
        showAnswer = true
        count = 4
    }

    override func stage() -> AnyView { AnyView(HataageStage(g: self)) }
    override func controls() -> AnyView { AnyView(HataageControls(g: self)) }
}

/// 旗1本
private struct FlagView: View {
    let red: Bool
    let up: Bool
    let neutral: Bool

    var body: some View {
        let cloth: Color = neutral ? Color.gray.opacity(0.35) : (red ? Color(red: 0.88, green: 0.18, blue: 0.18) : .white)
        return VStack(alignment: red ? .leading : .trailing, spacing: 0) {
            Rectangle()
                .fill(cloth)
                .frame(width: 170, height: 115)
                .overlay(Rectangle().stroke(Theme.ink.opacity(0.6), lineWidth: 4))
                .overlay {
                    if neutral {
                        Text("?").font(.big(70)).foregroundStyle(Theme.ink.opacity(0.5))
                    }
                }
            Rectangle()
                .fill(Color(red: 0.55, green: 0.38, blue: 0.20))
                .frame(width: 12, height: 150)
        }
    }
}

struct HataageStage: View {
    @ObservedObject var g: HataageGame

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 24) {
                if g.count > 0 {
                    Text(L.t("\(g.count)回目", "#\(g.count)"))
                        .font(.big(34)).foregroundStyle(Theme.sub)
                }
                StageText(g.command, size: 96, color: Theme.ink)
                if g.showAnswer && g.trick {
                    Text(L.t("ひっかけ！", "Trick!"))
                        .font(.big(44)).foregroundStyle(.white)
                        .padding(.horizontal, 22).padding(.vertical, 8)
                        .background(Capsule().fill(Theme.accent))
                        .transition(.scale)
                }
            }
            .padding(.horizontal, 50)
            .frame(height: 130)
            figure
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.45, dampingFraction: 0.7), value: g.flags)
        .animation(.easeInOut(duration: 0.3), value: g.showAnswer)
    }

    private func yFor(_ up: Bool) -> CGFloat {
        if !g.showAnswer { return -40 }
        return up ? -120 : 90
    }

    /// 見ている人と同じ向きにそろえるため、赤（右手）を画面の右に置く
    private var figure: some View {
        ZStack {
            Text("🧍").font(.system(size: 300))
            FlagView(red: false, up: g.flags.white, neutral: !g.showAnswer)
                .offset(x: -260, y: yFor(g.flags.white))
            FlagView(red: true, up: g.flags.red, neutral: !g.showAnswer)
                .offset(x: 260, y: yFor(g.flags.red))
            HStack {
                label(L.t("左手・白", "Left hand: white"))
                Spacer()
                label(L.t("右手・赤", "Right hand: red"))
            }
            .frame(width: 1100)
            .offset(y: 215)
        }
        .frame(height: 500)
    }

    private func label(_ text: String) -> some View {
        Text(text).font(.big(40)).foregroundStyle(Theme.ink)
            .padding(.horizontal, 20).padding(.vertical, 6)
            .background(Capsule().fill(Theme.card))
    }
}

struct HataageControls: View {
    @ObservedObject var g: HataageGame

    var body: some View {
        VStack(spacing: 12) {
            if !g.auto {
                HostButton(title: L.t("次の号令", "Next call"), symbol: "megaphone.fill", color: Theme.green, big: true) { g.nextCommand() }
                if !g.showAnswer {
                    HostButton(title: L.t("正解を見せる", "Show answer"), symbol: "eye.fill", color: Theme.accent) { g.revealAnswer() }
                }
            }
            HostButton(title: g.auto ? L.t("自動を止める", "Stop auto") : L.t("自動で進める", "Auto mode"),
                       symbol: g.auto ? "pause.fill" : "play.fill", color: g.auto ? Theme.accent : Theme.blue, big: g.auto) { g.toggleAuto() }
            Text(L.t("速さ", "Speed"))
                .font(.round(16)).foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    HostButton(title: g.speedName[i], color: g.speed == i ? Theme.green : Theme.hostCard) { g.speed = i }
                }
            }
            HostButton(title: L.t("両方さげてやり直す", "Reset: both down"), symbol: "arrow.counterclockwise", color: Theme.hostCard) { g.resetFlags() }
        }
    }
}
