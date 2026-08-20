import DJSwiftAPI
import Fluent
import Redis
import Vapor

struct DJSwiftAPIHandler: APIProtocol {
    let application: Application
    let redisNamespace: String
    let assetStorage: (any AssetStorage)?

    func getHealth(_ input: Operations.GetHealth.Input) async throws -> Operations.GetHealth.Output {
        .ok(.init(body: .json(.init(status: "ok", service: "DJSwiftServer"))))
    }

    func listStations(_ input: Operations.ListStations.Input) async throws -> Operations.ListStations.Output {
        let stations = try await StationRecord.query(on: application.db)
            .sort(\.$name)
            .all()
            .map(\.transport)
        return .ok(.init(body: .json(.init(stations: stations))))
    }

    func getStation(_ input: Operations.GetStation.Input) async throws -> Operations.GetStation.Output {
        guard let station = try await station(slug: input.path.stationId) else {
            return .notFound(notFound(code: "station_not_found", message: "Station '\(input.path.stationId)' does not exist."))
        }
        return .ok(.init(body: .json(station.transport)))
    }

    func getStationManifest(
        _ input: Operations.GetStationManifest.Input
    ) async throws -> Operations.GetStationManifest.Output {
        guard try await station(slug: input.path.stationId) != nil else {
            return .notFound(notFound(code: "station_not_found", message: "Station '\(input.path.stationId)' does not exist."))
        }

        let cacheKey = RedisKey("\(redisNamespace):station:\(input.path.stationId):manifest")
        if let cached = try await application.redis.get(cacheKey, asJSON: Components.Schemas.StationManifest.self) {
            return .ok(.init(body: .json(cached)))
        }

        let manifest = Components.Schemas.StationManifest(
            stationId: input.path.stationId,
            revision: 1,
            items: []
        )
        try await application.redis.setex(cacheKey, toJSON: manifest, expirationInSeconds: 60)
        return .ok(.init(body: .json(manifest)))
    }

    private func station(slug: String) async throws -> StationRecord? {
        try await StationRecord.query(on: application.db)
            .filter(\.$slug == slug)
            .first()
    }

    private func notFound(code: String, message: String) -> Components.Responses.NotFound {
        .init(body: .json(.init(code: code, message: message)))
    }
}
