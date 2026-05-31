# Conservatio iOS App

Native iOS app built with SwiftUI.

## Quick Start

### Option A: XcodeGen (recommended)

1. Install XcodeGen: `brew install xcodegen`
2. Run from this directory: `xcodegen generate`
3. Open `Conservatio.xcodeproj`
4. Set your Development Team in Signing settings
5. Build and run (Cmd+R)

### Option B: Manual Xcode Project

1. Open Xcode > File > New > Project > iOS App (SwiftUI)
2. Name it "Conservatio", set bundle ID to `dev.peterdsp.conservatio`
3. Delete the generated files and drag in the `Conservatio/` folder
4. Set iOS deployment target to 17.0
5. Add camera and photo library usage descriptions in Info.plist
6. Build and run

## Architecture

- SwiftUI views with observable stores (no external dependencies)
- JSON file persistence for MVP (will migrate to KMP shared SQLDelight)
- Native camera via UIImagePickerController
- PDF generation via UIGraphicsPDFRenderer (works offline)
- Photo picker via PhotosUI PhotosPicker

## Key Files

| File | Purpose |
|------|---------|
| `ConservatioApp.swift` | App entry point |
| `ContentView.swift` | Tab navigation |
| `Models/ConservationObject.swift` | Object domain model |
| `Models/ConditionReport.swift` | Report domain model with damage types |
| `Storage/ObjectStore.swift` | JSON persistence for objects |
| `Storage/ReportStore.swift` | JSON persistence for reports |
| `Storage/ImageStore.swift` | JPEG image file storage |
| `Views/Objects/CreateObjectView.swift` | Object creation form |
| `Views/Objects/ObjectDetailView.swift` | Object detail with photos |
| `Views/Reports/CreateReportView.swift` | Condition report form |
| `PDF/PDFReportGenerator.swift` | Professional PDF export |
| `PDF/PDFPreviewView.swift` | PDF preview and share |
| `Theme/ConservatioColors.swift` | Heritage color palette |
| `Theme/ConservatioTypography.swift` | Type scale |

## Design

Follows Apple Human Interface Guidelines with a custom heritage color palette:
- Primary: Terracotta `#C25B3A`
- Secondary: Stone Blue `#3A6B8C`
- Tertiary: Warm Gold `#D4A843`
