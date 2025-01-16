import SwiftUI

struct DoseEntry: Identifiable, Codable {
    let id: UUID
    let dose: Double
    let timestamp: Date
    var imageNames: [String]? // Store image file names instead of data
    
    enum CodingKeys: String, CodingKey {
        case id, dose, timestamp, imageNames
    }
}


struct HistoryView: View {
    @Binding var history: [DoseEntry]
    @Binding var totalDose: Double
    var saveAction: () -> Void
    
    private var sortedHistory: [DoseEntry] {
        history.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
            List {
                ForEach(sortedHistory) { entry in
                    NavigationLink(destination: DoseDetailView(entry: binding(for: entry), saveAction: saveAction)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(entry.dose, specifier: "%.1f") mg")
                                    .font(.headline)
                                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if entry.imageNames?.isEmpty == false {
                                Spacer()
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("Dose History")
        }
    
    private func deleteEntries(at offsets: IndexSet) {
        // Convert view indices to actual array indices
        let sortedIndices = offsets.map { sortedHistory[$0] }
        
        // Remove entries and update total dose
        for entry in sortedIndices {
            if let index = history.firstIndex(where: { $0.id == entry.id }) {
                totalDose -= history[index].dose
                history.remove(at: index)
            }
        }
        saveAction()
    }
    
    private func binding(for entry: DoseEntry) -> Binding<DoseEntry> {
            Binding(
                get: { entry },
                set: { newValue in
                    if let index = history.firstIndex(where: { $0.id == entry.id }) {
                        history[index] = newValue
                        saveAction()
                    }
                }
            )
        }
}



