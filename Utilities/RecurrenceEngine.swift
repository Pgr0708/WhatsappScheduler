// Utilities/RecurrenceEngine.swift
// WhatsappScheduler
//
// Computes the next trigger date for recurring schedules.

import Foundation

enum RecurrenceEngineError: Error {
    case noNextDate
}

struct RecurrenceEngine {

    /// Computes the next trigger date after `referenceDate` for a given recurrence rule.
    /// - Parameters:
    ///   - rule: The recurrence rule (.daily, .weekly, .monthly, or .none).
    ///   - days: For `.weekly`, an array of weekday integers (1=Sunday … 7=Saturday).
    ///   - referenceDate: The date after which the next occurrence should be found (defaults to now).
    ///   - baseTime: The original scheduled time (used to preserve hour/minute).
    /// - Returns: The next trigger Date, or nil if no future date can be found.
    static func nextDate(
        rule: RecurrenceRule,
        days: [Int],
        referenceDate: Date = Date(),
        baseTime: Date
    ) -> Date? {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: baseTime)

        switch rule {
        case .none:
            return nil

        case .daily:
            // Next occurrence at same time tomorrow (or later)
            var next = calendar.nextDate(
                after: referenceDate,
                matching: timeComponents,
                matchingPolicy: .nextTime
            )
            // Ensure it's strictly after referenceDate
            if let candidate = next, candidate <= referenceDate {
                next = calendar.date(byAdding: .day, value: 1, to: candidate)
            }
            return next

        case .weekly:
            guard !days.isEmpty else { return nil }
            // Find the nearest weekday from `days` after referenceDate
            var candidates: [Date] = []
            for weekday in days {
                var components = timeComponents
                components.weekday = weekday
                if let candidate = calendar.nextDate(
                    after: referenceDate,
                    matching: components,
                    matchingPolicy: .nextTimePreservingSmallerComponents
                ) {
                    candidates.append(candidate)
                }
            }
            return candidates.min()

        case .monthly:
            // Same day-of-month at same time next month
            let dayComponent = calendar.component(.day, from: baseTime)
            var components = timeComponents
            components.day = dayComponent
            if let candidate = calendar.nextDate(
                after: referenceDate,
                matching: components,
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) {
                return candidate
            }
            return nil
        }
    }

    /// After a notification fires, compute and update the next trigger for a recurring schedule.
    static func advance(schedule: inout ScheduledMessage) {
        guard schedule.recurrenceRule != .none, !schedule.isPaused else { return }
        let base = schedule.nextTriggerAt ?? schedule.scheduledAt
        schedule.nextTriggerAt = nextDate(
            rule: schedule.recurrenceRule,
            days: schedule.recurrenceDays,
            baseTime: base
        )
        schedule.updatedAt = Date()
    }
}
