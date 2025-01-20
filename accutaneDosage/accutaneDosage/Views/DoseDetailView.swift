import SwiftUI
import LazyPager
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
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving images: \(error)")
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
         ZStack { // Use ZStack to layer the overlay
             ScrollView {
                 VStack(spacing: 20) {
                     Group {
                         Text("\(entry.dose, specifier: "%.1f") mg")
                             .font(.title)
                             .bold()

                         Text(entry.timestamp.formatted(date: .long, time: .complete))
                             .foregroundColor(.secondary)
                     }

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
//             .fullScreenCover(isPresented: $showZoomedImage) {
//                 if let image = selectedImageForZoom {
//                     let imageData = image.jpegData(compressionQuality: 1.0) ?? Data()
//                     let imageData2 = selectedImages[2].jpegData(compressionQuality: 1.0) ?? Data()
//                     LazyPager(data: [imageData, imageData2]) { data in
//                         Image(uiImage: UIImage(data: data)!)
//                             .resizable()
//                             .scaledToFit()
//                     }
//                     .zoomable(min: 1, max: 5)
//                     .onDismiss() {
//                         showZoomedImage = false
//                     }
//                 }
//             }
         }
         .task {
             selectedImages = loadImages()
         }
     }
 }
