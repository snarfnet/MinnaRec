import Foundation

extension QuizBank {
    // MARK: - シルエット当て（.open）

    static func silhouette() -> [QuizItem] {
        // (絵文字, 日本語, English)。形だけで当てられるもの
        let data: [(String, String, String)] = [
            ("🐘", "ゾウ", "Elephant"),
            ("🦒", "キリン", "Giraffe"),
            ("🐇", "ウサギ", "Rabbit"),
            ("🐈", "ネコ", "Cat"),
            ("🐕", "イヌ", "Dog"),
            ("🐓", "ニワトリ", "Rooster"),
            ("🐢", "カメ", "Turtle"),
            ("🐌", "カタツムリ", "Snail"),
            ("🦀", "カニ", "Crab"),
            ("🐙", "タコ", "Octopus"),
            ("🐳", "クジラ", "Whale"),
            ("🦋", "チョウ", "Butterfly"),
            ("🐿️", "リス", "Squirrel"),
            ("🦌", "シカ", "Deer"),
            ("🐎", "ウマ", "Horse"),
            ("🐪", "ラクダ", "Camel"),
            ("🦩", "フラミンゴ", "Flamingo"),
            ("🐧", "ペンギン", "Penguin"),
            ("🦖", "恐竜", "Dinosaur"),
            ("🚲", "自転車", "Bicycle"),
            ("✈️", "飛行機", "Airplane"),
            ("🚂", "汽車", "Steam train"),
            ("⛵", "ヨット", "Sailboat"),
            ("🚁", "ヘリコプター", "Helicopter"),
            ("🍌", "バナナ", "Banana"),
            ("🍎", "リンゴ", "Apple"),
            ("🍇", "ブドウ", "Grapes"),
            ("🍄", "キノコ", "Mushroom"),
            ("🎸", "ギター", "Guitar"),
            ("🎺", "トランペット", "Trumpet"),
            ("☂️", "かさ", "Umbrella"),
            ("✂️", "はさみ", "Scissors"),
            ("🔑", "かぎ", "Key"),
            ("🔨", "かなづち", "Hammer"),
            ("⏰", "目覚まし時計", "Alarm clock"),
            ("🗼", "東京タワー", "Tokyo Tower"),
        ]
        let ask = L.t("この影は何でしょう？", "What is this shadow?")
        return data.map { QuizItem(prompt: ask, visual: .silhouette($0.0), answer: L.isJa ? $0.1 : $0.2) }
    }

    // MARK: - ズームアップ当て（.zoom）

    static func zoom() -> [QuizItem] {
        let data: [(String, String, String)] = [
            ("🍓", "イチゴ", "Strawberry"),
            ("🍉", "スイカ", "Watermelon"),
            ("🌻", "ひまわり", "Sunflower"),
            ("🌸", "桜", "Cherry blossom"),
            ("🍙", "おにぎり", "Rice ball"),
            ("🍣", "おすし", "Sushi"),
            ("🍡", "だんご", "Dango"),
            ("🎃", "かぼちゃ", "Pumpkin"),
            ("🌽", "とうもろこし", "Corn"),
            ("🍅", "トマト", "Tomato"),
            ("🥕", "にんじん", "Carrot"),
            ("🐞", "テントウムシ", "Ladybug"),
            ("🐝", "ハチ", "Bee"),
            ("🐼", "パンダ", "Panda"),
            ("🦁", "ライオン", "Lion"),
            ("🐯", "トラ", "Tiger"),
            ("🦉", "フクロウ", "Owl"),
            ("🐸", "カエル", "Frog"),
            ("🍔", "ハンバーガー", "Hamburger"),
            ("🎂", "ケーキ", "Cake"),
            ("⚽", "サッカーボール", "Soccer ball"),
            ("🎈", "風船", "Balloon"),
            ("🎁", "プレゼント", "Present"),
            ("🗻", "富士山", "Mount Fuji"),
            ("🌈", "にじ", "Rainbow"),
            ("🚒", "消防車", "Fire engine"),
            ("🚗", "自動車", "Car"),
            ("🏠", "家", "House"),
            ("👓", "めがね", "Glasses"),
            ("🍞", "パン", "Bread"),
            ("🥚", "たまご", "Egg"),
            ("🍊", "みかん", "Orange"),
            ("🐠", "熱帯魚", "Tropical fish"),
        ]
        let ask = L.t("これは何でしょう？", "What is it?")
        return data.map { QuizItem(prompt: ask, visual: .emoji($0.0), answer: L.isJa ? $0.1 : $0.2) }
    }
}
