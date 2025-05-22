import SwiftUI

struct CurriculumView: View {
    @EnvironmentObject var classService: ClassService
    @State private var selectedStandards: Set<String> = []
    @State private var searchText = ""
    @State private var showingAddCustomStandardSheet = false
    
    // Curriculum standards
    let standardCategories = [
        "Mathematics": [
            "MATH.K-12.1": "Make sense of problems and persevere in solving them",
            "MATH.K-12.2": "Reason abstractly and quantitatively",
            "MATH.K-12.3": "Construct viable arguments and critique reasoning of others",
            "MATH.K-12.4": "Model with mathematics",
            "MATH.K-12.5": "Use appropriate tools strategically",
            "MATH.K-12.6": "Attend to precision",
            "MATH.K-12.7": "Look for and make use of structure",
            "MATH.K-12.8": "Look for and express regularity in repeated reasoning"
        ],
        "Science": [
            "SCI.MS.1": "Structure and Properties of Matter",
            "SCI.MS.2": "Chemical Reactions",
            "SCI.MS.3": "Forces and Interactions",
            "SCI.MS.4": "Energy",
            "SCI.MS.5": "Waves and Electromagnetic Radiation",
            "SCI.MS.6": "Structure, Function, and Information Processing",
            "SCI.MS.7": "Matter and Energy in Organisms and Ecosystems",
            "SCI.MS.8": "Interdependent Relationships in Ecosystems"
        ],
        "English Language Arts": [
            "ELA.6-8.1": "Read closely to determine explicit and implicit meaning",
            "ELA.6-8.2": "Determine central ideas or themes and summarize key details",
            "ELA.6-8.3": "Analyze how individuals, events, and ideas develop and interact",
            "ELA.6-8.4": "Interpret words and phrases as used in text",
            "ELA.6-8.5": "Analyze the structure of texts",
            "ELA.6-8.6": "Assess point of view or purpose"
        ],
        "Social Studies": [
            "SS.6-8.1": "Inquire and Research Historical Topics",
            "SS.6-8.2": "Apply Historical Thinking and Analysis",
            "SS.6-8.3": "Evaluate Causes and Effects in History",
            "SS.6-8.4": "Compare Societies and Cultures",
            "SS.6-8.5": "Analyze Geographic Data and Human Movement",
            "SS.6-8.6": "Explain Economic Decision Making"
        ]
    ]
    
    var filteredStandards: [(category: String, standards: [String: String])] {
        if searchText.isEmpty {
            return standardCategories.sorted { $0.key < $1.key }
                .map { (category: $0.key, standards: $0.value) }
        } else {
            let query = searchText.lowercased()
            var result = [(category: String, standards: [String: String])]()
            
            for (category, standards) in standardCategories {
                let filteredStds = standards.filter { (id, description) in
                    id.lowercased().contains(query) || description.lowercased().contains(query)
                }
                
                if !filteredStds.isEmpty {
                    result.append((category: category, standards: filteredStds))
                }
            }
            
            return result
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        showingAddCustomStandardSheet = true
                    }) {
                        Label("Add Custom Standard", systemImage: "plus.circle.fill")
                    }
                    .foregroundColor(.blue)
                }
                
                ForEach(filteredStandards, id: \.category) { category in
                    Section(header: Text(category.category)) {
                        ForEach(category.standards.sorted(by: { $0.key < $1.key }), id: \.key) { id, description in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(id)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedStandards.contains(id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedStandards.contains(id) ? .blue : .gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedStandards.contains(id) {
                                    selectedStandards.remove(id)
                                } else {
                                    selectedStandards.insert(id)
                                }
                            }
                        }
                    }
                }
                
                if filteredStandards.isEmpty {
                    Section {
                        Text("No standards match your search")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            .navigationTitle("Curriculum Standards")
            .searchable(text: $searchText, prompt: "Search Standards")
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Handle saving selected standards
                        print("Selected \(selectedStandards.count) standards")
                    }
                    .disabled(selectedStandards.isEmpty)
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        // Handle saving selected standards
                        print("Selected \(selectedStandards.count) standards")
                    }
                    .disabled(selectedStandards.isEmpty)
                }
            }
            #endif
            .sheet(isPresented: $showingAddCustomStandardSheet) {
                CustomStandardView(onSave: { id, description in
                    // Handle saving custom standard
                    print("Custom standard: \(id) - \(description)")
                    selectedStandards.insert(id)
                })
            }
        }
    }
}

struct CustomStandardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var standardId = ""
    @State private var standardDescription = ""
    
    var onSave: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Standard Details")) {
                    TextField("Standard ID (e.g., MATH.CUSTOM.1)", text: $standardId)
                    .appTextFieldStyle()
                    TextField("Description", text: $standardDescription)
                        .appTextFieldStyle()
                        .frame(height: 100, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                }
            }
            .navigationTitle("Add Custom Standard")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(standardId, standardDescription)
                        dismiss()
                    }
                    .disabled(standardId.isEmpty || standardDescription.isEmpty)
                }
            }
        }
    }
}

struct CurriculumView_Previews: PreviewProvider {
    static var previews: some View {
        CurriculumView()
            .environmentObject(ClassService())
    }
}