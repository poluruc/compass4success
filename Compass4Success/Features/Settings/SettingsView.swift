import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dataRefreshInterval") private var dataRefreshInterval = 30 // minutes
    @State private var showLogoutAlert = false
    @State private var showResetAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Account")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(appSettings.accentColor)
                    
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
                
                NavigationLink(destination: ProfileSettingsView()) {
                    Label("Edit Profile", systemImage: "pencil")
                }
                
                Button(action: { showLogoutAlert = true }) {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Appearance")) {
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
                        Toggle(option.title, isOn: option.$isEnabled)
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

            Section(header: Text("Rubric Templates")) {
                NavigationLink(destination: RubricTemplatesView()) {
                    Label("Manage Rubric Templates", systemImage: "list.bullet.rectangle.portrait")
                }
            }
            
            Section(header: Text("Help & Support")) {
                ForEach(SettingsSupportOption.allOptions) { option in
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
        .navigationBarTitleDisplayMode(.inline)
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
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    @ViewBuilder
    private func supportDestination(for option: SettingsSupportOption) -> some View {
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

// Profile Settings View
struct ProfileSettingsView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var role = ""
    @State private var bio = ""
    @State private var notifications = true
    @State private var showSaveAlert = false
    
    // Retrieve user data in a real app
    private func loadUserData() {
        // Mock data for preview
        firstName = "Test"
        lastName = "Teacher"
        email = "teacher@demo.com"
        role = "Teacher"
        bio = "Experienced educator focused on student success."
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile photo
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.blue.opacity(0.1)).frame(width: 110, height: 110))
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 110, height: 110)
                            )
                        
                        Button("Change Photo") {
                            // Photo picker would be implemented here
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                // Personal Information
                GroupBox(label: Label("Personal Information", systemImage: "person.fill")) {
                    VStack(spacing: 15) {
                        TextField("First Name", text: $firstName)
                            .appTextFieldStyle()

                        
                        TextField("Last Name", text: $lastName)
                           .appTextFieldStyle()
                        
                        TextField("Email", text: $email)
                           .appTextFieldStyle()
                            .keyboardType(.emailAddress)
                        
                        TextField("Role", text: $role)
                            .appTextFieldStyle()
                            .disabled(true) // Role usually can't be changed by user
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // Bio
                GroupBox(label: Label("Bio", systemImage: "text.quote")) {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // Save button
                Button(action: {
                    // Save profile changes
                    showSaveAlert = true
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .alert("Profile Updated", isPresented: $showSaveAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Your profile has been successfully updated.")
                }
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle("Profile Settings")
        .onAppear(perform: loadUserData)
    }
}

// Appearance settings with actual functionality
struct AppearanceSettingsView: View {
    @EnvironmentObject var appSettings: AppSettings

    private let themes: [(String, ColorScheme?)] = [
        ("System", nil),
        ("Light", .light),
        ("Dark", .dark)
    ]
    private let predefinedColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Theme selection
                GroupBox(label: Label("Interface Theme", systemImage: "paintpalette")) {
                    Picker("Select Theme", selection: $appSettings.colorScheme) {
                        ForEach(themes, id: \.0) { (name, scheme) in
                            Text(name).tag(scheme as ColorScheme?)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)

                // Accent Color selection
                GroupBox(label: Label("Accent Color", systemImage: "circle.fill").foregroundColor(appSettings.accentColor)) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Choose a predefined color:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 10) {
                            ForEach(predefinedColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(appSettings.accentColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        appSettings.accentColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 10)

                        // Secondary color display (read-only)
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Secondary Color")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(appSettings.secondaryColor)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.secondary, lineWidth: 1)
                                        )
                                    Text(appSettings.secondaryColor.description.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                        .opacity(0.8)
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        .navigationTitle("Theme & Colors")
    }
}

// Font settings with real functionality
struct FontSettingsView: View {
    @AppStorage("fontSize") private var fontSize: Double = 1.0 // 1.0 = default
    @AppStorage("fontName") private var fontName: String = "System"
    
    private let fontOptions = ["System", "Rounded", "Serif", "Monospaced"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Text size
                GroupBox(label: Label("Text Size", systemImage: "textformat.size")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Adjust the text size:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $fontSize, in: 0.8...1.3, step: 0.05) {
                            Text("Text Size")
                        } minimumValueLabel: {
                            Text("A").font(.caption)
                        } maximumValueLabel: {
                            Text("A").font(.title3)
                        }
                        .padding(.vertical, 5)
                        
                        // Text size preview
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Preview")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("This is how text will appear in the app.")
                                .font(.system(size: 17 * fontSize))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // Font selection
                GroupBox(label: Label("Font Style", systemImage: "character")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose a font style:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Font Selection", selection: $fontName) {
                            ForEach(fontOptions, id: \.self) { font in
                                Text(font).tag(font)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 10)
                        
                        // Font preview
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Preview")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Group {
                                if fontName == "System" {
                                    Text("This is the System font.")
                                } else if fontName == "Rounded" {
                                    Text("This is the Rounded font.")
                                        .font(.system(.body, design: .rounded))
                                } else if fontName == "Serif" {
                                    Text("This is the Serif font.")
                                        .font(.system(.body, design: .serif))
                                } else if fontName == "Monospaced" {
                                    Text("This is the Monospaced font.")
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Text Size & Font")
    }
}

// Placeholder views for other navigation destinations
struct NotificationSettingsView: View {
    @AppStorage("pushNotificationsEnabled") private var pushNotificationsEnabled = true
    @AppStorage("emailNotificationsEnabled") private var emailNotificationsEnabled = false
    @AppStorage("notificationSound") private var notificationSound = "Default"
    @AppStorage("doNotDisturbStart") private var doNotDisturbStart = 22
    @AppStorage("doNotDisturbEnd") private var doNotDisturbEnd = 7
    @AppStorage("assignmentRemindersEnabled") private var assignmentRemindersEnabled = true
    @AppStorage("assignmentReminderTime") private var assignmentReminderTime = 30 // minutes before
    @AppStorage("classAnnouncementsEnabled") private var classAnnouncementsEnabled = true
    @AppStorage("studentActivityAlertsEnabled") private var studentActivityAlertsEnabled = true
    
    private let sounds = ["Default", "Chime", "Alert", "Bell", "Silent"]
    private let reminderTimes = [5, 10, 15, 30, 60, 120]
    
    var body: some View {
        Form {
            Section(header: Text("Notification Types")) {
                Toggle("Push Notifications", isOn: $pushNotificationsEnabled)
                Toggle("Email Notifications", isOn: $emailNotificationsEnabled)
            }
            
            Section(header: Text("Notification Sound")) {
                Picker("Sound", selection: $notificationSound) {
                    ForEach(sounds, id: \.self) { sound in
                        Text(sound)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Section(header: Text("Do Not Disturb"), footer: Text("Notifications will be muted during this time range.")) {
                HStack {
                    Text("From")
                    Spacer()
                    Picker("Start", selection: $doNotDisturbStart) {
                        ForEach(0..<24) { hour in
                            Text(String(format: "%02d:00", hour)).tag(hour)
                        }
                    }
                    .labelsHidden()
                    Text("to")
                    Picker("End", selection: $doNotDisturbEnd) {
                        ForEach(0..<24) { hour in
                            Text(String(format: "%02d:00", hour)).tag(hour)
                        }
                    }
                    .labelsHidden()
                }
            }
            
            Section(header: Text("Assignment Reminders")) {
                Toggle("Enable Assignment Reminders", isOn: $assignmentRemindersEnabled)
                if assignmentRemindersEnabled {
                    Picker("Remind me before", selection: $assignmentReminderTime) {
                        ForEach(reminderTimes, id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            Section(header: Text("Other Notifications")) {
                Toggle("Class Announcements", isOn: $classAnnouncementsEnabled)
                Toggle("Student Activity Alerts", isOn: $studentActivityAlertsEnabled)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacySettingsView: View {
    @State private var shareAnalytics = true
    @State private var shareCrashReports = true
    @State private var personalizedContent = false
    @State private var locationServices = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero section
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.5)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Privacy Matters")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Control how your data is used within the app")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Image(systemName: "lock.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 20)
                            .padding(.trailing, 20)
                    }
                }
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Data Usage Section
                GroupBox(label: 
                    Label("Data Usage", systemImage: "chart.bar.doc.horizontal")
                        .font(.headline)
                        .foregroundColor(.primary)
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Share Analytics", isOn: $shareAnalytics)
                            .tint(.blue)
                        
                        Divider()
                        
                        Toggle("Share Crash Reports", isOn: $shareCrashReports)
                            .tint(.blue)
                        
                        Divider()
                        
                        Toggle("Personalized Content", isOn: $personalizedContent)
                            .tint(.blue)
                        
                        Text("Analytics help us improve the app experience and fix issues. No personally identifiable information is collected.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // Location Services
                GroupBox(label: 
                    Label("Location Services", systemImage: "location.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Enable Location Access", isOn: $locationServices)
                            .tint(.blue)
                        
                        Text("Location is only used when required for specific features like nearby school search. Your location history is not stored or shared.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // Privacy Choices
                GroupBox(label: 
                    Label("Your Privacy Choices", systemImage: "person.badge.shield.checkmark")
                        .font(.headline)
                        .foregroundColor(.primary)
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        NavigationLink(destination: Text("Download Your Data").navigationTitle("Download Data")) {
                            HStack {
                                Image(systemName: "arrow.down.doc.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Download Your Data")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Get a copy of all your data")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Delete Account Data")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Permanently remove your data")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // Privacy Policy
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacy Policy")
                            .font(.headline)
                        
                        Text("Our full privacy policy explains how we collect, use, and protect your personal information.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link(destination: URL(string: "https://www.compass4success.edu/privacy")!) {
                            Text("Read Privacy Policy")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle("Privacy Settings")
        .alert("Delete Account Data", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // This would trigger actual data deletion flow
            }
        } message: {
            Text("This will permanently delete all your data from our servers. This action cannot be undone.")
        }
    }
}

struct FAQView: View {
    @State private var expandedItems = Set<Int>()
    @State private var searchText = ""
    
    // Sample FAQ data
    private let faqItems = [
        FAQItem(question: "How do I add a new class?", 
                answer: "To add a new class, navigate to the Classes tab and tap the '+' button in the top right corner. Fill in the required information like class name, subject, and grade level. Then tap 'Save' to create your new class."),
        FAQItem(question: "How do I track student attendance?", 
                answer: "You can track attendance by selecting a class, then tapping on the 'Attendance' tab. From there, you can mark students as present, absent, or tardy. The system automatically saves attendance records for future reference."),
        FAQItem(question: "Can I export student data?", 
                answer: "Yes, you can export student data in various formats. Navigate to the Analytics section and select the data you want to export. Tap the 'Export' button and choose your preferred format (CSV, PDF, or Excel)."),
        FAQItem(question: "How do I reset my password?", 
                answer: "To reset your password, go to the login screen and tap 'Forgot Password'. Enter your email address and follow the instructions sent to your email to create a new password."),
        FAQItem(question: "Is my data backed up automatically?", 
                answer: "Yes, all your data is automatically backed up to our secure cloud servers. You can access your data from any device by simply logging into your account."),
        FAQItem(question: "How do I contact support?", 
                answer: "You can contact support through the app by going to Settings > Help & Support > Contact Support. Alternatively, you can email us directly at support@compass4success.edu."),
        FAQItem(question: "Can I use the app offline?", 
                answer: "Yes, many features of the app work offline. Your changes will sync automatically when you reconnect to the internet."),
        FAQItem(question: "How do I create assignments for my class?", 
                answer: "To create an assignment, go to the Assignments tab and tap the '+' button. Enter the assignment details, select the class it belongs to, set a due date, and tap 'Save'."),
        FAQItem(question: "How do I view analytics for my classes?", 
                answer: "Go to the Analytics tab to view comprehensive statistics and visualizations for your classes. You can filter by class, time period, and specific metrics to get detailed insights.")
    ]
    
    var filteredFAQs: [FAQItem] {
        if searchText.isEmpty {
            return faqItems
        } else {
            return faqItems.filter { item in
                item.question.lowercased().contains(searchText.lowercased()) ||
                item.answer.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search FAQs", text: $searchText)
                    .appTextFieldStyle()
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)
            .cornerRadius(15)

            // Modern rounded header
            RoundedHeaderCard(
                title: "Frequently Asked Questions",
                subtitle: "Find answers to common questions",
                icon: "questionmark.circle.fill"
            )

            // FAQ list
            ScrollView {
                VStack(spacing: 12) {
                    Text("\(filteredFAQs.count) results")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    ForEach(Array(filteredFAQs.enumerated()), id: \.element.id) { index, item in
                        FAQItemView(
                            item: item, 
                            isExpanded: expandedItems.contains(index),
                            toggleExpand: {
                                if expandedItems.contains(index) {
                                    expandedItems.remove(index)
                                } else {
                                    expandedItems.insert(index)
                                }
                            }
                        )
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 20) {
                        Text("Still have questions?")
                            .font(.headline)
                        
                        Button(action: {
                            // Navigate to contact support
                        }) {
                            Label("Contact Support Team", systemImage: "message.fill")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let toggleExpand: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggleExpand) {
                HStack {
                    Text(item.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                    
                    Text(item.answer)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding([.horizontal, .bottom])
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .animation(.spring(), value: isExpanded)
    }
}

struct ContactSupportView: View {
    @State private var subject = ""
    @State private var message = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var preferredContact = "Email"
    @State private var showSuccessAlert = false
    @State private var isSubmitting = false
    
    private let contactOptions = ["Email", "Phone", "Both"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Modern rounded header
                RoundedHeaderCard(
                    title: "Contact Support",
                    subtitle: "We're here to help with any questions",
                    icon: "envelope.fill"
                )
                
                VStack(spacing: 24) {
                    // Support options cards
                    HStack(spacing: 12) {
                        SupportOptionCard(
                            icon: "mail.fill",
                            title: "Email",
                            subtitle: "support@compass4success.edu",
                            color: .blue
                        )
                        
                        SupportOptionCard(
                            icon: "phone.fill",
                            title: "Call",
                            subtitle: "1-800-COMPASS",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Chat status indicator
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        
                        Text("Support agents are online")
                            .font(.subheadline)
                        
                        Text("• Average response time: 15 mins")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
                    
                    // Contact form
                    GroupBox(label: Label("Send us a message", systemImage: "message.fill")) {
                        VStack(alignment: .leading, spacing: 16) {
                            TextField("Subject", text: $subject)
                                .appTextFieldStyle()
                            
                            Text("Message")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $message)
                                .frame(minHeight: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                            Text("Contact Information")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            TextField("Email Address", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .appTextFieldStyle()
                            
                            TextField("Phone Number (optional)", text: $phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.phonePad)
                                .appTextFieldStyle()
                            
                            Picker("Preferred Contact Method", selection: $preferredContact) {
                                ForEach(contactOptions, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 8)
                            
                            Button(action: {
                                submitSupportRequest()
                            }) {
                                Group {
                                    if isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Submit")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(subject.isEmpty || message.isEmpty || email.isEmpty || isSubmitting)
                            .opacity((subject.isEmpty || message.isEmpty || email.isEmpty) ? 0.6 : 1)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // FAQ shortcuts
                    GroupBox(label: Label("Frequently Asked Questions", systemImage: "questionmark.circle.fill")) {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(faqShortcuts, id: \.title) { shortcut in
                                NavigationLink(destination: FAQView()) {
                                    HStack {
                                        Text(shortcut.title)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if shortcut.title != faqShortcuts.last?.title {
                                    Divider()
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Message Sent", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for contacting us. We'll respond to your inquiry as soon as possible.")
        }
    }
    
    private func submitSupportRequest() {
        isSubmitting = true
        
        // Simulating network request delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccessAlert = true
            
            // Reset the form
            subject = ""
            message = ""
        }
    }
    
    private let faqShortcuts = [
        FAQShortcut(title: "How do I reset my password?"),
        FAQShortcut(title: "Can I use the app offline?"),
        FAQShortcut(title: "How do I create assignments?"),
        FAQShortcut(title: "How to view analytics?")
    ]
}

struct FAQShortcut {
    let title: String
}

struct SupportOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(color.opacity(0.7))
                    .font(.headline)
            }
            
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ReportIssueView: View {
    @State private var issueCategory = "App Functionality"
    @State private var issueDescription = ""
    @State private var severity = "Medium"
    @State private var email = ""
    @State private var attachScreenshot = false
    @State private var showSuccessAlert = false
    @State private var isSubmitting = false
    
    private let categories = ["App Functionality", "User Interface", "Performance", "Data Issues", "Other"]
    private let severityLevels = ["Low", "Medium", "High", "Critical"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Modern rounded header
                RoundedHeaderCard(
                    title: "Report an Issue",
                    subtitle: "Help us improve by reporting problems",
                    icon: "exclamationmark.triangle.fill"
                )
                
                VStack(spacing: 20) {
                    // Issue reporting instructions
                    HStack(spacing: 20) {
                        ForEach(0..<3) { i in
                            StepCard(
                                step: i+1,
                                title: ["Describe", "Attach", "Submit"][i],
                                description: [
                                    "Explain the issue in detail",
                                    "Add screenshots if needed",
                                    "Submit and track progress"
                                ][i]
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Issue form
                    GroupBox(label: Label("Issue Details", systemImage: "doc.text.fill")) {
                        VStack(alignment: .leading, spacing: 16) {
                            // Category
                            Text("Issue Category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Category", selection: $issueCategory) {
                                ForEach(categories, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            // Description
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            
                            TextEditor(text: $issueDescription)
                                .frame(minHeight: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Text("Please describe what happened, what you expected to happen, and steps to reproduce...")
                                        .foregroundColor(.gray.opacity(0.8))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                        .allowsHitTesting(false),
                                    alignment: .topLeading
                                )
                                .opacity(issueDescription.isEmpty ? 1 : 0)
                            
                            // Severity
                            Text("Severity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            
                            Picker("Severity", selection: $severity) {
                                ForEach(severityLevels, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            // Contact info
                            Text("Contact Email (optional)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            
                            TextField("Your email for follow-up", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .appTextFieldStyle()
                            
                            // Attachments
                            Toggle("Attach Screenshot", isOn: $attachScreenshot)
                                .padding(.vertical, 8)
                            
                            if attachScreenshot {
                                HStack {
                                    Image(systemName: "photo.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray.opacity(0.3))
                                        .overlay(
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.blue)
                                                .background(Circle().fill(Color.white))
                                                .offset(x: 10, y: 10)
                                        )
                                    
                                    Text("Tap to add a screenshot")
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            // Submit button
                            Button(action: {
                                submitIssueReport()
                            }) {
                                Group {
                                    if isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Submit Issue Report")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(issueDescription.isEmpty || isSubmitting)
                            .opacity(issueDescription.isEmpty ? 0.6 : 1)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Issue tips
                    GroupBox(label: Label("Tips for Effective Reports", systemImage: "lightbulb.fill")) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(reportingTips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    
                                    Text(tip)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if tip != reportingTips.last {
                                    Divider()
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Report Issue")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Issue Reported", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for your report. Our team will investigate this issue promptly.")
        }
    }
    
    private func submitIssueReport() {
        isSubmitting = true
        
        // Simulating network request delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccessAlert = true
            
            // Reset the form
            issueDescription = ""
            severity = "Medium"
            attachScreenshot = false
        }
    }
    
    private let reportingTips = [
        "Be specific about what happened",
        "Include steps to reproduce the issue",
        "Mention device model and OS version",
        "Add screenshots for visual issues"
    ]
}

struct StepCard: View {
    let step: Int
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 36, height: 36)
                
                Text("\(step)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct UserGuideView: View {
    @State private var searchText = ""
    @State private var selectedCategory: GuideCategory? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search guide", text: $searchText)
                        .appTextFieldStyle()
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // Hero section
                ZStack {
                    Image(systemName: "book.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .foregroundColor(.blue.opacity(0.1))
                    
                    VStack(spacing: 16) {
                        Text("User Guide")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Everything you need to know about using Compass4Success")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: 300)
                    }
                }
                .padding(30)
                
                // Categories
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(GuideCategory.allCategories) { category in
                        GuideCategoryCard(category: category)
                            .onTapGesture {
                                selectedCategory = category
                            }
                    }
                }
                .padding()
                
                // Quick start guide
                if selectedCategory == nil {
                    GroupBox(label: Label("Quick Start Guide", systemImage: "bolt.fill")) {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(quickStartItems) { item in
                                HStack(alignment: .top, spacing: 16) {
                                    Image(systemName: item.icon)
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.headline)
                                        
                                        Text(item.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if item.id != quickStartItems.last?.id {
                                    Divider()
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                } else {
                    // Category detail
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Button(action: {
                                selectedCategory = nil
                            }) {
                                Label("Back to Categories", systemImage: "chevron.left")
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Text(selectedCategory?.name ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(guideItems.filter { $0.category == selectedCategory }) { item in
                            GuideItemRow(item: item)
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("User Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private let quickStartItems = [
        QuickStartItem(id: 1, icon: "person.crop.circle.badge.plus", title: "Create Your Profile", description: "Set up your profile with your school information and preferences"),
        QuickStartItem(id: 2, icon: "rectangle.grid.1x2.fill", title: "Navigate the Dashboard", description: "View announcements, upcoming assignments, and student metrics"),
        QuickStartItem(id: 3, icon: "person.3.fill", title: "Manage Classes", description: "Add classes, enroll students, and track attendance"),
        QuickStartItem(id: 4, icon: "chart.bar.fill", title: "View Analytics", description: "Examine student performance data and identify trends")
    ]
    
    private let guideItems: [GuideItem] = GuideCategory.allCategories.flatMap { category in
        (1...4).map { i in
            GuideItem(
                id: "\(category.id)_\(i)",
                title: "Guide \(i) for \(category.name)",
                description: "Learn how to use \(category.name) features effectively",
                category: category
            )
        }
    }
}

struct QuickStartItem: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let description: String
}

struct GuideCategory: Identifiable, Equatable {
    public let id: String
    let name: String
    let icon: String
    let color: Color
    
    static func == (lhs: GuideCategory, rhs: GuideCategory) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let allCategories = [
        GuideCategory(id: "dashboard", name: "Dashboard", icon: "house.fill", color: .blue),
        GuideCategory(id: "classes", name: "Classes", icon: "person.3.fill", color: .green),
        GuideCategory(id: "assignments", name: "Assignments", icon: "list.clipboard.fill", color: .orange),
        GuideCategory(id: "analytics", name: "Analytics", icon: "chart.pie.fill", color: .purple),
        GuideCategory(id: "calendar", name: "Calendar", icon: "calendar", color: .red),
        GuideCategory(id: "messages", name: "Messages", icon: "bubble.left.and.bubble.right.fill", color: .cyan)
    ]
}

struct GuideItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: GuideCategory
}

struct GuideCategoryCard: View {
    let category: GuideCategory
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.largeTitle)
                .foregroundColor(category.color)
            
            Text(category.name)
                .font(.headline)
            
            Text("4 guides")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct GuideItemRow: View {
    let item: GuideItem
    
    var body: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundColor(item.category.color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
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

// Helper extension to convert Color to hex string
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != Float(1.0) {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

// Support option enum
enum SettingsSupportOption: String, CaseIterable, Identifiable {
    case faq = "FAQ"
    case contactSupport = "Contact Support"
    case reportIssue = "Report Issue"
    case userGuide = "User Guide"
    
    public var id: String { self.rawValue }
    
    var title: String {
        self.rawValue
    }
    
    var icon: String {
        switch self {
        case .faq:
            return "questionmark.circle"
        case .contactSupport:
            return "message.fill"
        case .reportIssue:
            return "exclamationmark.triangle"
        case .userGuide:
            return "book.fill"
        }
    }
    
    static var allOptions: [SettingsSupportOption] {
        self.allCases
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationService())
    }
}

