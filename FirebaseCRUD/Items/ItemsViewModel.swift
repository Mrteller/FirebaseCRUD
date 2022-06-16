import Foundation
import Combine
import FirebaseFirestore
//import FirebaseFirestoreSwift

class ItemsViewModel<Item: ItemWithImage>: ObservableObject {
    
    //    @FirestoreQuery(collectionPath: "products") var items: [ItemsModel]
    @Published var items = [Item]()
//    private var collection: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
//    var collectionName: String {
//        if let collection = collection, !collection.isEmpty {
//            return collection
//        } else {
//            return String(describing: Item.self)
//        }
//    }
//
//    init(collection: String? = nil) {
//        self.collection = collection
//    }
    
    deinit {
        unsubscribe()
    }
    
    func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }
    
    func subscribe() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection(Item.collectionName).addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self?.items = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Item.self)
                }
            }
        }
    }
    
    func removeItems(atOffsets indexSet: IndexSet) {
        let itemsToDelete = indexSet.lazy.compactMap { [weak self] in self?.items[$0] }
        itemsToDelete.forEach { item in
            if let documentID = item.id {
                db.collection(Item.collectionName).document(documentID).delete { error in
                    if let error = error {
                        print("Unable to remove item:\(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
