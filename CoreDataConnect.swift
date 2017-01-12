//
//  CoreDataConnect.swift
//  Your Email
//
//  Created by Antonio Tsai on 06/01/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//
import CoreData

class CoreDataConnect {
    var moc :NSManagedObjectContext!
    // typealias MyType = Record
    
    init(moc:NSManagedObjectContext) {
        self.moc = moc
    }
    
    // Insert
    func insert(myEntityName:String,
                attributeInfo:[String:String]) -> Bool {
        let insetData =
            NSEntityDescription.insertNewObject(
                forEntityName: myEntityName, into: self.moc)
        
        for (key,value) in attributeInfo {
            let t =
                insetData.entity.attributesByName[key]?.attributeType
            
            if t == .integer16AttributeType
                || t == .integer32AttributeType
                || t == .integer64AttributeType {
                insetData.setValue(Int(value),
                                   forKey: key)
            } else if t == .doubleAttributeType
                
                || t == .floatAttributeType {
                insetData.setValue(Double(value),
                                   forKey: key)
            } else if t == .booleanAttributeType {
                insetData.setValue(
                    (value == "true" ? true : false),
                    forKey: key)
            } else {
                insetData.setValue(value, forKey: key)
            }
        }
        
        do {
            try moc.save()
            
            return true
        } catch {
            fatalError("\(error)")
        }
        
        return false
    }
    
    // Select
    func fetch(myEntityName:String, predicate:String?,
               sort:[[String:Bool]]?, limit:Int?) -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(
            entityName: myEntityName)
        
        // predicate
        if let myPredicate = predicate {
            request.predicate =
                NSPredicate(format: myPredicate)
        }
        
        // sort
        if let mySort = sort {
            var sortArr :[NSSortDescriptor] = []
            for sortCond in mySort {
                for (k, v) in sortCond {
                    sortArr.append(
                        NSSortDescriptor(
                            key: k, ascending: v))
                }
            }
            
            request.sortDescriptors = sortArr
        }
        
        // limit
        if let limitNumber = limit {
            request.fetchLimit = limitNumber
        }
        
        do {
            let results =
                try moc.fetch(request)  as? [NSManagedObject]
            
            return results
        } catch {
            fatalError("\(error)")
        }
        
        return nil
    }
    
    // Update
    func update(myEntityName:String, predicate:String?,
        attributeInfo:[String:String]) -> Bool {
        if let results = self.fetch(
            myEntityName: myEntityName,
            predicate: predicate, sort: nil, limit: nil) {
            for result in results {
                for (key,value) in attributeInfo {
                    let t =
                        result.entity.attributesByName[key]?.attributeType
                    
                    if t == .integer16AttributeType
                        || t == .integer32AttributeType
                        || t == .integer64AttributeType {
                        result.setValue(
                            Int(value), forKey: key)
                    } else if t == .doubleAttributeType
                        || t == .floatAttributeType {
                        result.setValue(
                            Double(value), forKey: key)
                    } else if t == .booleanAttributeType {
                        result.setValue(
                            (value == "true" ? true : false),
                            forKey: key)
                    } else {
                        result.setValue(
                            value, forKey: key)
                    }
                }
            }
            
            do {
                try self.moc.save()
                
                return true
            } catch {
                fatalError("\(error)")
            }
        }
        
        return false
    }
    
    // Delete
    func delete(myEntityName:String, predicate:String?)
        -> Bool {
            if let results = self.fetch(myEntityName: myEntityName,
                                        predicate: predicate, sort: nil, limit: nil) {
                for result in results {
                    self.moc.delete(result)
                }
                
                do {
                    try self.moc.save()
                    
                    return true
                } catch {
                    fatalError("\(error)")
                }
            }
            
            return false
    }
}
