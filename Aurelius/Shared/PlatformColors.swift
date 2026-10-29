import SwiftUI

extension Color {
    /// Equivalente multiplataforma de `UIColor.systemBackground`.
    static var appBackground: Color {
        #if os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(uiColor: .systemBackground)
        #endif
    }

    /// Equivalente multiplataforma de `UIColor.secondarySystemGroupedBackground`.
    static var appSecondaryGroupedBackground: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(uiColor: .secondarySystemGroupedBackground)
        #endif
    }
}

extension View {
    /// `navigationBarTitleDisplayMode(.inline)` solo existe en iOS.
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

extension View {
    /// `listSectionSpacing` solo existe en iOS.
    func compactSectionSpacing(_ spacing: CGFloat) -> some View {
        #if os(iOS)
        listSectionSpacing(spacing)
        #else
        self
        #endif
    }
}
