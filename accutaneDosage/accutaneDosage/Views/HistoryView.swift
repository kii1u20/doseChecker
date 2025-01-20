import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DoseEntry.timestamp, order: .reverse) private var entries: [DoseEntry]
    @Binding var totalDose: Double
    
    var body: some View {
        List {
            ForEach(entries) { entry in
                let binding = Binding(
                    get: { entry },
                    set: { newValue in
                        entry.dose = newValue.dose
                        entry.timestamp = newValue.timestamp
                        entry.imageNames = newValue.imageNames
                        try? modelContext.save()
                    }
                )
                NavigationLink(destination: DoseDetailView(entry: binding)) {
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
        for index in offsets {
            let entry = entries[index]
            totalDose -= entry.dose
            modelContext.delete(entry)
            
            // Delete associated images if they exist
            if let imageNames = entry.imageNames {
                for imageName in imageNames {
//                    FileManager.deleteImage(named: imageName)
                }
            }
        }
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Error deleting entries: \(error)")
        }
    }
}
