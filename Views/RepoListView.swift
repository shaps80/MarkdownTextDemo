import SwiftUI

struct RepoListView: View {
    @EnvironmentObject private var cache: Cache

    var body: some View {
        ForEach(cache.repos) { repo in
            NavigationLink {
                ReadMeView(repo: repo)
            } label: {
                VStack(alignment: .leading) {
                    Text(repo.name)
                        .fontWeight(.medium)

                    Text(repo.owner)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                .padding(.vertical, 4)
            }
        }
        .environmentObject(cache)
    }
}
