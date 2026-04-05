// DesignSystem/DesignTokens.swift
// WhatsappScheduler

import SwiftUI

/// Central design tokens for the WhatsApp Scheduler app.
enum DS {
    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs:  CGFloat = 8
        static let sm:  CGFloat = 12
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 14
        static let lg:  CGFloat = 20
        static let xl:  CGFloat = 28
        static let pill:CGFloat = 999
    }

    // MARK: - Font
    enum Font {
        static let largeTitle  = SwiftUI.Font.largeTitle.bold()
        static let title       = SwiftUI.Font.title2.bold()
        static let headline    = SwiftUI.Font.headline
        static let body        = SwiftUI.Font.body
        static let caption     = SwiftUI.Font.caption
        static let footnote    = SwiftUI.Font.footnote
    }

    // MARK: - Color
    enum Color {
        static let whatsAppGreen = SwiftUI.Color.whatsAppGreen
        static let accent        = SwiftUI.Color.accentColor
        static let background    = SwiftUI.Color(.systemBackground)
        static let secondaryBG   = SwiftUI.Color(.secondarySystemBackground)
        static let tertiaryBG    = SwiftUI.Color(.tertiarySystemBackground)
        static let label         = SwiftUI.Color(.label)
        static let secondaryLabel = SwiftUI.Color(.secondaryLabel)
        static let separator     = SwiftUI.Color(.separator)
    }
}

// MARK: - LiquidGlassBackground

/// A blurred glass-style background used in onboarding and paywall.
struct LiquidGlassBackground: View {
    var colors: [Color] = [.whatsAppGreen, Color(red: 0.1, green: 0.8, blue: 0.6)]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -80, y: -120)

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 100, y: 200)
        }
    }
}

// MARK: - WhatsAppButton

struct WhatsAppButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                Text(title)
                    .font(DS.Font.headline)
            }
            .primaryButtonStyle()
            .background(DS.Color.whatsAppGreen)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
        .disabled(isLoading)
    }
}

// MARK: - StatusBadge

struct StatusBadge: View {
    let status: ScheduleStatus

    var body: some View {
        Text(label)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var label: String {
        switch status {
        case .pending:   return NSLocalizedString("status_pending",   comment: "")
        case .sent:      return NSLocalizedString("status_sent",      comment: "")
        case .cancelled: return NSLocalizedString("status_cancelled", comment: "")
        case .failed:    return NSLocalizedString("status_failed",    comment: "")
        }
    }

    private var color: Color {
        switch status {
        case .pending:   return .orange
        case .sent:      return .green
        case .cancelled: return .gray
        case .failed:    return .red
        }
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(DS.Color.secondaryLabel)

            Text(title)
                .font(DS.Font.title)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.secondaryLabel)
                .multilineTextAlignment(.center)

            if let action, let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, DS.Spacing.sm)
            }
        }
        .padding(DS.Spacing.xl)
    }
}

// MARK: - Preview Helpers

#Preview("LiquidGlassBackground") {
    LiquidGlassBackground()
}

#Preview("WhatsAppButton") {
    WhatsAppButton(title: "Open WhatsApp") {}
        .padding()
}

#Preview("StatusBadge") {
    HStack {
        StatusBadge(status: .pending)
        StatusBadge(status: .sent)
        StatusBadge(status: .cancelled)
        StatusBadge(status: .failed)
    }
    .padding()
}
