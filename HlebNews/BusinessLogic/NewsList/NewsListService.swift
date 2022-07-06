import Foundation

private struct Const {
    static let maxItemsPerPage = 20
}

enum NewsServiceError: Error {
    case lastPageLoaded
}

private struct LoadedArticle: Decodable {
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

private struct Source: Decodable {
    let id: String?
    let name: String?
}

private struct Articles: Decodable {
    let totalResults: Int
    let articles: [LoadedArticle]
}

protocol NewsListServiceProtocol {
    func cachedNews() -> [Article]
    func loadNews(at page: Int, completion: @escaping (Result<[Article], Error>) -> Void)
    func update(_ article: Article)
}

final class NewsListService {
    private let network: NetworkManagerProtocol
    private let cache: CachingManagerProtocol
    private let dateFormatter = CustomDateFormatter()

    private var maxItems = 0

    init(network: NetworkManagerProtocol,
         cache: CachingManagerProtocol) {
        self.network = network
        self.cache = cache
    }
}

// MARK: - NewsListServiceProtocol

extension NewsListService: NewsListServiceProtocol {

    func cachedNews() -> [Article] {
        cache.all()
    }

    func loadNews(at page: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard ((Const.maxItemsPerPage * page) - Const.maxItemsPerPage) <= maxItems else {
            completion(.failure(NewsServiceError.lastPageLoaded))
            return
        }
        network.load(params: ["page": "\(page)"]) { [weak self] (result: Result<Articles, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let loadedArticles):
                self.maxItems = loadedArticles.totalResults
                let articles = loadedArticles.articles.map { loadedArticle -> Article in
                    var publishedAtDate: Date? = nil
                    if let publishedAt = loadedArticle.publishedAt {
                        publishedAtDate = self.dateFormatter.date(from: publishedAt, format: .yyyyMMddHHmmssZ)
                    }

                    return Article(title: loadedArticle.title,
                                   imageURLString: loadedArticle.urlToImage,
                                   source: loadedArticle.source?.name,
                                   author: loadedArticle.author,
                                   description: loadedArticle.description,
                                   sourceURLString: loadedArticle.url,
                                   publishedAt: publishedAtDate,
                                   content: loadedArticle.content)
                }
                articles.forEach {
                    guard let title = $0.title else { return }
                    var article = $0
                    if let cachedArticle: Article = self.cache.value(by: title) {
                        article.visitsCount = cachedArticle.visitsCount
                    }
                    self.cache.cache(key: title, value: article)
                }
                completion(.success(self.cachedNews()))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func update(_ article: Article) {
        guard let title = article.title else { return }
        cache.cache(key: title, value: article)
    }
}
