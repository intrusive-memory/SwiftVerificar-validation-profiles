import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ErrorArgument Tests")
struct ErrorArgumentTests {

    // MARK: - Initialization

    @Test("ErrorArgument stores name correctly")
    func initialization() {
        let arg = ErrorArgument(name: "fontName")
        #expect(arg.name == "fontName")
    }

    @Test("ErrorArgument with various name formats")
    func variousNames() {
        let camelCase = ErrorArgument(name: "fontName")
        let simple = ErrorArgument(name: "value")
        let empty = ErrorArgument(name: "")
        let dotted = ErrorArgument(name: "font.name")

        #expect(camelCase.name == "fontName")
        #expect(simple.name == "value")
        #expect(empty.name == "")
        #expect(dotted.name == "font.name")
    }

    // MARK: - Hashable

    @Test("Equal ErrorArguments are equal")
    func hashableEquality() {
        let arg1 = ErrorArgument(name: "fontName")
        let arg2 = ErrorArgument(name: "fontName")

        #expect(arg1 == arg2)
        #expect(arg1.hashValue == arg2.hashValue)
    }

    @Test("Different ErrorArguments are not equal")
    func hashableInequality() {
        let arg1 = ErrorArgument(name: "fontName")
        let arg2 = ErrorArgument(name: "fontSize")

        #expect(arg1 != arg2)
    }

    @Test("ErrorArguments can be stored in a Set")
    func setStorage() {
        let arg1 = ErrorArgument(name: "fontName")
        let arg2 = ErrorArgument(name: "fontName")
        let arg3 = ErrorArgument(name: "fontSize")

        let set: Set<ErrorArgument> = [arg1, arg2, arg3]
        #expect(set.count == 2)
    }

    // MARK: - Codable

    @Test("ErrorArgument round-trips through JSON")
    func codableRoundTrip() throws {
        let original = ErrorArgument(name: "fontName")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ErrorArgument.self, from: data)

        #expect(decoded == original)
        #expect(decoded.name == "fontName")
    }

    @Test("ErrorArgument array round-trips through JSON")
    func codableArrayRoundTrip() throws {
        let originals = [
            ErrorArgument(name: "fontName"),
            ErrorArgument(name: "fontSize"),
            ErrorArgument(name: "pageNumber"),
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(originals)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([ErrorArgument].self, from: data)

        #expect(decoded.count == 3)
        #expect(decoded[0].name == "fontName")
        #expect(decoded[1].name == "fontSize")
        #expect(decoded[2].name == "pageNumber")
    }
}
