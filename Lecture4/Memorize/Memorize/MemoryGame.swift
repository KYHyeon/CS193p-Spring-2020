//
//  MemoryGame.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/23.
//  Copyright © 2020 현기엽. All rights reserved.
//

import Foundation

struct MemoryGame<CardContent> {
    var cards: Array<Card>
    
    // 매개변수로 넘어오는 Card는 값 방식인 struct 여서 복사되어 넘어오기 때문에 안에서 변경을 해도 반영되지 않는다
    // struct의 값을 바꾸기 위해서는 mutating 이 필요
    mutating func choose(card: Card) {
        print("card choosen: \(card)")
        
//        card.isFaceUp = !card.isFaceUp
        let chosenIndex = cards.firstIndex(matching: card)
//        let chosenCard = self.cards[chosenIndex]  // 이 순간 struct가 복사되어 넘어옴
//        chosenCard.isFaceUp = !chosenCard.isFaceUp
        cards[chosenIndex].isFaceUp = !cards[chosenIndex].isFaceUp
    }
    
    // init에서는 값들을 초기화 해야하기 때문에 mutating을 적지 않아도 동작한다
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
//        cards.shuffle()
    }
    
    // struct has free init
    struct Card: Identifiable {
        var id: Int
        
        var isFaceUp: Bool = true
        var isMatched: Bool = false
        var content: CardContent
    }
}
