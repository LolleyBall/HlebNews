import Foundation

protocol CachingManagerProtocol {
    func cache<T: Encodable>(key: String, value: T)
    func value<T: Decodable>(by key: String) -> T?
    func all<T: Decodable>() -> [T]
}

final class CachingManager {
    static let shared: CachingManagerProtocol = CachingManager()

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
}

// MARK: - CachingManagerProtocol

extension CachingManager: CachingManagerProtocol {
    func cache<T: Encodable>(key: String, value: T) {
        let encoder = try? JSONEncoder().encode(value)
        userDefaults.set(encoder, forKey: key)
    }

    func value<T: Decodable>(by key: String) -> T? {
        guard let data = userDefaults.data(forKey: key),
              let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                  return nil
              }
        return decodedData
    }

    func all<T: Decodable>() -> [T] {
        userDefaults.dictionaryRepresentation().compactMap {
            guard let data = $0.value as? Data,
                  let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                      return nil
                  }
            return decodedData
        }
    }
}
