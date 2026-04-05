// Utilities/Extensions.swift
// WhatsappScheduler

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    var isInFuture: Bool { self > Date() }

    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = style
        return formatter.string(from: self)
    }

    var shortDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - String Extensions

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    func snippet(maxLength: Int = 60) -> String {
        guard count > maxLength else { return self }
        return String(prefix(maxLength)) + "…"
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.secondarySystemBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .font(.headline)
    }

    func secondaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .font(.headline)
    }
}

// MARK: - Color Extensions

extension Color {
    static let whatsAppGreen  = Color(red: 37/255, green: 211/255, blue: 102/255)
    static let whatsAppTeal   = Color(red: 0/255,  green: 168/255, blue: 132/255)
    static let whatsAppDark   = Color(red: 18/255, green: 140/255, blue: 126/255)
}
