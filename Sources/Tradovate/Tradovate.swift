import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import HTTPTypes
import Foundation

public struct Tradovate {
    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    public static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        decoder.dateDecodingStrategy = .custom({ decoder in
            let transcoder = TimeAndDateTranscoder()
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            if let date = transcoder.iso8601DateFormatter.date(from: value) {
                return date
            }
            if let date = transcoder.iso8601DateMillisecondsFormatter.date(from: value) {
                return date
            }
            if let date = transcoder.iso8601DateOnlyFormatter.date(from: value) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(value)")
        })
        return decoder
    }()
    
    public enum Enviroment {
        case marketData, demo, live
        
        var path: String {
            switch self {
            case .marketData:
                return "md"
            case .demo:
                return "demo"
            case .live:
                return "live"
            }
        }
    }
    
    private static var shared: Tradovate = .init()
    
    private var authMiddleware: AuthenticationMiddleware? = nil
    private var env: Enviroment = .live
    private var middlewares: [any ClientMiddleware] {
        guard let authMiddleware else { return [] }
        return [authMiddleware]
    }

    private var client: Client {
        Client(
            serverURL: URL(string: "https://\(env.path).tradovateapi.com/v1")!,
            configuration: Configuration(
                dateTranscoder: TimeAndDateTranscoder()
            ),
            transport: AsyncHTTPClientTransport(),
            middlewares: middlewares
        )
    }
    
    // MARK: Public Access
    
    public static var enviroment: Enviroment {
        get {
            shared.env
        }
        set {
            shared.env = newValue
        }
    }
    
    public static var client: Client {
        shared.client
    }
    
    public static func setOAuthToken(_ token: String) {
        shared.authMiddleware = AuthenticationMiddleware(token: token)
    }
}

// MARK: Helpers

private struct AuthenticationMiddleware: ClientMiddleware {
    var token: String

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL
        ) async throws -> (HTTPResponse, HTTPBody?)) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.authorization] = "Bearer \(token)"
        return try await next(request, body, baseURL)
    }
}

private struct TimeAndDateTranscoder: DateTranscoder {
    let customDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Foundation.Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "h:mm MM/dd/yy"
        return formatter
    }()
    
    
    let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Foundation.Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    let iso8601DateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Foundation.Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    let iso8601DateMillisecondsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Foundation.Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }()
    
    func encode(_ date: Date) throws -> String {
        return iso8601DateMillisecondsFormatter.string(from: date)
    }
    
    func decode(_ dateString: String) throws -> Date {
        let formatters = [
            iso8601DateMillisecondsFormatter,
            iso8601DateFormatter,
            iso8601DateOnlyFormatter,
            customDateFormatter
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        throw DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Invalid date format: \(dateString)")
        )
    }
}
