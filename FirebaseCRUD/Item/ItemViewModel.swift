import Foundation
import Combine
import FirebaseFirestore
import UIKit // for UIImage

final class ItemViewModel: ObservableObject {
    @Published var item: ItemsModel
    @Published var modified = false
    @Published var isLoadingImage = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(item: ItemsModel = ItemsModel(title: "", price: 0, image: "")) {
        self.item = item
        
        self.$item
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                self?.modified = true
            }
            .store(in: &cancellables)
    }
    
    private var db = Firestore.firestore()
    
    // TODO: make `viewModel.item.id` non Optional?
    // make `upload(image...)` throwing?
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
        item.image = url
    }
    
    @MainActor private func setLoadingImage(_ value: Bool) {
        isLoadingImage = value
    }
    
    private func updateItem(_ item: ItemsModel) {
        if let documentID = item.id {
            do {
                try db.collection("products").document(documentID).setData(from: item)
            }
            catch {
                print("Error")
            }
        }
    }
    private func updateOrAddItem() {
        //        if let _ = item.id {
        updateItem(item)
        //        }
        //        else {
        //        addItem(item)
        //        }
    }
    
    
    private func removeMediaForItem(with documentID: String) async throws {
        let storageReference = StorageManager().listItem(for: documentID)
        try await StorageManager().deleteItem(item: storageReference)
    }
    
    
    func handleDoneTapped() {
        updateOrAddItem()
    }
    
    private func removeItem() {
        guard let documentID = item.id else { return }
        Task {
            try await db.collection("products").document(documentID).delete()
            try await removeMediaForItem(with: documentID)
        }
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
}
