import Vapor

func routes(_ app: Application) throws {
    app.get { _ async -> String in
        "DJSwiftServer"
    }

    app.get("hello") { _ async -> String in
        "Hello, world!"
    }
}
