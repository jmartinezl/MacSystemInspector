import SwiftUI

/// Punto de entrada: crea el estado compartido y define las ventanas.
@main
struct MacSystemInspectorApp: App {

    private let info = SystemInfo.load()
    @StateObject private var monitor = SystemMonitor()
    @StateObject private var appState = AppState()

    var body: some Scene {

        WindowGroup {
            ContentView(info: info)
                .environmentObject(monitor)
                .environmentObject(appState)
        }
        .defaultSize(width: 960, height: 640)
        .commands {
            AppCommands(info: info, monitor: monitor, appState: appState)
        }

        Window("Acerca de MacSystemInspector", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }
}
