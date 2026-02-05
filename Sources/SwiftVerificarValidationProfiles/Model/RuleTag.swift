import Foundation

/// Rule categorization tags for validation rules.
///
/// Tags classify validation rules along multiple dimensions:
/// - **Severity**: How critical is the rule (critical, major, minor, cosmetic)
/// - **Checkability**: Whether the rule can be verified by machine or requires human judgment
/// - **Category**: The PDF feature area the rule relates to (metadata, structure, text, etc.)
/// - **Feature-specific**: Tags for specific PDF features (alt-text, lang, table, etc.)
///
/// A single rule may have multiple tags. For example, a rule might be tagged as
/// `[.critical, .machine, .altText]` indicating it is a critical, machine-checkable rule
/// about alternative text.
///
/// - Note: This is a shared type consumed by validation-profiles and validation packages.
public enum RuleTag: String, Codable, CaseIterable, Sendable {

    // MARK: - Severity

    /// Critical severity -- rule failures indicate fundamental accessibility or compliance issues
    case critical

    /// Major severity -- rule failures indicate significant problems
    case major

    /// Minor severity -- rule failures indicate non-critical issues
    case minor

    /// Cosmetic severity -- rule failures are stylistic or presentational
    case cosmetic

    // MARK: - Checkability

    /// Machine-checkable -- the rule can be fully verified by automated tooling
    case machine

    /// Human-required -- the rule requires human judgment to verify
    case human

    // MARK: - Category

    /// Metadata-related rule (document info, XMP, etc.)
    case metadata

    /// Structure-related rule (document structure, tag tree, etc.)
    case structure

    /// Text-related rule (text content, encoding, etc.)
    case text

    /// Font-related rule (font embedding, metrics, etc.)
    case font

    /// Annotation-related rule (links, form fields, etc.)
    case annotation

    /// Syntax-related rule (PDF syntax compliance)
    case syntax

    /// Artifact-related rule (background, decoration, etc.)
    case artifact

    // MARK: - Feature-specific

    /// Alternative text rule (images, figures, non-text content)
    case altText = "alt-text"

    /// Language specification rule
    case lang

    /// Table-related rule (headers, scope, structure)
    case table

    /// List-related rule (structure, labels)
    case list

    /// Heading-related rule (hierarchy, nesting)
    case heading

    /// Figure-related rule (captions, descriptions)
    case figure

    /// Note-related rule (footnotes, endnotes)
    case note

    /// Table of contents rule
    case toc

    /// Form-related rule (fields, labels, instructions)
    case form

    // MARK: - Computed Properties

    /// Whether this tag represents a severity level.
    public var isSeverity: Bool {
        switch self {
        case .critical, .major, .minor, .cosmetic:
            return true
        default:
            return false
        }
    }

    /// Whether this tag represents a checkability classification.
    public var isCheckability: Bool {
        switch self {
        case .machine, .human:
            return true
        default:
            return false
        }
    }

    /// Whether this tag represents a broad category.
    public var isCategory: Bool {
        switch self {
        case .metadata, .structure, .text, .font, .annotation, .syntax, .artifact:
            return true
        default:
            return false
        }
    }

    /// Whether this tag represents a feature-specific classification.
    public var isFeatureSpecific: Bool {
        switch self {
        case .altText, .lang, .table, .list, .heading, .figure, .note, .toc, .form:
            return true
        default:
            return false
        }
    }
}
