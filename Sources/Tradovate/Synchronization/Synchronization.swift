import Foundation

extension Tradovate {
    public final class Synchronization: Socket {
        private var syncEventAction: ((Response.Synchronization) -> Void)? = nil
        private var ids: [Int]
        
        deinit {
            syncEventAction = nil
        }
        
        public init(_ ids: [Int], url: URL = URL(string: "wss://demo.tradovateapi.com/v1/websocket")!) throws {
            self.ids = ids
            try super.init(url: url)
        }
        
        public override func handleOpenFrame() {
            userSynchronization(ids)
        }
        
        public override func handleEvent(_ message: JSON, eventType: String) {
            do {
                switch eventType {
                case "props":
                    guard let data = message.data(using: .utf8) else { return }
                    syncEventAction?(try Tradovate.jsonDecoder.decode(Response.Synchronization.self, from: data))
                default:
                    print("🟡 unhandled server event:", eventType, message)
                }
            } catch {
                print("🔴 failed while trying to handle event: \(eventType) message: \(message) with error:", error)
            }
        }
        
        public func onSyncEvent(_ action: @escaping (Response.Synchronization) -> Void) -> Self {
            self.syncEventAction = action
            return self
        }
    }
}
