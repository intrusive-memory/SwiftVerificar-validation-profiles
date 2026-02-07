import Foundation

/// Unary operators for rule expression evaluation.
///
/// `UnaryOperator` represents operators that take a single operand in
/// rule test expressions. These include logical negation and numeric
/// negation.
///
/// ## Example
/// ```swift
/// let op = UnaryOperator.not
/// print(op.rawValue)  // "!"
/// print(op.isPrefix)  // true
/// ```
///
/// - Note: This type is used by ``Expression`` and ``ExpressionParser``
///   to represent unary operations in the AST.
public enum UnaryOperator: String, Sendable, Hashable, CaseIterable {
    /// Logical NOT (`!`).
    ///
    /// Negates the boolean value of the operand.
    /// ```javascript
    /// !true    // false
    /// !false   // true
    /// !null    // true (null is falsy)
    /// !"text"  // false (non-empty string is truthy)
    /// ```
    case not = "!"

    /// Numeric negation (`-`).
    ///
    /// Negates the numeric value of the operand.
    /// ```javascript
    /// -5       // -5
    /// -(-3)    // 3
    /// -3.14    // -3.14
    /// ```
    case minus = "-"

    // MARK: - Properties

    /// Whether this is a prefix operator.
    ///
    /// All unary operators in this enum are prefix operators,
    /// meaning they appear before their operand.
    public var isPrefix: Bool {
        true
    }

    /// A human-readable name for this operator.
    public var name: String {
        switch self {
        case .not:
            return "logical NOT"
        case .minus:
            return "negation"
        }
    }
}

// MARK: - CustomStringConvertible

extension UnaryOperator: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Codable

extension UnaryOperator: Codable {}
