#!/usr/bin/env python3
"""Set version localizations (ja/en), keywords, URLs, and age rating.
Discovers the app by bundle id. Idempotent."""
import jwt, time, requests, os

KEY_ID = 'WDXGY9WX55'
ISSUER = '2be0734f-943a-4d61-9dc9-5d9045c46fec'
BUNDLE = 'com.tokyonasu.MinnaRec'
p8 = open(os.path.expanduser('~/.appstoreconnect/private_keys/AuthKey_WDXGY9WX55.p8')).read()

DESC_JA = """プロジェクターやテレビに映して、みんなで遊ぶゲーム集です。デイサービスや老人ホームのレクリエーション、地域のサロン、家族の集まりに。

iPad を HDMI でつなぐか、AirPlay で映すだけ。大きい画面にはゲームだけが映り、手元の iPad は係の人の操作盤になります。参加する方はスマホもボタンもいりません。手をあげる、声で答える、チームで相談する。それだけです。

■ 20のゲーム
思い出す：なつかし道具 3つのヒント／この年なにがあった？／なつかしの歌イントロ当て／季節の行事クイズ
ことば：ことわざ穴うめ／漢字の読み／ご当地名物当て／しりとり爆弾
見る・覚える：まちがい探し／シルエット当て／覚えてね！／ズームアップ当て／あたま体操 計算
体を動かす：旗あげゲーム／手拍子リズム体操／じゃんけん大会
みんなで：ビンゴ／チーム対抗すごろく／お題ルーレット／ハイ＆ロー

■ 係の人の手間を減らす工夫
・はじめに遊び方を大きく表示。読み上げもできます
・問題と答えを自動で読み上げ
・赤組・白組など最大4チームの点数を表示
・iPad だけでも遊べます（操作盤は隠せます）
・大きく太い字と、はっきりした色

買い切り。広告なし、アカウント不要、ネット接続も不要です。"""

DESC_EN = """Games for a room full of people, shown on a projector or TV. Made for senior centers, care homes, community clubs and family get-togethers.

Connect an iPad with HDMI or AirPlay. The big screen shows only the game, and the iPad in your hand becomes the host's control panel. Players need no phone and no buttons. They raise a hand, call out an answer, or talk it over with their team.

20 GAMES
Remember: Old Things in 3 Hints / What Happened That Year? / Name That Song / Seasons & Festivals
Words: Finish the Proverb / Read the Kanji / Famous Local Foods / Word Bomb
Look & Recall: Spot the Difference / Silhouette Quiz / Remember This! / Zoom Quiz / Brain Math
Move: Flag Game / Clap Along / Rock Paper Scissors
All Together: Bingo / Team Board Game / Topic Roulette / High or Low

EASY ON THE HOST
- Rules appear in big letters first, and can be read aloud
- Questions and answers are read aloud for you
- Score board for up to four teams
- Works on the iPad alone too (the control panel can hide)
- Large, bold text and strong colors

One-time purchase. No ads, no account, no internet needed. Some quizzes are about Japanese culture."""

KW_JA = "レク,レクリエーション,介護,高齢者,シニア,デイサービス,脳トレ,クイズ,ビンゴ,回想法,老人ホーム,すごろく,体操"
KW_EN = "senior,elderly,activity,care home,group game,trivia,bingo,projector,brain,quiz,party,memory,dementia"

PROMO_JA = "iPad をプロジェクターにつなぐだけ。20のゲームで、みんなが笑顔になるレクの時間を。"
PROMO_EN = "Plug an iPad into a projector and play 20 big-screen games together."

URL = "https://snarfnet.github.io/"

LOCS = {
    'en-US': dict(description=DESC_EN, keywords=KW_EN, promotionalText=PROMO_EN,
                  marketingUrl=URL, supportUrl=URL),
    'ja': dict(description=DESC_JA, keywords=KW_JA, promotionalText=PROMO_JA,
               marketingUrl=URL, supportUrl=URL),
}


def tok():
    return jwt.encode({'iss': ISSUER, 'iat': int(time.time()), 'exp': int(time.time()) + 1200,
                       'aud': 'appstoreconnect-v1'}, p8, algorithm='ES256', headers={'kid': KEY_ID})


def api(m, p, payload=None):
    h = {'Authorization': f'Bearer {tok()}', 'Content-Type': 'application/json'}
    return requests.request(m, f'https://api.appstoreconnect.apple.com/v1{p}',
                            headers=h, **({'json': payload} if payload else {}))


APP_ID = api('GET', f'/apps?filter[bundleId]={BUNDLE}&limit=1').json()['data'][0]['id']
VERSION_ID = api('GET', f'/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=1').json()['data'][0]['id']
print('app', APP_ID, 'version', VERSION_ID)

existing = {l['attributes']['locale']: l['id']
            for l in api('GET', f'/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations?limit=20').json()['data']}
print('existing locales', list(existing))

for locale, attrs in LOCS.items():
    if locale in existing:
        lid = existing[locale]
        r = api('PATCH', f'/appStoreVersionLocalizations/{lid}',
                {'data': {'type': 'appStoreVersionLocalizations', 'id': lid, 'attributes': attrs}})
    else:
        r = api('POST', '/appStoreVersionLocalizations',
                {'data': {'type': 'appStoreVersionLocalizations',
                          'attributes': {'locale': locale, **attrs},
                          'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VERSION_ID}}}}})
    print(locale, r.status_code, '' if r.status_code < 300 else r.text[:300])

# Age rating: party games -> all none/false
inf = api('GET', f'/apps/{APP_ID}/appInfos?include=ageRatingDeclaration').json()
decl_id = None
for i in inf.get('included', []):
    if i['type'] == 'ageRatingDeclarations':
        decl_id = i['id']
if decl_id:
    age_attrs = {
        'alcoholTobaccoOrDrugUseOrReferences': 'NONE',
        'contests': 'NONE',
        'gamblingSimulated': 'NONE',
        'medicalOrTreatmentInformation': 'NONE',
        'profanityOrCrudeHumor': 'NONE',
        'sexualContentGraphicAndNudity': 'NONE',
        'sexualContentOrNudity': 'NONE',
        'horrorOrFearThemes': 'NONE',
        'matureOrSuggestiveThemes': 'NONE',
        'violenceCartoonOrFantasy': 'NONE',
        'violenceRealisticProlongedGraphicOrSadistic': 'NONE',
        'violenceRealistic': 'NONE',
        'gambling': False,
        'unrestrictedWebAccess': False,
        'lootBox': False,
        'messagingAndChat': False,
        'parentalControls': False,
        'advertising': False,
        'healthOrWellnessTopics': False,
        'userGeneratedContent': False,
        'ageAssurance': False,
        'kidsAgeBand': None,
    }
    r = api('PATCH', f'/ageRatingDeclarations/{decl_id}',
            {'data': {'type': 'ageRatingDeclarations', 'id': decl_id, 'attributes': age_attrs}})
    print('age rating', r.status_code, '' if r.status_code < 300 else r.text[:400])
print('metadata done')
