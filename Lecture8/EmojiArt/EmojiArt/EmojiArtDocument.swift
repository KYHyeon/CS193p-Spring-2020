//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 현기엽 on 2020/08/09.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static let palette: String = "★☁🌭⚾︎"
    
    // @Published // workaround for property observer problem with property wrappers
    private var emojiArt: EmojiArt {
        willSet {
            objectWillChange.send()
        }
        didSet {
            // UserDefaults는 버퍼를 사용하기 때문에 즉시 기록하지 않을 수 있다.
            // 다른 앱으로 이동했다가 돌아올 때 UserDefaults를 항상 기록한다.
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
//            print("json = \(emojiArt.json?.utf8 ?? "nil")")
        }
    }
    
    private static let untitled = "EmojiArtDocument.Untitled"
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // 사용자가 이미지를 받아오는 중간에 다른 이미지를 다운로드 할 수 있다
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
