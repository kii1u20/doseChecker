import SwiftUI
import SwiftData
import InteractiveImageView

struct DoseDetailView: View {
    @Binding var entry: DoseEntry
    @Environment(\.modelContext) private var modelContext
    @State private var showImagePicker = false
    @State private var tempSelectedImages: [UIImage] = [] // Temporary state for ImagePicker
    @State private var selectedImageForZoom: UIImage?
    @State private var showZoomedImage = false
    @State var tapLocation: CGPoint = .zero

    // Save images directly to `entry.imageData`
    private func saveImages(_ images: [UIImage]) {
        let newImageData = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
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

                    // Display images directly from `entry.imageData`
                    if let imageDataArray = entry.imageData, !imageDataArray.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(imageDataArray, id: \.self) { imageData in
                                    if let image = UIImage(data: imageData) {
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
                // Pass a temporary binding to ImagePicker
                ImagePicker(images: $tempSelectedImages)
                    .onDisappear {
                        if !tempSelectedImages.isEmpty {
                            saveImages(tempSelectedImages) // Save selected images to entry
                            tempSelectedImages.removeAll() // Clear temporary storage
                        }
                    }
            }
            .sheet(isPresented: $showZoomedImage) {
                if let image = selectedImageForZoom {
                    InteractiveImage(image: image, zoomInteraction: .init(location: tapLocation, scale: 1.2, animated: true))
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
