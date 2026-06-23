import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "DJSwift"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("health") { req async -> HealthResponse in
        HealthResponse(status: "ok", service: "DJSwiftServer")
    }

    let api = app.grouped("api", "v1")
    api.get("stations") { req async -> StationListResponse in
        StationListResponse(
            stations: [
                StationSummary(
                    id: "gaelic-ghost-one",
                    name: "Gaelic Ghost One",
                    tagline: "A bootstrap station placeholder for the first curated manifest."
                )
            ]
        )
    }

    try app.register(collection: TodoController())
}

struct HealthResponse: Content {
    let status: String
    let service: String
}

struct StationListResponse: Content {
    let stations: [StationSummary]
}

struct StationSummary: Content {
    let id: String
    let name: String
    let tagline: String
}
