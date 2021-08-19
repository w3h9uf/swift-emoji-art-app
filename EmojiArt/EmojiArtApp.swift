//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  @StateObject var paletteStore = PaletteStore(named: "default")
  var body: some Scene {
    DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
      EmojiArtDocumentView(document: config.document)
            .environmentObject(paletteStore)
      }
  }
}
