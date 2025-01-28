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
        Task(priority: .background) {
            do {
                let loadedEntries = try await DoseModelActor.shared.loadEntries()
                await MainActor.run {
                    entries = loadedEntries
                }
            } catch {
                print("Error loading history entries: \(error)")
            }
        }
    }
    
    func reset(modelContext: ModelContext) {
        totalDose = 0
        currentDoseString = ""
        
        // Clear entries from memory
        entries.removeAll()
        Task(priority: .background) {
            do {
                try await DoseModelActor.shared.clearAllEntries()
            } catch {
                print("Error clearing history: \(error)")
            }
        }
        
    }
    
    func addDose(dose: Double, modelContext: ModelContext) {
        totalDose += dose
        currentDoseString = ""
        
        let newEntry = DoseEntry(id: UUID(), dose: dose, timestamp: Date())
        // Update in-memory array
        entries.insert(newEntry, at: 0)  // Insert at beginning since sorted by newest
        
        Task(priority: .background) {
            do {
                try await DoseModelActor.shared.addDose(entry: newEntry)
            } catch {
                print("Error saving dose: \(error)")
            }
        }
    }
    
    func deleteEntry(at indexSet: IndexSet, modelContext: ModelContext) {
        let entry = entries[indexSet.first!]
        totalDose -= entry.dose
        entries.remove(at: indexSet.first!)
        Task(priority: .background) {
            do {
                try await DoseModelActor.shared.deleteEntry(entry)
            } catch {
                print ("Error deleting entry: \(error)")
            }
            
        }
    }
}
