import Foundation

/// PDF object types that validation rules can check.
///
/// Each case corresponds to a unique `object` attribute value in the XML validation profiles.
/// Raw values must match exactly -- they are used for rule lookup when matching a validation
/// rule to the PDF object it should be applied against.
///
/// The 188 cases span multiple layers of the PDF specification:
/// - COS Layer: Low-level PDF objects (arrays, dictionaries, streams, etc.)
/// - PD Layer: Page description objects (documents, pages, fonts, color spaces, etc.)
/// - SE Layer: Structure elements for tagged PDF
/// - SA Layer: Semantic accessibility objects for WCAG validation
/// - XMP Metadata: Extensible Metadata Platform objects
/// - External Objects: ICC profiles, font programs, etc.
/// - Operators: PDF content stream operators
///
/// - Note: This is a shared type consumed by validation-profiles and validation packages.
public enum PDFObjectType: String, CaseIterable, Sendable {

    // MARK: - COS Layer (low-level PDF objects) — 19 cases

    /// COS array object
    case cosArray = "CosArray"

    /// COS bounding box array
    case cosBBox = "CosBBox"

    /// COS blend mode name
    case cosBM = "CosBM"

    /// COS dictionary object
    case cosDict = "CosDict"

    /// COS document (top-level container)
    case cosDocument = "CosDocument"

    /// COS file specification dictionary
    case cosFileSpecification = "CosFileSpecification"

    /// COS stream filter
    case cosFilter = "CosFilter"

    /// COS inline image filter
    case cosIIFilter = "CosIIFilter"

    /// COS indirect object reference
    case cosIndirect = "CosIndirect"

    /// COS document info dictionary
    case cosInfo = "CosInfo"

    /// COS integer object
    case cosInteger = "CosInteger"

    /// COS name object
    case cosName = "CosName"

    /// COS real number object
    case cosReal = "CosReal"

    /// COS rendering intent name
    case cosRenderingIntent = "CosRenderingIntent"

    /// COS stream object
    case cosStream = "CosStream"

    /// COS string object
    case cosString = "CosString"

    /// COS trailer dictionary
    case cosTrailer = "CosTrailer"

    /// COS Unicode name
    case cosUnicodeName = "CosUnicodeName"

    /// COS cross-reference table/stream
    case cosXRef = "CosXRef"

    // MARK: - COS Text/Language — 4 cases

    /// COS actual text string
    case cosActualText = "CosActualText"

    /// COS alternate text (Alt attribute)
    case cosAlt = "CosAlt"

    /// COS language tag
    case cosLang = "CosLang"

    /// COS text string (generic)
    case cosTextString = "CosTextString"

    // MARK: - PD Layer -- Document — 6 cases

    /// PD document (logical document structure)
    case pdDocument = "PDDocument"

    /// PD page
    case pdPage = "PDPage"

    /// PD content stream
    case pdContentStream = "PDContentStream"

    /// PD encryption dictionary
    case pdEncryption = "PDEncryption"

    /// PD permissions dictionary
    case pdPerms = "PDPerms"

    /// PD outline (bookmarks)
    case pdOutline = "PDOutline"

    // MARK: - PD Layer -- Identification — 4 cases

    /// PDF/A identification metadata
    case pdfaIdentification = "PDFAIdentification"

    /// PDF/UA identification metadata
    case pdfuaIdentification = "PDFUAIdentification"

    /// PD UA identification metadata (alternate form)
    case pdUAIdentification = "PDUAIdentification"

    /// Main XMP metadata package
    case mainXMPPackage = "MainXMPPackage"

    // MARK: - PD Layer -- Structure — 2 cases

    /// PD structure tree root
    case pdStructTreeRoot = "PDStructTreeRoot"

    /// PD structure element
    case pdStructElem = "PDStructElem"

    // MARK: - PD Layer -- Annotations — 16 cases

    /// PD annotation (generic)
    case pdAnnot = "PDAnnot"

    /// PD 3D annotation
    case pd3DAnnot = "PD3DAnnot"

    /// PD file attachment annotation
    case pdFileAttachmentAnnot = "PDFileAttachmentAnnot"

    /// PD ink annotation
    case pdInkAnnot = "PDInkAnnot"

    /// PD link annotation
    case pdLinkAnnot = "PDLinkAnnot"

