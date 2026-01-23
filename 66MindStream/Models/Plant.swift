//
//  Plant.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation

struct Plant: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let achievementType: AchievementType
    let isUnlocked: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        achievementType: AchievementType,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.achievementType = achievementType
        self.isUnlocked = isUnlocked
    }
}

enum AchievementType: String, Codable {
    case sevenDaysStreak = "7 Days Streak"
    case weekBalance70 = "Week Balance 70%"
    case tenLongSessions = "10 Long Sessions"
}
