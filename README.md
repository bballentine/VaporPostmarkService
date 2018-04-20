# VaporPostmarkService
Vapor 3 service for sending email using the [Postmark API](https://postmarkapp.com). 

## Setup
[Register for a Postmark account](https://postmarkapp.com) and setup a server. Copy the **Server API** token from the **Credentials** section. 

Add the dependency to `Package.swift`

```swift
.package(url: "https://github.com/bballentine/VaporPostmarkService.git", from: "0.1.0")
```

Make sure to add it to your target as well.

In `configure.swift`, `import Postmark` and register the service. 

```swift
let postmark = Postmark(apiKey: "YOUR-API-KEY", postmarkURL: "https://api.postmarkapp.com/email")
services.register(postmark, as: PostmarkProvider.self)
```

Replace `YOUR-API-KEY` with the key you copied from Postmark earlier.

## Example Usage

`import Postmark` and then:

```swift
func sendEmailHandler(_ req: Request) throws -> Future<Response> {
    let postmarkMessage = Postmark.PostmarkData(from: "support@example.com", to: "user@example.com", subject: "Welcome!", text: "Hi. Welcome to my awesome service.", html: "<h1>Welcome to my awesome service</h1>")
    let postmark = try req.make(Postmark.self)
    
    return try postmark.sendMail(postmarkMessage, on: req)
}
```
