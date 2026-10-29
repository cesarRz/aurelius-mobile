import SwiftUI

struct AgendaDateNavigator: View {
    @Environment(\.calendar) private var calendar
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false

    var body: some View {
        HStack(spacing: 8) {
            Button {
                moveDay(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("Previous day")

            Button {
                showingDatePicker = true
            } label: {
                VStack(spacing: 4) {
                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        Text(selectedDate.formatted(.dateTime.month(.wide).day().year()))
                            .font(.headline)
                        Image(systemName: "calendar")
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .multilineTextAlignment(.center)
            }
            .accessibilityLabel("Choose date")
            .accessibilityValue(selectedDate.formatted(date: .complete, time: .omitted))

            Button {
                moveDay(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("Next day")
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Choose date")
                    .inlineNavigationTitle()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Today") {
                                selectedDate = .now
                                showingDatePicker = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingDatePicker = false }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func moveDay(by value: Int) {
        guard let date = calendar.date(byAdding: .day, value: value, to: selectedDate) else { return }
        selectedDate = date
    }
}
