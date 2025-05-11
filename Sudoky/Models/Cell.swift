//  Cell.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import Foundation

struct Cell: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var row: Int
    var col: Int
    var value: Int         // От 1 до 9, 0 если пусто
    var isEditable: Bool   // Можно ли редактировать (false для исходной доски)
    var isSelected: Bool   // Подсвечена ли ячейка
    var hasError: Bool = false
    var notes: [Int] = []

    enum CodingKeys: String, CodingKey {
        case id, row, col, value, isEditable, isSelected, hasError, notes
    }

    init(id: UUID = UUID(), row: Int, col: Int, value: Int, isEditable: Bool, isSelected: Bool, hasError: Bool = false, notes: [Int] = []) {
        self.id = id
        self.row = row
        self.col = col
        self.value = value
        self.isEditable = isEditable
        self.isSelected = isSelected
        self.hasError = hasError
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        row = try container.decode(Int.self, forKey: .row)
        col = try container.decode(Int.self, forKey: .col)
        value = try container.decode(Int.self, forKey: .value)
        isEditable = try container.decode(Bool.self, forKey: .isEditable)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
        hasError = try container.decodeIfPresent(Bool.self, forKey: .hasError) ?? false
        notes = try container.decodeIfPresent([Int].self, forKey: .notes) ?? []
    }
}
