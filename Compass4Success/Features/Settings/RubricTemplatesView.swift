import SwiftUI
import RealmSwift

// MARK: - View Models
class RubricTemplatesViewModel: ObservableObject {
    @Published var templates: [Rubric] = []
    private let saveKey = "savedRubricTemplates"
    
    init() {
        loadTemplates()
    }
    
    private func loadTemplates() {
        // Realm objects are not Codable; just use sampleTemplates for now
        templates = Rubric.sampleTemplates
    }
    
    func saveTemplates() {
        // No-op for now; implement Realm or other persistence if needed
    }
    
    func addTemplate(_ template: Rubric) {
        templates.append(template)
        saveTemplates()
    }
    
    func updateTemplate(_ template: Rubric) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    func deleteTemplate(_ template: Rubric) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
}

// MARK: - Views
struct RubricTemplatesView: View {
    @StateObject private var viewModel = RubricTemplatesViewModel()
    @State private var editingTemplate: IdentifiableRubric? = nil
    @State private var showingJSON: IdentifiableRubric? = nil
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: Rubric? = nil
    @State private var searchText = ""
    @State private var filteredTemplates: [Rubric] = []
    
    var body: some View {
        RubricTemplateListView(
            templates: filteredTemplates,
            onAction: handleTemplateAction
        )
        .onAppear(perform: filterTemplates)
        .onChange(of: searchText) { _ in filterTemplates() }
        .searchable(text: $searchText, prompt: "Search templates")
        .navigationTitle("Rubric Templates")
        .toolbar { toolbarContent }
        .modifier(editingSheet(editingTemplate: $editingTemplate, viewModel: viewModel))
        .modifier(jsonSheet(showingJSON: $showingJSON))
        .alert("Delete Template", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let template = templateToDelete {
                    viewModel.deleteTemplate(template)
                }
            }
        } message: {
            Text("Are you sure you want to delete this template? This action cannot be undone.")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button(action: { createAndEditManagedRubric(from: Rubric.empty) }) {
                    Label("New Template", systemImage: "plus")
                }
                Button(action: { createAndEditManagedRubric(from: Rubric.sampleWriting) }) {
                    Label("From Writing Template", systemImage: "doc.text")
                }
                Button(action: { createAndEditManagedRubric(from: Rubric.sampleMath) }) {
                    Label("From Math Template", systemImage: "function")
                }
                Button(action: { createAndEditManagedRubric(from: Rubric.sampleScience) }) {
                    Label("From Science Template", systemImage: "atom")
                }
            } label: {
                Label("New Template", systemImage: "plus")
            }
        }
    }

    private func createAndEditManagedRubric(from template: Rubric) {
        let realm = try! Realm()
        // If already managed, just use it
        if template.realm != nil {
            editingTemplate = IdentifiableRubric(template)
            return
        }
        // Deep copy to avoid Realm errors if template is a static sample
        let rubric = deepCopyRubric(template)
        try! realm.write {
            // Add rubric and all children to Realm
            realm.add(rubric)
            for criterion in rubric.criteria {
                realm.add(criterion)
                for level in criterion.levels {
                    realm.add(level)
                }
            }
        }
        editingTemplate = IdentifiableRubric(rubric)
    }

    private func editingSheet(editingTemplate: Binding<IdentifiableRubric?>, viewModel: RubricTemplatesViewModel) -> some ViewModifier {
        SheetModifier(editingTemplate: editingTemplate, viewModel: viewModel)
    }

    private func jsonSheet(showingJSON: Binding<IdentifiableRubric?>) -> some ViewModifier {
        JSONSheetModifier(showingJSON: showingJSON)
    }
    
    private func filterTemplates() {
        if searchText.isEmpty {
            filteredTemplates = viewModel.templates
        } else {
            let lowerSearch = searchText.lowercased()
            var result: [Rubric] = []
            for template in viewModel.templates {
                if template.name.localizedCaseInsensitiveContains(lowerSearch) ||
                    template.rubricdDscription.localizedCaseInsensitiveContains(lowerSearch) {
                    result.append(template)
                }
            }
            filteredTemplates = result
        }
    }

    private func handleTemplateAction(_ template: Rubric, _ action: RubricAction) {
        switch action {
        case .edit:
            // Ensure managed before editing
            if template.realm != nil {
                editingTemplate = IdentifiableRubric(template)
            } else {
                createAndEditManagedRubric(from: template)
            }
        case .copy:
            let copy = deepCopyRubric(template)
            let realm = try! Realm()
            try! realm.write {
                realm.add(copy)
                for criterion in copy.criteria {
                    realm.add(criterion)
                    for level in criterion.levels {
                        realm.add(level)
                    }
                }
            }
            viewModel.addTemplate(copy)
        case .json:
            showingJSON = IdentifiableRubric(template)
        case .delete:
            templateToDelete = template
            showingDeleteAlert = true
        }
    }
}

