//
//  FileView.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI


struct FileView: View {
    
    @State var url: FileURL
    
    @State var shownPaths: [FileURL]
    
    init( url: FileURL ) {
        self.url = url
        self.shownPaths = url.splitIntoURLs()
    }
    
    var body: some View {
        
        VStack {
            ForEach( shownPaths.indices, id: \.self ) { index in
                let url = shownPaths[index]
                DirectoryView(url: url, directory: FileManager.shared[url], activeURL: $url )
                
            }
            
        }
        .onChange(of: url) { newValue in
            shownPaths = newValue.splitIntoURLs()
        }
    }
    
    
}



struct DirectoryView: View {
    
    let url: FileURL
    
    @ObservedObject var directory: Directory
    @Binding var activeURL: FileURL
    
    var body: some View {
    
        VStack {
            
            Text( url.string(withFileName: true) )
            
            HStack {
                
                ForEach( directory.files, id: \.data.name ) { file in
                    
                    VStack {
                        Text( file.data.name )
                        Text( file.data.path.string() )
                        
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke())
                }
                
                ForEach( directory.directories, id: \.name ) { directory in
                    
                    VStack {
                        Text( directory.name )
                        Text( directory.url.string() )
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).foregroundColor(.gray)  )
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke())
                    .onTapGesture {
                        activeURL = directory.url
                    }
                }
            }
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 15).stroke())
        
    }
}
