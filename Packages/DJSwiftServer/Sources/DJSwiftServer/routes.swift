import Vapor

func routes(_ app: Application) throws {
    app.get { _ async -> String in
        "DJSwift web app coming soon"
    }
}
