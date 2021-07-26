//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  let document = EmojiArtDocument()
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
