import SwiftUI

enum GameCategory: Int, CaseIterable {
    case memory, words, eyes, body, together

    var title: String {
        switch self {
        case .memory: return L.t("思い出す", "Remember")
        case .words: return L.t("ことば", "Words")
        case .eyes: return L.t("見る・覚える", "Look & Recall")
        case .body: return L.t("体を動かす", "Move")
        case .together: return L.t("みんなで", "All Together")
        }
    }

    var color: Color {
        switch self {
        case .memory: return Color(red: 0.80, green: 0.45, blue: 0.20)
        case .words: return Color(red: 0.20, green: 0.48, blue: 0.75)
        case .eyes: return Color(red: 0.50, green: 0.32, blue: 0.70)
        case .body: return Color(red: 0.18, green: 0.60, blue: 0.40)
        case .together: return Color(red: 0.85, green: 0.30, blue: 0.40)
        }
    }

    var games: [GameID] { GameID.allCases.filter { $0.category == self } }
}

enum GameID: String, CaseIterable, Identifiable {
    case dougu, nenpyo, shouka, gyouji
    case kotowaza, kanji, meibutsu, shiritori
    case machigai, silhouette, kioku, zoom, keisan
    case hataage, rhythm, janken
    case bingo, sugoroku, roulette, highlow

    var id: String { rawValue }

    var category: GameCategory {
        switch self {
        case .dougu, .nenpyo, .shouka, .gyouji: return .memory
        case .kotowaza, .kanji, .meibutsu, .shiritori: return .words
        case .machigai, .silhouette, .kioku, .zoom, .keisan: return .eyes
        case .hataage, .rhythm, .janken: return .body
        case .bingo, .sugoroku, .roulette, .highlow: return .together
        }
    }

    var emoji: String {
        switch self {
        case .dougu: return "📻"
        case .nenpyo: return "📅"
        case .shouka: return "🎵"
        case .gyouji: return "🎎"
        case .kotowaza: return "📜"
        case .kanji: return "🈴"
        case .meibutsu: return "🗾"
        case .shiritori: return "💣"
        case .machigai: return "🔍"
        case .silhouette: return "👤"
        case .kioku: return "🧠"
        case .zoom: return "🔎"
        case .keisan: return "🧮"
        case .hataage: return "🚩"
        case .rhythm: return "👏"
        case .janken: return "✊"
        case .bingo: return "🎱"
        case .sugoroku: return "🎲"
        case .roulette: return "🎡"
        case .highlow: return "🃏"
        }
    }

    var title: String {
        switch self {
        case .dougu: return L.t("なつかし道具 3つのヒント", "Old Things: 3 Hints")
        case .nenpyo: return L.t("この年なにがあった？", "What Happened That Year?")
        case .shouka: return L.t("なつかしの歌イントロ当て", "Name That Song")
        case .gyouji: return L.t("季節の行事クイズ", "Seasons & Festivals")
        case .kotowaza: return L.t("ことわざ穴うめ", "Finish the Proverb")
        case .kanji: return L.t("漢字の読み", "Read the Kanji")
        case .meibutsu: return L.t("ご当地名物当て", "Famous Local Foods")
        case .shiritori: return L.t("しりとり爆弾", "Word Bomb")
        case .machigai: return L.t("まちがい探し", "Spot the Difference")
        case .silhouette: return L.t("シルエット当て", "Silhouette Quiz")
        case .kioku: return L.t("覚えてね！", "Remember This!")
        case .zoom: return L.t("ズームアップ当て", "Zoom Quiz")
        case .keisan: return L.t("あたま体操 計算", "Brain Math")
        case .hataage: return L.t("旗あげゲーム", "Flag Game")
        case .rhythm: return L.t("手拍子リズム体操", "Clap Along")
        case .janken: return L.t("じゃんけん大会", "Rock Paper Scissors")
        case .bingo: return L.t("ビンゴ", "Bingo")
        case .sugoroku: return L.t("チーム対抗すごろく", "Team Board Game")
        case .roulette: return L.t("お題ルーレット", "Topic Roulette")
        case .highlow: return L.t("ハイ＆ロー", "High or Low")
        }
    }

