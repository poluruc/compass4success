import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct AssignmentsAddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(86400 * 7)
    @State private var selectedClassIds = Set<String>()
    @State private var selectedGradeLevels = Set<String>()
    @State private var category = AssignmentCategory.assignment
    @State private var points = "100"
    @State private var selectedRubric: RubricTemplate? = nil
    @State private var showingRubricPicker = false
    @State private var newResourceUrl: String = ""
    @State private var resourceUrls: [String] = []
    @State private var showingFilePicker = false
    
    let classes: [SchoolClass]
    let rubrics = RubricLoader.loadAllRubrics()
    
    var body: some View {
        // NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        TextField("Title", text: $title)
                            .appTextFieldStyle()
                        TextField("Description", text: $description)
                            .appTextFieldStyle()
                    }

                    // Classes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Classes").font(.caption).foregroundColor(.secondary)
                        WrapHStack(items: classes, id: \.id) { schoolClass in
                            let isSelected = selectedClassIds.contains(schoolClass.id)
                            Button(action: {
                                if isSelected { selectedClassIds.remove(schoolClass.id) }
                                else { selectedClassIds.insert(schoolClass.id) }
                            }) {
                                HStack(spacing: 6) {
                                    if isSelected { Image(systemName: "checkmark").font(.caption) }
                                    Text(schoolClass.name).fontWeight(isSelected ? .semibold : .regular)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                                .foregroundColor(isSelected ? .white : .accentColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.accentColor, lineWidth: isSelected ? 0 : 1)
                                )
                                .cornerRadius(18)
                                .shadow(color: isSelected ? Color.accentColor.opacity(0.15) : .clear, radius: 4, x: 0, y: 2)
                                .animation(.easeInOut(duration: 0.15), value: isSelected)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                        if selectedClassIds.isEmpty {
                            Text("No Class Assigned")
                                .font(.caption2)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }

                    // Grades
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Grade Levels").font(.caption).foregroundColor(.secondary)
                        WrapHStack(items: GradeLevel.allCases, id: \.self) { grade in
                            let isSelected = selectedGradeLevels.contains(grade.rawValue)
                            Button(action: {
                                if isSelected { selectedGradeLevels.remove(grade.rawValue) }
                                else { selectedGradeLevels.insert(grade.rawValue) }
                            }) {
                                HStack(spacing: 6) {
                                    if isSelected { Image(systemName: "checkmark").font(.caption) }
                                    Text(grade.rawValue).fontWeight(isSelected ? .semibold : .regular)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.green : Color(.systemGray6))
                                .foregroundColor(isSelected ? .white : .green)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.green, lineWidth: isSelected ? 0 : 1)
                                )
                                .cornerRadius(18)
                                .shadow(color: isSelected ? Color.green.opacity(0.15) : .clear, radius: 4, x: 0, y: 2)
                                .animation(.easeInOut(duration: 0.15), value: isSelected)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                        if selectedGradeLevels.isEmpty {
                            Text("No Grade Level")
                                .font(.caption2)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }

                    // Category, Points, Due Date
                    HStack(spacing: 8) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                .foregroundColor(category.color)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 24, height: 24)
                                .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                            Picker("Category", selection: $category) {
                                ForEach(AssignmentCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(category.color)
                            .font(.headline)
                        }
                    }

                    HStack {
                        Text("Points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Points", text: $points)
                            .keyboardType(.numberPad)
                            .appTextFieldStyle()
                    }

                    HStack {
                        Text("Due Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }

                    // Resources
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resources").font(.caption).foregroundColor(.secondary)
                        ForEach(resourceUrls, id: \.self) { url in
                            HStack {
                                if isImage(url: url) {
                                    if let urlObj = URL(string: url) {
                                        if urlObj.isFileURL, let uiImage = loadLocalImage(from: url) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else {
                                            AsyncImage(url: urlObj) { phase in
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
                                } else {
                                    Image(systemName: "doc.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.blue)
                                }
                                Text(url)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                                Button(action: {
                                    resourceUrls.removeAll { $0 == url }
                                }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }
                            }
                        }
                        HStack {
                            TextField("Add file/link URL", text: $newResourceUrl)
                            Button(action: {
                                guard !newResourceUrl.isEmpty else { return }
                                resourceUrls.append(newResourceUrl)
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
                        .sheet(isPresented: $showingFilePicker) {
                            DocumentPicker { url in
                                resourceUrls.append(url.absoluteString)
                            }
                        }
                    }

                    // Rubric
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rubric").font(.caption).foregroundColor(.secondary)
                        if let rubric = selectedRubric {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rubric.title)
                                    .font(.headline)
                                Text(rubric.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("No rubric selected")
                                .foregroundColor(.secondary)
                        }
                        Button(action: { showingRubricPicker = true }) {
                            Text(selectedRubric == nil ? "Select Rubric" : "Change Rubric")
                        }
                    }
                    .sheet(isPresented: $showingRubricPicker) {
                        RubricPickerView(rubrics: rubrics) { rubric in
                            selectedRubric = rubric
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Add Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save logic here
                        let assignment = Assignment()
                        assignment.title = title
                        assignment.assignmentDescription = description
                        assignment.dueDate = dueDate
                        assignment.category = category.rawValue
                        assignment.totalPoints = Double(points) ?? 100
                        assignment.classIds.append(objectsIn: Array(selectedClassIds))
                        assignment.gradeLevels.append(objectsIn: Array(selectedGradeLevels))
                        assignment.resourceUrls.removeAll()
                        assignment.resourceUrls.append(objectsIn: resourceUrls)
                        assignment.rubricId = selectedRubric?.id
                        // TODO: handle rubricId and pass assignment to parent if needed
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedClassIds.isEmpty)
                }
            }
        // }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first { onPick(url) }
        }
    }
}

// Helper to detect image URLs
func isImage(url: String) -> Bool {
    let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic", "heif", "webp"]
    return imageExtensions.contains { url.lowercased().hasSuffix($0) }
}

// Helper to load local images
func loadLocalImage(from urlString: String) -> UIImage? {
    guard let url = URL(string: urlString), url.isFileURL else { return nil }
    return UIImage(contentsOfFile: url.path)
}

// Improved WrapHStack with dynamic height measurement
struct WrapHStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    let items: Data
    let id: KeyPath<Data.Element, ID>
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    init(items: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.id = id
        self.content = content
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: id) { item in
                content(item)
                    .padding([.horizontal, .vertical], 2)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item[keyPath: id] == items.last?[keyPath: id] {
                            width = 0 // Last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item[keyPath: id] == items.last?[keyPath: id] {
                            height = 0 // Last item
                        }
                        return result
                    })
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { self.totalHeight = $0 }
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
