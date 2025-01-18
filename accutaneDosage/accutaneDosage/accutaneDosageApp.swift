//
//  accutaneDosageApp.swift
//  accutaneDosage
//
//  Created by Kristian Ivanov on 15/01/2025.
//

import SwiftUI

@main
struct accutaneDosageApp: App {
    @StateObject private var doseTrackerVM = DoseTrackerViewModel()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(doseTrackerVM)
        }
    }
}
