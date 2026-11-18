import SwiftUI

/// iPad の画面
struct HostRootView: View {
    @EnvironmentObject var s: Session

    var body: some View {
        Group {
            if let e = s.engine {
                HostGameView(engine: e)
            } else {
                MenuView()
            }
        }
        .onAppear { ScreenshotMode.apply(s) }
    }
}

// MARK: - メニュー

struct MenuView: View {
    @EnvironmentObject var s: Session
    @State private var showSettings = false

    private let columns = [GridItem(.adaptive(minimum: 230, maximum: 320), spacing: 16)]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text(L.t("シニアーズゲーム", "Seniors Games"))
                    .font(.round(34, .heavy))
                    .foregroundStyle(Theme.accent)
                DisplayBadge()
                Spacer()
                Button { showSettings = true } label: {
                    Label(L.t("設定", "Settings"), systemImage: "gearshape.fill")
                        .font(.round(20))
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(Capsule().fill(Theme.ink.opacity(0.08)))
                }
                .foregroundStyle(Theme.ink)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(GameCategory.allCases, id: \.self) { cat in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(cat.title)
                                .font(.round(22, .heavy))
                                .foregroundStyle(cat.color)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(cat.games) { g in
                                    GameCard(id: g) { s.open(g) }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .sheet(isPresented: $showSettings) { SettingsSheet() }
    }
}

struct GameCard: View {
    let id: GameID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(id.emoji).font(.system(size: 46))
                VStack(alignment: .leading, spacing: 4) {
                    Text(id.title)
                        .font(.round(19, .heavy))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)
                    Text(id.tagline)
                        .font(.round(14, .medium))
                        .foregroundStyle(Theme.sub)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3).fill(id.category.color).frame(width: 6).padding(.vertical, 14)
            }
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

/// プロジェクターにつながっているか
struct DisplayBadge: View {
    @EnvironmentObject var s: Session

    var body: some View {
        Label(s.externalAttached ? L.t("プロジェクターに映しています", "Showing on the big screen")
                                 : L.t("iPad だけで表示中", "iPad only"),
              systemImage: s.externalAttached ? "tv.fill" : "ipad.landscape")
            .font(.round(15))
            .foregroundStyle(s.externalAttached ? Theme.green : Theme.sub)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill((s.externalAttached ? Theme.green : Theme.sub).opacity(0.12)))
    }
}

struct SettingsSheet: View {
    @EnvironmentObject var s: Session
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(L.t("チーム", "Teams")) {
                    Toggle(L.t("点数を表示する", "Show scores"), isOn: $s.showScoreboard)
                    Stepper(L.t("チームの数：\(s.teamCount)", "Teams: \(s.teamCount)"), value: $s.teamCount, in: 1...4)
                    Button(L.t("点数を0にもどす", "Reset scores"), role: .destructive) { s.resetScores() }
                }
                Section(L.t("音", "Sound")) {
                    Toggle(L.t("問題を読み上げる", "Read questions aloud"), isOn: $s.speechOn)
                }
                Section(L.t("ことば", "Language")) {
                    Picker(L.t("表示", "Display"), selection: $s.langJa) {
                        Text("日本語").tag(true)
                        Text("English").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                Section(L.t("プロジェクターへのつなぎ方", "Connecting a projector")) {
                    Text(L.t("HDMI アダプタでつなぐか、コントロールセンターの「画面ミラーリング」で Apple TV などを選びます。つながると、大きい画面にはゲームだけが映り、iPad は操作盤になります。",
                             "Use an HDMI adapter, or choose Screen Mirroring in Control Center. Once connected, the big screen shows only the game and the iPad becomes your control panel."))
                        .font(.round(15, .regular))
                }
            }
            .navigationTitle(L.t("設定", "Settings"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L.t("閉じる", "Done")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - ゲーム中

struct HostGameView: View {
    @EnvironmentObject var s: Session
    @ObservedObject var engine: GameEngine

    var body: some View {
        HStack(spacing: 0) {
            if s.externalAttached {
                VStack(alignment: .leading, spacing: 12) {
                    DisplayBadge()
                    StageView()
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.3), lineWidth: 2))
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.hostBg)
            } else {
                StageView()
                    .overlay(alignment: .topTrailing) {
                        if s.panelHidden {
                            Button { withAnimation { s.panelHidden = false } } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.round(24))
                                    .foregroundStyle(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Circle().fill(Theme.ink.opacity(0.55)))
                            }
                            .padding(14)
                        }
                    }
            }
            if !s.panelHidden || s.externalAttached {
                HostPanel(engine: engine)
                    .frame(width: 340)
                    .transition(.move(edge: .trailing))
            }
        }
        .background(Theme.hostBg.ignoresSafeArea())
    }
}

