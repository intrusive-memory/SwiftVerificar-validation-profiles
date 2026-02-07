import Foundation

/// Context for rule evaluation providing property values and variable bindings.
///
/// `ValidationContext` encapsulates the state needed to evaluate validation rules
/// against PDF objects. It contains:
/// - Object properties extracted from the PDF object being validated
/// - Profile-level variables with their resolved values
/// - The target object type being validated
///
/// ## Example
/// ```swift
/// let context = ValidationContext(
///     objectType: .pdDocument,
///     properties: [
///         "containsStructTreeRoot": .bool(true),
///         "version": .string("2.0")
///     ],
///     variables: [
///         "maxVersion": .string("2.0")
///     ]
/// )
///
/// let evaluator = RuleExpressionEvaluator()
/// let result = try evaluator.evaluate(
///     expression: "containsStructTreeRoot == true && version == maxVersion",
///     properties: context.allProperties
/// )
/// ```
///
/// - Note: This type merges properties and variables, with properties taking precedence over variables.
public struct ValidationContext: Sendable {

    /// The type of PDF object being validated.
    public let objectType: PDFObjectType

    /// Properties extracted from the PDF object.
    public let properties: [String: PropertyValue]

    /// Profile-level variables with resolved values.
    public let variables: [String: PropertyValue]

    /// Creates a new validation context.
    ///
    /// - Parameters:
    ///   - objectType: The type of PDF object being validated.
    ///   - properties: Properties extracted from the object.
    ///   - variables: Profile-level variables.
    public init(
        objectType: PDFObjectType,
        properties: [String: PropertyValue] = [:],
        variables: [String: PropertyValue] = [:]
    ) {
        self.objectType = objectType
        self.properties = properties
        self.variables = variables
    }

    /// All properties available for rule evaluation (properties merged with variables).
    ///
    /// Properties take precedence over variables when names conflict.
    public var allProperties: [String: PropertyValue] {
        variables.merging(properties) { _, property in property }
    }

    /// Creates a new context with additional properties.
    ///
    /// - Parameter additionalProperties: Properties to add or override.
    /// - Returns: A new context with the merged properties.
    public func adding(properties additionalProperties: [String: PropertyValue]) -> ValidationContext {
        let merged = properties.merging(additionalProperties) { _, new in new }
        return ValidationContext(
            objectType: objectType,
            properties: merged,
            variables: variables
        )
    }

    /// Creates a new context with additional variables.
    ///
    /// - Parameter additionalVariables: Variables to add or override.
    /// - Returns: A new context with the merged variables.
    public func adding(variables additionalVariables: [String: PropertyValue]) -> ValidationContext {
        let merged = variables.merging(additionalVariables) { _, new in new }
        return ValidationContext(
            objectType: objectType,
            properties: properties,
            variables: merged
        )
    }
}
