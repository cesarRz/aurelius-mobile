import SwiftUI

struct SidebarView: View {
    @Binding var tab: PhoneTab

    var body: some View {
        List(
            PhoneTab.allCases,
            selection: Binding<PhoneTab?>(
                get: { tab },
                set: { newValue in
                    if let newValue { tab = newValue }
                }
            )
        ) { item in
            Label(item.title, systemImage: item.icon)
                .tag(item)
        }
        .listStyle(.sidebar)
        .navigationTitle("Aurelius")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 260)
        #endif
    }
}
