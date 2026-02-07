import Foundation

/// Binary operators for rule expression evaluation.
///
/// `BinaryOperator` represents operators that take two operands in
/// rule test expressions. These include comparison, logical, and
/// arithmetic operators.
///
/// ## Operator Precedence
/// Operators are listed roughly in precedence order (lowest to highest):
/// 1. Logical OR (`||`)
/// 2. Logical AND (`&&`)
/// 3. Equality (`==`, `!=`)
/// 4. Comparison (`<`, `<=`, `>`, `>=`)
/// 5. Additive (`+`, `-`)
/// 6. Multiplicative (`*`, `/`, `%`)
///
/// ## Example
/// ```swift
/// let op = BinaryOperator.eq
/// print(op.rawValue)      // "=="
/// print(op.precedence)    // 4
/// print(op.isComparison)  // true
/// ```
///
/// - Note: This type is used by ``Expression`` and ``ExpressionParser``
///   to represent binary operations in the AST.
public enum BinaryOperator: String, Sendable, Hashable, CaseIterable {
    // MARK: - Comparison Operators

    /// Equality comparison (`==`).
    case eq = "=="

    /// Inequality comparison (`!=`).
    case neq = "!="

    /// Less than comparison (`<`).
    case lt = "<"

    /// Less than or equal comparison (`<=`).
    case lte = "<="

    /// Greater than comparison (`>`).
    case gt = ">"

    /// Greater than or equal comparison (`>=`).
    case gte = ">="

    // MARK: - Logical Operators

    /// Logical AND (`&&`).
    case and = "&&"

    /// Logical OR (`||`).
    case or = "||"

    // MARK: - Arithmetic Operators

    /// Addition (`+`).
    case plus = "+"

    /// Subtraction (`-`).
    case minus = "-"

    /// Multiplication (`*`).
    case multiply = "*"

    /// Division (`/`).
    case divide = "/"

    /// Modulo/remainder (`%`).
    case modulo = "%"

    // MARK: - Properties

    /// The precedence level of this operator (higher binds tighter).
    ///
    /// Precedence levels follow typical programming language conventions:
    /// - Level 1: Logical OR
    /// - Level 2: Logical AND
    /// - Level 3: Equality (==, !=)
    /// - Level 4: Comparison (<, <=, >, >=)
    /// - Level 5: Additive (+, -)
    /// - Level 6: Multiplicative (*, /, %)
    public var precedence: Int {
        switch self {
        case .or:
            return 1
        case .and:
            return 2
        case .eq, .neq:
            return 3
        case .lt, .lte, .gt, .gte:
            return 4
        case .plus, .minus:
            return 5
        case .multiply, .divide, .modulo:
            return 6
        }
    }

    /// Whether this operator is a comparison operator.
    public var isComparison: Bool {
        switch self {
        case .eq, .neq, .lt, .lte, .gt, .gte:
            return true
        case .and, .or, .plus, .minus, .multiply, .divide, .modulo:
            return false
        }
    }

    /// Whether this operator is a logical operator.
    public var isLogical: Bool {
        switch self {
        case .and, .or:
            return true
        default:
            return false
        }
    }

    /// Whether this operator is an arithmetic operator.
    public var isArithmetic: Bool {
        switch self {
        case .plus, .minus, .multiply, .divide, .modulo:
            return true
        default:
            return false
        }
    }

    /// Whether this operator is left-associative.
    ///
    /// All binary operators in this enum are left-associative,
    /// meaning `a op b op c` is parsed as `(a op b) op c`.
    public var isLeftAssociative: Bool {
        true
    }
}

// MARK: - CustomStringConvertible

extension BinaryOperator: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Codable

extension BinaryOperator: Codable {}
