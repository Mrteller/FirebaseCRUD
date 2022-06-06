import SwiftUI
import SDWebImageSwiftUI

enum Mode {
    case new
    case edit
}

enum Action {
    case delete
    case done
    case cancel
}


struct ItemEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var presentActionSheet = false
    
    @ObservedObject var viewModel = ItemViewModel()
    
    var mode: Mode = .new
    var completionHandler: ((Result<Action, Error>) -> Void)?
    
    @State private var image = UIImage()
    @State private var isShowingImagePicker = false
    @State private var isLoadingImage = false
    
    var saveButton: some View {
        Button(mode == .new ? "Done" : "Save", action: handleDoneTapped)
        .disabled(!viewModel.modified || isLoadingImage)
    }
    
    var cancelButton: some View {
        Button("Cancel", role: .cancel, action: handleCancelTapped)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Information")) {
                    TextField("Titile", text: $viewModel.item.title)
                    TextField("Price", value: $viewModel.item.price, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Image")) {
                    TextField("Image", text: $viewModel.item.image)
                    
                    AnimatedImage(url: URL(string: viewModel.item.image))
                        .resizable()
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                    
                    Button("Get") {
                        isShowingImagePicker = true
                    }
                }
                
                //MARK: - delete
                if mode == .edit {
                    Section("Delete items") {
                        Button("Delete", role: .destructive) { presentActionSheet.toggle() }
                    }
                }
            }
            .navigationTitle(mode == .new ? "New title" : viewModel.item.title)
            .navigationViewStyle(.automatic)
            .navigationBarTitleDisplayMode(mode == .new ? .inline : .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
            }
        }
        .interactiveDismissDisabled(isLoadingImage)
        // TODO: replace with confirmation dialog
        .actionSheet(isPresented: $presentActionSheet) {
            ActionSheet(title: Text("Are you sure?"),
                        buttons: [
                            .destructive(Text("Delete Item"), action: handleDeleteTapped),
                            .cancel()
                        ])
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
        }
        .onChange(of: image) { newValue in
            Task {
                isLoadingImage = true
                // TODO: make `viewModel.item.id` non Optional?
                // make `upload(image...)` throwing?
                // move to viewModel
                guard let url = await StorageManager().upload(image: image, name: viewModel.item.id ?? "untitled")
                else {
                    isLoadingImage = false
                    return
                }
                viewModel.updateItemImage(url: url.absoluteString)
                isLoadingImage = false
            }
        }
    }
    func handleDeleteTapped() {
        viewModel.handleDeleteTapped()
        dismiss()
        completionHandler?(.success(.delete))
    }
    
    func handleDoneTapped() {
        viewModel.handleDoneTapped()
        dismiss()
    }
    
    func handleCancelTapped() {
        if mode == .new {
            viewModel.handleCancelTapped()
        }
        dismiss()
    }
    
}
