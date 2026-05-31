import UIKit

struct PDFReportGenerator {

    // MARK: - Configuration

    private let pageWidth: CGFloat = 595.0  // A4
    private let pageHeight: CGFloat = 842.0 // A4
    private let margin: CGFloat = 40.0
    private let primaryColor = UIColor(red: 0.76, green: 0.36, blue: 0.23, alpha: 1.0) // Terracotta
    private let textColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
    private let secondaryTextColor = UIColor(red: 0.29, green: 0.27, blue: 0.31, alpha: 1.0)
    private let lineColor = UIColor(red: 0.85, green: 0.82, blue: 0.80, alpha: 1.0)

    private var contentWidth: CGFloat { pageWidth - margin * 2 }

    // MARK: - Public

    func generateReport(
        object: ConservationObject,
        report: ConditionReport,
        objectImages: [UIImage],
        conservatorName: String
    ) -> Data {
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        return renderer.pdfData { context in
            context.beginPage()
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

            // Object photo
            if let firstImage = objectImages.first {
                y = drawObjectPhoto(y: y, image: firstImage)
            }

            // Object info
            y = drawSectionHeader(y: y, title: "OBJECT")
            y = drawInfoRow(y: y, label: "Title:", value: object.title)
            y = drawInfoRow(y: y, label: "Type:", value: object.objectType.displayName)
            y = drawInfoRow(y: y, label: "Materials:", value: object.materials.joined(separator: ", "))
            if let dims = object.dimensions {
                y = drawInfoRow(y: y, label: "Dimensions:", value: formatDimensions(dims))
            }
            if let location = object.locationDescription, !location.isEmpty {
                y = drawInfoRow(y: y, label: "Location:", value: location)
            }
            if let owner = object.ownerName, !owner.isEmpty {
                y = drawInfoRow(y: y, label: "Owner:", value: owner)
            }
            if let inventory = object.inventoryNumber, !inventory.isEmpty {
                y = drawInfoRow(y: y, label: "Inventory:", value: inventory)
            }
            y += 12

            // Check if we need a new page
            if y > pageHeight - 250 {
                context.beginPage()
                y = margin
            }

            // Condition summary
            y = drawSectionHeader(y: y, title: "CONDITION SUMMARY")
            y = drawBulletPoint(y: y, text: "Overall condition: \(report.overallCondition.displayName)")
            y = drawBulletPoint(y: y, text: "Report type: \(report.reportType.displayName)")
            for damage in report.damageAnnotations {
                y = drawBulletPoint(
                    y: y,
                    text: "\(damage.damageType.displayName) - \(damage.severity.displayName)"
                )
                if let desc = damage.description, !desc.isEmpty {
                    y = drawIndentedText(y: y, text: desc)
                }
                // Check page mid-loop
                if y > pageHeight - 100 {
                    context.beginPage()
                    y = margin
                }
            }
            if report.damageAnnotations.isEmpty {
                y = drawBulletPoint(y: y, text: "No specific damage recorded.")
            }
            y += 12

            // Check page
            if y > pageHeight - 200 {
                context.beginPage()
                y = margin
            }

            // Recommended treatment
            if let recommendations = report.recommendations, !recommendations.isEmpty {
                y = drawSectionHeader(y: y, title: "RECOMMENDED TREATMENT")
                let steps = recommendations.components(separatedBy: "\n").filter { !$0.isEmpty }
                if steps.count > 1 {
                    for (index, step) in steps.enumerated() {
                        y = drawNumberedItem(y: y, number: index + 1, text: step)
                        if y > pageHeight - 100 {
                            context.beginPage()
                            y = margin
                        }
                    }
                } else {
                    y = drawBodyText(y: y, text: recommendations)
                }
                y += 12
            }

            // Check page
            if y > pageHeight - 200 {
                context.beginPage()
                y = margin
            }

            // Notes
            if let notes = report.notes, !notes.isEmpty {
                y = drawSectionHeader(y: y, title: "NOTES")
                y = drawBodyText(y: y, text: notes)
                y += 12
            }

            // Condition rating bar
            if y > pageHeight - 150 {
                context.beginPage()
                y = margin
            }
            y = drawConditionRating(y: y, rating: report.overallCondition)

            // Footer
            drawFooter(conservator: conservatorName)
        }
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
            result += "Weight: \(formatNumber(wt)) \(weightUnit)"
        }
        return result.isEmpty ? "Not specified" : result
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

