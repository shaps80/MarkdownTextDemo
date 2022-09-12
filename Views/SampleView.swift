import SwiftUI
import MarkdownText

struct SampleView: View {
    @ScaledMetric(wrappedValue: 20) private var spacing
    let url: URL

    @State private var showCode: Bool = true
    @State private var showHeadings: Bool = true
    @State private var showImages: Bool = true
    @State private var showQuotes: Bool = true
    @State private var showThematicBreaks: Bool = true
    @State private var showUnorderedBullets: Bool = true
    @State private var showOrderedBullets: Bool = true
    @State private var showCheckListBullets: Bool = true
    @State private var showUnorderedItems: Bool = true
    @State private var showOrderedItems: Bool = true
    @State private var showCheckedItems: Bool = true
    @State private var showLists: Bool = true

    private var markdown: String {
        let data = try! Data(contentsOf: url)
        return String(decoding: data, as: UTF8.self)
    }

    var body: some View {
        ScrollView {
            HStack {
                MarkdownText(markdown, paragraphSpacing: spacing)
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .markdownHeadingStyle(.custom)
        .markdownQuoteStyle(.custom)
        .markdownCodeStyle(.custom)
        .markdownInlineCodeStyle(.custom)
        .markdownOrderedListBulletStyle(.custom)
        .markdownImageStyle(.custom)
        .markdownCode(showCode ? .visible : .hidden)
        .markdownHeading(showHeadings ? .visible : .hidden)
        .markdownImage(showImages ? .visible : .hidden)
        .markdownQuote(showQuotes ? .visible : .hidden)
        .markdownThematicBreak(showThematicBreaks ? .visible : .hidden)
        .markdownUnorderedListItemBullet(showUnorderedBullets ? .visible : .hidden)
        .markdownOrderedListItemBullet(showOrderedBullets ? .visible : .hidden)
        .markdownCheckListItemBullet(showCheckListBullets ? .visible : .hidden)
        .markdownUnorderedListItem(showUnorderedItems ? .visible : .hidden)
        .markdownOrderedListItem(showOrderedItems ? .visible : .hidden)
        .markdownCheckListItem(showCheckedItems ? .visible : .hidden)
        .markdownList(showLists ? .visible : .hidden)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(url.deletingPathExtension().lastPathComponent)
        .toolbar {
            if url.lastPathComponent == "All.md" {
                Menu {
                    Toggle("Headings", isOn: $showHeadings.animation(.spring()))
                    Toggle("Blockquotes", isOn: $showQuotes.animation(.spring()))
                    Toggle("Code Blocks", isOn: $showCode.animation(.spring()))

                    Divider()

                    Toggle("Images", isOn: $showImages.animation(.spring()))
                    Toggle("Thematic Breaks", isOn: $showThematicBreaks.animation(.spring()))

                    Divider()

                    Toggle("Lists", isOn: $showLists.animation(.spring()))

                    Menu("List Bullets") {
                        Toggle("Ordered", isOn: $showOrderedBullets.animation(.spring()))
                        Toggle("Unordered", isOn: $showUnorderedBullets.animation(.spring()))
                        Toggle("Checked", isOn: $showCheckListBullets.animation(.spring()))
                    }

                    Menu("List Items") {
                        Toggle("Ordered", isOn: $showOrderedItems.animation(.spring()))
                        Toggle("Unordered", isOn: $showUnorderedItems.animation(.spring()))
                        Toggle("Checked", isOn: $showCheckedItems.animation(.spring()))
                    }
                } label: {
                    Label("Visibility", systemImage: "ellipsis.circle")
                }
            }
        }
    }
}
