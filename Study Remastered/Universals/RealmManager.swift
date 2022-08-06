//
//  Utilities.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/28/22.
//

import Foundation
import RealmSwift
import SwiftUI

class RealmManager: ObservableObject {
    
    
    //MARK: Realm Utils
    @Published var realm: Realm!
    
    static let shared = RealmManager()
    static let userDataSubscription = "User-Data"
    
    func loadRealm() async {
        
        //init the synced Realm
        
        do {
            let app = RealmSwift.App(id: "study-remastered-uesnt")
            let user = try await app.login(credentials: .anonymous )
            
            let config = user.flexibleSyncConfiguration { subs in
                if let _ = subs.first(named: RealmManager.userDataSubscription) { return }
                else { subs.append( QuerySubscription<UserData>(name: RealmManager.userDataSubscription) ) }
            }
            
            do { realm = try await Realm(configuration: config, downloadBeforeOpen: .always) }
            catch { print( "error creating the Realm: \(error.localizedDescription)" ) }
            
        }catch { print("failed to login the database user: \(error.localizedDescription)") }
        
        print( realm.configuration.fileURL! )
    }
    
    func locateDataInRealm( key: String ) -> UserData? {
        if let locatedData = realm.object(ofType: UserData.self, forPrimaryKey: key) {
            return locatedData
        } else { print( "There was an error finding the data in the realm database" ) }
        return nil
    }
    
    func saveDataToRealm<anyData: Object>(_ data: anyData) {
        realm.beginWrite()
        realm.add(data)
        
        do { try realm.commitWrite() }
        catch { print("There was an error committing the data: \(error.localizedDescription)") }
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