    /// PD markup annotation
    case pdMarkupAnnot = "PDMarkupAnnot"

    /// PD movie annotation
    case pdMovieAnnot = "PDMovieAnnot"

    /// PD popup annotation
    case pdPopupAnnot = "PDPopupAnnot"

    /// PD printer mark annotation
    case pdPrinterMarkAnnot = "PDPrinterMarkAnnot"

    /// PD rich media annotation
    case pdRichMediaAnnot = "PDRichMediaAnnot"

    /// PD rubber stamp annotation
    case pdRubberStampAnnot = "PDRubberStampAnnot"

    /// PD screen annotation
    case pdScreenAnnot = "PDScreenAnnot"

    /// PD sound annotation
    case pdSoundAnnot = "PDSoundAnnot"

    /// PD trap network annotation
    case pdTrapNetAnnot = "PDTrapNetAnnot"

    /// PD watermark annotation
    case pdWatermarkAnnot = "PDWatermarkAnnot"

    /// PD widget annotation (form field appearance)
    case pdWidgetAnnot = "PDWidgetAnnot"

    // MARK: - PD Layer -- Forms — 3 cases

    /// PD AcroForm (interactive form dictionary)
    case pdAcroForm = "PDAcroForm"

    /// PD form field
    case pdFormField = "PDFormField"

    /// PD text field
    case pdTextField = "PDTextField"

    // MARK: - PD Layer -- Actions/Destinations — 5 cases

    /// PD action (generic)
    case pdAction = "PDAction"

    /// PD additional actions dictionary
    case pdAdditionalActions = "PDAdditionalActions"

    /// PD destination
    case pdDestination = "PDDestination"

    /// PD GoTo action
    case pdGoToAction = "PDGoToAction"

    /// PD named action
    case pdNamedAction = "PDNamedAction"

    // MARK: - PD Layer -- Fonts — 10 cases

    /// PD font (generic)
    case pdFont = "PDFont"

    /// PD simple font
    case pdSimpleFont = "PDSimpleFont"

    /// PD Type 0 (composite) font
    case pdType0Font = "PDType0Font"

    /// PD Type 1 font
    case pdType1Font = "PDType1Font"

    /// PD TrueType font
    case pdTrueTypeFont = "PDTrueTypeFont"

    /// PD CID font
    case pdCIDFont = "PDCIDFont"

    /// PD CMap
    case pdCMap = "PDCMap"

    /// PD referenced CMap
    case pdReferencedCMap = "PDReferencedCMap"

    /// CMap file
    case cMapFile = "CMapFile"

    /// Individual glyph
    case glyph = "Glyph"

    // MARK: - PD Layer -- Color Spaces — 7 cases

    /// PD DeviceGray color space
    case pdDeviceGray = "PDDeviceGray"

    /// PD DeviceRGB color space
    case pdDeviceRGB = "PDDeviceRGB"

    /// PD DeviceCMYK color space
    case pdDeviceCMYK = "PDDeviceCMYK"

    /// PD DeviceN color space
    case pdDeviceN = "PDDeviceN"

    /// PD ICC-based CMYK color space
    case pdICCBasedCMYK = "PDICCBasedCMYK"

    /// PD Separation color space
    case pdSeparation = "PDSeparation"

    /// Transparency color space
    case transparencyColorSpace = "TransparencyColorSpace"

    // MARK: - PD Layer -- Graphics — 8 cases

    /// PD extended graphics state
    case pdExtGState = "PDExtGState"

    /// PD transparency group
    case pdGroup = "PDGroup"

    /// PD halftone dictionary
    case pdHalftone = "PDHalftone"

    /// PD XObject (generic)
    case pdXObject = "PDXObject"

    /// PD image XObject
    case pdXImage = "PDXImage"

    /// PD form XObject
    case pdXForm = "PDXForm"

    /// PD soft mask image
    case pdMaskImage = "PDMaskImage"

    /// PD 3D stream
    case pd3DStream = "PD3DStream"

    // MARK: - PD Layer -- Other — 7 cases

    /// PD media clip
    case pdMediaClip = "PDMediaClip"

    /// PD metadata stream
    case pdMetadata = "PDMetadata"

    /// PD optional content configuration
    case pdOCConfig = "PDOCConfig"

    /// PD signature reference
    case pdSigRef = "PDSigRef"

    /// PD digital signature
    case pdSignature = "PDSignature"

