import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: DoseTrackerViewModel
    @Binding var totalDose: Double
    
    var body: some View {
        List {
            ForEach(viewModel.entries) { entry in
                NavigationLink(destination: DoseDetailView(entry: binding(for: entry))) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(entry.dose, specifier: "%.1f") mg")
                                .font(.headline)
                            Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
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
                viewModel.deleteEntry(at: indexSet, modelContext: modelContext)
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
