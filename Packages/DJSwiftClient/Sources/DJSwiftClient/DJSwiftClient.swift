import DJSwiftAPI
import Foundation
import OpenAPIURLSession

public struct DJSwiftServiceClient: Sendable {
    public let transport: DJSwiftAPI.Client

    public init(serverURL: URL = URL(string: "http://127.0.0.1:8080")!) {
        transport = DJSwiftAPI.Client(
            serverURL: serverURL,
            transport: URLSessionTransport(),
        )
    }
}
