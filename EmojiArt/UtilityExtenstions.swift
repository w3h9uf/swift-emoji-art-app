//
//  UtilityExtenstions.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import Foundation
import SwiftUI

extension Collection where Element: Identifiable {
  func index(matching element: Element) -> Self.Index? {
    firstIndex(where: { $0.id == element.id })
  }
}

extension CGRect {
  var center: CGPoint {
    CGPoint(x: midX, y: midY)
  }
}

extension Array where Element == NSItemProvider {
  func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
    if let provider = first(where: { $0.canLoadObject(ofClass: theType)}) {
      provider.loadObject(ofClass: theType) { object, error in
        if let value = object as? T {
          DispatchQueue.main.async {
              load(value)
          }
        }
      }
      return true
    }
    return false
  }
  
  func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool
    where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
    if let provider = first(where: { $0.canLoadObject(ofClass: theType)}) {
      let _ = provider.loadObject(ofClass: theType) { object, error in
         if let value = object {
          DispatchQueue.main.async {
              load(value)
          }
        }
      }
      return true
    }
    return false
  }
  
  func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
    loadObjects(ofType: theType, firstOnly: true, using: load)
  }
  
  func loadFirstObject<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool
    where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
    loadObjects(ofType: theType, firstOnly: true, using: load)
  }
}


extension URL {
  var imageURL: URL {
    for query in query?.components(separatedBy: "&") ?? [] {
      let queryComponents = query.components(separatedBy: "=")
      if queryComponents.count == 2 {
        if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
          return url
        }
      }
    }
    return baseURL ?? self
  }
}
