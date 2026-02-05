import Foundation

/// A profile-level variable that can be referenced in rule test expressions.
///
/// Validation profiles may define variables with default values that can be
/// overridden at runtime. These variables are used in rule test expressions
/// to provide configurable thresholds, limits, or other parameters.
///
/// ## Example
/// For an XML variable element like:
/// ```xml
/// <variable name="maxCharacterDifference" defaultValue="1">
///     Maximum allowed difference between font program and dictionary widths
/// </variable>
/// ```
/// The corresponding `ProfileVariable` would be:
/// ```swift
/// ProfileVariable(
///     name: "maxCharacterDifference",
///     defaultValue: "1",
///     description: "Maximum allowed difference between font program and dictionary widths"
/// )
/// ```
///
/// - Note: This is a shared type consumed by validation-profiles and validation packages.
public struct ProfileVariable: Codable, Sendable, Hashable {

    /// The variable name, as referenced in rule test expressions.
    public let name: String

    /// The default value of the variable (always stored as a string).
    public let defaultValue: String

    /// A human-readable description of what this variable controls.
    public let description: String

    /// Creates a new profile variable.
    ///
    /// - Parameters:
    ///   - name: The variable name for use in expressions.
    ///   - defaultValue: The default value as a string.
    ///   - description: A description of the variable's purpose.
    public init(name: String, defaultValue: String, description: String) {
        self.name = name
        self.defaultValue = defaultValue
        self.description = description
    }
}
