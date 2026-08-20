import DJSwiftAPI
import DJSwiftDomain
import Fluent
import Foundation
import Redis
import Vapor

struct DJSwiftAPIHandler: APIProtocol {
    let application: Application
    let redisNamespace: String
    let assetStorage: (any AssetStorage)?

    func getHealth(_: Operations.GetHealth.Input) async throws -> Operations.GetHealth.Output {
        .ok(.init(body: .json(.init(status: "ok", service: "DJSwiftServer"))))
    }

    func listStations(_: Operations.ListStations.Input) async throws -> Operations.ListStations.Output {
        let stations = try await StationRecord.query(on: application.db)
            .sort(\.$name)
            .all()
            .map { try $0.station() }
        return .ok(.init(body: .json(.init(stations: stations))))
    }

    func getStation(_ input: Operations.GetStation.Input) async throws -> Operations.GetStation.Output {
        guard let station = try await station(slug: input.path.stationSlug) else {
            return .notFound(notFound(code: "station_not_found", message: "Station '\(input.path.stationSlug)' does not exist."))
        }

        return try .ok(.init(body: .json(station.station())))
    }

    func getStationManifest(
        _ input: Operations.GetStationManifest.Input,
    ) async throws -> Operations.GetStationManifest.Output {
        guard let station = try await station(slug: input.path.stationSlug) else {
            return .notFound(notFound(code: "station_not_found", message: "Station '\(input.path.stationSlug)' does not exist."))
        }

        let cacheKey = RedisKey("\(redisNamespace):station:\(input.path.stationSlug):manifest")
        if let cached = try await application.redis.get(cacheKey, asJSON: StationManifest.self) {
            return .ok(.init(body: .json(cached)))
        }

        let generatedAt = Date()
        let manifest = try StationManifest(
            id: UUID().uuidString,
            stationId: station.requireID().uuidString,
            revision: 1,
            generatedAt: generatedAt,
            validFrom: generatedAt,
            validThrough: generatedAt.addingTimeInterval(60 * 60),
            items: [],
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
