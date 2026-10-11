//
//  BackgroundView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.

import SwiftUI

struct BackgroundView: View {
    private static let imageNames = ["background1", "background2", "background3", "background4", "background5"]

    @State private var imageName: String
    @State private var hasAppeared = false

    init() {
        _imageName = State(initialValue: Self.imageNames.randomElement() ?? "background1")
    }
    
    var body: some View {
        GeometryReader { geo in
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .ignoresSafeArea()
                .onAppear {
                    if hasAppeared {
                        imageName = Self.imageNames.randomElement() ?? imageName
                    }
                    hasAppeared = true
                }
        }
    }
}
