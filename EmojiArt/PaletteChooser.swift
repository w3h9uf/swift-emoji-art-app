//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 8/2/21.
//

import SwiftUI

struct PaletteChooser: View {
  var emojiFontSize: CGFloat = 40
  
  @EnvironmentObject var store: PaletteStore
  
  @State private var chosenPaletteIndex = 0
  
  var body: some View {
    HStack {
      paletteControlButton
      body(for: store.palette(at: chosenPaletteIndex))
    }
    .clipped()
  }
  
  var paletteControlButton: some View {
    Button {
      withAnimation {
        chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
      }
    } label: {
      Image(systemName: "paintpalette")
    }
    .font(.system(size: emojiFontSize))
    .contextMenu {
      contextMenu
    }
  }
  
  @ViewBuilder
  var contextMenu: some View {
    AnimatedActionButton(title: "Edit", systemImage: "pencil") {
      editing = true
    }
    AnimatedActionButton(title: "New", systemImage: "plus") {
      editing = true
      store.insertPalette(named: "New", emojis: "", at: chosenPaletteIndex)
    }
    AnimatedActionButton(title: "Delete", systemImage: "minus") {
      store.removePalette(at: chosenPaletteIndex)
    }
    gotoMenu
  }
  
  var gotoMenu: some View {
    Menu {
      ForEach(store.palettes) { palette in
        AnimatedActionButton(title: palette.name) {
          if let index = store.palettes.index(matching: palette) {
            chosenPaletteIndex = index
          }
        }
      }
      
    } label: {
      Label("Go To", systemImage: "text.insert")
    }
  }
  
  
  func body(for palette: Palette) -> some View {
    HStack {
      Text(palette.name)
      ScrollingEmojisView(emojis: palette.emojis)
          .font(.system(size: emojiFontSize))
    }
    // With id, the HStack gets removed and recreated once the id (i.e. palette id) changes
    // So that custom transition can happen
    .id(palette.id)
    .transition(rollTransition)
    .popover(isPresented: $editing) {
      PaletteEditor(palette: $store.palettes[chosenPaletteIndex])
    }
  }
  
  @State private var editing = false
  
  var rollTransition: AnyTransition {
    AnyTransition.asymmetric(insertion: .offset(x: 0, y: emojiFontSize),
                             removal: .offset(x: 0, y: -emojiFontSize))
  }
}

struct ScrollingEmojisView: View {
  let emojis: String
  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(emojis.map {String($0)}, id: \.self) { emoji in
          Text(emoji)
            .onDrag { NSItemProvider(object: emoji as NSString) }
        }
      }
    }
  }

}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
