import SwiftUI
import RealmSwift

// Helper to safely mutate Realm objects
func updateRealm<T: Object>(_ object: T, _ block: (T) -> Void) {
    if let realm = object.realm {
        try? realm.write { block(object) }
    } else {
        block(object)
    }
}

struct RubricTemplateEditor: View {
    @ObservedObject var template: Rubric
    var onSave: (Rubric) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    @State private var criterionToDelete: RubricCriterion? = nil
    @State private var levelToDelete: (criterion: RubricCriterion, level: RubricLevel)? = nil
    
    var body: some View {
        NavigationView {
            Form {
                TemplateInfoSection(template: template)
                CriteriaSection(
                    template: template,
                    onDeleteLevel: { criterion, level in
                        levelToDelete = (criterion: criterion, level: level)
                        showingDeleteAlert = true
                    },
                    onDeleteCriterion: { criterion in
                        criterionToDelete = criterion
                        showingDeleteAlert = true
                    }
                )
                PreviewSection(template: template)
            }
            .navigationTitle(template.name.isEmpty ? "New Template" : "Edit Template")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(template)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Delete Item", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let (criterion, level) = levelToDelete {
                        updateRealm(criterion) { crit in
                            crit.levels.remove(at: crit.levels.index(of: level)!)
                        }
                        levelToDelete = nil
                    }
                    if let criterion = criterionToDelete {
                        updateRealm(template) { tmpl in
                            tmpl.criteria.remove(at: tmpl.criteria.index(of: criterion)!)
                        }
                        criterionToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this item? This action cannot be undone.")
            }
        }
    }
}

private struct TemplateInfoSection: View {
    @ObservedObject var template: Rubric
    
    var body: some View {
        Section(header: Text("Template Info")) {
            TextField("Title", text: Binding(
                get: { template.name },
                set: { newValue in updateRealm(template) { $0.name = newValue } }
            ))
            TextField("Description", text: Binding(
                get: { template.rubricdDscription },
                set: { newValue in updateRealm(template) { $0.rubricdDscription = newValue } }
            ))
        }
    }
}

private struct CriteriaSection: View {
    @ObservedObject var template: Rubric
    let onDeleteLevel: (RubricCriterion, RubricLevel) -> Void
    let onDeleteCriterion: (RubricCriterion) -> Void
    
    var body: some View {
        Section(header: Text("Criteria")) {
            ForEach(Array(template.criteria), id: \.id) { criterion in
                CriterionEditor(criterion: criterion) { action in
                    switch action {
                    case .deleteLevel(let level):
                        onDeleteLevel(criterion, level)
                    }
                }
            }
            .onDelete { indexSet in
                for idx in indexSet {
                    onDeleteCriterion(template.criteria[idx])
                }
            }
            
            Button(action: {
                updateRealm(template) { tmpl in
                    let newCriterion = RubricCriterion()
                    newCriterion.name = ""
                    newCriterion.rubricdDscription = ""
                    newCriterion.points = 0
                    tmpl.criteria.append(newCriterion)
                }
            }) {
                Label("Add Criterion", systemImage: "plus.circle.fill")
            }
        }
    }
}

private struct PreviewSection: View {
    @ObservedObject var template: Rubric
    
    var body: some View {
        Section(header: Text("Preview")) {
            RubricPreview(template: template)
        }
    }
}

private struct CriterionEditor: View {
    @ObservedObject var criterion: RubricCriterion
    var onAction: (CriterionAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Criterion Name", text: Binding(
                get: { criterion.name },
                set: { newValue in updateRealm(criterion) { $0.name = newValue } }
            ))
            .font(.system(size: 17, weight: .semibold))
            
            TextField("Description", text: Binding(
                get: { criterion.rubricdDscription },
                set: { newValue in updateRealm(criterion) { $0.rubricdDscription = newValue } }
            ))
            .font(.system(size: 13))
            
            TextField("Points", value: Binding(
                get: { criterion.points },
                set: { newValue in updateRealm(criterion) { $0.points = newValue } }
            ), formatter: NumberFormatter())
            .keyboardType(.decimalPad)
            .font(.system(size: 13))
            
            ForEach(Array(criterion.levels), id: \.id) { level in
                LevelEditor(level: level) {
                    onAction(.deleteLevel(level))
                }
            }
            
            Button(action: {
                updateRealm(criterion) { crit in
                    let newLevel = RubricLevel()
                    newLevel.level = (crit.levels.last?.level ?? 0) + 1
                    newLevel.rubricLevelDescription = ""
                    newLevel.percentage = 0.0
                    crit.levels.append(newLevel)
                }
            }) {
                Label("Add Level", systemImage: "plus.circle.fill")
            }
        }
        .padding(.vertical, 8)
    }
}

private struct LevelEditor: View {
    @ObservedObject var level: RubricLevel
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level \(level.level)")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            TextField("Description", text: Binding(
                get: { level.rubricLevelDescription },
                set: { newValue in updateRealm(level) { $0.rubricLevelDescription = newValue } }
            ))
            .font(.system(size: 13))
            
            HStack {
                Text("Percentage:")
                    .font(.system(size: 13))
                TextField("Percentage", value: Binding(
                    get: { level.percentage * 100 },
                    set: { newValue in updateRealm(level) { $0.percentage = newValue / 100 } }
                ), formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                .font(.system(size: 13))
                .frame(width: 60)
                Text("%")
                    .font(.system(size: 13))
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct RubricPreview: View {
    @ObservedObject var template: Rubric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(template.name)
                .font(.system(size: 20, weight: .bold))
            Text(template.rubricdDscription)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            ForEach(Array(template.criteria), id: \.id) { criterion in
                CriterionPreviewCard(criterion: criterion)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

private struct CriterionPreviewCard: View {
    @ObservedObject var criterion: RubricCriterion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(criterion.name)
                .font(.system(size: 17, weight: .semibold))
            Text(criterion.rubricdDscription)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Text("Points: \(criterion.points, specifier: "%.1f")")
                .font(.system(size: 13))
                .foregroundColor(.blue)
            
            ForEach(Array(criterion.levels), id: \.id) { level in
                LevelPreviewRow(level: level, criterionPoints: criterion.points)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct LevelPreviewRow: View {
    @ObservedObject var level: RubricLevel
    let criterionPoints: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
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

enum CriterionAction {
    case deleteLevel(RubricLevel)
} 