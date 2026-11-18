import Foundation

/// クイズの問題データ。L.isJa で日本語版・英語版を切り替える
enum QuizBank {
    /// 選択肢つきの問題。choices は answer と wrong をまとめたもの（並べ替えは QuizGame がする）
    static func choice(_ prompt: String, _ visual: QuizVisual = .none,
                       answer: String, wrong: [String], note: String = "") -> QuizItem {
        QuizItem(prompt: prompt, visual: visual, choices: [answer] + wrong, answer: answer, note: note)
    }

    // MARK: - なつかし道具 3つのヒント（.hints）

    static func dougu() -> [QuizItem] {
        // ヒントは むずかしい → やさしい の順
        let data: [(String, [String])]
        let prompt: String
        if L.isJa {
            prompt = "この道具は何でしょう？"
            data = [
                ("洗濯板", ["木でできている", "ギザギザの面がある", "たらいと一緒に使う", "服をこすって洗う"]),
                ("黒電話", ["重くて黒い", "指で回す穴がある", "ジリリリンと鳴る", "受話器を取って話す"]),
                ("ちゃぶ台", ["脚をたたんでしまえる", "丸い形が多い", "家族みんなで囲んだ", "「ひっくり返す」場面が有名"]),
                ("蚊帳", ["夏に使う", "網のような布", "部屋につって中で寝る", "蚊を防ぐ"]),
                ("火鉢", ["中に灰が入っている", "炭を入れる", "手をかざして温まる", "冬の暖房"]),
                ("湯たんぽ", ["金属や陶器でできている", "中にお湯を入れる", "布団の中に入れる", "足を温める"]),
                ("氷の冷蔵庫", ["木の箱", "上の段に大きな氷を入れる", "氷屋さんが届けてくれた", "食べ物を冷やす"]),
                ("足踏みミシン", ["鉄の脚と板がある", "足で踏んで動かす", "糸と針を使う", "服を縫う"]),
                ("七輪", ["土でできている", "中に炭を入れる", "うちわであおぐ", "さんまを焼く"]),
                ("そろばん", ["木の枠がある", "玉がたくさん並ぶ", "パチパチと音がする", "計算に使う"]),
                ("柱時計", ["壁に掛ける", "振り子がある", "ねじを巻く", "ボーンボーンと時を知らせる"]),
                ("ブラウン管テレビ", ["奥行きが大きい", "チャンネルを回した", "上にアンテナをのせた", "映りが悪いとたたいた"]),
                ("蓄音機", ["ラッパのような形", "ハンドルを回す", "針をそっと落とす", "レコードを聞く"]),
                ("かまど", ["土やレンガでできている", "薪を燃やす", "上に釜をのせる", "ご飯を炊く"]),
                ("五右衛門風呂", ["鉄でできている", "下から火を焚く", "底の板を沈めて入る", "お風呂"]),
                ("たらい", ["丸くて浅い", "金属や木でできている", "行水にも使った", "洗濯物を入れる大きな入れ物"]),
                ("ガリ版", ["ろうを塗った紙", "鉄筆で字を書く", "インクとローラーを使う", "学校のプリントを刷った"]),
                ("二槽式洗濯機", ["箱が2つ並んでいる", "片方で洗う", "もう片方で脱水する", "服を洗う電気製品"]),
                ("赤電話", ["赤い色", "お店の前に置いてあった", "10円玉を入れる", "だれでも使える電話"]),
                ("ハエ取り紙", ["天井からつるす", "ベタベタしている", "茶色い帯", "虫をくっつけて取る"]),
                ("炭火アイロン", ["鉄でできている", "中に炭を入れる", "布を熱でのばす", "服のしわを取る"]),
                ("行灯", ["紙を貼った木の枠", "中に油の皿がある", "火を灯す", "昔の明かり"]),
                ("真空管ラジオ", ["木の箱に入っている", "つまみを回す", "温まるまで音が出ない", "番組を聞く"]),
                ("竹馬", ["竹でできている", "2本で1組", "足をのせる台がある", "乗って歩く遊び道具"]),
                ("けん玉", ["木でできている", "糸で玉がつながっている", "皿が3つある", "玉を剣の先にさす"]),
                ("めんこ", ["厚い紙でできている", "絵が描いてある", "地面にたたきつける", "相手のものを裏返したら勝ち"]),
                ("下駄", ["木でできている", "歯が2本ある", "鼻緒がある", "カランコロンと鳴る"]),
                ("フィルムカメラ", ["24枚撮りや36枚撮りがある", "写真屋さんで現像した", "巻き上げレバーがある", "写真を撮る"]),
            ]
        } else {
            prompt = "What is this?"
            data = [
                ("A washboard", ["Made of wood and metal", "Has a ridged surface", "Used with a tub of water", "You scrub clothes on it"]),
                ("A rotary phone", ["Heavy and often black", "Has a dial with finger holes", "Rings loudly", "You pick up the receiver to talk"]),
                ("A typewriter", ["Heavy and made of metal", "Goes clack-clack", "Rings a bell at the end of a line", "Puts letters on paper"]),
                ("A record player", ["Has a spinning platter", "Has a needle on an arm", "Plays at 33 or 45", "Plays vinyl records"]),
                ("A cassette tape", ["Small plastic case", "Has two little wheels", "You rewind it with a pencil", "Holds music or voices"]),
                ("An icebox", ["A wooden cabinet", "Lined with metal", "The iceman delivered to it", "Kept food cold"]),
                ("A hot water bottle", ["Made of rubber", "Has a screw cap", "You fill it from the kettle", "Warms your feet in bed"]),
                ("A flat iron", ["Solid metal", "Heated on the stove", "Used in pairs, one heating", "Pressed the wrinkles out of clothes"]),
                ("An oil lamp", ["Has a glass chimney", "Has a wick", "Burns kerosene", "Gave light before electricity"]),
                ("A butter churn", ["Tall wooden barrel", "Has a long handle", "You push it up and down", "Turns cream into butter"]),
                ("A film camera", ["Rolls of 24 or 36", "Has a wind-on lever", "You took the roll to be developed", "Takes photographs"]),
                ("A transistor radio", ["Small and fits in a pocket", "Runs on batteries", "Has a tuning dial", "Plays the ballgame and music"]),
                ("A phone booth", ["Stands on the street corner", "Has a folding door", "Takes coins", "A public telephone"]),
                ("A pocket watch", ["Has a chain", "Has a cover that clicks open", "You wind it every day", "Tells the time"]),
                ("An egg beater", ["Has a crank handle", "Has two metal whisks", "You turn it fast", "Whips eggs and cream"]),
                ("A milk bottle", ["Made of glass", "Left on the doorstep", "The milkman brought it", "Holds milk"]),
                ("A slide rule", ["Long and narrow", "Has a sliding middle part", "Covered with tiny numbers", "Engineers did math with it"]),
            ]
        }
        return data.map { QuizItem(prompt: prompt, hints: $0.1, answer: $0.0) }
    }

