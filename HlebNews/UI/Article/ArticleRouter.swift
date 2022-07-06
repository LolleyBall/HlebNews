import Foundation
import UIKit

protocol ArticleRouterProtocol {
    func goToWebView(url: String)
}

struct ArticleRouter {
    weak var controller: ArticleViewController?
}

// MARK: - ArticleRouterProtocol

extension ArticleRouter: ArticleRouterProtocol {
    func goToWebView(url: String) {
        let webVM = WebViewModel(url: url)
        guard let webVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {
            return
        }
        webVC.viewModel = webVM

        controller?.present(webVC, animated: true, completion: nil)
    }
}
