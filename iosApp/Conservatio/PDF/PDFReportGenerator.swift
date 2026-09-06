import UIKit

/// A photo that belongs to a report, paired with the stable image id the
/// annotations reference. The id is what links a `DamageAnnotation.imageId`
/// to the picture it was placed on, so markers land on the correct photo.
struct ReportPhoto {
    let id: String
    let image: UIImage
}

final class PDFReportGenerator {

    // MARK: - Configuration

    private var pageWidth: CGFloat = 595.0  // A4 default, overridden per export
    private var pageHeight: CGFloat = 842.0
    private let margin: CGFloat = 40.0
    private let primaryColor = UIColor(red: 0.76, green: 0.36, blue: 0.23, alpha: 1.0) // Terracotta
    private let textColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
    private let secondaryTextColor = UIColor(red: 0.29, green: 0.27, blue: 0.31, alpha: 1.0)
    private let lineColor = UIColor(red: 0.85, green: 0.82, blue: 0.80, alpha: 1.0)

    private var contentWidth: CGFloat { pageWidth - margin * 2 }

    /// Set for the duration of a single `generateReport` call.
    private var l = ReportL10n(.english)
    private var options = PDFExportOptions.default
    private var pageNumber = 0
    /// X position where OBJECT info values start, sized per report to the
    /// widest label (matters most for long bilingual labels).
    private var infoValueX: CGFloat = 130

    // MARK: - Public

