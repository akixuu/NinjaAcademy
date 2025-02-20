import SwiftUI

@main
struct MyApp: App {
    @StateObject var appModel = AppModel.appModel

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
