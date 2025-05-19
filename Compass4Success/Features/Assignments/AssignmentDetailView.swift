import SwiftUI
import Combine

struct AssignmentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classService: ClassService
    @State private var showingDeleteConfirmation = false
    @State private var showingCrossClassAssignment = false
    @State private var showingEdit = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var classDetails: SchoolClass?
    @State private var showingFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackType: FeedbackType = .success
    
    enum FeedbackType {
        case success, error
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            }
        }
    }
    
    var assignment: Assignment
    var onDelete: ((Assignment) -> Void)?
    var onDuplicate: ((Assignment) -> Assignment)?
    
    private var assignmentStatus: String {
        if !assignment.isActive {
            return "Completed"
        } else if assignment.dueDate < Date() {
            return "Past Due"
        } else {
            return "Active"
        }
    }
    
    private var statusColor: Color {
        if !assignment.isActive {
            return .gray
        } else if assignment.dueDate < Date() {
            return .red
        } else {
            return .green
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Status bar
                HStack {
                    Label(assignmentStatus, systemImage: "circle.fill")
                        .foregroundColor(statusColor)
                        .font(.subheadline.bold())
                    
                    Spacer()
                    
                    Text("Due \(assignment.dueDate, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Assignment details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.headline)
                    
                    detailRow(label: "Title", value: assignment.title)
                    detailRow(label: "Type", value: assignment.category)
                    detailRow(label: "Assigned", value: "\(assignment.assignedDate, formatter: dateFormatter)")
                    detailRow(label: "Points", value: "\(assignment.totalPoints)")
                    
                    if !assignment.assignmentDescription.isEmpty {
                        Text("Description")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text(assignment.assignmentDescription)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Class information
                if let schoolClass = classDetails {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Class")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(schoolClass.name)
                                    .font(.body.bold())
                                
                                Text("\(schoolClass.courseCode) • Grade \(schoolClass.gradeLevel)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                showingCrossClassAssignment = true
                            } label: {
                                Text("Assign to Other Classes")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .controlSize(.small)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Submission statistics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Submissions")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        statView(
                            value: "\(assignment.submissions.count)",
                            label: "Submitted",
                            icon: "checkmark.circle.fill",
                            color: .blue
                        )
                        
                        if let classDetails = classDetails, classDetails.studentCount > 0 {
                            let remaining = max(0, classDetails.studentCount - assignment.submissions.count)
                            statView(
                                value: "\(remaining)",
                                label: "Missing",
                                icon: "exclamationmark.circle.fill",
                                color: .orange
                            )
                            
                            let percentage = classDetails.studentCount > 0 
                                ? (Double(assignment.submissions.count) / Double(classDetails.studentCount)) * 100 
                                : 0
                            
                            statView(
                                value: String(format: "%.0f%%", percentage),
                                label: "Completion",
                                icon: "percent",
                                color: .green
                            )
                        }
                    }
                    .padding(.bottom, 8)
                    
                    if !assignment.submissions.isEmpty {
                        // Grade distribution chart would go here in a real app
                        Text("Grade Distribution")
                            .font(.subheadline.bold())
                            .padding(.top, 4)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 100)
                            .overlay(
                                Text("Chart placeholder")
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showingEdit = true
                    }) {
                        Label("Edit Assignment", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        if let onDuplicate = onDuplicate {
                            let copy = onDuplicate(assignment)
                            showFeedback(message: "Assignment duplicated", type: .success)
                        }
                    }) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(role: .destructive, action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Assignment Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            // This would link to your edit assignment view
            Text("Edit Assignment View")
        }
        .sheet(isPresented: $showingCrossClassAssignment) {
            CrossClassAssignmentView(assignment: assignment) { result in
                switch result {
                case .success:
                    showFeedback(message: "Assignment copied to selected classes", type: .success)
                case .failure(let error):
                    showFeedback(message: error.localizedDescription, type: .error)
                }
            }
        }
        .alert("Delete Assignment", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let onDelete = onDelete {
                    onDelete(assignment)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this assignment? This action cannot be undone.")
        }
        .overlay(
            ZStack {
                if isLoading {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
                
                if showingFeedback {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: feedbackType.icon)
                            Text(feedbackMessage)
                            Spacer()
                        }
                        .padding()
                        .background(feedbackType.color.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(feedbackType.color)
                        .padding()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: showingFeedback)
        )
        .onAppear {
            loadClassDetails()
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
    }
    
    private func statView(value: String, label: String, icon: String, color: Color) -> some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2.bold())
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func loadClassDetails() {
        isLoading = true
        
        // In a real app, you would fetch this from a service
        let mockClass = SchoolClass(
            id: assignment.classId,
            name: "Algebra I",
            courseCode: "MATH101",
            gradeLevel: "9"
        )
        mockClass.studentCount = 28
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.classDetails = mockClass
            self.isLoading = false
        }
    }
    
    private func showFeedback(message: String, type: FeedbackType) {
        feedbackMessage = message
        feedbackType = type
        
        withAnimation {
            showingFeedback = true
        }
        
        // Hide after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingFeedback = false
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

// Preview provider
struct AssignmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let mockAssignment = Assignment()
            mockAssignment.id = "1"
            mockAssignment.title = "Math Quiz"
            mockAssignment.assignmentDescription = "Chapter 5 Quiz covering logarithmic functions"
            mockAssignment.dueDate = Date().addingTimeInterval(86400)
            mockAssignment.assignedDate = Date().addingTimeInterval(-86400)
            mockAssignment.classId = "1"
            mockAssignment.category = AssignmentCategory.quiz.rawValue
            mockAssignment.isActive = true
            
            // Add some mock submissions
            for i in 0..<15 {
                let submission = AssignmentSubmission()
                submission.id = UUID().uuidString
                submission.studentId = "student\(i)"
                submission.submissionDate = Date()
                submission.grade = Double.random(in: 60...100)
                mockAssignment.submissions.append(submission)
            }
            
            return AssignmentDetailView(
                assignment: mockAssignment,
                onDelete: { _ in },
                onDuplicate: { $0 }
            )
            .environmentObject(ClassService())
        }
    }
}