import SwiftUI

struct DoseDetailView: View {
    @Binding var entry: DoseEntry
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    var saveAction: () -> Void
    
    private func saveImages(_ images: [UIImage]) {
        var imageNames: [String] = []
        
        for image in images {
            let imageName = "\(entry.id)-\(UUID().uuidString).jpg"
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                if FileManager.saveImage(imageData, withName: imageName) {
                    imageNames.append(imageName)
                }
            }
        }
        
        if entry.imageNames == nil {
            entry.imageNames = imageNames
        } else {
            entry.imageNames?.append(contentsOf: imageNames)
        }
    }
    
    private func loadImages() -> [UIImage] {
        guard let imageNames = entry.imageNames else { return [] }
        return imageNames.compactMap { name in
            guard let imageData = FileManager.loadImage(named: name) else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dose Information
                Group {
                    Text("\(entry.dose, specifier: "%.1f") mg")
                        .font(.title)
                        .bold()
                    
                    Text(entry.timestamp.formatted(date: .long, time: .complete))
                        .foregroundColor(.secondary)
                }
                
                // Image Gallery
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                Button(action: {
                    showImagePicker = true
                }) {
                    Label("Add Images", systemImage: "photo.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(images: $selectedImages)
                .onDisappear() {
                    saveImages(selectedImages)
                    saveAction()
                }
            
        }
        .task {
            selectedImages = loadImages()
        }
    }
}
