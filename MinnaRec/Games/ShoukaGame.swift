import SwiftUI

/// 収録曲。どれも旋律の著作権が切れたもの（民謡・作者が古い曲）
fileprivate struct ShoukaSong {
    let ja: String
    let en: String
    /// Note.parse の書き方（すべてハ長調／イ短調）
    let notes: String
    let bpm: Double
    /// 最初に流す長さ（拍）
    let short: Double
    /// 「もう少し聞く」の長さ（拍）
    let mid: Double

    var title: String { L.t(ja, en) }
    var parsed: [Note] { Note.parse(notes) }
}

fileprivate enum ShoukaBank {
    static let twinkle = "C4:1 C4:1 G4:1 G4:1 A4:1 A4:1 G4:2 F4:1 F4:1 E4:1 E4:1 D4:1 D4:1 C4:2 G4:1 G4:1 F4:1 F4:1 E4:1 E4:1 D4:2 G4:1 G4:1 F4:1 F4:1 E4:1 E4:1 D4:2 C4:1 C4:1 G4:1 G4:1 A4:1 A4:1 G4:2 F4:1 F4:1 E4:1 E4:1 D4:1 D4:1 C4:2"
    static let frog = "C4:1 D4:1 E4:1 F4:1 E4:1 D4:1 C4:2 E4:1 F4:1 G4:1 A4:1 G4:1 F4:1 E4:2 C4:2 C4:2 C4:2 C4:2 C4:0.5 C4:0.5 D4:0.5 D4:0.5 E4:0.5 E4:0.5 F4:0.5 F4:0.5 E4:1 D4:1 C4:2"
    static let butterfly = "G4:1 E4:1 E4:2 F4:1 D4:1 D4:2 C4:1 D4:1 E4:1 F4:1 G4:1 G4:1 G4:2 G4:1 E4:1 E4:1 E4:1 F4:1 D4:1 D4:1 D4:1 C4:1 E4:1 G4:1 G4:1 E4:1 E4:1 E4:2"
    static let mary = "E4:1 D4:1 C4:1 D4:1 E4:1 E4:1 E4:2 D4:1 D4:1 D4:2 E4:1 G4:1 G4:2 E4:1 D4:1 C4:1 D4:1 E4:1 E4:1 E4:1 E4:1 D4:1 D4:1 E4:1 D4:1 C4:4"
    static let london = "G4:1.5 A4:0.5 G4:1 F4:1 E4:1 F4:1 G4:2 D4:1 E4:1 F4:2 E4:1 F4:1 G4:2 G4:1.5 A4:0.5 G4:1 F4:1 E4:1 F4:1 G4:2 D4:2 G4:2 E4:1 C4:3"
    static let birthday = "G4:0.75 G4:0.25 A4:1 G4:1 C5:1 B4:2 G4:0.75 G4:0.25 A4:1 G4:1 D5:1 C5:2 G4:0.75 G4:0.25 G5:1 E5:1 C5:1 B4:1 A4:2 F5:0.75 F5:0.25 E5:1 C5:1 D5:1 C5:3"
    static let jingle = "E4:1 E4:1 E4:2 E4:1 E4:1 E4:2 E4:1 G4:1 C4:1.5 D4:0.5 E4:4 F4:1 F4:1 F4:1.5 F4:0.5 F4:1 E4:1 E4:1 E4:0.5 E4:0.5 E4:1 D4:1 D4:1 E4:1 D4:2 G4:2 E4:1 E4:1 E4:2 E4:1 E4:1 E4:2 E4:1 G4:1 C4:1.5 D4:0.5 E4:4 F4:1 F4:1 F4:1.5 F4:0.5 F4:1 E4:1 E4:1 E4:0.5 E4:0.5 G4:1 G4:1 F4:1 D4:1 C4:4"
    static let auldLangSyne = "G3:1 C4:1.5 C4:0.5 C4:1 E4:1 D4:1.5 C4:0.5 D4:1 E4:1 C4:1.5 C4:0.5 E4:1 G4:1 A4:3 A4:1 G4:1.5 E4:0.5 E4:1 C4:1 D4:1.5 C4:0.5 D4:1 E4:1 C4:1.5 A3:0.5 A3:1 G3:1 C4:3"
    static let sakura = "A4:1 A4:1 B4:2 A4:1 A4:1 B4:2 A4:1 B4:1 C5:1 B4:1 A4:1 B4:0.5 A4:0.5 F4:2 E4:1 C4:1 E4:1 F4:1 E4:1 E4:0.5 C4:0.5 B3:2 A4:1 B4:1 C5:1 B4:1 A4:1 B4:0.5 A4:0.5 F4:2 E4:1 C4:1 E4:1 F4:1 E4:1 E4:0.5 C4:0.5 B3:2 A4:1 A4:1 B4:2 A4:1 A4:1 B4:2 E4:1 F4:1 B4:0.5 A4:0.5 F4:1 E4:4"
    static let yankee = "C4:1 C4:1 D4:1 E4:1 C4:1 E4:1 D4:1 G3:1 C4:1 C4:1 D4:1 E4:1 C4:2 B3:2 C4:1 C4:1 D4:1 E4:1 F4:1 E4:1 D4:1 C4:1 B3:1 G3:1 A3:1 B3:1 C4:2 C4:2"
    static let macdonald = "G4:1 G4:1 G4:1 D4:1 E4:1 E4:1 D4:2 B4:1 B4:1 A4:1 A4:1 G4:3 D4:1 G4:1 G4:1 G4:1 D4:1 E4:1 E4:1 D4:2 B4:1 B4:1 A4:1 A4:1 G4:4"
    static let susanna = "C4:0.5 D4:0.5 E4:1 G4:1 G4:1.5 A4:0.5 G4:1 E4:1 C4:1.5 D4:0.5 E4:1 E4:1 D4:1 C4:1 D4:3 C4:0.5 D4:0.5 E4:1 G4:1 G4:1.5 A4:0.5 G4:1 E4:1 C4:1.5 D4:0.5 E4:1 E4:1 D4:1 D4:1 C4:3"
    static let jacques = "C4:1 D4:1 E4:1 C4:1 C4:1 D4:1 E4:1 C4:1 E4:1 F4:1 G4:2 E4:1 F4:1 G4:2 G4:0.5 A4:0.5 G4:0.5 F4:0.5 E4:1 C4:1 G4:0.5 A4:0.5 G4:0.5 F4:0.5 E4:1 C4:1 C4:1 G3:1 C4:2 C4:1 G3:1 C4:2"
    static let grace = "G3:1 C4:2 E4:0.5 C4:0.5 E4:2 D4:1 C4:2 A3:1 G3:2 G3:1 C4:2 E4:0.5 C4:0.5 E4:2 D4:1 G4:3 G4:2 E4:1 G4:2 E4:0.5 C4:0.5 E4:2 D4:1 C4:2 A3:1 G3:2 G3:1 C4:2 E4:0.5 C4:0.5 E4:2 D4:1 C4:3"
    /// 6/8 拍子。1拍＝8分音符で書いている
    static let rowBoat = "C4:3 C4:3 C4:2 D4:1 E4:3 E4:2 D4:1 E4:2 F4:1 G4:6 C5:1 C5:1 C5:1 G4:1 G4:1 G4:1 E4:1 E4:1 E4:1 C4:1 C4:1 C4:1 G4:2 F4:1 E4:2 D4:1 C4:6"

    static let ja: [ShoukaSong] = [
        ShoukaSong(ja: "きらきら星", en: "Twinkle, Twinkle, Little Star", notes: twinkle, bpm: 100, short: 8, mid: 16),
        ShoukaSong(ja: "かえるの合唱", en: "The Frog Song", notes: frog, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "ちょうちょう", en: "Butterfly", notes: butterfly, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "メリーさんのひつじ", en: "Mary Had a Little Lamb", notes: mary, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "ロンドン橋", en: "London Bridge", notes: london, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "ハッピーバースデー", en: "Happy Birthday", notes: birthday, bpm: 100, short: 6, mid: 12),
        ShoukaSong(ja: "ジングルベル", en: "Jingle Bells", notes: jingle, bpm: 140, short: 8, mid: 16),
        ShoukaSong(ja: "蛍の光", en: "Auld Lang Syne", notes: auldLangSyne, bpm: 84, short: 9, mid: 17),
        ShoukaSong(ja: "さくらさくら", en: "Sakura Sakura", notes: sakura, bpm: 72, short: 8, mid: 16),
        ShoukaSong(ja: "アルプス一万尺", en: "Yankee Doodle", notes: yankee, bpm: 130, short: 8, mid: 16),
        ShoukaSong(ja: "ゆかいな牧場", en: "Old MacDonald Had a Farm", notes: macdonald, bpm: 120, short: 8, mid: 16),
        ShoukaSong(ja: "おおスザンナ", en: "Oh! Susanna", notes: susanna, bpm: 120, short: 9, mid: 17),
        ShoukaSong(ja: "グーチョキパーでなにつくろう", en: "Frère Jacques", notes: jacques, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "アメイジング・グレイス", en: "Amazing Grace", notes: grace, bpm: 80, short: 7, mid: 13),
    ]

    static let en: [ShoukaSong] = [
        ShoukaSong(ja: "きらきら星", en: "Twinkle, Twinkle, Little Star", notes: twinkle, bpm: 100, short: 8, mid: 16),
        ShoukaSong(ja: "ハッピーバースデー", en: "Happy Birthday", notes: birthday, bpm: 100, short: 6, mid: 12),
        ShoukaSong(ja: "ジングルベル", en: "Jingle Bells", notes: jingle, bpm: 140, short: 8, mid: 16),
        ShoukaSong(ja: "蛍の光", en: "Auld Lang Syne", notes: auldLangSyne, bpm: 84, short: 9, mid: 17),
        ShoukaSong(ja: "おおスザンナ", en: "Oh! Susanna", notes: susanna, bpm: 120, short: 9, mid: 17),
        ShoukaSong(ja: "アメイジング・グレイス", en: "Amazing Grace", notes: grace, bpm: 80, short: 7, mid: 13),
        ShoukaSong(ja: "アルプス一万尺", en: "Yankee Doodle", notes: yankee, bpm: 130, short: 8, mid: 16),
        ShoukaSong(ja: "ロンドン橋", en: "London Bridge Is Falling Down", notes: london, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "こげこげボート", en: "Row, Row, Row Your Boat", notes: rowBoat, bpm: 200, short: 12, mid: 24),
        ShoukaSong(ja: "ゆかいな牧場", en: "Old MacDonald Had a Farm", notes: macdonald, bpm: 120, short: 8, mid: 16),
        ShoukaSong(ja: "メリーさんのひつじ", en: "Mary Had a Little Lamb", notes: mary, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "グーチョキパーでなにつくろう", en: "Frère Jacques", notes: jacques, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "かえるの合唱", en: "The Frog Song (German folk)", notes: frog, bpm: 110, short: 8, mid: 16),
        ShoukaSong(ja: "ちょうちょう", en: "Little Hans (German folk)", notes: butterfly, bpm: 110, short: 8, mid: 16),
    ]

    static func all() -> [ShoukaSong] { L.isJa ? ja : en }
}

