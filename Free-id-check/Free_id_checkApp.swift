//
//  Free_id_checkApp.swift
//  Free-id-check
//
//  Created by Kathan Mehta on 2025-04-12.
//

import SwiftUI

@main
struct Free_id_checkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
