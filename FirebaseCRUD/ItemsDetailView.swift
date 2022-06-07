import SwiftUI
import SDWebImageSwiftUI

struct ItemsDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var presentEditItemSheet = false
    
    var item: ItemsModel
    
    private func editButton(action: @escaping () -> Void) -> some View {
        Button(action: { action() }) {
            Text("Edit")
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                Text(item.title)
            }
            Section(header: Text("Price")) {
                
                Text("\(item.price)$")
            }
            Section(header: Text("Image")) {
                HStack {
                    Spacer()
                    AnimatedImage(url: URL(string: item.image))
                        .resizable()
                        .frame(width: 255, height: 255)
                    Spacer()
                }
            }
        }
            
        
        .navigationTitle(item.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                editButton {
                    presentEditItemSheet.toggle()
                }
            }
        }
        .onAppear() {
            print(#file + " " + #function + " for \(item.title)")

        }
        .onDisappear() {
            print("ItemDetailView.onDisappear()")
        }
        .sheet(isPresented: $presentEditItemSheet) {
            ItemEditView(viewModel: ItemViewModel(item: item), mode: .edit) { result in
                if case .success(let action) = result, action == .delete {
                    dismiss()
                }
            }
        }
    }
}
