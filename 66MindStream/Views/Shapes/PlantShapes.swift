//
//  PlantShapes.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

// MARK: - Leaf Shape
struct LeafShape: Shape {
    var curvature: CGFloat = 0.3
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = rect.midX
        let centerY = rect.midY
        
        // Create leaf shape with curved edges
        path.move(to: CGPoint(x: centerX, y: rect.minY))
        
        // Top curve
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: centerY),
            control: CGPoint(x: centerX + width * curvature, y: centerY - height * 0.2)
        )
        
        // Bottom right curve
        path.addQuadCurve(
            to: CGPoint(x: centerX, y: rect.maxY),
            control: CGPoint(x: centerX + width * 0.3, y: centerY + height * 0.3)
        )
        
        // Bottom left curve
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: centerY),
            control: CGPoint(x: centerX - width * 0.3, y: centerY + height * 0.3)
        )
        
        // Top left curve
        path.addQuadCurve(
            to: CGPoint(x: centerX, y: rect.minY),
            control: CGPoint(x: centerX - width * curvature, y: centerY - height * 0.2)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Stem Shape
struct StemShape: Shape {
    var width: CGFloat = 4
    var height: CGFloat = 20
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        
        path.move(to: CGPoint(x: centerX - width/2, y: rect.maxY))
        path.addLine(to: CGPoint(x: centerX + width/2, y: rect.maxY))
        path.addLine(to: CGPoint(x: centerX + width/2, y: rect.minY))
        path.addLine(to: CGPoint(x: centerX - width/2, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Petal Shape
struct PetalShape: Shape {
    var petalCount: Int = 5
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<petalCount {
            let angle = Double(i) * 2 * .pi / Double(petalCount) - .pi / 2
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Bud Shape
struct BudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Create teardrop shape
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius * 0.7,
            width: radius * 2,
            height: radius * 1.4
        ))
        
        return path
    }
}
