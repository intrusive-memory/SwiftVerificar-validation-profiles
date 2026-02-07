import Foundation

/// A complete validation profile containing rules for a specific PDF standard.
///
/// A `ValidationProfile` represents a parsed XML validation profile from the
/// veraPDF validation-profiles repository. It contains all the rules needed
/// to validate a PDF document against a specific standard (e.g., PDF/UA-2,
/// PDF/A-1b, WCAG 2.2).
///
/// ## Structure
/// A profile consists of:
/// - ``details``: Metadata about the profile (name, description, creator, date).
/// - ``flavour``: The PDF standard/conformance level this profile targets.
/// - ``rules``: The individual validation rules to check.
/// - ``variables``: Configurable parameters referenced by rule expressions.
/// - ``hash``: An optional integrity hash for the profile.
///
/// ## Example
/// ```swift
/// let profile = ValidationProfile(
///     details: ProfileDetails(
///         name: "PDF/UA-2 validation profile",
///         description: "Rules for ISO 14289-2",
///         creator: "veraPDF Consortium",
///         created: Date()
///     ),
///     hash: nil,
///     rules: [rule1, rule2],
///     variables: [],
///     flavour: .pdfUA2
/// )
/// ```
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public struct ValidationProfile: Codable, Sendable {

    /// Metadata about this profile.
    public let details: ProfileDetails

    /// An optional integrity hash for the profile content.
    public let hash: String?

    /// The validation rules contained in this profile.
    public let rules: [ValidationRule]

    /// Profile-level variables that can be referenced in rule expressions.
    public let variables: [ProfileVariable]

    /// The PDF standard/conformance level this profile targets.
    public let flavour: PDFFlavour

    /// Creates a new validation profile.
    ///
    /// - Parameters:
    ///   - details: Profile metadata.
    ///   - hash: An optional integrity hash.
    ///   - rules: The validation rules.
    ///   - variables: Profile-level variables.
    ///   - flavour: The target PDF standard.
    public init(
        details: ProfileDetails,
        hash: String? = nil,
        rules: [ValidationRule],
        variables: [ProfileVariable] = [],
        flavour: PDFFlavour
    ) {
        self.details = details
        self.hash = hash
        self.rules = rules
        self.variables = variables
        self.flavour = flavour
    }

    /// The total number of rules in this profile.
    public var ruleCount: Int {
        rules.count
    }

    /// Returns rules filtered by the specified PDF object type.
    ///
    /// - Parameter objectType: The object type to filter by.
    /// - Returns: An array of rules that target the specified object type.
    public func rules(for objectType: PDFObjectType) -> [ValidationRule] {
        rules.filter { $0.object == objectType.rawValue }
    }

    /// Returns rules that have all of the specified tags.
    ///
    /// - Parameter tags: The tags to filter by. A rule must contain all specified tags.
    /// - Returns: An array of rules matching all specified tags.
    public func rules(withAllTags tags: Set<RuleTag>) -> [ValidationRule] {
        rules.filter { tags.isSubset(of: $0.tags) }
    }

    /// Returns rules that have any of the specified tags.
    ///
    /// - Parameter tags: The tags to filter by. A rule must contain at least one.
    /// - Returns: An array of rules matching at least one specified tag.
    public func rules(withAnyTag tags: Set<RuleTag>) -> [ValidationRule] {
        rules.filter { !$0.tags.isDisjoint(with: tags) }
    }
}
