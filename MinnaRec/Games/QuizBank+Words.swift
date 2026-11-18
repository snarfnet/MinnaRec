import Foundation

extension QuizBank {
    // MARK: - ことわざ穴うめ（.open）

    static func kotowaza() -> [QuizItem] {
        // (□のある文, 答え, 意味)
        let data: [(String, String, String)]
        let ask: String
        if L.isJa {
            ask = "\n□に入ることばは？"
            data = [
                ("猿も木から□□□", "落ちる", "名人でも失敗することがある"),
                ("石の上にも□□", "三年", "がまんすれば、いつか報われる"),
                ("急がば□□", "回れ", "あせらず確かな道を行くほうが早い"),
                ("花より□□", "団子", "見た目より中身・実益をとる"),
                ("犬も歩けば□に当たる", "棒", "出歩くと思わぬことに出会う"),
                ("猫に□□", "小判", "価値のわからない人には役に立たない"),
                ("豚に□□", "真珠", "価値のわからない人には役に立たない"),
                ("二階から□□", "目薬", "回りくどくて効き目がない"),
                ("七転び□起き", "八", "何度失敗してもまた立ち上がる"),
                ("早起きは□□の徳", "三文", "早起きすると良いことがある"),
                ("笑う門には□来たる", "福", "いつも笑っている家に幸せが来る"),
                ("塵も積もれば□となる", "山", "小さなことも重なれば大きくなる"),
                ("百聞は□見にしかず", "一", "何度も聞くより一度見るほうがよい"),
                ("雨降って□固まる", "地", "もめごとの後はかえって仲良くなる"),
                ("弘法にも□の誤り", "筆", "名人でも失敗することがある"),
                ("河童の□流れ", "川", "得意なことでも失敗することがある"),
                ("馬の耳に□□", "念仏", "いくら言っても効き目がない"),
                ("鬼に□□", "金棒", "強いものがさらに強くなる"),
                ("焼け石に□", "水", "少しの助けでは役に立たない"),
                ("光陰□のごとし", "矢", "月日がたつのはとても早い"),
                ("覆水□に返らず", "盆", "一度したことは元にもどせない"),
                ("案ずるより□むが易し", "産", "心配するより、やってみると簡単"),
                ("能ある鷹は□を隠す", "爪", "力のある人はそれを見せびらかさない"),
                ("井の中の□大海を知らず", "蛙", "せまい世界しか知らない"),
                ("腐っても□", "鯛", "良いものは古くなっても値打ちがある"),
                ("果報は□て待て", "寝", "あせらず待てば良い知らせが来る"),
                ("三人寄れば□□の知恵", "文殊", "みんなで考えれば良い知恵が出る"),
                ("泣きっ面に□", "蜂", "悪いことに悪いことが重なる"),
                ("出る杭は□たれる", "打", "目立つ人は憎まれやすい"),
                ("備えあれば□いなし", "憂", "準備しておけば心配はいらない"),
                ("灯台□暗し", "下", "身近なことほど気づきにくい"),
                ("釈迦に□□", "説法", "よく知っている人に教えるおろかさ"),
            ]
        } else {
            ask = "\nWhat is the missing word?"
            data = [
                ("An apple a day keeps the ___ away", "doctor", ""),
                ("The early bird catches the ___", "worm", ""),
                ("Don't count your ___ before they hatch", "chickens", ""),
                ("Every cloud has a silver ___", "lining", ""),
                ("A penny saved is a penny ___", "earned", ""),
                ("Too many cooks spoil the ___", "broth", ""),
                ("Actions speak louder than ___", "words", ""),
                ("When in Rome, do as the ___ do", "Romans", ""),
                ("Don't put all your eggs in one ___", "basket", ""),
                ("A bird in the hand is worth two in the ___", "bush", ""),
                ("Rome wasn't built in a ___", "day", ""),
                ("Better late than ___", "never", ""),
                ("Two heads are better than ___", "one", ""),
                ("Where there's smoke, there's ___", "fire", ""),
                ("Practice makes ___", "perfect", ""),
                ("Laughter is the best ___", "medicine", ""),
                ("Birds of a feather flock ___", "together", ""),
                ("Don't cry over spilled ___", "milk", ""),
                ("Honesty is the best ___", "policy", ""),
                ("The pen is mightier than the ___", "sword", ""),
            ]
        }
        return data.map { QuizItem(prompt: $0.0 + ask, answer: $0.1, note: $0.2) }
    }

    // MARK: - 漢字の読み（.open）
    // 英語版は「この漢字はどういう意味？」（形から想像できる字）

