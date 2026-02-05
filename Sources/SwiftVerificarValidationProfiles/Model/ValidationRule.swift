import Foundation

/// A single validation rule within a validation profile.
///
/// Each `ValidationRule` encapsulates one testable assertion about a PDF object.
/// It specifies which object type to check, the test expression to evaluate,
/// and the error details to report if the test fails.
///
/// ## Example
/// A rule checking that a document contains a structure tree root:
/// ```swift
/// let rule = ValidationRule(
///     id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
///     object: "PDDocument",
///     description: "The document shall contain a StructTreeRoot entry.",
///     test: "containsStructTreeRoot == true",
///     error: ErrorDetails(message: "Document does not contain StructTreeRoot"),
///     references: [Reference(specification: "ISO 14289-2:2024", clause: "8.2")],
///     tags: [.critical, .machine, .structure]
/// )
/// ```
///
/// ## Identifiable Conformance
/// The `id` property provides the ``RuleID`` that uniquely identifies this rule
/// within its specification. The computed ``uniqueID`` property produces a
/// string representation suitable for logging and lookup.
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public struct ValidationRule: Codable, Sendable, Identifiable {

    /// The unique identifier for this rule, combining specification, clause, and test number.
    public let id: RuleID

    /// The PDF object type this rule checks (matches a ``PDFObjectType`` raw value).
    public let object: String

    /// A human-readable description of what this rule verifies.
    public let description: String

    /// The test expression to evaluate against the object's properties.
    ///
    /// This is a JavaScript-like expression string that will be parsed and
    /// evaluated by the expression evaluator at validation time.
    public let test: String

    /// The error details reported when the test expression evaluates to `false`.
    public let error: ErrorDetails

    /// References to specification clauses that this rule implements.
    public let references: [Reference]

    /// Categorization tags for filtering and grouping rules.
    public let tags: Set<RuleTag>

    /// Creates a new validation rule.
    ///
    /// - Parameters:
    ///   - id: The rule identifier.
    ///   - object: The PDF object type to check.
    ///   - description: A description of the rule.
    ///   - test: The test expression string.
    ///   - error: Error details for failures.
    ///   - references: Specification references.
    ///   - tags: Categorization tags.
    public init(
        id: RuleID,
        object: String,
        description: String,
        test: String,
        error: ErrorDetails,
        references: [Reference] = [],
        tags: Set<RuleTag> = []
    ) {
        self.id = id
        self.object = object
        self.description = description
        self.test = test
        self.error = error
        self.references = references
        self.tags = tags
    }

    /// A unique string identifier combining specification, clause, and test number.
    ///
    /// Format: `"<specification_rawValue>-<clause>-<testNumber>"`
    ///
    /// Example: `"ISO_14289_2-8.2.5.26-1"`
    public var uniqueID: String {
        id.uniqueID
    }
}
