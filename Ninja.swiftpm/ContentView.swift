import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        VStack {
            SpriteView(scene: GameScene.scene)
        }
        .padding()
    }
}
