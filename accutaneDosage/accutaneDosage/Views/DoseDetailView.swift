import SwiftData
import SwiftUI
import InteractiveImageView

struct DoseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var entry: DoseEntry?
    @State private var selectedImages: [UIImage] = []
    @State private var imagePickerImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var selectedImageForZoom: Int?
    @State var opacity: CGFloat = 0
        
    let entryId: UUID
    
    private func loadEntry() {
        do {
            let descriptor = FetchDescriptor<DoseEntry>(
                predicate: #Predicate<DoseEntry> { entry in
                    entry.id == entryId
                }
            )
            if let loadedEntry = try modelContext.fetch(descriptor).first {
                entry = loadedEntry
                // Now load images separately
                loadImages(for: loadedEntry)
            }
        } catch {
            print("Error loading entry: \(error)")
        }
    }
    
    private func loadImages(for entry: DoseEntry) {
        guard let images = entry.images else { return }
        selectedImages = images.compactMap {
            return UIImage(data: $0.imageData)
        }
    }
    
    private func saveImages(_ images: [UIImage]) {
        guard let currentEntry = entry else { return }
        
        // Create DoseImage objects
        let newImages = images.compactMap { image -> DoseImage? in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
            return DoseImage(imageData: imageData, entry: currentEntry)
        }
        
        // Update entry
        if currentEntry.images == nil {
            currentEntry.images = newImages
        } else {
            currentEntry.images?.append(contentsOf: newImages)
        }
        currentEntry.hasImages = true
        
        // Insert new images into context
        newImages.forEach { modelContext.insert($0) }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving images: \(error)")
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                if let entry = entry {
                    VStack(spacing: 20) {
                        // Dose and timestamp display
                        Group {
                            Text("\(entry.dose, specifier: "%.1f") mg")
                                .font(.title)
                                .bold()
                            
                            Text(entry.timestamp.formatted(date: .long, time: .complete))
                                .foregroundColor(.secondary)
                        }
                        
                        // Display images
                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack {
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        Image(uiImage: selectedImages[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                selectedImageForZoom = index
                                            }
                                    }
                                }
                            }
                        }
                        
                        // Button to add new images
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Label("Add Images", systemImage: "photo.fill")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $imagePickerImages)
                    .onDisappear() {
                        if imagePickerImages.isEmpty { return }
                        
                        selectedImages.append(contentsOf: imagePickerImages)
                        saveImages(imagePickerImages)
                        imagePickerImages.removeAll()
                    }
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: Binding(
                get: { selectedImageForZoom != nil },
                set: { if !$0 { selectedImageForZoom = nil } }
            )) {
                if let index = selectedImageForZoom {
                    InteractiveImage(
                        image: selectedImages[index],
                        zoomInteraction: .init(location: .zero, scale: 1.2, animated: true)
                    )
                    .presentationDragIndicator(.visible)
                    .id(UUID())
                }
            }
        }
        .task {
            loadEntry()
        }
    }
}