    // MARK: - この年なにがあった？（.choices）

    static func nenpyo() -> [QuizItem] {
        let events: [(Int, String)]
        let prompt: String
        if L.isJa {
            prompt = "この年にあったのは？"
            events = [
                (1946, "日本国憲法が公布された"),
                (1949, "湯川秀樹がノーベル賞を受賞"),
                (1951, "サンフランシスコ平和条約に調印"),
                (1953, "テレビ放送が始まった"),
                (1954, "映画『ゴジラ』が公開された"),
                (1956, "日本が国際連合に加盟"),
                (1958, "東京タワーが完成"),
                (1959, "皇太子さまと美智子さまがご結婚"),
                (1960, "カラーテレビの本放送が始まった"),
                (1963, "黒部ダムが完成"),
                (1964, "東京オリンピックが開かれた"),
                (1966, "ビートルズが来日"),
                (1968, "川端康成がノーベル文学賞を受賞"),
                (1969, "アポロ11号が月に着陸"),
                (1970, "大阪で万国博覧会が開かれた"),
                (1971, "カップヌードルが発売された"),
                (1972, "札幌オリンピックが開かれた"),
                (1973, "オイルショックが起きた"),
                (1974, "長嶋茂雄が引退"),
                (1977, "王貞治が756号ホームラン"),
                (1978, "成田空港が開港"),
                (1983, "東京ディズニーランドが開園"),
                (1985, "つくば科学万博が開かれた"),
                (1987, "国鉄が分かれてJRが生まれた"),
                (1988, "青函トンネルが開業"),
                (1989, "元号が「平成」になった"),
                (1993, "皇太子さまと雅子さまがご結婚"),
                (1998, "長野オリンピックが開かれた"),
            ]
        } else {
            prompt = "What happened this year?"
            events = [
                (1953, "Mount Everest was climbed for the first time"),
                (1955, "Disneyland opened in California"),
                (1957, "Sputnik, the first satellite, was launched"),
                (1961, "Yuri Gagarin became the first person in space"),
                (1964, "The Beatles played on The Ed Sullivan Show"),
                (1966, "England won the World Cup"),
                (1967, "The first human heart transplant"),
                (1969, "Apollo 11 landed on the Moon"),
                (1970, "The Beatles broke up"),
                (1971, "Walt Disney World opened in Florida"),
                (1975, "Microsoft was founded"),
                (1976, "Concorde began passenger flights"),
                (1977, "The first Star Wars movie came out"),
                (1981, "Prince Charles married Lady Diana"),
                (1984, "Apple released the first Macintosh"),
                (1985, "The Live Aid concerts were held"),
                (1989, "The Berlin Wall came down"),
                (1990, "The Hubble Space Telescope was launched"),
                (1994, "The Channel Tunnel opened"),
                (1997, "Hong Kong was handed back to China"),
            ]
        }
        return events.map { (e: (Int, String)) -> QuizItem in
            let (year, event) = e
            // まちがいの選択肢は、ちがう年の出来事から選ぶ
            let wrong = events.filter { $0.0 != year }.shuffled().prefix(3).map { $0.1 }
            let label = L.isJa ? "\(year)年" : "\(year)"
            return choice(prompt, .big(label), answer: event, wrong: Array(wrong), note: L.isJa ? era(year) : "")
        }
    }

