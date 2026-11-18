import AVFoundation

/// 読み上げ。係の人が声を出さなくても進められるように
enum Speech {
    private static let synth = AVSpeechSynthesizer()

    static var enabled: Bool { UserDefaults.standard.object(forKey: "speechOn") as? Bool ?? true }

    static func say(_ text: String, rate: Float = 0.45, force: Bool = false) {
        guard enabled || force else { return }
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: L.isJa ? "ja-JP" : "en-US")
        u.rate = rate
        u.pitchMultiplier = 1.05
        u.volume = 1
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        synth.speak(u)
    }

    static func stop() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
    }
}

/// 音符。midi が負なら休み
struct Note {
    var midi: Int
    var beats: Double

    /// "C4:1 D4:0.5 R:1 F#4:2 Bb3:1" のように書く
    static func parse(_ text: String) -> [Note] {
        text.split(whereSeparator: { $0 == " " || $0 == "\n" }).compactMap { token in
            let parts = token.split(separator: ":")
            guard parts.count == 2, let beats = Double(parts[1]) else { return nil }
            let name = String(parts[0])
            if name.uppercased() == "R" { return Note(midi: -1, beats: beats) }
            guard let midi = midiNumber(name) else { return nil }
            return Note(midi: midi, beats: beats)
        }
    }

    static func midiNumber(_ name: String) -> Int? {
        let base: [Character: Int] = ["C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11]
        var chars = Array(name)
        guard let first = chars.first, let semis = base[Character(first.uppercased())] else { return nil }
        chars.removeFirst()
        var shift = 0
        while let c = chars.first, c == "#" || c == "b" {
            shift += c == "#" ? 1 : -1
            chars.removeFirst()
        }
        guard let octave = Int(String(chars)) else { return nil }
        return (octave + 1) * 12 + semis + shift
    }
}

enum Wave { case organ, chime, square }

/// 音を作って鳴らす。曲と効果音は別の再生口を使う
final class Synth {
    static let shared = Synth()

    private let engine = AVAudioEngine()
    private let music = AVAudioPlayerNode()
    private let effects = AVAudioPlayerNode()
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    var rate: Double { format.sampleRate }

    private init() {
        engine.attach(music)
        engine.attach(effects)
        engine.connect(music, to: engine.mainMixerNode, format: format)
        engine.connect(effects, to: engine.mainMixerNode, format: format)
    }

    private func ensureRunning() {
        if !engine.isRunning { try? engine.start() }
    }

    /// 曲を鳴らす。終わったら done を main で呼ぶ
    func play(_ notes: [Note], bpm: Double, wave: Wave = .organ, done: (() -> Void)? = nil) {
        ensureRunning()
        let buf = render(notes, bpm: bpm, wave: wave)
        music.stop()
        music.scheduleBuffer(buf, at: nil, options: .interrupts) {
            if let done { DispatchQueue.main.async(execute: done) }
        }
        music.play()
    }

    func stop() {
        music.stop()
    }

    func playEffect(_ buf: AVAudioPCMBuffer) {
        ensureRunning()
        effects.scheduleBuffer(buf, at: nil, options: .interrupts, completionHandler: nil)
        if !effects.isPlaying { effects.play() }
    }

    func buffer(seconds: Double, _ fill: (UnsafeMutablePointer<Float>, Int) -> Void) -> AVAudioPCMBuffer {
        let count = max(1, Int(seconds * rate))
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(count))!
        buf.frameLength = AVAudioFrameCount(count)
        fill(buf.floatChannelData![0], count)
        return buf
    }

    func render(_ notes: [Note], bpm: Double, wave: Wave) -> AVAudioPCMBuffer {
        let beat = 60.0 / bpm
        let total = notes.reduce(0) { $0 + $1.beats } * beat + 0.4
        return buffer(seconds: total) { out, count in
            for i in 0..<count { out[i] = 0 }
            var start = 0
            for note in notes {
                let len = Int(note.beats * beat * rate)
                if note.midi >= 0 {
                    let f = 440.0 * pow(2.0, Double(note.midi - 69) / 12.0)
                    let tail = Int(0.25 * rate)
                    for j in 0..<min(len + tail, count - start) {
                        let t = Double(j) / rate
                        let v = Synth.voice(wave, f, t, held: Double(len) / rate)
                        out[start + j] += Float(v * 0.32)
                    }
                }
                start += len
                if start >= count { break }
            }
        }
    }

