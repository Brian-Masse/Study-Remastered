//
//  FileManager.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI

class FileManager: ObservableObject {
    
    @Published var activePath: FileURL
    
    let loadedDirectories: [ DirectoryManager ] = []
    
    init( startingPath: FileURL ) {
        self.activePath = startingPath
    }
    
    
    func changeActiveDirectory(to newPath: FileURL) {
        
        
        
        
    }
    
    
    func createDirectories( alongPath: FileURL ) {
        
        
        
    }
    

}

class DirectoryManager: ObservableObject {
    
    
    let path: FileURL
    
    var objects: [ File ] = []
    var containedObjects: [ File ] = []
    
    init( path: FileURL, passedObjects: [File] ) {
        
        self.path = path
//
        self.containedObjects = passedObjects.compactMap { object in
            let result = object.path.matches(secondURL: path).1

            if result == .equals {
                self.objects.append(object)
                return nil
            }
            else if result == .secondInFirst { return object }
            return nil
        }
    }
    
}
