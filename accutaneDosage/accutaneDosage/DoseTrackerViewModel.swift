import Foundation
import SwiftUI
import SwiftData

class DoseTrackerViewModel: ObservableObject {
    @AppStorage("currentDose") public var currentDoseString: String = ""
    @AppStorage("totalDose") public var totalDose: Double = 0
    @AppStorage("weight") public var weight: String = ""
    @AppStorage("showWeightPrompt") public var showWeightPrompt: Bool = true
    @AppStorage("goalMgKg") public var goalMgKg: String = ""
        
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
    
    func reset(modelContext: ModelContext) {
        totalDose = 0
        currentDoseString = ""
        do {
            try modelContext.delete(model: DoseEntry.self)
        } catch {
            print("Error clearing history: \(error)")
        }
        FileManager.clearImageStorage()
    }
    
    func addDose(dose: Double, modelContext: ModelContext) {
        totalDose += dose
        currentDoseString = ""
        
        let newEntry = DoseEntry(id: UUID(), dose: dose, timestamp: Date())
        modelContext.insert(newEntry)
        do {
            try modelContext.save()
//            loadHistory(modelContext: modelContext)  // Reload to get the latest data
        } catch {
            print("Error saving dose: \(error)")
        }
    }
    

//    func loadHistory(modelContext: ModelContext) {
//         do {
//             let descriptor = FetchDescriptor<DoseEntry>(
//                 sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
//             )
//             history = try modelContext.fetch(descriptor)
//         } catch {
//             print("Error loading history: \(error)")
//         }
//     }
}