    static func kanji() -> [QuizItem] {
        if L.isJa {
            let data: [(String, String, String)] = [
                ("秋刀魚", "さんま", "秋の魚"),
                ("紫陽花", "あじさい", "梅雨の花"),
                ("向日葵", "ひまわり", "夏の花"),
                ("蒲公英", "たんぽぽ", "春の花"),
                ("秋桜", "コスモス", "秋の花"),
                ("胡瓜", "きゅうり", "夏の野菜"),
                ("南瓜", "かぼちゃ", "冬至に食べる野菜"),
                ("西瓜", "すいか", "夏の果物"),
                ("玉蜀黍", "とうもろこし", "夏の野菜"),
                ("牛蒡", "ごぼう", "きんぴらにする野菜"),
                ("茄子", "なす", "夏の野菜"),
                ("蜜柑", "みかん", "冬の果物"),
                ("林檎", "りんご", "赤い果物"),
                ("葡萄", "ぶどう", "秋の果物"),
                ("海老", "えび", "海の生き物"),
                ("烏賊", "いか", "海の生き物"),
                ("鰯", "いわし", "海の魚"),
                ("鯖", "さば", "海の魚"),
                ("河豚", "ふぐ", "毒のある魚"),
                ("蝸牛", "かたつむり", "雨の日の生き物"),
                ("蜻蛉", "とんぼ", "秋の虫"),
                ("蟋蟀", "こおろぎ", "秋に鳴く虫"),
                ("啄木鳥", "きつつき", "木をつつく鳥"),
                ("雲雀", "ひばり", "春の鳥"),
                ("海月", "くらげ", "海の生き物"),
                ("心太", "ところてん", "夏の食べ物"),
                ("土筆", "つくし", "春の草"),
                ("山葵", "わさび", "おすしに入れる"),
                ("生姜", "しょうが", "体が温まる"),
                ("椎茸", "しいたけ", "きのこ"),
                ("薔薇", "ばら", "とげのある花"),
                ("百合", "ゆり", "白い花"),
                ("菫", "すみれ", "春の花"),
                ("蛤", "はまぐり", "ひな祭りのお吸い物"),
            ]
            return data.map { QuizItem(prompt: "なんと読むでしょう？", visual: .big($0.0), answer: $0.1, note: $0.2) }
        } else {
            let data: [(String, String, String)] = [
                ("山", "Mountain", "It looks like three peaks"),
                ("川", "River", "Three lines of flowing water"),
                ("木", "Tree", "A trunk with branches and roots"),
                ("林", "Woods", "Two trees together"),
                ("森", "Forest", "Three trees together"),
                ("日", "Sun", "Once drawn as a circle"),
                ("月", "Moon", "Once drawn as a crescent"),
                ("火", "Fire", "Flames rising up"),
                ("水", "Water", "Water splashing"),
                ("人", "Person", "Two legs walking"),
                ("口", "Mouth", "An open mouth"),
                ("目", "Eye", "An eye turned on its side"),
                ("田", "Rice field", "A field divided into plots"),
                ("雨", "Rain", "Drops falling from the sky"),
                ("門", "Gate", "Two swinging doors"),
                ("上", "Up", "A mark above the line"),
                ("下", "Down", "A mark below the line"),
                ("大", "Big", "A person with arms spread wide"),
                ("小", "Small", "Little pieces"),
                ("魚", "Fish", "Head, body, and tail fin"),
            ]
            return data.map { QuizItem(prompt: "What does this kanji mean?", visual: .big($0.0), answer: $0.1, note: $0.2) }
        }
    }

    // MARK: - ご当地名物当て（.choices）
    // まちがいの選択肢には、その名物の産地と言われそうな所を入れない

