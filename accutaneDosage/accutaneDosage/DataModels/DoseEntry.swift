import SwiftData
import SwiftUI

@Model
final class DoseEntry {
    var id: UUID
    var dose: Double
    var timestamp: Date
    var hasImages: Bool
    var hasNote: Bool
    @Relationship(deleteRule: .cascade, inverse: \DoseImage.entry) var images: [DoseImage]?
    @Relationship(deleteRule: .cascade, inverse: \DoseNote.entry) var note: DoseNote?
    
    init(id: UUID = UUID(), dose: Double, timestamp: Date = Date()) {
        self.id = id
        self.dose = dose
        self.timestamp = timestamp
        self.hasImages = false
        self.hasNote = false
        self.images = nil
        self.note = nil
    }
}
