import Foundation

/// Abstract Syntax Tree (AST) node for rule test expressions.
///
/// `RuleExpression` represents a node in the expression tree that results from
/// parsing a rule test expression string. It is an indirect enum to support
/// recursive expression structures like nested binary operations.
///
/// ## Expression Types
/// - ``literal(_:)`` - A constant value (number, string, boolean, null)
/// - ``identifier(_:)`` - A variable/property reference
/// - ``binary(_:_:_:)`` - A binary operation (e.g., `a == b`)
/// - ``unary(_:_:)`` - A unary operation (e.g., `!x`)
/// - ``call(_:_:)`` - A function call (e.g., `Math.abs(x)`)
/// - ``member(_:_:)`` - Property access (e.g., `obj.property`)
/// - ``index(_:_:)`` - Array index access (e.g., `arr[0]`)
/// - ``ternary(_:_:_:)`` - Conditional expression (e.g., `a ? b : c`)
/// - ``lambda(_:_:)`` - Arrow function (e.g., `elem => elem == 'Figure'`)
/// - ``regex(_:)`` - Regular expression literal (e.g., `/^[a-z]+$/`)
///
/// ## Example
/// The expression `containsStructTreeRoot == true` parses to:
/// ```swift
/// RuleExpression.binary(
///     .identifier("containsStructTreeRoot"),
///     .eq,
///     .literal(.bool(true))
/// )
/// ```
///
/// ## Usage
/// Expressions are created by ``ExpressionParser`` and evaluated by
/// ``RuleExpressionEvaluator``.
///
/// - Note: This type is used by ``ExpressionParser`` and
///   ``RuleExpressionEvaluator`` for parsing and evaluating rule expressions.
public indirect enum RuleExpression: Sendable, Hashable {
    /// A literal/constant value.
    ///
    /// Examples: `true`, `false`, `null`, `42`, `3.14`, `"hello"`
    case literal(PropertyValue)

    /// A variable or property identifier.
    ///
    /// Examples: `containsStructTreeRoot`, `fontName`, `width`
    case identifier(String)

    /// A binary operation with two operands.
    ///
    /// Examples: `a == b`, `x && y`, `num1 + num2`
    case binary(RuleExpression, BinaryOperator, RuleExpression)

    /// A unary operation with one operand.
    ///
    /// Examples: `!value`, `-number`
    case unary(UnaryOperator, RuleExpression)

    /// A function call with name and arguments.
    ///
    /// Examples: `Math.abs(x)`, `split('&')`, `filter(pred)`
    ///
    /// - Note: Method calls like `str.split('&')` are represented as
    ///   `call("split", [receiver, ...args])` where receiver is the object
    ///   the method is called on.
    case call(String, [RuleExpression])

    /// Property/member access on an object.
    ///
    /// Examples: `obj.property`, `arr.length`, `str.length`
    case member(RuleExpression, String)

    /// Array index access.
    ///
    /// Examples: `arr[0]`, `str[i]`, `matrix[row][col]`
    case index(RuleExpression, RuleExpression)

    /// Ternary conditional expression.
    ///
    /// Examples: `condition ? thenValue : elseValue`
    case ternary(RuleExpression, RuleExpression, RuleExpression)

    /// Lambda/arrow function expression.
    ///
    /// Examples: `elem => elem == 'Figure'`, `x => x > 0`
    ///
    /// The first string is the parameter name, the expression is the body.
    case lambda(String, RuleExpression)

    /// Regular expression literal.
    ///
    /// Examples: `/^[a-zA-Z]+$/`, `/\d+/`
    ///
    /// The string contains the regex pattern without the surrounding slashes.
    case regex(String)

    // MARK: - Convenience Initializers

    /// Creates a literal null expression.
    public static var null: RuleExpression {
        .literal(.null)
    }

    /// Creates a literal boolean expression.
    ///
    /// - Parameter value: The boolean value.
    /// - Returns: A literal expression wrapping the boolean.
    public static func bool(_ value: Bool) -> RuleExpression {
        .literal(.bool(value))
    }

    /// Creates a literal integer expression.
    ///
    /// - Parameter value: The integer value.
    /// - Returns: A literal expression wrapping the integer.
    public static func int(_ value: Int64) -> RuleExpression {
        .literal(.int(value))
    }

    /// Creates a literal double expression.
    ///
    /// - Parameter value: The double value.
    /// - Returns: A literal expression wrapping the double.
    public static func double(_ value: Double) -> RuleExpression {
        .literal(.double(value))
    }

    /// Creates a literal string expression.
    ///
    /// - Parameter value: The string value.
    /// - Returns: A literal expression wrapping the string.
    public static func string(_ value: String) -> RuleExpression {
        .literal(.string(value))
    }

    /// Creates a literal array expression.
    ///
    /// - Parameter elements: The array elements.
    /// - Returns: A literal expression wrapping the array.
    public static func array(_ elements: [PropertyValue]) -> RuleExpression {
        .literal(.array(elements))
    }
}

