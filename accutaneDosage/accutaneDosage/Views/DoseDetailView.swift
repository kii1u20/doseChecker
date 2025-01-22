import SwiftData
import SwiftUI
import InteractiveImageView

struct DoseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var entry: DoseEntry
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var selectedImageForZoom: Int?
    @State private var notes: String = ""
    
    //MARK: - Main view
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
                    
                    Text("Add any notes below")
                        .font(.title)
                        .bold()
                    
                    TextEditor(text: $notes)
                        .padding(.vertical)
                        .padding(.horizontal)
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden) // Hide default background
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .frame(minHeight: 100)
                        .onChange(of: notes) { _, _ in
                            saveNotes()
                        }
                }
                .padding()
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
                    .padding(.top)
                    .ignoresSafeArea(.all)
                    .presentationDragIndicator(.visible)
                    .id(index)
                }
            }
        }
        .navigationTitle("Details")
        .task {
            loadNotes()
            loadImages()
        }
    }
    
    //MARK: - loading information from the SwiftData database
    private func loadNotes() {
        DispatchQueue.main.async {
            notes = entry.note?.text ?? ""
        }
    }
    
    private func loadImages() {
        DispatchQueue.main.async {
            guard let images = entry.images else { return }
            let uiImages = images.compactMap { UIImage(data: $0.imageData) }
            self.selectedImages = uiImages
        }
    }
    
    //MARK: - saving information to the SwiftData database
    private func saveNotes() {
        DispatchQueue.main.async {
            if notes.isEmpty && entry.note != nil {
                modelContext.delete(entry.note!)
                entry.note = nil
                entry.hasNote = false
            } else if !notes.isEmpty {
                if let existingNote = entry.note {
                    existingNote.text = notes
                } else {
                    let newNote = DoseNote(text: notes, entry: entry)
                    entry.note = newNote
                    entry.hasNote = true
                    modelContext.insert(newNote)
                }
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving notes: \(error)")
            }
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
    
    
}
