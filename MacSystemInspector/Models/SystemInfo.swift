import Foundation
import AppKit
import IOKit
import Metal

/// Nombre y resolución nativa de una pantalla.
struct DisplayInfo: Identifiable {
    let id = UUID()
    let name: String
    let resolution: String
    let scale: Int
}

/// Capacidad total y disponible del volumen de arranque.
struct StorageInfo {
    let total: Int64
    let available: Int64
    var used: Int64 { total - available }
    var usedFraction: Double { total > 0 ? Double(used) / Double(total) : 0 }
}

/// Datos del sistema que no cambian mientras la app está abierta.
struct SystemInfo {

    // MARK: - Sistema
    let macOSVersion: String
    let macOSBuild: String
    let hostName: String

    // MARK: - Hardware
    let modelIdentifier: String
    let chipName: String
    let architecture: String
    let physicalCores: Int
    let logicalCores: Int
    let memoryBytes: UInt64
    let gpuName: String
    /// Sensible: solo se muestra oculto en la interfaz, nunca en informes ni menús.
    let serialNumber: String
    let displays: [DisplayInfo]

    // MARK: - Carga

    /// Lee todos los datos estáticos del sistema.
    static func load() -> SystemInfo {
        let processInfo = ProcessInfo.processInfo
        let v = processInfo.operatingSystemVersion

        return SystemInfo(
            macOSVersion: "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)",
            macOSBuild: Sysctl.string("kern.osversion") ?? "—",
            hostName: processInfo.hostName,
            modelIdentifier: Sysctl.string("hw.model") ?? "—",
            chipName: Sysctl.string("machdep.cpu.brand_string") ?? "—",
            architecture: architectureName,
            physicalCores: Sysctl.int("hw.physicalcpu") ?? 0,
            logicalCores: Sysctl.int("hw.logicalcpu") ?? processInfo.processorCount,
            memoryBytes: processInfo.physicalMemory,
            gpuName: MTLCreateSystemDefaultDevice()?.name ?? "—",
            serialNumber: readSerialNumber(),
            displays: readDisplays()
        )
    }

    // MARK: - Almacenamiento

    /// Lee el espacio del disco; va aparte porque cambia y lo refresca `SystemMonitor`.
    static func readStorage() -> StorageInfo {
        let url = URL(fileURLWithPath: "/")
        let keys: Set<URLResourceKey> = [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey
        ]
        let values = try? url.resourceValues(forKeys: keys)

        return StorageInfo(
            total: Int64(values?.volumeTotalCapacity ?? 0),
            available: values?.volumeAvailableCapacityForImportantUsage ?? 0
        )
    }

    // MARK: - Helpers privados

    private static var architectureName: String {
        #if arch(arm64)
        return "Apple Silicon (arm64)"
        #else
        return "Intel (x86_64)"
        #endif
    }

    /// Número de serie desde el registro de IOKit.
    private static func readSerialNumber() -> String {
        let service = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )
        guard service != 0 else { return "—" }
        defer { IOObjectRelease(service) }

        let property = IORegistryEntryCreateCFProperty(
            service,
            kIOPlatformSerialNumberKey as CFString,
            kCFAllocatorDefault,
            0
        )
        return property?.takeRetainedValue() as? String ?? "—"
    }

    /// Pantallas conectadas con su resolución en píxeles reales.
    private static func readDisplays() -> [DisplayInfo] {
        NSScreen.screens.map { screen in
            let scale = screen.backingScaleFactor
            let w = Int(screen.frame.width * scale)
            let h = Int(screen.frame.height * scale)
            return DisplayInfo(
                name: screen.localizedName,
                resolution: "\(w) × \(h)",
                scale: Int(scale)
            )
        }
    }
}
