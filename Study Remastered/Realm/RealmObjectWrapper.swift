//
//  Realm Object Wrapper.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/13/22.
//

import Foundation
import RealmSwift


//for saving an object in a collection without having to conform the object to Object
class RealmObjectWrapper: Object {
    
    @Persisted(primaryKey: true) var _id: String
    
    @Persisted var owner: String = ""
    
    @Persisted var data: Data?
    
    @Persisted var type: String = ""
    
    //create the object when saving the real data, it will automatically check for duplicate wrappers in the database
    required convenience init<T: AnyObject>( _ object: T, type: String ) where T: WrappedRealmObject, T: Codable {
        self.init()
        
        self.owner = object.owner
        self.type = type
        
        self.data = encodeObject(object)
        self._id = object.id
        
        RealmManager.shared.saveDataToRealm(self)
    }
    
    private func encodeObject<T: AnyObject>( _ object: T) -> Data? where T: WrappedRealmObject, T: Codable {
        do { return try JSONEncoder().encode( object ) }
        catch { print( "error encoding the data: \( error.localizedDescription )" ) }
        return nil
    }
    
    func decodeObject<T: AnyObject>(defaultObject: T? = nil) -> T? where T: WrappedRealmObject, T: Codable {
        if let data = data {
            do {
                let object = try JSONDecoder().decode(T.self, from: data )
                object.setOwnership( self.owner, self._id )
                return object
            }
            catch { print( "error decoding data: \( error.localizedDescription )" ) }
        }
        return defaultObject
        
    }
}

struct RealmObjectWrapperKeys {
    static let setViewModelKey: String = "Brian.Masse.StudySetViewModel"
}

protocol WrappedRealmObject {
    
    var owner: String { get set }
    var id: String { get set }
    
    func setOwnership(_ : String, _: String) -> Void
    
}
