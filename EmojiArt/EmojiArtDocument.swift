//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import SwiftUI


class EmojiArtDocument: ObservableObject {
  @Published private(set) var emojiArt: EmojiArtModel {
    didSet {
      if emojiArt.background != oldValue.background {
        fetchBackgroundImageDataIfNeccessary()
      }
    }
  }
  
  init() {
    emojiArt = EmojiArtModel()
//    emojiArt.addEmoji("😬", at: (100, 200), size: 70)
//    emojiArt.addEmoji("🙌", at: (-100, -200), size: 100)
  }
  
  var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
  var background: EmojiArtModel.Background { emojiArt.background }
  
  @Published var backgroundImage: UIImage?
  @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
  
  enum BackgroundImageFetchStatus {
    case idle
    case fectching
  }
  
  private func fetchBackgroundImageDataIfNeccessary() {
    backgroundImage = nil
    switch emojiArt.background {
    case .url(let url):
      // fetch the url
      DispatchQueue.global(qos: .userInitiated).async {
        self.backgroundImageFetchStatus = .fectching
        let imageData = try? Data(contentsOf: url)
        DispatchQueue.main.async { [weak self] in
          self?.backgroundImageFetchStatus = .idle
          if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
            if imageData != nil {
              self?.backgroundImage = UIImage(data: imageData!)
            }
          }
        }
              }
    case .imageData(let data):
      backgroundImage = UIImage(data: data)
    case .blank:
      break
    }
  }
  
  // MARK: - Intent(s)
  
  func setBackground(_ background: EmojiArtModel.Background) {
    emojiArt.background = background
    print("backgound set to \(background)")
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
