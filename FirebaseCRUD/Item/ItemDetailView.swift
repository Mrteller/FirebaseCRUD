import SwiftUI
import SDWebImageSwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var presentEditItemSheet = false
    
    var item: ItemModel
    
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
                AnimatedImage(url: URL(string: item.imageURL))
                //                        .resizable()
                //                        .aspectRatio(contentMode: .fill)
                    .fitToAspect()
                    .frame(maxHeight: 200)
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


struct FitToAspectRatio: ViewModifier {
    
    let aspectRatio: Double
    let contentMode: SwiftUI.ContentMode
    
    func body(content: Content) -> some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(
                content.aspectRatio(nil, contentMode: contentMode)
            )
            .clipped()
    }
    
}

extension AnimatedImage {
    func fitToAspect(_ aspectRatio: Double = 1, contentMode: SwiftUI.ContentMode = .fill) -> some View {
        self.resizable()
            .scaledToFill()
            .modifier(FitToAspectRatio(aspectRatio: aspectRatio, contentMode: contentMode))
    }
}
