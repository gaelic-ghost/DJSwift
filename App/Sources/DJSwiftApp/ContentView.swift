import SwiftUI

struct ContentView: View {
    private let station = StationSummary.bootstrap

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                StationHeader(station: station)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Now lining up")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ForEach(station.previewItems) { item in
                        PreviewItemRow(item: item)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppBackdrop())
            .navigationTitle("DJSwift")
        }
    }
}

private struct StationHeader: View {
    let station: StationSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(station.name)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(station.tagline)
                .font(.title3)
                .foregroundStyle(.cyan)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.45), in: UnevenRoundedRectangle(cornerRadii: .init(topLeading: 4, bottomLeading: 4, bottomTrailing: 18, topTrailing: 4)))
        .overlay {
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 4, bottomLeading: 4, bottomTrailing: 18, topTrailing: 4))
                .stroke(.cyan.opacity(0.75), lineWidth: 1)
        }
    }
}

private struct PreviewItemRow: View {
    let item: PreviewItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.symbolName)
                .font(.title3.weight(.semibold))
                .frame(width: 34, height: 34)
                .foregroundStyle(.cyan)
                .background(.white.opacity(0.08), in: Rectangle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.black.opacity(0.36), in: Rectangle())
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(.pink)
                .frame(width: 3)
        }
    }
}

private struct AppBackdrop: View {
    var body: some View {
        LinearGradient(
            colors: [.black, Color(red: 0.05, green: 0.0, blue: 0.12), Color(red: 0.0, green: 0.12, blue: 0.16)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

