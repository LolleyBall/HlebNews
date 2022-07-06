import Foundation
import UIKit

protocol NewsListRouterProtocol {
    func goToArticle(_ article: Article)
}

struct NewsListRouter: NewsListRouterProtocol {
    weak var controller: NewsListViewController?

    func goToArticle(_ article: Article) {
        guard let articleVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController else {
            return
        }
        let articleVM = ArticleViewModel(article: article,
                                         articleService: ArticleService(network: NetworkManager.shared),
                                         router: ArticleRouter(controller: articleVC))
        articleVC.viewModel = articleVM
        controller?.present(articleVC, animated: true, completion: nil)
    }
}
