import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("Reference Tests")
struct ReferenceTests {

    // MARK: - Initialization

    @Test("Reference stores specification and clause correctly")
    func initialization() {
        let ref = Reference(specification: "ISO 14289-2:2024", clause: "8.2.5.26")

        #expect(ref.specification == "ISO 14289-2:2024")
        #expect(ref.clause == "8.2.5.26")
    }

    @Test("Reference with various specification formats")
    func variousFormats() {
        let iso = Reference(specification: "ISO 14289-2:2024", clause: "8.2")
        let pdf = Reference(specification: "PDF 2.0", clause: "7.7")
        let wcag = Reference(specification: "WCAG 2.2", clause: "1.1.1")

        #expect(iso.specification == "ISO 14289-2:2024")
        #expect(pdf.specification == "PDF 2.0")
        #expect(wcag.specification == "WCAG 2.2")
    }

    @Test("Reference with various clause formats")
    func variousClauses() {
        let simple = Reference(specification: "ISO 14289-2:2024", clause: "8")
        let dotted = Reference(specification: "ISO 14289-2:2024", clause: "8.2.5.26")
        let annex = Reference(specification: "ISO 14289-2:2024", clause: "A.1")
        let empty = Reference(specification: "ISO 14289-2:2024", clause: "")

        #expect(simple.clause == "8")
        #expect(dotted.clause == "8.2.5.26")
        #expect(annex.clause == "A.1")
        #expect(empty.clause == "")
    }

    // MARK: - Hashable

    @Test("Equal References are equal")
    func hashableEquality() {
        let ref1 = Reference(specification: "ISO 14289-2:2024", clause: "8.2")
        let ref2 = Reference(specification: "ISO 14289-2:2024", clause: "8.2")

        #expect(ref1 == ref2)
        #expect(ref1.hashValue == ref2.hashValue)
    }

    @Test("References with different specifications are not equal")
    func hashableInequalitySpec() {
        let ref1 = Reference(specification: "ISO 14289-2:2024", clause: "8.2")
        let ref2 = Reference(specification: "ISO 14289-1:2014", clause: "8.2")

        #expect(ref1 != ref2)
    }

    @Test("References with different clauses are not equal")
    func hashableInequalityClause() {
        let ref1 = Reference(specification: "ISO 14289-2:2024", clause: "8.2")
        let ref2 = Reference(specification: "ISO 14289-2:2024", clause: "8.3")

        #expect(ref1 != ref2)
    }

    @Test("References can be stored in a Set")
    func setStorage() {
        let ref1 = Reference(specification: "ISO 14289-2:2024", clause: "8.2")
        let ref2 = Reference(specification: "ISO 14289-2:2024", clause: "8.2")
        let ref3 = Reference(specification: "ISO 14289-2:2024", clause: "8.3")

        let set: Set<Reference> = [ref1, ref2, ref3]
        #expect(set.count == 2)
    }

    // MARK: - Codable

    @Test("Reference round-trips through JSON")
    func codableRoundTrip() throws {
        let original = Reference(specification: "ISO 14289-2:2024", clause: "8.2.5.26")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Reference.self, from: data)

        #expect(decoded == original)
        #expect(decoded.specification == "ISO 14289-2:2024")
        #expect(decoded.clause == "8.2.5.26")
    }

    @Test("Reference array round-trips through JSON")
    func codableArrayRoundTrip() throws {
        let originals = [
            Reference(specification: "ISO 14289-2:2024", clause: "8.2"),
            Reference(specification: "WCAG 2.2", clause: "1.1.1"),
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(originals)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([Reference].self, from: data)

        #expect(decoded.count == 2)
        #expect(decoded[0] == originals[0])
        #expect(decoded[1] == originals[1])
    }
}
