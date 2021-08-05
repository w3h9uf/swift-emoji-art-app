//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 8/3/21.
//

import SwiftUI

struct PaletteEditor: View {
  @Binding var palette: Palette
  
  var body: some View {
    Form {
      nameSection
      addEmojiSection
      removeEmojiSection
    }
    .frame(minWidth: 300, minHeight: 350)
  }
  
  var nameSection: some View {
    Section(header: Text("Name")) {
      TextField("Name", text: $palette.name)
    }
  }
  
  @State private var emojisToAdd = ""
  
  var addEmojiSection: some View {
    Section(header: Text("Add Emojis")) {
      TextField("", text: $emojisToAdd)
        .onChange(of: emojisToAdd) { emojis in
          addEmojis(emojis)
        }
    }
  }
  
  func addEmojis(_ emojis: String) {
    withAnimation {
      palette.emojis = (emojis + palette.emojis)
        .filter { $0.isEmoji }
        .removingDuplicateCharacters
    }
  }
  
  var removeEmojiSection: some View {
    Section(header: Text("Remove Emoji")) {
      let emojis = palette.emojis.removingDuplicateCharacters.map { String($0) }
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], content: {
        ForEach(emojis, id: \.self) { emoji in
          Text(emoji)
            .onTapGesture(perform: {
              withAnimation {
                palette.emojis.removeAll(where: { String($0) == emoji })
              }
            })
        }
      })
      .font(.system(size: 40))
    }
  }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
      PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 4)))
    }
}
