import Foundation
import Combine

/// Mensaje de un easter egg que se muestra como alerta.
struct EasterEggMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

/// Estado de la interfaz compartido entre los menús y la ventana principal.
final class AppState: ObservableObject {
    @Published var matrixMode = false
    @Published var easterEgg: EasterEggMessage?
}
