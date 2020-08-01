//
//  MemoryGame.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/23.
//  Copyright © 2020 현기엽. All rights reserved.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>
    
    // 변경이 일어날 때마다 할 수도 있지만 computed property를 사용하면 오류가 날 가능성을 줄여준다.
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {
            cards.indices.filter { cards[$0].isFaceUp }.only
//            var faceUpCardIndices = [Int]()
//            for index in cards.indices {
//                if cards[index].isFaceUp {
//                    faceUpCardIndices.append(index)
//                }
//            }
//            if faceUpCardIndices.count == 1 {
//                return faceUpCardIndices.first
//            } else {
//                return nil
//            }
        }
        // set 에 따로 설정하지 않으면 newValue를 새로운 값으로 사용한다.
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    // 매개변수로 넘어오는 Card는 값 방식인 struct 여서 복사되어 넘어오기 때문에 안에서 변경을 해도 반영되지 않는다
    // struct의 값을 바꾸기 위해서는 mutating 이 필요
    mutating func choose(card: Card) {
        print("card choosen: \(card)")
        
        //        card.isFaceUp = !card.isFaceUp
        
        // if 문의 ,(쉼표)는 순차적인 and
        if let chosenIndex = cards.firstIndex(matching: card), !cards[chosenIndex].isFaceUp, !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                self.cards[chosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
        }
        //        let chosenCard = self.cards[chosenIndex]  // 이 순간 struct가 복사되어 넘어옴
        //        chosenCard.isFaceUp = !chosenCard.isFaceUp
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
        
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
    }
}
