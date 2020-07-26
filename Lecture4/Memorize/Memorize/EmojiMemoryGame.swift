//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/23.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

// Viewmodel은 참조를 해야 하기 때문에 class를 사용하여 힙에 위치시킨다.
class EmojiMemoryGame: ObservableObject {
    // private(set) - glass door :
        // public get, private set
    // private - video doorbell's video:
        // private get, private set
    // Published와 같은 구문을 property wrapper라고 부른다
    @Published private var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["👻", "🎃", "🕷"]
        return MemoryGame<String>(numberOfPairsOfCards: emojis.count) { pairIndex in
            emojis[pairIndex]
        }
    }
        
    // MARK: - Access the Model
    var cards: Array<MemoryGame<String>.Card> {
        model.cards
    }
    
    // MARK: - Intent(s)
    // 모델을 변경할 수 있는 방법
    func choose(card: MemoryGame<String>.Card) {
//        objectWillChange.send()  // 변경사항을 publish 하기 위해서 사용하지만 @Published를 모델앞에 붙여서 항상 써야 하는 귀찮음을 막을 수 있다.
        model.choose(card: card)
    }
}
