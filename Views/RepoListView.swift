import SwiftUI

struct RepoListView: View {
    @EnvironmentObject private var cache: Cache

    var body: some View {
        ForEach(cache.repos) { repo in
            NavigationLink {
                ReadMeView(repo: repo)
            } label: {
                VStack(alignment: .leading) {
                    Text(repo.id)
                        .foregroundColor(.primary)
                        .font(.footnote)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
            }
        }
        .environmentObject(cache)
    }
}
