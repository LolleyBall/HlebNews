import Foundation

final class CustomDateFormatter {
    enum Format: String {
        case MMMdhmma = "MMM d, h:mm a"
        case yyyyMMddHHmmssZ = "yyyy-MM-dd'T'HH:mm:ssZ"
    }

    func string(from date: Date, format: Format) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }

    func date(from string: String, format: Format) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.date(from: string)
    }
}