    /// 西暦を「昭和39年」のように
    static func era(_ year: Int) -> String {
        if year <= 1988 { return "昭和\(year - 1925)年" }
        if year == 1989 { return "平成元年" }
        return "平成\(year - 1988)年"
    }

    // MARK: - 季節の行事クイズ（.choices）

    static func gyouji() -> [QuizItem] {
        // (問題, 絵文字, 答え, まちがい3つ, 一言)
        let data: [(String, String, String, [String], String)]
        if L.isJa {
            data = [
                ("節分に豆をまくのは何月？", "👹", "2月", ["1月", "3月", "4月"], "「鬼は外、福は内」"),
                ("ひな祭りは何月何日？", "🎎", "3月3日", ["2月3日", "5月5日", "7月7日"], "桃の節句ともいいます"),
                ("こどもの日は何月何日？", "🎏", "5月5日", ["3月3日", "4月29日", "7月7日"], "端午の節句です"),
                ("七夕は何月何日？", "🎋", "7月7日", ["6月6日", "8月8日", "7月17日"], "織姫と彦星が会う日"),
                ("端午の節句に外に飾るのは？", "🎏", "こいのぼり", ["ひな人形", "門松", "七夕飾り"], ""),
                ("ひな祭りに食べるお菓子は？", "🎎", "ひなあられ", ["柏餅", "月見団子", "千歳飴"], ""),
                ("こどもの日に食べるお菓子は？", "🍃", "柏餅", ["ひなあられ", "おはぎ", "月見団子"], "柏の葉で包んだお餅"),
                ("1月7日に食べるのは？", "🌿", "七草がゆ", ["年越しそば", "恵方巻", "お雑煮"], "1年の健康を願います"),
                ("大みそかに食べるのは？", "🍜", "年越しそば", ["七草がゆ", "柏餅", "うなぎ"], "細く長く生きられるように"),
                ("冬至に入るお風呂は？", "🛁", "ゆず湯", ["菖蒲湯", "桜湯", "みかん湯"], ""),
                ("冬至に食べるとよいといわれる野菜は？", "🎃", "かぼちゃ", ["きゅうり", "なす", "トマト"], ""),
                ("こどもの日に入るお風呂は？", "🛁", "菖蒲湯", ["ゆず湯", "桜湯", "みかん湯"], ""),
                ("十五夜にお団子と一緒に飾る草は？", "🌕", "すすき", ["ささ", "松", "菊"], ""),
                ("七五三でもらう細長いあめは？", "🍬", "千歳飴", ["べっこう飴", "金平糖", "わたあめ"], "長生きを願います"),
                ("節分に恵方を向いて食べるのは？", "🍣", "恵方巻", ["いなり寿司", "おにぎり", "お雑煮"], ""),
                ("お正月に玄関に飾るのは？", "🎍", "門松", ["こいのぼり", "笹飾り", "ひな人形"], ""),
                ("秋のお彼岸に供えるのは？", "🍡", "おはぎ", ["柏餅", "ひなあられ", "千歳飴"], "春は「ぼたもち」と呼びます"),
                ("土用の丑の日に食べるのは？", "🐟", "うなぎ", ["さんま", "たい", "いわし"], ""),
                ("七夕で願いごとを書く紙は？", "🎋", "短冊", ["色紙", "年賀状", "おみくじ"], ""),
                ("七夕で織姫と会うのは？", "🌌", "彦星", ["桃太郎", "浦島太郎", "金太郎"], ""),
                ("鏡開きはふつう何月何日？", "🍙", "1月11日", ["1月1日", "1月7日", "2月11日"], "鏡餅を割って食べます"),
                ("春の七草に入るのは？", "🌱", "せり", ["ききょう", "はぎ", "ひまわり"], "ききょう・はぎは秋の七草"),
                ("母の日は5月の何曜日？", "💐", "第2日曜日", ["第1月曜日", "第3日曜日", "第4土曜日"], ""),
                ("敬老の日は9月の何曜日？", "🍵", "第3月曜日", ["第1日曜日", "第2土曜日", "第4金曜日"], ""),
                ("お盆にきゅうりとなすで作るのは？", "🥒", "馬と牛", ["犬と猫", "鶴と亀", "舟と車"], "ご先祖さまの乗り物です"),
                ("「桃の節句」はどの行事？", "🍑", "ひな祭り", ["こどもの日", "七夕", "お月見"], ""),
                ("大みそかに鳴らす除夜の鐘は何回？", "🔔", "108回", ["12回", "88回", "100回"], "煩悩の数といわれます"),
                ("夏服に着替える衣替えはふつう何月何日？", "👕", "6月1日", ["4月1日", "5月5日", "7月1日"], ""),
                ("節分の次の日は？", "🌸", "立春", ["春分", "立夏", "冬至"], "暦の上で春が始まる日"),
                ("八十八夜のころにするのは？", "🍵", "お茶つみ", ["稲刈り", "もちつき", "雪かき"], "5月2日ごろです"),
            ]
        } else {
            data = [
                ("When is Halloween?", "🎃", "October 31", ["October 13", "November 1", "September 30"], ""),
                ("When is Valentine's Day?", "💝", "February 14", ["February 28", "March 14", "January 14"], ""),
                ("When is Groundhog Day?", "🦫", "February 2", ["March 2", "April 1", "January 20"], ""),
                ("What color do people wear on St. Patrick's Day?", "☘️", "Green", ["Red", "Blue", "Orange"], "It is on March 17"),
                ("What is the main dish at Thanksgiving?", "🦃", "Turkey", ["Ham", "Lobster", "Hot dogs"], ""),
                ("Thanksgiving in the US is on which day in November?", "🍂", "The 4th Thursday", ["The 1st Monday", "The 2nd Friday", "The last Sunday"], ""),
                ("Which animal brings eggs at Easter?", "🐰", "A rabbit", ["A cat", "A duck", "A squirrel"], "The Easter Bunny"),
                ("What do people carve at Halloween?", "🎃", "Pumpkins", ["Watermelons", "Potatoes", "Apples"], "Jack-o'-lanterns"),
                ("At Christmas, people kiss under the...", "🌿", "Mistletoe", ["Holly", "Ivy", "Oak"], ""),
                ("When is US Independence Day?", "🎆", "July 4", ["June 14", "July 14", "August 4"], ""),
                ("When is April Fools' Day?", "🤡", "April 1", ["April 15", "March 31", "May 1"], ""),
                ("In which month is the shortest day of the year?", "❄️", "December", ["January", "February", "November"], "In the northern half of the world"),
                ("When is Guy Fawkes Night in Britain?", "🎇", "November 5", ["October 31", "December 5", "November 11"], ""),
                ("What day comes after Christmas Day in Britain?", "🎁", "Boxing Day", ["Easter Monday", "Twelfth Night", "Labor Day"], ""),
                ("What song do people sing at New Year?", "🥂", "Auld Lang Syne", ["Jingle Bells", "Happy Birthday", "Silent Night"], ""),
                ("US Labor Day is on which day in September?", "🛠️", "The 1st Monday", ["The 2nd Monday", "The 3rd Friday", "The last Sunday"], ""),
                ("Mother's Day in the US is in which month?", "💐", "May", ["March", "June", "August"], "The 2nd Sunday"),
                ("Which date appears only once every four years?", "📅", "February 29", ["February 30", "December 32", "June 31"], "A leap day"),
            ]
        }
        return data.map { choice($0.0, .emoji($0.1), answer: $0.2, wrong: $0.3, note: $0.4) }
    }

