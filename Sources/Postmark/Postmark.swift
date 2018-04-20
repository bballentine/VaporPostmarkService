import Vapor
import Foundation

public protocol PostmarkProvider: Service {
    var apiKey: String { get }
    var messageURL: String { get }
    func sendMail(_ content: Postmark.PostmarkData, on req: Request) throws -> Future<Response>
}

public struct Postmark: PostmarkProvider {
    
    public enum PostmarkError: Error {
        case authenticationFailed
        case unprocessableEntity
        case serverError
        case serviceUnavailable
        case unableToSendEmail
    }
    
    public var apiKey: String
    public var messageURL: String
    
    public init(apiKey: String, messageURL: String) {
        self.apiKey = apiKey
        self.messageURL = messageURL
    }
    
    public struct PostmarkData: Content {
        let From: String
        let To: String
        let Subject: String
        let TextBody: String
        let HtmlBody: String?
        
        public init(from: String, to: String, subject: String, text: String, html: String?) {
            self.From = from
            self.To = to
            self.Subject = subject
            self.TextBody = text
            self.HtmlBody = html
        }
    }
    
    public func sendMail(_ content: PostmarkData, on req: Request) throws -> Future<Response> {
        var postmarkHeaders = HTTPHeaders([])
        postmarkHeaders.add(name: "X-Postmark-Server-Token", value: apiKey)
        
        let client = try req.make(Client.self)
        
        return client.post(messageURL, headers: postmarkHeaders, content: content).map(to: Response.self) { (response) in
            switch true {
            case response.http.status.code == 200:
                return response
            case response.http.status.code == 401:
                throw PostmarkError.authenticationFailed
            case response.http.status.code == 422:
                throw PostmarkError.unprocessableEntity
            case response.http.status.code == 500:
                throw PostmarkError.serverError
            case response.http.status.code == 503:
                throw PostmarkError.serviceUnavailable
            default:
                throw PostmarkError.unableToSendEmail
            }
            
            return response
        }
        
    }
    
}
