import SwiftUI
import AVFoundation
import AppKit
import UserNotifications
import WidgetKit

@main
struct EyeCareApp: App {
    @StateObject private var timerManager = TimerManager()
    
    init() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(timerManager)
                
                if timerManager.showingBreakScreen {
                    BreakOverlayView()
                        .environmentObject(timerManager)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .onReceive(timerManager.$showingBreakScreen) { showingBreak in
                if let window = NSApplication.shared.windows.first {
                    if showingBreak {
                        timerManager.storeWindowFrame(window.frame)
                        DispatchQueue.main.async {
                            if !window.styleMask.contains(.fullScreen) {
                                window.toggleFullScreen(nil)
                            }
                        }
                    } else if timerManager.hasStoredWindowFrame {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if window.styleMask.contains(.fullScreen) {
                                window.toggleFullScreen(nil)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if let storedFrame = timerManager.savedWindowFrame {
                                    window.setFrame(storedFrame, display: true, animate: true)
                                    timerManager.clearStoredWindowFrame()
                                }
                            }
                        }
                    }
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        MenuBarExtra {
            ContentView()
                .environmentObject(timerManager)
        } label: {
            MenuBarIcon(timerManager: timerManager)
        }
        .menuBarExtraStyle(.window)
        
        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(timerManager)
        }
        #endif
    }
}

struct MenuBarIcon: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: timerManager.isBreakTime ? "eye.fill" : "eye")
            
            if timerManager.isRunning {
                Text(timeString(from: timerManager.isBreakTime ? timerManager.breakTimeRemaining : timerManager.timeRemaining))
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
            }
        }
        .foregroundColor(timerManager.isBreakTime ? .green : nil)
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

enum WorkDuration: Int, CaseIterable, Identifiable, Hashable {
    case fiveSeconds = 5
    case tenMinutes = 600
    case twentyMinutes = 1200
    case thirtyMinutes = 1800
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .fiveSeconds: return "5 seconds"
        case .tenMinutes: return "10 minutes"
        case .twentyMinutes: return "20 minutes"
        case .thirtyMinutes: return "30 minutes"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .fiveSeconds: return "5 sec"
        case .tenMinutes: return "10 min"
        case .twentyMinutes: return "20 min"
        case .thirtyMinutes: return "30 min"
        }
    }
}

