import Foundation
import SotoS3
import Vapor

protocol AssetStorage: Sendable {
    func put(key: String, data: Data, contentType: String) async throws
}

struct S3AssetStorage: AssetStorage {
    let s3: S3
    let bucket: String

    func put(key: String, data: Data, contentType: String) async throws {
        do {
            _ = try await s3.putObject(.init(
                body: .init(bytes: data),
                bucket: bucket,
                contentType: contentType,
                key: key
            ))
        } catch {
            throw AssetStorageError.uploadFailed(bucket: bucket, key: key, underlying: error)
        }
    }
}

enum AssetStorageError: Error, CustomStringConvertible {
    case incompleteConfiguration
    case uploadFailed(bucket: String, key: String, underlying: any Error)

    var description: String {
        switch self {
        case .incompleteConfiguration:
            return "DJSwift S3 storage requires both AWS_REGION and AWS_S3_ASSET_BUCKET, or neither to disable it locally."
        case let .uploadFailed(bucket, key, underlying):
            return "DJSwift could not upload S3 object s3://\(bucket)/\(key): \(underlying)"
        }
    }
}

private struct AWSClientLifecycle: LifecycleHandler {
    let client: AWSClient

    func shutdownAsync(_ application: Application) async {
        do {
            try await client.shutdown()
        } catch let error as AWSClient.ClientError where error == .alreadyShutdown {
            // Shutdown is idempotent at the application boundary.
        } catch {
            application.logger.error("DJSwift could not shut down its Soto AWS client: \(error)")
        }
    }
}

func configureAssetStorage(_ app: Application) throws -> (any AssetStorage)? {
    let regionName = Environment.get("AWS_REGION")
    let bucket = Environment.get("AWS_S3_ASSET_BUCKET")

    guard regionName != nil || bucket != nil else {
        app.logger.notice("DJSwift S3 asset storage is disabled because AWS_REGION and AWS_S3_ASSET_BUCKET are unset.")
        return nil
    }
    guard let regionName, let bucket, !regionName.isEmpty, !bucket.isEmpty else {
        throw AssetStorageError.incompleteConfiguration
    }

    let client = AWSClient(credentialProvider: .default, logger: app.logger)
    app.lifecycle.use(AWSClientLifecycle(client: client))
    return S3AssetStorage(s3: S3(client: client, region: Region(rawValue: regionName)), bucket: bucket)
}
