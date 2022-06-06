import Foundation
import FirebaseFirestoreSwift

struct ItemsModel: Identifiable, Codable {
    // TODO: Find out about best practices dealing with `@DocumentID`
    @DocumentID var id = UUID().uuidString
    var title: String
    var price: Int
    var image: String
    
}
