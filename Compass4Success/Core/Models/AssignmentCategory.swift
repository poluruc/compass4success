import Foundation
import SwiftUI

// Assignment categories
public enum AssignmentCategory: String, CaseIterable {
    case assignment = "Assignment"
    case quiz = "Quiz"
    case test = "Test"
    case project = "Project"
    case presentation = "Presentation"
    case lab = "Lab Report"
    case essay = "Essay"
    case homework = "Homework"
    case midterm = "Midterm Exam"
    case final = "Final Exam"
    
    var color: Color {
        switch self {
        case .assignment:
            return .blue
        case .quiz:
            return .green
        case .test:
            return .orange
        case .project:
            return .purple
        case .presentation:
            return .pink
        case .lab:
            return .teal
        case .essay:
            return .indigo
        case .homework:
            return .mint
        case .midterm, .final:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .assignment:
            return "doc.text"
        case .quiz:
            return "checkmark.square"
        case .test:
            return "doc.text.magnifyingglass"
        case .project:
            return "folder"
        case .presentation:
            return "person.wave.2"
        case .lab:
            return "testtube.2"
        case .essay:
            return "text.quote"
        case .homework:
            return "house"
        case .midterm, .final:
            return "clock"
        }
    }
    
    var iconName: String {
        switch self {
        case .assignment: return "doc.text"
        case .quiz: return "questionmark.circle"
        case .test: return "doc.text.magnifyingglass"
        case .project: return "folder"
        case .presentation: return "person.wave.2"
        case .lab: return "testtube.2"
        case .essay: return "text.quote"
        case .homework: return "house"
        case .midterm: return "clock"
        case .final: return "clock.fill"
        }
    }
}
