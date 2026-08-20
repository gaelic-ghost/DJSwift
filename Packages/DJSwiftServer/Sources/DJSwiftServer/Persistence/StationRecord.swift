import DJSwiftAPI
import DJSwiftDomain
import Fluent
import Foundation

final class StationRecord: Model, @unchecked Sendable {
    static let schema = "stations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "slug")
    var slug: String

    @Field(key: "name")
    var name: String

    @Field(key: "tagline")
    var tagline: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, slug: String, name: String, tagline: String) {
        self.id = id
        self.slug = slug
        self.name = name
        self.tagline = tagline
    }

    var domain: DJSwiftDomain.Station {
        Station(id: slug, name: name, tagline: tagline)
    }

    var transport: Components.Schemas.Station {
        .init(id: slug, name: name, tagline: tagline)
    }
}
