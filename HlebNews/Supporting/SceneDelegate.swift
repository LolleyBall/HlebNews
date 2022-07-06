import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene),
        let newsListVC = window?.rootViewController as? NewsListViewController else { return }
        newsListVC.viewModel = NewsListViewModel(newsListService: NewsListService(network: NetworkManager.shared,
                                                                                  cache: CachingManager.shared), router: NewsListRouter(controller: newsListVC))
    }
}