// MARK: - CustomStringConvertible

extension RuleExpression: CustomStringConvertible {
    public var description: String {
        switch self {
        case .literal(let value):
            return value.stringValue
        case .identifier(let name):
            return name
        case .binary(let left, let op, let right):
            return "(\(left) \(op.rawValue) \(right))"
        case .unary(let op, let operand):
            return "\(op.rawValue)\(operand)"
        case .call(let name, let args):
            let argStr = args.map { $0.description }.joined(separator: ", ")
            return "\(name)(\(argStr))"
        case .member(let object, let property):
            return "\(object).\(property)"
        case .index(let object, let index):
            return "\(object)[\(index)]"
        case .ternary(let condition, let thenExpr, let elseExpr):
            return "(\(condition) ? \(thenExpr) : \(elseExpr))"
        case .lambda(let param, let body):
            return "\(param) => \(body)"
        case .regex(let pattern):
            return "/\(pattern)/"
        }
    }
}

// MARK: - Codable

extension RuleExpression: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case value, name, left, right, op, operand, object, property
        case function, args, index, condition, thenExpr, elseExpr
        case param, body, pattern
    }

    private enum ExpressionType: String, Codable {
        case literal, identifier, binary, unary, call, member, index, ternary, lambda, regex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ExpressionType.self, forKey: .type)

        switch type {
        case .literal:
            let value = try container.decode(PropertyValue.self, forKey: .value)
            self = .literal(value)
        case .identifier:
            let name = try container.decode(String.self, forKey: .name)
            self = .identifier(name)
        case .binary:
            let left = try container.decode(RuleExpression.self, forKey: .left)
            let op = try container.decode(BinaryOperator.self, forKey: .op)
            let right = try container.decode(RuleExpression.self, forKey: .right)
            self = .binary(left, op, right)
        case .unary:
            let op = try container.decode(UnaryOperator.self, forKey: .op)
            let operand = try container.decode(RuleExpression.self, forKey: .operand)
            self = .unary(op, operand)
        case .call:
            let name = try container.decode(String.self, forKey: .function)
            let args = try container.decode([RuleExpression].self, forKey: .args)
            self = .call(name, args)
        case .member:
            let object = try container.decode(RuleExpression.self, forKey: .object)
            let property = try container.decode(String.self, forKey: .property)
            self = .member(object, property)
        case .index:
            let object = try container.decode(RuleExpression.self, forKey: .object)
            let index = try container.decode(RuleExpression.self, forKey: .index)
            self = .index(object, index)
        case .ternary:
            let condition = try container.decode(RuleExpression.self, forKey: .condition)
            let thenExpr = try container.decode(RuleExpression.self, forKey: .thenExpr)
            let elseExpr = try container.decode(RuleExpression.self, forKey: .elseExpr)
            self = .ternary(condition, thenExpr, elseExpr)
        case .lambda:
            let param = try container.decode(String.self, forKey: .param)
            let body = try container.decode(RuleExpression.self, forKey: .body)
            self = .lambda(param, body)
        case .regex:
            let pattern = try container.decode(String.self, forKey: .pattern)
            self = .regex(pattern)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .literal(let value):
            try container.encode(ExpressionType.literal, forKey: .type)
            try container.encode(value, forKey: .value)
        case .identifier(let name):
            try container.encode(ExpressionType.identifier, forKey: .type)
            try container.encode(name, forKey: .name)
        case .binary(let left, let op, let right):
            try container.encode(ExpressionType.binary, forKey: .type)
            try container.encode(left, forKey: .left)
            try container.encode(op, forKey: .op)
            try container.encode(right, forKey: .right)
        case .unary(let op, let operand):
            try container.encode(ExpressionType.unary, forKey: .type)
            try container.encode(op, forKey: .op)
            try container.encode(operand, forKey: .operand)
        case .call(let name, let args):
            try container.encode(ExpressionType.call, forKey: .type)
            try container.encode(name, forKey: .function)
            try container.encode(args, forKey: .args)
        case .member(let object, let property):
            try container.encode(ExpressionType.member, forKey: .type)
            try container.encode(object, forKey: .object)
            try container.encode(property, forKey: .property)
        case .index(let object, let index):
            try container.encode(ExpressionType.index, forKey: .type)
            try container.encode(object, forKey: .object)
            try container.encode(index, forKey: .index)
        case .ternary(let condition, let thenExpr, let elseExpr):
            try container.encode(ExpressionType.ternary, forKey: .type)
            try container.encode(condition, forKey: .condition)
            try container.encode(thenExpr, forKey: .thenExpr)
            try container.encode(elseExpr, forKey: .elseExpr)
        case .lambda(let param, let body):
            try container.encode(ExpressionType.lambda, forKey: .type)
            try container.encode(param, forKey: .param)
            try container.encode(body, forKey: .body)
        case .regex(let pattern):
            try container.encode(ExpressionType.regex, forKey: .type)
            try container.encode(pattern, forKey: .pattern)
        }
    }
}