    /// メニューに出す一言
    var tagline: String {
        switch self {
        case .dougu: return L.t("ヒントを聞いて昔の道具を当てる", "Guess the old item from hints")
        case .nenpyo: return L.t("年号から出来事を思い出す", "Match the year to the event")
        case .shouka: return L.t("メロディーを聞いて曲名を当てる", "Guess the tune")
        case .gyouji: return L.t("季節の行事と食べ物", "Holidays and the seasons")
        case .kotowaza: return L.t("□に入ることばは？", "Fill in the missing word")
        case .kanji: return L.t("むずかしい漢字を読む", "Read tricky kanji")
        case .meibutsu: return L.t("名物から都道府県を当てる", "Which place is it famous in?")
        case .shiritori: return L.t("爆発する前に次の人へ", "Answer before it goes off")
        case .machigai: return L.t("左右でちがう所を探す", "Find what changed")
        case .silhouette: return L.t("黒い影は何？", "What is the shadow?")
        case .kioku: return L.t("見た物を思い出す", "Look, then recall")
        case .zoom: return L.t("だんだん見えてくる", "It gets clearer and clearer")
        case .keisan: return L.t("みんなで暗算", "Mental math together")
        case .hataage: return L.t("赤あげて、白さげない", "Raise red, keep white down")
        case .rhythm: return L.t("画面に合わせて手をたたく", "Clap with the screen")
        case .janken: return L.t("画面と勝負！", "Play against the screen")
        case .bingo: return L.t("大きな数字で抽選", "Big-number bingo caller")
        case .sugoroku: return L.t("サイコロとお題で進む", "Roll the dice, do the task")
        case .roulette: return L.t("話のきっかけを回す", "Spin for something to talk about")
        case .highlow: return L.t("次は大きい？小さい？", "Higher or lower next?")
        }
    }

