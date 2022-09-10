//
//  IndividualFileView.swift
//  Study Remastered
//
//  Created by Brian Masse on 8/22/22.
//

import Foundation
import SwiftUI

//MARK: File
struct IndividualFileView: View {
    
    let file: File
    let displayType: FileView.FileViewType

    @Binding var activeURL: FileURL
    @Binding var activeFile: String
    @Binding var trigger: FileView.TriggerType
    
    @State var displayView: Bool = false
    
    @ObservedObject var viewWrapper: ViewWrapper = ViewWrapper()
    
    class ViewWrapper: ObservableObject {
        @Published var view: AnyView!
    }
    
    let interactable: Bool
    
    var body: some View {
    
        FileItemView(name: file.data.name, icon: file.data.icon, url: file.data.path,
                     backgroundColor: .clear,
                     displayType: displayType)
        
        .onTapGesture() {
            if let view = file.data.tapGesture() {
                viewWrapper.view = view
                displayView = true
            }
        }
        .contextMenu {
            if interactable {
                Button {
                    activeURL = file.data.path
                    activeFile = file.data.name
                    trigger = .file
                } label: { NamedLabel("Rename File", and: "square.and.pencil") }
                Button {
                    activeURL = file.data.path
                    activeFile = file.data.name
                    trigger = .moveFile
                } label: { NamedLabel("Move File", and: "arrow.up.arrow.down") }
                Button(role: .destructive) {
                    file.data.delete()
                } label: { NamedLabel("Delete File", and: "trash") }
            }
        }
        .fullScreenCover(isPresented: $displayView) { viewWrapper.view }
    }
}


//MARK: Directory
struct IndividualDirectoryView: View {
    
    let directory: Directory
    let displayType: FileView.FileViewType

    @Binding var activeURL: FileURL
    @Binding var trigger: FileView.TriggerType
    
    let interactable: Bool
    
    let tapGesture: () -> Void
    
    private func isActive() -> Bool {
        return activeURL.string() == directory.url.string()
    }
    
    var body: some View {
    
        FileItemView(name: directory.name, icon: "tray.2", url: directory.url,
                     backgroundColor: isActive() ? .blue : Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.15),
                     displayType: displayType)
        
        .onTapGesture {
            activeURL = directory.url
            tapGesture()
        }
        .contextMenu {
            if interactable {
                Button {
                    activeURL = directory.url
                    trigger = .directory
                } label: { NamedLabel("Rename Group", and: "square.and.pencil") }
                Button {
                    activeURL = directory.url
                    trigger = .moveDirectory
                } label: { NamedLabel("Move Group", and: "arrow.up.arrow.down") }
                Button {
                    activeURL = directory.getContainerDirectory().url
                    directory.delete()
                } label: { NamedLabel("Delete Group", and: "trash") }
            }
        }
    }
}


struct FileItemView: View {
    
    let name: String
    let icon: String
    let url: FileURL
    
    let backgroundColor: Color
    
    let displayType: FileView.FileViewType
    
    var body: some View {
        ZStack {
            if displayType == .column {
                RoundedRectangle(cornerRadius: 15).stroke()
                
                VStack {
                    Text( name )
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.7)
                        .padding(.top, 5)
                    
                    Spacer()
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 34)
                    Spacer()
                    
                    Text( url.string(withFileName: true) )
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(3)
                }.padding(5)
            }
            
            if displayType == .list {
                HStack(spacing: 3) {
                    
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .padding(3)
                    
                    Text(name)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Spacer()
                    Text( url.string() )
                        .font(.custom("", size: 13))
//                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .padding(5)
            }
        }
        .background(RoundedRectangle(cornerRadius: 15).foregroundColor( backgroundColor ))
    }
}
