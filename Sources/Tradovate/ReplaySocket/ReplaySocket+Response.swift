import Foundation

public extension Tradovate.ReplaySocket {
    struct Response {
        public struct Clock: Codable {
            public var t: Date
            /// range from 0 to 400 (in percents), 400 being 4X the real-time speed of the market.
            public var s: Int
        }
    }
}
