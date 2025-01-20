import SwiftData
import SwiftUI

@Model
final class DoseEntry {
    var id: UUID
    var dose: Double
    var timestamp: Date
    var imageNames: [String]?
    
    init(id: UUID = UUID(), dose: Double, timestamp: Date = Date(), imageNames: [String]? = nil) {
        self.id = id
        self.dose = dose
        self.timestamp = timestamp
        self.imageNames = imageNames
    }
}
