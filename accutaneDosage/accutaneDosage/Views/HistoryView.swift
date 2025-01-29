import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: DoseTrackerViewModel
    @Binding var totalDose: Double
    @Namespace private var animation  // Add this line
    
    var body: some View {
        List {
            ForEach(viewModel.sortedDates, id: \.self) { date in
                Section(
                    header: HStack {
                        Spacer()
                        Text(date.formatted(.dateTime.month().day().year()))
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                ) {
                    ForEach(viewModel.groupedEntries[date] ?? []) { entry in
                        NavigationLink {
                            DoseDetailView(entry: binding(for: entry))
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(entry.dose, specifier: "%.1f") mg")
                                        .font(.headline)
                                    Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if entry.hasImages {
                                    Spacer()
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if let firstIndex = indexSet.first,
                           let entries = viewModel.groupedEntries[date] {
                            let entryToDelete = entries[firstIndex]
                            viewModel.deleteEntry(entryToDelete, modelContext: modelContext)
                        }
                    }
                }
            }
        }
        .navigationTitle("Dose History")
    }
}

private func binding(for entry: DoseEntry) -> Binding<DoseEntry> {
    Binding(
        get: { entry },
        set: { newValue in
            entry.dose = newValue.dose
            entry.timestamp = newValue.timestamp
            entry.hasImages = newValue.hasImages
            entry.images = newValue.images
            entry.hasNote = newValue.hasNote
            entry.note = newValue.note
        }
    )
}
