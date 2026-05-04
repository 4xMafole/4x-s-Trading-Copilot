import ActivityKit
import WidgetKit
import SwiftUI

struct TradingSessionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var sessionLabel: String
        var tradesRemaining: Int
        var eatTime: String
    }

    var name: String
}

struct TradingSessionLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TradingSessionAttributes.self) { context in
            VStack(alignment: .leading, spacing: 6) {
                Text("4x Trades")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.state.eatTime)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(context.state.sessionLabel)
                    .font(.subheadline)
                    .foregroundStyle(.green)
                Text("\(context.state.tradesRemaining) trades left today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.eatTime)
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.tradesRemaining) left")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.sessionLabel)
                        .font(.caption)
                        .lineLimit(1)
                }
            } compactLeading: {
                Text("4x")
            } compactTrailing: {
                Text("\(context.state.tradesRemaining)")
            } minimal: {
                Text("4x")
            }
        }
    }
}
