import SwiftData
import SwiftUI
import InteractiveImageView

struct DoseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var entry: DoseEntry
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var selectedImageForZoom: Int?
    @State var opacity: CGFloat = 0
    
    private func loadImages() {
        DispatchQueue.main.async {
            guard let images = entry.images else { return }
            let uiImages = images.compactMap { UIImage(data: $0.imageData) }
            self.selectedImages = uiImages
        }
    }
    
    private func saveImages(_ images: [UIImage]) {
        DispatchQueue.main.async {
            let compressedImages = images.compactMap { image -> DoseImage? in
                guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
                return DoseImage(imageData: data, entry: entry)
            }
            
            if entry.images == nil {
                entry.images = compressedImages
            } else {
                entry.images?.append(contentsOf: compressedImages)
            }
            entry.hasImages = true
            
            compressedImages.forEach { modelContext.insert($0) }
            do {
                try modelContext.save()
            } catch {
                print("Error saving images: \(error)")
            }
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                //                if let entry = entry {
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
                //                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $selectedImages) { newImages in
                    if !newImages.isEmpty {
                        saveImages(newImages)
                    }
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
                    .id(index)
                }
            }
        }
        .task {
            loadImages()
        }
    }
}

