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
    func domain() throws -> DJSwiftDomain.Station {
        guard let stationID = UUID(uuidString: id) else {
            throw DJSwiftClientMappingError.invalidStationID(id)
        }
        return Station(id: stationID, slug: slug, name: name, tagline: tagline)
    }

    init(domain: DJSwiftDomain.Station) {
        self.init(id: domain.id.uuidString, slug: domain.slug, name: domain.name, tagline: domain.tagline)
    }
}

public enum DJSwiftClientMappingError: Error, CustomStringConvertible, Equatable {
    case invalidStationID(String)

    public var description: String {
        switch self {
        case let .invalidStationID(value):
            "DJSwift received station id '\(value)', but the API contract requires a UUID string."
        }
    }
}
