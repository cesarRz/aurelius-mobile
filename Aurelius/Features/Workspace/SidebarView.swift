import SwiftUI

struct SidebarView: View {
    @Binding var tab: PhoneTab

    var body: some View {
        List {
            ForEach(PhoneTab.allCases, id: \.self) { item in
                Button {
                    tab = item
                } label: {
                    Label(item.title, systemImage: item.icon)
                }
                .foregroundStyle(tab == item ? Color.accentColor : Color.primary)
                .listRowBackground(
                    tab == item ? Color.accentColor.opacity(0.12) : Color.clear
                )
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Aurelius")
    }
}