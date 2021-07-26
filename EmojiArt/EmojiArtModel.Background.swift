//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Jizheng Yang on 7/25/21.
//

import Foundation


extension EmojiArtModel {
  
  enum Background {
    case blank
    case url(URL)
    case imageData(Data)
  
    var url: URL? {
      switch self {
      case .url(let url):
        return url
      default:
        return nil
      }
    }
    
    var imageData: Data? {
      switch self {
      case .imageData(let data):
        return data
      default:
        return nil
      }
    }
  }
}
