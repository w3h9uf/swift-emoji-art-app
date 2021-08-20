//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/26/21.
//

import SwiftUI

struct OptionalImage: View {
  var uiImage: UIImage?
  
  var body: some View {
    if uiImage != nil {
      Image(uiImage: uiImage!)
    }
  }
}


struct AnimatedActionButton: View {
  var title: String? = nil
  var systemImage: String? = nil
  let action: () -> Void
  
  var body: some View {
    Button {
      withAnimation {
        action()
      }
    } label: {
      if title != nil && systemImage != nil {
        Label(title!, systemImage: systemImage!)
      } else if title != nil {
        Text(title!)
      } else if systemImage != nil {
        Image(systemName: systemImage!)
      }
    }
  }
}


struct IdentifiableAlert: Identifiable {
  var id: String
  var alert: () -> Alert
}


struct UndoButton: View {
    let undo: String?
    let redo: String?
    
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        let canUndo = undoManager?.canUndo ?? false
        let canRedo = undoManager?.canRedo ?? false
        if canUndo || canRedo {
            Button {
                if canUndo {
                    undoManager?.undo()
                } else {
                    undoManager?.redo()
                }
            } label: {
                if canUndo {
                    Image(systemName: "arrow.uturn.backward.circle")
                } else {
                    Image(systemName: "arrow.uturn.forward.circle")
                }
            }
                .contextMenu {
                    if canUndo {
                        Button {
                            undoManager?.undo()
                        } label: {
                            Label(undo ?? "Undo", systemImage: "arrow.uturn.backward")
                        }
                    }
                    if canRedo {
                        Button {
                            undoManager?.redo()
                        } label: {
                            Label(redo ?? "Redo", systemImage: "arrow.uturn.forward")
                        }
                    }
                }
        }
    }
}

extension UndoManager {
    var optionalUndoMenuItemTitle: String? {
        canUndo ? undoMenuItemTitle : nil
    }
    var optionalRedoMenuItemTitle: String? {
        canRedo ? redoMenuItemTitle : nil
    }
}

extension View {
  @ViewBuilder
  func wrappedInNavigationViewToMakeDismissable(_ dismiss: (() -> Void)?) -> some View {
    if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
      NavigationView {
        self
          .navigationBarTitleDisplayMode(.inline)
          .dismissable(dismiss)
      }
      .navigationViewStyle(StackNavigationViewStyle())
    } else {
      self
    }
  }
  
  @ViewBuilder
  func dismissable(_ dismiss: (() -> Void)?) -> some View {
    if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
      self.toolbar(content: {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
        }
      })
    } else {
      self
    }
  }
}
