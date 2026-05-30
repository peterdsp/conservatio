# Design System

## Design Philosophy

Conservatio's design language communicates professionalism, trust, and respect for cultural heritage. The visual style should make conservators look more professional without adding friction to their workflow.

**Principles:**
1. **Professional, not corporate.** Warm and approachable, not cold enterprise software.
2. **Content-first.** Photos and documentation are the primary content. UI should frame, not compete.
3. **Offline-ready.** Visual states for synced, pending, and conflict. Users should always know their data status.
4. **Accessible.** High contrast, clear typography, touch-friendly targets.

## Color Palette

### Primary: Terracotta
Evokes heritage, craftsmanship, and the materials conservators work with.
- Light: `#E8967A`
- Default: `#C25B3A`
- Dark: `#8B3D24`

### Secondary: Stone Blue
Professional and trustworthy. Used for secondary actions and informational elements.
- Light: `#6999B8`
- Default: `#3A6B8C`
- Dark: `#1E4460`

### Tertiary: Warm Gold
Accent for highlights, badges, and calls to attention.
- Light: `#EEC96E`
- Default: `#D4A843`
- Dark: `#9B7A2E`

### Neutrals
- Background: `#FAF7F4` (warm off-white)
- Surface: `#FFFFFF`
- Surface Variant: `#F2EEEA`
- Text: `#1C1B1F`
- Text Secondary: `#49454F`
- Outline: `#79747E`

### Condition Ratings
- Excellent: `#2E7D32` (green)
- Good: `#558B2F` (light green)
- Fair: `#F9A825` (amber)
- Poor: `#EF6C00` (orange)
- Critical: `#C62828` (red)

## Typography

### Mobile
- **Android:** Material 3 type scale with Inter (sans) and Merriweather (serif for report headers)
- **iOS:** SF Pro (system) with matching size scale

### Web
- **Sans:** Inter (UI, labels, body)
- **Serif:** Merriweather (report headers, object titles in detail views)

### Scale
| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| Headline Large | 32 | Bold | Page titles |
| Headline Medium | 28 | Bold | Section headers |
| Headline Small | 24 | SemiBold | Card titles |
| Title Large | 22 | SemiBold | List headers |
| Title Medium | 16 | SemiBold | Subsection headers |
| Title Small | 14 | SemiBold | Labels with emphasis |
| Body Large | 16 | Regular | Primary body text |
| Body Medium | 14 | Regular | Secondary body text |
| Body Small | 12 | Regular | Captions, metadata |
| Label Large | 14 | Medium | Button text |
| Label Medium | 12 | Medium | Chip text, tags |
| Label Small | 11 | Medium | Timestamps, badges |

## Spacing

| Token | Value | Usage |
|-------|-------|-------|
| XS | 4px | Inline icon gaps |
| SM | 8px | Tight grouping |
| MD | 16px | Standard padding |
| LG | 24px | Section spacing |
| XL | 32px | Major sections |
| XXL | 48px | Page-level spacing |

## Components

### Condition Badge
Rounded pill showing condition rating with color-coded background.
```
[Excellent] [Good] [Fair] [Poor] [Critical]
  green      lime   amber  orange   red
```

### Object Card
Card with:
- Thumbnail image (square, rounded corners)
- Object title (Title Medium)
- Object type badge (Label Small)
- Condition indicator dot
- Last updated timestamp

### Report Card
Card with:
- Report type label
- Condition rating badge
- Examiner name
- Date
- Image count indicator

### Damage Annotation Marker
Circular or rectangular overlay on images:
- Border color matches DamageSeverity
- Tap/click to expand damage details
- Drag to reposition
- Resize handles on corners

## Figma References

Design inspiration from Figma Community:
- Material 3 Design Kit But Better (component foundations)
- DashStack / Dashboard UI Kit by ByeWind (web dashboard patterns)
- SaaS Dashboard CRM UI Kit (web layout patterns)

## Platform Adaptations

### Android
- Material 3 components (M3 Buttons, Cards, NavigationBar, TopAppBar)
- Dynamic Color (Material You) as optional setting
- Bottom navigation with 5 tabs
- FAB for primary action (new report, new object)

### iOS
- Native SwiftUI components (TabView, NavigationStack, List, Form)
- SF Symbols for icons
- Sheet presentations for creation flows
- Pull-to-refresh for sync

### Web
- Custom Tailwind components matching the design tokens
- Collapsible sidebar navigation
- Data tables for object/project listings
- Modal dialogs for quick creation
