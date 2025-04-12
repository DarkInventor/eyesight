import Foundation

extension UserDefaults {
    static let appGroupIdentifier = "group.com.your.app.identifier"  // Replace with your app group identifier
    
    static var shared: UserDefaults {
        return UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
} 