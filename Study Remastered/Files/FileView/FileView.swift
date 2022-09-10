//
//  FileView.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI


struct FileView: View {
    
    enum TriggerType {
        case none
        case directory
        case file
        case moveFile
        case moveDirectory
    }
    
    enum FileViewType {
        case column
        case list
    }
    
    @EnvironmentObject var fileManager: FileManager
    
    @State var fileViewType: FileViewType = .column
    
    @State var url: FileURL
    @State var activeFile: String = ""
    
    @State var enteredText: String = ""
    @State var trigger: TriggerType = .none
    
    private func checkDirectoryName() -> Bool {
        if enteredText.isEmpty { return false }
        
        let directory = fileManager[ url ]
        let containerDirectory = directory.getContainerDirectory()
        
        for dir in containerDirectory.directories { if dir.name == enteredText { return false } }
        for file in containerDirectory.files { if file.data.name == enteredText { return false } }
        return true
    }
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    
                    HStack {
                        NamedButton("list", and: "list.dash.header.rectangle", oriented: .vertical)
                            .onTapGesture { fileViewType = .list }
                            .foregroundColor( fileViewType == .list ? .primary : .gray )
                        
                        NamedButton("column", and: "rectangle.grid.1x2", oriented: .vertical)
                            .onTapGesture { fileViewType = .column }
                            .foregroundColor( fileViewType == .column ? .primary : .gray )
                    }
                    
                    
                    if fileViewType == .column { FileColumnView(activeURL: $url, activeFile: $activeFile, trigger: $trigger) }
                    if fileViewType == .list { FileListView(activeURL: $url, activeFile: $activeFile, trigger: $trigger, interactable: true) }
        
                    NamedButton("create Directory", and: "square.grid.3x1.folder.badge.plus", oriented: .horizontal)
                        .onTapGesture { FileManager.shared.createDirectory(at: url) }
                }
                
                if trigger == .file || trigger == .directory {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 5, x: 0, y: 0)

                        VStack {
                            TextField("Enter Text Here", text: $enteredText)
                            HStack {
                                NamedButton("done", and: "checkmark.square", oriented: .horizontal)
                                    .onTapGesture { if checkDirectoryName() {
                                        if trigger == .directory {
                                            url = fileManager.changeDirectoryName(at: url, to: enteredText)
                                        }
                                        if trigger == .file { fileManager.changeFileName(at: url, name: activeFile, to: enteredText) }
                                        trigger = .none
                                    } }
                                NamedButton("dismiss", and: "trash", oriented: .horizontal)
                                    .onTapGesture { trigger = .none }
                            }
                        }.padding()
                        
                    }.frame(width: geo.size.width * 0.65, height: geo.size.height * 0.15)
                }
            }
            .sheet(isPresented: .init(get: { trigger == .moveFile || trigger == .moveDirectory }, set: { _ in }) ) {
                FileMoverView( activeURL: $url, activeFile: $activeFile, trigger: $trigger, oldURL: url )
            }
        }
    }
}

struct FileMoverView: View {
    
    @Binding var activeURL: FileURL
    @Binding var activeFile: String
    
    @Binding var trigger: FileView.TriggerType
    
    @State var oldURL: FileURL
    @State var error: String = ""
    
    var body: some View {
        
        VStack {
            
            ZStack(alignment: .top) {
                NamedButton("Move Folder", and: "folder.badge.questionmark", oriented: .horizontal, reversed: true)
                
                HStack {
                    NamedButton("Cancel", and: "trash", oriented: .horizontal, reversed: true).onTapGesture { trigger = .none }
                    Spacer()
                    NamedButton("done", and: "checkmark.seal", oriented: .horizontal)
                        .onTapGesture {
                            
                            let result = FileManager.shared.checkMoveAction(from: oldURL, to: activeURL, fileName: trigger == .moveFile ? activeFile : nil)
                            if result.0 {
                            
                                if trigger == .moveFile { FileManager.shared.moveFile(from: oldURL, to: activeURL, fileName: activeFile) }
                                if trigger == .moveDirectory { FileManager.shared.moveDirectory(from: oldURL, to: activeURL) }

                                trigger = .none
                                
                            }else { error = result.1 }
                                
                        }
                }
            }.padding()
            
            if error != "" {
                NamedButton(error, and: "xmark.seal", oriented: .horizontal)
                    .foregroundColor(.red)
            }
            
            FileListView(activeURL: $activeURL, activeFile: $activeFile, trigger: $trigger, interactable: false)
        }
    }
}


