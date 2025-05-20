import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
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
        let content = ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome section
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome, \(getUserFirstName())")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("What would you like to do today?")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Quick stats section
                VStack(alignment: .leading) {
                    Text("Quick Stats")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.quickStats) { stat in
                            NavigationLink(destination: destinationView(for: stat)) {
                                QuickStatCard(stat: stat)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
                
                // Recent activity section
                VStack(alignment: .leading) {
                    Text("Recent Activity")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.recentActivities) { activity in
                        RecentActivityRow(activity: activity)
                            .pressableCard()
                    }
                }
                .padding(.bottom, 5)
                
                // Upcoming assignments section
                VStack(alignment: .leading) {
                    Text("Upcoming Assignments")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.upcomingAssignments.isEmpty {
                        HStack {
                            Spacer()
                            Text("No upcoming assignments")
                                .foregroundColor(.secondary)
                                .padding()
                            Spacer()
                        }
                    } else {
                        ForEach(viewModel.upcomingAssignments) { assignment in
                            UpcomingAssignmentRow(assignment: assignment)
                                .pressableCard()
                        }
                    }
                }
                .padding(.bottom, 5)
                
                // Announcements section
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "megaphone.fill")
                            .foregroundColor(.blue)
                            .font(.headline)
                        
                        Text("Announcements")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(viewModel.announcements.count)")
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal)
                    
                    // High Priority Badge - only show if there are high priority announcements
                    if viewModel.announcements.contains(where: { $0.priority == .high || $0.priority == .urgent }) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Text("Important announcements require your attention")
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.orange.gradient)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    
                    if viewModel.announcements.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "bell.slash")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray)
                                    )
                                    .padding(.bottom, 8)
                                
                                Text("No Announcements")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("You're all caught up!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .padding(.horizontal)
                            Spacer()
                        }
                    } else {
                        ForEach(viewModel.announcements) { announcement in
                            AnnouncementCard(announcement: announcement)
                                .pressableCard()
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.top)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.visible)
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        .padding(.bottom, 20)
        .navigationTitle("Dashboard")
        .onAppear {
            viewModel.loadDashboardData()
        }

        // Apply platform-specific modifiers outside the main view
        #if os(iOS)
        return content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    authService.logout()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
                .buttonStyle(PressableButtonStyle()),
                trailing: Button(action: refreshDashboard) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PressableButtonStyle())
            )
        #else
        return content
            .toolbar {
                ToolbarItem {
                    Button(action: refreshDashboard) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        authService.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        #endif
    }
    
    private func refreshDashboard() {
        viewModel.loadDashboardData()
    }
    
    // Helper method to safely get firstName from current user
    private func getUserFirstName() -> String {
        if let mockUser = authService.currentUser {
            return mockUser.firstName
        }
        return "Teacher"
    }
    
    @ViewBuilder
    private func destinationView(for stat: QuickStat) -> some View {
        switch stat.title {
        case "Students":
            StudentsView()
        case "Classes":
            if #available(macOS 13.0, iOS 16.0, *) {
                ClassesView()
            } else {
                Text("ClassesView requires macOS 13.0/iOS 16.0 or later")
            }
        case "Assignments":
            AssignmentsView()
        case "Analytics":
            if #available(macOS 13.0, iOS 16.0, *) {
                AnalyticsView()
            } else {
                Text("Analytics requires macOS 13.0/iOS 16.0 or later")
            }
        default:
            Text("Coming Soon")
        }
    }
}

// MARK: - Supporting Views

struct QuickStatCard: View {
    let stat: QuickStat
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: stat.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(stat.color)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    Text(stat.title)
                        .font(.headline)
                    
                    Text(stat.value)
                        .font(.title2)
                        .bold()
                }
                
                Spacer(minLength: 0)
            }
            .padding(.bottom, 2)
            
            Text(stat.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(height: 120) // Fixed height for consistency
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct RecentActivityRow: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack {
            Image(systemName: activity.icon)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(activity.color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.headline)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct UpcomingAssignmentRow: View {
    let assignment: Assignment
    
    var body: some View {
        NavigationLink(destination: AssignmentDetailView(assignment: assignment)) {
            HStack {
                // Left side - assignment icon and colored indicator
                VStack {
                    Image(systemName: "list.clipboard")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.trailing, 4)
                
                // Middle - assignment details
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.title)
                        .font(.headline)
                    
                    // Use courseId instead of className since className doesn't exist
                    Text("Course \(assignment.courseId.isEmpty ? "N/A" : assignment.courseId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Right side - date information with colored emphasis
                VStack(alignment: .trailing, spacing: 4) {
                    Text(assignment.dueDate, style: .date)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(assignment.dueDate, style: .time)
                            .foregroundColor(.blue)
                    }
                    .font(.caption)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle()) // This prevents the navigation link from changing the appearance
        .padding(.horizontal)
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct AnnouncementCard: View {
    let announcement: Announcement
    @State private var isExpanded = false
    
    // Get appropriate icon based on priority
    private var priorityIcon: String {
        switch announcement.priority {
        case .low:
            return "info.circle"
        case .normal:
            return "bell"
        case .high:
            return "exclamationmark.triangle"
        case .urgent:
            return "exclamationmark.3"
        }
    }
    
    // Time ago formatting
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: announcement.date, relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with priority indicator
            HStack(alignment: .top) {
                // Priority indicator and icon
                ZStack {
                    Circle()
                        .fill(announcement.priority.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: priorityIcon)
                        .font(.system(size: 20))
                        .foregroundColor(announcement.priority.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title with badge
                    HStack {
                        Text(announcement.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if announcement.priority == .high || announcement.priority == .urgent {
                            Text(announcement.priority.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(announcement.priority.color.opacity(0.2))
                                .foregroundColor(announcement.priority.color)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Author and date
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(announcement.author)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Content - only visible when expanded or if content is short
            if isExpanded || announcement.content.count < 80 {
                Text(announcement.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
            } else {
                Text(announcement.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
            }
            
            // Conditional footer for actions
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                
                HStack {
                    Button(action: {
                        // Action for responding to announcement
                    }) {
                        Label("Respond", systemImage: "arrowshape.turn.up.right")
                            .font(.caption)
                            .foregroundColor(announcement.priority.color)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for marking as read
                    }) {
                        Label("Mark as Read", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(announcement.priority.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView(viewModel: DashboardViewModel())
                .environmentObject(AuthenticationService())
                .environmentObject(ClassService())
        }
    }
}