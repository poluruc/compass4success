# Compass4Success Technical Context

*Last Updated: May 16, 2025*

## Technologies Used

### Core Technologies

- **Swift 5.7+**: Primary programming language
- **SwiftUI**: UI framework for declarative interface building
- **iOS 16.0+**: Primary target platform
- **macOS 13.0+**: Secondary target platform
- **Xcode 14.0+**: Development environment

### Frameworks & Libraries

- **Combine**: Reactive programming framework for handling asynchronous events
- **Realm**: Mobile database for local persistence
- **JWTDecode**: Library for handling authentication tokens
- **Charts**: Framework for data visualization components

### Backend Integration (Planned)

- **RESTful API**: For data synchronization
- **JWT Authentication**: For secure backend communication

## Development Setup

### Environment Setup

1. **Xcode 14.0+** with iOS 16.0+ SDK
2. **Swift Package Manager** for dependency management
3. **Git** for version control
4. **TestFlight** for beta distribution

### Project Configuration

- **Target Platforms**: iPhone, iPad, Mac (via Catalyst)
- **Orientation Support**: Portrait (primary) and landscape on iOS, standard window on macOS
- **Dark Mode**: Full support with adaptive colors
- **Accessibility**: VoiceOver compatibility

## Cross-Platform Compatibility

### Platform-Specific Code

- **Conditional Compilation**: Using #if os(iOS) / #else for platform-specific code
- **API Availability**: Using @available attributes for newer platform features
- **UI Adaptation**: Custom components that adapt to the platform

### Common Compatibility Issues

- **Colors**: System colors differ between iOS and macOS
- **Navigation**: Different navigation patterns between platforms
- **Typography**: Font metrics vary between platforms
- **Controls**: Different control styles and interactions

### Compatibility Utilities

- **ColorHelper**: Utility class that provides platform-appropriate colors
- **PlatformView**: Protocol for creating platform-specific view implementations
- **EnvironmentValues**: Custom environment values for platform detection

### Build Configuration

- **Development**: Mock data, logging enabled
- **Staging**: Test API endpoints, crash reporting
- **Production**: Live API endpoints, optimized performance

## Technical Constraints

### Platform Constraints

- iOS 16.0+ required (for latest SwiftUI features)
- Internet connectivity recommended but not required
- Device storage for local database

### Performance Requirements

- App launch time < 2 seconds
- Screen transitions < 300ms
- Database operations non-blocking
- Analytics processing on background threads

### Security Requirements

- Secure storage of authentication tokens
- Encryption of sensitive student data
- Privacy compliance with Ontario education standards
- Session timeout after period of inactivity

## Build Challenges and Solutions

### Common Build Errors

- **Type Checking Timeouts**: Swift compiler fails with deeply nested generic types
  - **Solution**: Break complex views into smaller components
  
- **Platform Compatibility Errors**: APIs available on one platform but not another
  - **Solution**: Use @available attributes and conditional compilation
  
- **Model Redeclaration Errors**: Properties defined multiple times
  - **Solution**: Carefully review model inheritance and extensions
  
- **Generic Type Inference Failures**: Compiler can't determine types
  - **Solution**: Explicitly specify generic parameters and ids

- **Reserved Keyword Conflicts**: Using Swift keywords (like 'class') as variable names
  - **Solution**: Use alternative names (e.g., 'schoolClass' instead of 'class')
  
- **Multiple View Declaration Errors**: Same view name defined in different files
  - **Solution**: Use unique names or namespacing (e.g., DashboardAssignmentCard instead of AssignmentCard)
  
- **Missing Property Errors**: Properties referenced but not defined in model classes
  - **Solution**: Add missing properties or create computed properties that provide compatibility

### Cross-Platform Build Process

1. **iOS-First Development**: Build and test on iOS first
2. **Compatibility Layer**: Add platform abstraction for system differences
3. **Conditional Code**: Apply platform-specific logic with #if os(iOS)/#else
4. **API Gating**: Use @available attributes for newer APIs
5. **Unified Testing**: Test on both platforms before committing

### Platform-Specific Modules

- **ColorHelper**: Platform-appropriate system colors
- **ViewModifiers**: Platform-specific view modifications
- **NavigationAdapters**: Platform-appropriate navigation patterns
- **ChartWrappers**: Compatibility layer for SwiftUI Charts

## Dependencies

### External Dependencies

- **Realm**: Version 10.30.0+
- **JWTDecode**: Version 3.0.0+
- **Swift Charts**: Integrated with iOS 16+

### Internal Dependencies

```
Features → Core Services → Models → Persistence
```

## Tool Usage Patterns

### SwiftUI Patterns

- **@State** for view-local state
- **@StateObject** for view-owned observable objects
- **@EnvironmentObject** for shared dependencies
- **@ObservedObject** for externally-owned objects

### Realm Patterns

- **@Persisted** for model properties
- **Object** inheritance for model classes
- **LinkingObjects** for reverse relationships
- **List** for one-to-many relationships

### Combine Patterns

- **Publishers** for data streams
- **AnyPublisher** for type erasure
- **Future** for one-time async operations
- **.sink** for subscribing to data changes

---

This technical context document outlines the technologies, development setup, technical constraints, dependencies, and tool usage patterns for the Compass4Success application.
