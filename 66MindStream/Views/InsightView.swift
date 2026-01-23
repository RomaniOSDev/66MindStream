//
//  InsightView.swift
//  66MindStream
//
//  Created by Роман Главацкий on 23.01.2026.
//

import SwiftUI

struct InsightView: View {
    @StateObject private var viewModel = InsightViewModel()
    @State private var selectedDay: Date?
    
    var body: some View {
        ZStack {
            Color(hex: "#1A2C38")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("Insights")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Calendar
                    CustomCalendarView(viewModel: viewModel, selectedDay: $selectedDay)
                    
                    // Balance chart
                    BalanceChartView(viewModel: viewModel)
                    
                    // Insights list
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Insights")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        ForEach(viewModel.insights, id: \.self) { insight in
                            InsightCard(text: insight)
                        }
                    }
                    .padding()
                    
                    // Selected day entries
                    if let selectedDay = selectedDay {
                        DayEntriesView(date: selectedDay)
                    }
                }
            }
        }
    }
}


struct BalanceChartView: View {
    @ObservedObject var viewModel: InsightViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Balance")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            let weekData = viewModel.weekData
            let maxValue = max(weekData.map { $0.focus + $0.noise }.max() ?? 1, 1)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 5) {
                        // Focus bar (up)
                        if data.focus > 0 {
                            Rectangle()
                                .fill(Color(hex: "#16FF16"))
                                .frame(width: 30, height: CGFloat(data.focus) / CGFloat(maxValue) * 100)
                        }
                        
                        // Noise bar (down)
                        if data.noise > 0 {
                            Rectangle()
                                .fill(Color(hex: "#1475E1"))
                                .frame(width: 30, height: CGFloat(data.noise) / CGFloat(maxValue) * 100)
                        }
                        
                        Text(dayLabel(for: data.date))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .frame(height: 120)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct InsightCard: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(Color(hex: "#16FF16"))
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DayEntriesView: View {
    let date: Date
    private let dataService = DataService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Entries for \(formattedDate)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            let entries = dataService.getEntries(for: date)
            
            if entries.isEmpty {
                Text("No entries for this day")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
            } else {
                ForEach(entries) { entry in
                    EntryRowView(entry: entry)
                }
            }
        }
        .padding()
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct EntryRowView: View {
    let entry: LogEntry
    
    var body: some View {
        HStack {
            Circle()
                .fill(entry.type == .focus ? Color(hex: "#16FF16") : Color(hex: "#1475E1"))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.type == .focus ? "Focus" : "Noise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if let comment = entry.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            Text(timeString)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
}

#Preview {
    InsightView()
}
