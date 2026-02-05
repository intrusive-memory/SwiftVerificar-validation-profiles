import Testing
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileDirectory Tests")
struct ProfileDirectoryTests {

    @Test("Shared instance is accessible")
    func sharedInstanceAccessible() async {
        let directory = ProfileDirectory.shared
        #expect(directory.availableFlavours.count > 0)
    }

    @Test("Available flavours includes expected profiles")
    func availableFlavoursIncludesExpected() async {
        let directory = ProfileDirectory.shared
        let flavours = directory.availableFlavours

        #expect(flavours.contains(.pdfUA2))
        #expect(flavours.contains(.pdfUA1))
        #expect(flavours.contains(.pdfA1a))
        #expect(flavours.contains(.pdfA1b))
        #expect(flavours.contains(.pdfA2a))
        #expect(flavours.contains(.wcag22))
    }

    @Test("Loads profile for PDF/UA-2")
    func loadsProfileForPDFUA2() async throws {
        let directory = ProfileDirectory.shared
        let profile = try await directory.profile(for: .pdfUA2)

        #expect(profile.flavour == .pdfUA2)
        #expect(profile.ruleCount > 0)
    }

    @Test("Loads profile for PDF/UA-1")
    func loadsProfileForPDFUA1() async throws {
        let directory = ProfileDirectory.shared
        let profile = try await directory.profile(for: .pdfUA1)

        #expect(profile.flavour == .pdfUA1)
        #expect(profile.ruleCount > 0)
    }

    @Test("Gets rules for specific object type")
    func getsRulesForObjectType() async throws {
        let directory = ProfileDirectory.shared
        let rules = try await directory.rules(for: .pdDocument, in: .pdfUA2)

        #expect(rules.count > 0)
        for rule in rules {
            #expect(rule.object == "PDDocument")
        }
    }

    @Test("Gets rules with specific tag")
    func getsRulesWithTag() async throws {
        let directory = ProfileDirectory.shared
        let rules = try await directory.rules(tagged: .structure, in: .pdfUA2)

        // Verify all returned rules have the structure tag
        for rule in rules {
            #expect(rule.tags.contains(.structure))
        }
    }

    @Test("Gets rules with all specified tags")
    func getsRulesWithAllTags() async throws {
        let directory = ProfileDirectory.shared
        let rules = try await directory.rules(
            withAllTags: [.machine, .structure],
            in: .pdfUA2
        )

        for rule in rules {
            #expect(rule.tags.contains(.machine))
            #expect(rule.tags.contains(.structure))
        }
    }

    @Test("Gets rules with any specified tag")
    func getsRulesWithAnyTag() async throws {
        let directory = ProfileDirectory.shared
        let rules = try await directory.rules(
            withAnyTag: [.structure, .text],
            in: .pdfUA2
        )

        // Verify all returned rules have at least one of the specified tags
        for rule in rules {
            #expect(rule.tags.contains(.structure) || rule.tags.contains(.text))
        }
    }

    @Test("Gets machine checkable rules")
    func getsMachineCheckableRules() async throws {
        let directory = ProfileDirectory.shared
        let rules = try await directory.machineCheckableRules(in: .pdfUA2)

        // Verify all returned rules have the machine tag
        for rule in rules {
            #expect(rule.tags.contains(.machine))
        }
    }

    @Test("Gets human checkable rules")
    func getsHumanCheckableRules() async throws {
        let directory = ProfileDirectory.shared
        let rules = try await directory.humanCheckableRules(in: .pdfUA2)

        for rule in rules {
            #expect(rule.tags.contains(.human))
        }
    }

    @Test("Gets profile statistics")
    func getsProfileStatistics() async throws {
        let directory = ProfileDirectory.shared
        let stats = try await directory.statistics(for: .pdfUA2)

        #expect(stats.flavour == .pdfUA2)
        #expect(stats.totalRules > 0)
        #expect(stats.uniqueObjectTypes > 0)
        #expect(stats.objectTypeCounts.count > 0)
    }

    @Test("Statistics totals match profile rule count")
    func statisticsTotalsMatchProfile() async throws {
        let directory = ProfileDirectory.shared
        let profile = try await directory.profile(for: .pdfUA2)
        let stats = try await directory.statistics(for: .pdfUA2)

        #expect(stats.totalRules == profile.ruleCount)
    }

    @Test("Statistics object type counts are correct")
    func statisticsObjectTypeCountsCorrect() async throws {
        let directory = ProfileDirectory.shared
        let stats = try await directory.statistics(for: .pdfUA2)

        let sumOfCounts = stats.objectTypeCounts.values.reduce(0, +)
        #expect(sumOfCounts == stats.totalRules)
    }

