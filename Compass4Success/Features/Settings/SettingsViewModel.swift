import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var notificationOptions: [NotificationOption]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize notification options
        notificationOptions = [
            NotificationOption(id: "1", title: "Grade Updates", isEnabled: .constant(true)),
            NotificationOption(id: "2", title: "Assignment Reminders", isEnabled: .constant(true)),
            NotificationOption(id: "3", title: "Student Activity", isEnabled: .constant(false)),
            NotificationOption(id: "4", title: "School Announcements", isEnabled: .constant(true))
        ]
    }
    
    func updateNotifications(enabled: Bool) {
        // In a real app, this would update notification permissions
        print("Notifications \(enabled ? "enabled" : "disabled")")
    }
    
    func updateDarkMode(enabled: Bool) {
        // In a real app, this would update the app's appearance
        print("Dark mode \(enabled ? "enabled" : "disabled")")
    }
    
    func updateDataRefreshInterval(minutes: Int) {
        // In a real app, this would update the refresh interval for data
        print("Data refresh interval set to \(minutes) minutes")
    }
    
    func resetAllData() {
        // In a real app, this would clear local data, reset settings, etc.
        print("All data has been reset")
    }
}

class NotificationOption: Identifiable, ObservableObject {
    let id: String
    let title: String
    @Binding var isEnabled: Bool
    
    init(id: String, title: String, isEnabled: Binding<Bool>) {
        self.id = id
        self.title = title
        self._isEnabled = isEnabled
    }
}