//
//  GardenViewModel.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation
import SwiftUI
import Combine

class GardenViewModel: ObservableObject {
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        updateGardenElements()
        dataService.objectWillChange.sink { [weak self] _ in
            self?.updateGardenElements()
        }.store(in: &cancellables)
    }
    
    @Published private(set) var gardenElements: [GardenElement] = []
    @Published var killedBugs: Set<UUID> = []
    private var previousEntryCount = 0
    
    func updateGardenElements() {
        var elements: [GardenElement] = []
        
        // Group all entries by day
        let allEntries = dataService.entries
        let groupedByDay = Dictionary(grouping: allEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        
        // Sort days chronologically (newest first)
        let sortedDays = groupedByDay.keys.sorted(by: >)
        let totalDays = sortedDays.count
        
        // Use vertical band that не заходит под таб-бар и не прижимает кверху
        let minY: CGFloat = 0.30   // верхняя граница сада
        let maxY: CGFloat = 0.78   // нижняя граница сада (чуть выше забора/таб-бара)
        let availableHeight = maxY - minY
        
        // Create elements organized by days (like garden rows)
        for (dayIndex, date) in sortedDays.enumerated() {
            guard let dayEntries = groupedByDay[date] else { continue }
            
            let focusEntries = dayEntries.filter { $0.type == .focus }
            let noiseEntries = dayEntries.filter { $0.type == .noise }
            
            // Calculate row position - evenly distribute across full height
            let normalizedRowY: CGFloat
            if totalDays <= 1 {
                normalizedRowY = 0.5 // Center if only one day
            } else {
                // Distribute evenly from top to bottom
                normalizedRowY = minY + (availableHeight * CGFloat(dayIndex) / CGFloat(max(totalDays - 1, 1)))
            }
            
            // Create plants for this day
            let plantsCount = max(1, focusEntries.count / 2)
            // Limit plants per row to prevent overflow
            let maxPlantsPerRow = 3
            let actualPlantsCount = min(plantsCount, maxPlantsPerRow)
            
            for plantIndex in 0..<actualPlantsCount {
                // Distribute plants evenly across available width (0.15 to 0.85)
                let availableWidth = 0.7 // 0.85 - 0.15
                let spacing = actualPlantsCount > 1 ? availableWidth / CGFloat(actualPlantsCount - 1) : 0
                let plantX = 0.15 + (CGFloat(plantIndex) * spacing)
                let position = CGPoint(
                    x: max(0.15, min(plantX, 0.85)),
                    y: normalizedRowY
                )
                
                let dateString = String(format: "%.0f", date.timeIntervalSince1970)
                let stableID = generateStableUUID(from: "plant-\(dateString)-\(plantIndex)")
                
                let baseSize = CGFloat(focusEntries.count) / 4.0
                let size = max(0.8, min(baseSize, 1.5))
                
                elements.append(.plant(
                    id: stableID,
                    position: position,
                    size: size
                ))
            }
            
            // Create streams for this day (positioned between plants)
            let streamsCount = max(1, noiseEntries.count)
            // Limit streams per row
            let maxStreamsPerRow = 3
            let actualStreamsCount = min(streamsCount, maxStreamsPerRow)
            
            for streamIndex in 0..<actualStreamsCount {
                // Distribute streams evenly across available width
                let availableWidth = 0.7
                let spacing = actualStreamsCount > 1 ? availableWidth / CGFloat(actualStreamsCount - 1) : 0
                let streamX = 0.15 + (CGFloat(streamIndex) * spacing) + 0.1 // Offset slightly from plants
                let position = CGPoint(
                    x: max(0.15, min(streamX, 0.85)),
                    y: normalizedRowY + 0.03 // Slightly below plants
                )
                
                let intensity = CGFloat(noiseEntries.reduce(0) { $0 + ($1.intensity ?? 1) }) / CGFloat(noiseEntries.count)
                let dateString = String(format: "%.0f", date.timeIntervalSince1970)
                let stableID = generateStableUUID(from: "stream-\(dateString)-\(streamIndex)")
                
                let normalizedIntensity = max(0.8, min(intensity / 2.5, 1.5))
                
                elements.append(.stream(
                    id: stableID,
                    position: position,
                    intensity: normalizedIntensity
                ))
            }
        }
        
        // Add decorative elements
        addDecorativeElements(to: &elements)
        
        // Add bugs (appear when there's too much noise)
        addBugs(to: &elements)
        
        let hasNewEntries = dataService.entries.count > previousEntryCount
        previousEntryCount = dataService.entries.count
        
        gardenElements = elements
        
        // Explicitly trigger update
        objectWillChange.send()
    }
    
    func killBug(_ bugId: UUID) {
        killedBugs.insert(bugId)
        objectWillChange.send()
    }
    
    private func addDecorativeElements(to elements: inout [GardenElement]) {
        let totalEntries = dataService.entries.count
        
        // Add stones (appear after 5 entries)
        if totalEntries >= 5 {
            let stonesCount = min(3, totalEntries / 5)
            for i in 0..<stonesCount {
                let stoneX = 0.15 + CGFloat(i) * 0.3
                let stoneY = 0.75 - CGFloat(i) * 0.05 // Keep above fence
                let position = CGPoint(
                    x: max(0.15, min(stoneX, 0.85)),
                    y: max(0.3, min(stoneY, 0.75))
                )
                let size = CGFloat.random(in: 0.3...0.5)
                
                let stableID = generateStableUUID(from: "stone-\(i)")
                elements.append(.stone(id: stableID, position: position, size: size))
            }
        }
        
        // Add butterflies (appear when focus balance is good)
        let focusCount = dataService.entries.filter { $0.type == .focus }.count
        let totalCount = dataService.entries.count
        if totalCount > 0 {
            let focusRatio = Double(focusCount) / Double(totalCount)
            if focusRatio >= 0.6 && totalEntries >= 10 {
                let butterfliesCount = min(2, Int(focusRatio * 3))
                for i in 0..<butterfliesCount {
                    let butterflyX = 0.2 + CGFloat(i) * 0.5
                    let butterflyY = 0.35 + CGFloat(i) * 0.15
                    let position = CGPoint(
                        x: max(0.2, min(butterflyX, 0.8)),
                        y: max(0.35, min(butterflyY, 0.7))
                    )
                    
                    let stableID = generateStableUUID(from: "butterfly-\(i)")
                    elements.append(.butterfly(id: stableID, position: position))
                }
            }
        }
        
        // Add paths between rows (if we have multiple days)
        let groupedByDay = Dictionary(grouping: dataService.entries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        let daysCount = groupedByDay.keys.count
        if daysCount >= 2 {
            for dayIndex in 0..<(daysCount - 1) {
                let pathY = 0.275 + (CGFloat(dayIndex) * 0.15)
                let position = CGPoint(x: 0.5, y: pathY)
                
                let stableID = generateStableUUID(from: "path-\(dayIndex)")
                elements.append(.path(id: stableID, position: position, length: 0.6))
            }
        }
        
        // Add soil patches under plants
        let plants = elements.filter { if case .plant = $0 { return true }; return false }
        for plant in plants.prefix(5) {
            if case .plant(_, let position, let size) = plant {
                let soilPosition = CGPoint(x: position.x, y: position.y + 0.05)
                let soilWidth = 0.15 * size
                
                let stableID = generateStableUUID(from: "soil-\(plant.id)")
                elements.append(.soil(id: stableID, position: soilPosition, width: soilWidth))
            }
        }
    }
    
    private func addBugs(to elements: inout [GardenElement]) {
        let noiseEntries = dataService.entries.filter { $0.type == .noise }
        let totalEntries = dataService.entries.count
        
        // Bugs appear when noise ratio is high
        if totalEntries > 0 {
            let noiseRatio = Double(noiseEntries.count) / Double(totalEntries)
            
            // Add bugs if noise ratio > 40%
            if noiseRatio > 0.4 {
                let bugsCount = min(5, Int(noiseRatio * 8))
                
                for i in 0..<bugsCount {
                    // Random position within safe bounds
                    let bugX = 0.2 + CGFloat(i % 3) * 0.25
                    let bugY = 0.4 + CGFloat(i / 3) * 0.15
                    
                    let position = CGPoint(
                        x: max(0.2, min(bugX, 0.8)),
                        y: max(0.4, min(bugY, 0.75))
                    )
                    
                    let bugType = BugType.allCases[i % BugType.allCases.count]
                    let stableID = generateStableUUID(from: "bug-\(i)-\(noiseEntries.count)")
                    
                    // Only add if not already killed
                    if !killedBugs.contains(stableID) {
                        elements.append(.bug(id: stableID, position: position, bugType: bugType))
                    }
                }
            }
        }
    }
    
    // This function is kept for backward compatibility but not used in new logic
    private func calculatePosition(for index: Int, total: Int) -> CGPoint {
        guard total > 0 else {
            return CGPoint(x: 0.5, y: 0.5)
        }
        
        // Use grid-based distribution
        let columns = max(3, Int(sqrt(Double(total))) + 1)
        let col = index % columns
        let row = index / columns
        
        let horizontalSpacing: CGFloat = 0.7 / CGFloat(max(columns - 1, 1))
        let verticalSpacing: CGFloat = 0.6 / CGFloat(max((total + columns - 1) / columns - 1, 1))
        
        let x = 0.15 + CGFloat(col) * horizontalSpacing
        let y = 0.2 + CGFloat(row) * verticalSpacing
        
        return CGPoint(
            x: max(0.15, min(x, 0.85)),
            y: max(0.2, min(y, 0.8))
        )
    }
    
    private func generateStableUUID(from string: String) -> UUID {
        // Generate a deterministic UUID from a string
        var hash = string.hashValue
        var uuidBytes = [UInt8](repeating: 0, count: 16)
        
        for i in 0..<16 {
            uuidBytes[i] = UInt8((hash >> (i * 2)) & 0xFF)
            hash = hash.multipliedReportingOverflow(by: 31).partialValue
        }
        
        // Set version (4) and variant bits
        uuidBytes[6] = (uuidBytes[6] & 0x0F) | 0x40
        uuidBytes[8] = (uuidBytes[8] & 0x3F) | 0x80
        
        let uuidString = String(format: "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
                                uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
                                uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
                                uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
                                uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15])
        
        return UUID(uuidString: uuidString) ?? UUID()
    }
}

enum GardenElement: Identifiable, Equatable {
    case plant(id: UUID, position: CGPoint, size: CGFloat)
    case stream(id: UUID, position: CGPoint, intensity: CGFloat)
    case stone(id: UUID, position: CGPoint, size: CGFloat)
    case butterfly(id: UUID, position: CGPoint)
    case path(id: UUID, position: CGPoint, length: CGFloat)
    case soil(id: UUID, position: CGPoint, width: CGFloat)
    case bug(id: UUID, position: CGPoint, bugType: BugType)
    
    var id: UUID {
        switch self {
        case .plant(let id, _, _), .stream(let id, _, _), .stone(let id, _, _), 
             .butterfly(let id, _), .path(let id, _, _), .soil(let id, _, _),
             .bug(let id, _, _):
            return id
        }
    }
    
    static func == (lhs: GardenElement, rhs: GardenElement) -> Bool {
        lhs.id == rhs.id
    }
}

enum BugType: String, CaseIterable {
    case fly = "Fly"
    case beetle = "Beetle"
    case ant = "Ant"
    case spider = "Spider"
}
