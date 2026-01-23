//
//  WaterShapes.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

// MARK: - Animated Wave Shape
struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerY = rect.midY
        
        path.move(to: CGPoint(x: 0, y: centerY))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let y = centerY + sin((relativeX * frequency + phase) * 2 * .pi) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Ripple Shape
struct RippleShape: Shape {
    var progress: CGFloat
    var amplitude: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2
        let radius = maxRadius * progress
        
        // Create ripple with wave effect
        for angle in stride(from: 0, through: 2 * .pi, by: 0.1) {
            let waveOffset = sin(angle * 3 + progress * 10) * amplitude
            let currentRadius = radius + waveOffset
            let x = center.x + cos(angle) * currentRadius
            let y = center.y + sin(angle) * currentRadius
            
            if angle == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Stream Shape
struct StreamShape: Shape {
    var width: CGFloat
    var height: CGFloat
    var wavePhase: CGFloat
    
    var animatableData: CGFloat {
        get { wavePhase }
        set { wavePhase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        
        // Create wavy stream path
        var points: [CGPoint] = []
        for y in stride(from: rect.minY, through: rect.maxY, by: 2) {
            let relativeY = (y - rect.minY) / rect.height
            let waveOffset = sin(relativeY * 4 * .pi + wavePhase) * width * 0.3
            let x = centerX + waveOffset
            points.append(CGPoint(x: x, y: y))
        }
        
        // Create path with width
        if !points.isEmpty {
            path.move(to: CGPoint(x: points[0].x - width/2, y: points[0].y))
            
            for point in points {
                path.addLine(to: CGPoint(x: point.x - width/2, y: point.y))
            }
            
            // Close the path
            for point in points.reversed() {
                path.addLine(to: CGPoint(x: point.x + width/2, y: point.y))
            }
            
            path.closeSubpath()
        }
        
        return path
    }
}

