//
//  SettingsView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1A2C38")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Settings sections
                    VStack(spacing: 20) {
                        // Rate Us
                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate Us",
                            color: Color(hex: "#FFD700")
                        ) {
                            rateApp()
                        }
                        
                        // Privacy Policy
                        SettingsRow(
                            icon: "lock.shield.fill",
                            title: "Privacy Policy",
                            color: Color(hex: "#1475E1")
                        ) {
                            openPrivacyPolicy()
                        }
                        
                        // Terms of Service
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            color: Color(hex: "#16FF16")
                        ) {
                            openTermsOfService()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // App info
                    VStack(spacing: 10) {
                        Text("Mind Stream")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Your mindful garden")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 40)
                }
            }
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://example.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://example.com/terms-of-service") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

#Preview {
    SettingsView()
}
