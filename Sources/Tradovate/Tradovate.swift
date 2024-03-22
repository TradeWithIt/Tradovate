import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import HTTPTypes
import Foundation

public struct Tradovate {
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
            serverURL: URL(string: "https://\(env.path).tradovateapi.com")!,
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
