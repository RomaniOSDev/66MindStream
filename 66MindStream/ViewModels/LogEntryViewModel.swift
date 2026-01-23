//
//  LogEntryViewModel.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import Foundation
import Combine

class LogEntryViewModel: ObservableObject {
    private var dataService = DataService.shared
    
    // Noise entry fields
    @Published var selectedNoiseSource: NoiseSource = .socialMedia
    @Published var noiseIntensity: Double = 3.0
    @Published var noiseComment: String = ""
    
    // Focus entry fields
    @Published var selectedFocusCategory: FocusCategory = .workStudy
    @Published var selectedDuration: FocusDuration = .fifteenMinutes
    @Published var helpedByOptions: Set<String> = []
    @Published var focusComment: String = ""
    
    let helpedByChoices = ["Turned off notifications", "Set timer", "Quiet space", "Music"]
    
    func saveNoiseEntry() {
        let entry = LogEntry(
            type: .noise,
            noiseSource: selectedNoiseSource,
            intensity: Int(noiseIntensity),
            comment: noiseComment.isEmpty ? nil : noiseComment
        )
        dataService.addEntry(entry)
        resetNoiseFields()
    }
    
    func saveFocusEntry() {
        let entry = LogEntry(
            type: .focus,
            focusCategory: selectedFocusCategory,
            duration: selectedDuration,
            helpedBy: helpedByOptions.isEmpty ? nil : Array(helpedByOptions),
            comment: focusComment.isEmpty ? nil : focusComment
        )
        dataService.addEntry(entry)
        resetFocusFields()
    }
    
    private func resetNoiseFields() {
        selectedNoiseSource = .socialMedia
        noiseIntensity = 3.0
        noiseComment = ""
    }
    
    private func resetFocusFields() {
        selectedFocusCategory = .workStudy
        selectedDuration = .fifteenMinutes
        helpedByOptions = []
        focusComment = ""
    }
}
