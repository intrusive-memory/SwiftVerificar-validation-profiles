import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ErrorDetails Tests")
struct ErrorDetailsTests {

    // MARK: - Initialization

    @Test("ErrorDetails stores message and arguments correctly")
    func initialization() {
        let args = [ErrorArgument(name: "fontName"), ErrorArgument(name: "pageNumber")]
        let details = ErrorDetails(message: "Font %1 on page %2 is not embedded", arguments: args)

        #expect(details.message == "Font %1 on page %2 is not embedded")
        #expect(details.arguments.count == 2)
        #expect(details.arguments[0].name == "fontName")
        #expect(details.arguments[1].name == "pageNumber")
    }

    @Test("ErrorDetails with empty arguments defaults correctly")
    func emptyArgumentsDefault() {
        let details = ErrorDetails(message: "Document missing StructTreeRoot")

        #expect(details.message == "Document missing StructTreeRoot")
        #expect(details.arguments.isEmpty)
    }

    @Test("ErrorDetails with explicit empty arguments")
    func explicitEmptyArguments() {
        let details = ErrorDetails(message: "Simple error", arguments: [])

        #expect(details.message == "Simple error")
        #expect(details.arguments.isEmpty)
    }

    // MARK: - Formatted Message

    @Test("formattedMessage substitutes single placeholder")
    func formattedMessageSingle() {
        let details = ErrorDetails(
            message: "Font %1 is not embedded",
            arguments: [ErrorArgument(name: "fontName")]
        )

        let result = details.formattedMessage(with: ["fontName": "Arial"])
        #expect(result == "Font Arial is not embedded")
    }

    @Test("formattedMessage substitutes multiple placeholders")
    func formattedMessageMultiple() {
        let details = ErrorDetails(
            message: "Font %1 on page %2 has width difference %3",
            arguments: [
                ErrorArgument(name: "fontName"),
                ErrorArgument(name: "pageNumber"),
                ErrorArgument(name: "difference"),
            ]
        )

        let result = details.formattedMessage(with: [
            "fontName": "Times-Roman",
            "pageNumber": "5",
            "difference": "2.5",
        ])
        #expect(result == "Font Times-Roman on page 5 has width difference 2.5")
    }

    @Test("formattedMessage uses <unknown> for missing values")
    func formattedMessageMissingValues() {
        let details = ErrorDetails(
            message: "Font %1 has issue %2",
            arguments: [
                ErrorArgument(name: "fontName"),
                ErrorArgument(name: "issue"),
            ]
        )

        let result = details.formattedMessage(with: ["fontName": "Helvetica"])
        #expect(result == "Font Helvetica has issue <unknown>")
    }

    @Test("formattedMessage with no placeholders returns message unchanged")
    func formattedMessageNoPlaceholders() {
        let details = ErrorDetails(message: "A simple error occurred")

        let result = details.formattedMessage(with: [:])
        #expect(result == "A simple error occurred")
    }

    @Test("formattedMessage with empty values dictionary")
    func formattedMessageEmptyValues() {
        let details = ErrorDetails(
            message: "Font %1 error",
            arguments: [ErrorArgument(name: "fontName")]
        )

        let result = details.formattedMessage(with: [:])
        #expect(result == "Font <unknown> error")
    }

    // MARK: - Hashable

    @Test("Equal ErrorDetails are equal")
    func hashableEquality() {
        let details1 = ErrorDetails(
            message: "Error %1",
            arguments: [ErrorArgument(name: "fontName")]
        )
        let details2 = ErrorDetails(
            message: "Error %1",
            arguments: [ErrorArgument(name: "fontName")]
        )

        #expect(details1 == details2)
        #expect(details1.hashValue == details2.hashValue)
    }

    @Test("ErrorDetails with different messages are not equal")
    func hashableInequalityMessage() {
        let details1 = ErrorDetails(message: "Error A")
        let details2 = ErrorDetails(message: "Error B")

        #expect(details1 != details2)
    }

    @Test("ErrorDetails with different arguments are not equal")
    func hashableInequalityArguments() {
        let details1 = ErrorDetails(
            message: "Error %1",
            arguments: [ErrorArgument(name: "fontName")]
        )
        let details2 = ErrorDetails(
            message: "Error %1",
            arguments: [ErrorArgument(name: "fontSize")]
        )

        #expect(details1 != details2)
    }

    // MARK: - Codable

    @Test("ErrorDetails round-trips through JSON")
    func codableRoundTrip() throws {
        let original = ErrorDetails(
            message: "Font %1 on page %2 is not embedded",
            arguments: [
                ErrorArgument(name: "fontName"),
                ErrorArgument(name: "pageNumber"),
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ErrorDetails.self, from: data)

        #expect(decoded == original)
        #expect(decoded.message == original.message)
        #expect(decoded.arguments.count == 2)
    }

    @Test("ErrorDetails with empty arguments round-trips through JSON")
    func codableRoundTripEmptyArgs() throws {
        let original = ErrorDetails(message: "Simple error")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ErrorDetails.self, from: data)

        #expect(decoded == original)
        #expect(decoded.arguments.isEmpty)
    }
}
