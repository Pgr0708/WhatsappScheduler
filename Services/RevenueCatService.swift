// Services/RevenueCatService.swift
// WhatsappScheduler
//
// RevenueCat integration stub for subscription management.
// Replace the placeholder API key and configure offerings in
// the RevenueCat dashboard and App Store Connect before shipping.

import Foundation
import StoreKit

// MARK: - Entitlement / Product IDs
enum PurchaseEntitlement: String {
    case pro = "pro_access"
}

enum ProductID: String, CaseIterable {
    case weeklyPro   = "com.whatsappscheduler.pro.weekly"
    case monthlyPro  = "com.whatsappscheduler.pro.monthly"
    case yearlyPro   = "com.whatsappscheduler.pro.yearly"
    case lifetimePro = "com.whatsappscheduler.pro.lifetime"
}

// MARK: - Subscription Status

struct SubscriptionStatus {
    var isActive: Bool
    var productId: String?
    var expiresAt: Date?
    var isLifetime: Bool

    static let free = SubscriptionStatus(isActive: false, productId: nil, expiresAt: nil, isLifetime: false)
}

// MARK: - RevenueCatService

/// Stub service for RevenueCat integration.
/// Wire up with the RevenueCat SDK (Purchases.configure) once the API key is set.
@MainActor
final class RevenueCatService: ObservableObject {

    static let shared = RevenueCatService()

    @Published var subscriptionStatus: SubscriptionStatus = .free
    @Published var availableProducts: [Product] = []
    @Published var isPurchasing: Bool = false
    @Published var purchaseError: String?

    // MARK: - RevenueCat API Key
    // ⚠️ Replace with your real key from the RevenueCat dashboard before shipping.
    // Store the actual key in a Config.plist or xcconfig file that is git-ignored
    // to prevent accidental exposure in version control.
    private let apiKey = "REPLACE_WITH_YOUR_REVENUECAT_API_KEY"

    private init() {}

    // MARK: - Setup

    /// Call this on app launch after user is authenticated.
    func setup() async {
        // When integrating RevenueCat SDK:
        // Purchases.configure(withAPIKey: apiKey)
        // Purchases.shared.delegate = self
        await loadProducts()
        await refreshStatus()
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: ProductID.allCases.map { $0.rawValue })
            self.availableProducts = products.sorted { $0.price < $1.price }
        } catch {
            // StoreKit not configured in dev — expected in simulator
        }
    }

    // MARK: - Purchase

    func purchase(product: Product) async -> Bool {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await refreshStatus()
                    return true
                case .unverified:
                    purchaseError = NSLocalizedString("purchase_verification_failed", comment: "")
                    return false
                }
            case .pending:
                return false
            case .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshStatus()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Status Refresh

    func refreshStatus() async {
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if ProductID(rawValue: transaction.productID) != nil {
                    let isLifetime = transaction.productID == ProductID.lifetimePro.rawValue
                    subscriptionStatus = SubscriptionStatus(
                        isActive: true,
                        productId: transaction.productID,
                        expiresAt: transaction.expirationDate,
                        isLifetime: isLifetime
                    )
                    found = true
                    break
                }
            }
        }
        if !found {
            subscriptionStatus = .free
        }
    }

    // MARK: - Gating Helper

    var isPro: Bool {
        subscriptionStatus.isActive
    }
}
