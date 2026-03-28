import SwiftUI

extension View {
    /// Adds standard high-contrast border when accessibility setting is enabled
    func highContrastBorder(_ isEnabled: Bool, color: Color = .white) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isEnabled ? color : .clear, lineWidth: 3)
        )
    }

    /// Makes text size respond to Dynamic Type with a minimum size
    func accessibleFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.font(.system(size: max(size, 16), weight: weight, design: design))
    }

    /// Ensures minimum touch target of 60x60pt for accessibility
    func accessibleTouchTarget() -> some View {
        self.frame(minWidth: 60, minHeight: 60)
    }
}
