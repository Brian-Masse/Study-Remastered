//
//  FileURL.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI

///when this list grows / shrinks, the file name must be given to the tail to ensure proper comparison
///this only happens in append as of now
class FileURL: Equatable { //acts as a linked list
    
    
    enum MatchType: String {
        case equals
        case firstInSecond
        case secondInFirst
        case forked
    }
    
    private(set) var file: String? = nil
    var head: FileURLNode!
    var tail: FileURLNode!
//    { didSet { length = getLength() }}
//    lazy var length: Int = getLength()
    
    init( head: String ) {
        let node = FileURLNode( head )
        self.head = node
        self.tail = node
    }
    
    init(_ components: [ String ]) {
        //goes through componetns and links them
        if !components.isEmpty {
            for index in components.indices {
                
                let node = FileURLNode(components[index])
                
                if index == 0 {
                    self.head = node
                    self.tail = node
                }else {
                    self.tail.next = node
                    self.tail = node
                }
            }
        }
    }

    init(startPath: FileURL, adding name: String) {
        let copy = startPath.copy()
        
        copy.append( name )

        self.head = copy.head
        self.tail = copy.tail
    }
    
    private func getLength() -> Int {
        var count = 0
        var node = self.head
        while node != nil {
            count += 1
            node = node!.next
        }
        return count
    }
    
    ///creates a list containg a URL of every link in this URL object
    ///ie. /main/second -> [ /main, /main/second ]
    ///this is used for displaying all directories in the UI
    func splitIntoURLs() -> [ FileURL ] {
        
        var node = self.head
        let url = FileURL( [] )
        var returning: [FileURL] = []
        
        while node != nil {
            url.append(node!.name)
            returning.append(url.copy())
            node = node!.next
        }
        return returning
    }
    
    ///this should only be used when copying
    private func setFile(with file: String?) {
        self.file = file
        guard let tail = self.tail else { return }
        tail.file = file
    }
    
    func string(withFileName: Bool = false) -> String {
        var base = ":"
        var node: FileURLNode? = self.head
        
        while node != nil {
            
            base += ("/" + node!.name)
            
            if let file = node?.file { if withFileName { base += file } }
            node = node!.next
        }
    
        return base
    }
    
    func append( _ component: String ) {
        let node = FileURLNode(component)
        if self.tail == nil {
            self.head = node
            self.tail = node
        }
        else { self.tail.next = node }
        self.tail.file = nil
        self.tail = node
        self.tail.file = file
    }
    
    func matches(secondURL: FileURL) -> (Int, FileURL.MatchType) {
        
        var matchCount = 0
        var node: FileURLNode? = self.head
        var secondNode: FileURLNode? = secondURL.head
        
        while node != nil {
            
            if secondNode == nil { return ( matchCount, .secondInFirst ) }
            
            if node == secondNode { matchCount += 1 }
            else { return ( matchCount, .forked ) }
            
            node = node!.next
            secondNode = secondNode!.next
        }
        if secondNode == nil { return ( matchCount, .equals )  }
        return ( matchCount, .firstInSecond )
    }
    
    ///makes a copy sharing not pointers
    func copy() -> FileURL {
        
        let copy = FileURL(head: self.head.name)
        var node: FileURLNode? = self.head.next
        
        while node != nil {
            let copiedNode = FileURLNode(node!.name)
            copy.tail.next = copiedNode
            copy.tail = copiedNode
            
            node = node!.next
        }
        
        copy.setFile(with: file)
        return copy
    }
    
    static func == (lhs: FileURL, rhs: FileURL) -> Bool { lhs.matches(secondURL: rhs).1 == .equals }
}


/// if a `URLNode` has a non nil `file` property, then it will not be considered automatically when matching with other urls:
///:/main/second/third/fileName == :/main/second/third
class FileURLNode: Equatable {

    var file: String? = nil
    var name: String
    var next: FileURLNode?
    
    init(_ name: String, _ next: FileURLNode? = nil) {
        self.name = name
        self.next = next
    }
    
    static func == (lhs: FileURLNode, rhs: FileURLNode) -> Bool { lhs.name == rhs.name }
}
