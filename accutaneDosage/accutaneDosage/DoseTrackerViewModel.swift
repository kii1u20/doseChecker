import Foundation
import SwiftUI

class DoseTrackerViewModel: ObservableObject {
    @AppStorage("currentDose") public var currentDoseString: String = ""
    @AppStorage("totalDose") public var totalDose: Double = 0
    @AppStorage("weight") public var weight: String = ""
    @AppStorage("showWeightPrompt") public var showWeightPrompt: Bool = true
    @AppStorage("goalMgKg") public var goalMgKg: String = ""
    
    public var history: [DoseEntry] = []
    
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
    
    func reset() {
        totalDose = 0
        currentDoseString = ""
        history = []
        saveHistory()
        FileManager.clearImageStorage()
    }
    
    func addDose(dose: Double) {
        totalDose += dose
        currentDoseString = ""
        
        let newEntry = DoseEntry(id: UUID(), dose: dose, timestamp: Date())
        history.append(newEntry)
        saveHistory()
    }
    
    func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            let fileURL = FileManager.documentsDirectory.appendingPathComponent("doseHistory.json")
            try data.write(to: fileURL)
        } catch {
            print("Error saving history: \(error)")
        }
    }

    func loadHistory() {
        let fileURL = FileManager.documentsDirectory.appendingPathComponent("doseHistory.json")
        if let data = try? Data(contentsOf: fileURL) {
            if let decoded = try? JSONDecoder().decode([DoseEntry].self, from: data) {
                history = decoded
            }
        }
    }
}
