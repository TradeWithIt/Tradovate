import Foundation

public extension Tradovate.MarketDataSocket {
    struct Response {
        public struct ChartSubscription: Codable {
            public let realtimeId: Int
            public let historicalId: Int
        }
        
        public struct Charts: Decodable {
            public let charts: [Chart]
        }
        
        public struct Chart: Decodable {
            public let id: Int
            public let tradeDate: Int
            public let bars: [Bar]
            
            public enum CodingKeys: String, CodingKey {
                case id
                case tradeDate = "td"
                case bars
            }
        }
        
        public struct Bar: Decodable {
            public let timestamp: Date
            public let open: Double
            public let high: Double
            public let low: Double
            public let close: Double
            public let upVolume: Double
            public let downVolume: Double
            public let upTicks: Double
            public let downTicks: Double
            public let bidVolume: Double
            public let offerVolume: Double
        }
    }
}