final class ShoukaGame: GameEngine {
    fileprivate var songs: [ShoukaSong] = []
    @Published var index = 0
    /// 0=まだ 1=短く 2=長く
    @Published var level = 0
    @Published var revealed = false
    @Published var isPlaying = false
    @Published var slow = false
    @Published var finished = false
    private var token = 0
    let perRound = 10

    init() {
        super.init(id: .shouka)
        shuffle()
    }

    fileprivate var current: ShoukaSong? { songs.indices.contains(index) ? songs[index] : nil }
    var total: Int { songs.count }

    override var pointValue: Int { level <= 1 ? 2 : 1 }

    func shuffle() {
        songs = Array(ShoukaBank.all().shuffled().prefix(perRound))
        index = 0
        finished = false
        resetSong()
    }

    private func resetSong() {
        halt()
        level = 0
        revealed = false
    }

    private func halt() {
        token += 1
        isPlaying = false
        Synth.shared.stop()
    }

    override func stop() {
        halt()
        super.stop()
    }

    override func prepareScreenshot() {
        showIntro = false
        level = 1
        isPlaying = true
    }

    private static func cut(_ notes: [Note], beats: Double) -> [Note] {
        var out: [Note] = []
        var sum = 0.0
        for n in notes {
            if sum >= beats - 0.001 { break }
            out.append(n)
            sum += n.beats
        }
        return out
    }

