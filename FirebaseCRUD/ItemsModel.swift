import Foundation
import FirebaseFirestoreSwift

struct ItemsModel: Identifiable, Codable {
    
    @DocumentID var id = UUID().uuidString
    var title: String
    var price: Int
    var image: String
    
}
