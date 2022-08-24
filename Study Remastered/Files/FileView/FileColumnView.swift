//
//  FileColumnView.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/22/22.
//

import Foundation
import SwiftUI

struct FileColumnView: View {
    
    @Binding var activeURL: FileURL
    @State var shownPaths: [ FileURL ] = []
    
    @Binding var activeFile: String
    @Binding var trigger: FileView.TriggerType
    
    var body: some View {
        
        GeometryReader { geo in
            ScrollView(.vertical) {
                VStack(spacing: DirectoryColumnView.Constants.space) {
                    ForEach( shownPaths.indices, id: \.self ) { index in
                        let url = shownPaths[index]
                        DirectoryColumnView(url: url, geo: geo, directory: FileManager.shared[url],
                                            activeURL: $activeURL,
                                            activeFile: $activeFile,
                                            trigger: $trigger)

                    }
                }
            }
        }
        .onAppear { shownPaths = activeURL.splitIntoURLs() }
        .onChange(of: activeURL) { newValue in shownPaths = newValue.splitIntoURLs() }
        
    }
    
    
    struct DirectoryColumnView: View {
        
        let url: FileURL
        let geo: GeometryProxy
        
        @ObservedObject var directory: Directory
        
        @Binding var activeURL: FileURL
        @Binding var activeFile: String
        @Binding var trigger: FileView.TriggerType
        
        var body: some View {
        
            VStack(spacing: 4) {
                
                Text( url.string(withFileName: true) )
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
//                let spacing = Constants.space * (Constants.numberPerRow + 1) + 50
//                let width = (geo.size.width - spacing) / Constants.numberPerRow
                let width = 78.75
                
                LazyVGrid(columns: [ .init(.adaptive(minimum: width, maximum: .infinity), spacing: Constants.space, alignment: .center) ], alignment: .leading, spacing: 10) {
                    
                    ForEach( directory.files, id: \.data.name ) { file in
                        IndividualFileView(file: file, displayType: .column,
                                           activeFile: $activeFile, trigger: $trigger, interactable: true)
                        .aspectRatio(Constants.ratio, contentMode: .fit)
                    }
//
                    ForEach( directory.directories, id: \.name ) { directory in
                        IndividualDirectoryView(directory: directory, displayType: .column, activeURL: $activeURL, trigger: $trigger, interactable: true)
                            { activeURL = directory.url }
                            .aspectRatio(Constants.ratio, contentMode: .fit)

                    }
                }
            }
            .padding(Constants.space)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke())
            .padding(Constants.space)
            
        }
        
        struct Constants {
            static let numberPerRow: CGFloat = 4
            static let space: CGFloat = 5
            static let ratio: CGFloat = 5/6
        }
    }
}
