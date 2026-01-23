//
//  OnboardingView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
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
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        title: "Welcome to Mind Stream",
                        description: "Track your digital wellbeing and grow your mindful garden",
                        icon: "leaf.fill",
                        color: Color(hex: "#16FF16")
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        title: "Focus & Noise",
                        description: "Log your focus moments to grow plants, and track digital noise to understand your patterns",
                        icon: "waveform",
                        color: Color(hex: "#1475E1")
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        title: "Grow Your Garden",
                        description: "Watch your garden flourish as you build mindful habits. Every entry matters.",
                        icon: "sparkles",
                        color: Color(hex: "#FFD700")
                    )
                    .tag(2)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Bottom button
                VStack(spacing: 20) {
                    if currentPage == 2 {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#1A2C38"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "#16FF16"))
                                .cornerRadius(12)
                                .shadow(color: Color(hex: "#16FF16").opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 40)
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(color)
            }
            
            // Text
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
