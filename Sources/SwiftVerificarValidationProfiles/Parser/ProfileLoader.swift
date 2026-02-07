import Foundation

/// Thread-safe profile loader with caching for validation profiles.
///
/// `ProfileLoader` provides asynchronous access to bundled validation profile
/// XML files. It parses profiles on first access and caches them for subsequent
/// requests, ensuring efficient repeated access.
///
/// ## Usage
/// ```swift
/// // Get the shared instance
/// let loader = ProfileLoader.shared
///
/// // Load a profile (cached after first load)
/// let profile = try await loader.loadProfile(for: .pdfUA2)
///
/// // Clear the cache if needed
/// await loader.clearCache()
/// ```
///
/// ## Thread Safety
/// `ProfileLoader` is an actor, ensuring all mutable state access is serialized.
/// Multiple concurrent calls to `loadProfile(for:)` for the same flavour will
/// result in only one parse operation, with subsequent calls receiving the
/// cached result.
///
/// ## Resource Bundle
/// Profiles are loaded from the package's resource bundle at:
/// `Resources/Profiles/PDF_UA/` and `Resources/Profiles/PDF_A/`
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public actor ProfileLoader {

    /// The shared singleton instance.
    public static let shared = ProfileLoader()

    /// Cached profiles keyed by flavour.
    private var cache: [PDFFlavour: ValidationProfile] = [:]

    /// The parser used to parse XML profiles.
    private let parser = ProfileXMLParser()

    /// Creates a new profile loader.
    ///
    /// Prefer using ``shared`` for the singleton instance with caching.
    public init() {}

    /// Loads a validation profile for the specified flavour.
    ///
    /// If the profile has been loaded previously, the cached version is returned.
    /// Otherwise, the profile is parsed from the bundled XML file and cached.
    ///
    /// - Parameter flavour: The PDF flavour to load the profile for.
    /// - Returns: The parsed `ValidationProfile`.
    /// - Throws: `ProfileLoadError` if the profile cannot be found or read,
    ///   or `ProfileParseError` if the XML is malformed.
    public func loadProfile(for flavour: PDFFlavour) throws -> ValidationProfile {
        // Return cached profile if available
        if let cached = cache[flavour] {
            return cached
        }

        // Load and parse the profile
        let profile = try loadProfileFromResources(flavour)
        cache[flavour] = profile
        return profile
    }

    /// Clears all cached profiles.
    ///
    /// After calling this method, subsequent calls to ``loadProfile(for:)``
    /// will re-parse the XML files from disk.
    public func clearCache() {
        cache.removeAll()
    }

    /// Returns whether a profile for the specified flavour is currently cached.
    ///
    /// - Parameter flavour: The flavour to check.
    /// - Returns: `true` if the profile is cached, `false` otherwise.
    public func isCached(_ flavour: PDFFlavour) -> Bool {
        cache[flavour] != nil
    }

    /// Returns the number of currently cached profiles.
    public var cachedProfileCount: Int {
        cache.count
    }

    /// Returns all currently cached flavours.
    public var cachedFlavours: Set<PDFFlavour> {
        Set(cache.keys)
    }

    /// Preloads profiles for the specified flavours.
    ///
    /// This method loads and caches multiple profiles, which can be useful
    /// for warming the cache at application startup.
    ///
    /// - Parameter flavours: The flavours to preload.
    /// - Throws: The first error encountered during loading.
    public func preloadProfiles(for flavours: [PDFFlavour]) throws {
        for flavour in flavours {
            _ = try loadProfile(for: flavour)
        }
    }

    // MARK: - Private Methods

    /// Loads a profile from the resource bundle.
    private func loadProfileFromResources(_ flavour: PDFFlavour) throws -> ValidationProfile {
        let filename = profileFilename(for: flavour)
        let subdirectory = profileSubdirectory(for: flavour)

        guard let url = Bundle.module.url(
            forResource: filename,
            withExtension: "xml",
            subdirectory: subdirectory
        ) else {
            throw ProfileLoadError.profileNotFound(flavour)
        }

        return try parser.parse(contentsOf: url)
    }

    /// Returns the filename (without extension) for a flavour's profile.
    private func profileFilename(for flavour: PDFFlavour) -> String {
        switch flavour {
        case .pdfUA2:
            return "PDFUA-2"
        case .pdfUA1:
            return "PDFUA-1"
        case .pdfA1a:
            return "PDFA-1A"
        case .pdfA1b:
            return "PDFA-1B"
        case .pdfA2a:
            return "PDFA-2A"
        case .pdfA2b:
            return "PDFA-2B"
        case .pdfA2u:
            return "PDFA-2U"
        case .pdfA3a:
            return "PDFA-3A"
        case .pdfA3b:
            return "PDFA-3B"
        case .pdfA3u:
            return "PDFA-3U"
        case .pdfA4:
            return "PDFA-4"
        case .pdfA4e:
            return "PDFA-4E"
        case .pdfA4f:
            return "PDFA-4F"
        case .wcag22:
            return "WCAG-2-2"
        case .wtpdf1Accessibility:
            return "WTPDF-1-0-Accessibility"
        case .wtpdf1Reuse:
            return "WTPDF-1-0-Reuse"
        }
    }

    /// Returns the subdirectory within Resources/Profiles for a flavour.
    private func profileSubdirectory(for flavour: PDFFlavour) -> String {
        switch flavour {
        case .pdfUA1, .pdfUA2, .wcag22, .wtpdf1Accessibility, .wtpdf1Reuse:
            return "Profiles/PDF_UA"
        case .pdfA1a, .pdfA1b, .pdfA2a, .pdfA2b, .pdfA2u,
             .pdfA3a, .pdfA3b, .pdfA3u, .pdfA4, .pdfA4e, .pdfA4f:
            return "Profiles/PDF_A"
        }
    }
}