    /// Output intents
    case outputIntents = "OutputIntents"

    /// Embedded file
    case embeddedFile = "EmbeddedFile"

    // MARK: - Operators — 2 cases

    /// Undefined operator
    case opUndefined = "Op_Undefined"

    /// Graphics state save operator (q)
    case opQGsave = "Op_q_gsave"

    // MARK: - External Objects — 6 cases

    /// ICC color profile
    case iccProfile = "ICCProfile"

    /// ICC input profile
    case iccInputProfile = "ICCInputProfile"

    /// ICC output profile
    case iccOutputProfile = "ICCOutputProfile"

    /// JPEG 2000 image
    case jpeg2000 = "JPEG2000"

    /// TrueType font program
    case trueTypeFontProgram = "TrueTypeFontProgram"

    /// PKCS data object (digital signature)
    case pkcsDataObject = "PKCSDataObject"

    // MARK: - XMP Metadata — 9 cases

    /// XMP metadata package
    case xmpPackage = "XMPPackage"

    /// XMP property
    case xmpProperty = "XMPProperty"

    /// XMP language alternative
    case xmpLangAlt = "XMPLangAlt"

    /// XMP extension schema definition
    case extensionSchemaDefinition = "ExtensionSchemaDefinition"

    /// XMP extension schema field
    case extensionSchemaField = "ExtensionSchemaField"

    /// XMP extension schema object
    case extensionSchemaObject = "ExtensionSchemaObject"

    /// XMP extension schema property
    case extensionSchemaProperty = "ExtensionSchemaProperty"

    /// XMP extension schema value type
    case extensionSchemaValueType = "ExtensionSchemaValueType"

    /// XMP extension schemas container
    case extensionSchemasContainer = "ExtensionSchemasContainer"

    // MARK: - SE Layer -- Structure Elements (PDF/UA + PDF/A) — 54 cases

    /// Structure element: Annotation
    case seAnnot = "SEAnnot"

    /// Structure element: Art (article)
    case seArt = "SEArt"

    /// Structure element: Artifact
    case seArtifact = "SEArtifact"

    /// Structure element: Aside
    case seAside = "SEAside"

    /// Structure element: Bibliography entry
    case seBibEntry = "SEBibEntry"

    /// Structure element: Block quote
    case seBlockQuote = "SEBlockQuote"

    /// Structure element: Caption
    case seCaption = "SECaption"

    /// Structure element: Code
    case seCode = "SECode"

    /// Structure element: Division
    case seDiv = "SEDiv"

    /// Structure element: Document
    case seDocument = "SEDocument"

    /// Structure element: Document fragment
    case seDocumentFragment = "SEDocumentFragment"

    /// Structure element: Emphasis
    case seEm = "SEEm"

    /// Structure element: Footnote/Endnote
    case seFENote = "SEFENote"

    /// Structure element: Figure
    case seFigure = "SEFigure"

    /// Structure element: Form
    case seForm = "SEForm"

    /// Structure element: Formula
    case seFormula = "SEFormula"

    /// Structure element: Graphic content item
    case seGraphicContentItem = "SEGraphicContentItem"

    /// Structure element: Heading (generic)
    case seH = "SEH"

    /// Structure element: Heading level N (H1-H6)
    case seHn = "SEHn"

    /// Structure element: Index
    case seIndex = "SEIndex"

    /// Structure element: List
    case seL = "SEL"

    /// Structure element: List body
    case seLBody = "SELBody"

    /// Structure element: List item
    case seLI = "SELI"

    /// Structure element: Marked content
    case seMarkedContent = "SEMarkedContent"

    /// Structure element: MathML structure element (short form)
    case seMathMLStructElem = "SEMathMLStructElem"

    /// Structure element: MathML structure element (long form)
    case seMathMLStructureElement = "SEMathMLStructureElement"

    /// Structure element: Non-standard
    case seNonStandard = "SENonStandard"

    /// Structure element: Note
    case seNote = "SENote"

    /// Structure element: Part
    case sePart = "SEPart"

    /// Structure element: Inline quotation
    case seQuote = "SEQuote"

    /// Structure element: Ruby base text
    case seRB = "SERB"

    /// Structure element: Ruby punctuation
    case seRP = "SERP"

    /// Structure element: Ruby annotation text
    case seRT = "SERT"

