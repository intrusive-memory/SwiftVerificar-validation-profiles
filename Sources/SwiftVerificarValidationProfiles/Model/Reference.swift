import Foundation

/// A reference to a specific clause within a specification document.
///
/// Validation rules may cite one or more references to the specification clauses
/// they implement. Each `Reference` points to a specific clause within a named
/// specification, providing traceability from a rule back to its normative source.
///
/// ## Example
/// For an XML reference element like:
/// ```xml
/// <reference specification="ISO 14289-2:2024" clause="8.2.5.26"/>
/// ```
/// The corresponding `Reference` would be:
/// ```swift
/// Reference(specification: "ISO 14289-2:2024", clause: "8.2.5.26")
/// ```
///
/// - Note: The `specification` field is a free-form string (not a ``Specification`` enum)
///   because references may cite specific editions, annexes, or external documents
///   that do not map directly to the enumeration.
public struct Reference: Codable, Sendable, Hashable {

    /// The name of the specification document (e.g., "ISO 14289-2:2024").
    public let specification: String

    /// The clause number within the specification (e.g., "8.2.5.26").
    public let clause: String

    /// Creates a new specification reference.
    ///
    /// - Parameters:
    ///   - specification: The name of the specification document.
    ///   - clause: The clause number within the specification.
    public init(specification: String, clause: String) {
        self.specification = specification
        self.clause = clause
    }
}
