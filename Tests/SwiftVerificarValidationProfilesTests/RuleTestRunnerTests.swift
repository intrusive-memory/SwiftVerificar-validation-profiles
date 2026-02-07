import Testing
@testable import SwiftVerificarValidationProfiles

@Suite("RuleTestRunner Tests")
struct RuleTestRunnerTests {

    @Test("Runs passing rule test")
    func runPassingTest() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Document must contain StructTreeRoot",
            test: "containsStructTreeRoot == true",
            error: ErrorDetails(message: "Missing StructTreeRoot"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["containsStructTreeRoot": .bool(true)]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(result.passed)
        #expect(result.error == nil)
        #expect(result.rule.id == rule.id)
    }

    @Test("Runs failing rule test")
    func runFailingTest() throws {
        let errorDetails = ErrorDetails(message: "Missing StructTreeRoot")
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Document must contain StructTreeRoot",
            test: "containsStructTreeRoot == true",
            error: errorDetails,
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["containsStructTreeRoot": .bool(false)]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(!result.passed)
        #expect(result.error?.message == "Missing StructTreeRoot")
    }

    @Test("Throws on object type mismatch")
    func throwsOnObjectTypeMismatch() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test rule",
            test: "true",
            error: ErrorDetails(message: "Error"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdPage,  // Mismatch
            properties: [:]
        )

        let runner = RuleTestRunner()

        #expect(throws: RuleTestError.self) {
            try runner.run(rule: rule, context: context)
        }
    }

    @Test("Throws on parse error")
    func throwsOnParseError() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test rule",
            test: "invalid syntax !!@@##",  // Invalid
            error: ErrorDetails(message: "Error"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [:]
        )

        let runner = RuleTestRunner()

        #expect(throws: RuleTestError.self) {
            try runner.run(rule: rule, context: context)
        }
    }

    @Test("Throws on evaluation error")
    func throwsOnEvaluationError() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test rule",
            test: "unknownIdentifier == true",  // Unknown identifier
            error: ErrorDetails(message: "Error"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [:]
        )

        let runner = RuleTestRunner()

        #expect(throws: RuleTestError.self) {
            try runner.run(rule: rule, context: context)
        }
    }

    @Test("Runs complex expression")
    func runComplexExpression() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Complex test",
            test: "(version == \"2.0\" || version == \"1.7\") && structTreeExists == true",
            error: ErrorDetails(message: "Failed"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [
                "version": .string("2.0"),
                "structTreeExists": .bool(true)
            ]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(result.passed)
    }

    @Test("Uses context variables in evaluation")
    func usesContextVariables() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test with variables",
            test: "version == maxVersion",
            error: ErrorDetails(message: "Version mismatch"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["version": .string("2.0")],
            variables: ["maxVersion": .string("2.0")]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(result.passed)
    }

    @Test("Properties override variables in evaluation")
    func propertiesOverrideVariables() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test precedence",
            test: "value == \"property\"",
            error: ErrorDetails(message: "Failed"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["value": .string("property")],
            variables: ["value": .string("variable")]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(result.passed)
    }

    @Test("Runs multiple rules")
    func runMultipleRules() throws {
        let rules = [
            ValidationRule(
                id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
                object: "PDDocument",
                description: "Test 1",
                test: "a == true",
                error: ErrorDetails(message: "Error 1"),
                references: [],
                tags: []
            ),
            ValidationRule(
                id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 2),
                object: "PDDocument",
                description: "Test 2",
                test: "b == true",
                error: ErrorDetails(message: "Error 2"),
                references: [],
                tags: []
            )
        ]

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [
                "a": .bool(true),
                "b": .bool(false)
            ]
        )

        let runner = RuleTestRunner()
        let results = try runner.run(rules: rules, context: context)

        #expect(results.count == 2)
        #expect(results[0].passed)
        #expect(!results[1].passed)
    }

    @Test("Result description for passing test")
    func resultDescriptionForPass() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test rule",
            test: "true",
            error: ErrorDetails(message: "Error"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [:]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        let description = result.description
        #expect(description.contains("PASS"))
        #expect(description.contains("ISO_14289_2-8.2-1"))
        #expect(description.contains("Test rule"))
    }

    @Test("Result description for failing test")
    func resultDescriptionForFail() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test rule",
            test: "false",
            error: ErrorDetails(message: "Test failed"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [:]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        let description = result.description
        #expect(description.contains("FAIL"))
        #expect(description.contains("ISO_14289_2-8.2-1"))
        #expect(description.contains("Test failed"))
    }

    @Test("RuleTestError description for object type mismatch")
    func errorDescriptionForObjectTypeMismatch() {
        let error = RuleTestError.objectTypeMismatch(
            ruleObject: "PDDocument",
            contextObject: "PDPage"
        )

        let description = error.description
        #expect(description.contains("Object type mismatch"))
        #expect(description.contains("PDDocument"))
        #expect(description.contains("PDPage"))
    }

    @Test("RuleTestError description for parse error")
    func errorDescriptionForParseError() {
        let parseError = ExpressionParseError.unexpectedToken(expected: "identifier", found: "number", position: 5)
        let error = RuleTestError.parseError(
            rule: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            error: parseError
        )

        let description = error.description
        #expect(description.contains("Parse error"))
        #expect(description.contains("ISO_14289_2-8.2-1"))
    }

    @Test("Runs rule with null checks")
    func runRuleWithNullChecks() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test null handling",
            test: "optional != null",
            error: ErrorDetails(message: "Value is null"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["optional": .string("value")]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(result.passed)
    }

    @Test("Runs rule with array operations")
    func runRuleWithArrayOperations() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test array operations",
            test: "items.length > 0",
            error: ErrorDetails(message: "Empty array"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["items": .array([.int(1), .int(2), .int(3)])]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(result.passed)
    }

    @Test("Runs rule with string methods")
    func runRuleWithStringMethods() throws {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test string methods",
            test: "text.toLowerCase() == \"hello\"",
            error: ErrorDetails(message: "Wrong text"),
            references: [],
            tags: []
        )

        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["text": .string("HELLO")]
        )

        let runner = RuleTestRunner()
        let result = try runner.run(rule: rule, context: context)

        #expect(result.passed)
    }
}
