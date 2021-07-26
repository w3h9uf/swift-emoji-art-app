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
