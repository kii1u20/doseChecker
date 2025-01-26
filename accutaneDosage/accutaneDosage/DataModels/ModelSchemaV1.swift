import SwiftUI
import SwiftData

enum AccutaneDosageSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [DoseEntry.self, DoseImage.self, DoseNote.self]
    }
    
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

    @Model
    final class DoseImage {
        var id: UUID
        @Attribute(.externalStorage) var imageData: Data
        var entry: DoseEntry?
        
        init(id: UUID = UUID(), imageData: Data, entry: DoseEntry? = nil) {
            self.id = id
            self.imageData = imageData
            self.entry = entry
        }
    }
    
    @Model
    final class DoseNote {
        var id: UUID
        var text: String
        var entry: DoseEntry?
        
        init(id: UUID = UUID(), text: String, entry: DoseEntry? = nil) {
            self.id = id
            self.text = text
            self.entry = entry
        }
    }
}
