import SwiftUI
import Charts

struct ClassAnalyticsView: View {
    let schoolClass: SchoolClass
    private let analyticsService = AnalyticsService()
    @State private var selectedMetric: MetricType = .grades
    @State private var isLoading = false
    
    enum MetricType: String, CaseIterable {
        case grades = "Grades"
        case assignments = "Assignments"
        case attendance = "Attendance"
        case participation = "Participation"
        
        var icon: String {
            switch self {
            case .grades: return "chart.bar.fill"
            case .assignments: return "checklist"
            case .attendance: return "calendar"
            case .participation: return "hand.raised.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Class details header
                ClassHeader(schoolClass: schoolClass)
                
                // Metric selector
                MetricSelector(selectedMetric: $selectedMetric)
                
                // Content based on selected metric
                switch selectedMetric {
                case .grades:
                    GradeAnalyticsView(schoolClass: schoolClass)
                case .assignments:
                    AssignmentAnalyticsView(schoolClass: schoolClass)
                case .attendance:
                    AttendanceAnalyticsView(schoolClass: schoolClass)
                case .participation:
                    ParticipationAnalyticsView(schoolClass: schoolClass)
                }
            }
            .padding()
        }
        .navigationTitle(schoolClass.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            isLoading ? LoadingOverlay() : nil
        )
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        // Simulate loading analytics data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.isLoading = false
        }
    }
}

struct ClassHeader: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(schoolClass.name)
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Label {
                    Text(schoolClass.subject)
                } icon: {
                    Image(systemName: "book.fill")
                }
                .font(.subheadline)
                
                Spacer()
                
                Label {
                    Text("Grade \(schoolClass.gradeLevel)")
                } icon: {
                    Image(systemName: "person.2.fill")
                }
                .font(.subheadline)
            }
            
            HStack {
                Label {
                    Text("Period \(schoolClass.period)")
                } icon: {
                    Image(systemName: "clock.fill")
                }
                .font(.subheadline)
                
                Spacer()
                
                Label {
                    Text("Room \(schoolClass.roomNumber)")
                } icon: {
                    Image(systemName: "door.right.hand.open")
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct MetricSelector: View {
    @Binding var selectedMetric: ClassAnalyticsView.MetricType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ClassAnalyticsView.MetricType.allCases, id: \.self) { metric in
                    Button(action: {
                        withAnimation {
                            selectedMetric = metric
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: metric.icon)
                                .font(.title2)
                            
                            Text(metric.rawValue)
                                .font(.caption)
                        }
                        .frame(width: 90, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMetric == metric ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedMetric == metric ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                        .foregroundColor(selectedMetric == metric ? .blue : .primary)
                    }
                }
            }
        }
    }
}

struct GradeAnalyticsView: View {
    let schoolClass: SchoolClass
    @State private var gradeDistribution: [ChartDataPoint] = []
    
    var body: some View {
        VStack(spacing: 16) {
            // Grade distribution chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Grade Distribution")
                    .font(.headline)
                
                Chart {
                    ForEach(gradeDistribution) { item in
                        BarMark(
                            x: .value("Grade Range", item.label),
                            y: .value("Students", item.value)
                        )
                        .foregroundStyle(by: .value("Grade Range", item.label))
                    }
                }
                .frame(height: 250)
                .chartForegroundStyleScale([
                    "A (90-100%)": .green,
                    "B (80-89%)": .blue,
                    "C (70-79%)": .yellow,
                    "D (60-69%)": .orange,
                    "F (0-59%)": .red
                ])
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            
            // Student performance list
            VStack(alignment: .leading, spacing: 8) {
                Text("Student Performance")
                    .font(.headline)
                
                ForEach(schoolClass.students) { student in
                    StudentGradeRow(student: student)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .onAppear {
            // Mock data for grade distribution
            gradeDistribution = [
                ChartDataPoint(label: "A (90-100%)", value: Double.random(in: 3...8)),
                ChartDataPoint(label: "B (80-89%)", value: Double.random(in: 5...10)),
                ChartDataPoint(label: "C (70-79%)", value: Double.random(in: 4...9)),
                ChartDataPoint(label: "D (60-69%)", value: Double.random(in: 2...5)),
                ChartDataPoint(label: "F (0-59%)", value: Double.random(in: 0...3))
            ]
        }
    }
}

struct StudentGradeRow: View {
    let student: Student
    @State private var grade = Double.random(in: 60...100)
    
    var body: some View {
        HStack {
            Text(student.fullName)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(Int(grade))%")
                .font(.headline)
                .foregroundColor(getGradeColor(grade))
            
            Text(getLetterGrade(grade))
                .font(.subheadline)
                .frame(width: 30)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(getGradeColor(grade).opacity(0.2))
                )
                .foregroundColor(getGradeColor(grade))
        }
        .padding(.vertical, 6)
    }
    
    private func getGradeColor(_ grade: Double) -> Color {
        switch grade {
        case 90...100:
            return .green
        case 80..<90:
            return .blue
        case 70..<80:
            return .yellow
        case 60..<70:
            return .orange
        default:
            return .red
        }
    }
    
    private func getLetterGrade(_ grade: Double) -> String {
        switch grade {
        case 90...100:
            return "A"
        case 80..<90:
            return "B"
        case 70..<80:
            return "C"
        case 60..<70:
            return "D"
        default:
            return "F"
        }
    }
}

struct AssignmentAnalyticsView: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Assignment Completion")
                .font(.headline)
            
            // Simplified placeholder
            Text("Assignment analytics content will appear here")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct AttendanceAnalyticsView: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Attendance Records")
                .font(.headline)
            
            // Simplified placeholder
            Text("Attendance analytics content will appear here")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ParticipationAnalyticsView: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Class Participation")
                .font(.headline)
            
            // Simplified placeholder
            Text("Participation analytics content will appear here")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ClassAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock class for preview
        let mockClass = MockDataService.shared.generateMockData().classes.first!
        
        NavigationView {
            ClassAnalyticsView(schoolClass: mockClass)
        }
    }
}