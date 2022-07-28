//
//  Utilities.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/28/22.
//

import Foundation
import RealmSwift
import SwiftUI
import UIKit

class Utilities {
    
    let realm: Realm!
    
    init() {
        do {
            let realm = try Realm()
            self.realm = realm
        }
        catch {
            print("There was an error connecting to the data base: \(error.localizedDescription)")
            self.realm = nil
        }
        
        // This will delete everything in the db
//
//        realm.beginWrite()
//        realm.deleteAll()
//        try! realm.commitWrite()
        
    }
    
    func locateDataInRealm( key: String ) -> UserData? {
        if let locatedData = realm.object(ofType: UserData.self, forPrimaryKey: key) {
            return locatedData
        } else { print( "There was an error finding the data in the realm database" ) }
        return nil
    }
    
    func saveToDataToRealm<anyData: Object>(_ data: anyData) {
        realm.beginWrite()
        realm.add(data)
        
        do { try realm.commitWrite() }
        catch { print("There was an error committing the data: \(error.localizedDescription)") }
        
    }
    
    func saveSeriesToRealm<anyData: Sequence>(_ data: anyData) where anyData.Element: Object {
        
        realm.beginWrite()
        realm.add(data, update: .all)
        
        do { try realm.commitWrite() }
        catch { print("There was an error committing the sequnce of data: \(error.localizedDescription)") }
        
    }
    
    func removeDataFromRealm(key: String) {
        if let data = locateDataInRealm(key: key) {
            realm.beginWrite()
            realm.delete(data)
            do { try realm.commitWrite() }
            catch { print("There was an error committing the deletion of data: \(error.localizedDescription)") }
        }
    }
}

let util = Utilities()