    /// Structure element: Ruby annotation
    case seRuby = "SERuby"

    /// Structure element: Section
    case seSect = "SESect"

    /// Structure element: Simple content item
    case seSimpleContentItem = "SESimpleContentItem"

    /// Structure element: Span
    case seSpan = "SESpan"

    /// Structure element: Strong emphasis
    case seStrong = "SEStrong"

    /// Structure element: Subscript
    case seSub = "SESub"

    /// Structure element: Table body
    case seTBody = "SETBody"

    /// Structure element: Table data cell
    case seTD = "SETD"

    /// Structure element: Table footer
    case seTFoot = "SETFoot"

    /// Structure element: Table header cell
    case seTH = "SETH"

    /// Structure element: Table head
    case seTHead = "SETHead"

    /// Structure element: Table of contents
    case seTOC = "SETOC"

    /// Structure element: Table of contents item
    case seTOCI = "SETOCI"

    /// Structure element: Table row
    case seTR = "SETR"

    /// Structure element: Table
    case seTable = "SETable"

    /// Structure element: Table cell (generic)
    case seTableCell = "SETableCell"

    /// Structure element: Text item
    case seTextItem = "SETextItem"

    /// Structure element: Title
    case seTitle = "SETitle"

    /// Structure element: Warichu punctuation
    case seWP = "SEWP"

    /// Structure element: Warichu text
    case seWT = "SEWT"

    /// Structure element: Warichu annotation
    case seWarichu = "SEWarichu"

    // MARK: - SA Layer -- Semantic Accessibility (WCAG validation) — 26 cases

    /// Semantic accessibility: Caption
    case saCaption = "SACaption"

    /// Semantic accessibility: Figure
    case saFigure = "SAFigure"

    /// Semantic accessibility: Heading (generic)
    case saH = "SAH"

    /// Semantic accessibility: Heading level N
    case saHn = "SAHn"

    /// Semantic accessibility: List
    case saL = "SAL"

    /// Semantic accessibility: List body
    case saLBody = "SALBody"

    /// Semantic accessibility: List item
    case saLI = "SALI"

    /// Semantic accessibility: Label
    case saLbl = "SALbl"

    /// Semantic accessibility: Line art chunk
    case saLineArtChunk = "SALineArtChunk"

    /// Semantic accessibility: Link annotation
    case saLinkAnnotation = "SALinkAnnotation"

    /// Semantic accessibility: List item (semantic)
    case saListItem = "SAListItem"

    /// Semantic accessibility: Paragraph
    case saP = "SAP"

    /// Semantic accessibility: Repeated characters
    case saRepeatedCharacters = "SARepeatedCharacters"

    /// Semantic accessibility: Span
    case saSpan = "SASpan"

    /// Semantic accessibility: Structure element
    case saStructElem = "SAStructElem"

    /// Semantic accessibility: Table body
    case saTBody = "SATBody"

    /// Semantic accessibility: Table data cell
    case saTD = "SATD"

    /// Semantic accessibility: Table footer
    case saTFoot = "SATFoot"

    /// Semantic accessibility: Table header cell
    case saTH = "SATH"

    /// Semantic accessibility: Table head
    case saTHead = "SATHead"

    /// Semantic accessibility: Table of contents
    case saTOC = "SATOC"

    /// Semantic accessibility: Table of contents item
    case saTOCI = "SATOCI"

    /// Semantic accessibility: Table row
    case saTR = "SATR"

    /// Semantic accessibility: Table
    case saTable = "SATable"

    /// Semantic accessibility: Table cell (generic)
    case saTableCell = "SATableCell"

    /// Semantic accessibility: Text chunk
    case saTextChunk = "SATextChunk"
}

// MARK: - PDFObjectType Layer Classification

extension PDFObjectType {

    /// The architectural layer this object type belongs to.
    public enum Layer: String, Sendable, CaseIterable {
        /// COS (Carousel Object System) layer -- low-level PDF objects
        case cos = "COS"
        /// PD (Page Description) layer -- logical document objects
        case pd = "PD"
        /// SE (Structure Element) layer -- tagged PDF structure
        case se = "SE"
        /// SA (Semantic Accessibility) layer -- WCAG validation objects
        case sa = "SA"
        /// XMP Metadata layer
        case xmp = "XMP"
        /// External objects (ICC profiles, font programs, etc.)
        case external = "External"
        /// Content stream operators
        case operators = "Operators"
    }

