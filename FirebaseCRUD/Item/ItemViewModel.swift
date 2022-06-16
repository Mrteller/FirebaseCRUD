import Foundation
import Combine
import FirebaseFirestore
import UIKit // for UIImage

protocol ItemWithImage: Identifiable, Codable {
    var id: String? { get set }
    var imageURL: String { get set }
    static var collection: String? { get set }
}

extension ItemWithImage {
    
    static var collection: String? {
        get { nil }
        set { }
    }
    
    static var collectionName: String {
        if let collection = collection, !collection.isEmpty {
            return collection
        } else {
            return String(describing: type(of: self))
        }
    }
}


final class ItemViewModel<Item: ItemWithImage>: ObservableObject {
    @Published var item: Item
    @Published var modified = false
    @Published var isLoadingImage = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private var db = Firestore.firestore()
    
    init(item: Item) {
        self.item = item
        
        self.$item
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                self?.modified = true
            }
            .store(in: &cancellables)
    }
    
    func handleDoneTapped() {
        updateOrAddItem()
    }
    
    func handleDeleteTapped() {
        removeItem()
    }
    
    func handleCancelTapped() {
        guard let documentID = item.id else { return }
        Task {
            try await removeMediaForItem(with: documentID)
        }
    }
    
    // TODO: make `viewModel.item.id` non Optional?
    // make `upload(image...)` throwing?
    // use image data?
    func update(image: UIImage) async {
        await setLoadingImage(true)
        guard let url = await StorageManager().upload(image: image, name: item.id ?? "untitled")
        else {
            await setLoadingImage(false)
            return
        }
        await updateItemImage(url: url.absoluteString)
        await setLoadingImage(false)
    }
    
    @MainActor private func updateItemImage(url: String) {
        item.imageURL = url
    }
    
    @MainActor private func setLoadingImage(_ value: Bool) {
        isLoadingImage = value
    }
    
    private func updateOrAddItem() {
        if let documentID = item.id {
            do {
                try db.collection(Item.collectionName).document(documentID).setData(from: item)
            }
            catch {
                print("Error")
            }
        }
    }
    
    private func removeMediaForItem(with documentID: String) async throws {
        let storageReference = StorageManager().listItem(for: documentID)
        try await StorageManager().deleteItem(item: storageReference)
    }
    
    private func removeItem() {
        guard let documentID = item.id else { return }
        Task {
            try await db.collection(Item.collectionName).document(documentID).delete()
            try await removeMediaForItem(with: documentID)
        }
    }
    
}
