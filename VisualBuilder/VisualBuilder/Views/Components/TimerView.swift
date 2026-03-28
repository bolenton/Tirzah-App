import SwiftUI

struct TimerView: View {
    let remainingTime: TimeInterval
    let totalTime: TimeInterval

    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return remainingTime / totalTime
    }

    private var timeString: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var timerColor: Color {
        if progress > 0.5 { return .vbBlue }
        if progress > 0.25 { return .vbYellow }
        if progress > 0.10 { return .vbOrange }
        return .vbRed
    }

    private var isUrgent: Bool {
        progress <= 0.10
    }

    var body: some View {
        HStack(spacing: 12) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.vbSurface, lineWidth: 4)
                    .frame(width: 48, height: 48)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(timerColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: progress)

                Image(systemName: "timer")
                    .font(.system(size: 18))
                    .foregroundStyle(timerColor)
            }

            // Time text
            Text(timeString)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(timerColor)
                .scaleEffect(isUrgent ? 1.05 : 1.0)
                .animation(
                    isUrgent ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default,
                    value: isUrgent
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vbBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUrgent ? timerColor.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Timer: \(Int(remainingTime)) seconds remaining")
        .accessibilityValue("\(Int(progress * 100)) percent time remaining")
    }
}
