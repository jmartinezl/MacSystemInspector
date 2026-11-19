import SwiftUI

/// Overlay animado de caracteres verdes cayendo, al estilo "Matrix".
struct MatrixRain: View {

    private let glyphs = Array("01ABCDEFGHIJKLMNOPQRSTUVWXYZ+=*<>ｱｲｳｴｵｶｷｸｹｺ")
    private let cell: CGFloat = 16
    private let tailLength = 12

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)

            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let columns = Int(size.width / cell)
                    let rows = max(Int(size.height / cell), 1)

                    for col in 0..<columns {
                        let speed = 5.0 + Double(col % 7)
                        let offset = Double((col * 37) % 101)
                        let head = Int((t * speed + offset)
                            .truncatingRemainder(dividingBy: Double(rows + 20)))

                        for tail in 0..<tailLength {
                            let row = head - tail
                            guard row >= 0, row < rows else { continue }

                            let index = (col * 31 + row * 17 + Int(t * 8)) % glyphs.count
                            let opacity = 1 - Double(tail) / Double(tailLength)

                            var text = context.resolve(
                                Text(String(glyphs[index]))
                                    .font(.system(size: 14, design: .monospaced))
                            )
                            text.shading = .color(.green.opacity(opacity))

                            context.draw(text, at: CGPoint(
                                x: CGFloat(col) * cell + cell / 2,
                                y: CGFloat(row) * cell + cell / 2
                            ))
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
