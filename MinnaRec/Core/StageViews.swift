import SwiftUI

/// プロジェクターに映す画面。iPad だけのときは iPad の左側にも出る
struct StageView: View {
    @EnvironmentObject var s: Session

    var body: some View {
        StageCanvas {
            if let e = s.engine {
                EngineStage(engine: e)
            } else {
                WelcomeStage()
            }
        }
    }
}

struct EngineStage: View {
    @EnvironmentObject var s: Session
    @ObservedObject var engine: GameEngine

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                Text(engine.id.emoji).font(.system(size: 52))
                Text(engine.id.title)
                    .font(.big(46))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()
            }
            .padding(.horizontal, 50)
            .frame(height: 100)
            .background(engine.id.category.color)

            ZStack {
                if engine.showIntro {
                    IntroCard(id: engine.id)
                        .transition(.opacity)
                } else {
                    engine.stage()
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.3), value: engine.showIntro)

            if engine.usesTeams && s.showScoreboard && !engine.showIntro {
                ScoreboardStrip()
            }
        }
    }
}

struct WelcomeStage: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("🎵 🎲 🎡 👏 🎱")
                .font(.system(size: 110))
            Text(L.t("みんなでレク", "Minna Rec"))
                .font(.big(170))
                .foregroundStyle(Theme.accent)
            Text(L.t("まもなく はじまります", "We'll begin shortly"))
                .font(.big(64))
                .foregroundStyle(Theme.ink)
        }
    }
}

struct IntroCard: View {
    let id: GameID

    var body: some View {
        VStack(spacing: 34) {
            HStack(spacing: 30) {
                Text(id.emoji).font(.system(size: 150))
                Text(id.title)
                    .font(.big(88))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            StageCard(padding: 44) {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(Array(id.rules.enumerated()), id: \.offset) { i, rule in
                        HStack(alignment: .top, spacing: 24) {
                            Text("\(i + 1)")
                                .font(.big(46))
                                .foregroundStyle(.white)
                                .frame(width: 72, height: 72)
                                .background(Circle().fill(id.category.color))
                            Text(rule)
                                .font(.big(56))
                                .foregroundStyle(Theme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: 1300, alignment: .leading)
            }
        }
        .padding(40)
    }
}

/// 下に出すチームの点数
struct ScoreboardStrip: View {
    @EnvironmentObject var s: Session

    var body: some View {
        HStack(spacing: 24) {
            ForEach(s.teams) { team in
                HStack(spacing: 18) {
                    Circle().fill(team.color).frame(width: 46, height: 46)
                        .overlay(Circle().stroke(Theme.ink.opacity(0.3), lineWidth: 3))
                    Text(team.name).font(.big(46)).foregroundStyle(Theme.ink)
                    Text("\(team.score)")
                        .font(.big(70))
                        .foregroundStyle(team.color)
                        .contentTransition(.numericText())
                        .animation(.spring, value: team.score)
                    Text(L.t("点", "pts")).font(.big(34)).foregroundStyle(Theme.sub)
                }
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(RoundedRectangle(cornerRadius: 26).fill(Theme.card))
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(team.color, lineWidth: 5))
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 14)
        .frame(height: 132)
    }
}

/// 大きい字のことば（長いと自動で小さくなる）
struct StageText: View {
    let text: String
    var size: CGFloat = 90
    var color: Color = Theme.ink

    init(_ text: String, size: CGFloat = 90, color: Color = Theme.ink) {
        self.text = text
        self.size = size
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.big(size))
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.35)
    }
}

/// 「おつかれさまでした」画面
struct FinishStage: View {
    @EnvironmentObject var s: Session
    var message: String = L.t("おつかれさまでした！", "Great job, everyone!")

    var body: some View {
        VStack(spacing: 40) {
            Text("🎉").font(.system(size: 160))
            StageText(message, size: 110, color: Theme.accent)
            if s.showScoreboard, let best = s.teams.max(by: { $0.score < $1.score }), best.score > 0,
               s.teams.filter({ $0.score == best.score }).count == 1 {
                StageText(L.t("\(best.name)の勝ち！", "\(best.name) wins!"), size: 80, color: best.color)
            }
        }
    }
}
