//
//  ContentView.swift
//  Free-id-check
//
//  Created by Kathan Mehta on 2025-04-12.
//

import SwiftUI
import CoreData

struct DurationButton: View {
    let duration: WorkDuration
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(duration.shortTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? Theme.current.accentForeground : Theme.current.textPrimary)
                .frame(height: 30)
                .frame(minWidth: 70)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Theme.current.accent : Theme.current.mutedBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.current.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ContentView: View {
    @EnvironmentObject private var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Timer")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Theme.current.textPrimary)
            
            // Timer Display
            Text(timeString(from: timerManager.timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(Theme.current.textPrimary)
                .frame(height: 0)
                .padding(.bottom, 10)
            
            // Duration Selection
            HStack(spacing: 8) {
                ForEach(WorkDuration.allCases) { duration in
                    DurationButton(
                        duration: duration,
                        isSelected: timerManager.selectedDuration == duration
                    ) {
                        timerManager.selectedDuration = duration
                    }
                    .keyboardShortcut(KeyEquivalent(String(duration.rawValue / 60).first ?? "0"), modifiers: [.command, .shift])
                }
            }
            
            // Control Button
            Button(action: {
                timerManager.toggleTimer()
            }) {
                ZStack {
                    Circle()
                        .fill(Theme.current.mutedBackground)
                        .overlay(
                            Circle()
                                .stroke(Theme.current.border, lineWidth: 1)
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.current.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.space, modifiers: [])
            .help("Play/Pause (Space)")
            
            // Stats
            if showBreakStreak {
                HStack(spacing: 16) {
                    StatView(
                        icon: "checkmark.circle.fill",
                        value: "\(timerManager.breakStreak)",
                        label: "Break Streak"
                    )
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(width: 340, height: 340)
        .background(Theme.current.background)
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains([.command, .shift]) {
                    if let number = Int(event.characters ?? ""),
                       let duration = WorkDuration.allCases.first(where: { $0.rawValue / 60 == number }) {
                        timerManager.selectedDuration = duration
                        if !timerManager.isRunning {
                            timerManager.timeRemaining = duration.rawValue
                        }
                        return nil
                    }
                }
                return event
            }
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    @AppStorage("showBreakStreak") private var showBreakStreak = true
}

#Preview {
    ContentView()
        .environmentObject(TimerManager())
}
