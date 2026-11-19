import Foundation
import Combine
import IOKit.ps

/// Memoria física en uso respecto al total.
struct MemoryUsage {
    var used: UInt64 = 0
    var total: UInt64 = 0
    var fraction: Double { total > 0 ? Double(used) / Double(total) : 0 }
}

/// Nivel de carga y estado de la batería.
struct BatteryInfo {
    let fraction: Double
    let isCharging: Bool
    let isPluggedIn: Bool

    /// Estado de carga traducido al idioma del sistema.
    var statusText: String {
        if isCharging { return String(localized: "Charging") }
        return isPluggedIn ? String(localized: "Plugged In") : String(localized: "On Battery")
    }
}

/// Métricas que cambian con el tiempo, refrescadas cada segundo.
final class SystemMonitor: ObservableObject {

    @Published var cpuUsage: Double = 0
    @Published var memory = MemoryUsage()
    @Published var uptime: TimeInterval = 0
    @Published var battery: BatteryInfo?
    @Published var storage = SystemInfo.readStorage()
    @Published var thermalState: ProcessInfo.ThermalState = .nominal

    private var timer: Timer?
    private var activeViews = 0
    private var previousTicks: (used: UInt64, total: UInt64)?

    // MARK: - Control

    /// Registra una vista que necesita datos e inicia el timer si es la primera.
    func start() {
        activeViews += 1
        guard timer == nil else { return }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    /// Da de baja una vista y detiene el timer cuando ya no queda ninguna.
    func stop() {
        activeViews = max(activeViews - 1, 0)
        guard activeViews == 0 else { return }
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        cpuUsage = readCPUUsage()
        memory = readMemory()
        uptime = ProcessInfo.processInfo.systemUptime
        battery = readBattery()
        storage = SystemInfo.readStorage()
        thermalState = ProcessInfo.processInfo.thermalState
    }

    // MARK: - CPU

    /// Fracción de CPU usada desde la lectura anterior (0 en la primera).
    private func readCPUUsage() -> Double {
        var info = host_cpu_load_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }

        let user = UInt64(info.cpu_ticks.0)
        let system = UInt64(info.cpu_ticks.1)
        let idle = UInt64(info.cpu_ticks.2)
        let nice = UInt64(info.cpu_ticks.3)

        let used = user + system + nice
        let total = used + idle

        defer { previousTicks = (used, total) }
        guard let previous = previousTicks, total > previous.total else { return 0 }

        return Double(used - previous.used) / Double(total - previous.total)
    }

    // MARK: - Memoria

    /// Memoria activa + wired + comprimida, como la cuenta el Monitor de Actividad.
    private func readMemory() -> MemoryUsage {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return MemoryUsage() }

        let pageSize = UInt64(Sysctl.int("hw.pagesize") ?? 16384)
        let usedPages = UInt64(stats.active_count)
                      + UInt64(stats.wire_count)
                      + UInt64(stats.compressor_page_count)

        return MemoryUsage(
            used: usedPages * pageSize,
            total: ProcessInfo.processInfo.physicalMemory
        )
    }

    // MARK: - Batería

    /// Primera batería encontrada, o `nil` en Macs de escritorio.
    private func readBattery() -> BatteryInfo? {
        guard
            let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef]
        else { return nil }

        for source in sources {
            guard
                let description = IOPSGetPowerSourceDescription(snapshot, source)?
                    .takeUnretainedValue() as? [String: Any],
                let current = description[kIOPSCurrentCapacityKey] as? Int,
                let maximum = description[kIOPSMaxCapacityKey] as? Int,
                maximum > 0
            else { continue }

            return BatteryInfo(
                fraction: Double(current) / Double(maximum),
                isCharging: description[kIOPSIsChargingKey] as? Bool ?? false,
                isPluggedIn: (description[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue
            )
        }
        return nil
    }
}
