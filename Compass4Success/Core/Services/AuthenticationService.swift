import Foundation
import Combine

// Simple placeholder for testing - renamed to MockUser to avoid conflicts
class MockUser {
    var id: String
    var name: String
    var email: String
    var role: String
    var firstName: String
    var lastName: String
    var allClasses: [MockSchoolClass] = []
    
    // Add properties needed by other parts of the app
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var canManageClasses: Bool {
        return role == "teacher" || role == "admin"
    }
    
    init(id: String, name: String, email: String, role: String) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        
        // Split name into first and last name
        let components = name.split(separator: " ", maxSplits: 1)
        self.firstName = String(components.first ?? "")
        self.lastName = components.count > 1 ? String(components[1]) : ""
    }
}

// Simple placeholder for SchoolClass to avoid dependency issues
class MockSchoolClass {
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

enum AuthenticationError: Error {
    case invalidCredentials
    case networkError
    case tokenExpired
    case invalidToken
    case serverError(String)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection error"
        case .tokenExpired:
            return "Session expired. Please login again"
        case .invalidToken:
            return "Invalid authentication token"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

class AuthenticationService: ObservableObject {
    @Published private(set) var currentUser: MockUser?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up with no authenticated user by default
        self.currentUser = nil
        self.isAuthenticated = false
        
        // For testing purposes, you can uncomment these lines to skip login
        /*
        let mockUser = MockUser(
            id: "1",
            name: "Test Teacher",
            email: "teacher@test.com",
            role: "teacher"
        )
        self.currentUser = mockUser
        self.isAuthenticated = true
        */
    }
    
    // Simple mock login function that always succeeds
    func login(email: String, password: String) -> AnyPublisher<MockUser, AuthenticationError> {
        let mockUser = MockUser(
            id: "1",
            name: "Test Teacher",
            email: email,
            role: "teacher"
        )
        
        return Just(mockUser)
            .setFailureType(to: AuthenticationError.self)
            .delay(for: 0.5, scheduler: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .eraseToAnyPublisher()
    }
    
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
    }
}