import Foundation

public extension Tradovate.MarketDataSocket {
    func getChart(_ body: Request.ChartData) async throws -> Response.ChartSubscription {
        try await withCheckedThrowingContinuation { continuation in
            executeRequest(endpoint: "md/getChart", body: body) { result in
                do {
                    switch result {
                    case .success(let json):
                        guard let data = json?.data(using: .utf8) else {
                            continuation.resume(throwing: Tradovate.Socket.Error.invalidInput)
                            return
                        }
                        let response = try Tradovate.jsonDecoder.decode(Response.ChartSubscription.self, from: data)
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getChart(_ body: Request.ChartData, completion: ( (Result<Response.ChartSubscription?, Swift.Error>) -> Void)? = nil) {
        executeRequest(endpoint: "md/getChart", body: body) { result in
            do {
                switch result {
                case .success(let json):
                    guard let data = json?.data(using: .utf8) else {
                        completion?(.failure(Tradovate.Socket.Error.invalidInput))
                        return
                    }
                    let response = try Tradovate.jsonDecoder.decode(Response.ChartSubscription.self, from: data)
                    completion?(.success(response))
                case .failure(let error):
                    completion?(.failure(error))
                }
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    func cancelChart(_ id: Int) {
        executeRequest(endpoint: "md/cancelChart", body: Request.CancelSubscription(subscriptionId: id))
    }
    
    struct Request {
        // Define an enum to handle the "symbol" field which can be either a String or an Integer
        public enum Symbol: Codable {
            case string(String)
            case integer(Int)
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let stringValue = try? container.decode(String.self) {
                    self = .string(stringValue)
                } else if let intValue = try? container.decode(Int.self) {
                    self = .integer(intValue)
                } else {
                    throw DecodingError.typeMismatch(Symbol.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected a String or an Integer"))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let stringValue):
                    try container.encode(stringValue)
                case .integer(let intValue):
                    try container.encode(intValue)
                }
            }
        }

        // Model for "chartDescription"
        public struct ChartDescription: Codable {
            public let underlyingType: String
            public let elementSize: Int
            public let elementSizeUnit: String
            public let withHistogram: Bool
            
            public init(
                underlyingType: String = "MinuteBar",
                elementSize: Int = 15,
                elementSizeUnit: String = "UnderlyingUnits",
                withHistogram: Bool = false
            ) {
                self.underlyingType = underlyingType
                self.elementSize = elementSize
                self.elementSizeUnit = elementSizeUnit
                self.withHistogram = withHistogram
            }
        }

        // Model for "timeRange"
        public struct TimeRange: Codable {
            public let closestTimestamp: String?
            public let closestTickId: Int?
            public let asFarAsTimestamp: String?
            public let asMuchAsElements: Int?
            
            public init(
                closestTimestamp: String? = nil,
                closestTickId: Int? = nil,
                asFarAsTimestamp: String? = nil,
                asMuchAsElements: Int? = 60
            ) {
                self.closestTimestamp = closestTimestamp
                self.closestTickId = closestTickId
                self.asFarAsTimestamp = asFarAsTimestamp
                self.asMuchAsElements = asMuchAsElements
            }
        }

        // Root model
        public struct ChartData: Codable {
            public let symbol: Symbol
            public let chartDescription: ChartDescription
            public let timeRange: TimeRange
            
            public init(symbol: Symbol, chartDescription: ChartDescription, timeRange: TimeRange) {
                self.symbol = symbol
                self.chartDescription = chartDescription
                self.timeRange = timeRange
            }
        }
        
        public struct CancelSubscription: Codable {
            public let subscriptionId: Int
        }
    }
}
