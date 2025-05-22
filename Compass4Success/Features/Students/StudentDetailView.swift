import SwiftUI
import Combine
import Charts
#if canImport(UIKit)
import UIKit
#endif

struct StudentDetailView: View {
    let student: Student
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = StudentDetailViewModel()
    @State private var selectedTab = 0
    @State private var selectedCourse: String? = nil
    @State private var selectedStatus: String? = nil
    @State private var selectedAssignment: StudentDetailViewModel.AssignmentData? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with student info
            header
                .padding(.bottom)
            
            // Tab selector
            tabBar
                .padding(.horizontal)
            
            // Content based on selected tab
            tabContent
                .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.loadStudentData(for: student)
        }
        .navigationDestination(for: StudentDetailViewModel.AssignmentData.self) { assignment in
            let assignmentObj = convertToAssignment(assignment)
            AssignmentDetailView(
                viewModel: AssignmentViewModel(assignment: assignmentObj),
                assignment: assignmentObj
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 12) {
            HStack {
#if os(iOS)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
#endif
                
                Spacer()
                
                Text(student.fullName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Menu {
                    Button(action: {}) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {}) {
                        Label("Print Report", systemImage: "printer")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Student details
            VStack(spacing: 4) {
                Text(student.grade.isEmpty ? "Grade: N/A" : "Grade \(student.grade)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("ID: \(student.studentNumber)", systemImage: "number")
                    
                    Label(student.email, systemImage: "envelope")
                        .lineLimit(1)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            // Quick stats
            HStack(spacing: 0) {
                StatBox(
                    title: "Overall Average",
                    value: viewModel.averageGrade,
                    icon: "chart.bar.fill",
                    color: Self.getColorForGrade(viewModel.numericAverage)
                )
                
                Divider()
                
                StatBox(
                    title: "Achievement",
                    value: viewModel.achievementLevel,
                    icon: "chart.line.uptrend.xyaxis",
                    color: StudentDetailView.getColorForLevel(viewModel.achievementLevel)
                )
                
                Divider()
                
                StatBox(
                    title: "Attendance",
                    value: "\(viewModel.attendanceRate)%",
                    icon: "calendar.badge.clock",
                    color: StudentDetailView.getColorForAttendance(viewModel.attendanceRate)
                )
            }
            .frame(height: 80)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(TabSection.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation {
                        selectedTab = tab.rawValue
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: selectedTab == tab.rawValue ? 16 : 14))
                        
                        Text(tab.title)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundColor(selectedTab == tab.rawValue ? .blue : .gray)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    // MARK: - Tab Content
    private var tabContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch TabSection(rawValue: selectedTab) ?? .overview {
                case .overview:
                    overviewTabView
                case .grades:
                    gradesTabView
                case .assignments:
                    assignmentsTabView
                case .analytics:
                    analyticsTabView
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
    
    // Tab sections
    enum TabSection: Int, CaseIterable {
        case overview = 0
        case grades = 1
        case assignments = 2
        case analytics = 3
        
        var title: String {
            switch self {
            case .overview: return "Overview"
            case .grades: return "Grades"
            case .assignments: return "Assignments"
            case .analytics: return "Analytics"
            }
        }
        
        var icon: String {
            switch self {
            case .overview: return "person.fill"
            case .grades: return "list.number"
            case .assignments: return "doc.text"
            case .analytics: return "chart.xyaxis.line"
            }
        }
    }
    
    // Helper functions for colors
    public static func getColorForGrade(_ grade: Double) -> Color {
        switch grade {
        case 80...100: return .green
        case 70..<80: return .blue
        case 60..<70: return .orange
        default: return .red
        }
    }
    
    private static func getColorForLevel(_ level: String) -> Color {
        switch level {
        case "Level 4": return .green
        case "Level 3": return .blue
        case "Level 2": return .orange
        case "Level 1": return .red
        default: return .gray
        }
    }
    
    private static func getColorForAttendance(_ rate: Double) -> Color {
        switch rate {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .orange
        default: return .red
        }
    }
    
    // Helper Views
    private struct DetailInfoRow: View {
        let label: String
        let value: String
        
        var body: some View {
            HStack(alignment: .top) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 120, alignment: .leading)
                
                Text(value)
                    .font(.subheadline)
                
                Spacer()
            }
        }
    }
    
    struct AssignmentRow: View {
        let assignment: StudentDetailViewModel.AssignmentData
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(assignment.courseName) • Due \(StudentDetailView.formatDate(assignment.dueDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    DetailStatusBadge(status: assignment.status)
                    
                    if let grade = assignment.grade {
                        Text("\(String(format: "%.0f", grade))/\(String(format: "%.0f", assignment.maxPoints))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Add chevron to indicate it's navigable
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle()) // Ensure the entire row is tappable
        }
    }
    
    // Chart data model
    struct TimeSeriesDataPoint: Identifiable {
        let id = UUID()
        let label: String
        let date: Date
        let value: Double
    }
    
    // Helper function to format dates
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Helper function for letter grades (Ontario system)
    private static func getLetterGrade(_ grade: Double) -> String {
        switch grade {
        case 90...100: return "A+"
        case 85..<90: return "A"
        case 80..<85: return "A-"
        case 77..<80: return "B+"
        case 73..<77: return "B"
        case 70..<73: return "B-"
        case 67..<70: return "C+"
        case 63..<67: return "C"
        case 60..<63: return "C-"
        case 57..<60: return "D+"
        case 53..<57: return "D"
        case 50..<53: return "D-"
        default: return "F"
        }
    }
    
    // MARK: - Overview Tab
    private var overviewTabView: some View {
        VStack(spacing: 16) {
            // Personal information card
            VStack(alignment: .leading, spacing: 12) {
                Text("Personal Information")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    DetailInfoRow(label: "Full Name", value: student.fullName)
                    DetailInfoRow(label: "Email", value: student.email)
                    DetailInfoRow(label: "Student ID", value: student.studentNumber)
                    DetailInfoRow(label: "Grade Level", value: "Grade \(student.grade)")
                    
                    if let dob = student.dateOfBirth {
                        DetailInfoRow(label: "Date of Birth", value: Self.formatDate(dob))
                    }
                    
                    DetailInfoRow(label: "Guardian Email", value: student.guardianEmail.isEmpty ? "Not provided" : student.guardianEmail)
                    DetailInfoRow(label: "Guardian Phone", value: student.guardianPhone.isEmpty ? "Not provided" : student.guardianPhone)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
            }
            
            // Academic summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Academic Summary")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Ontario achievement categories
                VStack(spacing: 12) {
                    ForEach(viewModel.skillAssessments) { assessment in
                        HStack {
                            Text(assessment.skill)
                                .font(.subheadline)
                                .frame(width: 180, alignment: .leading)
                            
                            DetailLevelProgressBar(level: assessment.level)
                            
                            Text("Level \(assessment.level)")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
            }
            
            // Course highlights
            VStack(alignment: .leading, spacing: 12) {
                Text("Course Overview")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    ForEach(viewModel.courseGrades.prefix(3)) { course in
                        DetailCourseGradeRow(course: course)
                        
                        if course.id != viewModel.courseGrades.prefix(3).last?.id {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
                
                if viewModel.courseGrades.count > 3 {
                    Button(action: {
                        selectedTab = TabSection.grades.rawValue
                    }) {
                        Text("View All Courses")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            // Recent activity
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Activity")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    ForEach(viewModel.recentAssignments.prefix(2)) { assignment in
                        NavigationLink(value: assignment) {
                            AssignmentRow(assignment: assignment)
                        }
                        .buttonStyle(PressableButtonStyle())
                        
                        if assignment.id != viewModel.recentAssignments.prefix(2).last?.id {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
                
                if viewModel.recentAssignments.count > 2 {
                    Button(action: {
                        selectedTab = TabSection.assignments.rawValue
                    }) {
                        Text("View All Assignments")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    // MARK: - Grades Tab
    private var gradesTabView: some View {
        VStack(spacing: 16) {
            // Average grade section
            VStack(alignment: .leading, spacing: 12) {
                Text("Overall Performance")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    // Overall grade
                    VStack(alignment: .center, spacing: 4) {
                        Text(viewModel.averageGrade)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Self.getColorForGrade(viewModel.numericAverage))
                        
                        Text("Average")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Achievement level (Ontario system)
                    VStack(alignment: .center, spacing: 4) {
                        Text(viewModel.achievementLevel)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Self.getColorForLevel(viewModel.achievementLevel))
                        
                        Text("Achievement")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Letter grade
                    VStack(alignment: .center, spacing: 4) {
                        if viewModel.numericAverage > 0 {
                            Text(Self.getLetterGrade(viewModel.numericAverage))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Self.getColorForGrade(viewModel.numericAverage))
                        } else {
                            Text("N/A")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                        
                        Text("Letter Grade")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
            }
            
            // Course grades
            VStack(alignment: .leading, spacing: 12) {
                Text("Course Grades")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Grade list header
                HStack {
                    Text("Course")
                        .fontWeight(.medium)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Grade")
                        .fontWeight(.medium)
                        .frame(width: 70, alignment: .trailing)
                    
                    Text("Level")
                        .fontWeight(.medium)
                        .frame(width: 70, alignment: .trailing)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Course list
                VStack(spacing: 0) {
                    ForEach(viewModel.courseGrades) { course in
                        HStack {
                            Text(course.courseName)
                                .font(.subheadline)
                                .lineLimit(1)
                                .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f%%", course.grade))
                                    .font(.subheadline)
                                    .foregroundColor(Self.getColorForGrade(course.grade))
                                
                                // Trend indicator
                                if course.trend != 0 {
                                    Image(systemName: course.trend > 0 ? "arrow.up" : "arrow.down")
                                        .font(.caption2)
                                        .foregroundColor(course.trend > 0 ? .green : .red)
                                }
                            }
                            .frame(width: 70, alignment: .trailing)
                            
                            Text(course.level)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(StudentDetailView.getColorForLevel(course.level).opacity(0.2))
                                .cornerRadius(4)
                                .frame(width: 70, alignment: .trailing)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        
                        if course.id != viewModel.courseGrades.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
            }
            
            // Learning skills assessment (Ontario-specific)
            VStack(alignment: .leading, spacing: 12) {
                Text("Learning Skills and Work Habits")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    DetailLearningSkillRow(skill: "Responsibility", level: "Excellent")
                    DetailLearningSkillRow(skill: "Organization", level: "Good")
                    DetailLearningSkillRow(skill: "Independent Work", level: "Good")
                    DetailLearningSkillRow(skill: "Collaboration", level: "Excellent")
                    DetailLearningSkillRow(skill: "Initiative", level: "Good")
                    DetailLearningSkillRow(skill: "Self-Regulation", level: "Very Good")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
            }
        }
    }
    
    // MARK: - Assignments Tab
    private var assignmentsTabView: some View {
        VStack(spacing: 16) {
            // Filter options
            HStack {
                Menu {
                    Button("All Courses", action: {
                        selectedCourse = nil
                    })
                    
                    Divider()
                    
                    ForEach(viewModel.courseGrades) { course in
                        Button(course.courseName, action: {
                            selectedCourse = course.courseName
                        })
                    }
                } label: {
                    HStack {
                        Text(selectedCourse == nil ? "Course: All" : "Course: \(selectedCourse!)")
                        Image(systemName: "chevron.down")
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Menu {
                    Button("All", action: {
                        selectedStatus = nil
                    })
                    Button("Completed", action: {
                        selectedStatus = "Completed"
                    })
                    Button("In Progress", action: {
                        selectedStatus = "In Progress"
                    })
                    Button("Not Started", action: {
                        selectedStatus = "Not Started"
                    })
                    Button("Late", action: {
                        selectedStatus = "Late"
                    })
                } label: {
                    HStack {
                        Text(selectedStatus == nil ? "Status: All" : "Status: \(selectedStatus!)")
                        Image(systemName: "chevron.down")
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 4)
            
            // Assignment completion stats - now using the filtered assignments for calculations
            HStack(spacing: 12) {
                // Get filtered assignments for stats
                let filteredAssignments = filteredAssignmentsList
                
                // Break down complex expression for completed assignments
                let completedAssignments = filteredAssignments.filter { $0.status == "Completed" }
                let completedCount = completedAssignments.count
                
                DetailCompletionStatCard(
                    title: "Completed",
                    count: completedCount,
                    total: filteredAssignments.count,
                    color: .green
                )
                
                // Break down complex expression for in progress assignments
                let inProgressAssignments = filteredAssignments.filter { $0.status == "In Progress" }
                let inProgressCount = inProgressAssignments.count
                
                DetailCompletionStatCard(
                    title: "In Progress",
                    count: inProgressCount,
                    total: filteredAssignments.count,
                    color: .blue
                )
                
                // Break down complex expression for not started assignments
                let notStartedAssignments = filteredAssignments.filter { $0.status == "Not Started" }
                let notStartedCount = notStartedAssignments.count
                
                DetailCompletionStatCard(
                    title: "Not Started",
                    count: notStartedCount,
                    total: filteredAssignments.count,
                    color: .orange
                )
            }
            
            // Assignments list - now using filtered assignments
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("All Assignments")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        // Reset filters to show all assignments
                        selectedCourse = nil
                        selectedStatus = nil
                    }) {
                        Label("Show All", systemImage: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal)
                
                if filteredAssignmentsList.isEmpty {
                    Text("No assignments found matching filters")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 0) {
                        ForEach(filteredAssignmentsList) { assignment in
                            // Helper method for assignment items
                            assignmentItemView(for: assignment)
                            
                            if assignment.id != filteredAssignmentsList.last?.id {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                }
            }
        }
    }
    
    // Computed property to filter assignments based on selected filters
    private var filteredAssignmentsList: [StudentDetailViewModel.AssignmentData] {
        viewModel.recentAssignments.filter { assignment in
            // First check course filter
            let courseMatches = selectedCourse == nil || assignment.courseName == selectedCourse
            
            // Then check status filter
            let statusMatches = selectedStatus == nil || assignment.status == selectedStatus
            
            // Assignment is included only if both filters match
            return courseMatches && statusMatches
        }
    }
    
    // MARK: - Analytics Tab
    private var analyticsTabView: some View {
        VStack(spacing: 20) {
            if #available(iOS 16.0, macOS 13.0, *) {
                // Grade trend over time
                VStack(alignment: .leading, spacing: 12) {
                    Text("Grade Trend")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack {
                        // Legend for subjects
                        HStack(spacing: 20) {
                            ForEach(viewModel.gradeHistory) { history in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(history.color)
                                        .frame(width: 8, height: 8)
                                    Text(history.subject)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        simpleGradeTrendSection
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Simple skills section
                simpleSkillsSection
            } else {
                Text("Advanced analytics available on iOS 16.0+ and macOS 13.0+")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var simpleSkillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skills Assessment")
                .font(.headline)
            
            Text("Ontario Curriculum Achievement Categories")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                SkillProgressBar(label: "Knowledge", value: 0.85, color: .blue)
                SkillProgressBar(label: "Thinking", value: 0.75, color: .green)
                SkillProgressBar(label: "Communication", value: 0.9, color: .orange)
                SkillProgressBar(label: "Application", value: 0.8, color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var simpleGradeTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grade Trend")
                .font(.headline)
            
            // Simple legend
            HStack {
                ForEach(viewModel.gradeHistory) { history in
                    Label(history.subject, systemImage: "circle.fill")
                        .foregroundColor(history.color)
                        .font(.caption)
                        .padding(.horizontal, 8)
                }
            }
            
            // Use the standard chart - no longer complex due to our improvements
            gradeChart
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var gradeChart: some View {
        // Simply delegate to our simpleGradeChart implementation
        simpleGradeChart
    }
    
    @available(iOS 16.0, macOS 13.0, *)
    private var simpleGradeChart: some View {
        // Create flat data structure for the chart
        var chartPoints: [SimpleChartPoint] = []
        var colors: [Color] = []
        
        // Prepare the data
        for history in viewModel.gradeHistory {
            colors.append(history.color)
            for point in history.dataPoints {
                chartPoints.append(
                    SimpleChartPoint(
                        id: UUID(),
                        subject: history.subject,
                        date: point.date,
                        grade: point.grade
                    )
                )
            }
        }
        
        // Use a simpler chart configuration that avoids custom axis configuration issues
        return Chart(chartPoints) { point in
            LineMark(
                x: .value("Month", point.date, unit: .month),
                y: .value("Grade", point.grade)
            )
            .foregroundStyle(by: .value("Subject", point.subject))
        }
        .chartForegroundStyleScale(range: colors)
        .chartYScale(domain: 60...100)
        // Use a standard X-axis configuration to avoid AxisContent errors
        .chartXAxis(.automatic)
        .frame(height: 180)
        .padding([.top, .bottom])
    }
    
    // Simple struct for the chart points
    @available(iOS 16.0, macOS 13.0, *)
    private struct SimpleChartPoint: Identifiable {
        let id: UUID
        let subject: String
        let date: Date
        let grade: Double
    }
    
    // MARK: - Supporting Views
    
    private struct StatBox: View {
        let title: String
        let value: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - View Model
    
    class StudentDetailViewModel: ObservableObject {
        @Published var courseGrades: [CourseGrade] = []
        @Published var recentAssignments: [AssignmentData] = []
        @Published var attendanceData: [AttendanceRecord] = []
        @Published var skillAssessments: [SkillAssessment] = []
        @Published var averageGrade: String = "N/A"
        @Published var numericAverage: Double = 0.0
        @Published var achievementLevel: String = "N/A"
        @Published var attendanceRate: Double = 0.0
        @Published var gradeHistory: [GradeHistory] = []
        
        struct CourseGrade: Identifiable {
            let id = UUID()
            let courseName: String
            let grade: Double
            let letterGrade: String
            let level: String
            let trend: Double
        }
        
        struct AssignmentData: Identifiable, Hashable {
            let id = UUID()
            let title: String
            let courseName: String
            let dueDate: Date
            let status: String
            let grade: Double?
            let maxPoints: Double
            
            // Implement hash(into:) to make AssignmentData hashable
            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
            
            // Implement == for Equatable conformance (required for Hashable)
            static func == (lhs: AssignmentData, rhs: AssignmentData) -> Bool {
                lhs.id == rhs.id
            }
        }
        
        struct AttendanceRecord: Identifiable {
            let id = UUID()
            let date: Date
            let status: String
            let isPresent: Bool
        }
        
        struct SkillAssessment: Identifiable {
            let id = UUID()
            let skill: String
            let level: Int
            let description: String
        }
        
        // Data structures for grade history chart
        struct GradeHistory: Identifiable {
            let id = UUID()
            let subject: String
            let color: Color
            let dataPoints: [GradeDataPoint]
            
            init(subject: String, color: Color, dataPoints: [GradeDataPoint]) {
                self.subject = subject
                self.color = color
                self.dataPoints = dataPoints
            }
        }
        
        struct GradeDataPoint: Identifiable {
            let id = UUID()
            let date: Date
            let grade: Double
            
            init(date: Date, grade: Double) {
                self.date = date
                self.grade = grade
            }
        }
        
        func loadStudentData(for student: Student) {
            // In a real app, you would load data from a service
            // For now, we'll create mock data
            
            generateMockData()
            
            // Calculate averages
            calculateAverages()
        }
        
        private func generateMockData() {
            // Generate course grades
            courseGrades = [
                CourseGrade(courseName: "Mathematics", grade: 87.5, letterGrade: "A", level: "Level 4", trend: 2.3),
                CourseGrade(courseName: "Science", grade: 83.0, letterGrade: "A-", level: "Level 4", trend: -1.2),
                CourseGrade(courseName: "English", grade: 78.5, letterGrade: "B+", level: "Level 3", trend: 0.5),
                CourseGrade(courseName: "History", grade: 74.0, letterGrade: "B", level: "Level 3", trend: 1.5),
                CourseGrade(courseName: "Physical Education", grade: 92.0, letterGrade: "A+", level: "Level 4", trend: 3.0),
                CourseGrade(courseName: "Art", grade: 88.0, letterGrade: "A", level: "Level 4", trend: 0.0)
            ]
            
            // Generate recent assignments
            let now = Date()
            let calendar = Calendar.current
            
            recentAssignments = [
                AssignmentData(
                    title: "Polynomials Quiz",
                    courseName: "Mathematics",
                    dueDate: calendar.date(byAdding: .day, value: -5, to: now)!,
                    status: "Completed",
                    grade: 85.0,
                    maxPoints: 100.0
                ),
                AssignmentData(
                    title: "Lab Report: Chemical Reactions",
                    courseName: "Science",
                    dueDate: calendar.date(byAdding: .day, value: -3, to: now)!,
                    status: "Completed",
                    grade: 82.0,
                    maxPoints: 100.0
                ),
                AssignmentData(
                    title: "Essay: Shakespeare Analysis",
                    courseName: "English",
                    dueDate: calendar.date(byAdding: .day, value: 1, to: now)!,
                    status: "In Progress",
                    grade: nil,
                    maxPoints: 100.0
                ),
                AssignmentData(
                    title: "Historical Figures Presentation",
                    courseName: "History",
                    dueDate: calendar.date(byAdding: .day, value: 7, to: now)!,
                    status: "Not Started",
                    grade: nil,
                    maxPoints: 100.0
                )
            ]
            
            // Generate grade history data for trending chart
            let mathHistory = generateSubjectGradeHistory(subject: "Mathematics", baseGrade: 82.0, color: .blue, variance: 5.0)
            let scienceHistory = generateSubjectGradeHistory(subject: "Science", baseGrade: 78.0, color: .green, variance: 6.0)
            let englishHistory = generateSubjectGradeHistory(subject: "English", baseGrade: 75.0, color: .orange, variance: 4.0)
            
            gradeHistory = [mathHistory, scienceHistory, englishHistory]
            
            // Generate attendance records
            attendanceData = []
            for i in 0..<30 {
                let isPresent = Double.random(in: 0...1) < 0.9 // 90% attendance rate
                attendanceData.append(
                    AttendanceRecord(
                        date: calendar.date(byAdding: .day, value: -i, to: now)!,
                        status: isPresent ? "Present" : (Double.random(in: 0...1) < 0.5 ? "Absent" : "Late"),
                        isPresent: isPresent
                    )
                )
            }
            
            // Generate skill assessments (Ontario curriculum)
            skillAssessments = [
                SkillAssessment(skill: "Knowledge/Understanding", level: 4, description: "Demonstrates thorough knowledge of content"),
                SkillAssessment(skill: "Thinking/Inquiry", level: 3, description: "Uses planning skills with considerable effectiveness"),
                SkillAssessment(skill: "Communication", level: 4, description: "Expresses ideas with a high degree of clarity"),
                SkillAssessment(skill: "Application", level: 3, description: "Applies concepts with considerable effectiveness")
            ]
        }
        
        private func calculateAverages() {
            // Calculate average grade
            if !courseGrades.isEmpty {
                let sum = courseGrades.reduce(0.0) { $0 + $1.grade }
                numericAverage = sum / Double(courseGrades.count)
                averageGrade = String(format: "%.1f%%", numericAverage)
                
                // Set achievement level based on Ontario standards
                if numericAverage >= 80 {
                    achievementLevel = "Level 4"
                } else if numericAverage >= 70 {
                    achievementLevel = "Level 3"
                } else if numericAverage >= 60 {
                    achievementLevel = "Level 2"
                } else {
                    achievementLevel = "Level 1"
                }
            }
            
            // Calculate attendance rate
            let presentCount = attendanceData.filter { $0.isPresent }.count
            attendanceRate = (Double(presentCount) / Double(attendanceData.count)) * 100
        }
        
        // Helper to generate grade history data for a subject
        private func generateSubjectGradeHistory(subject: String, baseGrade: Double, color: Color, variance: Double) -> GradeHistory {
            let calendar = Calendar.current
            let now = Date()
            var dataPoints: [GradeDataPoint] = []
            
            // Create data points for the last 5 months (one per month)
            for i in 0..<5 {
                // Start from 4 months ago to current month
                let monthOffset = 4 - i
                let date = calendar.date(byAdding: .month, value: -monthOffset, to: now)!
                
                // Generate a grade that trends upward with some randomness
                let randomVariance = Double.random(in: -variance...variance)
                let trendFactor = Double(i) * 1.2 // Gradual improvement
                let grade = min(max(baseGrade + trendFactor + randomVariance, 60.0), 98.0)
                
                dataPoints.append(GradeDataPoint(date: date, grade: grade))
            }
            
            return GradeHistory(subject: subject, color: color, dataPoints: dataPoints)
        }
    }
    
    // MARK: - Helper Views
    private struct DetailCourseGradeRow: View {
        let course: StudentDetailViewModel.CourseGrade
        
        var body: some View {
            HStack {
                Text(course.courseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f%%", course.grade))
                        .font(.headline)
                        .foregroundColor(Self.getColorForGrade(course.grade))
                    
                    HStack(spacing: 4) {
                        Text(course.level)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(self.getColorForLevel(course.level).opacity(0.2))
                            .cornerRadius(4)
                        
                        if course.trend != 0 {
                            HStack(spacing: 2) {
                                Image(systemName: course.trend > 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption2)
                                
                                Text("\(String(format: "%.1f", abs(course.trend)))%")
                                    .font(.caption2)
                            }
                            .foregroundColor(course.trend > 0 ? .green : .red)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        
        private static func getColorForGrade(_ grade: Double) -> Color {
            switch grade {
            case 80...100: return .green
            case 70..<80: return .blue
            case 60..<70: return .orange
            default: return .red
            }
        }
        
        private func getColorForLevel(_ level: String) -> Color {
            switch level {
            case "Level 4": return .green
            case "Level 3": return .blue
            case "Level 2": return .orange
            case "Level 1": return .red
            default: return .gray
            }
        }
    }
    
    private struct DetailStatusBadge: View {
        let status: String
        
        var body: some View {
            Text(status)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(getBackgroundColor())
                .foregroundColor(getForegroundColor())
                .cornerRadius(10)
        }
        
        private func getBackgroundColor() -> Color {
            switch status {
            case "Completed":
                return Color.green.opacity(0.2)
            case "In Progress":
                return Color.blue.opacity(0.2)
            case "Late":
                return Color.red.opacity(0.2)
            default:
                return Color.orange.opacity(0.2)
            }
        }
        
        private func getForegroundColor() -> Color {
            switch status {
            case "Completed":
                return .green
            case "In Progress":
                return .blue
            case "Late":
                return .red
            default:
                return .orange
            }
        }
    }
    
    private struct DetailCompletionStatCard: View {
        let title: String
        let count: Int
        let total: Int
        let color: Color
        
        var percentage: Double {
            return total > 0 ? (Double(count) / Double(total)) * 100 : 0
        }
        
        var body: some View {
            VStack(spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("\(Int(percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    private struct DetailLevelProgressBar: View {
        let level: Int
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(1...4, id: \.self) { i in
                    Rectangle()
                        .fill(i <= level ? getLevelColor(level: i) : Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                }
            }
        }
        
        private func getLevelColor(level: Int) -> Color {
            switch level {
            case 1: return .red
            case 2: return .orange
            case 3: return .blue
            case 4: return .green
            default: return .gray
            }
        }
    }
    
    private struct DetailLearningSkillRow: View {
        let skill: String
        let level: String
        
        var body: some View {
            HStack {
                Text(skill)
                    .font(.subheadline)
                
                Spacer()
                
                Text(level)
                    .font(.subheadline)
                    .foregroundColor(getLevelColor())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getLevelColor().opacity(0.1))
                    .cornerRadius(4)
            }
        }
        
        private func getLevelColor() -> Color {
            switch level {
            case "Excellent": return .green
            case "Very Good": return .blue
            case "Good": return .orange
            case "Needs Improvement": return .red
            default: return .gray
            }
        }
    }
    
    private struct AttendanceStatBox: View {
        let label: String
        let count: Int
        let total: Int
        let color: Color
        
        var percentage: Double {
            return Double(count) / Double(total) * 100
        }
        
        var body: some View {
            VStack(spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("\(Int(percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private struct SkillProgressBar: View {
        let label: String
        let value: Double
        let color: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.caption)
                        .frame(width: 100, alignment: .leading)
                    
                    Text("\(Int(value * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(color)
                            .frame(width: geometry.size.width * value, height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
            }
        }
    }
    
    // MARK: - Helper methods for formatting
    
    private func formatGradeDisplay(grade: Double, maxPoints: Double) -> (gradeText: String, percentageText: String, percentageColor: Color) {
        // Format the grade values
        let gradeFormatted = String(format: "%.1f", grade)
        let maxFormatted = String(format: "%.1f", maxPoints)
        let gradeText = "Grade: \(gradeFormatted)/\(maxFormatted)"
        
        // Calculate and format the percentage
        let percentage = (grade/maxPoints) * 100
        let percentageFormatted = String(format: "%.0f%%", percentage)
        
        // Get the color based on the percentage
        let percentageColor = Self.getColorForGrade(percentage)
        
        return (gradeText, percentageFormatted, percentageColor)
    }
    
    // Helper method to convert AssignmentData to Assignment
    private func convertToAssignment(_ assignmentData: StudentDetailViewModel.AssignmentData) -> Assignment {
        let assignment = Assignment()
        assignment.id = assignmentData.id.uuidString
        assignment.title = assignmentData.title
        assignment.dueDate = assignmentData.dueDate
        assignment.totalPoints = assignmentData.maxPoints
        assignment.category = "Assignment" // Default value
        assignment.assignedDate = Date().addingTimeInterval(-86400) // 1 day ago as default
        assignment.isActive = true
        assignment.assignmentDescription = ""
        
        // Convert grade to submission if available
        if let grade = assignmentData.grade {
            let submission = Submission()
            submission.id = UUID().uuidString
            submission.score = Int(grade)
            submission.statusEnum = .graded
            assignment.submissions.append(submission)
        }
        
        return assignment
    }
    
    // Helper method for displaying an assignment item to simplify assignmentsTabView
    private func assignmentItemView(for assignment: StudentDetailViewModel.AssignmentData) -> some View {
        NavigationLink(value: assignment) {
            VStack(alignment: .leading, spacing: 4) {
                // Title row
                HStack {
                    Text(assignment.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(assignment.courseName)
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                // Due date and status row
                HStack {
                    Label("Due: \(Self.formatDate(assignment.dueDate))", systemImage: "calendar")
                    
                    Spacer()
                    
                    DetailStatusBadge(status: assignment.status)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // Grade display if available
                if let grade = assignment.grade {
                    // Use the helper method to get all the formatted values
                    let (gradeText, percentageText, percentageColor) = formatGradeDisplay(
                        grade: grade, 
                        maxPoints: assignment.maxPoints
                    )
                    
                    HStack {
                        Text(gradeText)
                            .font(.subheadline)
                        
                        Text("(\(percentageText))")
                            .font(.subheadline)
                            .foregroundColor(percentageColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                } else {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.blue.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PressableCardButtonStyle()) // Use card button style to make it visually clickable
    }
}

#Preview {
    let mockStudent = Student()
    mockStudent.firstName = "John"
    mockStudent.lastName = "Doe"
    mockStudent.email = "john.doe@example.com"
    mockStudent.grade = "9"
    mockStudent.studentNumber = "12345"
    
    return StudentDetailView(student: mockStudent)
}
