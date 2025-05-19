import Foundation

struct SupportOption: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String
    let type: SupportOptionType
    
    static func == (lhs: SupportOption, rhs: SupportOption) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum SupportOptionType: Equatable {
        case faq, contactSupport, reportIssue, userGuide, tutorial
    }
    
    static let faq = SupportOption(id: "1", title: "Frequently Asked Questions", icon: "questionmark.circle", type: .faq)
    static let contactSupport = SupportOption(id: "2", title: "Contact Support", icon: "envelope", type: .contactSupport)
    static let reportIssue = SupportOption(id: "3", title: "Report an Issue", icon: "exclamationmark.triangle", type: .reportIssue)
    static let userGuide = SupportOption(id: "4", title: "User Guide", icon: "book", type: .userGuide)
    static let tutorial = SupportOption(id: "5", title: "Tutorial", icon: "play.circle", type: .tutorial)
    
    static let allOptions: [SupportOption] = [
        .faq,
        .contactSupport,
        .reportIssue,
        .userGuide,
        .tutorial
    ]
}
