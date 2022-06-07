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
                
                Text(item.price, format: .currency(code: Locale.current.currencySymbol!))
            }
            Section(header: Text("Image")) {
                    AnimatedImage(url: URL(string: item.image))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 400)
                        .cornerRadius(20)
                        .alignmentGuide(HorizontalAlignment.center) { dimension in
                            dimension.width / 2
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
