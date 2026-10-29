import SwiftUI

struct AgendaAreaFilter: View {
    let areas: [Area]
    @Binding var selectedAreaID: UUID?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 18) {
                areaButton("All", icon: "square.grid.2x2", id: nil)
                ForEach(areas) { area in
                    areaButton(area.name, icon: area.icon, id: area.id)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.hidden)
    }

    private func areaButton(_ title: String, icon: String, id: UUID?) -> some View {
        let selected = selectedAreaID == id
        return Button {
            selectedAreaID = id
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(selected ? Color.appBackground : .primary)
                    .frame(width: 52, height: 52)
                    .background(selected ? Color.primary : Color.primary.opacity(0.05), in: Circle())
                Text(title)
                    .font(.caption.weight(selected ? .semibold : .regular))
                    .foregroundStyle(selected ? .primary : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 68)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
