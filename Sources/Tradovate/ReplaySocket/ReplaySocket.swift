import Foundation

extension Tradovate {
    public final class ReplaySocket: Socket {
        private var clock: Request.Clock
        private var clockEventAction: ((Response.Clock) -> Void)? = nil
        
        deinit {
            clockEventAction = nil
        }
        
        public init(_ clock: Request.Clock) throws {
            self.clock = clock
            try super.init(url: URL(string: "wss://replay.tradovateapi.com/v1/websocket")!)
        }
        
        public override func handleEvent(_ message: JSON, eventType: String) {
            do {
                switch eventType {
                case "clock":
                    guard let data = message.data(using: .utf8) else { return }
                    clockEventAction?(try Tradovate.jsonDecoder.decode(Response.Clock.self, from: data))
                default:
                    print("🟡 unhandled server event:", eventType, message)
                }
            } catch {
                print("🔴 failed while trying to handle event: \(eventType) message: \(message) with error:", error)
            }
        }
        
        public override func handleOpenFrame() {
            initializeClock(clock)
        }
        
        public func onClockEvent(_ action: @escaping (Response.Clock) -> Void) -> Self {
            self.clockEventAction = action
            return self
        }
    }
}
