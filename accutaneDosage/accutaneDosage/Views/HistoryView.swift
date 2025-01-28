import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: DoseTrackerViewModel
    @Binding var totalDose: Double
    @Namespace private var animation  // Add this line
    
    private var groupedEntries: [Date: [DoseEntry]] {
        Dictionary(grouping: viewModel.entries) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
    }
    
    // Sort dates in descending order
    private var sortedDates: [Date] {
        groupedEntries.keys.sorted(by: >)
    }
    
    var body: some View {
        List {
            ForEach(sortedDates, id: \.self) { date in
                Section(
                    header: HStack {
                        Spacer()
                        Text(date.formatted(.dateTime.month().day().year()))
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                ) {
                    ForEach(groupedEntries[date] ?? []) { entry in
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
                        // Convert section index to global index
                        if let firstIndex = indexSet.first,
                           let entries = groupedEntries[date] {
                            if let globalIndex = viewModel.entries.firstIndex(where: { $0.id == entries[firstIndex].id }) {
                                viewModel.deleteEntry(at: IndexSet([globalIndex]), modelContext: modelContext)
                            }
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
        }
    )
}
