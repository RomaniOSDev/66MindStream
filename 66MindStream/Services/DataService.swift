//
//  DataService.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var entries: [LogEntry] = []
    @Published var plants: [Plant] = []
    @Published var achievements: [Achievement] = []
    
    private let entriesKey = "MindStream_Entries"
    private let plantsKey = "MindStream_Plants"
    private let achievementsKey = "MindStream_Achievements"
    
    private init() {
        loadData()
        initializeDefaultPlants()
    }
    
    // MARK: - Data Persistence
    
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    func savePlants() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: plantsKey)
        }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadData() {
        // Load entries
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([LogEntry].self, from: data) {
            entries = decoded
        }
        
        // Load plants
        if let data = UserDefaults.standard.data(forKey: plantsKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        }
        
        // Load achievements
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
    }
    
    // MARK: - Entries Management
    
    func addEntry(_ entry: LogEntry) {
        entries.append(entry)
        saveEntries()
        checkAchievements()
        // Explicitly trigger update
        objectWillChange.send()
    }
    
    func getEntries(for date: Date) -> [LogEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getWeekEntries(for week: Date) -> [LogEntry] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week) else {
            return []
        }
        return entries.filter { weekInterval.contains($0.date) }
    }
    
    // MARK: - Statistics
    
    func getFocusNoiseRatio(for week: Date) -> (focus: Int, noise: Int) {
        let weekEntries = getWeekEntries(for: week)
        let focusCount = weekEntries.filter { $0.type == .focus }.count
        let noiseCount = weekEntries.filter { $0.type == .noise }.count
        return (focusCount, noiseCount)
    }
    
    func getStreakDays() -> Int {
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date > $1.date }
        
        guard !sortedEntries.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            if entryDate == currentDate {
                if !calendar.isDate(currentDate, inSameDayAs: Date()) || streak == 0 {
                    streak += 1
                }
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if entryDate < currentDate {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Plants & Achievements
    
    private func initializeDefaultPlants() {
        if plants.isEmpty {
            plants = [
                Plant(name: "First Sprout", description: "Your journey begins", achievementType: .sevenDaysStreak),
                Plant(name: "Balance Bloom", description: "Finding harmony", achievementType: .weekBalance70),
                Plant(name: "Deep Root", description: "Master of focus", achievementType: .tenLongSessions)
            ]
            savePlants()
        }
    }
    
    private func checkAchievements() {
        let streak = getStreakDays()
        if streak >= 7 {
            unlockAchievement(.sevenDaysStreak)
        }
        
        // Check week balance
        let weekEntries = getWeekEntries(for: Date())
        let ratio = getFocusNoiseRatio(for: Date())
        let total = ratio.focus + ratio.noise
        if total > 0 {
            let focusPercentage = Double(ratio.focus) / Double(total) * 100
            if focusPercentage >= 70 {
                unlockAchievement(.weekBalance70)
            }
        }
        
        // Check long sessions
        let longSessions = entries.filter { entry in
            entry.type == .focus && entry.duration == .oneHourPlus
        }
        if longSessions.count >= 10 {
            unlockAchievement(.tenLongSessions)
        }
    }
    
    private func unlockAchievement(_ type: AchievementType) {
        if !achievements.contains(where: { $0.type == type }) {
            let achievement = Achievement(type: type, unlockedDate: Date())
            achievements.append(achievement)
            
            // Unlock corresponding plant
            if let index = plants.firstIndex(where: { $0.achievementType == type && !$0.isUnlocked }) {
                plants[index] = Plant(
                    id: plants[index].id,
                    name: plants[index].name,
                    description: plants[index].description,
                    achievementType: plants[index].achievementType,
                    isUnlocked: true
                )
                savePlants()
            }
            
            saveAchievements()
        }
    }
}
