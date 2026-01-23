//
//  CalendarView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct CustomCalendarView: View {
    @ObservedObject var viewModel: InsightViewModel
    @Binding var selectedDay: Date?
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            dominantType: viewModel.getDominantType(for: date),
                            isSelected: selectedDay != nil && calendar.isDate(date, inSameDayAs: selectedDay!),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            selectedDay = selectedDay == date ? nil : date
                        }
                    } else {
                        // Empty cell for alignment
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var calendarDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start else {
            return []
        }
        
        // Get first day of week for the month
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Adjust for calendar's first weekday (Sunday = 1, Monday = 2, etc.)
        let firstWeekdayIndex = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        // Get number of days in month
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before month starts
        for _ in 0..<firstWeekdayIndex {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let dominantType: DayDominantType?
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                
                // Color dot based on dominant type
                if let dominantType = dominantType {
                    Circle()
                        .fill(dotColor(for: dominantType))
                        .frame(width: 8, height: 8)
                        .shadow(color: dotColor(for: dominantType).opacity(0.5), radius: 2, x: 0, y: 1)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(width: 44, height: 50)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
            )
        }
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .white.opacity(0.3)
        }
        if isToday {
            return .white
        }
        return .white.opacity(0.9)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color(hex: "#16FF16").opacity(0.2)
        }
        if isToday {
            return Color.white.opacity(0.1)
        }
        return Color.clear
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color(hex: "#16FF16")
        }
        if isToday {
            return Color.white.opacity(0.3)
        }
        return Color.clear
    }
    
    private func dotColor(for type: DayDominantType) -> Color {
        switch type {
        case .focus:
            return Color(hex: "#16FF16")
        case .noise:
            return Color(hex: "#1475E1")
        case .balanced:
            return Color(hex: "#16FF16").opacity(0.7)
        }
    }
}

enum DayDominantType {
    case focus
    case noise
    case balanced
}
