//
//  GardenView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct GardenView: View {
    @StateObject private var viewModel = GardenViewModel()
    @State private var showLogEntry = false
    @State private var previousElementIDs: Set<UUID> = []
    @State private var newElementIDs: Set<UUID> = []
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1A2C38")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#16FF16"))
                    
                    Text("Garden")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Garden elements
                GeometryReader { geometry in
                    // Use full geometry size but with margins to keep elements inside
                    let totalWidth = geometry.size.width
                    let totalHeight = geometry.size.height
                    
                    // Define margins to keep elements inside screen
                    let horizontalMargin: CGFloat = 20
                    let verticalMargin: CGFloat = 20
                    let contentWidth = totalWidth - (horizontalMargin * 2)
                    let contentHeight = totalHeight - (verticalMargin * 2)
                    let contentX = horizontalMargin
                    let contentY = verticalMargin
                    
                    ZStack {
                        // Fence along the bottom of the garden
                        FenceView(postCount: 8)
                            .frame(width: contentWidth * 0.95, height: contentHeight * 0.12)
                            .position(
                                x: totalWidth / 2,
                                y: contentY + contentHeight * 0.88
                            )
                        
                        if viewModel.gardenElements.isEmpty {
                            // Empty garden message
                            VStack(spacing: 20) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(hex: "#16FF16").opacity(0.5))
                                
                                Text("Your garden is empty")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("Add focus entries to grow plants")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(width: contentWidth, height: contentHeight)
                            .position(x: totalWidth / 2, y: contentY + contentHeight / 2)
                        } else {
                            // Render all elements together (mixed)
                            // Render decorative elements first (background layer)
                            ForEach(viewModel.gardenElements.filter { element in
                                if case .soil = element { return true }
                                if case .path = element { return true }
                                if case .stone = element { return true }
                                return false
                            }) { element in
                                switch element {
                                case .stone(let id, let position, let size):
                                    StoneView(size: size)
                                        .position(
                                            x: contentX + position.x * contentWidth,
                                            y: contentY + position.y * contentHeight
                                        )
                                case .path(let id, let position, let length):
                                    PathView(length: length)
                                        .position(
                                            x: contentX + position.x * contentWidth,
                                            y: contentY + position.y * contentHeight
                                        )
                                case .soil(let id, let position, let width):
                                    SoilView(width: width)
                                        .position(
                                            x: contentX + position.x * contentWidth,
                                            y: contentY + position.y * contentHeight
                                        )
                                default:
                                    EmptyView()
                                }
                            }
                            
                            // Render main elements (plants and streams)
                            ForEach(viewModel.gardenElements.filter { element in
                                if case .plant = element { return true }
                                if case .stream = element { return true }
                                return false
                            }) { element in
                                switch element {
                                case .plant(let id, let position, let size):
                                    AnimatedPlantView(
                                        size: size,
                                        shouldAnimate: newElementIDs.contains(id)
                                    )
                                    .position(
                                        x: contentX + position.x * contentWidth,
                                        y: contentY + position.y * contentHeight
                                    )
                                case .stream(let id, let position, let intensity):
                                    AnimatedStreamView(
                                        intensity: intensity,
                                        shouldAnimate: newElementIDs.contains(id)
                                    )
                                    .position(
                                        x: contentX + position.x * contentWidth,
                                        y: contentY + position.y * contentHeight
                                    )
                                default:
                                    EmptyView()
                                }
                            }
                            
                        // Render butterflies on top (foreground layer)
                        ForEach(viewModel.gardenElements.filter { element in
                            if case .butterfly = element { return true }
                            return false
                        }) { element in
                            if case .butterfly(let id, let position) = element {
                                ButterflyView()
                                    .position(
                                        x: contentX + position.x * contentWidth,
                                        y: contentY + position.y * contentHeight
                                    )
                            }
                        }
                        
                        // Render bugs (interactive - can be tapped to kill)
                        ForEach(viewModel.gardenElements.filter { element in
                            if case .bug = element { return true }
                            return false
                        }) { element in
                            if case .bug(let id, let position, let bugType) = element {
                                if !viewModel.killedBugs.contains(id) {
                                    BugView(bugType: bugType) {
                                        viewModel.killBug(id)
                                    }
                                    .position(
                                        x: contentX + position.x * contentWidth,
                                        y: contentY + position.y * contentHeight
                                    )
                                }
                            }
                        }
                        }
                    }
                }
            }
            
            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showLogEntry = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#1A2C38"))
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#16FF16"))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showLogEntry) {
            LogEntryView()
        }
        .onChange(of: viewModel.gardenElements) { newElements in
            let currentIDs = Set(newElements.map { $0.id })
            let newIDs = currentIDs.subtracting(previousElementIDs)
            
            if !newIDs.isEmpty {
                newElementIDs = newIDs
                // Clear animation flag after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    newElementIDs.removeAll()
                }
            }
            
            previousElementIDs = currentIDs
        }
        .onAppear {
            previousElementIDs = Set(viewModel.gardenElements.map { $0.id })
        }
    }
}

