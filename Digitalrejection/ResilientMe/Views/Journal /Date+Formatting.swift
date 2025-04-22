import Foundation

// MARK: - Date Formatting Extension

extension Date {
    /// Formats the date into a string using the specified format pattern.
    /// - Parameter format: A `DateFormatter` compliant format string (e.g., "MMM d, yyyy", "EEEE, MMMM d").
    /// - Returns: A formatted string representation of the date.
    func formatted(format: String) -> String {
        let formatter = DateFormatter()
        // Consider setting locale and timezone if specific formatting is required globally
        // formatter.locale = Locale(identifier: "en_US_POSIX") 
        // formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    /// Provides a relative date string (e.g., "Yesterday", "2 days ago") for recent dates.
    /// Falls back to a standard format for older dates.
    /// - Parameter fallbackFormat: The format string to use for dates older than a week.
    /// - Returns: A user-friendly string representation of the date.
    func relativeFormatted(fallbackFormat: String = "MMM d, yyyy") -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            // Check if within the last week
            if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
               self > weekAgo {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // Day of the week (e.g., "Monday")
                return formatter.string(from: self)
            } else {
                // Older than a week, use the fallback format
                return self.formatted(format: fallbackFormat)
            }
        }
    }
} 