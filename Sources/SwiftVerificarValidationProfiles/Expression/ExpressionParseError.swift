import Foundation

/// Errors that can occur during expression parsing.
///
/// `ExpressionParseError` represents the various error conditions that
/// can occur when parsing a rule test expression string into an AST.
///
/// ## Example
/// ```swift
/// let parser = ExpressionParser()
/// do {
///     let ast = try parser.parse("x == ")  // Missing right operand
/// } catch let error as ExpressionParseError {
///     print(error.localizedDescription)
/// }
/// ```
///
/// - Note: This type is used by ``ExpressionParser`` to report parse errors.
public enum ExpressionParseError: Error, Sendable, Hashable {
    /// The input expression is empty.
    case emptyExpression

    /// An unexpected token was encountered.
    ///
    /// - Parameters:
    ///   - expected: What was expected at this position.
    ///   - found: The actual token found.
    ///   - position: The character position in the input.
    case unexpectedToken(expected: String, found: String, position: Int)

    /// An unexpected character was encountered during lexing.
    ///
    /// - Parameters:
    ///   - character: The unexpected character.
    ///   - position: The character position in the input.
    case unexpectedCharacter(character: Character, position: Int)

    /// Unexpected end of input.
    ///
    /// - Parameter expected: What was expected at the end.
    case unexpectedEndOfInput(expected: String)

    /// An unterminated string literal.
    ///
    /// - Parameter position: The position where the string started.
    case unterminatedString(position: Int)

    /// An unterminated regex literal.
    ///
    /// - Parameter position: The position where the regex started.
    case unterminatedRegex(position: Int)

    /// An invalid number literal.
    ///
    /// - Parameters:
    ///   - text: The invalid number text.
    ///   - position: The character position in the input.
    case invalidNumber(text: String, position: Int)

    /// An invalid operator.
    ///
    /// - Parameters:
    ///   - text: The invalid operator text.
    ///   - position: The character position in the input.
    case invalidOperator(text: String, position: Int)

    /// An invalid escape sequence in a string.
    ///
    /// - Parameters:
    ///   - sequence: The invalid escape sequence.
    ///   - position: The character position in the input.
    case invalidEscapeSequence(sequence: String, position: Int)

    /// Division by zero in a constant expression.
    case divisionByZero

    /// Maximum expression depth exceeded.
    ///
    /// This prevents stack overflow from deeply nested expressions.
    case maxDepthExceeded(depth: Int)
}

// MARK: - LocalizedError

extension ExpressionParseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyExpression:
            return "Expression is empty"
        case .unexpectedToken(let expected, let found, let position):
            return "Unexpected token at position \(position): expected \(expected), found '\(found)'"
        case .unexpectedCharacter(let character, let position):
            return "Unexpected character '\(character)' at position \(position)"
        case .unexpectedEndOfInput(let expected):
            return "Unexpected end of input: expected \(expected)"
        case .unterminatedString(let position):
            return "Unterminated string literal starting at position \(position)"
        case .unterminatedRegex(let position):
            return "Unterminated regex literal starting at position \(position)"
        case .invalidNumber(let text, let position):
            return "Invalid number '\(text)' at position \(position)"
        case .invalidOperator(let text, let position):
            return "Invalid operator '\(text)' at position \(position)"
        case .invalidEscapeSequence(let sequence, let position):
            return "Invalid escape sequence '\(sequence)' at position \(position)"
        case .divisionByZero:
            return "Division by zero in constant expression"
        case .maxDepthExceeded(let depth):
            return "Maximum expression depth exceeded (\(depth))"
        }
    }
}

// MARK: - CustomStringConvertible

extension ExpressionParseError: CustomStringConvertible {
    public var description: String {
        errorDescription ?? "Unknown parse error"
    }
}
