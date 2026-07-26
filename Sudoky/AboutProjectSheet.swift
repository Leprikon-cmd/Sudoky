//
//  AboutProjectSheet.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 03.06.2025.
//
//  Показывает информацию об авторах и игре

import SwiftUI

struct AboutProjectSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        let _ = languageManager.language
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text(loc("about.appName"))
                            .font(.title2.bold())

                        Text(loc("about.author"))

                        Text(loc("about.acknowledgements"))
                        Text(loc("about.thanks.natasha"))
                        Text(loc("about.thanks.composer"))
                        Text(loc("about.thanks.fox"))
                        Text(loc("about.thanks.testers"))

                        Text(loc("about.aiTeam"))
                        Text(loc("about.ai.chatgpt"))
                        Text(loc("about.ai.shedevrum"))
                        Text(loc("about.ai.deepseek"))

                        Text(loc("about.description.title"))
                        Text(loc("about.description.body"))
                        Text(loc("about.description.free"))
                        Text(loc("about.description.support"))
                    }

                    Divider()

                    Group {
                        Text(loc("about.howToPlay.title"))
                            .font(.title3.bold())

                        Text(loc("about.howToPlay.chooseDifficulty"))
                        Text(loc("about.howToPlay.dokushin"))
                        Text(loc("about.howToPlay.points"))
                        Text(loc("about.howToPlay.saved"))

                        Text(loc("about.closing"))
                        
                        Text(loc("about.contact"))
                    }
                }
                .padding()
                .textStyle(size: 16)
            }
            .navigationTitle(loc("about.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc("about.close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
