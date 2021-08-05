//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 8/4/21.
//

import SwiftUI

struct PaletteManager: View {
  @EnvironmentObject var store: PaletteStore
  @Environment(\.colorScheme) var colorScheme
  
  @State private var editMode: EditMode = .inactive
  @Environment(\.presentationMode) var presentationMode
  
    var body: some View {
      NavigationView {
        List {
          ForEach(store.palettes) { palette in
            NavigationLink(
              destination: PaletteEditor(palette: $store.palettes[palette])) {
                VStack(alignment: .leading) {
                  Text(palette.name).font(colorScheme == .dark ? .largeTitle : .caption)
                  Text(palette.emojis)
                }
              }
          }
          .onDelete { indexSet in
            store.palettes.remove(atOffsets: indexSet)
          }
          .onMove { indexSet, newOffset in
            store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
            
          }
        }
        .navigationTitle("Manage Palette")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem { EditButton() }
          ToolbarItem(placement: .navigationBarLeading) {
            if presentationMode.wrappedValue.isPresented,
               UIDevice.current.userInterfaceIdiom != .pad {
              Button("Close") {
                presentationMode.wrappedValue.dismiss()
              }
            }
          }
        }
        .environment(\.editMode, $editMode)
      }
    }
}

//struct PaletteManager_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteManager()
//    }
//}
