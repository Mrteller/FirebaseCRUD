//https://www.youtube.com/watch?v=fZQK3AnV2r4&t=189s

import SwiftUI
import Firebase
import SDWebImageSwiftUI

//import FirebaseFirestoreSwift

struct ItemsView: View {
    
    @StateObject private var viewModel = ItemsViewModel()
    @State private var presentAddItemSheet = false
    //@FirestoreQuery(collectionPath: "products") var items: [ItemsModel]
        
    struct ItemRowView: View {
        let item: ItemModel
        var body: some View {
            NavigationLink(destination: ItemDetailView(item: item)) {
                VStack(alignment: .leading) {
                    HStack {
                        AnimatedImage(url: URL(string: item.image))
                            .resizable()
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                        
                        Text(item.title)
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach (viewModel.items) { item in
                    ItemRowView(item: item)
                }
            }
            .sheet(isPresented: $presentAddItemSheet) {
                ItemEditView()
            }
            .onAppear() {
                print("ItemsList")
                viewModel.subscribe()
            }
            .navigationViewStyle(.automatic)
            .navigationTitle("Items Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentAddItemSheet.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
