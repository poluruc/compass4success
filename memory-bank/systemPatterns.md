# Compass4Success System Patterns

*Last Updated: May 16, 2025*

## Project Structure

The Compass4Success application follows this directory structure:

```
Compass4Success/
    App/                    # App entry point and configuration
    Core/                   # Shared models, services, and utilities
        Extensions/
        Models/             # Data models using Realm
        Services/           # Business logic and data services
        Utils/
        Views/              # Shared view components
    Features/               # Feature modules
        Analytics/          # Analytics dashboards and visualizations
        Assignments/        # Assignment management
        Authentication/     # Login and authentication
        Classes/            # Class management
        Dashboard/          # Main dashboard
        Gradebook/          # Grading interface
        Settings/           # Application settings
        Students/           # Student management
    Resources/              # Static resources
    UI/                     # Shared UI components
```

### Key Project Structure Notes

1. The Xcode project file is located at `/Users/poluruc/chandra/work/cline/compass4success/Compass4Success/Compass4Success.xcodeproj`.
2. The project also has a Swift Package Manager (SPM) setup.
3. File organization follows a Feature Module pattern where specific functionality is grouped into feature folders.
4. The core models and services are kept in a "Core" directory to be shared across features.

## System Architecture

Compass4Success follows a modular architecture organized into distinct layers:

```
App Layer → Features Layer → Core Layer → Persistence Layer
```

### Layer Responsibilities

1. **App Layer**: Entry point, authentication state, global navigation
2. **Features Layer**: Domain-specific functionality (Dashboard, Gradebook, etc.)
3. **Core Layer**: Business logic, models, services, utilities
4. **Persistence Layer**: Data storage using Realm

## Cross-Platform Architecture

The application is designed to work on both iOS and macOS with minimal platform-specific code:

### Shared Core

- All models, services, and business logic are platform-agnostic
- ViewModels remain the same across platforms
- Data flow and authentication mechanisms are identical

### Platform Adaptation

- UI components adapt to platform conventions
- Navigation follows platform patterns (tabs on iOS, sidebar on macOS)
- Platform-specific features are conditionally included

### Platform Detection

```swift
// Conditional compilation
#if os(iOS)
    // iOS-specific code
#else
    // macOS-specific code
#endif

// API availability
@available(macOS 13.0, iOS 16.0, *)
struct MyView: View {
    // Uses APIs available on macOS 13.0+ and iOS 16.0+
}
```

## Design Patterns

### MVVM (Model-View-ViewModel)

The application follows the MVVM pattern:
- **Models**: Data structures (Student, Assignment, etc.)
- **Views**: SwiftUI views for user interfaces
- **ViewModels**: State management, business logic processing

Example implementation:
```swift
// Model
class Student: Object, Identifiable { ... }

// ViewModel
class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    
    func fetchStudents() { ... }
    func addStudent(_ student: Student) { ... }
}

// View
struct StudentsView: View {
    @StateObject private var viewModel = StudentViewModel()
    
    var body: some View {
        // UI bound to viewModel
    }
}
```

### Publisher-Subscriber Pattern

Utilizes Combine framework for reactive programming:
- Services publish updates
- Views subscribe to relevant data
- State changes propagate automatically

### Dependency Injection

Services are injected rather than created directly:
```swift
class AnalyticsService {
    init(classService: ClassService) {
        self.classService = classService
    }
}
```

## Component Relationships

### Authentication Flow

```
LoginView → AuthenticationService → App Router → MainTabView
```

### Data Flow

```
User Interaction → View → ViewModel → Service → Realm Database
```

### Analytics Flow

```
Raw Data → AnalyticsService → Transformation → Analytics Models → Visualization
```

## Troubleshooting Patterns

### Build Error Resolution

1. **Incremental Building**: Fix one component at a time, building after each change
2. **Error Categorization**: Group errors by type (model, UI, platform compatibility)
3. **Dependency Chain**: Resolve upstream errors before downstream ones
4. **Minimal Reproduction**: Create simplified test cases for complex errors

### Common Error Patterns and Solutions

#### Type Checking Timeouts
- **Pattern**: Complex nested generic views cause compiler to time out
- **Solution**: Break down complex views into smaller components with explicit types

```swift
// BAD: Complex nested generics
List {
    ForEach(viewModel.complexData) { item in
        ComplexView(with: item.nestedData.map { transform($0) })
    }
}

// GOOD: Simpler with explicit types
List {
    ForEach(viewModel.complexData, id: \.id) { item in
        SimpleItemRow(item: item)
    }
}
```

