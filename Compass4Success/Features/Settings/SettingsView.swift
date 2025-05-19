import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("dataRefreshInterval") private var dataRefreshInterval = 30 // minutes
    @State private var showLogoutAlert = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let user = authService.currentUser as? MockUser {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(user.role.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            } else {
                                Text("User")
                                    .font(.headline)
                                Text("Not signed in")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    NavigationLink(destination: Text("Profile Settings").padding()) {
                        Label("Edit Profile", systemImage: "pencil")
                    }
                    
                    Button(action: { showLogoutAlert = true }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .onChange(of: darkModeEnabled) { newValue in
                            viewModel.updateDarkMode(enabled: newValue)
                        }
                    
                    NavigationLink(destination: AppearanceSettingsView()) {
                        Label("Theme & Colors", systemImage: "paintbrush")
                    }
                    
                    NavigationLink(destination: FontSettingsView()) {
                        Label("Text Size & Font", systemImage: "textformat.size")
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            viewModel.updateNotifications(enabled: newValue)
                        }
                    
                    if notificationsEnabled {
                        ForEach(viewModel.notificationOptions) { option in
                            Toggle(option.title, isOn: option.isEnabled)
                        }
                        
                        NavigationLink(destination: NotificationSettingsView()) {
                            Label("Advanced Notification Settings", systemImage: "bell.badge")
                        }
                    }
                }
                
                Section(header: Text("Data & Privacy")) {
                    Picker("Data Refresh Interval", selection: $dataRefreshInterval) {
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                        Text("2 hours").tag(120)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: dataRefreshInterval) { newValue in
                        viewModel.updateDataRefreshInterval(minutes: newValue)
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("Privacy Settings", systemImage: "lock.shield")
                    }
                    
                    Button(action: { showResetAlert = true }) {
                        Label("Reset All Data", systemImage: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Help & Support")) {
                    ForEach(SupportOption.allOptions) { option in
                        NavigationLink(destination: supportDestination(for: option)) {
                            Label(option.title, systemImage: option.icon)
                        }
                    }
                }
                
                Section(footer: Text("Compass4Success v1.0.0 • © 2025 Compass Education")) {
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                    }
                    
                    Link(destination: URL(string: "https://www.compass4success.edu/terms")!) {
                        HStack {
                            Label("Terms of Service", systemImage: "doc.text")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.compass4success.edu/privacy")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Reset Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("This will reset all app data. This action cannot be undone.")
            }
        }
    }
    
    @ViewBuilder
    private func supportDestination(for option: SupportOption) -> some View {
        switch option {
        case .faq:
            FAQView()
        case .contactSupport:
            ContactSupportView()
        case .reportIssue:
            ReportIssueView()
        case .userGuide:
            UserGuideView()
        default:
            Text(option.title)
                .padding()
        }
    }
}

// Placeholder views for navigation destinations
struct AppearanceSettingsView: View {
    var body: some View {
        Text("Appearance Settings")
            .navigationTitle("Theme & Colors")
    }
}

struct FontSettingsView: View {
    var body: some View {
        Text("Font Settings")
            .navigationTitle("Text Size & Font")
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        Text("Notification Settings")
            .navigationTitle("Notifications")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .navigationTitle("Privacy")
    }
}

struct FAQView: View {
    var body: some View {
        Text("Frequently Asked Questions")
            .navigationTitle("FAQ")
    }
}

struct ContactSupportView: View {
    var body: some View {
        Text("Contact Support")
            .navigationTitle("Support")
    }
}

struct ReportIssueView: View {
    var body: some View {
        Text("Report Issue")
            .navigationTitle("Report Issue")
    }
}

struct UserGuideView: View {
    var body: some View {
        Text("User Guide")
            .navigationTitle("User Guide")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "graduationcap.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Compass4Success")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .foregroundColor(.secondary)
            
            Text("© 2025 Compass Education")
                .font(.caption)
                .padding(.top, 5)
            
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationService())
    }
}