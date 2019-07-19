//
//  CoreDataStack.swift
//  Virtual Tourist v2
//
//  Created by Andrea Tongsak on 7/18/19.
//  Copyright © 2019 Andrea Tongsak. All rights reserved.
//

import CoreData

// MARK: CoreDataStack

struct CoreDataStack {
    // MARK: Properties
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    let context: NSManagedObjectContext
    
    // MARK: Initializers
    
    init?(modelName: String) {
        
        // Assuming model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("unable to find \(modelName)")
            return nil
        }
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // creates context and connects to coordinator
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        // Add SQLite store located in documents folder
        let fm = FileManager.default
        
        guard let docURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach documents folder")
            return nil
        }
        
        self.dbURL = docURL.appendingPathComponent("model.sqlite")
        
        // migration
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(dbURL)")
        }
    }
    
    // MARK: Utils
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options: [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }

}

// MARK: CoreDataStack (Remove Data)

internal extension CoreDataStack {
    func dropAllData() throws {
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}


// MARK: CoreDataStack (Save Data)

extension CoreDataStack {
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func autoSave(_ delayInSeconds: Int) {
        if delayInSeconds > 0 {
            do {
                try saveContext()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}
