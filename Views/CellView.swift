//  CellView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import SwiftUI

struct CellView: View {
    let cell: Cell

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(cell.isSelected ? Color.yellow.opacity(0.4) : Color.gray.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                )

            Text(cell.value == 0 ? "" : "\(cell.value)")
                .font(.system(size: 18, weight: cell.isEditable ? .regular : .bold))
                .foregroundColor(cell.isEditable ? .blue : .black)
        }
        .frame(width: 36, height: 36)
    }
}
