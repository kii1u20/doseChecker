import SwiftUI
import SwiftData

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
