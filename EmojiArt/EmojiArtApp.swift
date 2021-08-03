//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  @StateObject var document = EmojiArtDocument()
  @StateObject var paletteStore = PaletteStore(named: "default")
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
              .environmentObject(paletteStore)
        }
    }
}
