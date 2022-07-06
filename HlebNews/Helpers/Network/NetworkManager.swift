import Foundation

private struct Const {
    static let api = "https://newsapi.org/v2/top-headlines"
    static let defaultCountry = "us"
    static let apiKey = "74cc40ce4e804d2b95335c51eb523080"
}

protocol NetworkManagerProtocol {
    func load<T: Decodable>(params: [String: String]?,
                            completion: @escaping (Result<T, Error>) -> Void)
    func data(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkManager {
    static let shared: NetworkManagerProtocol = NetworkManager()
    private let decoder = JSONDecoder()
}

// MARK: - NetworkManagerProtocol

extension NetworkManager: NetworkManagerProtocol {
    func load<T: Decodable>(params: [String: String]?,
                            completion: @escaping (Result<T, Error>) -> Void) {
        guard let urlComponents = NSURLComponents(string: Const.api) else {
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "country", value: Const.defaultCountry),
            URLQueryItem(name: "apiKey", value: Const.apiKey)
        ]
        params?.forEach {
            urlComponents.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        guard let url = urlComponents.url else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let model = try? self?.decoder.decode(T.self, from: data) else {
                      if let error = error {
                          completion(.failure(error))
                      }
                      return
                  }
            completion(.success(model))
        }
        task.resume()
    }

    func data(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
