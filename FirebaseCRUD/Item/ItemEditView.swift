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
    // TODO: choose between @StateObject and @ObservedObject
    @StateObject var viewModel = ItemViewModel()
    
    var mode: Mode = .new
    var completionHandler: ((Result<Action, Error>) -> Void)?
    
    @State private var image = UIImage()
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    private var saveButton: some View {
        Button(mode == .new ? "Done" : "Save", action: handleDoneTapped)
            .disabled(!viewModel.modified || viewModel.isLoadingImage)
            .buttonStyle(ProgressButtonStyle(isLoading: viewModel.isLoadingImage))
    }
    
    private var cancelButton: some View {
        Button("Cancel", role: .cancel, action: handleCancelTapped)
    }
    
    private func mediaButton(_ source: UIImagePickerController.SourceType) -> some View {
        Button {
            sourceType = source
            isShowingImagePicker = true
        } label: {
            Image(systemName: source == .camera ? "camera" : "photo.on.rectangle")
                .symbolVariant(.fill)
                .frame(maxWidth: .infinity)
        }
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
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .alignmentGuide(HorizontalAlignment.center) { dimension in
                            dimension.width / 2
                        }
                    
                    HStack {
                        mediaButton(.camera)
                        mediaButton(.photoLibrary)
                    }
                    .font(.title)
                    .buttonStyle(.bordered)
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
        .interactiveDismissDisabled(viewModel.isLoadingImage)
        // TODO: replace with confirmation dialog
        .actionSheet(isPresented: $presentActionSheet) {
            ActionSheet(title: Text("Are you sure?"),
                        buttons: [
                            .destructive(Text("Delete Item"), action: handleDeleteTapped),
                            .cancel()
                        ])
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $image).id(sourceType.rawValue)
        }
        .onChange(of: image) { newValue in
            Task {
                await viewModel.update(image: newValue)
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
