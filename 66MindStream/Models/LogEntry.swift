//
//  LogEntry.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation

enum EntryType: String, Codable {
    case noise = "noise"
    case focus = "focus"
}

enum NoiseSource: String, Codable, CaseIterable {
    case socialMedia = "Social Media"
    case news = "News"
    case notifications = "Notifications"
    case aimlessSearch = "Aimless Search"
    case other = "Other"
}

enum FocusCategory: String, Codable, CaseIterable {
    case workStudy = "Work/Study"
    case reading = "Reading"
    case creativity = "Creativity"
    case conversation = "Conversation"
    case screenFreeRest = "Screen-Free Rest"
}

enum FocusDuration: String, Codable, CaseIterable {
    case fifteenMinutes = "15 min"
    case thirtyMinutes = "30 min"
    case oneHourPlus = "1h+"
    case notImportant = "Not Important"
}

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let type: EntryType
    let date: Date
    
    // Noise fields
    var noiseSource: NoiseSource?
    var intensity: Int? // 1-5
    
    // Focus fields
    var focusCategory: FocusCategory?
    var duration: FocusDuration?
    var helpedBy: [String]? // ["Turned off notifications", "Set timer"]
    
    // Common
    var comment: String?
    
    init(
        id: UUID = UUID(),
        type: EntryType,
        date: Date = Date(),
        noiseSource: NoiseSource? = nil,
        intensity: Int? = nil,
        focusCategory: FocusCategory? = nil,
        duration: FocusDuration? = nil,
        helpedBy: [String]? = nil,
        comment: String? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.noiseSource = noiseSource
        self.intensity = intensity
        self.focusCategory = focusCategory
        self.duration = duration
        self.helpedBy = helpedBy
        self.comment = comment
    }
}
