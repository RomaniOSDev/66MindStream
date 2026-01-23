//
//  HomeView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dataService = DataService.shared
    @State private var showLogEntry = false
    @State private var selectedEntryType: EntryType? = nil
    @State private var animateStats = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#1A2C38"),
                    Color(hex: "#0F1A23")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    headerSection
                    
                    // Today's stats
                    todayStatsSection
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Weekly progress
                    weeklyProgressSection
                    
                    // Recent achievements
                    achievementsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showLogEntry, onDismiss: {
            selectedEntryType = nil
        }) {
            LogEntryView(initialType: selectedEntryType)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateStats = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(greeting)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Your mindful garden")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Settings button
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Today's Stats Section
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                // Focus card
                StatCard(
                    title: "Focus",
                    value: "\(todayFocusCount)",
                    icon: "leaf.fill",
                    color: Color(hex: "#16FF16"),
                    animate: animateStats
                )
                
                // Noise card
                StatCard(
                    title: "Noise",
                    value: "\(todayNoiseCount)",
                    icon: "waveform",
                    color: Color(hex: "#1475E1"),
                    animate: animateStats
                )
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                QuickActionButton(
                    title: "Add Focus",
                    icon: "leaf.fill",
                    color: Color(hex: "#16FF16")
                ) {
                    selectedEntryType = .focus
                    showLogEntry = true
                }
                
                QuickActionButton(
                    title: "Add Noise",
                    icon: "waveform",
                    color: Color(hex: "#1475E1")
                ) {
                    selectedEntryType = .noise
                    showLogEntry = true
                }
            }
        }
    }
    
    // MARK: - Weekly Progress Section
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("This Week")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            let ratio = dataService.getFocusNoiseRatio(for: Date())
            let total = ratio.focus + ratio.noise
            let focusPercentage = total > 0 ? Double(ratio.focus) / Double(total) : 0.0
            
            VStack(spacing: 10) {
                HStack {
                    Text("Focus Balance")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(focusPercentage * 100))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#16FF16"))
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#16FF16"),
                                        Color(hex: "#12CC12")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * focusPercentage, height: 12)
                            .shadow(color: Color(hex: "#16FF16").opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 12)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Achievements")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            if dataService.achievements.isEmpty {
                Text("Complete challenges to unlock achievements!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(dataService.achievements.suffix(3)) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good Morning"
        } else if hour < 18 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
        }
    }
    
    private var todayFocusCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dataService.getEntries(for: today).filter { $0.type == .focus }.count
    }
    
    private var todayNoiseCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dataService.getEntries(for: today).filter { $0.type == .noise }.count
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animate: Bool
    
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(scale)
        .onAppear {
            if animate {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                    scale = 1.0
                }
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "star.fill")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "#FFD700"))
            
            Text(achievement.type.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let date = achievement.unlockedDate {
                Text(formattedDate(date))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(width: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#FFD700").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
}
