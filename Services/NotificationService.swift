// Services/NotificationService.swift
// WhatsappScheduler
//
// Manages local notification scheduling.
// When a notification is tapped, the app opens WhatsApp
// with the pre-filled message for the user to send manually.

import Foundation
import UserNotifications
import UIKit

enum NotificationError: LocalizedError {
    case permissionDenied
    case schedulingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("notification_permission_denied", comment: "")
        case .schedulingFailed(let error):
            return error.localizedDescription
        }
    }
}

/// Category identifier for WhatsApp schedule notifications
private let kScheduleNotificationCategory = "WHATSAPP_SCHEDULE"
/// UserInfo key for schedule ID
let kNotificationScheduleIDKey = "scheduleId"
/// UserInfo key for phone number
let kNotificationPhoneKey = "phone"
/// UserInfo key for message body
let kNotificationMessageKey = "message"

final class NotificationService: NSObject {

    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    // MARK: - Setup

    func setup() {
        center.delegate = self
        registerNotificationCategories()
    }

    private func registerNotificationCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_WHATSAPP",
            title: NSLocalizedString("notification_action_open_whatsapp", comment: ""),
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: kScheduleNotificationCategory,
            actions: [openAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        center.setNotificationCategories([category])
    }

    // MARK: - Permission

    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await center.requestAuthorization(options: options)
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule

    /// Schedule a local notification for the given ScheduledMessage.
    func schedule(_ message: ScheduledMessage) async throws {
        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else {
            throw NotificationError.permissionDenied
        }

        let content = UNMutableNotificationContent()
        let displayName = message.recipientName ?? message.phoneNumber
        content.title = String(format: NSLocalizedString("notification_title_format", comment: ""), displayName)
        content.body = String(message.messageBody.prefix(100))
        content.sound = .default
        content.categoryIdentifier = kScheduleNotificationCategory
        content.userInfo = [
            kNotificationScheduleIDKey: message.id.uuidString,
            kNotificationPhoneKey: message.phoneNumber,
            kNotificationMessageKey: message.messageBody
        ]

        // Badge count will be updated separately
        let triggerDate = message.nextTriggerAt ?? message.scheduledAt
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: message.id.uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            throw NotificationError.schedulingFailed(error)
        }
    }

    /// Cancel notification for a schedule ID.
    func cancel(scheduleId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [scheduleId.uuidString])
        center.removeDeliveredNotifications(withIdentifiers: [scheduleId.uuidString])
    }

    /// Cancel all pending schedule notifications.
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Badge

    /// Update the app icon badge to reflect pending schedule count.
    @MainActor
    func updateBadge(pendingCount: Int) {
        UNUserNotificationCenter.current().setBadgeCount(pendingCount) { _ in }
    }

    // MARK: - Pending Requests

    func pendingScheduleIds() async -> Set<String> {
        let requests = await center.pendingNotificationRequests()
        let ids = requests.map { $0.identifier }
        return Set(ids)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {

    // Called when notification is tapped while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    // Called when user taps notification or action button
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard
            let phone = userInfo[kNotificationPhoneKey] as? String,
            let message = userInfo[kNotificationMessageKey] as? String
        else { return }

        // Open WhatsApp with prefilled message
        await WhatsAppService.shared.openWhatsApp(phoneNumber: phone, message: message)

        // Log the event
        if let idString = userInfo[kNotificationScheduleIDKey] as? String,
           let scheduleId = UUID(uuidString: idString) {
            await logWhatsAppOpened(scheduleId: scheduleId, phone: phone)
        }
    }

    @MainActor
    private func logWhatsAppOpened(scheduleId: UUID, phone: String) {
        // Post notification so HistoryViewModel can pick it up
        NotificationCenter.default.post(
            name: .didOpenWhatsAppFromSchedule,
            object: nil,
            userInfo: [
                kNotificationScheduleIDKey: scheduleId.uuidString,
                kNotificationPhoneKey: phone
            ]
        )
    }
}

// MARK: - NSNotification.Name
extension Notification.Name {
    static let didOpenWhatsAppFromSchedule = Notification.Name("didOpenWhatsAppFromSchedule")
    static let schedulesDidChange          = Notification.Name("schedulesDidChange")
}