    /// はじめに大きい画面へ出す遊び方
    var rules: [String] {
        switch self {
        case .dougu: return [L.t("ヒントが1つずつ出ます", "Hints appear one at a time"), L.t("わかったら手をあげてください", "Raise your hand when you know"), L.t("ヒントが少ないほど高得点", "Fewer hints, more points")]
        case .nenpyo: return [L.t("年号が出ます", "A year appears"), L.t("その年の出来事をえらんでください", "Pick what happened that year"), L.t("思い出話もどうぞ", "Share your memories too")]
        case .shouka: return [L.t("メロディーが流れます", "A melody plays"), L.t("曲名がわかったら手をあげて", "Raise your hand when you know it"), L.t("みんなで歌ってもOK", "Feel free to sing along")]
        case .gyouji: return [L.t("季節の行事の問題です", "Questions about the seasons"), L.t("答えがわかったら手をあげて", "Raise your hand to answer")]
        case .kotowaza: return [L.t("ことわざの一部がかくれています", "Part of a proverb is hidden"), L.t("□に入ることばを当ててください", "Guess the missing word")]
        case .kanji: return [L.t("漢字が出ます", "A word appears"), L.t("読み方を当ててください", "Say how to read it")]
        case .meibutsu: return [L.t("名物が出ます", "A famous food appears"), L.t("どこの名物か当ててください", "Guess where it comes from")]
        case .shiritori: return [L.t("お題に合うことばを言って次の人へ", "Say a word and pass it on"), L.t("爆弾はいつ爆発するかわかりません", "Nobody knows when it goes off"), L.t("爆発した人は一言どうぞ", "Whoever holds it says a few words")]
        case .machigai: return [L.t("左と右で3か所ちがいます", "Three things are different"), L.t("見つけたら手をあげて", "Raise your hand when you spot one")]
        case .silhouette: return [L.t("黒い影が出ます", "A shadow appears"), L.t("何の影か当ててください", "Guess what it is")]
        case .kioku: return [L.t("絵がいくつか出ます", "Some pictures appear"), L.t("よく見て覚えてください", "Look closely and remember"), L.t("消えたあとに問題が出ます", "Then a question appears")]
        case .zoom: return [L.t("とても大きく写っています", "It starts zoomed way in"), L.t("だんだん小さくなります", "It slowly zooms out"), L.t("早く当てた人の勝ち", "Guess early to win")]
        case .keisan: return [L.t("計算の問題が出ます", "A math problem appears"), L.t("頭の中で計算してください", "Work it out in your head")]
        case .hataage: return [L.t("両手を旗にします（右手が赤、左手が白）", "Your hands are flags (right red, left white)"), L.t("声のとおりにあげたりさげたり", "Raise or lower as you are told"), L.t("ひっかけに注意！", "Watch out for tricks!")]
        case .rhythm: return [L.t("画面の絵に合わせて動きます", "Move with the picture"), L.t("👏 手をたたく　🦵 ひざをたたく", "👏 clap   🦵 pat knees"), L.t("無理せずゆっくりどうぞ", "Go slowly, no strain")]
        case .janken: return [L.t("画面とじゃんけんします", "Play against the screen"), L.t("「じゃんけん、ぽん！」で出してください", "Show your hand on GO!"), L.t("勝った人は残ります", "Winners stay in")]
        case .bingo: return [L.t("ビンゴカードを配ってください", "Hand out bingo cards"), L.t("出た数字に印をつけます", "Mark the numbers called"), L.t("そろったら「ビンゴ！」", "Call BINGO when you get a line")]
        case .sugoroku: return [L.t("チームごとにサイコロをふります", "Each team rolls the dice"), L.t("止まったマスのお題をします", "Do the task on your square"), L.t("先にゴールしたチームの勝ち", "First team to the goal wins")]
        case .roulette: return [L.t("ルーレットを回します", "Spin the wheel"), L.t("出たお題についてお話しします", "Talk about the topic")]
        case .highlow: return [L.t("次の数字は大きい？小さい？", "Will the next number be higher or lower?"), L.t("大きいと思ったら手をあげて", "Raise your hand for higher"), L.t("当たった人は続けられます", "Get it right to stay in")]
        }
    }

    @MainActor
    func make() -> GameEngine {
        switch self {
        case .dougu: return QuizGame(id: self, items: QuizBank.dougu(), mode: .hints)
        case .nenpyo: return QuizGame(id: self, items: QuizBank.nenpyo(), mode: .choices)
        case .gyouji: return QuizGame(id: self, items: QuizBank.gyouji(), mode: .choices)
        case .kotowaza: return QuizGame(id: self, items: QuizBank.kotowaza(), mode: .open)
        case .kanji: return QuizGame(id: self, items: QuizBank.kanji(), mode: .open)
        case .meibutsu: return QuizGame(id: self, items: QuizBank.meibutsu(), mode: .choices)
        case .silhouette: return QuizGame(id: self, items: QuizBank.silhouette(), mode: .open)
        case .zoom: return QuizGame(id: self, items: QuizBank.zoom(), mode: .zoom)
        case .keisan: return QuizGame(id: self, items: QuizBank.keisan(), mode: .open)
        case .shouka: return ShoukaGame()
        case .shiritori: return ShiritoriGame()
        case .machigai: return MachigaiGame()
        case .kioku: return KiokuGame()
        case .hataage: return HataageGame()
        case .rhythm: return RhythmGame()
        case .janken: return JankenGame()
        case .bingo: return BingoGame()
        case .sugoroku: return SugorokuGame()
        case .roulette: return RouletteGame()
        case .highlow: return HighLowGame()
        }
    }
}
