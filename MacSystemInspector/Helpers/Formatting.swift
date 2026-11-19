import Foundation

/// Formateadores compartidos entre la interfaz, los menús y el informe.
enum Format {

    private static let uptimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    /// Convierte bytes a texto legible (p. ej. "16 GB").
    static func bytes(_ value: some BinaryInteger, _ style: ByteCountFormatter.CountStyle) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: style)
    }

    /// Convierte una fracción 0…1 a porcentaje sin decimales.
    static func percent(_ fraction: Double) -> String {
        fraction.formatted(.percent.precision(.fractionLength(0)))
    }

    /// Convierte segundos a días, horas y minutos abreviados.
    static func uptime(_ seconds: TimeInterval) -> String {
        uptimeFormatter.string(from: seconds) ?? "—"
    }
}

extension ProcessInfo.ThermalState {

    /// Nombre del estado térmico traducido al idioma del sistema.
    var localizedName: String {
        switch self {
        case .nominal: String(localized: "Normal")
        case .fair: String(localized: "Fair")
        case .serious: String(localized: "Serious")
        case .critical: String(localized: "Critical")
        @unknown default: String(localized: "Unknown")
        }
    }
}

extension Double {

    /// Limita el valor al rango 0…1.
    var clampedToUnit: Double { min(max(self, 0), 1) }
}
