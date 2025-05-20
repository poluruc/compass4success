import SwiftUI
import RealmSwift

@main
struct Compass4SuccessApp: SwiftUI.App {
    init() {
        let config = Realm.Configuration(
            schemaVersion: 2, // Increment this if you change Realm models again
            migrationBlock: { migration, oldSchemaVersion in
                // For most property adds/removes, this can be empty.
                // Add custom migration logic here if needed.
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }
    // Create instances of services to be injected into the environment
    @StateObject private var authService = AuthenticationService()
    @StateObject private var classService = ClassService()
    @StateObject private var appSettings = AppSettings()
    
    // Create a singleton dashboard view model to share across app
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @State private var selectedTab = 0 {
        didSet {
            // When switching back to the dashboard tab, refresh the data
            if selectedTab == 0 && oldValue != 0 {
                dashboardViewModel.loadDashboardData()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if #available(macOS 13.0, iOS 16.0, *) {
                MainContentView()
                    .environmentObject(authService)
                    .environmentObject(classService)
                    .environmentObject(appSettings)
                    .preferredColorScheme(appSettings.colorScheme)
            } else {
                // Fallback for older OS versions
                Text("This app requires macOS 13.0/iOS 16.0 or later")
                    .padding()
            }
        }
    }
}

// Main content view that handles authentication state
@available(macOS 13.0, iOS 16.0, *)
struct MainContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var classService: ClassService
    @EnvironmentObject var appSettings: AppSettings
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView(selection: $selectedTab) {
                    NavigationView {
                        DashboardView(viewModel: DashboardViewModel())
                            .environmentObject(appSettings)
                            .onAppear {
                                // Refresh dashboard data when tab is selected
                                selectedTab = 0
                            }
                    }
                    .tag(0)
                    .tabItem {
                        Label("Dashboard", systemImage: "house")
                    }
                    
                    NavigationView {
                        ClassesView()
                            .onAppear {
                                selectedTab = 1
                            }
                    }
                    .tag(1)
                    .tabItem {
                        Label("Classes", systemImage: "book")
                    }
                    
                    NavigationView {
                        StudentsView()
                            .onAppear {
                                selectedTab = 2
                            }
                    }
                    .tag(2)
                    .tabItem {
                        Label("Students", systemImage: "person.3")
                    }
                    
                    NavigationView {
                        AssignmentsView()
                            .onAppear {
                                selectedTab = 3
                            }
                    }
                    .tag(3)
                    .tabItem {
                        Label("Assignments", systemImage: "list.clipboard")
                    }
                    
                    NavigationView {
                        GradebookView()
                            .onAppear {
                                selectedTab = 4
                            }
                    }
                    .tag(4)
                    .tabItem {
                        Label("Gradebook", systemImage: "book.closed")
                    }
                    
                    NavigationView {
                        SettingsView()
                            .onAppear {
                                selectedTab = 5
                            }
                    }
                    .tag(5)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                }
                .accentColor(appSettings.accentColor)
                #if os(iOS)
                .edgesIgnoringSafeArea(.top)
                #endif
            } else {
                LoginView()
            }
        }
    }
}
