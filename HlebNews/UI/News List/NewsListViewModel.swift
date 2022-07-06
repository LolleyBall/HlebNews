import Foundation

private enum NewsSource {
    case cache
    case loaded
}

protocol NewsListViewModelProtocol {
    var didLoadFirstNews: (() -> Void)? { get set }
    var didReceiveError: ((String) -> Void)? { get set }
    var didUpdateAt: ((Int) -> Void)? { get set }

    var dataSource: [ArticleTableViewCell.Model] { get }

    func viewDidLoad()
    func loadMore()
    func update()
    func didTapArticle(at index: Int)
}

final class NewsListViewModel {
    private let newsListService: NewsListServiceProtocol
    private let router: NewsListRouterProtocol
    private let dateFormatter = CustomDateFormatter()
    private let newsQueue = DispatchQueue(label: "com.news.queue")

    private var currentPage = 0
    private var source: NewsSource = .cache

    var dataSource = [ArticleTableViewCell.Model]()
    var articles = [Article]()

    var didLoadFirstNews: (() -> Void)?
    var didReceiveError: ((String) -> Void)?
    var didUpdateAt: ((Int) -> Void)?

    init(newsListService: NewsListServiceProtocol,
         router: NewsListRouterProtocol) {
        self.newsListService = newsListService
        self.router = router
    }

    private func loadArticles(at page: Int) {
        newsQueue.sync {
            guard page > currentPage else {
                return
            }
            newsListService.loadNews(at: page) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let loadedArticles):
                    if self.source == .cache {
                        self.articles = loadedArticles
                            .sorted(by: { news1, news2 in
                                guard let news1PublishedAt = news1.publishedAt,
                                      let news2PublishedAt = news2.publishedAt else {
                                          return false
                                      }
                                return news1PublishedAt > news2PublishedAt
                            })
                        self.source = .loaded
                    } else {
                        self.articles.append(contentsOf: loadedArticles)
                    }
                    self.fillDataSource()
                    self.didLoadFirstNews?()
                case .failure(let error):
                    switch error {
                    case NewsServiceError.lastPageLoaded:
                        break
                    default:
                        self.didReceiveError?("Ошибка в процессе загрузки")
                    }
                }
                self.currentPage = page
            }
        }
    }

    private func fillDataSource() {
        dataSource = articles
            .map {
                var publishedAtString: String? = nil
                if let publishedAt = $0.publishedAt {
                    publishedAtString = dateFormatter.string(from: publishedAt, format: .MMMdhmma)
                }
                return ArticleTableViewCell.Model(title: $0.title,
                                                  publisher: $0.source,
                                                  publishedAt: publishedAtString,
                                                  viewsCount: "\($0.visitsCount)",
                                                  description: $0.description)
            }
    }
}

// MARK: - NewsListViewModelProtocol

extension NewsListViewModel: NewsListViewModelProtocol {

    func viewDidLoad() {
        articles = newsListService.cachedNews()
            .sorted(by: { news1, news2 in
                guard let news1PublishedAt = news1.publishedAt,
                      let news2PublishedAt = news2.publishedAt else {
                          return false
                      }
                return news1PublishedAt > news2PublishedAt
            })
        fillDataSource()
        didLoadFirstNews?()
        loadArticles(at: 1)
    }

    func loadMore() {
        loadArticles(at: currentPage + 1)
    }

    func update() {
        currentPage = 0
        loadArticles(at: 1)
    }

    func didTapArticle(at index: Int) {
        if articles.count > index {
            var selectedArticle = articles[index]
            selectedArticle.visitsCount += 1
            newsListService.update(selectedArticle)
            articles[index] = selectedArticle
            dataSource[index].viewsCount = "\(selectedArticle.visitsCount)"
            didUpdateAt?(index)
            router.goToArticle(selectedArticle)
        }
    }
}