    private func play(beats: Double?) {
        guard let s = current else { return }
        halt()
        token += 1
        let t = token
        let all = s.parsed
        let notes = beats.map { ShoukaGame.cut(all, beats: $0) } ?? all
        isPlaying = true
        Synth.shared.play(notes, bpm: s.bpm * (slow ? 0.75 : 1)) { [weak self] in
            guard let self, self.token == t else { return }
            self.isPlaying = false
        }
    }

    func playShort() {
        guard let s = current else { return }
        level = max(level, 1)
        play(beats: s.short)
    }

    func playMore() {
        guard let s = current else { return }
        level = 2
        play(beats: s.mid)
    }

    func reveal() {
        guard let s = current else { return }
        revealed = true
        level = 2
        halt()
        Sfx.fanfare()
        Speech.say(L.t("答えは、", "It's ") + s.title)
        let t = token
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self, self.token == t, self.revealed else { return }
            self.play(beats: nil)
        }
    }

    func replayAll() { play(beats: nil) }

    func toggleSlow() { slow.toggle() }

    func next() {
        if index + 1 >= songs.count {
            halt()
            finished = true
            Sfx.fanfare()
            return
        }
        index += 1
        resetSong()
    }

    func previous() {
        guard index > 0 else { return }
        finished = false
        index -= 1
        resetSong()
    }

    override func stage() -> AnyView { AnyView(ShoukaStage(g: self)) }
    override func controls() -> AnyView { AnyView(ShoukaControls(g: self)) }
}

