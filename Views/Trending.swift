import Foundation
import SwiftUIBackports

@MainActor
enum Client {
    private static let url = URL(string: "https://api.github.com/search/repositories?sort=stars&order=desc&q=language:swift")!
    private static let decoder = JSONDecoder()

    // hacky, but good enough for this demo
    private static let cache = Cache.shared

    static func fetchRepos() async throws {
        guard cache.repos.isEmpty else { return }

        let data = try await URLSession.shared
            .backport.data(from: url).0

        let items = try decoder.decode(Repo.Items.self, from: data)
        cache.repos = items.repos
    }

    static func fetchReadme(for repo: Repo) async throws -> String {
        let data = try await URLSession.shared
            .backport.data(from: repo.url).0
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
        case id = "full_name"
    }

    var id: String

    var url: URL {
        URL(string: "https://raw.githubusercontent.com/\(id)/master/README.md")!
    }

    struct Items: Codable {
        enum CodingKeys: String, CodingKey {
            case repos = "items"
        }

        let repos: [Repo]
    }
}

struct ClientError: LocalizedError, Identifiable {
    var id: String { error.localizedDescription }
    let error: Error
    var errorDescription: String? {
        error.localizedDescription
    }
}
