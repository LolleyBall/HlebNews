import Foundation

protocol ArticleViewModelProtocol {
    var article: Article { get }

    var didLoadImage: ((Data) -> Void)? { get set }

    func viewDidLoad()
    func didTapOpenNews()
}

final class ArticleViewModel {
    private(set) var article: Article
    private let articleService: ArticleServiceProtocol
    private let router: ArticleRouterProtocol

    var didLoadImage: ((Data) -> Void)?

    init(article: Article,
         articleService: ArticleServiceProtocol,
         router: ArticleRouterProtocol) {
        self.article = article
        self.articleService = articleService
        self.router = router
    }
}

// MARK: - ArticleViewModelProtocol

extension ArticleViewModel: ArticleViewModelProtocol {

    func viewDidLoad() {
        guard let imageURLString = article.imageURLString else {
            return
        }
        articleService.loadImage(url: imageURLString) { [weak self] result in
            switch result {
            case .success(let data):
                self?.didLoadImage?(data)
            case .failure: break
            }
        }
    }

    func didTapOpenNews() {
        guard let url = article.sourceURLString else {
            return
        }
        router.goToWebView(url: url)
    }
}
