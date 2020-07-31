//
//  Cardify.swift
//  Memorize
//
//  Created by 현기엽 on 2020/08/01.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

struct Cardify: ViewModifier {
    var isFaceUp: Bool
    
    // TODO: - Content: associate type?? 찾아보기
    func body(content: Content) -> some View {
        ZStack {
        if isFaceUp {
            RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
            // 아이폰의 기본 크기는 500 * 800 정도
            // 아이패드는 1000 * 700 정도
            RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
            // stroke에 fill을 하면 선의 색깔이 흰색으로 변한다
            // fill에 stroke를 하면 fill의 반환값이 some View이기 때문에 적용되지 않는다
            //            RoundedRectangle(cornerRadius: 10.0).stroke().fill(Color.white)
            // 내부속성이 우선적용
            //                .foregroundColor(Color.orange)
            // iOS에서의 각도는 오른쪽(90도) 가 기준(0도) 이다.
            // 왼쪽 위가 (0,0) 이기 때문에 시계 방향과 시계 반대 방향이 반대로 되어 있다.
            content
        } else {
            // cardify가 재사용 가능하게 하기 위해서 matched 구문을 제거함
//            if !card.isMatched {
                RoundedRectangle(cornerRadius: cornerRadius).fill()
//            }
        }
        }
    }
    
    private let cornerRadius: CGFloat = 10
    private let edgeLineWidth: CGFloat = 3
    
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
