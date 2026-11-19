import AppKit

/// Genera el informe del sistema y lo copia al portapapeles; nunca incluye el número de serie.
enum ReportBuilder {

    // MARK: - Texto

    /// Informe legible, una línea por dato.
    static func text(info: SystemInfo, monitor: SystemMonitor) -> String {
        let storageTotal = Format.bytes(monitor.storage.total, .file)
        let storageAvailable = Format.bytes(monitor.storage.available, .file)
        var lines = [
            "Mac System Inspector",
            "macOS: \(info.macOSVersion) (\(info.macOSBuild))",
            String(localized: "Computer Name: \(info.hostName)"),
            String(localized: "Model: \(info.modelIdentifier)"),
            "Chip: \(info.chipName)",
            String(localized: "Architecture: \(info.architecture)"),
            String(localized: "Cores: \(info.physicalCores) physical / \(info.logicalCores) logical"),
            String(localized: "Memory: \(Format.bytes(info.memoryBytes, .memory))"),
            "GPU: \(info.gpuName)",
            String(localized: "Storage: \(storageTotal) (\(storageAvailable) available)")
        ]
        for display in info.displays {
            lines.append(String(localized: "Display: \(display.name) \(display.resolution) @\(display.scale)x"))
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - JSON

    /// Informe en JSON con claves ordenadas.
    static func json(info: SystemInfo, monitor: SystemMonitor) -> String {
        let dict: [String: Any] = [
            "macOS": info.macOSVersion,
            "build": info.macOSBuild,
            "hostName": info.hostName,
            "model": info.modelIdentifier,
            "chip": info.chipName,
            "architecture": info.architecture,
            "physicalCores": info.physicalCores,
            "logicalCores": info.logicalCores,
            "memoryBytes": info.memoryBytes,
            "gpu": info.gpuName,
            "storageTotalBytes": monitor.storage.total,
            "storageAvailableBytes": monitor.storage.available,
            "displays": info.displays.map {
                ["name": $0.name, "resolution": $0.resolution, "scale": $0.scale] as [String: Any]
            }
        ]
        guard
            let data = try? JSONSerialization.data(
                withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: data, encoding: .utf8)
        else { return "{}" }
        return string
    }

    // MARK: - Portapapeles

    /// Reemplaza el contenido del portapapeles con el texto dado.
    static func copy(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }
}
