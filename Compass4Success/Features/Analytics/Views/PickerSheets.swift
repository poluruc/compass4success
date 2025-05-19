import SwiftUI

// Helper sheets for picking various analytics-related options
struct PickerSheets {
    
    struct ClassPickerSheet: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var selectedClass: SchoolClass?
        let classes: [SchoolClass]
        
        var body: some View {
            NavigationView {
                List {
                    Button {
                        selectedClass = nil
                        dismiss()
                    } label: {
                        HStack {
                            Text("All Classes")
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedClass == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Section(header: Text("Classes")) {
                        ForEach(classes) { classItem in
                            Button {
                                selectedClass = classItem
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(classItem.name)
                                            .foregroundColor(.primary)
                                        Text("Period \(classItem.period) • \(classItem.subject)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedClass?.id == classItem.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select Class")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct GradeLevelPickerSheet: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var selectedGradeLevel: String?
        let gradeLevels = ["9", "10", "11", "12"]
        
        var body: some View {
            NavigationView {
                List {
                    Button {
                        selectedGradeLevel = nil
                        dismiss()
                    } label: {
                        HStack {
                            Text("All Grades")
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedGradeLevel == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Section(header: Text("Grade Levels")) {
                        ForEach(gradeLevels, id: \.self) { grade in
                            Button {
                                selectedGradeLevel = grade
                                dismiss()
                            } label: {
                                HStack {
                                    Text("Grade \(grade)")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedGradeLevel == grade {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select Grade Level")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct TimeFramePickerSheet: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var selectedTimeFrame: AnalyticsView.TimeFrame
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Time Frame")) {
                        ForEach(AnalyticsView.TimeFrame.allCases, id: \.self) { timeFrame in
                            Button {
                                selectedTimeFrame = timeFrame
                                dismiss()
                            } label: {
                                HStack {
                                    Text(timeFrame.rawValue)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedTimeFrame == timeFrame {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select Time Frame")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct AnalyticsTypePickerSheet: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var selectedAnalyticsType: AnalyticsView.AnalyticsType
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Analytics Type")) {
                        ForEach(AnalyticsView.AnalyticsType.allCases, id: \.self) { type in
                            Button {
                                selectedAnalyticsType = type
                                dismiss()
                            } label: {
                                HStack {
                                    Label {
                                        Text(type.rawValue)
                                            .foregroundColor(.primary)
                                    } icon: {
                                        Image(systemName: type.icon)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedAnalyticsType == type {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select Analytics Type")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}