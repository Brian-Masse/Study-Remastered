//
//  FileManager.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI
import Combine

//MARK: FileManager
class FileManager: ObservableObject {
    
    @Published var main: Directory = Directory(at: mainDirectory)
    
    static let shared: FileManager = FileManager()
    
    var observer: AnyCancellable!
    
    init() {
        self.observer = main.objectWillChange.sink() { self.objectWillChange.send() }
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
    
    func insertFile( _ file: File, createDirectory: Bool ) {
        guard let directory = findFileURLMatch(at: file.data.path, createDirectory: true) else { return }
        if file.data.name == HiddenFile.hiddenFileName { directory.hiddenFile = file }
        else { directory.files.append(file) }
    }
    
    //MARK: Delete Functions
    func deleteFiles( at url: FileURL ) {
        guard let directory = findFileURLMatch(at: url) else { return }
        directory.files.removeAll()
    }
    
    func deleteFile( at url: FileURL, name: String ) {
        
        guard let directory = findFileURLMatch(at: url) else { return }
        guard let index = directory.files.firstIndex(where: { f in f.data.name == name }) else { return  }
        directory.files.remove(at: index)
    }
    
    func deleteDirectory( at url: FileURL ) {
        guard let directory = findFileURLMatch(at: url) else { return }
        let containingDirectory = directory.getContainerDirectory()
        
        moveContentsOfDirectory(directory, to: containingDirectory.url)
        directory.files.removeAll()
        directory.directories.removeAll()
        directory.hiddenFile.data.delete()
        
        guard let index = containingDirectory.directories.firstIndex(where: { dir in dir.name == directory.name }) else { return }
        containingDirectory.directories.remove(at: index)
    }
    
    func clearFileManager() {
        main.clearDirectory()
    }
    
    // MARK: Create Functions

    func createDirectory(at url: FileURL) {
        let testName = UUID().uuidString
        
        let newURL = FileURL(startPath: url, adding: testName)
        let hiddenFile = HiddenFile(at: newURL)
        self.insertFile( File(hiddenFile), createDirectory: true)
    }
    
    //MARK: Change Functions
    
    func changeDirectoryName(at url: FileURL, to newName: String) -> FileURL {
        
        guard let directory = findFileURLMatch(at: url) else { return mainDirectory }
        
        let containingURL = directory.getContainerDirectory().url
        
        return directory.changeURL(with: containingURL, name: newName)
    }
    
    func changeFileName( at url: FileURL, name: String, to newName: String ) {
        guard let directory = findFileURLMatch(at: url) else { return }
        guard let file = directory.files.first(where: { file in file.data.name == name }) else { return }
        
        file.data.changeName(newName)
        file.data.path.setFile(with: newName)
    }
    
    
    //MARK: Move Functions
    
    func checkMoveAction( from url: FileURL, to newURL: FileURL, fileName: String? ) -> (Bool, String) {
        
        let oldDirectory = findFileURLMatch(at: url)!
        guard let newDirectory = findFileURLMatch(at: newURL) else { return ( false, "cannot find new directory" ) }
        
        if let name = fileName {
            for file in newDirectory.files {
                if file.data.name == name { return ( false, "File Already Exists There with the Name \(name)" ) }
            }
        } else {
    
            // check that the newURL is not inside of the old one
            let subDirectories = newURL.splitIntoURLs()
            for subDirectory in subDirectories {
                if subDirectory.string() == url.string() { return ( false, "Cannot Put a Directoy Inside Itself" ) }
            }
            
            for directory in newDirectory.directories {
                if directory.name == oldDirectory.name { return ( false, "Directory Already Exists There with the Name \(directory.name)" ) }
            }
        }
            
        return (true, "")
    }
    
    func moveDirectory(from url: FileURL, to newURL: FileURL)  {
        
        guard let directory = findFileURLMatch(at: url) else { return }
        guard let newDirectory = findFileURLMatch(at: newURL) else { return }
        let containingDirectory = directory.getContainerDirectory()
        
        guard let index = containingDirectory.directories.firstIndex(where: { dir in dir.name == directory.name }) else { return }
        containingDirectory.directories.remove(at: index)
        
        newDirectory.directories.append( directory )
        let _ = directory.changeURL(with: newURL)
        
    
    }
    
    func moveFile( from url: FileURL, to newURL: FileURL, fileName: String ) {
        
        guard let directory = findFileURLMatch(at: url) else { return }
        guard let index = directory.files.firstIndex(where: { file in file.data.name == fileName }) else { return }
        
        let file = directory.files[index]
        directory.files.remove(at: index)
        
        file.data.changeURL(with: newURL)
        insertFile(file, createDirectory: false)
    }
    
    private func moveContentsOfDirectory( _ directory: Directory, to url: FileURL ) {
        
        guard let newDirectory = findFileURLMatch(at: url) else { return }
        
        for directory in directory.directories { let _ = directory.changeURL(with: url) }
        for file in directory.files { file.data.changeURL(with: url) }
        
        newDirectory.directories.append(contentsOf: directory.directories )
        newDirectory.files.append(contentsOf: directory.files )
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

//MARK: Directory
class Directory: ObservableObject {
    
    @Published private(set) var url: FileURL
    
    var name: String { url.tail.name }
    
    @Published var directories: [ Directory ] = []
    @Published var files: [ File ] = []
    
    var hiddenFile: File!
    
    var observer: AnyCancellable!
    
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
    
    func getContainerDirectory() -> Directory {
        let containingURL = url.copy()
        containingURL.removeLast()
        return FileManager.shared[containingURL]
    }
    
    func changeURL(with url: FileURL, name: String? = nil) -> FileURL {
        let newURL = FileURL(startPath: url, adding: name == nil ? self.name : name!  )
        for file in files { file.data.changeURL(with: newURL) }
        for directory in directories { let _ = directory.changeURL(with: newURL) }
        hiddenFile.data.changeURL(with: newURL)
        
        self.url = newURL
        return newURL
    }
    
    func delete() {
        FileManager.shared.deleteDirectory(at: url)
    }
    
    func clearDirectory() {
        
        files.removeAll()
        for directory in directories {
            directory.clearDirectory()
        }
        directories.removeAll()
        
    }
    
    func string() {
        
        print("Directory at: \( url.string() ) [\(TextFieldViewController.getMemoryAdress(of: self))]\nFiles:")
        for file in files {
            print("\(file.data.name) at: \(file.data.path.string(withFileName: true))")
        }
        print("\nDirectories:")
        for directory in directories {
            print( "\(directory.url.string()) [\(TextFieldViewController.getMemoryAdress(of: directory))]" )
        }
        print("\n")
    
        
    }
}
