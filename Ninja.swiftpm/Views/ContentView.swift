import SwiftUI
import SpriteKit

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ZStack {
            SpriteView(scene: GameScene.scene)
            .overlay(alignment: .topLeading) {
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
