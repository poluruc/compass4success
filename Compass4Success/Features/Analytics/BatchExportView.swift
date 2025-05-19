import SwiftUI

struct BatchExportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var classService: ClassService
    @State private var selectedClasses: [SchoolClass] = []
    @State private var selectedReportTypes: [ReportType] = []
    @State private var selectedTimeFrame: AnalyticsView.TimeFrame = .semester
    @State private var selectedFormat = ExportFormat.pdf
    @State private var includeStudentDetails = true
    @State private var includeCharts = true
    @State private var gradeBreakdownType = GradeBreakdownType.byAssignment
    @State private var showClassPicker = false
    @State private var isExporting = false
    @State private var showingSuccessAlert = false
    
    enum ReportType: String, CaseIterable, Identifiable {
        case gradeDistribution = "Grade Distribution"
        case assignmentCompletion = "Assignment Completion"
        case standardsMastery = "Standards Mastery"
        case attendance = "Attendance"
        case classProgress = "Class Progress"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .gradeDistribution: return "chart.bar.fill"
            case .assignmentCompletion: return "checklist.checked"
            case .standardsMastery: return "star.fill"
            case .attendance: return "calendar.badge.clock"
            case .classProgress: return "chart.line.uptrend.xyaxis"
            }
        }
    }
    
    enum GradeBreakdownType: String, CaseIterable {
        case byAssignment = "By Assignment"
        case byStandard = "By Standard"
        case byStudent = "By Student"
    }
    
    var body: some View {
        NavigationView {
            Form {
                classSelectionSection
                
                reportTypeSection
                
                timeFrameSection
                
                exportOptionsSection
                
                exportButton
            }
            .navigationTitle("Batch Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showClassPicker) {
                classPickerView
            }
            .alert("Export Successful", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your batch export of \(selectedReportTypes.count) report types for \(selectedClasses.count) classes has been completed.")
            }
            .disabled(isExporting)
            .overlay {
                if isExporting {
                    LoadingOverlay(message: "Preparing Reports...")
                }
            }
        }
    }
    
    private var classSelectionSection: some View {
        Section(header: Text("Classes")) {
            Button {
                showClassPicker = true
            } label: {
                HStack {
                    Text(selectedClasses.isEmpty ? "Select Classes" : "\(selectedClasses.count) Classes Selected")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            
            if !selectedClasses.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedClasses) { classItem in
                            Text(classItem.name)
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var reportTypeSection: some View {
        Section(header: Text("Report Types")) {
            ForEach(ReportType.allCases) { reportType in
                Button {
                    toggleReportType(reportType)
                } label: {
                    HStack {
                        Image(systemName: reportType.icon)
                            .foregroundColor(.blue)
                        
                        Text(reportType.rawValue)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedReportTypes.contains(reportType) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    private var timeFrameSection: some View {
        Section(header: Text("Time Frame")) {
            Picker("Time Period", selection: $selectedTimeFrame) {
                ForEach(AnalyticsView.TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var exportOptionsSection: some View {
        Section(header: Text("Export Options")) {
            Picker("Format", selection: $selectedFormat) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Label {
                        Text(format.rawValue)
                    } icon: {
                        Image(systemName: format.icon)
                    }
                    .tag(format)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Toggle("Include Student Details", isOn: $includeStudentDetails)
            
            Toggle("Include Charts & Visualizations", isOn: $includeCharts)
                .disabled(selectedFormat != .pdf)
            
            if includeStudentDetails {
                Picker("Grade Breakdown", selection: $gradeBreakdownType) {
                    ForEach(GradeBreakdownType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
        }
    }
    
    private var exportButton: some View {
        Section {
            Button(action: exportData) {
                HStack {
                    Spacer()
                    Label("Generate \(selectedFormat.rawValue) Reports", systemImage: "square.and.arrow.up")
                        .font(.headline)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .disabled(selectedClasses.isEmpty || selectedReportTypes.isEmpty)
            .listRowInsets(EdgeInsets())
        }
    }
    
    private var classPickerView: some View {
        let classes = classService.classes
        
        return NavigationView {
            List {
                Section(header: Text("Quick Selection")) {
                    Button("Select All") {
                        selectedClasses = classes
                    }
                    
                    Button("Clear Selection") {
                        selectedClasses = []
                    }
                }
                
                Section(header: Text("Classes")) {
                    ForEach(classes) { classItem in
                        Button {
                            toggleClass(classItem)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(classItem.name)
                                        .foregroundColor(.primary)
                                    Text("\(classItem.subject) • Period \(classItem.period)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedClasses.contains(where: { $0.id == classItem.id }) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Classes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showClassPicker = false
                    }
                }
            }
        }
    }
    
    private func toggleClass(_ classItem: SchoolClass) {
        if let index = selectedClasses.firstIndex(where: { $0.id == classItem.id }) {
            selectedClasses.remove(at: index)
        } else {
            selectedClasses.append(classItem)
        }
    }
    
    private func toggleReportType(_ type: ReportType) {
        if let index = selectedReportTypes.firstIndex(of: type) {
            selectedReportTypes.remove(at: index)
        } else {
            selectedReportTypes.append(type)
        }
    }
    
    private func exportData() {
        guard !selectedClasses.isEmpty, !selectedReportTypes.isEmpty else { return }
        
        isExporting = true
        
        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isExporting = false
            showingSuccessAlert = true
        }
    }
}

struct BatchExportView_Previews: PreviewProvider {
    static var previews: some View {
        BatchExportView()
            .environmentObject(ClassService())
    }
}