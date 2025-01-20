//
//  accutaneDosageApp.swift
//  accutaneDosage
//
//  Created by Kristian Ivanov on 15/01/2025.
//

import SwiftUI
import SwiftData

@main
struct accutaneDosageApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: DoseEntry.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    @StateObject private var doseTrackerVM = DoseTrackerViewModel()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(doseTrackerVM)
        }
        .modelContainer(container)
    }
}

