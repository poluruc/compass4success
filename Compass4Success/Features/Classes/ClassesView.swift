import SwiftUI

struct ClassesView: View {
    @EnvironmentObject private var classService: ClassService
    @State private var showAddClassSheet = false
    @State private var selectedClass: SchoolClass? = nil
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            if classService.classes.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "book.closed")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("No Classes Found")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Add your first class to get started")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showAddClassSheet = true
                    }) {
                        Text("Add Class")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(classService.classes) { schoolClass in
                            ClassCard(schoolClass: schoolClass)
                                .onTapGesture {
                                    selectedClass = schoolClass
                                }
                        }
                    }
                    .padding()
                }
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .foregroundColor(.white)
            }
        }
        .navigationTitle("Classes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddClassSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: refreshClasses) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $showAddClassSheet) {
            // This would be implemented as a form to add a new class
            Text("Add Class Form")
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $selectedClass) { schoolClass in
            // This would be implemented as a detail view for the class
            ClassDetailView(schoolClass: schoolClass)
                .presentationDetents([.medium, .large])
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

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClassesView()
                .environmentObject(ClassService())
        }
    }
}