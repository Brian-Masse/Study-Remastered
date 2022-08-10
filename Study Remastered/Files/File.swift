//
//  File.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import RealmSwift

struct File: Fileable {
    
    enum FileType: String {
        case set
        case group
    }
    
    var id: String
    
    var path: FileURL = .init([])
    
    var name: String
    
    let type: FileType
    
    
    init( _ name: String, at path: FileURL, ofType type: FileType ) {
        
        self.name = name
        self.path = path.copy()
        self.path.setFile(with: name)

        self.type = type

        self.id = self.path.string(withFileName: true)
        
    }
    
}

protocol Fileable: Identifiable {
    
    var path: FileURL { get set }
    
    var name: String { get set }
    
    var type: File.FileType { get }
    
}



let dummyData = [

    test("one", 1),
    test("two", 2),
    test("three", 3)

]

class test: Object {
    
    @Persisted(primaryKey: true) var _id = ""
    @Persisted var test1: String = "hello"
    @Persisted var test2: Int = 5
    
    required convenience init( _ test1: String, _ test2: Int ) {
        self.init()
        self.test1 = test1
        self.test2 = test2
        
        self._id = "\( test1 ) \(test2)"
    }
    
}
