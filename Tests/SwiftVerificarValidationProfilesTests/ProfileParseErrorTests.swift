import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileParseError Tests")
struct ProfileParseErrorTests {

    // MARK: - Error Cases

    @Test("invalidXML case stores underlying error")
    func invalidXMLWithError() {
        let underlying = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        let error = ProfileParseError.invalidXML(underlying)

        if case .invalidXML(let stored) = error {
            #expect(stored != nil)
            #expect((stored as NSError?)?.code == 42)
        } else {
            Issue.record("Expected invalidXML case")
        }
    }

    @Test("invalidXML case can be nil")
    func invalidXMLWithNil() {
        let error = ProfileParseError.invalidXML(nil)

        if case .invalidXML(let stored) = error {
            #expect(stored == nil)
        } else {
            Issue.record("Expected invalidXML case")
        }
    }

    @Test("missingRequiredElement stores element name")
    func missingRequiredElement() {
        let error = ProfileParseError.missingRequiredElement("profile")

        if case .missingRequiredElement(let name) = error {
            #expect(name == "profile")
        } else {
            Issue.record("Expected missingRequiredElement case")
        }
    }

    @Test("invalidAttributeValue stores attribute name and value")
    func invalidAttributeValue() {
        let error = ProfileParseError.invalidAttributeValue(attributeName: "flavour", value: "UNKNOWN")

        if case .invalidAttributeValue(let name, let value) = error {
            #expect(name == "flavour")
            #expect(value == "UNKNOWN")
        } else {
            Issue.record("Expected invalidAttributeValue case")
        }
    }

    @Test("unknownFlavour stores flavour string")
    func unknownFlavour() {
        let error = ProfileParseError.unknownFlavour("INVALID_FLAVOUR")

        if case .unknownFlavour(let flavour) = error {
            #expect(flavour == "INVALID_FLAVOUR")
        } else {
            Issue.record("Expected unknownFlavour case")
        }
    }

    @Test("emptyProfile case exists")
    func emptyProfile() {
        let error = ProfileParseError.emptyProfile
        if case .emptyProfile = error {
            // Success
        } else {
            Issue.record("Expected emptyProfile case")
        }
    }

    // MARK: - Equatable

    @Test("Equal invalidXML errors with same description are equal")
    func invalidXMLEquality() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Same"])
        let error2 = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Same"])

        #expect(ProfileParseError.invalidXML(error1) == ProfileParseError.invalidXML(error2))
    }

    @Test("invalidXML with nil equals invalidXML with nil")
    func invalidXMLNilEquality() {
        #expect(ProfileParseError.invalidXML(nil) == ProfileParseError.invalidXML(nil))
    }

    @Test("Different invalidXML errors are not equal")
    func invalidXMLInequality() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error 1"])
        let error2 = NSError(domain: "Test", code: 2, userInfo: [NSLocalizedDescriptionKey: "Error 2"])

        #expect(ProfileParseError.invalidXML(error1) != ProfileParseError.invalidXML(error2))
    }

    @Test("Same missingRequiredElement are equal")
    func missingRequiredElementEquality() {
        #expect(ProfileParseError.missingRequiredElement("test") == ProfileParseError.missingRequiredElement("test"))
    }

    @Test("Different missingRequiredElement are not equal")
    func missingRequiredElementInequality() {
        #expect(ProfileParseError.missingRequiredElement("test1") != ProfileParseError.missingRequiredElement("test2"))
    }

    @Test("Same invalidAttributeValue are equal")
    func invalidAttributeValueEquality() {
        let error1 = ProfileParseError.invalidAttributeValue(attributeName: "attr", value: "val")
        let error2 = ProfileParseError.invalidAttributeValue(attributeName: "attr", value: "val")
        #expect(error1 == error2)
    }

    @Test("Different invalidAttributeValue are not equal")
    func invalidAttributeValueInequality() {
        let error1 = ProfileParseError.invalidAttributeValue(attributeName: "attr1", value: "val")
        let error2 = ProfileParseError.invalidAttributeValue(attributeName: "attr2", value: "val")
        #expect(error1 != error2)
    }

    @Test("Same unknownFlavour are equal")
    func unknownFlavourEquality() {
        #expect(ProfileParseError.unknownFlavour("X") == ProfileParseError.unknownFlavour("X"))
    }

    @Test("Different unknownFlavour are not equal")
    func unknownFlavourInequality() {
        #expect(ProfileParseError.unknownFlavour("X") != ProfileParseError.unknownFlavour("Y"))
    }

    @Test("emptyProfile equals emptyProfile")
    func emptyProfileEquality() {
        #expect(ProfileParseError.emptyProfile == ProfileParseError.emptyProfile)
    }

    @Test("Different error types are not equal")
    func differentTypesInequality() {
        #expect(ProfileParseError.emptyProfile != ProfileParseError.missingRequiredElement("test"))
        #expect(ProfileParseError.unknownFlavour("X") != ProfileParseError.emptyProfile)
    }

    // MARK: - LocalizedError

    @Test("invalidXML has error description with underlying error")
    func invalidXMLErrorDescription() {
        let underlying = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = ProfileParseError.invalidXML(underlying)

        #expect(error.errorDescription?.contains("Invalid XML") == true)
        #expect(error.errorDescription?.contains("Test error") == true)
    }

    @Test("invalidXML has error description without underlying error")
    func invalidXMLErrorDescriptionNil() {
        let error = ProfileParseError.invalidXML(nil)
        #expect(error.errorDescription == "Invalid XML structure")
    }

    @Test("missingRequiredElement has error description")
    func missingRequiredElementErrorDescription() {
        let error = ProfileParseError.missingRequiredElement("details")
        #expect(error.errorDescription?.contains("details") == true)
        #expect(error.errorDescription?.contains("Missing required element") == true)
    }

    @Test("invalidAttributeValue has error description")
    func invalidAttributeValueErrorDescription() {
        let error = ProfileParseError.invalidAttributeValue(attributeName: "flavour", value: "BAD")
        #expect(error.errorDescription?.contains("flavour") == true)
        #expect(error.errorDescription?.contains("BAD") == true)
    }

    @Test("unknownFlavour has error description")
    func unknownFlavourErrorDescription() {
        let error = ProfileParseError.unknownFlavour("WEIRD_FLAVOUR")
        #expect(error.errorDescription?.contains("WEIRD_FLAVOUR") == true)
        #expect(error.errorDescription?.contains("Unknown profile flavour") == true)
    }

    @Test("emptyProfile has error description")
    func emptyProfileErrorDescription() {
        let error = ProfileParseError.emptyProfile
        #expect(error.errorDescription?.contains("empty") == true)
    }

    // MARK: - Error Protocol

    @Test("ProfileParseError conforms to Error")
    func conformsToError() {
        let error: Error = ProfileParseError.emptyProfile
        #expect(error is ProfileParseError)
    }

    @Test("ProfileParseError can be thrown and caught")
    func canBeThrown() throws {
        func throwingFunction() throws {
            throw ProfileParseError.emptyProfile
        }

        #expect(throws: ProfileParseError.self) {
            try throwingFunction()
        }
    }
}
