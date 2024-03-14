# Tradovate API

Generated from [OpenAPI](https://api.tradovate.com) using [Swift OpenAPI Generator](https://www.swift.org/blog/introducing-swift-openapi-generator/) 


[Open API Explores](https://tradewithit.github.io/Tradovate/index.html)

This repository was generated using swift package command 
```
swift package plugin generate-code-from-openapi --target Tradovate

```

This generated files into the GreetingServiceClient target’s Sources directory, in a directory called GeneratedSources, which has been check into this repository.

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding a dependency is as easy as adding it to the dependencies value of your Package.swift.

Add the package dependency in your Package.swift:
```
dependencies: [
    .package(url: "https://github.com/TradeWithIt/Tradovate", from: "1.0.0")
]
```
Next, in your target, add OpenAPIURLSession to your dependencies:
```
.target(name: "MyTarget", dependencies: [
    .product(name: "Tradovate", package: "Tradovate"),
]),
```


## Usage 
Set auth:
```
import Tradovate


Tradovate.setSandboxApiKeys(
    apiKey: "",
    apiSecret: ""
)
```

Example use:
```
import AlpacaMarket


do {
    let response = try await Tradovate.sandbox.getBarsForStockSymbol(
        .init(
            path: .init(symbol: "AAPL"),
            query: .init(timeframe: "1min")
        )
    )
    
    switch response {
    case .ok(let okResponse):
        // Switch over the response content type.
        switch okResponse.body {
        case .json(let bars):
            // Print the greeting message.
            print("👋 \(bars.symbol)")
            print("👋 \(bars.next_page_token)")
            let candles = bars.bars.map({ Candle(from: $0) })
            await MainActor.run {
                self.candles = candles
            }
        }
    case .undocumented(statusCode: let statusCode, _):
        // Handle HTTP response status codes not documented in the OpenAPI document.
        print("🥺 undocumented response: \(statusCode)")
    }
    
} catch {
    print(error)
}
```
