import SwiftUI

/// Ventana "Acerca de" con versión, créditos y un easter egg.
struct AboutView: View {

    @State private var taps = 0
    @State private var rotation = 0.0
    @State private var secretFound = false

    private var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Versión \(version) (\(build))"
    }

    var body: some View {
        VStack(spacing: 14) {

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
                .rotationEffect(.degrees(rotation))
                .onTapGesture(perform: iconTapped)

            VStack(spacing: 2) {
                Text("MacSystemInspector").font(.title.bold())
                Text(versionText).foregroundStyle(.secondary)
            }

            Text("Muestra la información de tu hardware en una sola ventana.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Divider()

            VStack(spacing: 4) {
                Text("Desarrollado por").font(.caption).foregroundStyle(.secondary)
                Text("mapacheboreal").font(.headline)            // ← CAMBIA (nombre)
                Text("Hecho con SwiftUI en Xcode").font(.caption).foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Link("GitHub", destination: URL(string: "https://github.com/tu-usuario")!)        // ← CAMBIA
                Link("Correo", destination: URL(string: "mailto:tu@correo.com")!)                // ← CAMBIA
            }

            if secretFound {
                Text("🦝 ¡Encontraste el mapache secreto!")
                    .font(.callout.weight(.medium))
                    .transition(.scale.combined(with: .opacity))
            }

            Text("© 2026 mapacheboreal")                           // ← CAMBIA
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(28)
        .frame(width: 340)
    }

    /// Gira el ícono y muestra el mensaje secreto tras 5 clics.
    private func iconTapped() {
        taps += 1
        guard taps >= 5 else { return }
        taps = 0
        withAnimation(.easeInOut(duration: 1)) {
            rotation += 360
            secretFound = true
        }
    }
}

#Preview {
    AboutView()
}
