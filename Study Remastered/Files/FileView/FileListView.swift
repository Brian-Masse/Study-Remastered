//
//  FileListView.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/22/22.
//

import Foundation
import SwiftUI

struct FileListView: View {
    
    @EnvironmentObject var fileManager: FileManager
    
    @Binding var activeURL: FileURL
    @Binding var activeFile: String
    
    @Binding var trigger: FileView.TriggerType
    
    let interactable: Bool
    
    var body: some View {
        
        GeometryReader { geo in
            ScrollView(.vertical) {
                VStack {
                    DirectoryListView(directory: fileManager.main, activeURL: $activeURL,
                                      activeFile: $activeFile, trigger: $trigger, interactable: interactable)
                }
                .padding()
            }
            .background(RoundedRectangle(cornerRadius: 15).stroke())
            .padding(3)
        }
    }
    
    struct DirectoryListView: View {
        
        @ObservedObject var directory: Directory
        @State var collapsed = true
        
        @Binding var activeURL: FileURL
        @Binding var activeFile: String
        
        @Binding var trigger: FileView.TriggerType
        
        let interactable: Bool
        
        var body: some View {
            
            VStack(alignment: .leading) {
                
                IndividualDirectoryView(directory: directory, displayType: .list, activeURL: $activeURL, trigger: $trigger, interactable: interactable)
                { collapsed.toggle() }
                
                VStack(alignment: .leading) {
                    if !collapsed {
                        ForEach( directory.directories.indices, id: \.self ) { index in
                            DirectoryListView(directory: directory.directories[index], activeURL: $activeURL, activeFile: $activeFile, trigger: $trigger, interactable: interactable)
                        }
                        
                        ForEach( directory.files.indices, id: \.self ) { index in
                            IndividualFileView(file: directory.files[index], displayType: .list,
                                               activeFile: $activeFile, trigger: $trigger, interactable: interactable)
                        }
                    }
                }
                .padding(.leading, 20)
            }
        }
    }
}
