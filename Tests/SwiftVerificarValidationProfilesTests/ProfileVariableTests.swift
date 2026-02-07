import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileVariable Tests")
struct ProfileVariableTests {

    // MARK: - Initialization

    @Test("ProfileVariable stores name, defaultValue, and description correctly")
    func initialization() {
        let variable = ProfileVariable(
            name: "maxCharacterDifference",
            defaultValue: "1",
            description: "Maximum allowed difference between font program and dictionary widths"
        )

        #expect(variable.name == "maxCharacterDifference")
        #expect(variable.defaultValue == "1")
        #expect(variable.description == "Maximum allowed difference between font program and dictionary widths")
    }

    @Test("ProfileVariable with various default value types")
    func variousDefaults() {
        let intVar = ProfileVariable(name: "maxDifference", defaultValue: "1", description: "Int value")
        let floatVar = ProfileVariable(name: "threshold", defaultValue: "0.5", description: "Float value")
        let boolVar = ProfileVariable(name: "strict", defaultValue: "true", description: "Bool value")
        let emptyVar = ProfileVariable(name: "optional", defaultValue: "", description: "Empty value")

        #expect(intVar.defaultValue == "1")
        #expect(floatVar.defaultValue == "0.5")
        #expect(boolVar.defaultValue == "true")
        #expect(emptyVar.defaultValue == "")
    }

    // MARK: - Hashable

    @Test("Equal ProfileVariables are equal")
    func hashableEquality() {
        let var1 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "A variable")
        let var2 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "A variable")

        #expect(var1 == var2)
        #expect(var1.hashValue == var2.hashValue)
    }

    @Test("ProfileVariables with different names are not equal")
    func hashableInequalityName() {
        let var1 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "A variable")
        let var2 = ProfileVariable(name: "minDiff", defaultValue: "1", description: "A variable")

        #expect(var1 != var2)
    }

    @Test("ProfileVariables with different default values are not equal")
    func hashableInequalityDefaultValue() {
        let var1 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "A variable")
        let var2 = ProfileVariable(name: "maxDiff", defaultValue: "2", description: "A variable")

        #expect(var1 != var2)
    }

    @Test("ProfileVariables with different descriptions are not equal")
    func hashableInequalityDescription() {
        let var1 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "Desc A")
        let var2 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "Desc B")

        #expect(var1 != var2)
    }

    @Test("ProfileVariables can be stored in a Set")
    func setStorage() {
        let var1 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "Desc")
        let var2 = ProfileVariable(name: "maxDiff", defaultValue: "1", description: "Desc")
        let var3 = ProfileVariable(name: "minDiff", defaultValue: "0", description: "Desc")

        let set: Set<ProfileVariable> = [var1, var2, var3]
        #expect(set.count == 2)
    }

    // MARK: - Codable

    @Test("ProfileVariable round-trips through JSON")
    func codableRoundTrip() throws {
        let original = ProfileVariable(
            name: "maxCharacterDifference",
            defaultValue: "1",
            description: "Maximum allowed difference"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ProfileVariable.self, from: data)

        #expect(decoded == original)
        #expect(decoded.name == "maxCharacterDifference")
        #expect(decoded.defaultValue == "1")
        #expect(decoded.description == "Maximum allowed difference")
    }

    @Test("ProfileVariable array round-trips through JSON")
    func codableArrayRoundTrip() throws {
        let originals = [
            ProfileVariable(name: "maxDiff", defaultValue: "1", description: "Max difference"),
            ProfileVariable(name: "threshold", defaultValue: "0.5", description: "Threshold"),
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(originals)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([ProfileVariable].self, from: data)

        #expect(decoded.count == 2)
        #expect(decoded[0] == originals[0])
        #expect(decoded[1] == originals[1])
    }
}