class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = WorkDuration.twentyMinutes.rawValue {
        didSet {
            updateWidget()
        }
    }
    @Published var breakTimeRemaining: Int = 20 {
        didSet {
            updateWidget()
        }
    }
    @Published var isBreakTime: Bool = false {
        didSet {
            updateWidget()
        }
    }
    @Published var showingBreakScreen: Bool = false
    @Published private(set) var isRunning: Bool = false {
        didSet {
            updateWidget()
        }
    }
    @Published var selectedDuration: WorkDuration = .twentyMinutes {
        didSet {
            if !isRunning || pausedTimeRemaining != nil {
                timeRemaining = selectedDuration.rawValue
                pausedTimeRemaining = selectedDuration.rawValue
            }
            updateWidget()
        }
    }
    @Published private(set) var breakStreak: Int = 0 {
        didSet {
            updateWidget()
        }
    }
    @Published private(set) var lastBreakSkipped: Bool = false
    
    private var timer: DispatchSourceTimer?
    private var breakTimer: DispatchSourceTimer?
    private var storedWindowFrame: NSRect?
    private var pausedTimeRemaining: Int?
    private var lastUpdateTime: Date = Date()
    
    var isPaused: Bool {
        !isRunning && pausedTimeRemaining != nil
    }
    
    var hasStoredWindowFrame: Bool {
        storedWindowFrame != nil
    }
    
    var savedWindowFrame: NSRect? {
        get { storedWindowFrame }
    }
    
    init() {
        timeRemaining = selectedDuration.rawValue
        
        // Add observer for app termination
        NotificationCenter.default.addObserver(self,
            selector: #selector(saveState),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
        
        // Load saved state
        loadState()
    }
    
    deinit {
        timer?.cancel()
        breakTimer?.cancel()
    }
    
    private func updateWidget() {
        // Save state when updating widget
        saveState()
        // Reload widget
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func createBackgroundTimer() -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        return timer
    }
    
    func startTimer() {
        timer?.cancel()
        
        if pausedTimeRemaining == nil {
            timeRemaining = selectedDuration.rawValue
        } else {
            timeRemaining = pausedTimeRemaining!
            pausedTimeRemaining = nil
        }
        
        // Schedule notification for work timer end
        scheduleWorkEndNotification()
        
        lastUpdateTime = Date()
        timer = createBackgroundTimer()
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            // Calculate elapsed time since last update
            let now = Date()
            let elapsed = Int(now.timeIntervalSince(self.lastUpdateTime))
            self.lastUpdateTime = now
            
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining = max(0, self.timeRemaining - elapsed)
                }
                
                if self.timeRemaining == 0 {
                    self.timer?.cancel()
                    self.startBreak()
                }
            }
        }
        timer?.resume()
        isRunning = true
    }
    
    func startBreak() {
        isBreakTime = true
        breakTimeRemaining = 20
        playBreakStartSound()
        showingBreakScreen = true
        
        // Schedule notification for break end
        scheduleBreakEndNotification()
        
        lastUpdateTime = Date()
        breakTimer = createBackgroundTimer()
        breakTimer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            let now = Date()
            let elapsed = Int(now.timeIntervalSince(self.lastUpdateTime))
            self.lastUpdateTime = now
            
            DispatchQueue.main.async {
                if self.breakTimeRemaining > 0 {
                    self.breakTimeRemaining = max(0, self.breakTimeRemaining - elapsed)
                }
                
                if self.breakTimeRemaining == 0 {
                    self.breakTimer?.cancel()
                    self.completeBreak()
                }
            }
        }
        breakTimer?.resume()
    }
    
    private func scheduleBreakEndNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Break Complete"
        content.body = "Time to get back to work!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(breakTimeRemaining), repeats: false)
        let request = UNNotificationRequest(identifier: "breakEnd", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleWorkEndNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a Break"
        content.body = "Look away from your screen for 20 seconds"
        content.sound = .default
        
        // Notify 30 seconds before the timer ends
        if timeRemaining > 30 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining - 30), repeats: false)
            let request = UNNotificationRequest(identifier: "workEndWarning", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    @objc private func saveState() {
        let state: [String: Any] = [
            "timeRemaining": timeRemaining,
            "breakTimeRemaining": breakTimeRemaining,
            "isBreakTime": isBreakTime,
            "isRunning": isRunning,
            "selectedDuration": selectedDuration.rawValue,
            "breakStreak": breakStreak,
            "lastUpdateTime": lastUpdateTime
        ]
        UserDefaults.shared.set(state, forKey: "timerState")
    }
    
    private func loadState() {
        guard let state = UserDefaults.shared.dictionary(forKey: "timerState") else { return }
        
        if let timeRemaining = state["timeRemaining"] as? Int {
            self.timeRemaining = timeRemaining
        }
        if let breakTimeRemaining = state["breakTimeRemaining"] as? Int {
            self.breakTimeRemaining = breakTimeRemaining
        }
        if let isBreakTime = state["isBreakTime"] as? Bool {
            self.isBreakTime = isBreakTime
        }
        if let isRunning = state["isRunning"] as? Bool,
           let lastUpdateTime = state["lastUpdateTime"] as? Date {
            // Calculate elapsed time while app was closed
            let elapsed = Int(Date().timeIntervalSince(lastUpdateTime))
            if isRunning {
                if isBreakTime {
                    self.breakTimeRemaining = max(0, self.breakTimeRemaining - elapsed)
                    if self.breakTimeRemaining > 0 {
                        startBreak()
                    }
                } else {
                    self.timeRemaining = max(0, self.timeRemaining - elapsed)
                    if self.timeRemaining > 0 {
                        startTimer()
                    }
                }
            }
        }
        if let durationValue = state["selectedDuration"] as? Int,
           let duration = WorkDuration(rawValue: durationValue) {
            self.selectedDuration = duration
        }
        if let breakStreak = state["breakStreak"] as? Int {
            self.breakStreak = breakStreak
        }
    }
    
    func storeWindowFrame(_ frame: NSRect) {
        storedWindowFrame = frame
    }
    
    func clearStoredWindowFrame() {
        storedWindowFrame = nil
    }
    
    private func playBreakStartSound() {
        SoundManager.shared.play(.breakStart)
    }
    
    private func playBreakEndSound() {
        SoundManager.shared.play(.breakEnd)
    }
    
    func skipBreak() {
        lastBreakSkipped = true
        breakStreak = 0
        endBreak()
    }
    
    private func completeBreak() {
        lastBreakSkipped = false
        breakStreak += 1
        endBreak()
    }
    
    private func endBreak() {
        breakTimer?.cancel()
        breakTimer = nil
        isBreakTime = false
        showingBreakScreen = false  // This will trigger the onReceive modifier to exit fullscreen
        
        timeRemaining = selectedDuration.rawValue
        playBreakEndSound()
        startTimer()
    }
    
    func resetTimer() {
        pausedTimeRemaining = nil
        timeRemaining = selectedDuration.rawValue
        isBreakTime = false
        startTimer()
    }
    
    func pauseTimer() {
        timer?.cancel()
        timer = nil
        pausedTimeRemaining = timeRemaining
        isRunning = false
    }
    
    func resumeTimer() {
        if !isRunning {
            startTimer()
        }
    }
    
    func setDuration(_ duration: WorkDuration) {
        selectedDuration = duration
        resetTimer()
    }
    
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            resumeTimer()
        }
    }
} 
