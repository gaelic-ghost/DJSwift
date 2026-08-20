import DJSwiftAPI
import DJSwiftDomain
import Foundation
import OpenAPIURLSession

public struct DJSwiftServiceClient: Sendable {
    public let transport: DJSwiftAPI.Client

    public init(serverURL: URL = URL(string: "http://127.0.0.1:8080")!) {
        transport = DJSwiftAPI.Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
    }
}

public extension Components.Schemas.Station {
    var domain: DJSwiftDomain.Station {
        Station(id: id, name: name, tagline: tagline)
    }

    init(domain: DJSwiftDomain.Station) {
        self.init(id: domain.id, name: domain.name, tagline: domain.tagline)
    }
}
