import SwiftUI

@main
struct NFeDownloadForMacApp: App {
    @State private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 1080, minHeight: 760)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1240, height: 840)

        Settings {
            SettingsView(viewModel: viewModel)
                .frame(width: 720, height: 560)
        }
    }
}
