import SwiftUI

// Screen identifiers
public enum AppScreen: String, Identifiable {
    case assignmentList
    case assignmentDetail
    case addAssignment
    case editAssignment
    case assignmentSubmissions
    case crossClassAssignment
    
    case studentList
    case studentDetail
    case addStudent
    case editStudent
    
    case classList
    case classDetail
    case addClass
    case editClass
    case curriculum
    
    case dashboard
    case analytics
    case reports
    case gradebook
    case settings
    
    case login
    case register
    case resetPassword
    
    public var id: String { self.rawValue }
}

// Use this for screen factories to avoid duplicate view declarations
public protocol ScreenFactory {
    associatedtype Screen: View
    
    func makeScreen(for screen: AppScreen, withParams params: [String: Any]) -> Screen?
}

// Helper for navigating between screens
public class NavigationCoordinator: ObservableObject {
    @Published var activeScreen: AppScreen?
    @Published var screenParams: [String: Any] = [:]
    
    public init(startingScreen: AppScreen? = nil) {
        self.activeScreen = startingScreen
    }
    
    public func navigate(to screen: AppScreen, withParams params: [String: Any] = [:]) {
        self.activeScreen = screen
        self.screenParams = params
    }
    
    public func goBack() {
        self.activeScreen = nil
        self.screenParams = [:]
    }
}

// Use NavigationWrapper to prevent naming conflicts
public struct NavigationWrapper<Content: View>: View {
    private let content: Content
    private let navigationTitle: String
    
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.navigationTitle = title
        self.content = content()
    }
    
    public var body: some View {
        content
            .navigationTitle(navigationTitle)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}
