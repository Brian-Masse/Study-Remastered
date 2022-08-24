//
//  File.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import RealmSwift

struct File {
    
    enum FileType: String {
        case set
        case group
    }
    
    var data: Fileable
    
    init( _ data: Fileable ) {
        self.data = data
        self.data.path.setFile(with: self.data.name)
    }
}

/// conform any object that wants to be saved into the filing system to `fileable`
/// when loaded into the app, these filable objects must be wrapped in a file and added to the shared FIleManager
protocol Fileable: Codable {
    
    var path: FileURL { get }
    
    var name: String { get set }
    
    func changeURL(with : FileURL) -> Void
    
    /// this needs to delete the object in whatever other objects / dbs its apart of it, AS WELL AS delete itself from the FileManager
    func delete() -> Void
    
    /// this needs to change the name of the object (such as changing a set name), change the name property under `fileable`
    func changeName(_ newName: String) -> Void
    
}

class test: Fileable {
    
    private(set) var path: FileURL
    
    var name: String
    
    init( at path: FileURL, name: String ) {
        
        self.path = path.copy()
        self.name = name
    }
    
    func changeURL(with url: FileURL) {
        self.path = url
    }
    
    func delete() {
        FileManager.shared.deleteFile( at: self.path, name: self.name )
    }
    
    func changeName(_ newName: String) {
        name = newName
        path.setFile(with: newName)
    }
    
    
}

class HiddenFile: Fileable, WrappedRealmObject {
    
    static let hiddenFileName = "$$_HIDDEN-FILE_$$"
    
    var owner: String = ""
    var id: String = ""
    
    var path: FileURL
    
    var name: String
    
    init(at url: FileURL ) {
        
        self.name = HiddenFile.hiddenFileName
        self.path = url.copy()
        
        self.setOwnership(AuthenticatorViewModel.shared.accessToken, UUID().uuidString)
        let _ = RealmObjectWrapper(self, type: .hiddenFileKey) // saves the object to the Realm Database
        
    }
    
    func changeURL(with newURL: FileURL) {
        self.path = newURL
        let _ = RealmObjectWrapper(self, type: .hiddenFileKey) // updates the object in the Realm Database
    }
    
    func delete() {
        let _ : RealmObjectWrapper? = RealmManager.shared.removeDataFromRealm(key: id)
    }
    
    func setOwnership(_ owner: String, _ id: String) {
        self.owner = owner
        self.id = id
    }
    
    func changeName(_ newName: String) { }
}


let unkownDirectory = FileURL( [  "unkown" ] )
let mainDirectory = FileURL( [  "main" ] )
let first = FileURL(startPath: mainDirectory, adding: "first")
let second = FileURL(startPath: mainDirectory, adding: "second")
let third = FileURL(startPath: second, adding: "third")
let fourth = FileURL(startPath: mainDirectory, adding: "fourth")

let object1 = test(at: mainDirectory, name: "object1")
let object2 = test(at: second, name: "object2")
let object3 = test(at: mainDirectory, name: "object3")
let object4 = test(at: third, name: "object4")
let object5 = test(at: fourth, name: "object5")


let data: [ File ] = [

    File(object1),
    File(object2),
    File(object3),
    File(object4),
    File(object5)

]