struct RubricTemplateListView: View {
    let templates: [Rubric]
    let onAction: (Rubric, RubricAction) -> Void
    var body: some View {
        List {
            ForEach(Array(templates), id: \.id) { template in
                RubricTemplateRow(template: template) { action in
                    onAction(template, action)
                }
            }
        }
    }
}

struct RubricTemplateRow: View {
    let template: Rubric
    let onAction: (RubricAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TemplateHeaderView(template: template, onAction: onAction)
            TemplateCriteriaScrollView(template: template)
        }
        .padding(.vertical, 8)
    }
}

private struct TemplateHeaderView: View {
    let template: Rubric
    let onAction: (RubricAction) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.system(size: 17, weight: .semibold))
                Text(template.rubricdDscription)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
            TemplateActionMenu(onAction: onAction)
        }
    }
}

private struct TemplateActionMenu: View {
    let onAction: (RubricAction) -> Void
    
    var body: some View {
        Menu {
            Button(action: { onAction(.edit) }) {
                Label("Edit", systemImage: "pencil")
            }
            Button(action: { onAction(.copy) }) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            Button(action: { onAction(.json) }) {
                Label("View JSON", systemImage: "doc.text")
            }
            Button(role: .destructive, action: { onAction(.delete) }) {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.blue)
        }
    }
}

private struct TemplateCriteriaScrollView: View {
    let template: Rubric
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(template.criteria), id: \.id) { criterion in
                    CriterionCard(criterion: criterion)
                }
            }
        }
    }
}

struct CriterionCard: View {
    let criterion: RubricCriterion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CriterionHeaderView(name: criterion.name)
            CriterionLevelsView(levels: Array(criterion.levels), criterionPoints: criterion.points)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .frame(width: 260)
        .frame(minHeight: 260)
    }
}

private struct CriterionHeaderView: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 15, weight: .semibold))
    }
}

private struct CriterionLevelsView: View {
    let levels: [RubricLevel]
    let criterionPoints: Double
    
    var body: some View {
        ForEach(levels, id: \.id) { level in
            CriterionLevelRow(level: level, criterionPoints: criterionPoints)
        }
    }
}

private struct CriterionLevelRow: View {
    let level: RubricLevel
    let criterionPoints: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 15))
                Text("Level \(level.level)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.accentColor)
                Spacer()
                Text("\(level.calculatePoints(forCriterionPoints: criterionPoints), specifier: "%.1f") pts")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.blue)
            }
            Text(level.rubricLevelDescription)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 220, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Supporting Types
enum RubricAction {
    case edit, copy, json, delete
}

// MARK: - Data Models
extension Rubric {
    static var sampleWriting: Rubric {
        let rubric = Rubric()
        rubric.name = "Writing Assessment"
        rubric.rubricdDscription = "Comprehensive writing rubric for essays and reports"
        rubric.totalPoints = 100.0
        rubric.criteria.removeAll()

        let content = RubricCriterion()
        content.name = "Content & Ideas"
        content.rubricdDscription = "Clear thesis, well-developed ideas, strong evidence"
        content.points = 25.0
        content.levels.append(objectsIn: [
            {
                let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Clear thesis, well-developed ideas, strong evidence"; l.percentage = 1.0; return l
            }(),
            {
                let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Clear thesis, adequate development, some evidence"; l.percentage = 0.8; return l
            }(),
            {
                let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Unclear thesis, limited development, weak evidence"; l.percentage = 0.5; return l
            }(),
            {
                let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: No clear thesis, poor development, no evidence"; l.percentage = 0.2; return l
            }()
        ])

        let org = RubricCriterion()
        org.name = "Organization"
        org.rubricdDscription = "Logical flow, clear transitions, strong structure"
        org.points = 25.0
        org.levels.append(objectsIn: [
            {
                let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Logical flow, clear transitions, strong structure"; l.percentage = 1.0; return l
            }(),
            {
                let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Clear structure, some transitions"; l.percentage = 0.8; return l
            }(),
            {
                let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Weak structure, few transitions"; l.percentage = 0.5; return l
            }(),
            {
                let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: No clear structure, confusing"; l.percentage = 0.2; return l
            }()
        ])

        let lang = RubricCriterion()
        lang.name = "Language & Style"
        lang.rubricdDscription = "Precise vocabulary, varied sentences, engaging style"
        lang.points = 25.0
        lang.levels.append(objectsIn: [
            {
                let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Precise vocabulary, varied sentences, engaging style"; l.percentage = 1.0; return l
            }(),
            {
                let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Appropriate vocabulary, some sentence variety"; l.percentage = 0.8; return l
            }(),
            {
                let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Basic vocabulary, simple sentences"; l.percentage = 0.5; return l
            }(),
            {
                let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Limited vocabulary, repetitive sentences"; l.percentage = 0.2; return l
            }()
        ])

        let conv = RubricCriterion()
        conv.name = "Conventions"
        conv.rubricdDscription = "Correct grammar, spelling, punctuation"
        conv.points = 25.0
        conv.levels.append(objectsIn: [
            {
                let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: No errors in grammar, spelling, punctuation"; l.percentage = 1.0; return l
            }(),
            {
                let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Few minor errors"; l.percentage = 0.8; return l
            }(),
            {
                let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Some errors, but meaning is clear"; l.percentage = 0.5; return l
            }(),
            {
                let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Frequent errors, meaning is unclear"; l.percentage = 0.2; return l
            }()
        ])

        rubric.criteria.append(objectsIn: [content, org, lang, conv])
        return rubric
    }
    
