import Foundation
import Combine
import FirebaseFirestore
//import FirebaseFirestoreSwift

protocol ItemsViewModelProtocol: AnyObject {
    associatedtype ItemModelType: Codable
    var items: [ItemModelType] {get set}
    var listenerRegistration: ListenerRegistration? {get set}
    func subscribe()
    func unsubscribe()
}

extension ItemsViewModelProtocol {
    
    //    @FirestoreQuery(collectionPath: "products") var items: [ItemsModel]
    
    private var itemTypeName: String {
        let name = String(describing: ItemModelType.self)
        print(name)
        return name
    }
    
    func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }
    
    func subscribe() {
        if listenerRegistration == nil {
            listenerRegistration = Firestore.firestore().collection(itemTypeName).addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self?.items = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: ItemModelType.self)
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

final class ItemsViewModel: ObservableObject, ItemsViewModelProtocol {
    @Published var items = [ItemModel]()
    var listenerRegistration: ListenerRegistration?
}
