// Services/WhatsAppService.swift
// WhatsappScheduler
//
// Handles WhatsApp deep link generation and navigation.
// iOS does NOT allow automatic message sending via WhatsApp —
// the user must always tap "Send" inside WhatsApp.
// This service builds the wa.me deep link and opens WhatsApp.

import Foundation
import UIKit

enum WhatsAppError: LocalizedError {
    case whatsAppNotInstalled
    case invalidPhoneNumber
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .whatsAppNotInstalled:
            return NSLocalizedString("whatsapp_not_installed", comment: "")
        case .invalidPhoneNumber:
            return NSLocalizedString("invalid_phone_number", comment: "")
        case .invalidURL:
            return NSLocalizedString("invalid_url", comment: "")
        }
    }
}

/// Service responsible for generating WhatsApp deep links and opening WhatsApp.
final class WhatsAppService {

    static let shared = WhatsAppService()
    private init() {}

    // MARK: - Deep Link Generation

    /// Builds a `whatsapp://send` deep link URL.
    /// - Parameters:
    ///   - phoneNumber: Phone number in E.164 format (e.g. "+919876543210") or digits only.
    ///   - message: Pre-filled message text.
    /// - Returns: A URL using the `whatsapp://send` scheme, or nil on failure.
    func deepLinkURL(phoneNumber: String, message: String) -> URL? {
        let sanitized = sanitize(phoneNumber: phoneNumber)
        guard !sanitized.isEmpty else { return nil }
        guard var components = URLComponents(string: "https://wa.me/\(sanitized)") else {
            return nil
        }
        if !message.isEmpty {
            components.queryItems = [URLQueryItem(name: "text", value: message)]
        }
        return components.url
    }

    /// Builds a `whatsapp://send` scheme URL (for devices with WhatsApp installed).
    func nativeDeepLinkURL(phoneNumber: String, message: String) -> URL? {
        let sanitized = sanitize(phoneNumber: phoneNumber)
        guard !sanitized.isEmpty else { return nil }
        var components = URLComponents()
        components.scheme = "whatsapp"
        components.host = "send"
        components.queryItems = [
            URLQueryItem(name: "phone", value: sanitized),
            URLQueryItem(name: "text", value: message)
        ]
        return components.url
    }

    // MARK: - Open WhatsApp

    /// Opens WhatsApp with the given phone number and pre-filled message.
    /// Falls back to the wa.me web URL if WhatsApp is not installed.
    /// - Parameters:
    ///   - phoneNumber: Phone number (E.164 or digits only).
    ///   - message: Pre-filled message text (user must tap Send).
    ///   - completion: Called with an error if opening fails.
    @MainActor
    func openWhatsApp(phoneNumber: String, message: String, completion: ((WhatsAppError?) -> Void)? = nil) {
        let sanitized = sanitize(phoneNumber: phoneNumber)
        guard !sanitized.isEmpty else {
            completion?(.invalidPhoneNumber)
            return
        }

        // Try native WhatsApp scheme first
        if let nativeURL = nativeDeepLinkURL(phoneNumber: sanitized, message: message),
           UIApplication.shared.canOpenURL(nativeURL) {
            UIApplication.shared.open(nativeURL, options: [:]) { success in
                completion?(success ? nil : .whatsAppNotInstalled)
            }
            return
        }

        // Fallback: wa.me web link (works in Safari / opens WhatsApp on device)
        if let webURL = deepLinkURL(phoneNumber: sanitized, message: message) {
            UIApplication.shared.open(webURL, options: [:]) { success in
                completion?(success ? nil : .invalidURL)
            }
        } else {
            completion?(.invalidURL)
        }
    }

    /// Returns true if WhatsApp is installed on the device.
    func isWhatsAppInstalled() -> Bool {
        guard let url = URL(string: "whatsapp://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    // MARK: - Phone Number Sanitization

    /// Strips all non-digit characters except the leading '+'.
    func sanitize(phoneNumber: String) -> String {
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("+") {
            let digits = trimmed.dropFirst().filter { $0.isNumber }
            return "+\(digits)"
        }
        return trimmed.filter { $0.isNumber }
    }

    /// Basic E.164 validation: starts with + and has 7–15 digits.
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let sanitized = sanitize(phoneNumber: phoneNumber)
        let pattern = #"^\+[1-9]\d{6,14}$"#
        return sanitized.range(of: pattern, options: .regularExpression) != nil
    }
}
