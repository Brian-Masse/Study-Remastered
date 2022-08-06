//
//  Migrator.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/6/22.
//

import Foundation
import RealmSwift

class Migrator {
    
    static let userDataVersion = 2
    
    static let shared = Migrator()
    
    //for notes about updating schema see: https://ali-akhtar.medium.com/migration-with-realm-realmswift-part-6-11c3a7b24955
    func updateUserDataSchema(version: Int, user: RealmSwift.User) -> Realm.Configuration {
    
        var configuration = user.flexibleSyncConfiguration()
        configuration.schemaVersion = UInt64(Float(version))
        configuration.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: UserData.className() ) { oldObject, newObject in
                    
                    let firstName = (oldObject!["firstName"] as! String).lowercased()
                    let lastInitial = (oldObject!["firstName"] as! String).first!
                    
                    let abreviatedUserName = "\(firstName) + \(lastInitial)"
                    newObject!["userName"] = abreviatedUserName
                }
            }
        }
        
        return configuration
    }
    
}
