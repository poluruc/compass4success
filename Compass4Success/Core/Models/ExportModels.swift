import SwiftUI

// Central export format definition to be used across the app
public enum ExportFormat: String, CaseIterable, Identifiable {
    case pdf = "PDF"
    case csv = "CSV"
    case excel = "Excel"
    
    public var id: String { self.rawValue }
    
    public var icon: String {
        switch self {
        case .pdf:
            return "doc.fill"
        case .csv:
            return "tablecells"
        case .excel:
            return "chart.bar.doc.horizontal"
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .pdf:
            return "pdf"
        case .csv:
            return "csv"
        case .excel:
            return "xlsx"
        }
    }
    
    public var mimeType: String {
        switch self {
        case .pdf:
            return "application/pdf"
        case .csv:
            return "text/csv"
        case .excel:
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        }
    }
} 