    // MARK: - あたま体操 計算（.open、毎回作り直す）

    static func keisan() -> [QuizItem] {
        var items: [QuizItem] = []
        let ask = L.t("いくつでしょう？", "What is the answer?")
        // やさしい順に 30 問
        for i in 0..<30 {
            switch i % 6 {
            case 0:
                let a = Int.random(in: 11...49), b = Int.random(in: 11...39)
                items.append(QuizItem(prompt: ask, visual: .big("\(a) ＋ \(b)"), answer: "\(a + b)"))
            case 1:
                let a = Int.random(in: 40...99), b = Int.random(in: 11...a - 10)
                items.append(QuizItem(prompt: ask, visual: .big("\(a) − \(b)"), answer: "\(a - b)"))
            case 2:
                let a = Int.random(in: 2...9), b = Int.random(in: 2...9)
                items.append(QuizItem(prompt: ask, visual: .big("\(a) × \(b)"), answer: "\(a * b)"))
            case 3:
                items.append(coins())
            case 4:
                items.append(change())
            default:
                let a = Int.random(in: 2...9) * 10, b = Int.random(in: 2...9) * 10, c = Int.random(in: 1...9)
                items.append(QuizItem(prompt: ask, visual: .big("\(a) ＋ \(b) ＋ \(c)"), answer: "\(a + b + c)"))
            }
        }
        return items
    }

