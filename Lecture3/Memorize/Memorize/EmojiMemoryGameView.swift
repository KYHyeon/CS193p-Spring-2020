//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/22.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

// 객체 지향 프로그래밍 처럼 보이지만 functional 프로그래밍이다
struct EmojiMemoryGameView: View {
    @ObservedObject var viewModel: EmojiMemoryGame // SceneDelegate에서 초기화
    // objectWillChange.send() 를 매번 받지만 실제로 변경사항이 있는 부분만 새로 그린다
    
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
        //            .aspectRatio(contentMode: .fit)
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    // 클로저에 안들어가있기 때문에 self.을 쓰지 않아도 된다
    func body(for size: CGSize) -> some View {
        ZStack {
            if card.isFaceUp {
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                // 아이폰의 기본 크기는 500 * 800 정도
                // 아이패드는 1000 * 700 정도
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
                // stroke에 fill을 하면 선의 색깔이 흰색으로 변한다
                // fill에 stroke를 하면 fill의 반환값이 some View이기 때문에 적용되지 않는다
                //            RoundedRectangle(cornerRadius: 10.0).stroke().fill(Color.white)
                // 내부속성이 우선적용
                //                .foregroundColor(Color.orange)
                Text(self.card.content)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius).fill()
            }
        }
        .font(Font.system(size: fontSize(for: size)))
    }
    
    // MARK: - Drawing Constants
    
    let cornerRadius: CGFloat = 10
    let edgeLineWidth: CGFloat = 3
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.75
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // preview를 위한 테스트 용이기 때문에 EmojiMemoryGame 생성자를 직접 사용
        EmojiMemoryGameView(viewModel: EmojiMemoryGame())
    }
}
