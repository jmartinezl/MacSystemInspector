import SwiftUI
import AppKit

/// Tarjeta con título e ícono que ocupa todo el ancho de su columna.
struct Card<Content: View>: View {
    let title: LocalizedStringKey
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.secondary)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
    }
}

/// Anillo de progreso con porcentaje al centro y detalle debajo.
struct RingGauge: View {
    let title: LocalizedStringKey
    let fraction: Double
    let detail: String

    private var clamped: Double { fraction.clampedToUnit }

    private var tint: Color {
        switch clamped {
        case ..<0.6: .green
        case ..<0.85: .orange
        default: .red
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: clamped)
                    .stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.4), value: clamped)

                VStack(spacing: 0) {
                    Text(Format.percent(clamped))
                        .font(.title3.bold())
                        .monospacedDigit()
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 70, maxWidth: 110)
            .aspectRatio(1, contentMode: .fit)

            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Fila de "etiqueta: valor" con el valor seleccionable.
struct InfoRow: View {
    let title: Text
    let value: String

    init(_ title: LocalizedStringKey, _ value: String) {
        self.title = Text(title)
        self.value = value
    }

    /// Variante para títulos que vienen del sistema y no se traducen.
    init(verbatim title: String, _ value: String) {
        self.title = Text(verbatim: title)
        self.value = value
    }

    var body: some View {
        LabeledContent {
            Text(value)
                .textSelection(.enabled)
                .multilineTextAlignment(.trailing)
        } label: {
            title
        }
    }
}

/// Barra de progreso horizontal con título y detalle.
struct GaugeRow: View {
    let title: LocalizedStringKey
    let fraction: Double
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(detail).foregroundStyle(.secondary).monospacedDigit()
            }
            ProgressView(value: fraction.clampedToUnit)
        }
    }
}

/// Fila con un valor sensible oculto que se muestra solo al presionar el botón.
struct SecretInfoRow: View {
    let title: LocalizedStringKey
    let value: String

    @State private var isRevealed = false

    init(_ title: LocalizedStringKey, _ value: String) {
        self.title = title
        self.value = value
    }

    private var buttonLabel: LocalizedStringKey { isRevealed ? "Hide" : "Show" }

    var body: some View {
        LabeledContent(title) {
            HStack(spacing: 6) {
                Text(isRevealed ? value : "••••••••••")
                    .textSelection(.enabled)
                    .monospaced(!isRevealed)
                    .foregroundStyle(isRevealed ? .primary : .secondary)

                Button(buttonLabel, systemImage: isRevealed ? "eye.slash" : "eye") {
                    isRevealed.toggle()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help(buttonLabel)
            }
        }
    }
}
