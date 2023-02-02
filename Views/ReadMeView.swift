import SwiftUI
import SwiftUIBackports
import MarkdownText

struct ReadMeView: View {
    @ScaledMetric(wrappedValue: 20) private var spacing

    @State private var markdown: String = ""
    @State private var clientError: ClientError?
    @State private var isFetching: Bool = false

    let repo: Repo

    var body: some View {
        ScrollView {
            HStack {
                LazyMarkdownText(markdown, paragraphSpacing: spacing)
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle("\(repo.id)")
        .backport.task {
            guard markdown.isEmpty else { return }

            isFetching = true
            defer { isFetching = false }

            do {
                markdown = try await Client.fetchReadme(for: repo)
            } catch {
                clientError = ClientError(error: error)
            }
        }
        .alert(item: $clientError) { error in
            Alert(title: Text("Failed"), message: Text(error.localizedDescription))
        }
        .overlay(ProgressView().opacity(isFetching ? 1 : 0))
        .toolbar {
            Backport.ShareLink(item: URL(string: "https://github.com/\(repo.id)")!) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
}
