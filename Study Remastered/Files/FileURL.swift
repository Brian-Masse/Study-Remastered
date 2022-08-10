//
//  FileURL.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI

class FileURL { //acts as a linked list
    
    enum MatchDirection: Int {
        case foward
        case backward
    }
    
    enum MatchType: String {
        case equals
        case firstInSecond
        case secondInFirst
        case forked
    }
    
    private(set) var file: String? = nil
    var head: FileURLNode!
    var tail: FileURLNode! { didSet { length = getLength() }}
    
    lazy var length: Int = getLength()
    
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
    
    func setFile(with file: String?) {
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
        self.tail.next = node
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
}

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


let mainDirectory = FileURL( [  "main" ] )
let first = FileURL(startPath: mainDirectory, adding: "first")
let second = FileURL(startPath: mainDirectory, adding: "second")
let third = FileURL(startPath: mainDirectory, adding: "third")
let final = FileURL(startPath: mainDirectory, adding: "final")

let data: [ File ] = [

    File("object1", at: first, ofType: .set),
    File("object2", at: second, ofType: .set),
    File("object4", at: third, ofType: .set),
    File("object5", at: final, ofType: .set)
                
]
