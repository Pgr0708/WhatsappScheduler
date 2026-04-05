// Features/Onboarding/OnboardingView.swift
// WhatsappScheduler

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String
    let gradient: [Color]
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        systemImage: "clock.badge.checkmark.fill",
        title: NSLocalizedString("onboarding_title_1", comment: ""),
        subtitle: NSLocalizedString("onboarding_subtitle_1", comment: ""),
        gradient: [Color.whatsAppGreen, Color.whatsAppTeal]
    ),
    OnboardingPage(
        systemImage: "link.circle.fill",
        title: NSLocalizedString("onboarding_title_2", comment: ""),
        subtitle: NSLocalizedString("onboarding_subtitle_2", comment: ""),
        gradient: [Color.whatsAppTeal, Color(red: 0.1, green: 0.5, blue: 0.8)]
    ),
    OnboardingPage(
        systemImage: "rectangle.stack.fill.badge.person.crop",
        title: NSLocalizedString("onboarding_title_3", comment: ""),
        subtitle: NSLocalizedString("onboarding_subtitle_3", comment: ""),
        gradient: [Color(red: 0.4, green: 0.2, blue: 0.9), Color.whatsAppGreen]
    ),
    OnboardingPage(
        systemImage: "bell.badge.fill",
        title: NSLocalizedString("onboarding_title_4", comment: ""),
        subtitle: NSLocalizedString("onboarding_subtitle_4", comment: ""),
        gradient: [Color.orange, Color.pink]
    )
]

struct OnboardingView: View {

    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showPaywall = false
    @State private var notificationGranted = false

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .animation(.easeInOut, value: currentPage)

            VStack {
                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? Color.white : Color.white.opacity(0.4))
                            .frame(width: i == currentPage ? 10 : 7, height: i == currentPage ? 10 : 7)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, DS.Spacing.lg)

                // Action buttons
                VStack(spacing: DS.Spacing.sm) {
                    if currentPage == pages.count - 1 {
                        // Last page — ask for notifications then show paywall
                        Button {
                            Task {
                                let granted = (try? await NotificationService.shared.requestAuthorization()) ?? false
                                notificationGranted = granted
                                showPaywall = true
                            }
                        } label: {
                            Text(NSLocalizedString("onboarding_get_started", comment: ""))
                                .primaryButtonStyle()
                                .background(Color.white)
                                .foregroundStyle(Color.whatsAppGreen)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        }
                        .padding(.horizontal, DS.Spacing.xl)

                        Button {
                            showPaywall = true
                        } label: {
                            Text(NSLocalizedString("onboarding_skip", comment: ""))
                                .foregroundStyle(Color.white.opacity(0.8))
                                .font(.subheadline)
                        }
                    } else {
                        Button {
                            withAnimation { currentPage += 1 }
                        } label: {
                            Text(NSLocalizedString("onboarding_next", comment: ""))
                                .primaryButtonStyle()
                                .background(Color.white.opacity(0.2))
                                .foregroundStyle(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        }
                        .padding(.horizontal, DS.Spacing.xl)

                        Button {
                            showPaywall = true
                        } label: {
                            Text(NSLocalizedString("onboarding_skip", comment: ""))
                                .foregroundStyle(Color.white.opacity(0.8))
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.bottom, DS.Spacing.xxl)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(onDismiss: {
                hasCompletedOnboarding = true
            })
        }
    }
}

// MARK: - Single Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        ZStack {
            LiquidGlassBackground(colors: page.gradient)

            VStack(spacing: DS.Spacing.xl) {
                Spacer()

                Image(systemName: page.systemImage)
                    .font(.system(size: 90, weight: .light))
                    .foregroundStyle(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)

                VStack(spacing: DS.Spacing.sm) {
                    Text(page.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)

                    Text(page.subtitle)
                        .font(.body)
                        .foregroundStyle(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Spacing.xl)
                }

                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
