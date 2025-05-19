import SwiftUI


enum AnalyticsType: String, CaseIterable {
    case performance = "Performance"
    case attendance = "Attendance"
    case behavior = "Behavior"
    case engagement = "Engagement"
    
    var icon: String {
        switch self {
        case .performance: return "chart.bar.fill"
        case .attendance: return "person.fill.checkmark"
        case .behavior: return "hand.raised.fill"
        case .engagement: return "person.3.fill"
        }
    }
}

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
                .platformSpecificTitleDisplayMode()
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
                .platformSpecificTitleDisplayMode()
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
        @Binding var selectedTimeFrame: AnalyticsTimeFrame
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Time Frame")) {
                        ForEach(AnalyticsTimeFrame.allCases, id: \.self) { timeFrame in
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
                .platformSpecificTitleDisplayMode()
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
        @Binding var selectedAnalyticsType: AnalyticsViewType
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Analytics Type")) {
                        ForEach(AnalyticsViewType.allCases, id: \.self) { type in
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
                .platformSpecificTitleDisplayMode()
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

// Helper extension to handle navigationBarTitleDisplayMode differences between iOS and macOS
extension View {
    @ViewBuilder
    func platformSpecificTitleDisplayMode() -> some View {
        #if os(iOS)
        if #available(iOS 14.0, *) {
            self.navigationBarTitleDisplayMode(.inline)
        } else {
            self
        }
        #else
        // macOS doesn't support navigationBarTitleDisplayMode
        self
        #endif
    }
}
