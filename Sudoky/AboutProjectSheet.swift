import SwiftUI

struct AboutProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    @ScaledMetric(relativeTo: .body) private var headingFontSize: CGFloat = 22
    @ScaledMetric(relativeTo: .body) private var bodyFontSize: CGFloat = 17

    var body: some View {
        let _ = languageManager.language

        NavigationView {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        PaperSectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                heading("about.appName", size: 24)
                                paragraph("about.author")
                            }
                        }

                        PaperSectionCard {
                            VStack(alignment: .leading, spacing: 6) {
                                heading("about.acknowledgements")
                                paragraph("about.thanks.natasha")
                                paragraph("about.thanks.composer")
                                paragraph("about.thanks.fox")
                                paragraph("about.thanks.testers")
                            }
                        }

                        PaperSectionCard {
                            VStack(alignment: .leading, spacing: 6) {
                                heading("about.aiTeam")
                                paragraph("about.ai.chatgpt")
                                paragraph("about.ai.shedevrum")
                                paragraph("about.ai.deepseek")
                            }
                        }

                        PaperSectionCard {
                            VStack(alignment: .leading, spacing: 6) {
                                heading("about.description.title")
                                paragraph("about.description.body")
                                paragraph("about.description.free")
                                paragraph("about.description.support")
                            }
                        }

                        PaperSectionCard {
                            VStack(alignment: .leading, spacing: 6) {
                                heading("about.howToPlay.title")
                                paragraph("about.howToPlay.chooseDifficulty")
                                paragraph("about.howToPlay.dokushin")
                                paragraph("about.howToPlay.points")
                                paragraph("about.howToPlay.saved")
                            }
                        }

                        PaperSectionCard {
                            VStack(alignment: .leading, spacing: 6) {
                                paragraph("about.closing")
                                paragraph("about.contact")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(loc("about.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(loc("about.close"))
                            .textStyle(size: bodyFontSize)
                    }
                }
            }
        }
    }

    private func heading(_ key: String, size: CGFloat? = nil) -> some View {
        Text(loc(key))
            .textStyle(size: size ?? headingFontSize)
            .fontWeight(.semibold)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    private func paragraph(_ key: String) -> some View {
        Text(loc(key))
            .textStyle(size: bodyFontSize)
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
    }
}
