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


extension CGSize {
  var center: CGPoint {
    CGPoint(x: width/2, y: height/2)
  }
  
  static func +(lhs: Self, rhs: Self) -> CGSize {
    CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
  }
  
  static func -(lhs: Self, rhs: Self) -> CGSize {
    CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
  }
  
  static func *(lhs: Self, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
  }
  
  static func /(lhs: Self, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
  }
}

extension String {
    var removingDuplicateCharacters: String {
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}

extension Character {
    var isEmoji: Bool {
        // Swift does not have a way to ask if a Character isEmoji
        // but it does let us check to see if our component scalars isEmoji
        // unfortunately unicode allows certain scalars (like 1)
        // to be modified by another scalar to become emoji (e.g. 1️⃣)
        // so the scalar "1" will report isEmoji = true
        // so we can't just check to see if the first scalar isEmoji
        // the quick and dirty here is to see if the scalar is at least the first true emoji we know of
        // (the start of the "miscellaneous items" section)
        // or check to see if this is a multiple scalar unicode sequence
        // (e.g. a 1 with a unicode modifier to force it to be presented as emoji 1️⃣)
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        }
    }

    subscript(_ element: Element) -> Element {
        get {
            if let index = index(matching: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = index(matching: element) {
                replaceSubrange(index...index, with: [newValue])
            }
        }
    }
}
