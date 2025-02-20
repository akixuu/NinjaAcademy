import SwiftUI
import SpriteKit

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            SpriteView(scene: IntroductionScene(size:UIScreen.main.bounds.size))
                .ignoresSafeArea()
        }
        .overlay(alignment: .topLeading) {
            if appModel.gameStarted {
                camera()
                    .frame(width: 400, height: 300)
                    .padding()
            }
        }
    }
    
    private func camera() -> some View {
        CameraView()
            .environmentObject(appModel)
            .overlay(alignment: .topLeading) {
                VStack {
                    PredictionLabelOverlay(detectedMove: appModel.prediction)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
    }

}