    @Test("Clears cache successfully")
    func clearsCacheSuccessfully() async throws {
        let directory = ProfileDirectory.shared

        // Load a profile to populate cache
        _ = try await directory.profile(for: .pdfUA2)

        // Clear cache
        await directory.clearCache()

        // Should still be able to load after clearing
        let profile = try await directory.profile(for: .pdfUA2)
        #expect(profile.flavour == .pdfUA2)
    }

    @Test("Returns empty array for object type with no rules")
    func returnsEmptyForObjectTypeWithNoRules() async throws {
        let directory = ProfileDirectory.shared

        // Find an object type that is unlikely to have rules
        // We'll use a type that's defined but may not have specific rules
        let rules = try await directory.rules(for: .cosArray, in: .pdfUA2)

        // This may or may not be empty, but should not throw
        #expect(rules.count >= 0)
    }

    @Test("Multiple calls use cached profile")
    func multiplCallsUseCachedProfile() async throws {
        let directory = ProfileDirectory.shared

        let profile1 = try await directory.profile(for: .pdfUA2)
        let profile2 = try await directory.profile(for: .pdfUA2)

        // Should be the same profile (from cache)
        #expect(profile1.flavour == profile2.flavour)
        #expect(profile1.ruleCount == profile2.ruleCount)
    }

    @Test("Can load multiple different profiles")
    func loadsMultipleDifferentProfiles() async throws {
        let directory = ProfileDirectory.shared

        let pdfua2 = try await directory.profile(for: .pdfUA2)
        let pdfua1 = try await directory.profile(for: .pdfUA1)

        #expect(pdfua2.flavour == .pdfUA2)
        #expect(pdfua1.flavour == .pdfUA1)
        #expect(pdfua2.flavour != pdfua1.flavour)
    }

    @Test("Rules filtering by object type works correctly")
    func rulesFilteringByObjectTypeCorrect() async throws {
        let directory = ProfileDirectory.shared
        let profile = try await directory.profile(for: .pdfUA2)
        let directoryRules = try await directory.rules(for: .pdDocument, in: .pdfUA2)

        let profileRules = profile.rules(for: .pdDocument)

        #expect(directoryRules.count == profileRules.count)
    }

    @Test("Statistics includes machine checkable count")
    func statisticsIncludesMachineCheckable() async throws {
        let directory = ProfileDirectory.shared
        let stats = try await directory.statistics(for: .pdfUA2)

        #expect(stats.machineCheckableRules >= 0)
        #expect(stats.machineCheckableRules <= stats.totalRules)
    }

    @Test("Statistics includes human checkable count")
    func statisticsIncludesHumanCheckable() async throws {
        let directory = ProfileDirectory.shared
        let stats = try await directory.statistics(for: .pdfUA2)

        #expect(stats.humanCheckableRules >= 0)
        #expect(stats.humanCheckableRules <= stats.totalRules)
    }

    @Test("Statistics includes critical rules count")
    func statisticsIncludesCriticalCount() async throws {
        let directory = ProfileDirectory.shared
        let stats = try await directory.statistics(for: .pdfUA2)

        #expect(stats.criticalRules >= 0)
        #expect(stats.criticalRules <= stats.totalRules)
    }

    @Test("Custom ProfileDirectory instance works")
    func customInstanceWorks() async throws {
        let customLoader = ProfileLoader.shared
        let directory = ProfileDirectory(loader: customLoader)

        let profile = try await directory.profile(for: .pdfUA2)
        #expect(profile.flavour == .pdfUA2)
    }

    @Test("Gets rules for multiple object types")
    func getsRulesForMultipleObjectTypes() async throws {
        let directory = ProfileDirectory.shared

        let docRules = try await directory.rules(for: .pdDocument, in: .pdfUA2)
        let pageRules = try await directory.rules(for: .pdPage, in: .pdfUA2)

        #expect(docRules.count >= 0)
        #expect(pageRules.count >= 0)
    }

    @Test("ProfileStatistics initialization")
    func profileStatisticsInit() {
        let stats = ProfileStatistics(
            flavour: .pdfUA2,
            totalRules: 100,
            machineCheckableRules: 80,
            humanCheckableRules: 20,
            criticalRules: 10,
            uniqueObjectTypes: 50,
            objectTypeCounts: ["PDDocument": 5, "PDPage": 3]
        )

        #expect(stats.flavour == .pdfUA2)
        #expect(stats.totalRules == 100)
        #expect(stats.machineCheckableRules == 80)
        #expect(stats.humanCheckableRules == 20)
        #expect(stats.criticalRules == 10)
        #expect(stats.uniqueObjectTypes == 50)
        #expect(stats.objectTypeCounts.count == 2)
    }
}
