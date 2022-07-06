import Foundation

struct Article: Codable {
    let title: String?
    let imageURLString: String?
    let source: String?
    let author: String?
    let description: String?
    let sourceURLString: String?
    let publishedAt: Date?
    let content: String?
    var visitsCount = 0
}
