// Features/Paywall/PaywallView.swift
// WhatsappScheduler

import SwiftUI
import StoreKit

struct PaywallFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

private let paywallFeatures: [PaywallFeature] = [
    PaywallFeature(icon: "infinity",          title: NSLocalizedString("paywall_feature_unlimited_title", comment: ""),  subtitle: NSLocalizedString("paywall_feature_unlimited_sub", comment: "")),
    PaywallFeature(icon: "repeat.circle.fill", title: NSLocalizedString("paywall_feature_recurring_title", comment: ""),  subtitle: NSLocalizedString("paywall_feature_recurring_sub", comment: "")),
    PaywallFeature(icon: "rectangle.stack.fill", title: NSLocalizedString("paywall_feature_templates_title", comment: ""), subtitle: NSLocalizedString("paywall_feature_templates_sub", comment: "")),
    PaywallFeature(icon: "icloud.fill",        title: NSLocalizedString("paywall_feature_sync_title", comment: ""),       subtitle: NSLocalizedString("paywall_feature_sync_sub", comment: "")),
    PaywallFeature(icon: "chart.bar.fill",     title: NSLocalizedString("paywall_feature_analytics_title", comment: ""), subtitle: NSLocalizedString("paywall_feature_analytics_sub", comment: ""))
]

struct PaywallView: View {

    @StateObject private var purchaseService = RevenueCatService.shared
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)?

    @State private var selectedProduct: Product?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        LiquidGlassBackground()
                            .frame(height: 280)

                        VStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white)

                            Text(NSLocalizedString("paywall_title", comment: ""))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)

                            Text(NSLocalizedString("paywall_subtitle", comment: ""))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }

                    // Features list
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(paywallFeatures) { feature in
                            HStack(spacing: DS.Spacing.md) {
                                Image(systemName: feature.icon)
                                    .font(.title3)
                                    .foregroundStyle(DS.Color.whatsAppGreen)
                                    .frame(width: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.headline)
                                    Text(feature.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.vertical, DS.Spacing.sm)

                            Divider().padding(.horizontal, DS.Spacing.lg)
                        }
                    }
                    .padding(.top, DS.Spacing.lg)

                    // Products
                    if purchaseService.availableProducts.isEmpty {
                        // Placeholder products while loading or in simulator
                        PlaceholderProductsView(onDismiss: {
                            onDismiss?()
                            dismiss()
                        })
                    } else {
                        VStack(spacing: DS.Spacing.sm) {
                            ForEach(purchaseService.availableProducts, id: \.id) { product in
                                ProductRow(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id
                                )
                                .onTapGesture { selectedProduct = product }
                            }
                        }
                        .padding(DS.Spacing.lg)

                        // Purchase button
                        Button {
                            guard let product = selectedProduct ?? purchaseService.availableProducts.first else { return }
                            Task { _ = await purchaseService.purchase(product: product) }
                        } label: {
                            Group {
                                if purchaseService.isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(NSLocalizedString("paywall_subscribe_button", comment: ""))
                                }
                            }
                            .primaryButtonStyle()
                            .background(DS.Color.whatsAppGreen)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        }
                        .padding(.horizontal, DS.Spacing.lg)
                        .disabled(purchaseService.isPurchasing)
                    }

                    // Restore + skip
                    VStack(spacing: DS.Spacing.xs) {
                        Button {
                            Task { await purchaseService.restorePurchases() }
                        } label: {
                            Text(NSLocalizedString("paywall_restore", comment: ""))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            onDismiss?()
                            dismiss()
                        } label: {
                            Text(NSLocalizedString("paywall_continue_free", comment: ""))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, DS.Spacing.lg)

                    Text(NSLocalizedString("paywall_legal_notice", comment: ""))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.bottom, DS.Spacing.xxl)
                }
            }

            // Close button
            Button {
                onDismiss?()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding(DS.Spacing.md)
            }
        }
        .task { await purchaseService.loadProducts() }
    }
}

// MARK: - Product Row

struct ProductRow: View {
    let product: Product
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(product.displayPrice)
                .font(.headline)
                .foregroundStyle(DS.Color.whatsAppGreen)
        }
        .padding(DS.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(isSelected ? DS.Color.whatsAppGreen.opacity(0.1) : DS.Color.secondaryBG)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(isSelected ? DS.Color.whatsAppGreen : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Placeholder (simulator / no products configured)

struct PlaceholderProductsView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Text(NSLocalizedString("paywall_products_unavailable", comment: ""))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Button {
                onDismiss()
            } label: {
                Text(NSLocalizedString("paywall_continue_free", comment: ""))
                    .secondaryButtonStyle()
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
        .padding(DS.Spacing.lg)
    }
}

#Preview {
    PaywallView()
}
