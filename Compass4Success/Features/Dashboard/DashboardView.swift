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
        ScrollView {
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
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.quickStats) { stat in
                                NavigationLink(destination: destinationView(for: stat)) {
                                    QuickStatCard(stat: stat)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Recent activity section
                VStack(alignment: .leading) {
                    Text("Recent Activity")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.recentActivities) { activity in
                        RecentActivityRow(activity: activity)
                    }
                }
                
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
                        }
                    }
                }
                
                // Announcements section
                VStack(alignment: .leading) {
                    Text("Announcements")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.announcements.isEmpty {
                        HStack {
                            Spacer()
                            Text("No announcements at this time")
                                .foregroundColor(.secondary)
                                .padding()
                            Spacer()
                        }
                    } else {
                        ForEach(viewModel.announcements) { announcement in
                            AnnouncementCard(announcement: announcement)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Dashboard")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: refreshDashboard) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    authService.logout()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
            #else
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
            #endif
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            viewModel.loadDashboardData()
        }
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
            }
            .padding(.bottom, 2)
            
            Text(stat.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: 200)
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.headline)
                
                // Use courseId instead of className since className doesn't exist
                Text("Course \(assignment.courseId.isEmpty ? "N/A" : assignment.courseId)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(assignment.dueDate, style: .date)
                    .font(.subheadline)
                
                HStack {
                    Image(systemName: "clock")
                    Text(assignment.dueDate, style: .time)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct AnnouncementCard: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(announcement.title)
                .font(.headline)
            
            Text(announcement.content)
                .font(.body)
                .lineLimit(3)
            
            HStack {
                Text("Posted by \(announcement.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(announcement.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
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