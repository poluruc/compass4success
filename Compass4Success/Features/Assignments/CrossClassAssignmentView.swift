import SwiftUI
import Combine

struct CrossClassAssignmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var classService: ClassService
    
    @State private var selectedClasses = Set<String>()
    @State private var searchText = ""
    @State private var isSubmitting = false
    @State private var isShowingConfirmation = false
    @State private var errorMessage: String?
    
    var assignment: Assignment
    var onComplete: (Result<Bool, Error>) -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if isSubmitting {
                    LoadingOverlay(message: "Publishing assignment to selected classes...")
                } else {
                    VStack {
                        // Class list with checkboxes
                        List {
                            ForEach(filteredClasses) { schoolClass in
                                ClassSelectionRow(
                                    schoolClass: schoolClass,
                                    isSelected: selectedClasses.contains(schoolClass.id)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedClasses.contains(schoolClass.id) {
                                        selectedClasses.remove(schoolClass.id)
                                    } else {
                                        selectedClasses.insert(schoolClass.id)
                                    }
                                }
                            }
                        }
                        .searchable(text: $searchText, prompt: "Search classes")
                        
                        // Summary and submit button at the bottom
                        VStack(spacing: 16) {
                            Text("\(selectedClasses.count) classes selected")
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                isShowingConfirmation = true
                            }) {
                                Text("Publish to Selected Classes")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedClasses.isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(selectedClasses.isEmpty)
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                    }
                }
            }
            .navigationTitle("Publish to Classes")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #endif
            }
            .alert(isPresented: $isShowingConfirmation) {
                Alert(
                    title: Text("Confirm Publication"),
                    message: Text("Are you sure you want to publish \"\(assignment.title)\" to \(selectedClasses.count) classes?"),
                    primaryButton: .default(Text("Publish")) {
                        publishAssignment()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private var filteredClasses: [SchoolClass] {
        if searchText.isEmpty {
            return classService.classes
        } else {
            return classService.classes.filter { schoolClass in
                schoolClass.name.lowercased().contains(searchText.lowercased()) ||
                (!schoolClass.courseCode.isEmpty && 
                    schoolClass.courseCode.lowercased().contains(searchText.lowercased()))
            }
        }
    }
    
    private func publishAssignment() {
        // This would be an API call in a real app
        isSubmitting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            
            // Success callback
            presentationMode.wrappedValue.dismiss()
            onComplete(.success(true))
        }
    }
}

struct ClassSelectionRow: View {
    let schoolClass: SchoolClass
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(schoolClass.name)
                    .font(.headline)
                
                if !schoolClass.courseCode.isEmpty {
                    Text(schoolClass.courseCode)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

// Preview provider
struct CrossClassAssignmentView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAssignment = Assignment(id: "1", title: "Math Quiz", dueDate: Date().addingTimeInterval(86400), assignmentDescription: "Chapter 5 Quiz")
        mockAssignment.classId = "1"
        
        return CrossClassAssignmentView(assignment: mockAssignment) { result in
            print("Assignment complete with result: \(result)")
        }
        .environmentObject(ClassService())
    }
}
