import SwiftUI

@available(iOS 13.0, *)
struct TDDemoPlayerView: View {
    var body: some View {
        Text("Demo Player")
            .font(.headline)
            .padding(8)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(8)
    }
}

@available(iOS 13.0, *)
struct TDDemoVastRendererView: View {
    @State private var showPlayer = true

    var body: some View {
        VStack(spacing: 16) {
            Text("TDDemoVastRendererView")
                .font(.title)
                .fontWeight(.semibold)

            Text("SwiftUI nested view for #screen_name verify")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if showPlayer {
                TDDemoPlayerView()
            } else {
                Text("Fallback branch")
            }

            Button(action: {
                showPlayer.toggle()
            }) {
                Text("Toggle Player")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)

            Button(action: {}) {
                Text("Auto Track Click Test")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
        }
        .padding()
    }
}
