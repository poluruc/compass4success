import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
struct ClassesView: View {
    @EnvironmentObject private var classService: ClassService
    @State private var showAddClassSheet = false
    @State private var selectedClass: SchoolClass?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom toolbar
            HStack {
                Button(action: refreshClasses) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                
                Spacer()
                
                Text("Classes")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showAddClassSheet = true
                }) {
                    Label("Add", systemImage: "plus")
                }
            }
            .padding()
            
            ZStack {
                if classService.classes.isEmpty {
                    // Use EmptyView for compatibility
                    ScrollView {
                        VStack {
                            Image(systemName: "book.closed")
                                .font(.largeTitle)
                                .padding()
                            
                            Text("No Classes")
                                .font(.headline)
                            
                            Text("You don't have any classes yet. Tap the + button to add your first class.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(classService.classes) { schoolClass in
                                ClassListItem(schoolClass: schoolClass)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedClass = schoolClass
                                    }
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showAddClassSheet) {
            // This would be implemented as a form to add a new class
            Text("Add Class Form")
                #if os(iOS)
                .presentationDetents([.medium, .large])
                #elseif os(macOS)
                // Check for macOS 13+ at runtime
                .modifier(MacOSPresentationDetentsModifier(detents: [.medium, .large]))
                #endif
        }
        .sheet(item: $selectedClass) { schoolClass in
            // This would be implemented as a detail view for the class
            ClassDetailView(schoolClass: schoolClass)
                #if os(iOS)
                .presentationDetents([.medium, .large])
                #elseif os(macOS)
                // Check for macOS 13+ at runtime
                .modifier(MacOSPresentationDetentsModifier(detents: [.medium, .large]))
                #endif
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            refreshClasses()
        }
    }
    
    private func refreshClasses() {
        isLoading = true
        classService.loadClasses()
        isLoading = false
    }
    
    private func deleteClass(at offsets: IndexSet) {
        // Implement the delete logic here
    }
}

struct ClassCard: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(schoolClass.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(schoolClass.subject)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Period \(schoolClass.period)")
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                StatusItem(
                    count: schoolClass.enrollmentCount,
                    label: "Students",
                    icon: "person.3"
                )
                
                StatusItem(
                    count: schoolClass.activeAssignmentsCount, 
                    label: "Assignments",
                    icon: "list.clipboard"
                )
                
                Spacer()
                
                if let averageGrade = schoolClass.averageGrade {
                    Text(String(format: "%.1f%%", averageGrade * 100))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                } else {
                    Text("No grades")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct StatusItem: View {
    let count: Int
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.headline)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ClassDetailView: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack {
            Text(schoolClass.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(schoolClass.subject)
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Room \(schoolClass.roomNumber) • Period \(schoolClass.period)")
                .font(.headline)
                .padding(.top, 4)
            
            // More details would be added here in a real implementation
        }
        .padding()
    }
}

// ClassRow view for list items
struct ClassListItem: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(schoolClass.name)
                .font(.headline)
            
            Text("\(schoolClass.courseCode) • Grade \(schoolClass.gradeLevel)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if schoolClass.studentCount > 0 {
                Text("\(schoolClass.studentCount) students")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

// A modifier that conditionally applies presentationDetents on macOS 13+
@available(macOS 13.0, *)
struct MacOSPresentationDetentsModifier: ViewModifier {
    let detents: Set<PresentationDetent>
    
    func body(content: Content) -> some View {
        if #available(macOS 13.0, *) {
            content.presentationDetents(detents)
        } else {
            content
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(macOS 13.0, *) {
            NavigationView {
                ClassesView()
                    .environmentObject(ClassService())
            }
        } else {
            Text("ClassesView requires macOS 13.0 or newer")
        }
    }
}