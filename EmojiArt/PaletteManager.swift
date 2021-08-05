//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 8/4/21.
//

import SwiftUI

struct PaletteManager: View {
  @EnvironmentObject var store: PaletteStore
  
    var body: some View {
      NavigationView {
        List {
          ForEach(store.palettes) { palette in
            NavigationLink(
              destination: PaletteEditor(palette: $store.palettes[palette])) {
                VStack(alignment: .leading) {
                  Text(palette.name)
                  Text(palette.emojis)
                }
              }
          }
        }
        .navigationTitle("Manage Palette")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
}

//struct PaletteManager_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteManager()
//    }
//}
