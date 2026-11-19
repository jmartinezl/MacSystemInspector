# MacSystemInspector

App de macOS hecha con SwiftUI que muestra en una sola ventana la información del hardware y el rendimiento en vivo de tu Mac.

## Qué muestra

- **En vivo** (se actualiza cada segundo): uso de CPU, memoria y disco, batería, estado térmico y tiempo encendido.
- **Sistema y hardware**: versión de macOS, modelo, chip, núcleos, GPU, memoria total, número de serie y pantallas conectadas.

## Funciones

| Acción | Atajo |
|---|---|
| Copiar el informe en texto | ⌘⇧C |
| Copiar el informe en JSON (sin número de serie) | ⌘⇧J |
| Copiar un dato suelto | Edición → Copiar dato… |
| Modo Matrix | ⌥⌘M |

El menú **Secretos** y la ventana **Acerca de** tienen algunos easter eggs.

## Requisitos

- macOS 26.7 o superior
- Xcode 27

## Compilar y ejecutar

Abre `MacSystemInspector.xcodeproj` en Xcode y presiona ⌘R, o desde la terminal (sin abrir Xcode):

```bash
xcodebuild -project MacSystemInspector.xcodeproj -scheme MacSystemInspector \
  -destination 'platform=macOS' -configuration Debug \
  -derivedDataPath build build

open build/Build/Products/Debug/MacSystemInspector.app
```

El resultado queda en `build/` (ignorada por git). Si no cambiaste código, basta con el `open`.

## Estructura

```
MacSystemInspector/
├── MyApp.swift          # Punto de entrada y ventanas
├── AppCommands.swift    # Menús de la barra
├── Models/              # Lectura de datos del sistema y estado de la app
├── Views/               # Vistas SwiftUI y componentes reutilizables
└── Helpers/             # sysctl y formateadores
```
