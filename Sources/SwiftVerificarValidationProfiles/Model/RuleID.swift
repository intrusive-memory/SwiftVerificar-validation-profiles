import Foundation

/// Rule identifier that uniquely identifies a validation rule within a specification.
///
/// A `RuleID` combines a specification reference, clause number, and test number
/// to produce a unique identifier for each validation rule. This corresponds to
/// the `<id>` element in the XML validation profiles.
///
/// ## Example
/// For an XML element like:
/// ```xml
/// <id specification="ISO_14289_2" clause="8.2.5.26" testNumber="1"/>
/// ```
/// The corresponding `RuleID` would be:
/// ```swift
/// RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)
/// ```
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public struct RuleID: Codable, Sendable, Hashable {

    /// The ISO specification this rule belongs to.
    public let specification: Specification

    /// The clause reference within the specification (e.g., "8.2.5.26").
    public let clause: String

    /// The test number within the clause (1-based).
    public let testNumber: Int

    /// Creates a new rule identifier.
    ///
    /// - Parameters:
    ///   - specification: The ISO specification this rule belongs to.
    ///   - clause: The clause reference within the specification.
    ///   - testNumber: The test number within the clause.
    public init(specification: Specification, clause: String, testNumber: Int) {
        self.specification = specification
        self.clause = clause
        self.testNumber = testNumber
    }

    /// A string representation combining all components for display and lookup.
    ///
    /// Format: `"<specification_rawValue>-<clause>-<testNumber>"`
    ///
    /// Example: `"ISO_14289_2-8.2.5.26-1"`
    public var uniqueID: String {
        "\(specification.rawValue)-\(clause)-\(testNumber)"
    }
}
