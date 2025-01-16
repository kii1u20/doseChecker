import FileProvider

extension FileManager {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func saveImage(_ imageData: Data, withName name: String) -> Bool {
        let imageURL = documentsDirectory.appendingPathComponent(name)
        do {
            try imageData.write(to: imageURL)
            return true
        } catch {
            print("Error saving image: \(error)")
            return false
        }
    }
    
    static func loadImage(named name: String) -> Data? {
        let imageURL = documentsDirectory.appendingPathComponent(name)
        return try? Data(contentsOf: imageURL)
    }
    
    static func clearImageStorage() {
            let fileManager = FileManager.default
            let documentsURL = documentsDirectory
            
            do {
                let fileURLs = try fileManager.contentsOfDirectory(
                    at: documentsURL,
                    includingPropertiesForKeys: nil
                )
                
                // Delete only image files (jpg)
                for fileURL in fileURLs where fileURL.pathExtension == "jpg" {
                    try fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("Error clearing image storage: \(error)")
            }
        }
}


