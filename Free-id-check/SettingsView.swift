import SwiftUI

struct ThemePreview: View {
    let style: ThemeStyle
    let isSelected: Bool
    
    var body: some View {
        let colors = Theme.colors(for: style)
        
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Circle()
                    .fill(colors.accent)
                    .frame(width: 16, height: 16)
                
                Text(style.rawValue)
                    .foregroundColor(Theme.current.textPrimary)
                    .fontWeight(.medium)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(Theme.current.accent)
                }
            }
            
            Text(style.description)
                .foregroundColor(Theme.current.textSecondary)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Theme.current.mutedBackground : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Theme.current.accent : Theme.current.border, lineWidth: 1)
        )
    }
}

struct SettingsView: View {
    @AppStorage("playSound") private var playSound = true
    @AppStorage("showMotivationalMessages") private var showMotivationalMessages = true
    @AppStorage("showBreakStreak") private var showBreakStreak = true
    @AppStorage("selectedTheme") private var selectedTheme = ThemeStyle.minimal
    @AppStorage("autoStartBreaks") private var autoStartBreaks = true
    @AppStorage("showNotifications") private var showNotifications = true
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Theme")
                        .font(.headline)
                        .foregroundColor(Theme.current.textPrimary)
                    
                    Text("Choose a theme that helps you stay focused and relaxed")
                        .font(.caption)
                        .foregroundColor(Theme.current.textSecondary)
                    
                    ForEach(ThemeStyle.allCases) { style in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTheme = style
                            }
                        }) {
                            ThemePreview(style: style, isSelected: selectedTheme == style)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Behavior")
                        .font(.headline)
                        .foregroundColor(Theme.current.textPrimary)
                    
                    Toggle(isOn: $autoStartBreaks) {
                        VStack(alignment: .leading) {
                            Text("Auto-start Breaks")
                                .foregroundColor(Theme.current.textPrimary)
                            Text("Automatically start break timer when work timer ends")
                                .font(.caption)
                                .foregroundColor(Theme.current.textSecondary)
                        }
                    }
                    
                    Toggle(isOn: $showNotifications) {
                        VStack(alignment: .leading) {
                            Text("Show Notifications")
                                .foregroundColor(Theme.current.textPrimary)
                            Text("Display system notifications for timer events")
                                .font(.caption)
                                .foregroundColor(Theme.current.textSecondary)
                        }
                    }
                    
                    Toggle(isOn: $playSound) {
                        VStack(alignment: .leading) {
                            Text("Sound Effects")
                                .foregroundColor(Theme.current.textPrimary)
                            Text("Play sounds when breaks start and end")
                                .font(.caption)
                                .foregroundColor(Theme.current.textSecondary)
                        }
                    }
                    
                    Toggle(isOn: $showMotivationalMessages) {
                        VStack(alignment: .leading) {
                            Text("Motivational Messages")
                                .foregroundColor(Theme.current.textPrimary)
                            Text("Show encouraging messages during breaks")
                                .font(.caption)
                                .foregroundColor(Theme.current.textSecondary)
                        }
                    }
                    
                    Toggle(isOn: $showBreakStreak) {
                        VStack(alignment: .leading) {
                            Text("Break Streak")
                                .foregroundColor(Theme.current.textPrimary)
                            Text("Track and display consecutive breaks taken")
                                .font(.caption)
                                .foregroundColor(Theme.current.textSecondary)
                        }
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Keyboard Shortcuts")
                        .font(.headline)
                        .foregroundColor(Theme.current.textPrimary)
                    
                    KeyboardShortcutRow(key: "Space", action: "Play/Pause Timer")
                    KeyboardShortcutRow(key: "Esc", action: "Skip Break")
                    KeyboardShortcutRow(key: "⌘ + R", action: "Reset Timer")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 400)
        .background(Theme.current.background)
    }
}

struct KeyboardShortcutRow: View {
    let key: String
    let action: String
    
    var body: some View {
        HStack {
            Text(key)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.current.mutedBackground)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.current.border, lineWidth: 1)
                )
            
            Text(action)
                .foregroundColor(Theme.current.textSecondary)
        }
    }
}

#Preview {
    SettingsView()
} 