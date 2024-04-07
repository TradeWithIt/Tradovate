import Foundation

extension Tradovate {
    public final class MarketDataSocket: Socket {
        private var chartEventAction: ((Response.Charts) -> Void)? = nil
        
        deinit {
            chartEventAction = nil
        }
        
        public init() throws {
            try super.init(url: URL(string: "wss://md.tradovateapi.com/v1/websocket")!)
        }
        
        public override func handleEvent(_ message: JSON, eventType: String) {
            do {
                switch eventType {
                case "chart":
                    guard let data = message.data(using: .utf8) else { return }
                    chartEventAction?(try Tradovate.jsonDecoder.decode(Response.Charts.self, from: data))
                default:
                    print("🟡 unhandled server event:", eventType, message)
                }
            } catch {
                print("🔴 failed while trying to handle event: \(eventType) message: \(message) with error:", error)
            }
        }
        
        public func onChartEvent(_ action: @escaping (Response.Charts) -> Void) -> Self {
            self.chartEventAction = action
            return self
        }
    }
}
