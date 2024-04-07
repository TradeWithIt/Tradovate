import Foundation

public extension Tradovate.Synchronization {
    func userSynchronization(_ ids: [Int]) {
        executeRequest(endpoint: "user/syncrequest", body: Request.Sync(users: ids))
    }
    
    func startOrderStrategy(_ request: Request.OrderStrategyRequest) async throws -> Response.OrderStrategyResponse {
        try await withCheckedThrowingContinuation { continuation in
            executeRequest(endpoint: "user/syncrequest", body: request) { result in
                do {
                    switch result {
                    case .success(let json):
                        guard let data = json?.data(using: .utf8) else {
                            continuation.resume(throwing: Tradovate.Socket.Error.invalidInput)
                            return
                        }
                        let response = try Tradovate.jsonDecoder.decode(Response.OrderStrategyResponse.self, from: data)
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
    
    struct Request {
        public struct Sync: Codable {
            public var users: [Int]
            public init(users: [Int]) {
                self.users = users
            }
        }
        
        public struct OrderStrategyRequest: Encodable {
            let accountId: Int
            let accountSpec: String
            let symbol: String
            let action: String
            let orderStrategyTypeId: Int
            let params: Params
            
            public init(
                accountId: Int,
                accountSpec: String,
                symbol: String,
                action: String,
                orderStrategyTypeId: Int = 2,
                params: Params
            ) {
                self.accountId = accountId
                self.accountSpec = accountSpec
                self.symbol = symbol
                self.action = action
                self.orderStrategyTypeId = orderStrategyTypeId
                self.params = params
            }
        }

        public struct Params: Encodable {
            let entryVersion: EntryVersion
            let brackets: [Bracket]
            public init(entryVersion: EntryVersion, brackets: [Bracket]) {
                self.entryVersion = entryVersion
                self.brackets = brackets
            }
        }

        public struct EntryVersion: Encodable {
            let orderQty: Int
            let orderType: String
            public init(orderQty: Int, orderType: String) {
                self.orderQty = orderQty
                self.orderType = orderType
            }
        }

        public struct Bracket: Encodable {
            let qty: Int
            let profitTarget: Int?
            let stopLoss: Int
            let trailingStop: Bool
            
            public init(qty: Int, profitTarget: Int? = nil, stopLoss: Int, trailingStop: Bool) {
                self.qty = qty
                self.profitTarget = profitTarget
                self.stopLoss = stopLoss
                self.trailingStop = trailingStop
            }
        }
    }
}
