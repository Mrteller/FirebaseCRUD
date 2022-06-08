import Foundation
import Combine
import FirebaseFirestore
//import FirebaseFirestoreSwift

class ItemsViewModel: ObservableObject {
    
    //    @FirestoreQuery(collectionPath: "products") var items: [ItemsModel]
    @Published var items = [ItemModel]()
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
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
            listenerRegistration = db.collection("products").addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self?.items = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: ItemModel.self)
                }
            }
        }
    }
    
//    func removeItems(atOffsets indexSet: IndexSet) {
//        let itemsToDelete = indexSet.lazy.map { items[$0] }
//        itemsToDelete.forEach { item in
//            if let documentID = item.id {
//                db.collection("products").document(documentID).delete { error in
//                    if let error = error {
//                        print("Unable to remove item:\(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
}
