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

Tradovate.enviroment = .live
Tradovate.setOAuthToken("ABC124-MyToken")
```

Example use:
```
import Tradovate

do {
    Tradovate.enviroment = .live
    Tradovate.setApiKeys(
        username: "AKGKC0HFHIVRJGHLWMXY",
        password: "h8VVk45l4BYjeouSJgJkyZcJ3OyyqKwMNp0xBwlm"
    )
    let response = try await Tradovate.client.accessTokenRequest(body: .json(.init(
        name:       "Your credentials here",
        password:   "Your credentials here",
        appId:      "Sample App",
        appVersion: "1.0",
        cid:        "0",
        sec:        "Your API secret here"
    )))
    
    switch response {
    case .ok(let okResponse):
        switch okResponse.body {
        case .json(let result):
            await MainActor.run {
                print("✅ accessToken: ", result.accessToken ?? "")
            }
        }
    case .undocumented(statusCode: let statusCode, let x):
        print("🥺 undocumented response: \(statusCode)", x, response)
    }
    
} catch {
    print("🔴", error)
}```
