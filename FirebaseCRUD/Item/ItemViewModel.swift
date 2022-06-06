import Foundation
import Combine
import FirebaseFirestore

class ItemViewModel: ObservableObject {    
    @Published var item: ItemsModel
    @Published var modified = false
    
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
    
//    private func addItem(_ item: ItemsModel) {
//        do {
//            let _ = try db.collection("products").addDocument(from: item)
//        }
//        catch {
//            print(error)
//        }
//    }
    
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
    
    
    func handleDoneTapped() {
        updateOrAddItem()
    }
    
    private func removeItem() {
        if let documentID = item.id {
            Task {
                try await db.collection("products").document(documentID).delete()
                let storageReference = StorageManager().listItem(for: documentID)
                try await StorageManager().deleteItem(item: storageReference)
            }
        }
    }
    func handleDeleteTapped() {
        removeItem()
    }
}
