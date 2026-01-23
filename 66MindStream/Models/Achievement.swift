//
//  Achievement.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    let unlockedDate: Date?
    
    init(
        id: UUID = UUID(),
        type: AchievementType,
        unlockedDate: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.unlockedDate = unlockedDate
    }
}