// MARK: - Animated Plant View
struct AnimatedPlantView: View {
    let size: CGFloat
    let shouldAnimate: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.8
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Stem using custom shape with shadow
            StemShape(width: 5, height: max(40, 50 * size))
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#16FF16"),
                            Color(hex: "#12CC12")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5, height: max(40, 50 * size))
                .shadow(color: Color(hex: "#16FF16").opacity(0.4), radius: 4, x: 0, y: 2)
            
            // Leaves using custom LeafShape
            ForEach(0..<leafCount, id: \.self) { index in
                LeafShape(curvature: 0.3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#16FF16"),
                                Color(hex: "#16FF16").opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: max(20, 28 * size), height: max(16, 24 * size))
                    .rotationEffect(.degrees(Double(index) * leafAngle + rotation))
                    .offset(y: -max(20, 25 * size))
                    .shadow(color: Color(hex: "#16FF16").opacity(0.5), radius: 6, x: 0, y: 3)
            }
            
            // Bud or Flower
            if size > 0.6 {
                // Flower with petals
                ZStack {
                    ForEach(0..<5, id: \.self) { petalIndex in
                        PetalShape(petalCount: 5)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#16FF16"),
                                        Color(hex: "#12CC12")
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 9 * size
                                )
                            )
                            .frame(width: 18 * size, height: 18 * size)
                            .rotationEffect(.degrees(Double(petalIndex) * 72))
                            .shadow(color: Color(hex: "#16FF16").opacity(0.6), radius: 8, x: 0, y: 4)
                    }
                    // Center
                    Circle()
                        .fill(Color(hex: "#1A2C38"))
                        .frame(width: 6 * size, height: 6 * size)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .offset(y: -max(30, 35 * size))
            } else if size > 0.3 {
                // Bud
                BudShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#16FF16"),
                                Color(hex: "#12CC12")
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 7 * size
                        )
                    )
                    .frame(width: 14 * size, height: 14 * size)
                    .offset(y: -max(25, 30 * size))
                    .shadow(color: Color(hex: "#16FF16").opacity(0.5), radius: 6, x: 0, y: 3)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            // Initial growth animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Continuous gentle swaying
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                rotation = 3
            }
        }
        .onChange(of: shouldAnimate) { newValue in
            if newValue {
                // Pulse animation when new entry is added
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
            }
        }
    }
    
    private var leafCount: Int {
        if size > 1.0 { return 6 }
        if size > 0.8 { return 5 }
        if size > 0.6 { return 4 }
        return 3
    }
    
    private var leafAngle: Double {
        360.0 / Double(leafCount)
    }
}

// MARK: - Animated Stream View
struct AnimatedStreamView: View {
    let intensity: CGFloat
    let shouldAnimate: Bool
    
    @State private var wavePhase: CGFloat = 0
    @State private var rippleProgress: CGFloat = 0
    @State private var opacity: Double = 0.8
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Animated waves
            ForEach(0..<3, id: \.self) { index in
                WaveShape(
                    phase: wavePhase + CGFloat(index) * 0.3,
                    amplitude: 3 * intensity,
                    frequency: 2.0 + CGFloat(index) * 0.5
                )
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#1475E1").opacity(0.9 * intensity * (1.0 - CGFloat(index) * 0.2)),
                            Color(hex: "#0F5FA8").opacity(0.7 * intensity * (1.0 - CGFloat(index) * 0.2))
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: max(60, 90 * intensity), height: max(50, 75 * intensity))
                .offset(y: CGFloat(index) * 12)
                .shadow(color: Color(hex: "#1475E1").opacity(0.5), radius: 8, x: 0, y: 4)
            }
            
            // Ripple effect
            RippleShape(
                progress: rippleProgress,
                amplitude: 2
            )
            .stroke(
                LinearGradient(
                    colors: [
                        Color(hex: "#1475E1").opacity(0.8 * intensity),
                        Color(hex: "#0F5FA8").opacity(0.6 * intensity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .frame(width: max(55, 70 * intensity), height: max(55, 70 * intensity))
            .shadow(color: Color(hex: "#1475E1").opacity(0.4), radius: 6, x: 0, y: 3)
            
            // Mist effect with animated opacity
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#1475E1").opacity(0.5 * intensity),
                            Color(hex: "#1475E1").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 20
                    )
                )
                .frame(width: max(60, 85 * intensity), height: max(60, 85 * intensity))
                .blur(radius: 18)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            // Initial appearance animation
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Continuous wave animation using sine function
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                wavePhase = 2.0 * .pi
            }
            
            // Ripple animation
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                rippleProgress = 1.0
            }
        }
        .onChange(of: shouldAnimate) { newValue in
            if newValue {
                // Reset and animate ripple
                rippleProgress = 0
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.2
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        scale = 1.0
                    }
                }
            }
        }
    }
}

#Preview {
    GardenView()
}
