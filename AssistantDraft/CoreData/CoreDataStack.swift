//
//  CoreDataStack.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 12/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import CoreData

//Called when want to obtain context and save context. Also in built functions for fetching and deleting files
class CoreDataStack {
    
    //Where context is created
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AssistantDraft")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext { return persistentContainer.viewContext }
    
    //Saves current context
    class func saveContext () {
        let context = persistentContainer.viewContext
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

