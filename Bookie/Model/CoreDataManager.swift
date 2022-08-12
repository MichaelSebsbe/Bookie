//
//  CoreDataManager.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    private init() {
        ValueTransformer.setValueTransformer(NSMutableAttributedStringTransformer(), forName: NSValueTransformerName("NSMutableAttributedStringTransformer"))
    }
    
    func saveItems(){
        
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// - Parameter request: NSFetchRequest type for the items to be fetched
    /// - Returns: [NSFetchRequestResult]. Down cast it to the same type as request
    func loadItems<NSFetchRequestResult>(with request: NSFetchRequest<NSFetchRequestResult>) -> [NSFetchRequestResult]?{
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
