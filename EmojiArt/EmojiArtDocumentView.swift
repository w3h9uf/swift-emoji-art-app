//
//  ContentView.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
  @ObservedObject var document: EmojiArtDocument
    var body: some View {
      VStack(spacing: 0) {
        documentBody
        PaletteChooser(emojiFontSize: Constants.EmojiTextFont)
      }
    }
  
  var documentBody: some View {
    GeometryReader { geometry in
      ZStack {
        Color.yellow.overlay(
          OptionalImage(uiImage: document.backgroundImage)
            .scaleEffect(zoomScale)
            .position(convertFromEmojiCoordinates((0,0), in: geometry))
          //Image("test_bg").resizable().scaledToFill().position(convertFromEmojiCoordinates((0,0), in: geometry))
        )
        .gesture(doubleTapToZoom(in: geometry.size)
                  .exclusively(before: deselectAllEmojisGesture()))
        if document.backgroundImageFetchStatus == .fectching {
          ProgressView().scaleEffect(2)
        } else {
          ForEach(document.emojis) { emoji in
            Text(emoji.text)
              .border(Color.blue, width: emojiIsSelected(emoji) ? 2 : 0)
              .font(.system(size: fontSize(for: emoji)))
              .scaleEffect(zoomScale * (emojiIsSelected(emoji) ? gestureEmojiZoomScale : 1))
              .position(position(for: emoji, in: geometry))
              .gesture(selectGesture(for: emoji))
          }
        }
      }
      .clipped() // make sure the view not go beyond boundary
      .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
        return drop(providers: providers, at: location, in: geometry)
      }
      .gesture(panGesture().simultaneously(with: zoomGesture()))
      .alert(item: $alertToShow) { alertToShow in
        alertToShow.alert()
      }
      .onChange(of: document.backgroundImageFetchStatus) { status in
        switch status {
        case .failed(let url):
          showBackgroundImageFetchFailedAlert(url)
        default:
          break
        }
      }
      .onReceive(document.$backgroundImage, perform: { image in
        zoomToFit(image, in: geometry.size)
      })
    }
  }
  
  @State private var alertToShow: IdentifiableAlert?
  
  private func showBackgroundImageFetchFailedAlert(_ url: URL) {
    alertToShow = IdentifiableAlert(id: "fetch failed " + url.absoluteString) {
      Alert(title: Text("Background Image Fetch"),
            message: Text("Cound not load image from \(url)"),
            dismissButton: .default(Text("OK")))
    }
  }
  
  private struct Constants {
    static let EmojiTextFont: CGFloat = 60
  }
  

  private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
    CGFloat(emoji.size)
  }
  
  private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
    let center = geometry.frame(in: .local).center
    return CGPoint(x: center.x + CGFloat(emoji.x) * zoomScale + panOffset.width + (emojiIsSelected(emoji) ? gestureEmojiPanOffset.width : 0),
                   y: center.y + CGFloat(emoji.y) * zoomScale + panOffset.height + (emojiIsSelected(emoji) ? gestureEmojiPanOffset.height: 0))
  }
  
  private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
    let center = geometry.frame(in: .local).center
    return CGPoint(x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
                   y: center.y + CGFloat(location.y) * zoomScale + panOffset.height)
  }
  
  private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
    let center = geometry.frame(in: .local).center
    let location = CGPoint(x: (location.x - center.x - panOffset.width) / zoomScale,
                           y: (location.y - center.y - panOffset.height) / zoomScale)
    return (Int(location.x), Int(location.y))
  }
  
  private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
    var found = providers.loadObjects(ofType: URL.self) { url in
      document.setBackground(EmojiArtModel.Background.url(url.imageURL))
    }
    if !found {
      found = providers.loadObjects(ofType: UIImage.self) { image in
        if let data = image.jpegData(compressionQuality: 1.0) {
          document.setBackground(.imageData(data))
        }
      }
    }
    if !found {
      found = providers.loadObjects(ofType: String.self) { string in
        if let emoji = string.first {
          document.addEmoji(
            String(emoji),
            at: convertToEmojiCoordinates(location, in: geometry),
            size: Constants.EmojiTextFont / zoomScale)
        }
      }
    }
    return found
  }
  
  // MARK: - Pan Gesture
  @State private var steadyStatePanOffset: CGSize = CGSize.zero
  @GestureState private var gesturePanOffset: CGSize = CGSize.zero
  @GestureState private var gestureEmojiPanOffset: CGSize = CGSize.zero

  private var panOffset: CGSize {
    (steadyStatePanOffset + gesturePanOffset) * zoomScale
  }
  
  private func panGesture() -> some Gesture {
    if selectedEmoji.isEmpty {
      return DragGesture()
        .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
          gesturePanOffset = latestDragGestureValue.translation / zoomScale
        }
        .onEnded { finalDragGestureValue in
          steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
        }
    } else {
      return DragGesture()
        .updating($gestureEmojiPanOffset) { latestDragGestureValue, gestureEmojiPanOffset, _ in
          gestureEmojiPanOffset = latestDragGestureValue.translation / zoomScale / gestureEmojiZoomScale
        }
        .onEnded { finalDragGestureValue in
          for emoji in selectedEmoji {
            document.moveEmoji(emoji, by: finalDragGestureValue.translation / zoomScale / gestureEmojiZoomScale)
          }
        }
    }
  }
  
  // background zoom gesture
  // It makes sense to have zoomScale a UI state since it has nothing to do with model
  @State private var steadyStateZoomScale: CGFloat = 1
  @GestureState private var gestureZoomScale: CGFloat = 1
  @GestureState private var gestureEmojiZoomScale: CGFloat = 1
  
  private var zoomScale: CGFloat {
    gestureZoomScale * steadyStateZoomScale
  }
  
  private func doubleTapToZoom(in size: CGSize) -> some Gesture {
    TapGesture(count: 2)
      .onEnded {
        withAnimation {
          zoomToFit(document.backgroundImage, in: size)
        }
      }
  }
  
  private func zoomGesture() -> some Gesture {
    if selectedEmoji.isEmpty {
      return MagnificationGesture()
      .updating($gestureZoomScale) { latestZoomScale, gestureZoomScale/*this is an inout*/, transaction in
        gestureZoomScale = latestZoomScale
      }
      .onEnded { gestureScaleAtEnd in
        steadyStateZoomScale *= gestureScaleAtEnd
        
      }
    } else {
      return MagnificationGesture()
        .updating($gestureEmojiZoomScale) { latestZoomScale, gestureEmojiZoomScale/*this is an inout*/, transaction in
          gestureEmojiZoomScale = latestZoomScale
        }
        .onEnded { gestureScaleAtEnd in
          for emoji in selectedEmoji {
            document.scaleEmoji(emoji, by: gestureScaleAtEnd)
          }
        }
    }
  }
  
  private func zoomToFit(_ imageOrNil: UIImage?, in size: CGSize) {
    if let image = imageOrNil, image.size.width > 0,
       image.size.height > 0, size.width > 0, size.height > 0 {
      let hZoom = size.width / image.size.width
      let vZoom = size.width / image.size.height
      steadyStatePanOffset = .zero
      steadyStateZoomScale = min(hZoom, vZoom)
    }
  }
  
  // MARK: - Emoji Select Gesture
  @State private var selectedEmoji: Array<EmojiArtModel.Emoji> = []
  
  private func emojiIsSelected(_ emoji: EmojiArtModel.Emoji) -> Bool {
    return selectedEmoji.firstIndex(where: { $0.id == emoji.id }) != nil
  }
  
  private func selectGesture(for emoji: EmojiArtModel.Emoji) -> some Gesture {
    TapGesture()
      .onEnded {
        addOrDeleteSelectedEmoji(emoji)
      }
  }
  
  private func deselectAllEmojisGesture() -> some Gesture {
    TapGesture()
      .onEnded {
        selectedEmoji.removeAll()
      }
  }
  
  private func addOrDeleteSelectedEmoji(_ emoji: EmojiArtModel.Emoji) {
    if let index = selectedEmoji.firstIndex(where: { $0.id == emoji.id }) {
      selectedEmoji.remove(at: index)
    } else {
      selectedEmoji.append(emoji)
    }
  }
  


}

















struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