    /// 硬貨の合計
    private static func coins() -> QuizItem {
        if L.isJa {
            let h = Int.random(in: 1...5), t = Int.random(in: 1...9), f = Int.random(in: 0...1)
            var text = "100円玉が\(h)枚、10円玉が\(t)枚"
            if f == 1 { text += "、50円玉が1枚" }
            return QuizItem(prompt: text + "。\n全部でいくら？", answer: "\(h * 100 + t * 10 + f * 50)円")
        } else {
            let q = Int.random(in: 1...3), d = Int.random(in: 1...5), n = Int.random(in: 0...2)
            var text = "\(q) quarter\(q > 1 ? "s" : "") and \(d) dime\(d > 1 ? "s" : "")"
            if n > 0 { text += " and \(n) nickel\(n > 1 ? "s" : "")" }
            return QuizItem(prompt: text + ".\nHow many cents?", answer: "\(q * 25 + d * 10 + n * 5) cents")
        }
    }

    /// おつり
    private static func change() -> QuizItem {
        if L.isJa {
            let pay = [500, 1000].randomElement()!
            let price = Int.random(in: 6...(pay / 10 - 6)) * 10
            let things = ["パン", "お弁当", "牛乳", "おまんじゅう", "大根", "お花"]
            return QuizItem(prompt: "\(pay)円玉を出して、\(price)円の\(things.randomElement()!)を買いました。\nおつりは？"
                                .replacingOccurrences(of: "1000円玉", with: "1000円札"),
                            answer: "\(pay - price)円")
        } else {
            let pay = [5, 10, 20].randomElement()!
            let price = Int.random(in: 1...(pay - 1))
            let things = ["a loaf of bread", "a bunch of flowers", "a book", "a cake", "a pie"]
            return QuizItem(prompt: "You pay $\(pay) for \(things.randomElement()!) that costs $\(price).\nHow much change?",
                            answer: "$\(pay - price)")
        }
    }
}
