import SwiftUI
import SwiftUIBackports
import MarkdownText

struct ContentView: View {
    let urls = Bundle.main.urls(forResourcesWithExtension: "md", subdirectory: "Samples")?
        .sorted { $0.lastPathComponent < $1.lastPathComponent } ?? []

    @StateObject private var cache: Cache
    @State private var clientError: ClientError?
    @State private var isFetching: Bool = false

    init() {
        _cache = .init(wrappedValue: Cache.shared)
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(urls, id: \.lastPathComponent) { url in
                        NavigationLink(url.deletingPathExtension().lastPathComponent) {
                            SampleView(url: url)
                        }
                    }
                } header: {
                    Text("Samples")
                }

                Section {
                    RepoListView()
                } header: {
                    Text("Trending")
                }
                .overlay(ProgressView().opacity(isFetching ? 1 : 0))
            }
#if os(iOS)
            .listStyle(.insetGrouped)
#endif
            .navigationTitle("Markdown")
        }
        .markdownHeadingStyle(.custom)
        .markdownQuoteStyle(.custom)
        .markdownCodeStyle(.custom)
        .markdownInlineCodeStyle(.custom)
        .markdownOrderedListBulletStyle(.custom)
        .markdownImageStyle(.custom)
        .backport.task {
            guard cache.repos.isEmpty else { return }
            await fetch()
        }
        .alert(item: $clientError) { error in
            Alert(title: Text("Failed"), message: Text(error.localizedDescription))
        }
        .environmentObject(cache)
    }

    @Sendable
    private func fetch() async {
        isFetching = true
        defer { isFetching = false }

        do {
            try await Client.fetchRepos()
        } catch {
            clientError = ClientError(error: error)
        }
    }
}
