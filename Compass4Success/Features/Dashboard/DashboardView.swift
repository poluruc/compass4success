import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var classService: ClassService
    @ObservedObject var viewModel: DashboardViewModel
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackType: FeedbackView.FeedbackType = .success
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case semester = "Semester"
        case year = "Year"
    }
    
    var body: some View {
        let userName = getUserFirstName()
        
        ScrollView {
            VStack(spacing: 20) {
                // Welcome section with animation
                welcomeSection(userName: userName)
                
                // Time range picker with animation
                timeRangePicker()
                
                // Quick stats with staggered animation
                quickStatsGrid()
                
                // Upcoming assignments with animation
                upcomingAssignmentsSection()
                
                // Recent activity with animation
                recentActivitySection()
            }
            .padding(.vertical)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: refreshDashboard) {
                    Image(systemName: "arrow.clockwise")
                        .pressableButton()
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    authService.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .overlay {
            if showFeedback {
                VStack {
                    Spacer()
                    FeedbackView(
                        message: feedbackMessage,
                        type: feedbackType,
                        isPresented: $showFeedback
                    )
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            refreshDashboard()
        }
    }
    
    // Helper method to safely get firstName from current user
    private func getUserFirstName() -> String {
        if let user = authService.currentUser as? User {
            return user.firstName
        } else if let mockUser = authService.currentUser as? MockUser {
            return mockUser.firstName
        }
        return "Teacher"
    }
    
    private func welcomeSection(userName: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome back,")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(userName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Current date display
                Text(formattedCurrentDate())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // User avatar/profile image
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(userName.prefix(1).uppercased())
                        .font(.title2.bold())
                        .foregroundColor(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .cardAppear(delay: 0.2)
    }
    
    // Helper to format the current date
    private func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func timeRangePicker() -> some View {
        VStack(spacing: 4) {
            HStack {
                Text("Filter by time range")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Added a small refresh button
                Button(action: {
                    withAnimation {
                        refreshDashboard()
                    }
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: selectedTimeRange) { newValue in
                // Show feedback when time range changes
                feedbackType = .info
                feedbackMessage = "Showing \(newValue.rawValue) view"
                withAnimation {
                    showFeedback = true
                }
                
                // Hide feedback after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showFeedback = false
                    }
                }
                
                // Request a data refresh when the time range changes
                viewModel.reloadData()
            }
            .cardAppear(delay: 0.3)
        }
    }
    
    private func quickStatsGrid() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(Array(viewModel.quickStats.enumerated()), id: \.element.id) { index, stat in
                NavigationLink(destination: destinationView(for: stat)) {
                    QuickStatCard(stat: stat)
                        .cardAppear(delay: 0.4 + Double(index) * 0.1)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    
    private func destinationView(for stat: QuickStat) -> AnyView {
        switch stat.title {
        case "Students":
            return AnyView(StudentsView())
        case "Classes":
            return AnyView(ClassesView())
        case "Assignments":
            return AnyView(AssignmentsView())
        case "Avg. Grade":
            return AnyView(GradebookView(classService: classService))
        default:
            return AnyView(Text("Feature not implemented yet").padding())
        }
    }
    
    private func upcomingAssignmentsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Assignments")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(selectedTimeRange.rawValue) view")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .cardAppear(delay: 0.6)
            
            // Filter assignments based on selected time range
            let filteredAssignments = viewModel.filterAssignmentsByTimeRange(
                timeRange: selectedTimeRange.rawValue,
                assignments: viewModel.upcomingAssignments
            )
            
            if filteredAssignments.isEmpty {
                VStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                    
                    Text("No upcoming assignments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                ForEach(Array(filteredAssignments.enumerated()), id: \.element.id) { index, assignment in
                    NavigationLink(destination: AssignmentsView()) {
                        DashboardAssignmentCard(assignment: assignment)
                            .listItemAppear(index: index)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private func recentActivitySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .cardAppear(delay: 0.8)
            
            ForEach(Array(viewModel.recentActivities.enumerated()), id: \.element.id) { index, activity in
                NavigationLink(destination: activityDestination(for: activity)) {
                    ActivityCard(activity: activity)
                        .listItemAppear(index: index)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func activityDestination(for activity: Activity) -> AnyView {
        switch activity.type {
        case .gradeUpdate:
            return AnyView(GradebookView(classService: classService))
        case .newAssignment:
            return AnyView(AssignmentsView())
        case .studentUpdate:
            return AnyView(StudentsView())
        case .systemNotice:
            return AnyView(SettingsView())
        }
    }
    
    // Refreshes dashboard data
    private func refreshDashboard() {
        viewModel.loadData()
        
        // Show a feedback message
        feedbackType = .success
        feedbackMessage = "Dashboard updated"
        withAnimation {
            showFeedback = true
        }
        
        // Hide feedback after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showFeedback = false
            }
        }
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let stat: QuickStat
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and icon
            HStack {
                Text(stat.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: stat.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(stat.trendDirection.color)
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            // Value display
            Text(stat.value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Trend indicator
            if !stat.trend.isEmpty {
                HStack(spacing: 4) {
                    if stat.trendDirection != .none {
                        Image(systemName: stat.trendDirection.icon)
                            .font(.caption)
                            .foregroundColor(stat.trendDirection.color)
                    }
                    
                    Text(stat.trend)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(stat.trendDirection.color)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(stat.trendDirection.color.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(stat.trendDirection.color.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Dashboard Assignment Card
struct DashboardAssignmentCard: View {
    let assignment: Assignment
    
    // Define a computed property to provide a color based on the assignment title
    private var assignmentColor: Color {
        // Use a hash of the name to generate a somewhat consistent color
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        let hash = abs(assignment.title.hashValue) % colors.count
        return colors[hash]
    }
    
    // Calculate days remaining until due date
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: assignment.dueDate)
        return components.day ?? 0
    }
    
    // Format the due date based on urgency
    private var formattedDueDate: String {
        if daysRemaining == 0 {
            return "Due today!"
        } else if daysRemaining == 1 {
            return "Due tomorrow"
        } else if daysRemaining > 1 && daysRemaining <= 7 {
            return "Due in \(daysRemaining) days"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return "Due \(formatter.string(from: assignment.dueDate))"
        }
    }
    
    // Color coding based on urgency
    private var urgencyColor: Color {
        if daysRemaining <= 1 {
            return .red
        } else if daysRemaining <= 3 {
            return .orange
        } else if daysRemaining <= 7 {
            return .blue
        } else {
            return .green
        }
    }
    
    // Workaround for when extensions aren't properly imported
    private var submittedCount: Int {
        return assignment.submissions.count
    }
    
    private var totalCount: Int {
        return 25 // Same placeholder as in the extension
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(urgencyColor) 
                .frame(width: 6, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !assignment.assignmentDescription.isEmpty {
                    Text(assignment.assignmentDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Text(formattedDueDate)
                    .font(.subheadline)
                    .foregroundColor(daysRemaining <= 1 ? .red : .secondary)
                    .fontWeight(daysRemaining <= 1 ? .semibold : .regular)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(submittedCount)/\(totalCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(Int((Double(submittedCount) / Double(totalCount)) * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(urgencyColor.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: urgencyColor.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    let activity: Activity
    
    // Format the relative time with more detail
    private var formattedTime: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: activity.timestamp, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced icon with animated gradient effect
            Image(systemName: activity.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [activity.type.color, activity.type.color.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                        .opacity(0.3)
                )
                .shadow(color: activity.type.color.opacity(0.3), radius: 3, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(4)
                    .background(activity.type.color.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(activity.type.color.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: activity.type.color.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// Extension to handle animation effects for cards
extension View {
    func cardAppear(delay: Double) -> some View {
        self.scaleEffect(1) // Start with normal scale
            .opacity(1) // Start with full opacity
    }
    
    func listItemAppear(index: Int) -> some View {
        self.opacity(1) // Start with full opacity
            .offset(y: 0) // No offset
    }
    
    func pressableButton() -> some View {
        self
    }
}

// Feedback View
struct FeedbackView: View {
    let message: String
    let type: FeedbackType
    @Binding var isPresented: Bool
    
    enum FeedbackType {
        case success, error, info, warning
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            case .warning: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(type.color)
            
            Text(message)
                .font(.subheadline)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    isPresented = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue]),
                            center: .center
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .onAppear {
                isAnimating = true
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(viewModel: DashboardViewModel())
            .environmentObject(AuthenticationService())
            .environmentObject(ClassService())
    }
}