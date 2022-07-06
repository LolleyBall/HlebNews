import Foundation

protocol WebViewModelProtocol {
    var request: URLRequest? { get }
}

final class WebViewModel {
    let url: String

    init(url: String) {
        self.url = url
    }
}

// MARK: - WebViewModelProtocol

extension WebViewModel: WebViewModelProtocol {
    var request: URLRequest? {
        guard let newsURL = URL(string: url) else {
            return nil
        }
        return URLRequest(url: newsURL)
    }
}
