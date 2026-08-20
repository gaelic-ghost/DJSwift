import DJSwiftDomain
import SwiftUI

public struct DJSwiftContentView: View {
    private let station = Station.bootstrap

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(station.name)
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(station.tagline)
                        .font(.title3)
                        .foregroundStyle(.cyan)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 18))
                .overlay { RoundedRectangle(cornerRadius: 18).stroke(.cyan.opacity(0.75)) }

                Text("Now lining up")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [.black, Color(red: 0.05, green: 0, blue: 0.12), Color(red: 0, green: 0.12, blue: 0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
            )
            .navigationTitle("DJSwift")
        }
    }
}
