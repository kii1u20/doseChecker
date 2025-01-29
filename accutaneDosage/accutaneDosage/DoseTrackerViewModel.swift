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
    
    var groupedEntries: [Date: [DoseEntry]] = [:]
    
    // Sort dates in descending order
    var sortedDates: [Date] = []
    
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
                let groupedEntries = Dictionary(grouping: loadedEntries) { entry in
                    Calendar.current.startOfDay(for: entry.timestamp)
                }
                let sortedDates = groupedEntries.keys.sorted(by: >)
                await MainActor.run {
                    entries = loadedEntries
                    self.groupedEntries = groupedEntries
                    self.sortedDates = sortedDates
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
        Task(priority: .background) {
            entries.removeAll()
            groupedEntries.removeAll()
            sortedDates.removeAll()
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
        
        // Handle grouped entries
        let dateKey = Calendar.current.startOfDay(for: newEntry.timestamp)
        if var entriesForDate = groupedEntries[dateKey] {
            entriesForDate.insert(newEntry, at: 0)
            groupedEntries[dateKey] = entriesForDate
        } else {
            groupedEntries[dateKey] = [newEntry]
            sortedDates.append(dateKey)
            // Sort dates on background thread
            Task(priority: .background) {
                let sorted = groupedEntries.keys.sorted(by: >)
                await MainActor.run {
                    sortedDates = sorted
                }
            }
        }
        
        Task(priority: .background) {
            do {
                try await DoseModelActor.shared.addDose(entry: newEntry)
            } catch {
                print("Error saving dose: \(error)")
            }
        }
        print("entries: \(entries.count)")
        print("groupedEntries: \(groupedEntries.count)")
        print("sortedDates: \(sortedDates.count)")
    }
    
    func deleteEntry(_ entry: DoseEntry, modelContext: ModelContext) {
        totalDose -= entry.dose
        entries.removeAll { $0.id == entry.id }
        
        // Handle grouped entries
        let dateKey = Calendar.current.startOfDay(for: entry.timestamp)
        if var entriesForDate = groupedEntries[dateKey] {
            entriesForDate.removeAll { $0.id == entry.id }
            if entriesForDate.isEmpty {
                groupedEntries.removeValue(forKey: dateKey)
                sortedDates.removeAll { $0 == dateKey }
                // Sort dates on background thread
                Task(priority: .background) {
                    let sorted = groupedEntries.keys.sorted(by: >)
                    await MainActor.run {
                        sortedDates = sorted
                    }
                }
            } else {
                groupedEntries[dateKey] = entriesForDate
            }
        }
        
        Task(priority: .background) {
            do {
                try await DoseModelActor.shared.deleteEntry(entry)
            } catch {
                print("Error deleting entry: \(error)")
            }
        }
        
        print("entries: \(entries.count)")
        print("groupedEntries: \(groupedEntries.count)")
        print("sortedDates: \(sortedDates.count)")
    }
}
