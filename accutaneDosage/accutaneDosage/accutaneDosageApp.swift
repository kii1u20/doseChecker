//
//  accutaneDosageApp.swift
//  accutaneDosage
//
//  Created by Kristian Ivanov on 15/01/2025.
//

import SwiftUI
import SwiftData

typealias DoseEntry = AccutaneDosageSchemaV2.DoseEntry
typealias DoseImage = AccutaneDosageSchemaV2.DoseImage
typealias DoseNote = AccutaneDosageSchemaV2.DoseNote

enum migrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] {
        [
            AccutaneDosageSchemaV1.self,
            AccutaneDosageSchemaV2.self
        ]
    }
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: AccutaneDosageSchemaV1.self,
        toVersion: AccutaneDosageSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            let entries = try? context.fetch(FetchDescriptor<AccutaneDosageSchemaV2.DoseEntry>())
            entries?.forEach { entry in
                if entry.hasImages {
                    let images = entry.images!
                    images.enumerated().forEach { index, image in
                        image.sortIndex = index
                    }
                }
            }
            try? context.save()
        }
    )
}

@main
struct accutaneDosageApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([DoseEntry.self, DoseImage.self, DoseNote.self])
            let config = ModelConfiguration()
            container = try ModelContainer(for: schema, migrationPlan: migrationPlan.self, configurations: config)
            DoseModelActor.initialize(container: container)
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

