import SwiftData
import Foundation

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
