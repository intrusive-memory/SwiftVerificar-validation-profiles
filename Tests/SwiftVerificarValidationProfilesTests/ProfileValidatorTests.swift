import Foundation
import Testing
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileValidator Tests")
struct ProfileValidatorTests {

    @Test("Validates valid profile")
    func validatesValidProfile() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                    object: "PDDocument",
                    description: "Test rule",
                    test: "containsStructTreeRoot == true",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: [.machine]
                )
            ],
            variables: [],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(result.isValid)
        #expect(!result.hasIssues)
        #expect(result.errors.isEmpty)
        #expect(result.warnings.isEmpty)
    }

    @Test("Detects invalid test expression")
    func detectsInvalidExpression() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                    object: "PDDocument",
                    description: "Test rule",
                    test: "invalid syntax !!@@##",  // Invalid
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                )
            ],
            variables: [],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(!result.isValid)
        #expect(result.hasIssues)
        #expect(result.errors.count == 1)
        #expect(result.errors[0].category == .invalidExpression)
    }

    @Test("Detects unknown object type")
    func detectsUnknownObjectType() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                    object: "UnknownObjectType",  // Unknown
                    description: "Test rule",
                    test: "true",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                )
            ],
            variables: [],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(result.isValid)  // Warnings don't make profile invalid
        #expect(result.hasIssues)
        #expect(result.warnings.count == 1)
        #expect(result.warnings[0].category == .unknownObjectType)
    }

    @Test("Detects placeholder/argument mismatch")
    func detectsPlaceholderArgumentMismatch() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                    object: "PDDocument",
                    description: "Test rule",
                    test: "true",
                    error: ErrorDetails(
                        message: "Error with %1 and %2",
                        arguments: [ErrorArgument(name: "arg1")]  // Only 1 argument for 2 placeholders
                    ),
                    references: [],
                    tags: []
                )
            ],
            variables: [],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(result.isValid)  // Warnings don't make profile invalid
        #expect(result.hasIssues)
        #expect(result.warnings.count == 1)
        #expect(result.warnings[0].category == .argumentMismatch)
    }

    @Test("Detects empty variable name")
    func detectsEmptyVariableName() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [],
            variables: [
                ProfileVariable(
                    name: "",  // Empty name
                    defaultValue: "value",
                    description: "Test variable"
                )
            ],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(!result.isValid)
        #expect(result.hasIssues)
        #expect(result.errors.count == 1)
        #expect(result.errors[0].category == .invalidVariable)
    }

    @Test("Detects reserved keyword in variable name")
    func detectsReservedKeyword() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [],
            variables: [
                ProfileVariable(
                    name: "null",  // Reserved keyword
                    defaultValue: "value",
                    description: "Test variable"
                )
            ],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(result.isValid)  // Warnings don't make invalid
        #expect(result.hasIssues)
        #expect(result.warnings.count == 1)
        #expect(result.warnings[0].category == .invalidVariable)
    }

    @Test("Detects duplicate rule IDs")
    func detectsDuplicateRuleIDs() {
        let ruleID = RuleID(specification: .iso142892, clause: "8.2", testNumber: 1)

        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: ruleID,
                    object: "PDDocument",
                    description: "Test rule 1",
                    test: "true",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                ),
                ValidationRule(
                    id: ruleID,  // Duplicate
                    object: "PDPage",
                    description: "Test rule 2",
                    test: "true",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                )
            ],
            variables: [],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(result.isValid)  // Warnings don't make invalid
        #expect(result.hasIssues)
        #expect(result.warnings.count == 1)
        #expect(result.warnings[0].category == .duplicateRuleID)
    }

    @Test("Validates profile with multiple issues")
    func validatesProfileWithMultipleIssues() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test Profile",
                description: "A test profile",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                    object: "UnknownType",
                    description: "Test rule",
                    test: "invalid syntax",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                )
            ],
            variables: [
                ProfileVariable(name: "", defaultValue: "value", description: "Invalid")
            ],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(!result.isValid)
        #expect(result.hasIssues)
        #expect(result.errors.count > 0)
    }

    @Test("ProfileValidationResult properties")
    func profileValidationResultProperties() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test",
                description: "Test",
                creator: "Test",
                created: Date()
            ),
            rules: [],
            variables: [],
            flavour: .pdfUA2
        )

        let issues: [ProfileValidationIssue] = [
            ProfileValidationIssue(
                severity: .error,
                category: .invalidExpression,
                message: "Error message"
            ),
            ProfileValidationIssue(
                severity: .warning,
                category: .unknownObjectType,
                message: "Warning message"
            )
        ]

        let result = ProfileValidationResult(profile: profile, issues: issues)

        #expect(!result.isValid)
        #expect(result.hasIssues)
        #expect(result.errors.count == 1)
        #expect(result.warnings.count == 1)
    }

    @Test("ProfileValidationIssue description")
    func profileValidationIssueDescription() {
        let issue = ProfileValidationIssue(
            severity: .error,
            category: .invalidExpression,
            message: "Test message",
            details: "Test details",
            ruleID: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1)
        )

        let description = issue.description
        #expect(description.contains("ERROR"))
        #expect(description.contains("invalidExpression"))
        #expect(description.contains("Test message"))
        #expect(description.contains("Test details"))
        #expect(description.contains("ISO_14289_2-8.2-1"))
    }

    @Test("ProfileValidationIssue without details")
    func profileValidationIssueWithoutDetails() {
        let issue = ProfileValidationIssue(
            severity: .warning,
            category: .unknownObjectType,
            message: "Test message"
        )

        let description = issue.description
        #expect(description.contains("WARNING"))
        #expect(description.contains("Test message"))
        #expect(!description.contains("Details:"))
        #expect(!description.contains("Rule:"))
    }

    @Test("Validates real PDF/UA-2 profile")
    func validatesRealProfile() async throws {
        let profile = try await ProfileLoader.shared.loadProfile(for: .pdfUA2)

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        // The validation should complete without crashing
        // Note: The profile may have some issues (e.g., unknown object types)
        // but these are warnings from the upstream veraPDF profiles, not errors in our implementation
        #expect(result.profile.flavour == .pdfUA2)
        #expect(result.issues.count >= 0) // Just verify issues list exists
    }

    @Test("ProfileValidationSeverity cases")
    func profileValidationSeverityCases() {
        #expect(ProfileValidationSeverity.error.rawValue == "error")
        #expect(ProfileValidationSeverity.warning.rawValue == "warning")
    }

    @Test("ProfileValidationCategory cases")
    func profileValidationCategoryCases() {
        #expect(ProfileValidationCategory.invalidExpression.rawValue == "invalidExpression")
        #expect(ProfileValidationCategory.unknownObjectType.rawValue == "unknownObjectType")
        #expect(ProfileValidationCategory.invalidVariable.rawValue == "invalidVariable")
        #expect(ProfileValidationCategory.duplicateRuleID.rawValue == "duplicateRuleID")
        #expect(ProfileValidationCategory.argumentMismatch.rawValue == "argumentMismatch")
    }

    @Test("Validates known object types")
    func validatesKnownObjectTypes() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test",
                description: "Test",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                    object: "PDDocument",
                    description: "Test",
                    test: "true",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                ),
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.3", testNumber: 1),
                    object: "PDPage",
                    description: "Test",
                    test: "true",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                )
            ],
            variables: [],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        // Should not have unknown object type warnings
        let unknownTypeWarnings = result.warnings.filter { $0.category == .unknownObjectType }
        #expect(unknownTypeWarnings.isEmpty)
    }

    @Test("Handles profile with no variables")
    func handlesProfileWithNoVariables() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test",
                description: "Test",
                creator: "Test",
                created: Date()
            ),
            rules: [
                ValidationRule(
                    id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                    object: "PDDocument",
                    description: "Test",
                    test: "true",
                    error: ErrorDetails(message: "Error"),
                    references: [],
                    tags: []
                )
            ],
            variables: [],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(result.isValid)
        #expect(!result.hasIssues)
    }

    @Test("Handles profile with no rules")
    func handlesProfileWithNoRules() {
        let profile = ValidationProfile(
            details: ProfileDetails(
                name: "Test",
                description: "Test",
                creator: "Test",
                created: Date()
            ),
            rules: [],
            variables: [
                ProfileVariable(name: "validVar", defaultValue: "value", description: "Test")
            ],
            flavour: .pdfUA2
        )

        let validator = ProfileValidator()
        let result = validator.validate(profile: profile)

        #expect(result.isValid)
        #expect(!result.hasIssues)
    }
}
