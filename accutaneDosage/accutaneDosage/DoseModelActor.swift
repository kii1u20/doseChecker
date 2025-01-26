import SwiftUI
import SwiftData

@ModelActor
actor DoseModelActor {
    static var shared: DoseModelActor!
    
    static func initialize(container: ModelContainer) {
        shared = DoseModelActor(modelContainer: container)
    }
    
    // MARK: - Dose Entry Operations
    func loadEntries() throws -> [DoseEntry] {
        var descriptor = FetchDescriptor<DoseEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.propertiesToFetch = [
            \DoseEntry.id,
            \DoseEntry.dose,
            \DoseEntry.timestamp
        ]
        return try modelContext.fetch(descriptor)
    }
    
    func addDose(entry: DoseEntry) throws {
        modelContext.insert(entry)
        try modelContext.save()
    }
    
    func deleteEntry(_ entry: DoseEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    func clearAllEntries() throws {
        try modelContext.delete(model: DoseEntry.self)
        try modelContext.save()
    }
    
    // MARK: - Notes Operations
    func saveNote(text: String, for entry: DoseEntry) throws {
        if text.isEmpty && entry.note != nil {
            modelContext.delete(entry.note!)
            entry.note = nil
            entry.hasNote = false
        } else if !text.isEmpty {
            if let existingNote = entry.note {
                existingNote.text = text
            } else {
                let newNote = DoseNote(text: text, entry: entry)
                entry.note = newNote
                entry.hasNote = true
                modelContext.insert(newNote)
            }
        }
        try modelContext.save()
    }
    
    func loadNotes(for entry: DoseEntry) -> String {
        entry.note?.text ?? ""
    }
    
    // MARK: - Image Operations
    func saveImages(_ images: [UIImage], for entry: DoseEntry) throws {
        let compressedImages = images.compactMap { image -> DoseImage? in
            guard let data = image.heicData() else { return nil }
            return DoseImage(imageData: data, entry: entry)
        }
        
        if entry.images == nil {
            entry.images = compressedImages
        } else {
            entry.images?.append(contentsOf: compressedImages)
        }
        entry.hasImages = true
        
//        compressedImages.forEach { modelContext.insert($0) }
        try modelContext.save()
    }
    
    func loadImages(for entry: DoseEntry) -> [UIImage] {
        guard let images = entry.images else { return [] }
        return images.compactMap { UIImage(data: $0.imageData) }
    }
}