struct HostPanel: View {
    @EnvironmentObject var s: Session
    @ObservedObject var engine: GameEngine
    @State private var confirmBack = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button { confirmBack = true } label: {
                    Label(L.t("メニュー", "Menu"), systemImage: "chevron.left")
                        .font(.round(18))
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Capsule().fill(.white.opacity(0.12)))
                }
                Spacer()
                if !s.externalAttached {
                    Button { withAnimation { s.panelHidden = true } } label: {
                        Label(L.t("隠す", "Hide"), systemImage: "arrow.right.to.line")
                            .font(.round(18))
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(Capsule().fill(.white.opacity(0.12)))
                    }
                }
            }
            .foregroundStyle(.white)

            ScrollView {
                VStack(spacing: 12) {
                    if engine.showIntro {
                        HostButton(title: L.t("はじめる", "Start"), symbol: "play.fill", color: Theme.green, big: true) {
                            Speech.stop()
                            engine.begin()
                        }
                        HostButton(title: L.t("遊び方を読み上げる", "Read the rules"), symbol: "speaker.wave.2.fill", color: Theme.hostCard) {
                            Speech.say(engine.introSpeech, force: true)
                        }
                    } else {
                        engine.controls()
                        HostButton(title: L.t("遊び方にもどる", "Show rules again"), symbol: "info.circle", color: Theme.hostCard) {
                            engine.stop()
                            engine.showIntro = true
                        }
                    }
                }
            }

            if engine.usesTeams && s.showScoreboard {
                TeamScorePad(engine: engine)
            }
        }
        .padding(14)
        .background(Theme.hostBg)
        .alert(L.t("メニューにもどりますか？", "Back to the menu?"), isPresented: $confirmBack) {
            Button(L.t("もどる", "Back"), role: .destructive) { s.close() }
            Button(L.t("続ける", "Keep playing"), role: .cancel) {}
        }
    }
}

/// チームに点を入れるボタン
struct TeamScorePad: View {
    @EnvironmentObject var s: Session
    @ObservedObject var engine: GameEngine

    var body: some View {
        VStack(spacing: 8) {
            ForEach(s.teams) { team in
                HStack(spacing: 8) {
                    Circle().fill(team.color).frame(width: 16, height: 16)
                    Text(team.name).font(.round(17)).foregroundStyle(.white)
                    Text("\(team.score)").font(.round(22, .heavy)).foregroundStyle(.white)
                        .frame(minWidth: 36)
                    Spacer()
                    Button { s.addPoint(team.id, -1) } label: {
                        Image(systemName: "minus").font(.round(18))
                            .frame(width: 44, height: 44)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.12)))
                    }
                    Button { s.addPoint(team.id, engine.pointValue) } label: {
                        Text("+\(engine.pointValue)").font(.round(20, .heavy))
                            .frame(width: 70, height: 44)
                            .background(RoundedRectangle(cornerRadius: 10).fill(team.color))
                    }
                }
                .foregroundStyle(.white)
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.hostCard))
    }
}
