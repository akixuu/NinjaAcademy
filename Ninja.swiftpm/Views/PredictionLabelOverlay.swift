import SwiftUI

struct PredictionLabelOverlay: View {
    @ScaledMetric private var size: CGFloat = 80

    var detectedMove: NinjaMoves

    var body: some View {
        if detectedMove == .unknown {
            EmptyView()
        } else {
            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                .fill(Color.translucentBlack)
                .frame(width: size, height: size)
                .padding()
                .overlay {
                    VStack {
                        Text(detectedMove.rawValue)
                    }
                    .foregroundColor(.white)
                }
        }
    }
}

extension Color {
    static var translucentBlack: Color { black.opacity(0.5) }
}