#### Platform Compatibility Errors
- **Pattern**: Using APIs not available on all target platforms
- **Solution**: Use availability checking and conditionals

```swift
// BAD: Using APIs without availability check
Section("Settings") {
    Toggle("Dark Mode", isOn: $isDarkMode)
}

// GOOD: Using availability check
if #available(macOS 13.0, *) {
    Section("Settings") {
        Toggle("Dark Mode", isOn: $isDarkMode)
    }
} else {
    Section(header: Text("Settings")) {
        Toggle("Dark Mode", isOn: $isDarkMode)
    }
}
```

#### Model Redeclaration Issues
- **Pattern**: Properties or methods defined multiple times
- **Solution**: Careful review of inheritance and extensions

```swift
// BAD: Redeclaring property in computed property
class Student {
    var assignments = List<Assignment>()
    
    var totalAssignments: Int {
        return assignments.count
    }
    
    // This causes redeclaration
    var totalAssignments: Int { /* Another implementation */ }
}

// GOOD: Unique property names
class Student {
    var assignments = List<Assignment>()
    
    var totalAssignments: Int {
        return assignments.count
    }
    
    var totalActiveAssignments: Int {
        return assignments.filter { $0.isActive }.count
    }
}
```

### Realm Relationship Patterns

```swift
// One-to-many relationship (preferred approach)
// In the "many" side:
@Persisted var classes = LinkingObjects(fromType: SchoolClass.self, property: "students")

// In the "one" side:
@Persisted var students = List<Student>()

// Computed property for backwards compatibility when changing relationship types:
var schoolObj: School? {
    return school.first
}
```

### Realm Relationship Troubleshooting

- **Pattern**: Using direct references instead of LinkingObjects for bidirectional relationships
- **Solution**: Use LinkingObjects on one side and List on the other

```swift
// BAD: Using direct references on both sides
// In School:
@Persisted var classes = List<SchoolClass>()
// In SchoolClass:
@Persisted var school: School?

// GOOD: Using LinkingObjects for bidirectional relationship
// In School:
@Persisted var classes = List<SchoolClass>()
// In SchoolClass:
@Persisted(originProperty: "classes") var school: LinkingObjects<School>
```

## Critical Implementation Paths

### School Year Tracking System

The application now implements a standardized school year tracking system:

1. **SchoolYearHelper Utility**
   - Generates standardized "YYYY-YYYY" format strings
   - Validates school year format
   - Provides consistent representation across the application

```swift
// SchoolYearHelper implementation
class SchoolYearHelper {
    // Generate a school year string from a start year (e.g., 2024 -> "2024-2025")
    static func generateSchoolYear(startYear: Int) -> String {
        return "\(startYear)-\(startYear + 1)"
    }
    
    // Validate a school year string format
    static func isValidSchoolYear(_ year: String) -> Bool {
        // Implementation validates "YYYY-YYYY" format with consecutive years
        let components = year.split(separator: "-")
        guard components.count == 2,
              let firstYear = Int(components[0]),
              let secondYear = Int(components[1]),
              secondYear == firstYear + 1 else {
            return false
        }
        return true
    }
}
```

2. **SchoolYear Model Integration**
   - Board, School, and SchoolClass models include currentSchoolYear properties
   - Consistent format enforced through helper methods
   - Year-based filtering supported across analytics features

3. **SchoolYearPickerSheet Component** 
   - Reusable UI component for year selection
   - Auto-generates reasonable range of school years
   - Platform-independent implementation

### User Authentication

1. Login view collects credentials
2. AuthenticationService validates with mock/actual backend
3. JWT tokens stored securely
4. App state updated to reflect authentication
5. Automatic token refresh when needed

### Cross-Platform Color Handling

```swift
// BAD: Using platform-specific colors directly
.background(Color(.systemBackground))
.foregroundColor(Color(.secondaryLabel))

// GOOD: Using ColorHelper for platform independence
.background(ColorHelper.backgroundSwiftUI)
.foregroundColor(ColorHelper.secondaryLabelSwiftUI)

// ColorHelper implementation
class ColorHelper {
    // Platform-specific UIKit/AppKit color definitions
    #if os(iOS)
    static var systemBackground: UIColor {
        return UIColor.systemBackground
    }
    #elseif os(macOS)
    static var systemBackground: NSColor {
        return NSColor.windowBackgroundColor
    }
    #endif
    
    // SwiftUI wrappers for easy use in views
    static var backgroundSwiftUI: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}
```

