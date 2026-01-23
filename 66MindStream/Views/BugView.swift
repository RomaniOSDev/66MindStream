//
//  BugView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct BugView: View {
    let bugType: BugType
    let onTap: () -> Void
    
    @State private var isAlive = true
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        if isAlive {
            ZStack {
                bugBody
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .offset(x: position.x, y: position.y)
            .onTapGesture {
                killBug()
            }
            .onAppear {
                startMovement()
            }
        }
    }
    
    @ViewBuilder
    private var bugBody: some View {
        switch bugType {
        case .fly:
            FlyView()
        case .beetle:
            BeetleView()
        case .ant:
            AntView()
        case .spider:
            SpiderView()
        }
    }
    
    private func killBug() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 1.5
            opacity = 0.0
            rotation = 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAlive = false
            onTap()
        }
    }
    
    private func startMovement() {
        // Random movement animation
        let randomX = CGFloat.random(in: -15...15)
        let randomY = CGFloat.random(in: -10...10)
        
        withAnimation(.easeInOut(duration: Double.random(in: 2.0...4.0)).repeatForever(autoreverses: true)) {
            position = CGPoint(x: randomX, y: randomY)
        }
        
        // Slight rotation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
            rotation = Double.random(in: -10...10)
        }
    }
}

// MARK: - Fly View
struct FlyView: View {
    @State private var wingFlap: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(Color(hex: "#2C2C2C"))
                .frame(width: 12, height: 6)
            
            // Wings
            ForEach(0..<2, id: \.self) { index in
                Ellipse()
                    .fill(Color(hex: "#4A4A4A").opacity(0.6))
                    .frame(width: 8, height: 4)
                    .offset(x: CGFloat(index == 0 ? -4 : 4), y: -2)
                    .scaleEffect(y: 1.0 + wingFlap * 0.3)
            }
            
            // Eyes
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 2, height: 2)
                    .offset(x: CGFloat(index == 0 ? -3 : 3), y: -1)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                wingFlap = 1.0
            }
        }
    }
}

// MARK: - Beetle View
struct BeetleView: View {
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#3A3A3A"),
                            Color(hex: "#1A1A1A")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 14, height: 10)
            
            // Shell segments
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#2A2A2A"))
                    .frame(width: 3, height: 8)
                    .offset(x: CGFloat(index - 1) * 4, y: 0)
            }
            
            // Legs
            ForEach(0..<6, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(hex: "#2A2A2A"))
                    .frame(width: 1, height: 4)
                    .offset(
                        x: CGFloat(index % 2 == 0 ? -6 : 6),
                        y: CGFloat(index / 2 - 1) * 3
                    )
            }
        }
    }
}

// MARK: - Ant View
struct AntView: View {
    var body: some View {
        ZStack {
            // Body segments
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(hex: "#2C2C2C"))
                    .frame(width: index == 1 ? 10 : 6, height: index == 1 ? 10 : 6)
                    .offset(x: CGFloat(index - 1) * 5, y: 0)
            }
            
            // Antennae
            ForEach(0..<2, id: \.self) { index in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: -3))
                    path.addLine(to: CGPoint(x: CGFloat(index == 0 ? -2 : 2), y: -6))
                }
                .stroke(Color(hex: "#2C2C2C"), lineWidth: 1)
                .offset(x: CGFloat(index == 0 ? -3 : 3), y: -5)
            }
            
            // Legs
            ForEach(0..<6, id: \.self) { index in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(index % 2 == 0 ? -3 : 3), y: 4))
                }
                .stroke(Color(hex: "#2C2C2C"), lineWidth: 1)
                .offset(x: CGFloat(index / 2 - 1) * 4, y: 3)
            }
        }
    }
}

// MARK: - Spider View
struct SpiderView: View {
    @State private var legAnimation: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(Color(hex: "#1A1A1A"))
                .frame(width: 12, height: 10)
            
            // Head
            Circle()
                .fill(Color(hex: "#2C2C2C"))
                .frame(width: 6, height: 6)
                .offset(x: -4, y: 0)
            
            // Eyes
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(Color.red.opacity(0.9))
                    .frame(width: 1.5, height: 1.5)
                    .offset(
                        x: -4 + CGFloat(index % 2) * 2,
                        y: CGFloat(Double(index) / 2.0 - 0.5) * 1.5
                    )
            }
            
            // Legs (8 legs)
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * (2 * .pi / 8)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(
                        x: cos(angle) * 8,
                        y: sin(angle) * 8
                    ))
                }
                .stroke(Color(hex: "#2C2C2C"), lineWidth: 1.5)
                .offset(x: CGFloat(cos(angle) * 2), y: CGFloat(sin(angle) * 2))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                legAnimation = 1.0
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "#1A2C38")
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            BugView(bugType: .fly, onTap: {})
            BugView(bugType: .beetle, onTap: {})
            BugView(bugType: .ant, onTap: {})
            BugView(bugType: .spider, onTap: {})
        }
    }
}
