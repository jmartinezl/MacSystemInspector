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
                Button("Copiar informe", systemImage: "doc.on.doc") {
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
        Card(title: "Rendimiento en vivo", systemImage: "gauge.with.dots.needle.67percent") {
            HStack(alignment: .top, spacing: 12) {
                RingGauge(title: "CPU",
                          fraction: monitor.cpuUsage,
                          detail: "\(info.logicalCores) núcleos")
                RingGauge(title: "Memoria",
                          fraction: monitor.memory.fraction,
                          detail: "\(Format.bytes(monitor.memory.used, .memory)) / \(Format.bytes(monitor.memory.total, .memory))")
                RingGauge(title: "Disco",
                          fraction: monitor.storage.usedFraction,
                          detail: "\(Format.bytes(monitor.storage.used, .file)) / \(Format.bytes(monitor.storage.total, .file))")
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Tarjetas

    private var systemCard: some View {
        Card(title: "Sistema", systemImage: "macwindow") {
            InfoRow("macOS", "\(info.macOSVersion) (\(info.macOSBuild))")
            InfoRow("Equipo", info.hostName)
            InfoRow("Encendido", Format.uptime(monitor.uptime))
            InfoRow("Estado térmico", monitor.thermalState.localizedName)
        }
    }

    private var hardwareCard: some View {
        Card(title: "Hardware", systemImage: "cpu") {
            InfoRow("Modelo", info.modelIdentifier)
            InfoRow("Chip / CPU", info.chipName)
            InfoRow("Arquitectura", info.architecture)
            InfoRow("Núcleos", "\(info.physicalCores) físicos · \(info.logicalCores) lógicos")
            InfoRow("GPU", info.gpuName)
            InfoRow("Serie", info.serialNumber)
        }
    }

    private var memoryStorageCard: some View {
        Card(title: "Memoria y almacenamiento", systemImage: "memorychip") {
            InfoRow("Memoria total", Format.bytes(info.memoryBytes, .memory))
            InfoRow("Memoria en uso", Format.bytes(monitor.memory.used, .memory))
            Divider()
            InfoRow("Disco total", Format.bytes(monitor.storage.total, .file))
            InfoRow("Disco usado", Format.bytes(monitor.storage.used, .file))
            InfoRow("Disponible", Format.bytes(monitor.storage.available, .file))
        }
    }

    private func batteryCard(_ battery: BatteryInfo) -> some View {
        Card(title: "Batería", systemImage: "battery.100") {
            GaugeRow(title: "Carga",
                     fraction: battery.fraction,
                     detail: Format.percent(battery.fraction))
            InfoRow("Estado", battery.statusText)
        }
    }

    private var displaysCard: some View {
        Card(title: "Pantallas", systemImage: "display") {
            ForEach(info.displays) { display in
                InfoRow(display.name, "\(display.resolution) @\(display.scale)x")
            }
        }
    }
}

#Preview {
    ContentView(info: SystemInfo.load())
        .environmentObject(SystemMonitor())
        .environmentObject(AppState())
}
