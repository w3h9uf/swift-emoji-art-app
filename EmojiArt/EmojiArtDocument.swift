//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import SwiftUI


class EmojiArtDocument: ObservableObject {
  @Published private(set) var emojiArt: EmojiArtModel
  
  init() {
    emojiArt = EmojiArtModel()
//    emojiArt.addEmoji("😬", at: (100, 200), size: 70)
//    emojiArt.addEmoji("🙌", at: (-100, -200), size: 100)
  }
  
  var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
  var background: EmojiArtModel.Background { emojiArt.background }
  
  // MARK: - Intent(s)
  
  func setBackground(_ background: EmojiArtModel.Background) {
    emojiArt.background = background
  }
  
  func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
    emojiArt.addEmoji(emoji, at: location, size: Int(size))
  }
  
  func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
    if let index = emojis.index(matching: emoji) {
      emojiArt.emojis[index].x += Int(offset.width)
      emojiArt.emojis[index].y += Int(offset.height)
    }
  }
  
  func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
    if let index = emojis.index(matching: emoji) {
      emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
    }
  }
}
