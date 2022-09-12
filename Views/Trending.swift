import Foundation
import SwiftUIBackports

@MainActor
enum Client {
    private static let url = URL(string: "https://gh-trending-api.herokuapp.com/repositories/swift")!
    private static let decoder = JSONDecoder()

    // hacky, but good enough for this demo
    private static let cache = Cache.shared

    static func fetchRepos() async throws {
        guard cache.repos.isEmpty else { return }

        print("Fetching repos...")
        let data = try await URLSession.shared
            .backport.data(from: url).0
        print("Fetched repos.")

        let updates = try decoder.decode([Repo].self, from: data)
        cache.repos = updates
    }

    static func fetchReadme(for repo: Repo) async throws -> String {
        print("Fetching \(repo.id) readme...")
        let data = try await URLSession.shared
            .backport.data(from: repo.url).0
        print("Fetched \(repo.id) readme")
        return String(decoding: data, as: UTF8.self)
    }
}

@MainActor
final class Cache: ObservableObject {
    static let shared = Cache()

    @Published var repos: [Repo] {
        didSet {
            let data = try? JSONEncoder().encode(repos)
            try? data?.write(to: Self.url, options: .atomicWrite)
        }
    }

    init() {
        do {
            let data = try Data(contentsOf: Self.url)
            repos = try JSONDecoder().decode([Repo].self, from: data)
        } catch {
            repos = []
        }
    }

    private static let url = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("repositories.json")
}

struct Repo: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case owner = "username"
        case name = "repositoryName"
    }

    var id: String { "\(owner)/\(name)" }
    var owner: String
    var name: String

    var url: URL {
        URL(string: "https://raw.githubusercontent.com/\(owner)/\(name)/master/README.md")!
    }
}

struct ClientError: LocalizedError, Identifiable {
    var id: String { error.localizedDescription }
    let error: Error
    var errorDescription: String? {
        error.localizedDescription
    }
}
