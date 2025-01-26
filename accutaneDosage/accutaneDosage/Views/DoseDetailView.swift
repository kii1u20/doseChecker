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
    @FocusState var isNotesFieldFocused: Bool
    @Namespace private var animation  // Add this line
    
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
                                        .matchedTransitionSource(id: index, in: animation)
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
                        .focused($isNotesFieldFocused)
                    Spacer()
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
                    .navigationTransition(.zoom(sourceID: index, in: animation))
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
        .onTapGesture {
            isNotesFieldFocused = false
        }
    }
    
    //MARK: - loading information from the SwiftData database
    private func loadNotes() {
        Task {
            let loadedNotes = await DoseModelActor.shared.loadNotes(for: entry)
            await MainActor.run {
                notes = loadedNotes
            }
        }
    }
    
    private func loadImages() {
        Task {
            let loadedImages = await DoseModelActor.shared.loadImages(for: entry)
            await MainActor.run {
                selectedImages = loadedImages
            }
        }
    }
    
    //MARK: - saving information to the SwiftData database
    private func saveNotes() {
        Task {
            do {
                try await DoseModelActor.shared.saveNote(text: notes, for: entry)
            } catch {
                print("error saving notes")
            }
        }
    }
    
    private func saveImages(_ images: [UIImage]) {
        Task {
            do {
                try await DoseModelActor.shared.saveImages(images, for: entry)
            } catch {
                print("error saving images")
            }
        }
    }
}