    static var sampleMath: Rubric {
        let rubric = Rubric()
        rubric.name = "Math Problem Solving"
        rubric.rubricdDscription = "Assessment rubric for mathematical problem-solving"
        rubric.totalPoints = 100.0
        rubric.criteria.removeAll()

        let understanding = RubricCriterion()
        understanding.name = "Understanding"
        understanding.rubricdDscription = "Complete understanding of concepts"
        understanding.points = 33.3
        understanding.levels.append(objectsIn: [
            { let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Complete understanding of concepts"; l.percentage = 1.0; return l }(),
            { let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Good understanding with minor gaps"; l.percentage = 0.8; return l }(),
            { let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Partial understanding"; l.percentage = 0.5; return l }(),
            { let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Limited understanding"; l.percentage = 0.2; return l }()
        ])

        let process = RubricCriterion()
        process.name = "Solution Process"
        process.rubricdDscription = "Clear, logical steps, appropriate methods"
        process.points = 33.3
        process.levels.append(objectsIn: [
            { let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Clear, logical steps, appropriate methods"; l.percentage = 1.0; return l }(),
            { let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Mostly clear steps, minor errors"; l.percentage = 0.8; return l }(),
            { let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Some unclear steps, several errors"; l.percentage = 0.5; return l }(),
            { let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Unclear process, major errors"; l.percentage = 0.2; return l }()
        ])

        let accuracy = RubricCriterion()
        accuracy.name = "Accuracy"
        accuracy.rubricdDscription = "All calculations correct"
        accuracy.points = 33.4
        accuracy.levels.append(objectsIn: [
            { let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: All calculations correct"; l.percentage = 1.0; return l }(),
            { let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Minor calculation errors"; l.percentage = 0.8; return l }(),
            { let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Several calculation errors"; l.percentage = 0.5; return l }(),
            { let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Major calculation errors"; l.percentage = 0.2; return l }()
        ])

        rubric.criteria.append(objectsIn: [understanding, process, accuracy])
        return rubric
    }
    
    static var sampleScience: Rubric {
        let rubric = Rubric()
        rubric.name = "Science Lab Report"
        rubric.rubricdDscription = "Comprehensive rubric for science laboratory reports"
        rubric.totalPoints = 100.0
        rubric.criteria.removeAll()

        let hypothesis = RubricCriterion()
        hypothesis.name = "Hypothesis"
        hypothesis.rubricdDscription = "Clear, testable, well-justified"
        hypothesis.points = 25.0
        hypothesis.levels.append(objectsIn: [
            { let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Clear, testable, well-justified"; l.percentage = 1.0; return l }(),
            { let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Testable, somewhat justified"; l.percentage = 0.8; return l }(),
            { let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Vague, limited justification"; l.percentage = 0.5; return l }(),
            { let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Missing or unclear"; l.percentage = 0.2; return l }()
        ])

        let methods = RubricCriterion()
        methods.name = "Methods"
        methods.rubricdDscription = "Detailed, reproducible, appropriate controls"
        methods.points = 25.0
        methods.levels.append(objectsIn: [
            { let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Detailed, reproducible, appropriate controls"; l.percentage = 1.0; return l }(),
            { let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Clear, mostly reproducible"; l.percentage = 0.8; return l }(),
            { let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Some details missing"; l.percentage = 0.5; return l }(),
            { let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Incomplete or unclear"; l.percentage = 0.2; return l }()
        ])

        let analysis = RubricCriterion()
        analysis.name = "Analysis"
        analysis.rubricdDscription = "Thorough analysis, clear conclusions"
        analysis.points = 25.0
        analysis.levels.append(objectsIn: [
            { let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Thorough analysis, clear conclusions"; l.percentage = 1.0; return l }(),
            { let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Good analysis, some conclusions"; l.percentage = 0.8; return l }(),
            { let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Basic analysis, weak conclusions"; l.percentage = 0.5; return l }(),
            { let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Limited analysis, no conclusions"; l.percentage = 0.2; return l }()
        ])

        let presentation = RubricCriterion()
        presentation.name = "Presentation"
        presentation.rubricdDscription = "Clear, logical, well-organized report"
        presentation.points = 25.0
        presentation.levels.append(objectsIn: [
            { let l = RubricLevel(); l.level = 4; l.rubricLevelDescription = "Excellent: Clear, logical, well-organized report"; l.percentage = 1.0; return l }(),
            { let l = RubricLevel(); l.level = 3; l.rubricLevelDescription = "Good: Mostly clear and organized"; l.percentage = 0.8; return l }(),
            { let l = RubricLevel(); l.level = 2; l.rubricLevelDescription = "Fair: Somewhat unclear or disorganized"; l.percentage = 0.5; return l }(),
            { let l = RubricLevel(); l.level = 1; l.rubricLevelDescription = "Needs Work: Unclear, poorly organized"; l.percentage = 0.2; return l }()
        ])

        rubric.criteria.append(objectsIn: [hypothesis, methods, analysis, presentation])
        return rubric
    }
    
    static var sampleTemplates: [Rubric] { [sampleWriting, sampleMath, sampleScience] }
}

// Helper to deep copy a Rubric
func deepCopyRubric(_ original: Rubric) -> Rubric {
    let copy = Rubric()
    copy.name = original.name + " (Copy)"
    copy.rubricdDscription = original.rubricdDscription
    copy.totalPoints = original.totalPoints
    copy.createdBy = original.createdBy
    copy.isShared = original.isShared
    copy.createdAt = Date()
    copy.lastModified = Date()
    for origCriterion in original.criteria {
        let criterionCopy = RubricCriterion()
        criterionCopy.name = origCriterion.name
        criterionCopy.rubricdDscription = origCriterion.rubricdDscription
        criterionCopy.points = origCriterion.points
        for origLevel in origCriterion.levels {
            let levelCopy = RubricLevel()
            levelCopy.level = origLevel.level
            levelCopy.rubricLevelDescription = origLevel.rubricLevelDescription
            levelCopy.percentage = origLevel.percentage
            criterionCopy.levels.append(levelCopy)
        }
        copy.criteria.append(criterionCopy)
    }
    return copy
}

// Helper wrapper for Identifiable Rubric
struct IdentifiableRubric: Identifiable {
    let id: String
    let rubric: Rubric
    init(_ rubric: Rubric) {
        self.id = rubric.id
        self.rubric = rubric
    }
}

private struct SheetModifier: ViewModifier {
    @Binding var editingTemplate: IdentifiableRubric?
    var viewModel: RubricTemplatesViewModel
    func body(content: Content) -> some View {
        content.sheet(item: $editingTemplate) { identifiable in
            RubricTemplateEditor(template: identifiable.rubric) { updated in
                if updated.id == Rubric.empty.id {
                    viewModel.addTemplate(updated)
                } else {
                    viewModel.updateTemplate(updated)
                }
            }
        }
    }
}

private struct JSONSheetModifier: ViewModifier {
    @Binding var showingJSON: IdentifiableRubric?
    func body(content: Content) -> some View {
        content.sheet(item: $showingJSON) { identifiable in
            let template = identifiable.rubric
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Template JSON")
                            .font(.system(size: 17, weight: .semibold))
                            .padding(.bottom, 4)
                        Text(template.toJSONString())
                            .font(.system(.footnote, design: .monospaced))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationTitle("Source JSON")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Copy") {
                            UIPasteboard.general.string = template.toJSONString()
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showingJSON = nil }
                    }
                }
            }
        }
    }
} 
