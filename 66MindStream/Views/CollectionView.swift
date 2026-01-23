//
//  CollectionView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "#1A2C38")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("Plant Collection")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Unlocked plants
                    if !viewModel.unlockedPlants.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Unlocked")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                ForEach(viewModel.unlockedPlants) { plant in
                                    PlantCard(plant: plant, isUnlocked: true)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Locked plants
                    if !viewModel.lockedPlants.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Locked")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                ForEach(viewModel.lockedPlants) { plant in
                                    PlantCard(plant: plant, isUnlocked: false)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    if viewModel.unlockedPlants.isEmpty && viewModel.lockedPlants.isEmpty {
                        Text("No plants available")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    }
                }
            }
        }
    }
}

struct PlantCard: View {
    let plant: Plant
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Plant animation
            ZStack {
                if isUnlocked {
                    CollectionPlantAnimationView()
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(height: 120)
            
            VStack(spacing: 5) {
                Text(plant.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))
                
                Text(plant.description)
                    .font(.system(size: 14))
                    .foregroundColor(isUnlocked ? .white.opacity(0.7) : .white.opacity(0.3))
                    .multilineTextAlignment(.center)
                
                if !isUnlocked {
                    Text(achievementRequirement)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 5)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isUnlocked ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isUnlocked ? Color(hex: "#16FF16").opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var achievementRequirement: String {
        switch plant.achievementType {
        case .sevenDaysStreak:
            return "Unlock: 7 days streak"
        case .weekBalance70:
            return "Unlock: 70% focus week"
        case .tenLongSessions:
            return "Unlock: 10 long sessions"
        }
    }
}

struct CollectionPlantAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Stem
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#16FF16"))
                .frame(width: 4, height: 30)
            
            // Leaves
            ForEach(0..<4, id: \.self) { index in
                Ellipse()
                    .fill(Color(hex: "#16FF16"))
                    .frame(width: 16, height: 12)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(y: -15)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
            
            // Flower
            Circle()
                .fill(Color(hex: "#16FF16").opacity(0.8))
                .frame(width: 12, height: 12)
                .offset(y: -20)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    CollectionView()
}
