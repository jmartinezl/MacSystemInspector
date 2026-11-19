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
            Button("Acerca de MacSystemInspector") {
                openWindow(id: "about")
            }
        }

        // MARK: Edit → después de Cut / Copy / Paste
        CommandGroup(after: .pasteboard) {
            Divider()

            Button("Copiar informe completo") {
                ReportBuilder.copy(ReportBuilder.text(info: info, monitor: monitor))
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])

            Button("Copiar informe como JSON") {
                ReportBuilder.copy(ReportBuilder.json(info: info, monitor: monitor))
            }
            .keyboardShortcut("j", modifiers: [.command, .shift])

            Menu("Copiar dato…") {
                Button("Versión de macOS") { ReportBuilder.copy("\(info.macOSVersion) (\(info.macOSBuild))") }
                Button("Modelo") { ReportBuilder.copy(info.modelIdentifier) }
                Button("Chip") { ReportBuilder.copy(info.chipName) }
                Button("Memoria") { ReportBuilder.copy(Format.bytes(info.memoryBytes, .memory)) }
                Button("GPU") { ReportBuilder.copy(info.gpuName) }
                Divider()
                Button("Número de serie") { ReportBuilder.copy(info.serialNumber) }
            }
        }

        // MARK: Easter eggs
        CommandMenu("Secretos") {

            Button("🦝 Saludar al mapache") {
                appState.easterEgg = EasterEggMessage(
                    title: "🦝 ¡Hola, mapache boreal!",
                    message: "Los mapaches no \"lavan\" su comida: exploran con las patas, que tienen una sensibilidad táctil enorme. Esta app hace lo mismo con tu Mac."
                )
            }

            Button("Datos inútiles") {
                appState.easterEgg = EasterEggMessage(
                    title: "📀 Datos inútiles",
                    message: uselessFacts
                )
            }

            Divider()

            Toggle("Modo Matrix", isOn: $appState.matrixMode)
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

        return """
        Tu RAM equivale a \(ramFloppies) disquetes.
        Tu disco equivale a \(diskFloppies) disquetes.
        Llevas \(seconds) segundos encendido.
        Y tienes \(info.logicalCores) núcleos trabajando por ti.
        """
    }
}
