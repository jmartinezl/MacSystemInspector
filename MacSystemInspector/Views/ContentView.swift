import SwiftUI
import AppKit

/// Ventana principal con el resumen en vivo y las tarjetas de información.
struct ContentView: View {

    let info: SystemInfo
    @EnvironmentObject private var monitor: SystemMonitor
    @EnvironmentObject private var appState: AppState

    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 520), spacing: 16, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                liveSummary

                LazyVGrid(columns: columns, spacing: 16) {
                    systemCard
                    hardwareCard
                    memoryStorageCard
                    if let battery = monitor.battery { batteryCard(battery) }
                    if !info.displays.isEmpty { displaysCard }
                }
            }
            .padding(20)
        }
        .frame(minWidth: 380, minHeight: 300)
        .onAppear { monitor.start() }
        .onDisappear { monitor.stop() }
        .toolbar {
            ToolbarItem {
                Button("Copy Report", systemImage: "doc.on.doc") {
                    ReportBuilder.copy(ReportBuilder.text(info: info, monitor: monitor))
                }
            }
        }
        .overlay {
            if appState.matrixMode {
                MatrixRain().transition(.opacity)
            }
        }
        .animation(.easeInOut, value: appState.matrixMode)
        .alert(
            appState.easterEgg?.title ?? "",
            isPresented: Binding(
                get: { appState.easterEgg != nil },
                set: { if !$0 { appState.easterEgg = nil } }
            ),
            presenting: appState.easterEgg
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { egg in
            Text(egg.message)
        }
    }

    // MARK: - Resumen en vivo (ancho completo)

    private var liveSummary: some View {
        Card(title: "Live Performance", systemImage: "gauge.with.dots.needle.67percent") {
            HStack(alignment: .top, spacing: 12) {
                RingGauge(title: "CPU",
                          fraction: monitor.cpuUsage,
                          detail: String(localized: "\(info.logicalCores) cores"))
                RingGauge(title: "Memory",
                          fraction: monitor.memory.fraction,
                          detail: "\(Format.bytes(monitor.memory.used, .memory)) / \(Format.bytes(monitor.memory.total, .memory))")
                RingGauge(title: "Disk",
                          fraction: monitor.storage.usedFraction,
                          detail: "\(Format.bytes(monitor.storage.used, .file)) / \(Format.bytes(monitor.storage.total, .file))")
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Tarjetas

    private var systemCard: some View {
        Card(title: "System", systemImage: "macwindow") {
            InfoRow(verbatim: "macOS", "\(info.macOSVersion) (\(info.macOSBuild))")
            InfoRow("Computer Name", info.hostName)
            InfoRow("Uptime", Format.uptime(monitor.uptime))
            InfoRow("Thermal State", monitor.thermalState.localizedName)
        }
    }

    private var hardwareCard: some View {
        Card(title: "Hardware", systemImage: "cpu") {
            InfoRow("Model", info.modelIdentifier)
            InfoRow(verbatim: "Chip / CPU", info.chipName)
            InfoRow("Architecture", info.architecture)
            InfoRow("Cores", String(localized: "\(info.physicalCores) physical · \(info.logicalCores) logical"))
            InfoRow(verbatim: "GPU", info.gpuName)
            SecretInfoRow("Serial Number", info.serialNumber)
        }
    }

    private var memoryStorageCard: some View {
        Card(title: "Memory & Storage", systemImage: "memorychip") {
            InfoRow("Total Memory", Format.bytes(info.memoryBytes, .memory))
            InfoRow("Memory Used", Format.bytes(monitor.memory.used, .memory))
            Divider()
            InfoRow("Total Disk", Format.bytes(monitor.storage.total, .file))
            InfoRow("Disk Used", Format.bytes(monitor.storage.used, .file))
            InfoRow("Available", Format.bytes(monitor.storage.available, .file))
        }
    }

    private func batteryCard(_ battery: BatteryInfo) -> some View {
        Card(title: "Battery", systemImage: "battery.100") {
            GaugeRow(title: "Charge",
                     fraction: battery.fraction,
                     detail: Format.percent(battery.fraction))
            InfoRow("Status", battery.statusText)
        }
    }

    private var displaysCard: some View {
        Card(title: "Displays", systemImage: "display") {
            ForEach(info.displays) { display in
                InfoRow(verbatim: display.name, "\(display.resolution) @\(display.scale)x")
            }
        }
    }
}

#Preview {
    ContentView(info: SystemInfo.load())
        .environmentObject(SystemMonitor())
        .environmentObject(AppState())
}
