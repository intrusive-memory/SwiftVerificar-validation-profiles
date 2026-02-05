import Foundation

/// ISO specification reference for PDF standards.
///
/// Each case represents an ISO standard or specification that PDF validation
/// rules can reference. The raw values are identifiers used in the XML
/// validation profiles for rule-to-specification linking.
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public enum Specification: String, Codable, CaseIterable, Sendable {

    /// ISO 19005-1 (PDF/A-1)
    case iso190051 = "ISO_19005_1"

    /// ISO 19005-2 (PDF/A-2)
    case iso190052 = "ISO_19005_2"

    /// ISO 19005-3 (PDF/A-3)
    case iso190053 = "ISO_19005_3"

    /// ISO 19005-4 (PDF/A-4)
    case iso190054 = "ISO_19005_4"

    /// ISO 14289-1 (PDF/UA-1)
    case iso142891 = "ISO_14289_1"

    /// ISO 14289-2 (PDF/UA-2)
    case iso142892 = "ISO_14289_2"

    /// ISO 32000-1 (PDF 1.7)
    case iso320001 = "ISO_32000_1"

    /// ISO 32000-2 (PDF 2.0)
    case iso320002 = "ISO_32000_2"

    /// ISO 32005 (Tagged PDF)
    case iso32005 = "ISO_32005"

    /// WCAG 2.2 (Web Content Accessibility Guidelines)
    case wcag22 = "WCAG_2_2"

    /// No specific standard
    case noStandard = "NO_STANDARD"

    // MARK: - Computed Properties

    /// Human-readable display name for this specification.
    public var displayName: String {
        switch self {
        case .iso190051: return "ISO 19005-1 (PDF/A-1)"
        case .iso190052: return "ISO 19005-2 (PDF/A-2)"
        case .iso190053: return "ISO 19005-3 (PDF/A-3)"
        case .iso190054: return "ISO 19005-4 (PDF/A-4)"
        case .iso142891: return "ISO 14289-1 (PDF/UA-1)"
        case .iso142892: return "ISO 14289-2 (PDF/UA-2)"
        case .iso320001: return "ISO 32000-1 (PDF 1.7)"
        case .iso320002: return "ISO 32000-2 (PDF 2.0)"
        case .iso32005: return "ISO 32005 (Tagged PDF)"
        case .wcag22: return "WCAG 2.2"
        case .noStandard: return "No Standard"
        }
    }

    /// Whether this specification is a PDF/A standard.
    public var isPDFA: Bool {
        switch self {
        case .iso190051, .iso190052, .iso190053, .iso190054:
            return true
        default:
            return false
        }
    }

    /// Whether this specification is a PDF/UA standard.
    public var isPDFUA: Bool {
        switch self {
        case .iso142891, .iso142892:
            return true
        default:
            return false
        }
    }

    /// Whether this specification is accessibility-related.
    public var isAccessibilityRelated: Bool {
        switch self {
        case .iso142891, .iso142892, .wcag22:
            return true
        default:
            return false
        }
    }
}
