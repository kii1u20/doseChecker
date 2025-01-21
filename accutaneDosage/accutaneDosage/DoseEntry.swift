import SwiftData
import SwiftUI

@Model
final class DoseEntry {
    var id: UUID
    var dose: Double
    var timestamp: Date
    var hasImages: Bool
    @Relationship(deleteRule: .cascade, inverse: \DoseImage.entry) var images: [DoseImage]?
    
    init(id: UUID = UUID(), dose: Double, timestamp: Date = Date()) {
        self.id = id
        self.dose = dose
        self.timestamp = timestamp
        self.hasImages = false
        self.images = nil
    }
}
