//
//  DecorativeElements.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

// MARK: - Stone View
struct StoneView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Stone shape
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.6),
                            Color.gray.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20 * size, height: 15 * size)
                .overlay(
                    Ellipse()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Highlights
            Ellipse()
                .fill(Color.white.opacity(0.2))
                .frame(width: 8 * size, height: 6 * size)
                .offset(x: -3 * size, y: -2 * size)
        }
    }
}

// MARK: - Butterfly View
struct ButterflyView: View {
    @State private var wingFlap: CGFloat = 0
    @State private var position: CGPoint = .zero
    
    var body: some View {
        ZStack {
            // Left wing
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#FFD700").opacity(0.8),
                            Color(hex: "#FFA500").opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 12)
                .rotationEffect(.degrees(-20.0 + Double(wingFlap) * 10.0))
                .offset(x: -4, y: 0)
            
            // Right wing
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#FFD700").opacity(0.8),
                            Color(hex: "#FFA500").opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 12)
                .rotationEffect(.degrees(20.0 - Double(wingFlap) * 10.0))
                .offset(x: 4, y: 0)
            
            // Body
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#1A2C38"))
                .frame(width: 3, height: 10)
        }
        .shadow(color: Color(hex: "#FFD700").opacity(0.3), radius: 4, x: 0, y: 2)
        .onAppear {
            // Wing flapping animation
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                wingFlap = 1.0
            }
            
            // Floating animation
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                position = CGPoint(x: 10, y: -5)
            }
        }
        .offset(x: position.x, y: position.y)
    }
}

// MARK: - Path View
struct PathView: View {
    let length: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [
                        Color.brown.opacity(0.4),
                        Color.brown.opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: length * 200, height: 3)
            .shadow(color: Color.brown.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Soil View
struct SoilView: View {
    let width: CGFloat
    
    var body: some View {
        ZStack {
            // Soil patch
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.brown.opacity(0.3),
                            Color.brown.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: width * 50
                    )
                )
                .frame(width: width * 100, height: width * 60)
            
            // Texture dots
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Color.brown.opacity(0.2))
                    .frame(width: 2, height: 2)
                    .offset(
                        x: CGFloat(index - 2) * width * 8,
                        y: CGFloat(index % 2 == 0 ? 1 : -1) * width * 6
                    )
            }
        }
    }
}

// MARK: - Fence View
struct FenceView: View {
    let postCount: Int
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing = width / CGFloat(max(postCount - 1, 1))
            
            ZStack(alignment: .bottomLeading) {
                // Horizontal rails
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.brown.opacity(0.7),
                                    Color.brown.opacity(0.5)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.brown.opacity(0.8),
                                    Color.brown.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 4)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .offset(y: -8)
                
                // Vertical posts
                HStack(spacing: spacing) {
                    ForEach(0..<postCount, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.brown.opacity(0.9),
                                        Color.brown.opacity(0.6)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 8, height: height)
                            .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "#1A2C38")
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            StoneView(size: 0.5)
            ButterflyView()
            PathView(length: 0.6)
            SoilView(width: 0.3)
            FenceView(postCount: 7)
        }
    }
}
