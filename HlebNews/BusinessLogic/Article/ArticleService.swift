import Foundation

protocol ArticleServiceProtocol {
    func loadImage(url: String, completion: @escaping (Result<Data, Error>) -> Void)
}

final class ArticleService {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }
}

extension ArticleService: ArticleServiceProtocol {
    func loadImage(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        network.data(from: url, completion: completion)
    }
}
