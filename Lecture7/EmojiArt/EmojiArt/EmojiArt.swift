//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 현기엽 on 2020/08/09.
//  Copyright © 2020 현기엽. All rights reserved.
//

import Foundation

struct EmojiArt {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable {
        let text: String
        // 중앙이 (0,0)인 좌표계 사용, iOS의 좌표계(좌측 상단이 원점)와는 다름
        var x: Int // offset from center
        var y: Int // offset from center
        var size: Int
        
        // UUID를 사용해도 되지만 EmojiArt에서 관리하는 Int를 사용
        let id: Int
        
        // addEmoji를 이용하여야 만들 수 있도록 제한
        // private을 사용하면 EmojiArt에서 조차 Emoji를 만들 수 없다.
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
