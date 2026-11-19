import AppKit

/// Genera el informe del sistema y lo copia al portapapeles.
enum ReportBuilder {

    // MARK: - Texto

    /// Informe legible, una línea por dato.
    static func text(info: SystemInfo, monitor: SystemMonitor) -> String {
        var lines = [
            "Mac System Inspector",
            "macOS: \(info.macOSVersion) (\(info.macOSBuild))",
            "Equipo: \(info.hostName)",
            "Modelo: \(info.modelIdentifier)",
            "Chip: \(info.chipName)",
            "Arquitectura: \(info.architecture)",
            "Núcleos: \(info.physicalCores) físicos / \(info.logicalCores) lógicos",
            "Memoria: \(Format.bytes(info.memoryBytes, .memory))",
            "GPU: \(info.gpuName)",
            "Almacenamiento: \(Format.bytes(monitor.storage.total, .file)) (\(Format.bytes(monitor.storage.available, .file)) disponibles)"
        ]
        for display in info.displays {
            lines.append("Pantalla: \(display.name) \(display.resolution) @\(display.scale)x")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - JSON (sin número de serie, a propósito)

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
