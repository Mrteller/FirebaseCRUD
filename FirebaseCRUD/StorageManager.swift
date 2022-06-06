import SwiftUI
import Firebase
import FirebaseStorage

final class StorageManager {
    let storage = Storage.storage()
    
    func upload(image: UIImage, name: String, savedWithURL: ((URL) -> Void)? = nil) async {
        // Create a storage reference
        let storageRef = storage.reference().child("images/\(name).jpg")
        
        // Resize the image to 200px with a custom extension
        let resizedImage = image.aspectFittedToHeight(200)
        
        // Convert the image into JPEG and compress the quality to reduce its size
        let data = resizedImage.jpegData(compressionQuality: 0.2)
        
        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        
        // Upload the image
        if let data = data {
            do {
                let storedMetadata = try await storageRef.putDataAsync(data, metadata: metadata)
                print("Metadata: ", storedMetadata)
                let storedURL = try await storageRef.downloadURL()
                savedWithURL?(storedURL)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func listAllFiles() {
        // Create a reference
        let storageRef = storage.reference().child("images")
        
        // List all items in the images folder
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error while listing all files: ", error)
            }
            
            guard let result = result else { return }
            
            for item in result.items {
                print("Item in images folder: ", item)
            }
        }
    }
    
    func listItem(for name: String) -> StorageReference {
        storage.reference().child("images/\(name).jpg")
    }
    
    func deleteItem(item: StorageReference) async throws {
        try await item.delete()
    }
}
