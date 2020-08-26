//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by 현기엽 on 2020/08/16.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

// 직접적인 관련이 없는 파일들은 분리하라
struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if  uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