    static func meibutsu() -> [QuizItem] {
        // (名物, 絵文字, 答え, まちがい3つ)
        let data: [(String, String, String, [String])]
        if L.isJa {
            data = [
                ("明太子", "🌶️", "福岡県", ["北海道", "宮城県", "長野県"]),
                ("さくらんぼ", "🍒", "山形県", ["沖縄県", "鹿児島県", "高知県"]),
                ("りんご", "🍎", "青森県", ["沖縄県", "宮崎県", "高知県"]),
                ("牛タン", "🐮", "宮城県", ["沖縄県", "香川県", "長崎県"]),
                ("讃岐うどん", "🍜", "香川県", ["北海道", "宮城県", "福岡県"]),
                ("きりたんぽ", "🍢", "秋田県", ["沖縄県", "福岡県", "広島県"]),
                ("八ツ橋", "🍘", "京都府", ["青森県", "北海道", "鹿児島県"]),
                ("もみじまんじゅう", "🍁", "広島県", ["北海道", "宮城県", "沖縄県"]),
                ("ちんすこう", "🍪", "沖縄県", ["北海道", "青森県", "新潟県"]),
                ("白い恋人", "🍫", "北海道", ["沖縄県", "京都府", "熊本県"]),
                ("信玄餅", "🍡", "山梨県", ["青森県", "沖縄県", "福岡県"]),
                ("草加せんべい", "🍘", "埼玉県", ["北海道", "沖縄県", "宮崎県"]),
                ("喜多方ラーメン", "🍜", "福島県", ["沖縄県", "鹿児島県", "高知県"]),
                ("辛子れんこん", "🪷", "熊本県", ["北海道", "青森県", "秋田県"]),
                ("カステラ", "🍰", "長崎県", ["北海道", "秋田県", "岩手県"]),
                ("宇都宮餃子", "🥟", "栃木県", ["沖縄県", "鹿児島県", "北海道"]),
                ("赤福", "🍡", "三重県", ["北海道", "秋田県", "沖縄県"]),
                ("ひつまぶし", "🍱", "愛知県", ["北海道", "青森県", "沖縄県"]),
                ("たこ焼き", "🐙", "大阪府", ["北海道", "秋田県", "沖縄県"]),
                ("夕張メロン", "🍈", "北海道", ["沖縄県", "高知県", "鹿児島県"]),
                ("カツオのたたき", "🐟", "高知県", ["群馬県", "栃木県", "山梨県"]),
                ("お茶", "🍵", "静岡県", ["北海道", "青森県", "沖縄県"]),
                ("ますのすし", "🍣", "富山県", ["沖縄県", "宮崎県", "鹿児島県"]),
                ("わんこそば", "🍜", "岩手県", ["沖縄県", "鹿児島県", "大阪府"]),
                ("梅干し（南高梅）", "🍙", "和歌山県", ["北海道", "青森県", "秋田県"]),
                ("下関のふぐ", "🐡", "山口県", ["長野県", "群馬県", "栃木県"]),
                ("二十世紀梨", "🍐", "鳥取県", ["沖縄県", "鹿児島県", "高知県"]),
                ("チキン南蛮", "🍗", "宮崎県", ["北海道", "青森県", "秋田県"]),
                ("信州そば", "🍜", "長野県", ["沖縄県", "鹿児島県", "高知県"]),
                ("ゴーヤーチャンプルー", "🥒", "沖縄県", ["北海道", "青森県", "新潟県"]),
            ]
            return data.map { choice("「\($0.0)」はどこの名物？", .emoji($0.1), answer: $0.2, wrong: $0.3) }
        } else {
            data = [
                ("Sushi", "🍣", "Japan", ["Mexico", "Brazil", "Sweden"]),
                ("Pizza", "🍕", "Italy", ["Japan", "Canada", "India"]),
                ("Croissant", "🥐", "France", ["Thailand", "Mexico", "Kenya"]),
                ("Paella", "🥘", "Spain", ["Japan", "Canada", "Norway"]),
                ("Tacos", "🌮", "Mexico", ["Japan", "Germany", "India"]),
                ("Kimchi", "🥬", "Korea", ["Italy", "Mexico", "Ireland"]),
                ("Pretzels", "🥨", "Germany", ["Thailand", "Brazil", "Japan"]),
                ("Fish and chips", "🐟", "England", ["Mexico", "India", "Thailand"]),
                ("Pad Thai", "🍜", "Thailand", ["Italy", "Canada", "Ireland"]),
                ("Goulash", "🍲", "Hungary", ["Japan", "Mexico", "Brazil"]),
                ("Maple syrup", "🍁", "Canada", ["Egypt", "India", "Spain"]),
                ("Peking duck", "🦆", "China", ["Mexico", "Ireland", "Sweden"]),
                ("Pho", "🍜", "Vietnam", ["Ireland", "Brazil", "Germany"]),
                ("Cheese fondue", "🫕", "Switzerland", ["Thailand", "Mexico", "Japan"]),
                ("Waffles", "🧇", "Belgium", ["Thailand", "Kenya", "Japan"]),
                ("Haggis", "🐑", "Scotland", ["Italy", "Mexico", "Japan"]),
                ("Feta cheese", "🧀", "Greece", ["Japan", "Canada", "Brazil"]),
                ("Vegemite", "🍞", "Australia", ["Italy", "Mexico", "Japan"]),
            ]
            return data.map { choice("Where is \($0.0) from?", .emoji($0.1), answer: $0.2, wrong: $0.3) }
        }
    }
}
