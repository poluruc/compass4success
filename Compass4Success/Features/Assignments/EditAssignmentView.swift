import SwiftUI

private struct ClassSelectionButton: View {
    let schoolClass: SchoolClass
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
}

private struct GradeLevelButton: View {
    let grade: GradeLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
}

// MARK: - Main View
struct EditAssignmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var selectedClassIds: Set<String>
    @State private var selectedGradeLevels: Set<String>
    @State private var category: AssignmentCategory
    @State private var points: String
    @State private var selectedRubric: RubricTemplate?
    @State private var showingRubricPicker = false
    @State private var newResourceUrl: String = ""
    @State private var resourceUrls: [String]
    @State private var showingFilePicker = false
    
    let classes: [SchoolClass]
    let rubrics: [RubricTemplate]
    let originalAssignment: Assignment
    let onSave: (Assignment) -> Void
    let onCancel: () -> Void
    
    init(assignment: Assignment, classes: [SchoolClass], rubrics: [RubricTemplate], onSave: @escaping (Assignment) -> Void, onCancel: @escaping () -> Void) {
        self.originalAssignment = assignment
        self.classes = classes.isEmpty ? mockClasses : classes
        self.rubrics = rubrics
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: assignment.title)
        _description = State(initialValue: assignment.assignmentDescription)
        _dueDate = State(initialValue: assignment.dueDate)
        _selectedClassIds = State(initialValue: Set(assignment.classIds))
        _selectedGradeLevels = State(initialValue: Set(assignment.gradeLevels))
        _category = State(initialValue: AssignmentCategory(rawValue: assignment.category) ?? .assignment)
        _points = State(initialValue: String(Int(assignment.totalPoints)))
        if let rubricId = assignment.rubricId, let rubric = rubrics.first(where: { $0.id == rubricId }) {
            _selectedRubric = State(initialValue: rubric)
        } else {
            _selectedRubric = State(initialValue: nil)
        }
        _resourceUrls = State(initialValue: Array(assignment.resourceUrls))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AssignmentBasicDetailsView(title: $title, description: $description)
                    ClassSelectionView(classes: classes, selectedClassIds: $selectedClassIds)
                    GradeLevelSelectionView(selectedGradeLevels: $selectedGradeLevels)
                    AssignmentMetadataView(category: $category, points: $points, dueDate: $dueDate)
                    
                    // Resources
                    AssignmentResourcesView(
                        resourceUrls: $resourceUrls,
                        newResourceUrl: $newResourceUrl,
                        showingFilePicker: $showingFilePicker
                    )
                    
                    RubricSelectionView(
                        rubrics: rubrics,
                        selectedRubric: $selectedRubric,
                        showingRubricPicker: $showingRubricPicker
                    )
                }
                .padding()
            }
            .navigationTitle("Edit Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel") { onCancel(); dismiss() } 
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAssignment()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingRubricPicker) {
                RubricPickerView(rubrics: rubrics) { rubric in
                    selectedRubric = rubric
                }
            }
        }
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

    private func saveAssignment() {
        guard let totalPoints = Double(points) else { return }
        let updated = originalAssignment
        updated.title = title
        updated.assignmentDescription = description
        updated.dueDate = dueDate
        updated.category = category.rawValue
        updated.totalPoints = totalPoints
        updated.rubricId = selectedRubric?.id
        updated.classIds.removeAll()
        updated.classIds.append(objectsIn: Array(selectedClassIds))
        updated.gradeLevels.removeAll()
        updated.gradeLevels.append(objectsIn: Array(selectedGradeLevels))
        updated.resourceUrls.removeAll()
        updated.resourceUrls.append(objectsIn: resourceUrls)
        onSave(updated)
        dismiss()
    }
}

// Make sure mockClasses is available
private let mockClasses: [SchoolClass] = [
    SchoolClass(id: "1", name: "Math 9A", clazzCode: "M9A", courseCode: "MTH9A", gradeLevel: "9"),
    SchoolClass(id: "2", name: "Science 10B", clazzCode: "S10B", courseCode: "SCI10B", gradeLevel: "10"),
    SchoolClass(id: "3", name: "English 11C", clazzCode: "E11C", courseCode: "ENG11C", gradeLevel: "11"),
    SchoolClass(id: "4", name: "History 9/10", clazzCode: "H910", courseCode: "HIST910", gradeLevel: "9,10")
]

// Add these new view components before EditAssignmentView
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
