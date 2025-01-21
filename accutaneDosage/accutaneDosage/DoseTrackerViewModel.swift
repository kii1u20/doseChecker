import Foundation
import SwiftUI
import SwiftData

class DoseTrackerViewModel: ObservableObject {
    @AppStorage("currentDose") public var currentDoseString: String = ""
    @AppStorage("totalDose") public var totalDose: Double = 0
    @AppStorage("weight") public var weight: String = ""
    @AppStorage("showWeightPrompt") public var showWeightPrompt: Bool = true
    @AppStorage("goalMgKg") public var goalMgKg: String = ""
    
    // Keep track of entries in memory
    @Published private(set) var entries: [DoseEntry] = []
    
    // Calculate maximum dose based on weight
    var maxDose: Double {
        guard let weightKg = Double(weight) else { return 0 }
        return weightKg * (Double(goalMgKg) ?? 0)
    }
    
    // Calculate remaining dose
    var remainingDose: Double {
        return max(maxDose - totalDose, 0)
    }
    
    var totalDosePerKg: Double {
        return totalDose / (Double(weight) ?? 0)
    }
    
    func loadInitialData(modelContext: ModelContext) {
        do {
            var descriptor = FetchDescriptor<DoseEntry>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            descriptor.propertiesToFetch = [
                \DoseEntry.id,
                 \DoseEntry.dose,
                 \DoseEntry.timestamp
            ]
            entries = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading initial data: \(error)")
        }
    }
    
    func reset(modelContext: ModelContext) {
        totalDose = 0
        currentDoseString = ""
        
        // Clear entries from memory
        entries.removeAll()
        
        do {
            try modelContext.delete(model: DoseEntry.self)
            try modelContext.save()
        } catch {
            print("Error clearing history: \(error)")
        }
        FileManager.clearImageStorage()
    }
    
    func addDose(dose: Double, modelContext: ModelContext) {
        totalDose += dose
        currentDoseString = ""
        
        let newEntry = DoseEntry(id: UUID(), dose: dose, timestamp: Date())
        // Update in-memory array
        entries.insert(newEntry, at: 0)  // Insert at beginning since sorted by newest
        
        modelContext.insert(newEntry)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving dose: \(error)")
        }
    }
    
    func deleteEntry(at indexSet: IndexSet, modelContext: ModelContext) {
        for index in indexSet {
            let entry = entries[index]
            totalDose -= entry.dose
            entries.remove(at: index)
            modelContext.delete(entry)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting entries: \(error)")
        }
    }
}
