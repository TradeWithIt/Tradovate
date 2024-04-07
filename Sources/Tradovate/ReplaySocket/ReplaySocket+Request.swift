import Foundation

public extension Tradovate.ReplaySocket {
    func initializeClock(_ clock: Request.Clock) {
        executeRequest(endpoint: "replay/initializeclock", body: clock)
    }
    
    /// Sets replay speed.
    /// - Parameter speed: range from 0 to 400 (in percents), 400 being 4X the real-time speed of the market
    func setSpeed(_ speed: Int) {
        executeRequest(endpoint: "replay/changespeed", body: Request.Speed(speed: speed))
    }
    
    struct Request {
        public struct Clock: Codable {
            public let startTimestamp: Date
            public let speed: Int
            public let initialBalance: Int
            
            public init(startTimestamp: Date, speed: Int, initialBalance: Int) {
                self.startTimestamp = startTimestamp
                self.speed = speed
                self.initialBalance = initialBalance
            }
        }
        
        public struct Speed: Codable {
            /// range from 0 to 400 (in percents), 400 being 4X the real-time speed of the market.
            public var speed: Int
            
            public init(speed: Int) {
                self.speed = speed
            }
        }
    }
}
