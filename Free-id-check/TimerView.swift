import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var timerManager: TimerManager
    
    private var progress: Double {
        let totalTime = Double(timerManager.selectedDuration.rawValue)
        return 1.0 - (Double(timerManager.timeRemaining) / totalTime)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Timer Display
            VStack(spacing: 16) {
                ZStack {
                    // Progress Ring
                    Circle()
                        .stroke(Theme.current.mutedBackground, lineWidth: 12)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            timerManager.isBreakTime ? Theme.current.success : Theme.current.accent,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    VStack(spacing: 8) {
                        Text(timeString(from: timerManager.timeRemaining))
                            .font(.system(size: 48, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.current.textPrimary)
                            .monospacedDigit()
                        
                        Text(timerManager.isBreakTime ? "Break Time" : "Focus Time")
                            .font(.headline)
                            .foregroundColor(Theme.current.textSecondary)
                    }
                }
                
                if timerManager.isBreakTime {
                    Text(motivationalMessage)
                        .font(.subheadline)
                        .foregroundColor(Theme.current.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(showMotivationalMessages ? 1 : 0)
                        .animation(.easeInOut, value: motivationalMessage)
                }
            }
            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    timerManager.resetTimer()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(Theme.current.warning)
                        .frame(width: 44, height: 44)
                        .background(Theme.current.mutedBackground)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.current.border, lineWidth: 1))
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Reset Timer (⌘R)")
                
                Button(action: {
                    timerManager.toggleTimer()
                }) {
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(Theme.current.background)
                        .frame(width: 64, height: 64)
                        .background(timerManager.isBreakTime ? Theme.current.success : Theme.current.accent)
                        .clipShape(Circle())
                }
                .keyboardShortcut(.space, modifiers: [])
                .help("Play/Pause (Space)")
                
                Button(action: {
                    // Settings button action
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(Theme.current.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(Theme.current.mutedBackground)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.current.border, lineWidth: 1))
                }
                .help("Settings")
            }
            
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
        .padding()
        .background(Theme.current.background)
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private var motivationalMessage: String {
        let messages = [
            "Keep up the good work!",
            "Almost there!",
            "Stay focused!",
            "You're doing great!",
            "Keep going!"
        ]
        return messages[Int(Date().timeIntervalSince1970) % messages.count]
    }
    
    @AppStorage("showMotivationalMessages") private var showMotivationalMessages = true
    @AppStorage("showBreakStreak") private var showBreakStreak = true
}

struct StatView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(Theme.current.accent)
                Text(value)
                    .font(.headline)
                    .foregroundColor(Theme.current.textPrimary)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.current.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.current.mutedBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.current.border, lineWidth: 1)
        )
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerManager())
} 