### Platform-Specific Chart Rendering

1. Check API availability using @available attributes
2. Provide conditional imports for Charts framework
3. Create dedicated chartView and fallbackView properties
4. Apply platform-specific styling and interactions
5. Ensure both views provide equivalent data visualization

```swift
struct TimeSeriesDataChart: View {
    let data: [TimeSeriesDataPoint]
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            chartView
        } else {
            fallbackView
        }
    }
    
    @available(macOS 13.0, iOS 16.0, *)
    private var chartView: some View {
        #if canImport(Charts)
        Chart {
            // Chart implementation using Swift Charts
        }
        #else
        EmptyView()
        #endif
    }
    
    private var fallbackView: some View {
        // Custom implementation using standard SwiftUI components
        // that works on all platforms
    }
}
```

### Grade Management

1. Teacher selects class/assignment
2. Gradebook presents editable student list
3. Changes tracked in real-time
4. Data persisted locally with Realm
5. Analytics updated to reflect changes

### Student Analytics

1. Raw grade data collected from Realm
2. AnalyticsService processes and transforms data
3. Charts and visualizations generated
4. Multiple levels of analytics available (student, class, grade, etc.)
5. Export functionality for reporting

---

This system patterns document outlines the architecture, key technical decisions, design patterns, component relationships, and critical implementation paths in the Compass4Success application.

## Component Structure Patterns

```swift
// Break large views into smaller components
// Instead of this:
struct ComplexView: View {
    let data: ComplexData
    
    var body: some View {
        VStack {
            // Complex nested structure with many layers and generics
            ForEach(data.items) { item in
                // More complexity
                Chart {
                    // Even more complexity
                }
            }
        }
    }
}

// Do this:
struct ComplexView: View {
    let data: ComplexData
    
    var body: some View {
        VStack {
            ChartSection(items: data.items)
        }
    }
}

struct ChartSection: View {
    let items: [Item]
    
    var body: some View {
        ForEach(items, id: \.id) { item in
            SingleItemChart(item: item)
        }
    }
}

struct SingleItemChart: View {
    let item: Item
    
    var body: some View {
        Chart {
            // Chart implementation
        }
    }
}
```

### ForEach Type Annotations

Always use explicit type annotations with ForEach to avoid type inference issues:

```swift
// BAD: Let Swift infer the type
ForEach(analyticsService.schools) { school in
    // ...
}

// GOOD: Explicit type annotation
ForEach(analyticsService.schools as [School], id: \.id) { school in
    // ...
}
```

# Cross-Platform View Adaptation Patterns

The application now includes several patterns for adapting views across platforms:

## Conditional View Modifiers

Created dedicated ViewExtension helpers for applying modifiers conditionally by platform:

```swift
extension View {
    // Apply a modifier only on iOS
    @ViewBuilder
    func iOSOnly<Content: View>(@ViewBuilder content: (Self) -> Content) -> some View {
        #if os(iOS)
        content(self)
        #else
        self
        #endif
    }
    
    // Apply a modifier only on macOS
    @ViewBuilder
    func macOSOnly<Content: View>(@ViewBuilder content: (Self) -> Content) -> some View {
        #if os(macOS)
        content(self)
        #else
        self
        #endif
    }
}
```

## Chart Component Pattern

For SwiftUI Chart components (iOS 16+ / macOS 13+), implemented a consistent pattern:

```swift
struct AnalyticsChartView: View {
    // Common properties across all platforms
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            modernChartView // Using SwiftUI Charts
        } else {
            legacyChartView // Fallback implementation
        }
    }
    
    // Platform-specific chart implementations
    @available(macOS 13.0, iOS 16.0, *)
    private var modernChartView: some View {
        Chart {
            // Modern chart implementation
        }
    }
    
    private var legacyChartView: some View {
        // Legacy implementation using basic SwiftUI components
        // Works on all supported platforms
    }
}
```

## Component Naming Convention

To avoid view redeclaration conflicts, established naming conventions:

- Feature-prefixed component names: `DashboardAssignmentCard` vs `GradebookAssignmentCard`
- Context-specific component names rather than generic ones
- Consistent naming patterns across related components