    /// 1つの音の形（音色と音量の変化）
    static func voice(_ wave: Wave, _ f: Double, _ t: Double, held: Double) -> Double {
        let w = 2 * Double.pi * f * t
        let attack = min(1, t / 0.012)
        let release = t > held ? max(0, 1 - (t - held) / 0.08) : 1
        switch wave {
        case .organ:
            let body = sin(w) + 0.35 * sin(2 * w) + 0.12 * sin(3 * w)
            let env = attack * release * (0.75 + 0.25 * exp(-t * 6))
            return body * env * 0.75
        case .chime:
            let body = sin(w) + 0.25 * sin(2.76 * w) + 0.1 * sin(5.4 * w)
            return body * attack * exp(-t * 4.5) * (t > held + 0.3 ? 0 : 1)
        case .square:
            let s: Double = sin(w) >= 0 ? 1 : -1
            return s * 0.35 * attack * release
        }
    }
}

/// 効果音
enum Sfx {
    private static var cache: [String: AVAudioPCMBuffer] = [:]

    private static func cached(_ key: String, _ make: () -> AVAudioPCMBuffer) -> AVAudioPCMBuffer {
        if let b = cache[key] { return b }
        let b = make()
        cache[key] = b
        return b
    }

    private static func tones(_ key: String, _ notes: String, bpm: Double, wave: Wave) {
        let b = cached(key) { Synth.shared.render(Note.parse(notes), bpm: bpm, wave: wave) }
        Synth.shared.playEffect(b)
    }

    /// 正解・得点
    static func ding() { tones("ding", "E6:0.5 C7:1.5", bpm: 240, wave: .chime) }
    /// まちがい・爆発前
    static func buzz() { tones("buzz", "C3:1.5", bpm: 120, wave: .square) }
    /// ファンファーレ
    static func fanfare() { tones("fanfare", "C5:0.5 E5:0.5 G5:0.5 C6:1.5 G5:0.5 C6:2", bpm: 260, wave: .organ) }
    /// 小さいカチッ
    static func tick() {
        let b = cached("tick") {
            Synth.shared.buffer(seconds: 0.05) { out, n in
                for i in 0..<n { out[i] = Float.random(in: -1...1) * Float(exp(-Double(i) / 200)) * 0.6 }
            }
        }
        Synth.shared.playEffect(b)
    }
    /// 手拍子
    static func clap() {
        let b = cached("clap") {
            Synth.shared.buffer(seconds: 0.18) { out, n in
                for i in 0..<n {
                    let t = Double(i) / 44100
                    out[i] = Float.random(in: -1...1) * Float(exp(-t * 28)) * 0.8
                }
            }
        }
        Synth.shared.playEffect(b)
    }
    /// 太鼓のドン
    static func drum() {
        let b = cached("drum") {
            Synth.shared.buffer(seconds: 0.35) { out, n in
                for i in 0..<n {
                    let t = Double(i) / 44100
                    let f = 60 + 90 * exp(-t * 25)
                    out[i] = Float(sin(2 * .pi * f * t) * exp(-t * 9) * 0.9)
                }
            }
        }
        Synth.shared.playEffect(b)
    }
    /// 爆発
    static func boom() {
        let b = cached("boom") {
            Synth.shared.buffer(seconds: 1.4) { out, n in
                var low: Float = 0
                for i in 0..<n {
                    let t = Double(i) / 44100
                    low = low * 0.96 + Float.random(in: -1...1) * 0.04
                    out[i] = (low * 6 + Float(sin(2 * .pi * 45 * t))) * Float(exp(-t * 2.5)) * 0.7
                }
            }
        }
        Synth.shared.playEffect(b)
    }
    /// ドラムロール（seconds 秒）
    static func drumroll(_ seconds: Double = 2) {
        let b = Synth.shared.buffer(seconds: seconds) { out, n in
            for i in 0..<n {
                let t = Double(i) / 44100
                let hit = exp(-(t.truncatingRemainder(dividingBy: 0.06)) * 60)
                out[i] = Float.random(in: -1...1) * Float(hit * 0.45 * min(1, t * 2))
            }
        }
        Synth.shared.playEffect(b)
    }
}
