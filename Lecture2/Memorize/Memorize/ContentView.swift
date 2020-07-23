//
//  ContentView.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/22.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

// 객체 지향 프로그래밍 처럼 보이지만 functional 프로그래밍이다
struct ContentView: View {
    var viewModel: EmojiMemoryGame // SceneDelegate에서 초기화
    
    // protocol View - associatedtype Body : View
    // some : body의 내부 구조가 바뀔 수 있으므로 컴파일러에게 미리 알려주는 역할
    //        View 가 Generic이기 때문에 필요
    var body: some View {
        /* return */ HStack/* spacing: 0, */ {
            // ForEach를 루트로 쓰게 되면 ForEach는 layoutView가 아니기 때문에 Preview에서 여러 개로 보여준다.
            // 시뮬레이터로 실행시키면 가상의 View를 하나 더 만들어 넣어준다
            // ForEach로 반복을 하기 위해서는 identifiable protocol을 지원해야 한다
            ForEach(viewModel.cards) { card in
                CardView(card: card).onTapGesture {
                    self.viewModel.choose(card: card)
                }
            }
        }
            // padding은 ZStack에 직접 적용
            .padding()
            // ZStack에 적용되는 foregroundColor와 같은 속성은 environment로서 내부 모든 뷰에 적용
            .foregroundColor(Color.orange)
            .font(Font.largeTitle)
//            .fixedSize()
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card
    
    var body: some View {
        ZStack {
            if card.isFaceUp {
                RoundedRectangle(cornerRadius: 10.0).fill(Color.white)
                // 아이폰의 기본 크기는 500 * 800 정도
                // 아이패드는 1000 * 700 정도
                RoundedRectangle(cornerRadius: 10.0).stroke(lineWidth: 3)
                // stroke에 fill을 하면 선의 색깔이 흰색으로 변한다
                // fill에 stroke를 하면 fill의 반환값이 some View이기 때문에 적용되지 않는다
                //            RoundedRectangle(cornerRadius: 10.0).stroke().fill(Color.white)
                // 내부속성이 우선적용
                //                .foregroundColor(Color.orange)
                Text(card.content)
            } else {
                RoundedRectangle(cornerRadius: 10.0).fill()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // preview를 위한 테스트 용이기 때문에 EmojiMemoryGame 생성자를 직접 사용
        ContentView(viewModel: EmojiMemoryGame())
    }
}
