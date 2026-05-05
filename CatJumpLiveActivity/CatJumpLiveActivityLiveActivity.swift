import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct CatJumpLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CatJumpAttributes.self) { context in
            CatJumpLockScreenView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.9))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    catEmoji(lives: context.state.lives)
                        .font(.system(size: 28))
                        .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Lv \(context.state.level)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        livesRow(lives: context.state.lives)
                    }
                    .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    CatJumpExpandedBottomView(state: context.state)
                }
            } compactLeading: {
                catEmoji(lives: context.state.lives)
                    .font(.system(size: 13))
            } compactTrailing: {
                Text("\(context.state.score)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            } minimal: {
                catEmoji(lives: context.state.lives)
                    .font(.system(size: 12))
            }
        }
    }
}

// MARK: - Lock Screen / Notification banner

private struct CatJumpLockScreenView: View {
    let state: CatJumpAttributes.ContentState

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            catEmoji(lives: state.lives)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 0) {
                Text(state.isGameOver ? "Game Over" : "CatJump")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(state.score)")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(state.isGameOver ? .red : Color(red: 1, green: 0.55, blue: 0))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 3) {
                Text("Level \(state.level)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                livesRow(lives: state.lives)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Dynamic Island expanded bottom region

private struct CatJumpExpandedBottomView: View {
    let state: CatJumpAttributes.ContentState

    var body: some View {
        HStack(spacing: 8) {
            if state.isGameOver {
                Text("GAME OVER")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.red)
            }
            Text("\(state.score)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(state.isGameOver ? .white : Color(red: 1, green: 0.55, blue: 0))
                .lineLimit(1)
                .monospacedDigit()
            if !state.isGameOver {
                Text("pts")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 6)
    }
}

// MARK: - Helpers

private func catEmoji(lives: Int) -> Text {
    switch lives {
    case 3...: return Text("😸")
    case 2:    return Text("😺")
    case 1:    return Text("😿")
    default:   return Text("💀")
    }
}

private func livesRow(lives: Int) -> some View {
    HStack(spacing: 2) {
        ForEach(0..<max(0, min(lives, 3)), id: \.self) { _ in
            Text("❤️").font(.system(size: 9))
        }
    }
}
