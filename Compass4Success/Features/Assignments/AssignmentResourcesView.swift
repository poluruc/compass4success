import SwiftUI

public struct AssignmentResourcesView: View {
    @Binding var resourceUrls: [String]
    @Binding var newResourceUrl: String
    @Binding var showingFilePicker: Bool
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resources").font(.caption).foregroundColor(.secondary)
            
            ForEach(resourceUrls, id: \.self) { url in
                ResourceItemView(url: url) {
                    resourceUrls.removeAll { $0 == url }
                }
            }
            
            ResourceInputView(
                newResourceUrl: $newResourceUrl,
                showingFilePicker: $showingFilePicker,
                onAddResource: { url in
                    resourceUrls.append(url)
                }
            )
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker { url in
                    resourceUrls.append(url.absoluteString)
                }
            }
        }
    }
    
    public init(resourceUrls: Binding<[String]>, newResourceUrl: Binding<String>, showingFilePicker: Binding<Bool>) {
        self._resourceUrls = resourceUrls
        self._newResourceUrl = newResourceUrl
        self._showingFilePicker = showingFilePicker
    }
}

private struct ResourceItemView: View {
    let url: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            ResourceThumbnailView(url: url)
            Text(url)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash").foregroundColor(.red)
            }
        }
    }
}

private struct ResourceThumbnailView: View {
    let url: String
    
    var body: some View {
        Group {
            if isImage(url: url) {
                ImageThumbnailView(url: url)
            } else {
                DocumentThumbnailView()
            }
        }
    }
    
    private func isImage(url: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic"]
        return imageExtensions.contains { url.lowercased().hasSuffix($0) }
    }
}

private struct ImageThumbnailView: View {
    let url: String
    
    var body: some View {
        Group {
            if let urlObj = URL(string: url) {
                if urlObj.isFileURL, let uiImage = loadLocalImage(from: url) {
                    LocalImageView(image: uiImage)
                } else {
                    RemoteImageView(url: urlObj)
                }
            }
        }
    }
}

private struct LocalImageView: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct RemoteImageView: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 40, height: 40)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}

private struct DocumentThumbnailView: View {
    var body: some View {
        Image(systemName: "doc.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
            .foregroundColor(.blue)
    }
}

private struct ResourceInputView: View {
    @Binding var newResourceUrl: String
    @Binding var showingFilePicker: Bool
    let onAddResource: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Add file/link URL", text: $newResourceUrl)
                    .appTextFieldStyle()
                Button(action: {
                    guard !newResourceUrl.isEmpty else { return }
                    onAddResource(newResourceUrl)
                    newResourceUrl = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            
            Button {
                showingFilePicker = true
            } label: {
                Label("Attach File", systemImage: "paperclip")
            }
        }
    }
}

// MARK: - Preview Provider
struct AssignmentResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentResourcesView(
            resourceUrls: .constant([
                "https://example.com/image.jpg",
                "https://example.com/document.pdf"
            ]),
            newResourceUrl: .constant(""),
            showingFilePicker: .constant(false)
        )
        .padding()
    }
} 
