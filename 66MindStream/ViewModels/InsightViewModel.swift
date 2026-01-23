//
//  InsightViewModel.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation
import Combine
import SwiftUI

class InsightViewModel: ObservableObject {
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        dataService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    @Published var selectedDate: Date = Date()
    
    var weekData: [(date: Date, focus: Int, noise: Int)] {
        let calendar = Calendar.current
        var weekData: [(date: Date, focus: Int, noise: Int)] = []
        
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return []
        }
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                continue
            }
            let entries = dataService.getEntries(for: date)
            let focus = entries.filter { $0.type == .focus }.count
            let noise = entries.filter { $0.type == .noise }.count
            weekData.append((date: date, focus: focus, noise: noise))
        }
        
        return weekData
    }
    
    var insights: [String] {
        var insights: [String] = []
        
        // Analyze noise patterns
        let noiseEntries = dataService.entries.filter { $0.type == .noise }
        if !noiseEntries.isEmpty {
            let groupedBySource = Dictionary(grouping: noiseEntries) { $0.noiseSource }
            if let mostCommon = groupedBySource.max(by: { $0.value.count < $1.value.count }) {
                let hourGroups = Dictionary(grouping: mostCommon.value) { entry in
                    Calendar.current.component(.hour, from: entry.date)
                }
                if let peakHour = hourGroups.max(by: { $0.value.count < $1.value.count }) {
                    insights.append("You're most distracted by \(mostCommon.key?.rawValue ?? "unknown") after \(peakHour.key):00.")
                }
            }
        }
        
        // Analyze focus patterns
        let focusEntries = dataService.entries.filter { $0.type == .focus }
        if !focusEntries.isEmpty {
            let longSessions = focusEntries.filter { $0.duration == .oneHourPlus }
            if !longSessions.isEmpty {
                let hourGroups = Dictionary(grouping: longSessions) { entry in
                    Calendar.current.component(.hour, from: entry.date)
                }
                if let bestHour = hourGroups.max(by: { $0.value.count < $1.value.count }) {
                    insights.append("Your best focus sessions (1h+) happen around \(bestHour.key):00.")
                }
            }
        }
        
        // Week balance
        let ratio = dataService.getFocusNoiseRatio(for: Date())
        let total = ratio.focus + ratio.noise
        if total > 0 {
            let focusPercentage = Int((Double(ratio.focus) / Double(total)) * 100)
            let noisePercentage = 100 - focusPercentage
            insights.append("This week's balance: \(focusPercentage)% focus, \(noisePercentage)% noise. \(focusPercentage >= 65 ? "Great week!" : "Keep going!")")
        }
        
        return insights.isEmpty ? ["Start logging to see insights!"] : insights
    }
    
    func getDayColor(for date: Date) -> Color? {
        let entries = dataService.getEntries(for: date)
        let hasFocus = entries.contains { $0.type == .focus }
        let hasNoise = entries.contains { $0.type == .noise }
        
        if hasFocus && hasNoise {
            return Color(hex: "#16FF16").opacity(0.7) // Mixed
        } else if hasFocus {
            return Color(hex: "#16FF16")
        } else if hasNoise {
            return Color(hex: "#1475E1")
        }
        return nil
    }
    
    func getDominantType(for date: Date) -> DayDominantType? {
        let entries = dataService.getEntries(for: date)
        
        guard !entries.isEmpty else {
            return nil
        }
        
        let focusCount = entries.filter { $0.type == .focus }.count
        let noiseCount = entries.filter { $0.type == .noise }.count
        
        // If only one type exists
        if focusCount > 0 && noiseCount == 0 {
            return .focus
        }
        if noiseCount > 0 && focusCount == 0 {
            return .noise
        }
        
        // If both types exist, determine dominant
        if focusCount > noiseCount {
            return .focus
        } else if noiseCount > focusCount {
            return .noise
        } else {
            // Equal counts
            return .balanced
        }
    }
}
