import Foundation

/// PDF flavour/standard being validated.
///
/// Each case represents a specific conformance level of a PDF standard.
/// The raw values match the identifiers used in the veraPDF validation-profiles
/// repository and are used for profile lookup and matching.
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public enum PDFFlavour: String, Codable, CaseIterable, Sendable {

    // MARK: - PDF/A Flavours

    /// PDF/A-1a (ISO 19005-1, Level A conformance)
    case pdfA1a = "PDFA_1_A"

    /// PDF/A-1b (ISO 19005-1, Level B conformance)
    case pdfA1b = "PDFA_1_B"

    /// PDF/A-2a (ISO 19005-2, Level A conformance)
    case pdfA2a = "PDFA_2_A"

    /// PDF/A-2b (ISO 19005-2, Level B conformance)
    case pdfA2b = "PDFA_2_B"

    /// PDF/A-2u (ISO 19005-2, Level U conformance)
    case pdfA2u = "PDFA_2_U"

    /// PDF/A-3a (ISO 19005-3, Level A conformance)
    case pdfA3a = "PDFA_3_A"

    /// PDF/A-3b (ISO 19005-3, Level B conformance)
    case pdfA3b = "PDFA_3_B"

    /// PDF/A-3u (ISO 19005-3, Level U conformance)
    case pdfA3u = "PDFA_3_U"

    /// PDF/A-4 (ISO 19005-4)
    case pdfA4 = "PDFA_4"

    /// PDF/A-4e (ISO 19005-4, Engineering)
    case pdfA4e = "PDFA_4_E"

    /// PDF/A-4f (ISO 19005-4, File)
    case pdfA4f = "PDFA_4_F"

    // MARK: - PDF/UA Flavours

    /// PDF/UA-1 (ISO 14289-1)
    case pdfUA1 = "PDFUA_1"

    /// PDF/UA-2 (ISO 14289-2)
    case pdfUA2 = "PDFUA_2"

    // MARK: - WCAG

    /// WCAG 2.2 (Web Content Accessibility Guidelines)
    case wcag22 = "WCAG_2_2"

    // MARK: - WTPDF

    /// WTPDF 1.0 Accessibility (Well-Tagged PDF)
    case wtpdf1Accessibility = "WTPDF_1_0_ACCESSIBILITY"

    /// WTPDF 1.0 Reuse (Well-Tagged PDF)
    case wtpdf1Reuse = "WTPDF_1_0_REUSE"

    // MARK: - Computed Properties

    /// Whether this flavour is a PDF/A archival standard.
    public var isPDFA: Bool {
        switch self {
        case .pdfA1a, .pdfA1b, .pdfA2a, .pdfA2b, .pdfA2u,
             .pdfA3a, .pdfA3b, .pdfA3u, .pdfA4, .pdfA4e, .pdfA4f:
            return true
        default:
            return false
        }
    }

    /// Whether this flavour is a PDF/UA accessibility standard.
    public var isPDFUA: Bool {
        switch self {
        case .pdfUA1, .pdfUA2:
            return true
        default:
            return false
        }
    }

    /// Whether this flavour is accessibility-related (PDF/UA, WCAG, or WTPDF accessibility).
    public var isAccessibilityRelated: Bool {
        switch self {
        case .pdfUA1, .pdfUA2, .wcag22, .wtpdf1Accessibility:
            return true
        default:
            return false
        }
    }

    /// The corresponding ISO specification for this flavour.
    public var specification: Specification {
        switch self {
        case .pdfA1a, .pdfA1b:
            return .iso190051
        case .pdfA2a, .pdfA2b, .pdfA2u:
            return .iso190052
        case .pdfA3a, .pdfA3b, .pdfA3u:
            return .iso190053
        case .pdfA4, .pdfA4e, .pdfA4f:
            return .iso190054
        case .pdfUA1:
            return .iso142891
        case .pdfUA2:
            return .iso142892
        case .wcag22:
            return .wcag22
        case .wtpdf1Accessibility, .wtpdf1Reuse:
            return .iso320002
        }
    }

    /// Human-readable display name for this flavour.
    public var displayName: String {
        switch self {
        case .pdfA1a: return "PDF/A-1a"
        case .pdfA1b: return "PDF/A-1b"
        case .pdfA2a: return "PDF/A-2a"
        case .pdfA2b: return "PDF/A-2b"
        case .pdfA2u: return "PDF/A-2u"
        case .pdfA3a: return "PDF/A-3a"
        case .pdfA3b: return "PDF/A-3b"
        case .pdfA3u: return "PDF/A-3u"
        case .pdfA4: return "PDF/A-4"
        case .pdfA4e: return "PDF/A-4e"
        case .pdfA4f: return "PDF/A-4f"
        case .pdfUA1: return "PDF/UA-1"
        case .pdfUA2: return "PDF/UA-2"
        case .wcag22: return "WCAG 2.2"
        case .wtpdf1Accessibility: return "WTPDF 1.0 Accessibility"
        case .wtpdf1Reuse: return "WTPDF 1.0 Reuse"
        }
    }
}