/// 揺れる音符
private struct ShoukaNotes: View {
    let active: Bool
    private let symbols = ["♪", "♫", "♩", "♬", "♪"]
    private let colors: [Color] = [Theme.accent, Theme.blue, Theme.green, Theme.gold, Color(red: 0.6, green: 0.3, blue: 0.7)]

    var body: some View {
        TimelineView(.animation(paused: !active)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            HStack(spacing: 50) {
                ForEach(0..<5, id: \.self) { i in
                    noteView(i, t: t)
                }
            }
        }
        .frame(height: 260)
    }

    private func noteView(_ i: Int, t: Double) -> some View {
        let phase = t * 3 + Double(i) * 1.3
        let dy = active ? sin(phase) * 40 : 0
        let rot = active ? sin(phase * 0.7) * 14 : 0
        return Text(symbols[i])
            .font(.system(size: 170, weight: .black))
            .foregroundStyle(colors[i].opacity(active ? 1 : 0.35))
            .offset(y: dy)
            .rotationEffect(.degrees(rot))
    }
}

struct ShoukaStage: View {
    @ObservedObject var g: ShoukaGame

    var body: some View {
        if g.finished {
            FinishStage()
        } else {
            VStack(spacing: 26) {
                Text(L.t("第\(g.index + 1)曲", "Song \(g.index + 1)") + "  /  \(g.total)")
                    .font(.big(38))
                    .foregroundStyle(Theme.sub)
                ShoukaNotes(active: g.isPlaying)
                status
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.45), value: g.revealed)
        }
    }

    @ViewBuilder
    private var status: some View {
        if g.revealed, let s = g.current {
            VStack(spacing: 14) {
                StageText(s.title, size: 100, color: .white)
                Text(L.t("みんなで歌いましょう", "Let's all sing!"))
                    .font(.big(44))
                    .foregroundStyle(.white.opacity(0.92))
            }
            .padding(.horizontal, 60).padding(.vertical, 26)
            .background(RoundedRectangle(cornerRadius: 36).fill(Theme.accent))
            .padding(.horizontal, 80)
            .transition(.scale.combined(with: .opacity))
        } else if g.isPlaying {
            StageText(L.t("よく聞いてください", "Listen closely"), size: 76)
        } else if g.level == 0 {
            StageText(L.t("何の曲でしょう？", "What song is this?"), size: 80)
        } else {
            VStack(spacing: 10) {
                StageText(L.t("わかったら手をあげて！", "Raise your hand if you know it!"), size: 76, color: Theme.accent)
                Text(L.t("いま当てたら \(g.pointValue)点", "\(g.pointValue) points if you get it now"))
                    .font(.big(40))
                    .foregroundStyle(Theme.sub)
            }
        }
    }
}

struct ShoukaControls: View {
    @ObservedObject var g: ShoukaGame

    var body: some View {
        VStack(spacing: 12) {
            if g.finished {
                HostButton(title: L.t("もう一回（曲を入れかえる）", "Play again (new songs)"), symbol: "arrow.clockwise", color: Theme.green, big: true) {
                    g.shuffle()
                }
            } else {
                playButtons
                if let s = g.current {
                    Text(L.t("曲名：", "Song: ") + s.title)
                        .font(.round(17))
                        .foregroundStyle(.white.opacity(0.75))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }
                HostButton(title: g.slow ? L.t("ゆっくり：オン", "Slow: on") : L.t("ゆっくり：オフ", "Slow: off"),
                           symbol: "tortoise.fill", color: g.slow ? Theme.gold : Theme.hostCard) { g.toggleSlow() }
                HStack(spacing: 10) {
                    HostButton(title: L.t("前へ", "Back"), symbol: "arrow.left", color: Theme.hostCard) { g.previous() }
                    HostButton(title: L.t("とばす", "Skip"), symbol: "forward.fill", color: Theme.hostCard) { g.next() }
                }
            }
        }
    }

    @ViewBuilder
    private var playButtons: some View {
        if g.revealed {
            HostButton(title: L.t("次の曲", "Next song"), symbol: "arrow.right", color: Theme.green, big: true) { g.next() }
            HostButton(title: L.t("最後まで流す", "Play it all"), symbol: "music.note", color: Theme.blue) { g.replayAll() }
        } else {
            HostButton(title: g.level == 0 ? L.t("再生", "Play") : L.t("もう一度（短く）", "Again (short)"),
                       symbol: "play.fill", color: Theme.blue, big: true) { g.playShort() }
            if g.level >= 1 {
                HostButton(title: L.t("もう少し聞く", "Play a bit more"), symbol: "forward.end.fill", color: Theme.gold, big: true) { g.playMore() }
            }
            HostButton(title: L.t("答えを見せる", "Show answer"), symbol: "eye.fill", color: Theme.accent, big: true) { g.reveal() }
        }
    }
}
