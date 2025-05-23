import RealmSwift
import SwiftUI
import UIKit
import UniformTypeIdentifiers

// Mock data for previews
private let mockClasses: [SchoolClass] = [
    SchoolClass(id: "1", name: "Math 9A", clazzCode: "M9A", courseCode: "MTH9A", gradeLevel: "9"),
    SchoolClass(
        id: "2", name: "Science 10B", clazzCode: "S10B", courseCode: "SCI10B", gradeLevel: "10"),
    SchoolClass(
        id: "3", name: "English 11C", clazzCode: "E11C", courseCode: "ENG11C", gradeLevel: "11"),
    SchoolClass(
        id: "4", name: "History 9/10", clazzCode: "H910", courseCode: "HIST910", gradeLevel: "9,10"),
]

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
                // Basic Details
                AssignmentBasicDetailsView(title: $title, description: $description)

                // Class Selection
                ClassSelectionView(classes: classes, selectedClassIds: $selectedClassIds)

                // Grade Level Selection
                GradeLevelSelectionView(selectedGradeLevels: $selectedGradeLevels)

                // Assignment Metadata
                AssignmentMetadataView(
                    category: $category,
                    points: $points,
                    dueDate: $dueDate
                )

                // Resources
                AssignmentResourcesView(
                    resourceUrls: $resourceUrls,
                    newResourceUrl: $newResourceUrl,
                    showingFilePicker: $showingFilePicker
                )

                // Rubric Selection
                RubricSelectionView(
                    rubrics: rubrics,
                    selectedRubric: $selectedRubric,
                    showingRubricPicker: $showingRubricPicker
                )
            }
            .padding()
        }
        .navigationTitle("New Assignment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createAssignment()
                }
                .disabled(!isValid)
            }
        }
        .sheet(isPresented: $showingRubricPicker) {
            RubricPickerView(rubrics: rubrics) { rubric in
                selectedRubric = rubric
            }
        }
        // }
    }

    private var isValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasClass = !selectedClassIds.isEmpty
        let hasValidPoints = Double(points) != nil
        if selectedRubric != nil {
            return hasTitle && hasClass
        }
        return hasTitle && hasClass && hasValidPoints
    }

    private func createAssignment() {
        guard let totalPoints = Double(points) else { return }

        let assignment = Assignment()
        assignment.title = title
        assignment.assignmentDescription = description
        assignment.dueDate = dueDate
        assignment.category = category.rawValue
        assignment.totalPoints = totalPoints
        assignment.rubricId = selectedRubric?.id
        assignment.classIds.append(objectsIn: Array(selectedClassIds))
        assignment.gradeLevels.append(objectsIn: Array(selectedGradeLevels))
        assignment.resourceUrls.append(objectsIn: resourceUrls)

        // Save the assignment to Realm
        let realm = try! Realm()
        try! realm.write {
            realm.add(assignment)
        }
        dismiss()
    }
}

// MARK: - Preview Provider
struct AssignmentsAddView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentsAddView(classes: mockClasses)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [UTType.data], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController, context: Context
    ) {}
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        func documentPicker(
            _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
        ) {
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

struct CategoryPicker: View {
    @Binding var selectedCategory: AssignmentCategory
    @State private var showPicker = false

    var body: some View {
        Button {
            showPicker = true
        } label: {
            HStack {
                Image(systemName: selectedCategory.iconName)
                    .foregroundColor(selectedCategory.color)
                Text(selectedCategory.rawValue)
                    .foregroundColor(selectedCategory.color)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showPicker) {
            VStack(spacing: 0) {
                Text("Choose Category")
                    .font(.headline)
                    .padding()

                List {
                    ForEach(AssignmentCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            showPicker = false
                        }) {
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                                    .foregroundColor(category.color)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(category.color)
                                }
                            }
                            .contentShape(Rectangle())  // 🔥 makes the full row tappable
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(PlainButtonStyle())  // removes default blue highlight
                    }
                }
            }
            .padding(.vertical, 10)
            .presentationDetents([.medium, .large])
        }
    }
}

// Improved WrapHStack with dynamic height measurement
struct WrapHStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    let items: Data
    let id: KeyPath<Data.Element, ID>
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    init(
        items: Data, id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
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
                    .alignmentGuide(
                        .leading,
                        computeValue: { d in
                            if abs(width - d.width) > geometry.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if item[keyPath: id] == items.last?[keyPath: id] {
                                width = 0  // Last item
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                    )
                    .alignmentGuide(
                        .top,
                        computeValue: { _ in
                            let result = height
                            if item[keyPath: id] == items.last?[keyPath: id] {
                                height = 0  // Last item
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
