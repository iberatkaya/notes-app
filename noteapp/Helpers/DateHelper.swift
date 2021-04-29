import Foundation

/// Format a date to a date time.
/// - Parameters
///     - date: The date to be converted to a string.
func formatDateTime(date: Date) -> String {
    let formatter1 = DateFormatter()
    formatter1.dateStyle = .short
    formatter1.timeStyle = .short
    return formatter1.string(from: date)
}
