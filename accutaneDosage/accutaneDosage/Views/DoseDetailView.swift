import SwiftData
import SwiftUI
import InteractiveImageView

struct DoseDetailView: View {
    @Binding var entry: DoseEntry
    @Environment(\.modelContext) private var modelContext
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var selectedImageForZoom: UIImage?
    @State private var showZoomedImage = false
    @State var tapLocation: CGPoint = .zero
    @State var opacity: CGFloat = 0 // Dismiss gesture background opacity

    // Convert UIImage to Data and store it in `entry.imageData`
    private func saveImages(_ images: [UIImage]) {
        let newImageData = images.compactMap { image -> Data? in
            image.jpegData(compressionQuality: 0.8)
        }
        
        if entry.imageData == nil {
            entry.imageData = newImageData
        } else {
            entry.imageData?.append(contentsOf: newImageData)
        }

        do {
            try modelContext.save()
        } catch {
            print("Error saving images: \(error)")
        }
    }

    // Convert `entry.imageData` back to an array of UIImages
    private func loadImages() -> [UIImage] {
        guard let imageDataArray = entry.imageData else { return [] }
        return imageDataArray.compactMap { UIImage(data: $0) }
    }

    var body: some View {
        ZStack {
            ScrollView {
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
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            selectedImageForZoom = image
                                            showZoomedImage = true
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $selectedImages)
                    .onDisappear() {
                        saveImages(selectedImages)
                    }
            }
            .sheet(isPresented: $showZoomedImage) {
                if let image = selectedImageForZoom {
                    InteractiveImage(image: image, zoomInteraction: .init(location: tapLocation, scale: 1.2, animated: true))
                        .presentationDragIndicator(.visible)
                }
            }
        }
        .task {
            selectedImages = loadImages() // Load images when the view appears
        }
    }
}
