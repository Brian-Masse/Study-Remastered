//
//  FileView.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/7/22.
//

import Foundation
import SwiftUI


struct FileView: View {
    
    let objects: [ File ]
    
    var body: some View {
        
        DirectoryView()
            .environmentObject( DirectoryManager(path: mainDirectory, passedObjects: data) )
        
    }
}



struct DirectoryView: View {
    
    @EnvironmentObject var directoryManager: DirectoryManager
    
    var body: some View {
        
        VStack {
            
            HStack {
                ForEach( directoryManager.objects ) { object in
                    VStack {
                        Text( object.name )
                        Text( object.path.string() )
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke())
                }
            }
            
            Text("sync test to realm")
                .onTapGesture {
                    RealmManager.shared.saveSequenceToRealm( dummyData )
                }
            
            Text("In SubFolders")
            
            HStack {
                ForEach( directoryManager.containedObjects ) { object in
                    VStack {
                        Text( object.name )
                        Text( object.path.string() )
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke())
                }
            }
            
        }
        
    }
    
}
