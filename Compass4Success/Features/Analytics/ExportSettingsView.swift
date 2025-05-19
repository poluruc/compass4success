import SwiftUI

struct ExportSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let analyticsType: AnalyticsView.AnalyticsType
    let timeFrame: AnalyticsView.TimeFrame
    
    @State private var selectedFormat = ExportFormat.pdf
    @State private var includeCharts = true
    @State private var includeStudentNames = true
    @State private var includeGradeBreakdown = true
    @State private var includeNotes = false
    @State private var isExporting = false
    @State private var showingSuccessAlert = false
    
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF"
        case csv = "CSV"
        case excel = "Excel"
        
        var icon: String {
            switch self {
            case .pdf:
                return "doc.fill"
            case .csv:
                return "tablecells"
            case .excel:
                return "chart.bar.doc.horizontal"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Type")) {
                    Text("Analytics: \(analyticsType.rawValue)")
                        .font(.headline)
                    
                    Text("Time Period: \(timeFrame.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Export Format")) {
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
                }
                
                Section(header: Text("Include")) {
                    Toggle("Charts & Visualizations", isOn: $includeCharts)
                        .disabled(selectedFormat != .pdf)
                    
                    Toggle("Student Names", isOn: $includeStudentNames)
                    
                    Toggle("Grade Breakdown", isOn: $includeGradeBreakdown)
                    
                    Toggle("Teacher Notes", isOn: $includeNotes)
                }
                
                Section(header: Text("Export Options")) {
                    Button(action: exportData) {
                        if isExporting {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                        } else {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .disabled(isExporting)
                }
            }
            .navigationTitle("Export Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isExporting)
                }
            }
            .alert("Export Successful", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your \(analyticsType.rawValue) data has been exported as a \(selectedFormat.rawValue) file.")
            }
        }
    }
    
    private func exportData() {
        isExporting = true
        
        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isExporting = false
            showingSuccessAlert = true
        }
    }
}

struct ExportSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ExportSettingsView(
            analyticsType: .gradeDistribution,
            timeFrame: .semester
        )
    }
}