        // Brand name
        let brandAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: primaryColor
        ]
        let brand = "Conservatio" as NSString
        brand.draw(at: CGPoint(x: margin, y: currentY), withAttributes: brandAttrs)

        // Subtitle
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .regular),
            .foregroundColor: secondaryTextColor
        ]
        let subtitle = "Intelligent Documentation.\nVerified Preservation." as NSString
        subtitle.draw(at: CGPoint(x: margin, y: currentY + 28), withAttributes: subAttrs)

        // Report info (right side)
        let infoAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: textColor
        ]
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: textColor
        ]

        let rightX = pageWidth - margin - 160

        ("Report ID:" as NSString).draw(
            at: CGPoint(x: rightX, y: currentY),
            withAttributes: labelAttrs
        )
        (reportId as NSString).draw(
            at: CGPoint(x: rightX + 70, y: currentY),
            withAttributes: infoAttrs
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateStr = dateFormatter.string(from: date)

        ("Date:" as NSString).draw(
            at: CGPoint(x: rightX, y: currentY + 14),
            withAttributes: labelAttrs
        )
        (dateStr as NSString).draw(
            at: CGPoint(x: rightX + 70, y: currentY + 14),
            withAttributes: infoAttrs
        )

        ("Conservator:" as NSString).draw(
            at: CGPoint(x: rightX, y: currentY + 28),
            withAttributes: labelAttrs
        )
        (conservator as NSString).draw(
            at: CGPoint(x: rightX + 70, y: currentY + 28),
            withAttributes: infoAttrs
        )

        currentY += 55

        // Divider line
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
            .foregroundColor: textColor
        ]
        let title = "CONDITION REPORT" as NSString
        let titleSize = title.size(withAttributes: attrs)
        let x = (pageWidth - titleSize.width) / 2
        title.draw(at: CGPoint(x: x, y: y), withAttributes: attrs)

        // Underline
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y + titleSize.height + 2))
        path.addLine(to: CGPoint(x: x + titleSize.width, y: y + titleSize.height + 2))
        lineColor.setStroke()
        path.lineWidth = 0.5
        path.stroke()

        return y + titleSize.height + 16
    }

    private func drawObjectPhoto(y: CGFloat, image: UIImage) -> CGFloat {
        let maxPhotoHeight: CGFloat = 220
        let maxPhotoWidth = contentWidth * 0.55
        let aspect = image.size.width / image.size.height
        var photoWidth = maxPhotoWidth
        var photoHeight = photoWidth / aspect
        if photoHeight > maxPhotoHeight {
            photoHeight = maxPhotoHeight
            photoWidth = photoHeight * aspect
        }

        let photoRect = CGRect(x: margin, y: y, width: photoWidth, height: photoHeight)

        // Border
        let borderRect = photoRect.insetBy(dx: -1, dy: -1)
        UIColor(red: 0.9, green: 0.88, blue: 0.86, alpha: 1.0).setStroke()
        let border = UIBezierPath(rect: borderRect)
        border.lineWidth = 0.5
        border.stroke()

        image.draw(in: photoRect)

        return y + photoHeight + 16
    }

    private func drawSectionHeader(y: CGFloat, title: String) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: primaryColor
        ]
        (title as NSString).draw(
            at: CGPoint(x: margin + 4, y: y),
            withAttributes: attrs
        )

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
            .foregroundColor: textColor
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: secondaryTextColor
        ]
        (label as NSString).draw(
            at: CGPoint(x: margin + 4, y: y),
            withAttributes: labelAttrs
        )
        let valueRect = CGRect(x: margin + 80, y: y, width: contentWidth - 84, height: 200)
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
            .foregroundColor: textColor
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
            .foregroundColor: secondaryTextColor
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
            .foregroundColor: textColor
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
            .foregroundColor: secondaryTextColor
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

        // Section header
        currentY = drawSectionHeader(y: currentY, title: "CONDITION RATING")

        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 8
        let barX = margin + 4

        // Background bar segments (green to red)
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

        // Rating label color
        let ratingColor = uiColorForRating(rating)
        let ratingAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: ratingColor
        ]
        let ratingText = rating.displayName as NSString
        ratingText.draw(
            at: CGPoint(x: barX + barWidth + 12, y: currentY - 2),
            withAttributes: ratingAttrs
        )

        return currentY + barHeight + 20
    }

    private func uiColorForRating(_ rating: ConditionRating) -> UIColor {
        switch rating {
        case .excellent:
            return UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1.0)
        case .good:
            return UIColor(red: 0.33, green: 0.55, blue: 0.18, alpha: 1.0)
        case .fair:
            return UIColor(red: 0.98, green: 0.66, blue: 0.15, alpha: 1.0)
        case .poor:
            return UIColor(red: 0.94, green: 0.42, blue: 0.0, alpha: 1.0)
        case .critical:
            return UIColor(red: 0.78, green: 0.16, blue: 0.16, alpha: 1.0)
        }
    }

    private func drawFooter(conservator: String) {
        let footerY = pageHeight - margin - 30

        // Divider
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: footerY))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: footerY))
        lineColor.setStroke()
        path.lineWidth = 0.5
        path.stroke()

        // Signature line
        let sigAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 9),
            .foregroundColor: secondaryTextColor
        ]
        let sig = conservator as NSString
        let sigSize = sig.size(withAttributes: sigAttrs)
        sig.draw(
            at: CGPoint(x: pageWidth - margin - sigSize.width, y: footerY + 8),
            withAttributes: sigAttrs
        )

        // Page info
        let pageAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7, weight: .regular),
            .foregroundColor: secondaryTextColor
        ]
        ("Generated by Conservatio" as NSString).draw(
            at: CGPoint(x: margin, y: footerY + 8),
            withAttributes: pageAttrs
        )
    }
}
