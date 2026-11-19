import Foundation

/// Lectura de valores del kernel con `sysctlbyname`.
enum Sysctl {

    /// Lee un valor de texto, o `nil` si la clave no existe.
    static func string(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return nil }

        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return nil }

        return String(cString: buffer)
    }

    /// Lee un entero de 32 o 64 bits (funciona con ambos porque el buffer empieza en 0).
    static func int(_ name: String) -> Int? {
        var value: Int64 = 0
        var size = MemoryLayout<Int64>.size

        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else { return nil }
        return Int(value)
    }
}