    /// Generates the report PDF.
    ///
    /// - Parameters:
    ///   - photos: The report's photos, in order, each paired with the id its
    ///     annotations reference. Markers are drawn on the matching photo.
    ///   - options: Export options (language, paper size, content toggles),
    ///     normally taken from Settings via `PDFExportOptions.fromUserDefaults()`.
    func generateReport(
        object: ConservationObject,
        report: ConditionReport,
        photos: [ReportPhoto],
        conservatorName: String,
        options: PDFExportOptions = .fromUserDefaults()
    ) -> Data {
        self.options = options
        self.l = ReportL10n(options.language)
        self.pageNumber = 0
        let size = options.paperSize.pointSize
        self.pageWidth = size.width
        self.pageHeight = size.height

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        return renderer.pdfData { context in
            beginPage(context)
            var y = margin

            let reportIdShort = report.id.uuidString.prefix(8).uppercased()

            // Header
            y = drawHeader(
                y: y,
                reportId: "CR-\(reportIdShort)",
                date: report.examinationDate,
                conservator: conservatorName
            )

            // Title
            y = drawTitle(y: y)

            // Cover photo (identification). Never annotated; the annotated
            // copies live in the photo documentation section below.
            if options.includePhotos, let cover = photos.first {
                y = drawObjectPhoto(y: y, image: cover.image)
            }

            // Object info
            y = drawSectionHeader(y: y, title: l.objectSection)
            // Size the value column to the widest label so bilingual labels do
            // not overlap their values.
            let infoLabels = [
                l.titleLabel, l.typeLabel, l.materialsLabel, l.dimensionsLabel,
                l.locationLabel, l.ownerLabel, l.inventoryLabel,
            ]
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            ]
            let widest = infoLabels.reduce(CGFloat(0)) { max($0, ($1 as NSString).size(withAttributes: labelAttrs).width) }
            infoValueX = margin + 4 + min(widest + 12, contentWidth * 0.55)
            y = drawInfoRow(y: y, label: l.titleLabel, value: object.title)
            y = drawInfoRow(y: y, label: l.typeLabel, value: l.objectType(object.objectType))
            if !object.materials.isEmpty {
                y = drawInfoRow(y: y, label: l.materialsLabel, value: object.materials.joined(separator: ", "))
            }
            if let dims = object.dimensions {
                let formatted = formatDimensions(dims)
                if !formatted.isEmpty {
                    y = drawInfoRow(y: y, label: l.dimensionsLabel, value: formatted)
                }
            }
            if let location = object.locationDescription, !location.isEmpty {
                y = drawInfoRow(y: y, label: l.locationLabel, value: location)
            }
            if let owner = object.ownerName, !owner.isEmpty {
                y = drawInfoRow(y: y, label: l.ownerLabel, value: owner)
            }
            if let inventory = object.inventoryNumber, !inventory.isEmpty {
                y = drawInfoRow(y: y, label: l.inventoryLabel, value: inventory)
            }
            y += 12

            y = ensureSpace(context, y: y, needed: 120)

            // Condition summary
            y = drawSectionHeader(y: y, title: l.conditionSummarySection)
            y = drawBulletPoint(y: y, text: "\(l.overallConditionLabel): \(l.conditionRating(report.overallCondition))")
            y = drawBulletPoint(y: y, text: "\(l.reportTypeLabel): \(l.reportType(report.reportType))")
            for damage in report.damageAnnotations {
                y = drawBulletPoint(
                    y: y,
                    text: "\(l.damageType(damage.damageType)) - \(l.severity(damage.severity))"
                )
                if let desc = damage.description, !desc.isEmpty {
                    y = drawIndentedText(y: y, text: desc)
                }
                y = ensureSpace(context, y: y, needed: 60)
            }
            if report.damageAnnotations.isEmpty {
                y = drawBulletPoint(y: y, text: l.noDamageRecorded)
            }
            y += 12

            // Photo documentation with damage markers and per-photo legend.
            if options.includePhotos, options.includeAnnotations {
                y = drawPhotoDocumentation(context, y: y, photos: photos, report: report)
            }

            y = ensureSpace(context, y: y, needed: 120)

            // Recommended treatment (user text, printed verbatim).
            if let recommendations = report.recommendations, !recommendations.isEmpty {
                y = drawSectionHeader(y: y, title: l.recommendedTreatmentSection)
                let steps = recommendations.components(separatedBy: "\n").filter { !$0.isEmpty }
                if steps.count > 1 {
                    for (index, step) in steps.enumerated() {
                        y = drawNumberedItem(y: y, number: index + 1, text: step)
                        y = ensureSpace(context, y: y, needed: 60)
                    }
                } else {
                    y = drawBodyText(y: y, text: recommendations)
                }
                y += 12
            }

            y = ensureSpace(context, y: y, needed: 120)

            // Notes (user text, printed verbatim).
            if let notes = report.notes, !notes.isEmpty {
                y = drawSectionHeader(y: y, title: l.notesSection)
                y = drawBodyText(y: y, text: notes)
                y += 12
            }

            // Condition rating gauge
            if options.includeConditionGauge {
                y = ensureSpace(context, y: y, needed: 80)
                y = drawConditionRating(y: y, rating: report.overallCondition)
            }
        }
    }

    // MARK: - Page management

    private func beginPage(_ context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        pageNumber += 1
        drawFooterChrome()
    }

    /// Ensures at least `needed` points remain before the footer; starts a new
    /// page otherwise. Returns the y to keep drawing at.
    private func ensureSpace(_ context: UIGraphicsPDFRendererContext, y: CGFloat, needed: CGFloat) -> CGFloat {
        if y > pageHeight - margin - 40 - needed {
            beginPage(context)
            return margin
        }
        return y
    }

    // MARK: - Photo documentation

    private func drawPhotoDocumentation(
        _ context: UIGraphicsPDFRendererContext,
        y: CGFloat,
        photos: [ReportPhoto],
        report: ConditionReport
    ) -> CGFloat {
        // Only photos that actually carry positioned markers are documented,
        // so the section stays focused on damage evidence.
        let documented = photos.filter { photo in
            report.damageAnnotations.contains { positioned($0, imageId: photo.id) }
        }
        guard !documented.isEmpty else { return y }

        var currentY = ensureSpace(context, y: y, needed: 260)
        currentY = drawSectionHeader(y: currentY, title: l.photoDocumentationSection)

        for (photoIndex, photo) in documented.enumerated() {
            let markers = report.damageAnnotations
                .filter { positioned($0, imageId: photo.id) }

            // Keep a photo and at least its first legend row together.
            currentY = ensureSpace(context, y: currentY, needed: 300)

            // Photo caption
            let caption = "\(l.photoLabel) \(photoIndex + 1)"
            (caption as NSString).draw(
                at: CGPoint(x: margin + 4, y: currentY),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                    .foregroundColor: textColor,
                ]
            )
            currentY += 16

            currentY = drawAnnotatedPhoto(y: currentY, photo: photo, markers: markers)

            // Legend for this photo
            currentY += 4
            (l.legendHeading as NSString).draw(
                at: CGPoint(x: margin + 4, y: currentY),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 8, weight: .semibold),
                    .foregroundColor: secondaryTextColor,
                ]
            )
            currentY += 14

            for (index, marker) in markers.enumerated() {
                currentY = ensureSpace(context, y: currentY, needed: 40)
                currentY = drawLegendRow(y: currentY, number: index + 1, annotation: marker)
            }
            currentY += 12
        }

        return currentY
    }

    /// Draws a photo aspect-fitted into the content area and overlays a
    /// numbered marker for each annotation. Markers are positioned from the
    /// annotation's stored percentages, so they track the same spot regardless
    /// of the photo's pixel size, and the image is normalised to `.up` first so
    /// EXIF orientation cannot shift them.
    private func drawAnnotatedPhoto(y: CGFloat, photo: ReportPhoto, markers: [DamageAnnotation]) -> CGFloat {
        let image = Self.normalizedUp(photo.image)
        let maxPhotoHeight: CGFloat = 300
        let maxPhotoWidth = contentWidth
        let aspect = image.size.width / max(image.size.height, 1)
        var photoWidth = maxPhotoWidth
        var photoHeight = photoWidth / aspect
        if photoHeight > maxPhotoHeight {
            photoHeight = maxPhotoHeight
            photoWidth = photoHeight * aspect
        }

        let photoRect = CGRect(x: margin, y: y, width: photoWidth, height: photoHeight)

        UIColor(red: 0.9, green: 0.88, blue: 0.86, alpha: 1.0).setStroke()
        let border = UIBezierPath(rect: photoRect.insetBy(dx: -1, dy: -1))
        border.lineWidth = 0.5
        border.stroke()

        image.draw(in: photoRect)

        for (index, marker) in markers.enumerated() {
            guard let xPct = marker.xPercent, let yPct = marker.yPercent else { continue }

            // Optional bounding box for area annotations.
            if let wPct = marker.widthPercent, let hPct = marker.heightPercent, wPct > 0, hPct > 0 {
                let boxRect = Self.markerRect(
                    in: photoRect,
                    xPercent: xPct, yPercent: yPct,
                    widthPercent: wPct, heightPercent: hPct
                )
                colorForSeverity(marker.severity).setStroke()
                let box = UIBezierPath(rect: boxRect)
                box.lineWidth = 1.5
                box.stroke()
            }

            let center = Self.markerPoint(in: photoRect, xPercent: xPct, yPercent: yPct)
            drawMarker(number: index + 1, at: center, color: colorForSeverity(marker.severity))
        }

        return y + photoHeight + 8
    }

    private func drawMarker(number: Int, at center: CGPoint, color: UIColor) {
        let diameter: CGFloat = 20
        let rect = CGRect(
            x: center.x - diameter / 2,
            y: center.y - diameter / 2,
            width: diameter,
            height: diameter
        )

        // White halo so the marker stays legible on any photo.
        UIColor.white.setStroke()
        let halo = UIBezierPath(ovalIn: rect.insetBy(dx: -1.5, dy: -1.5))
        halo.lineWidth = 2
        halo.stroke()

        color.setFill()
        UIBezierPath(ovalIn: rect).fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.white,
        ]
        let text = "\(number)" as NSString
        let textSize = text.size(withAttributes: attrs)
        text.draw(
            at: CGPoint(x: center.x - textSize.width / 2, y: center.y - textSize.height / 2),
            withAttributes: attrs
        )
    }

    private func drawLegendRow(y: CGFloat, number: Int, annotation: DamageAnnotation) -> CGFloat {
        let color = colorForSeverity(annotation.severity)

        // Number swatch
        let diameter: CGFloat = 14
        let swatch = CGRect(x: margin + 6, y: y, width: diameter, height: diameter)
        color.setFill()
        UIBezierPath(ovalIn: swatch).fill()
        let numAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .bold),
            .foregroundColor: UIColor.white,
        ]
        let numText = "\(number)" as NSString
        let numSize = numText.size(withAttributes: numAttrs)
        numText.draw(
            at: CGPoint(x: swatch.midX - numSize.width / 2, y: swatch.midY - numSize.height / 2),
            withAttributes: numAttrs
        )

        // "Damage type - Severity" (localised vocabulary)
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: textColor,
        ]
        let title = "\(l.damageType(annotation.damageType)) - \(l.severity(annotation.severity))" as NSString
        let textX = margin + 6 + diameter + 8
        title.draw(at: CGPoint(x: textX, y: y), withAttributes: titleAttrs)
        var rowHeight = max(diameter, title.size(withAttributes: titleAttrs).height)

        // Description (user text, verbatim)
        if let desc = annotation.description, !desc.isEmpty {
            let descAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 8),
                .foregroundColor: secondaryTextColor,
            ]
            let descStr = desc as NSString
            let descRect = CGRect(x: textX, y: y + 12, width: contentWidth - (textX - margin), height: 120)
            let bounding = descStr.boundingRect(
                with: CGSize(width: descRect.width, height: 120),
                options: .usesLineFragmentOrigin,
                attributes: descAttrs,
                context: nil
            )
            descStr.draw(in: descRect, withAttributes: descAttrs)
            rowHeight = 12 + bounding.height
        }

        return y + rowHeight + 6
    }

    // MARK: - Marker geometry (pure, unit tested)

    /// Maps a stored percentage position to a point inside a drawn photo rect.
    static func markerPoint(in rect: CGRect, xPercent: Double, yPercent: Double) -> CGPoint {
        let clampedX = min(max(xPercent, 0), 100)
        let clampedY = min(max(yPercent, 0), 100)
        return CGPoint(
            x: rect.origin.x + CGFloat(clampedX / 100.0) * rect.width,
            y: rect.origin.y + CGFloat(clampedY / 100.0) * rect.height
        )
    }

    /// Maps a stored percentage bounding box (centre + size) to a rect inside a
    /// drawn photo rect.
    static func markerRect(
        in rect: CGRect,
        xPercent: Double, yPercent: Double,
        widthPercent: Double, heightPercent: Double
    ) -> CGRect {
        let center = markerPoint(in: rect, xPercent: xPercent, yPercent: yPercent)
        let w = CGFloat(min(max(widthPercent, 0), 100) / 100.0) * rect.width
        let h = CGFloat(min(max(heightPercent, 0), 100) / 100.0) * rect.height
        return CGRect(x: center.x - w / 2, y: center.y - h / 2, width: w, height: h)
    }

    /// Redraws an image in `.up` orientation so EXIF orientation cannot move
    /// percentage-positioned markers. A no-op for images already `.up`.
    static func normalizedUp(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private func positioned(_ annotation: DamageAnnotation, imageId: String) -> Bool {
        annotation.imageId == imageId && annotation.xPercent != nil && annotation.yPercent != nil
    }

    // MARK: - Formatting

    private func formatDimensions(_ dims: Dimensions) -> String {
        var parts: [String] = []
        if let h = dims.height { parts.append("H: \(formatNumber(h))") }
        if let w = dims.width { parts.append("W: \(formatNumber(w))") }
        if let d = dims.depth { parts.append("D: \(formatNumber(d))") }
        if let dia = dims.diameter { parts.append("Dia: \(formatNumber(dia))") }
        var result = parts.joined(separator: " x ")
        if !result.isEmpty {
            result += " \(dims.unit.displayName)"
        }
        if let wt = dims.weight {
            let weightUnit = dims.unit == .kg || dims.unit == .g ? dims.unit.displayName : "kg"
            result += result.isEmpty ? "" : ", "
            result += "\(l.weightLabel): \(formatNumber(wt)) \(weightUnit)"
        }
        return result
    }

    private func formatNumber(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    // MARK: - Drawing Helpers

    private func drawHeader(
        y: CGFloat,
        reportId: String,
        date: Date,
        conservator: String
    ) -> CGFloat {
        var currentY = y

        let brandAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: primaryColor,
        ]
        ("Conservatio" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: brandAttrs)

        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .regular),
            .foregroundColor: secondaryTextColor,
        ]
        ("Intelligent Documentation.\nVerified Preservation." as NSString)
            .draw(at: CGPoint(x: margin, y: currentY + 28), withAttributes: subAttrs)

        // Right meta block. Label and value are stacked so long bilingual
        // labels never collide with their values, and the block is left
        // aligned in a column sized to its widest line.
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: textColor,
        ]
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8.5, weight: .semibold),
            .foregroundColor: primaryColor,
        ]

        let pairs: [(String, String)] = [
            (l.reportIdLabel, reportId),
            (l.dateLabel, l.date(date)),
            (l.conservatorLabel, conservator),
        ]

        let blockWidth = pairs.reduce(CGFloat(0)) { partial, pair in
            let lw = (pair.0 as NSString).size(withAttributes: labelAttrs).width
            let vw = (pair.1 as NSString).size(withAttributes: valueAttrs).width
            return max(partial, max(lw, vw))
        }
        let blockX = pageWidth - margin - min(blockWidth, contentWidth * 0.5)

        var metaY = currentY
        for (label, value) in pairs {
            (label as NSString).draw(at: CGPoint(x: blockX, y: metaY), withAttributes: labelAttrs)
            metaY += 11
            (value as NSString).draw(at: CGPoint(x: blockX, y: metaY), withAttributes: valueAttrs)
            metaY += 14
        }

        currentY = max(currentY + 48, metaY + 4)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: currentY))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        primaryColor.setStroke()
        path.lineWidth = 1.5
        path.stroke()

        return currentY + 12
    }

    private func drawTitle(y: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: textColor,
        ]
        let title = l.conditionReportTitle as NSString
        let titleSize = title.size(withAttributes: attrs)
        let x = (pageWidth - titleSize.width) / 2
        title.draw(at: CGPoint(x: x, y: y), withAttributes: attrs)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y + titleSize.height + 2))
        path.addLine(to: CGPoint(x: x + titleSize.width, y: y + titleSize.height + 2))
        lineColor.setStroke()
        path.lineWidth = 0.5
        path.stroke()

        return y + titleSize.height + 16
    }

    private func drawObjectPhoto(y: CGFloat, image: UIImage) -> CGFloat {
        let normalized = Self.normalizedUp(image)
        let maxPhotoHeight: CGFloat = 220
        let maxPhotoWidth = contentWidth * 0.55
        let aspect = normalized.size.width / max(normalized.size.height, 1)
        var photoWidth = maxPhotoWidth
        var photoHeight = photoWidth / aspect
        if photoHeight > maxPhotoHeight {
            photoHeight = maxPhotoHeight
            photoWidth = photoHeight * aspect
        }

        let photoRect = CGRect(x: margin, y: y, width: photoWidth, height: photoHeight)

        UIColor(red: 0.9, green: 0.88, blue: 0.86, alpha: 1.0).setStroke()
        let border = UIBezierPath(rect: photoRect.insetBy(dx: -1, dy: -1))
        border.lineWidth = 0.5
        border.stroke()

        normalized.draw(in: photoRect)

        return y + photoHeight + 16
    }

    private func drawSectionHeader(y: CGFloat, title: String) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: primaryColor,
        ]
        (title as NSString).draw(at: CGPoint(x: margin + 4, y: y), withAttributes: attrs)

        let lineY = y + 16
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: lineY))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: lineY))
        lineColor.setStroke()
        path.lineWidth = 0.5
        path.stroke()

        return lineY + 8
    }

    private func drawInfoRow(y: CGFloat, label: String, value: String) -> CGFloat {
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: textColor,
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: secondaryTextColor,
        ]
        (label as NSString).draw(at: CGPoint(x: margin + 4, y: y), withAttributes: labelAttrs)
        let valueRect = CGRect(x: infoValueX, y: y, width: pageWidth - margin - infoValueX, height: 200)
        let valueStr = value as NSString
        let boundingRect = valueStr.boundingRect(
            with: CGSize(width: valueRect.width, height: 200),
            options: .usesLineFragmentOrigin,
            attributes: valueAttrs,
            context: nil
        )
        valueStr.draw(in: valueRect, withAttributes: valueAttrs)
        return y + max(14, boundingRect.height + 4)
    }

    private func drawBulletPoint(y: CGFloat, text: String) -> CGFloat {
        let bulletAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: textColor,
        ]
        let bullet = "\u{2022} \(text)" as NSString
        let rect = CGRect(x: margin + 8, y: y, width: contentWidth - 12, height: 200)
        let boundingRect = bullet.boundingRect(
            with: CGSize(width: rect.width, height: 200),
            options: .usesLineFragmentOrigin,
            attributes: bulletAttrs,
            context: nil
        )
        bullet.draw(in: rect, withAttributes: bulletAttrs)
        return y + boundingRect.height + 4
    }

    private func drawIndentedText(y: CGFloat, text: String) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 8),
            .foregroundColor: secondaryTextColor,
        ]
        let str = text as NSString
        let rect = CGRect(x: margin + 20, y: y, width: contentWidth - 24, height: 200)
        let boundingRect = str.boundingRect(
            with: CGSize(width: rect.width, height: 200),
            options: .usesLineFragmentOrigin,
            attributes: attrs,
            context: nil
        )
        str.draw(in: rect, withAttributes: attrs)
        return y + boundingRect.height + 2
    }

    private func drawNumberedItem(y: CGFloat, number: Int, text: String) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: textColor,
        ]
        let str = "\(number). \(text)" as NSString
        let rect = CGRect(x: margin + 8, y: y, width: contentWidth - 12, height: 200)
        let boundingRect = str.boundingRect(
            with: CGSize(width: rect.width, height: 200),
            options: .usesLineFragmentOrigin,
            attributes: attrs,
            context: nil
        )
        str.draw(in: rect, withAttributes: attrs)
        return y + boundingRect.height + 4
    }

    private func drawBodyText(y: CGFloat, text: String) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: secondaryTextColor,
        ]
        let str = text as NSString
        let rect = CGRect(x: margin + 4, y: y, width: contentWidth - 8, height: 400)
        let boundingRect = str.boundingRect(
            with: CGSize(width: rect.width, height: 400),
            options: .usesLineFragmentOrigin,
            attributes: attrs,
            context: nil
        )
        str.draw(in: rect, withAttributes: attrs)
        return y + boundingRect.height + 4
    }

    private func drawConditionRating(y: CGFloat, rating: ConditionRating) -> CGFloat {
        var currentY = y
        currentY = drawSectionHeader(y: currentY, title: l.conditionRatingSection)

        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 8
        let barX = margin + 4

        let colors: [UIColor] = [
            UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1.0),
            UIColor(red: 0.33, green: 0.55, blue: 0.18, alpha: 1.0),
            UIColor(red: 0.98, green: 0.66, blue: 0.15, alpha: 1.0),
            UIColor(red: 0.94, green: 0.42, blue: 0.0, alpha: 1.0),
            UIColor(red: 0.78, green: 0.16, blue: 0.16, alpha: 1.0),
        ]

        let segmentWidth = barWidth / CGFloat(colors.count)
        for (i, color) in colors.enumerated() {
            let segmentRect = CGRect(
                x: barX + segmentWidth * CGFloat(i),
                y: currentY,
                width: segmentWidth,
                height: barHeight
            )
            color.setFill()
            let cornerRadius: CGFloat = (i == 0 || i == colors.count - 1) ? 4 : 0
            UIBezierPath(roundedRect: segmentRect, cornerRadius: cornerRadius).fill()
        }

        let ratingColor = uiColorForRating(rating)
        let ratingAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: ratingColor,
        ]
        (l.conditionRating(rating) as NSString).draw(
            at: CGPoint(x: barX + barWidth + 12, y: currentY - 2),
            withAttributes: ratingAttrs
        )

        return currentY + barHeight + 20
    }

    private func uiColorForRating(_ rating: ConditionRating) -> UIColor {
        switch rating {
        case .excellent: return UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1.0)
        case .good: return UIColor(red: 0.33, green: 0.55, blue: 0.18, alpha: 1.0)
        case .fair: return UIColor(red: 0.98, green: 0.66, blue: 0.15, alpha: 1.0)
        case .poor: return UIColor(red: 0.94, green: 0.42, blue: 0.0, alpha: 1.0)
        case .critical: return UIColor(red: 0.78, green: 0.16, blue: 0.16, alpha: 1.0)
        }
    }

    private func colorForSeverity(_ severity: DamageSeverity) -> UIColor {
        switch severity {
        case .minor: return UIColor(red: 0.33, green: 0.55, blue: 0.18, alpha: 1.0)
        case .moderate: return UIColor(red: 0.98, green: 0.66, blue: 0.15, alpha: 1.0)
        case .severe: return UIColor(red: 0.94, green: 0.42, blue: 0.0, alpha: 1.0)
        case .critical: return UIColor(red: 0.78, green: 0.16, blue: 0.16, alpha: 1.0)
        }
    }

    /// Footer chrome drawn on every page: divider, brand line, and page number.
    private func drawFooterChrome() {
        let footerY = pageHeight - margin - 20

        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: footerY))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: footerY))
        lineColor.setStroke()
        path.lineWidth = 0.5
        path.stroke()

        let pageAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7, weight: .regular),
            .foregroundColor: secondaryTextColor,
        ]
        (l.generatedByConservatio as NSString).draw(
            at: CGPoint(x: margin, y: footerY + 8),
            withAttributes: pageAttrs
        )

        // The total page count is unknown while streaming pages, so the footer
        // shows the current page number only.
        let pageLabel = l.pick(en: "Page", el: "Σελίδα")
        let currentPage = "\(pageLabel) \(pageNumber)" as NSString
        let size = currentPage.size(withAttributes: pageAttrs)
        currentPage.draw(
            at: CGPoint(x: pageWidth - margin - size.width, y: footerY + 8),
            withAttributes: pageAttrs
        )
    }
}