    /// The architectural layer this object type belongs to.
    public var layer: Layer {
        switch self {
        // COS Layer
        case .cosArray, .cosBBox, .cosBM, .cosDict, .cosDocument,
             .cosFileSpecification, .cosFilter, .cosIIFilter, .cosIndirect,
             .cosInfo, .cosInteger, .cosName, .cosReal, .cosRenderingIntent,
             .cosStream, .cosString, .cosTrailer, .cosUnicodeName, .cosXRef,
             .cosActualText, .cosAlt, .cosLang, .cosTextString:
            return .cos

        // PD Layer
        case .pdDocument, .pdPage, .pdContentStream, .pdEncryption, .pdPerms, .pdOutline,
             .pdfaIdentification, .pdfuaIdentification, .pdUAIdentification, .mainXMPPackage,
             .pdStructTreeRoot, .pdStructElem,
             .pdAnnot, .pd3DAnnot, .pdFileAttachmentAnnot, .pdInkAnnot, .pdLinkAnnot,
             .pdMarkupAnnot, .pdMovieAnnot, .pdPopupAnnot, .pdPrinterMarkAnnot,
             .pdRichMediaAnnot, .pdRubberStampAnnot, .pdScreenAnnot, .pdSoundAnnot,
             .pdTrapNetAnnot, .pdWatermarkAnnot, .pdWidgetAnnot,
             .pdAcroForm, .pdFormField, .pdTextField,
             .pdAction, .pdAdditionalActions, .pdDestination, .pdGoToAction, .pdNamedAction,
             .pdFont, .pdSimpleFont, .pdType0Font, .pdType1Font, .pdTrueTypeFont,
             .pdCIDFont, .pdCMap, .pdReferencedCMap, .cMapFile, .glyph,
             .pdDeviceGray, .pdDeviceRGB, .pdDeviceCMYK, .pdDeviceN,
             .pdICCBasedCMYK, .pdSeparation, .transparencyColorSpace,
             .pdExtGState, .pdGroup, .pdHalftone, .pdXObject, .pdXImage, .pdXForm,
             .pdMaskImage, .pd3DStream,
             .pdMediaClip, .pdMetadata, .pdOCConfig, .pdSigRef, .pdSignature,
             .outputIntents, .embeddedFile:
            return .pd

        // SE Layer
        case .seAnnot, .seArt, .seArtifact, .seAside, .seBibEntry, .seBlockQuote,
             .seCaption, .seCode, .seDiv, .seDocument, .seDocumentFragment, .seEm,
             .seFENote, .seFigure, .seForm, .seFormula, .seGraphicContentItem,
             .seH, .seHn, .seIndex, .seL, .seLBody, .seLI,
             .seMarkedContent, .seMathMLStructElem, .seMathMLStructureElement,
             .seNonStandard, .seNote, .sePart, .seQuote,
             .seRB, .seRP, .seRT, .seRuby, .seSect,
             .seSimpleContentItem, .seSpan, .seStrong, .seSub,
             .seTBody, .seTD, .seTFoot, .seTH, .seTHead,
             .seTOC, .seTOCI, .seTR, .seTable, .seTableCell,
             .seTextItem, .seTitle, .seWP, .seWT, .seWarichu:
            return .se

        // SA Layer
        case .saCaption, .saFigure, .saH, .saHn, .saL, .saLBody, .saLI, .saLbl,
             .saLineArtChunk, .saLinkAnnotation, .saListItem, .saP,
             .saRepeatedCharacters, .saSpan, .saStructElem,
             .saTBody, .saTD, .saTFoot, .saTH, .saTHead,
             .saTOC, .saTOCI, .saTR, .saTable, .saTableCell, .saTextChunk:
            return .sa

        // XMP Metadata
        case .xmpPackage, .xmpProperty, .xmpLangAlt,
             .extensionSchemaDefinition, .extensionSchemaField,
             .extensionSchemaObject, .extensionSchemaProperty,
             .extensionSchemaValueType, .extensionSchemasContainer:
            return .xmp

        // External Objects
        case .iccProfile, .iccInputProfile, .iccOutputProfile,
             .jpeg2000, .trueTypeFontProgram, .pkcsDataObject:
            return .external

        // Operators
        case .opUndefined, .opQGsave:
            return .operators
        }
    }
}
