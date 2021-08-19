//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
  static let emojiart = UTType(exportedAs: "com.jasonyangjizheng.EmojiArt")
}

class EmojiArtDocument: ReferenceFileDocument {
  static var readableContentTypes = [UTType.emojiart]
  static var writableContentTypes = [UTType.emojiart]
  
  required init(configuration: ReadConfiguration) throws {
    if let data = configuration.file.regularFileContents {
      emojiArt = try EmojiArtModel(json: data)
      fetchBackgroundImageDataIfNeccessary()
    } else {
      throw CocoaError(.fileReadCorruptFile)
    }
  }
  
  func snapshot(contentType: UTType) throws -> Data {
    try emojiArt.json()
  }
  
  func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
    FileWrapper(regularFileWithContents: snapshot)
  }
  
  @Published private(set) var emojiArt: EmojiArtModel {
    didSet {
      //scheduleAutosave()
      if emojiArt.background != oldValue.background {
        fetchBackgroundImageDataIfNeccessary()
      }
    }
  }
  
  init() {
//    if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
//      emojiArt = autosavedEmojiArt
//      fetchBackgroundImageDataIfNeccessary()
//    } else {
      emojiArt = EmojiArtModel()
//    }
  }
  
//  private struct Autosave {
//    static let filename = "Autosave.emojiart"
//    static var url: URL? {
//      let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//      return documentDirectory?.appendingPathComponent(filename)
//    }
//    static let coalescingInterval = 5.0
//  }
//
//  private var autosaveTimer: Timer?
//
//  private func scheduleAutosave() {
//    autosaveTimer?.invalidate()
//    autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
//      self.autosave()
//    }
//  }
//  private func autosave() {
//    if let url = Autosave.url {
//      save(to: url)
//    }
//  }
//
//  private func save(to url: URL) {
//    let thisFunction = "\(String(describing: self)).\(#function)"
//    do {
//      let data: Data = try emojiArt.json()
//      print("\(thisFunction) jason = \(String(data: data, encoding: .utf8) ?? "nil")")
//      try data.write(to: url)
//      print("\(thisFunction) succeeded")
//    }
//    catch let encodingError where encodingError is EncodingError {
//      print("\(thisFunction) cannot encode EmojiArt into JSON because \(encodingError.localizedDescription)")
//    }
//    catch {
//      print("Failed to \(thisFunction), error = \(error)")
//    }
//  }
  
  var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
  var background: EmojiArtModel.Background { emojiArt.background }
  
  @Published var backgroundImage: UIImage?
  @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
  
  enum BackgroundImageFetchStatus: Equatable {
    case idle
    case fectching
    case failed(URL)
  }
  
  private var backgroundImageFetchCancellable: AnyCancellable?
  
  private func fetchBackgroundImageDataIfNeccessary() {
    backgroundImage = nil
    switch emojiArt.background {
    case .url(let url):
      // fetch the url
      self.backgroundImageFetchStatus = .fectching
//      DispatchQueue.global(qos: .userInitiated).async {
//        let imageData = try? Data(contentsOf: url)
//        DispatchQueue.main.async { [weak self] in
//          // publishing changes in background thread is not allowed (can cause unpredictable UI behavior)
//          // put the publishing operation back to main queue.
//          self?.backgroundImageFetchStatus = .idle
//          if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
//            if imageData != nil {
//              self?.backgroundImage = UIImage(data: imageData!)
//            }
//            if self?.backgroundImage == nil {
//              self?.backgroundImageFetchStatus = .failed(url)
//            }
//          }
//        }
//              }
      backgroundImageFetchCancellable?.cancel()
      let session = URLSession.shared
      let publisher = session.dataTaskPublisher(for: url)
        .map { (data, urlResponse) in UIImage(data: data) }
        .replaceError(with: nil)
        .receive(on: DispatchQueue.main)
      backgroundImageFetchCancellable = publisher
//        .assign(to: \EmojiArtDocument.backgroundImage, on: self)
        .sink {
          [weak self] image in
          self?.backgroundImage = image
          self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
        }
      
    case .imageData(let data):
      backgroundImage = UIImage(data: data)
    case .blank:
      break
    }
  }
  
  // MARK: - Intent(s)
  
  func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?) {
    undoablyPerform(operation: "Set Background", with: undoManager) {
      emojiArt.background = background
    }
    emojiArt.background = background
    print("backgound set to \(background)")
  }
  
  func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager: UndoManager?) {
    emojiArt.addEmoji(emoji, at: location, size: Int(size))
  }
  
  func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
    if let index = emojis.index(matching: emoji) {
      emojiArt.emojis[index].x += Int(offset.width)
      emojiArt.emojis[index].y += Int(offset.height)
    }
  }
  
  func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
    if let index = emojis.index(matching: emoji) {
      emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
    }
  }
  
  // MARK: - Undo
  
  private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
    let oldEmojiArt = emojiArt
    doit()
    undoManager?.registerUndo(withTarget: self) { myself in
      myself.undoablyPerform(operation: operation, with: undoManager) {
        myself.emojiArt = oldEmojiArt
      }
      myself.emojiArt = oldEmojiArt
    }
    undoManager?.setActionName(operation)
  }
}


