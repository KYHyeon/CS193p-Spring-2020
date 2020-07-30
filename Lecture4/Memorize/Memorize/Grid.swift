//
//  Grid.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/26.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

// Item이 제네릭으로 넘어오는 Don't Care 이지만 ForEach에 넣기 위해서는 Identifiable 을 만족해야 한다
struct Grid<Item, ItemView>: View where Item: Identifiable, ItemView: View{
    var items: [Item]
    var viewForItem:(Item) -> ItemView
    
    init(items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: GridLayout(itemCount: self.items.count, in: geometry.size))
        }
        
    }
    
    func body(for layout: GridLayout) -> some View {
        ForEach(items) { item in
            self.body(for: item, in: layout)
        }
    }
    
    func body(for item: Item, in layout: GridLayout) -> some View {
        let index = items.firstIndex(matching: item)!
        // Group은 geometry builder와 같은 ViewBuilder
        //        return Group {
        //            if index != nil {
        //                viewForItem(item)
        //                .frame(width: layout.itemSize.width, height: layout.itemSize.height)
        //                .position(layout.location(ofItemAt: index!))
        //            }
        //        }
        return viewForItem(item)
            .frame(width: layout.itemSize.width, height: layout.itemSize.height)
            .position(layout.location(ofItemAt: index))
    }
    
    
    
}

/*
 struct Grid_Previews: PreviewProvider {
 static var previews: some View {
 // 테스트 데이터를 넣어서 canvas에서 미리보기를 볼 수 있음
 Grid()
 }
 }
 */
