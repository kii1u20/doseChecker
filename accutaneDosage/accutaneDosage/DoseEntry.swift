import SwiftData
import SwiftUI

@Model
final class DoseEntry {
    var id: UUID
    var dose: Double
    var timestamp: Date
    @Attribute(.externalStorage) var imageData: [Data]?
    
    init(id: UUID = UUID(), dose: Double, timestamp: Date = Date(), imageData: [Data]? = nil) {
        self.id = id
        self.dose = dose
        self.timestamp = timestamp
        self.imageData = imageData
    }
}
