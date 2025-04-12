import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Theme.current.progressBackground,
                    lineWidth: 6
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Theme.current.progressForeground,
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

struct BreakOverlayView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @AppStorage("showMotivationalMessages") private var showMotivationalMessages = true
    @AppStorage("showBreakStreak") private var showBreakStreak = true
    @Environment(\.colorScheme) private var colorScheme
    
    private var progress: Double {
        1.0 - (Double(timerManager.breakTimeRemaining) / 20.0)
    }
    
    private var motivationalMessage: String {
        let messages = [
            "Your eyes deserve this break!",
            "Keep up the good habit!",
            "20 seconds to refresh your vision",
            "Protect your eyes, they're irreplaceable",
            "A small break for long-term benefits"
        ]
        return messages[Int(Date().timeIntervalSince1970) % messages.count]
    }
    
    var body: some View {
        ZStack {
            // Background
            Theme.current.background
                .opacity(0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Eye Break Time!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Theme.current.textPrimary)
                
                if showMotivationalMessages {
                    Text(motivationalMessage)
                        .font(.system(size: 20))
                        .foregroundColor(Theme.current.textSecondary)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
                
                Text("Look at something 20 feet away")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.current.textSecondary)
                
                ZStack {
                    CircularProgressView(progress: progress)
                        .frame(width: 200, height: 200)
                    
                    Text(timeString(from: timerManager.breakTimeRemaining))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.current.textPrimary)
                }
                .padding(.vertical, 20)
                
                if showBreakStreak && timerManager.breakStreak > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Theme.current.accent)
                        Text("Break streak: \(timerManager.breakStreak)")
                            .foregroundColor(Theme.current.textSecondary)
                    }
                    .font(.system(size: 16, weight: .medium))
                    .padding(.top, -20)
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        timerManager.skipBreak()
                    }) {
                        Text("Skip Break")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.current.accentForeground)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Theme.current.accent)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Theme.current.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                    
                    Text("Press Esc to skip")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.current.textSecondary)
                }
            }
            .padding(40)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        String(format: "%02d", seconds)
    }
}

#Preview {
    BreakOverlayView()
        .environmentObject(TimerManager())
} 