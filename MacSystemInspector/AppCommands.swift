import SwiftUI

/// Menús de la barra: Acerca de, opciones de copiado y easter eggs.
struct AppCommands: Commands {

    let info: SystemInfo
    let monitor: SystemMonitor
    @ObservedObject var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {

        // MARK: Acerca de (reemplaza el estándar)
        CommandGroup(replacing: .appInfo) {
            Button("About MacSystemInspector") {
                openWindow(id: "about")
            }
        }

        // MARK: Edit → después de Cut / Copy / Paste
        CommandGroup(after: .pasteboard) {
            Divider()

            Button("Copy Full Report") {
                ReportBuilder.copy(ReportBuilder.text(info: info, monitor: monitor))
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])

            Button("Copy Report as JSON") {
                ReportBuilder.copy(ReportBuilder.json(info: info, monitor: monitor))
            }
            .keyboardShortcut("j", modifiers: [.command, .shift])

            Menu("Copy Item") {
                Button("macOS Version") { ReportBuilder.copy("\(info.macOSVersion) (\(info.macOSBuild))") }
                Button("Model") { ReportBuilder.copy(info.modelIdentifier) }
                Button(String("Chip")) { ReportBuilder.copy(info.chipName) }
                Button("Memory") { ReportBuilder.copy(Format.bytes(info.memoryBytes, .memory)) }
                Button(String("GPU")) { ReportBuilder.copy(info.gpuName) }
            }
        }

        // MARK: Easter eggs
        CommandMenu("Secrets") {

            Button("🦝 Say Hi to the Raccoon") {
                appState.easterEgg = EasterEggMessage(
                    title: String(localized: "🦝 Hi, boreal raccoon!"),
                    message: String(localized: "Raccoons don’t really “wash” their food: they explore with their paws, which are extremely sensitive to touch. This app does the same with your Mac.")
                )
            }

            Button("Useless Facts") {
                appState.easterEgg = EasterEggMessage(
                    title: String(localized: "📀 Useless Facts"),
                    message: uselessFacts
                )
            }

            Divider()

            Toggle("Matrix Mode", isOn: $appState.matrixMode)
                .keyboardShortcut("m", modifiers: [.command, .option])
        }
    }

    // MARK: - Contenido de los secretos

    /// Equivalencias curiosas de la RAM, el disco y el tiempo encendido.
    private var uselessFacts: String {
        let floppy = 1_474_560.0  // disquete de 1.44 MB
        let ramFloppies = (Double(info.memoryBytes) / floppy).formatted(.number.precision(.fractionLength(0)))
        let diskFloppies = (Double(monitor.storage.total) / floppy).formatted(.number.precision(.fractionLength(0)))
        let seconds = Int(monitor.uptime).formatted()

        return String(localized: """
        Your RAM equals \(ramFloppies) floppy disks.
        Your disk equals \(diskFloppies) floppy disks.
        Your Mac has been on for \(seconds) seconds.
        And you have \(info.logicalCores) cores working for you.
        """)
    }
}
