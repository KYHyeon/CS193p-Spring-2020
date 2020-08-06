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
        VStack {
            Grid(items: viewModel.cards) { card in
                //        /* return */ HStack/* spacing: 0, */ {
                // ForEach를 루트로 쓰게 되면 ForEach는 layoutView가 아니기 때문에 Preview에서 여러 개로 보여준다.
                // 시뮬레이터로 실행시키면 가상의 View를 하나 더 만들어 넣어준다
                // ForEach로 반복을 하기 위해서는 identifiable protocol을 지원해야 한다
                //            ForEach { card in
                CardView(card: card).onTapGesture {
                    withAnimation(.linear(duration: 0.75)) {
                        self.viewModel.choose(card: card)
                    }
                }
                .padding(5)
                //            }
            }
                // padding은 ZStack에 직접 적용
                .padding()
                // ZStack에 적용되는 foregroundColor와 같은 속성은 environment로서 내부 모든 뷰에 적용
                .foregroundColor(Color.orange)
            //            .aspectRatio(contentMode: .fit)
            Button(action: {
                withAnimation(.easeInOut) {
                    self.viewModel.resetGame()
                }
            }, label: { Text("New Game")})  // 문자열은 localized String을 통해 현지화 할 수 있다.
        }
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    @State private var animatedBonusRemaining: Double = 0
    
    private func startBonusTimeAnimation() {
        // synchronize model
        animatedBonusRemaining = card.bonusRemaining
        // animation value to 0 during remaining
        withAnimation(.linear(duration: card.bonusTimeRemaining)) {
            animatedBonusRemaining = 0
        }
    }
    
    // 클로저에 안들어가있기 때문에 self.을 쓰지 않아도 된다
    @ViewBuilder
    private func body(for size: CGSize) -> some View {
        if card.isFaceUp || !card.isMatched {
            // ViewBuilder에 아무것도 넣지 않으면 EmptyView가 들어간다.
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle.degrees(0 - 90), endAngle: Angle.degrees(-animatedBonusRemaining * 360 - 90), clockwise: true)
                            .onAppear {
                                self.startBonusTimeAnimation()
                        }
                    } else {
                        Pie(startAngle: Angle.degrees(0 - 90), endAngle: Angle.degrees(-card.bonusRemaining * 360 - 90), clockwise: true)
                    }
                }
                .padding(5).opacity(0.4)
                Text(self.card.content)
                    .font(Font.system(size: fontSize(for: size)))
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    // 애니메이션은 변경사항에만 애니메이션을 적용한다.
                    .animation(card.isMatched ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
            }
            .cardify(isFaceUp: card.isFaceUp)
            .transition(AnyTransition.scale)
            //  .modifier(Cardify(isFaceUp: card.isFaceUp))
        }
    }
    
    // MARK: - Drawing Constants
    
    private func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.7
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // preview를 위한 테스트 용이기 때문에 EmojiMemoryGame 생성자를 직접 사용
        let game = EmojiMemoryGame()
        game.choose(card: game.cards[2])
        return EmojiMemoryGameView(viewModel: game)
    }
}
