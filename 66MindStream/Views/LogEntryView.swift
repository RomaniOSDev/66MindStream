//
//  LogEntryView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct LogEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = LogEntryViewModel()
    @State private var selectedType: EntryType?
    var initialType: EntryType? = nil
    
    var body: some View {
        ZStack {
            Color(hex: "#1A2C38")
                .ignoresSafeArea()
            
            if currentType == nil {
                // Selection screen
                VStack(spacing: 30) {
                    Text("Add Entry")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Noise card
                    EntryTypeCard(
                        title: "Noise Stream",
                        subtitle: "I feel digital overload",
                        icon: "waveform",
                        color: Color(hex: "#1475E1")
                    ) {
                        selectedType = .noise
                    }
                    
                    // Focus card
                    EntryTypeCard(
                        title: "Focus Sprout",
                        subtitle: "I was focused and present",
                        icon: "leaf.fill",
                        color: Color(hex: "#16FF16")
                    ) {
                        selectedType = .focus
                    }
                    
                    Spacer()
                }
                .padding()
            } else if currentType == .noise {
                NoiseEntryForm(viewModel: viewModel) {
                    dismiss()
                }
            } else if currentType == .focus {
                FocusEntryForm(viewModel: viewModel) {
                    dismiss()
                }
            }
        }
        .onAppear {
            if let initial = initialType {
                selectedType = initial
            }
        }
    }
    
    private var currentType: EntryType? {
        selectedType ?? initialType
    }
}

struct EntryTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(color.opacity(0.2))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: 2)
            )
        }
    }
}

struct NoiseEntryForm: View {
    @ObservedObject var viewModel: LogEntryViewModel
    let onSave: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Noise Stream")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // What distracted?
                VStack(alignment: .leading, spacing: 10) {
                    Text("What distracted you?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Picker("Source", selection: $viewModel.selectedNoiseSource) {
                        ForEach(NoiseSource.allCases, id: \.self) { source in
                            Text(source.rawValue).tag(source)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                }
                
                // Intensity
                VStack(alignment: .leading, spacing: 10) {
                    Text("How intense? \(Int(viewModel.noiseIntensity))")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Slider(value: $viewModel.noiseIntensity, in: 1...5, step: 1)
                        .tint(Color(hex: "#1475E1"))
                }
                
                // Comment
                VStack(alignment: .leading, spacing: 10) {
                    Text("Comment (optional)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    TextField("", text: $viewModel.noiseComment, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                // Save button
                Button(action: {
                    viewModel.saveNoiseEntry()
                    onSave()
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#1475E1"))
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

struct FocusEntryForm: View {
    @ObservedObject var viewModel: LogEntryViewModel
    let onSave: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Focus Sprout")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // What focused on?
                VStack(alignment: .leading, spacing: 10) {
                    Text("What were you focused on?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Picker("Category", selection: $viewModel.selectedFocusCategory) {
                        ForEach(FocusCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                }
                
                // Duration
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Picker("Duration", selection: $viewModel.selectedDuration) {
                        ForEach(FocusDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                }
                
                // What helped?
                VStack(alignment: .leading, spacing: 10) {
                    Text("What helped? (optional)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ForEach(viewModel.helpedByChoices, id: \.self) { choice in
                        Toggle(choice, isOn: Binding(
                            get: { viewModel.helpedByOptions.contains(choice) },
                            set: { isOn in
                                if isOn {
                                    viewModel.helpedByOptions.insert(choice)
                                } else {
                                    viewModel.helpedByOptions.remove(choice)
                                }
                            }
                        ))
                        .tint(Color(hex: "#16FF16"))
                        .foregroundColor(.white)
                    }
                }
                
                // Comment
                VStack(alignment: .leading, spacing: 10) {
                    Text("Comment (optional)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    TextField("", text: $viewModel.focusComment, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                // Save button
                Button(action: {
                    viewModel.saveFocusEntry()
                    onSave()
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A2C38"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#16FF16"))
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

#Preview {
    LogEntryView()
}
