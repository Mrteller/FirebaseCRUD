import Foundation
import FirebaseFirestoreSwift

struct ItemsModel: Identifiable, Codable {
    
    @DocumentID var id: String?
    var title: String
    var price: Int
    var image: String
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case price = "price"
//        case image
//    }
}
