//
//  FileURL.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI
import Combine

//MARK: FILEURL
///when this list grows / shrinks, the file name must be given to the tail to ensure proper comparison
///this only happens in append as of now
class FileURL: Equatable, Codable { //acts as a linked list
    
    enum MatchType: String {
        case equals
        case firstInSecond
        case secondInFirst
        case forked
    }
    
    private(set) var file: String? = nil
    @Published var head: FileURLNode!
    @Published var tail: FileURLNode!
    
//    { didSet { length = getLength() }}
//    lazy var length: Int = getLength()
    
    //MARK: Init
    init( head: String ) {
        let node = FileURLNode( head )
        self.head = node
        self.tail = node
    }
    
    init(_ components: [ String ]) {
        linkList(components)
    }

    init(startPath: FileURL, adding name: String) {
        let copy = startPath.copy()
        
        copy.append( name )

        self.head = copy.head
        self.tail = copy.tail
    }
    
    private func linkList( _ list: [ String ] ) {
        
        //goes through componetns and links them
        if list.isEmpty { return }
        self.head = FileURLNode( list.first! )
        var node = self.head
        
        for index in 1..<list.count {
            node!.next = FileURLNode( list[index] )
            node = node!.next
        }
        
        node!.file = file
        self.tail = node
    }
    
    ///creates a list containg a URL of every link in this URL object
    ///ie. /main/second -> [ /main, /main/second ]
    ///this is used for displaying all directories in the UI
    func splitIntoURLs() -> [ FileURL ] {
        
        let url = FileURL( [] )
        var returning: [FileURL] = []
        
        loopThrough { node in
            url.append(node.name)
            returning.append(url.copy())
        }

        return returning
    }
    
    func setFile(with file: String?) {
        self.file = file
        guard let tail = self.tail else { return }
        tail.file = file
    }
    
    func string(withFileName: Bool = false) -> String {
        var base = ":"
        
        loopThrough { node in
            base += ("/" + node.name)
            if let file = node.file { if withFileName { base += "/\(file)" } }
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
    
    func removeLast() {
        
        if self.head == nil || self.head.next == nil { return }
        var node = self.head
        
        //this will stop when you are one before the tail
        while node!.next!.next != nil { node = node!.next }
        self.tail = node
        self.tail.file = file
        self.tail.next = nil
    }
    
    ///makes a copy sharing not pointers
    func copy() -> FileURL {
        let copy = FileURL(head: self.head.name)
        
        loopThrough(startAtHead: false) { node in
            let copiedNode = FileURLNode(node.name)
            copy.tail.next = copiedNode
            copy.tail = copiedNode
        }
        copy.setFile(with: file)
        return copy
    }
    
    private func loopThrough( startAtHead: Bool = true, _ action: ( FileURLNode ) -> Void ) {
        if self.head == nil { return }
        
        var node = self.head
        if !startAtHead { node = self.head!.next }
        
        while node != nil {
            action( node! )
            node = node!.next
        }
    }
    
    //MARK: Serialization
    
    enum CodingKeys: String, CodingKey {
        case names
        case file
    }
    
    func encode(to encoder: Encoder) throws {
    
        var strings: [String] = []
        loopThrough { node in strings.append( node.name ) }
        
        Utilities.shared.encodeData(strings, using: encoder, with: CodingKeys.names)
        Utilities.shared.encodeData(file, using: encoder, with: CodingKeys.file)
        
    }
    
    required init(from decoder: Decoder) throws {
    
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        let names: [String] = Utilities.shared.decodeData(in: values, with: CodingKeys.names, defaultValue: [])!
        self.file = Utilities.shared.decodeData(in: values, with: CodingKeys.names)
        
        linkList(names)
    }
    
    static func == (lhs: FileURL, rhs: FileURL) -> Bool { lhs.string() == rhs.string() }
}


//MARK: FileURLNode
/// if a `URLNode` has a non nil `file` property, then it will not be considered automatically when matching with other urls:
///:/main/second/third/fileName == :/main/second/third
class FileURLNode: Equatable, ObservableObject {

    var file: String? = nil
    @Published var name: String
    var next: FileURLNode?
    
    init(_ name: String, _ next: FileURLNode? = nil) {
        self.name = name
        self.next = next
    }
    
    static func == (lhs: FileURLNode, rhs: FileURLNode) -> Bool { lhs.name == rhs.name }
}
