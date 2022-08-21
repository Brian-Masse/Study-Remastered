//
//  FileManager.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI

class FileManager: ObservableObject {
    
    let main: Directory = Directory(at: mainDirectory)
    
    static let shared: FileManager = FileManager()
    
    init() {
        
        for file in data {
            insertFiles( [file], createDirectory: true)
        }
    }
    
    subscript( url: FileURL ) -> Directory {
        get {
            guard let directory = findFileURLMatch(at: url) else { return Directory(at: unkownDirectory) }
            return directory
        }
    }
    
    func insertFiles( _ files: [ File ], createDirectory: Bool ) {
        guard let path = files.first?.data.path else { return }
        guard let directory = findFileURLMatch(at: path, createDirectory: true) else { return }
        directory.files.append(contentsOf: files)
    }
    
    func inserFile( _ file: File, createDirectory: Bool ) {
        guard let directory = findFileURLMatch(at: file.data.path, createDirectory: true) else { return }
        directory.files.append(file)
    }
    
    func deleteFiles( at url: FileURL ) {
        guard let directory = findFileURLMatch(at: url) else { return }
        directory.files.removeAll()
    }
    
    func deleteFile( _ file: File ) {
        
        guard let directory = findFileURLMatch(at: file.data.path) else { return }
        guard let index = directory.files.firstIndex(where: { f in f.data.name == file.data.name }) else { return  }
        directory.files.remove(at: index)
        
    }
    
    //finds a directory at the url, if it doesnt it exist it may be created
    private func findFileURLMatch(at url: FileURL, createDirectory: Bool = false ) -> Directory? {
        
        if url.head.name == "main" && url.head.next == nil { return main }
        
        guard let firstNode = url.head.next else { URLNotFound(url: url); return nil }
        guard let directory = main.findFileURLMatch(at: firstNode, fullURL: url, createDirectory: createDirectory) else { URLNotFound(url: url); return nil }
        return directory
        
    }
    
    private func URLNotFound( url: FileURL ) { print( "Error 1: File URL note found: \(url.string())" ) }

    


}

class Directory: ObservableObject {
    
    let url: FileURL
    
    var name: String { url.tail.name }
    
    var directories: [ Directory ] = []
    
    var files: [ File ] = []
    
    init( at path: FileURL ) {
        self.url = path
    }
    
    init( at path: FileURL, with files: [ File ] ) {
        self.url = path
        self.files = files
    }
    
    //url: the link of the url to compare agains the directories, fullURL: the path of the file trying to be found
    func findFileURLMatch(at url: FileURLNode, fullURL: FileURL, createDirectory: Bool) -> Directory? {
        
        for directory in directories {
            if directory.name == url.name {
                if url.next == nil { return directory }
                else { return directory.findFileURLMatch(at: url.next!, fullURL: fullURL, createDirectory: createDirectory ) }
            }
        }
        if createDirectory {
            let newDirectory = Directory(at: fullURL)
            self.directories.append(newDirectory)
        
            if url.next == nil { return newDirectory }
            else { return newDirectory.findFileURLMatch(at: url.next!, fullURL: fullURL, createDirectory: createDirectory) }
        }
        
        return nil
    }
    
    func string() {
        
        print("Directory at: \( url.string() )\nFiles:")
        for file in files {
            print("\(file.data.name) at: \(file.data.path.string(withFileName: true))")
        }
        print("\nDirectories:")
        for directory in directories {
            print( "\(directory.url.string())" )
        }
        print("\n")
    
        
    }
}
