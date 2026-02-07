import Foundation

/// Errors that can occur during expression evaluation.
///
/// `EvaluationError` represents runtime errors that occur when evaluating
/// a parsed expression against a set of property values.
///
/// ## Example
/// ```swift
/// let evaluator = RuleExpressionEvaluator()
/// do {
///     let result = try evaluator.evaluate(
///         expression: "unknownVar == true",
///         properties: [:]
///     )
/// } catch let error as EvaluationError {
///     print(error.localizedDescription)  // "Unknown identifier: unknownVar"
/// }
/// ```
///
/// - Note: This type is used by ``RuleExpressionEvaluator`` to report
///   evaluation errors.
public enum EvaluationError: Error, Sendable, Hashable {
    /// Reference to an unknown identifier/property.
    ///
    /// - Parameter name: The name of the unknown identifier.
    case unknownIdentifier(name: String)

    /// Reference to an unknown function.
    ///
    /// - Parameter name: The name of the unknown function.
    case unknownFunction(name: String)

    /// Type mismatch for an operation.
    ///
    /// - Parameters:
    ///   - operation: The operation that failed.
    ///   - expected: The expected type(s).
    ///   - found: The actual type.
    case typeMismatch(operation: String, expected: String, found: String)

    /// Division by zero.
    case divisionByZero

    /// Index out of bounds for array access.
    ///
    /// - Parameters:
    ///   - index: The attempted index.
    ///   - count: The array size.
    case indexOutOfBounds(index: Int, count: Int)

    /// Invalid regex pattern.
    ///
    /// - Parameter pattern: The invalid regex pattern.
    case invalidRegex(pattern: String)

    /// Invalid argument count for a function.
    ///
    /// - Parameters:
    ///   - function: The function name.
    ///   - expected: The expected argument count.
    ///   - found: The actual argument count.
    case invalidArgumentCount(function: String, expected: Int, found: Int)

    /// Null pointer/reference error.
    ///
    /// - Parameter operation: The operation that encountered null.
    case nullReference(operation: String)

    /// Maximum recursion depth exceeded.
    ///
    /// - Parameter depth: The depth at which evaluation stopped.
    case maxDepthExceeded(depth: Int)
}

// MARK: - LocalizedError

extension EvaluationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownIdentifier(let name):
            return "Unknown identifier: \(name)"
        case .unknownFunction(let name):
            return "Unknown function: \(name)"
        case .typeMismatch(let operation, let expected, let found):
            return "Type mismatch in \(operation): expected \(expected), found \(found)"
        case .divisionByZero:
            return "Division by zero"
        case .indexOutOfBounds(let index, let count):
            return "Index out of bounds: \(index) (array size: \(count))"
        case .invalidRegex(let pattern):
            return "Invalid regular expression: \(pattern)"
        case .invalidArgumentCount(let function, let expected, let found):
            return "Invalid argument count for \(function): expected \(expected), found \(found)"
        case .nullReference(let operation):
            return "Null reference in \(operation)"
        case .maxDepthExceeded(let depth):
            return "Maximum recursion depth exceeded (\(depth))"
        }
    }
}

// MARK: - CustomStringConvertible

extension EvaluationError: CustomStringConvertible {
    public var description: String {
        errorDescription ?? "Unknown evaluation error"
    }
}
