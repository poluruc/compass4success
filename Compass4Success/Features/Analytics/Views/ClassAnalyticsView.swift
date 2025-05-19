import SwiftUI
import Charts

@available(macOS 13.0, iOS 16.0, *)
struct ClassAnalyticsView: View {
    let schoolClass: SchoolClass
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
            case .assignments: return "doc.text.fill"
            case .attendance: return "calendar"
            case .participation: return "hand.raised.fill"
            }
        }
    }
    
    var body: some View {
        #if os(iOS)
        SwiftUI.ScrollView(.vertical, showsIndicators: true) {
            mainContent
        }
        .navigationTitle(schoolClass.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(content: {
            if isLoading {
                LoadingOverlay()
            }
        })
        .onAppear {
            loadData()
        }
        #else
        SwiftUI.ScrollView(.vertical, showsIndicators: true) {
            mainContent
        }
        .navigationTitle(schoolClass.name)
        .overlay(content: {
            if isLoading {
                LoadingOverlay()
            }
        })
        .onAppear {
            loadData()
        }
        #endif
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            // Class details header
            ClassHeader(schoolClass: schoolClass)
            
            // Metric selector
            MetricSelector(selectedMetric: $selectedMetric)
            
            // Content based on selected metric
            if #available(macOS 13.0, *) {
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
            } else {
                // Fallback for unsupported OS versions
                VStack {
                    Text("Advanced analytics require macOS 13.0 or newer")
                        .font(.headline)
                    
                    Text("Please update your operating system to access all features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            }
        }
        .padding()
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

@available(macOS 13.0, iOS 16.0, *)
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

@available(macOS 13.0, iOS 16.0, *)
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
    @State private var grade = Double.random(in: 65...95) // Mock grade
    
    var body: some View {
        HStack {
            // Student name
            VStack(alignment: .leading) {
                Text("\(student.firstName) \(student.lastName)")
                    .fontWeight(.medium)
                
                Text("ID: \(student.studentNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Grade
            VStack(alignment: .trailing) {
                Text("\(Int(grade))%")
                    .fontWeight(.bold)
                    .foregroundColor(gradeColor)
                
                Text(letterGrade)
                    .font(.caption)
                    .foregroundColor(gradeColor)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
    }
    
    private var letterGrade: String {
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
    
    private var gradeColor: Color {
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
}

@available(macOS 13.0, iOS 16.0, *)
struct AssignmentAnalyticsView: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        Text("Assignment Analytics")
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct AttendanceAnalyticsView: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        Text("Attendance Analytics")
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct ParticipationAnalyticsView: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        Text("Participation Analytics")
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct ClassAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock class for preview
        let mockClass = MockDataService.shared.generateMockData().classes.first!
        
        NavigationView {
            ClassAnalyticsView(schoolClass: mockClass)
        }
    }
}