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
    }
}

/// conform any object that wants to be saved into the filing system to `fileable`
/// when loaded into the app, these filable objects must be wrapped in a file and added to the shared FIleManager
protocol Fileable {
    
    var path: FileURL { get }
    
    var name: String { get set }
    
    func changeURL(with : FileURL) -> Void
    
}

class test: Fileable {
    
    private(set) var path: FileURL
    
    var name: String
    
    init( at path: FileURL, name: String ) {
        
        self.path = path
        self.name = name
    }
    
    func changeURL(with url: FileURL) {
        self.path = url
    }
    
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
