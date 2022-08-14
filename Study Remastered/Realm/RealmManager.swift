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
    static let sharedSetsSubscription = "Shared-Data-Sets"
    
    func loadRealm() async {
        
        //init the synced Realm
        
        do {
            let app = RealmSwift.App(id: "study-remastered-uesnt")
            let user = try await app.login(credentials: .anonymous )
            
    
//            let config = user.flexibleSyncConfiguration { subs in
//                if let _ = subs.first(named: RealmManager.userDataSubscription) { return }
//                else { subs.append( QuerySubscription<UserData>(name: RealmManager.userDataSubscription) ) }
//            }
        
            let config = Migrator.shared.updateUserDataSchema(version: Migrator.userDataVersion, user: user)
            
            do { realm = try await Realm(configuration: config, downloadBeforeOpen: .always) }
            catch { print( "error creating the Realm: \(error.localizedDescription)" ) }
            
            //when this runs, no user is signed in, so it passes a blank token
            //when the authenticatorHandler is initialized, and the callback for userSigning in is called, it will also update the subscriptions with the correct token query
            await self.updatUserDataSubscriptions(with: "")
            
        }catch { print("failed to login the database user: \(error.localizedDescription)") }
        
        print( realm.configuration.fileURL! )
    }
    
    func updatUserDataSubscriptions( with accessToken: String ) async {
        
        let _: UserData? = await addSubscriptions(RealmManager.userDataSubscription) { query in query.accessToken == accessToken }
        let _: RealmObjectWrapper? = await addSubscriptions(RealmManager.sharedSetsSubscription) { query in query.owner == accessToken }
        
    }
    
    private func addSubscriptions<objectType: Object>( _ name: String, query: (( RealmSwift.Query<objectType> ) -> RealmSwift.Query<Bool>)? = nil ) async -> objectType? {
        
        let subscriptions = realm.subscriptions
        let foundSubscriptions = subscriptions.first(named: name)
        do {
            try await subscriptions.update {
                //already have this subscription, so just update the query
                if foundSubscriptions != nil {
                    foundSubscriptions!.updateQuery(toType: objectType.self, where: query )
                        
                }else {
                    subscriptions.append( QuerySubscription<objectType>(name: name, query: query ) )
                }
            }
            
        }catch { print( "erorr generating subscriptions \( name ): \(error.localizedDescription)" ) }
        return nil
    }
    
    func locateDataInRealm<T: Object>( key: String ) -> T? {
        if let locatedData = realm.object(ofType: T.self, forPrimaryKey: key) {
            return locatedData
        } else { print( "There was an error finding the data in the realm database" ) }
        return nil
    }
    
    func locateObjectsInRealm<objectType: Object>( include filter: (( RealmSwift.Query<objectType> ) -> RealmSwift.Query<Bool>)? = nil ) -> [objectType] {
        
        var results = realm.objects(objectType.self)
        
        if let filter = filter { results = results.where(filter) }
        
        return Array( results )
    }
    
    func saveDataToRealm<anyData: Object>(_ data: anyData) {
        realm.beginWrite()
        
        realm.add(data, update: .modified)
        
        do { try realm.commitWrite() }
        catch { print("There was an error committing the data: \(error.localizedDescription)") }
    }
    
    func saveSequenceToRealm<anyData: Object>(_ dataSeries: [anyData]) {
        for data in dataSeries {
            saveDataToRealm(data)
        }
    }
    
    func removeDataFromRealm<T: Object>(key: String) -> T? {
        if let data: T = locateDataInRealm(key: key) {
            realm.beginWrite()
            realm.delete(data)
            do { try realm.commitWrite() }
            catch { print("There was an error committing the deletion of data: \(error.localizedDescription)") }
        }
        return nil
    }
}
