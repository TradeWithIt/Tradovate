import Foundation
import WebSocket
import Dispatch

public typealias JSON = String

extension Tradovate {
    public typealias Id = Int
    // Data Update Model
    public struct DataUpdate<T: Decodable>: Decodable {
        public let modificationType: String
        public let entityType: String
        public let entity: T
    }
    
    public class Socket {
        public enum Error: Swift.Error {
            case invalidInput
        }
        
        let websocket = WebSocket()
        let url: URL
        let queue: DispatchQueue
        var heartbeatTimer: DispatchSourceTimer?
        var requestCounter = 0
        var pendingRequests = [Int: (completion: ((Result<JSON?, Swift.Error>) -> Void)?, endpoint: String)]()
        var requestTokenAction: (() -> String)? = nil
        
        deinit {
            websocket.close()
            heartbeatTimer?.cancel()
            heartbeatTimer = nil
            requestTokenAction = nil
        }
        
        public init(url: URL) throws {
            self.url = url
            self.queue = DispatchQueue(label: "com.heartbeat.socket.\(url.host ?? "unknow")")
            try connect(to: url)
        }
        
        private func connect(to url: URL) throws {
            let request = URLRequest(url: url)
            try websocket.connect(to: request) {[weak self] socket in
                socket.onText {[weak self] ws, text in
                    self?.processMessage(text)
                }
                
                socket.onClose { ws in
                    // Handle closure of the WebSocket connection
                    print("🔒 WebSocket closed")
                }
            }
        }
        
        private func processMessage(_ message: String) {
            guard !message.isEmpty else { return }
            
            let type = message.prefix(1)  // Get the type prefix
            let jsonData = String(message.dropFirst())  // Remove the type prefix to parse the JSON data
            
            switch type {
            case "o":  // Open frame
                print("🟢 isConnected: ", websocket.isConnected == true ? "Yes" : "No")
                // Auth Request
                if let accessToken = requestTokenAction?() {
                    authorise(accessToken)
                }
                startHeartbeatTimer()
                handleOpenFrame()
            case "h":  // Heartbeat frame
                startHeartbeatTimer()
            case "a":  // Array of JSON-encoded messages
                print("🔵 text:", message)
                processFrame(jsonData)
            case "c":  // Close frame
                websocket.close()
                handleCloseFrame()
            default:
                print("⚠️ Unknown frame type received")
            }
        }
        
        func sendHeartbeat() {
            websocket.send("[]")
        }
        
        func startHeartbeatTimer() {
            heartbeatTimer?.cancel() // Cancel any existing timer
            
            heartbeatTimer = DispatchSource.makeTimerSource(queue: queue)
            heartbeatTimer?.schedule(deadline: .now(), repeating: 2.5)
            heartbeatTimer?.setEventHandler { [weak self] in
                guard let self else { return }
                guard websocket.isConnected else {
                    try? self.connect(to: url)
                    return
                }
                
                self.sendHeartbeat()
            }
            heartbeatTimer?.resume()
        }
        
        func processFrame(_ message: String) {
            guard message.first == "[", message.last == "]", let data = message.data(using: .utf8) else {
                print("⚠️ JSON Array format is incorrect")
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    for jsonObject in jsonArray {
                        processJSON(jsonObject)
                    }
                }
            } catch {
                print("❗️Error parsing JSON array: \(error)")
            }
        }
        
        func processJSON(_ jsonObject: [String : Any]) {
            // Extract top-level properties
            let e = jsonObject["e"] as? String
            let i = jsonObject["i"] as? Int
            let s = jsonObject["s"] as? Int
            
            if let s, s != 200 {
                switch s {
                case 401:
                    print("🟡 Authentication is required: status: 401")
                default:
                    print("🟡 message status is not 200", e ?? "", i ?? -1, s)
                }
            }
            
            if let d = jsonObject["d"], let dString = d as? String {
                if let eventType = e {
                    handleEvent(dString, eventType: eventType)
                } else if let requestId = i {
                    handleResponse(dString, requestId: requestId)
                }
            }
        }
        
        func authorise(_ accessToken: String) {
            executeRequest(endpoint: "authorize", body: accessToken)
        }
        
        func handleResponse(_ message: JSON, requestId: Int) {
            guard let pendingRequest = pendingRequests.removeValue(forKey: requestId) else { return }
            pendingRequest.completion?(.success(message))
        }
        
        open func handleEvent(_ message: JSON, eventType: String) {}
        open func handleOpenFrame() {}
        open func handleCloseFrame() {}
        
        public func executeRequest<Body: Encodable>(
            endpoint: String,
            query: [String: Any] = [:],
            body: Body? = nil,
            completion: ( (Result<JSON?, Swift.Error>) -> Void)? = nil
        ) {
            let requestId = requestCounter
            requestCounter += 1
            pendingRequests[requestId] = (completion, endpoint)
            
            var requestFrame = "\(endpoint)\n\(requestId)"
            
            if !query.isEmpty {
                let queryString = query.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                requestFrame += "\n\(queryString)"
            }
            
            if let body = body {
                let encoder = Tradovate.jsonEncoder
                do {
                    let bodyData = try encoder.encode(body)
                    if let bodyString = String(data: bodyData, encoding: .utf8) {
                        requestFrame += "\n\n\(bodyString)"
                    }
                } catch {
                    completion?(.failure(error))
                    return
                }
            }
            websocket.send(requestFrame)
        }
        
        public func onAccessTokenRequest(_ action: @escaping () -> String) -> Self {
            self.requestTokenAction = action
            return self
        }
    }
}
