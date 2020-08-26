//
//  Grid.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/26.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

extension Grid where Item: Identifiable, ID == Item.ID {
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}


// Item이 제네릭으로 넘어오는 Don't Care 이지만 ForEach에 넣기 위해서는 Identifiable 을 만족해야 한다
struct Grid<Item, ID, ItemView>: View where ID: Hashable, ItemView: View{
    private var items: [Item]
    private var id: KeyPath<Item, ID>
    private var viewForItem:(Item) -> ItemView
    
    init(_ items: [Item], id: KeyPath<Item, ID>, viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.id = id
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: GridLayout(itemCount: self.items.count, in: geometry.size))
        }
    }
    
    private func body(for layout: GridLayout) -> some View {
        ForEach(items, id: id) { item in
            self.body(for: item, in: layout)
        }
    }
    
    private func body(for item: Item, in layout: GridLayout) -> some View {
        let index = items.firstIndex(where: { item[keyPath: id] == $0[keyPath: id] } )
        // Group은 geometry builder와 같은 ViewBuilder
        return Group {
            if index != nil {
                viewForItem(item)
                    .frame(width: layout.itemSize.width, height: layout.itemSize.height)
                    .position(layout.location(ofItemAt: index!))
            }
        }
//        return viewForItem(item)
//            .frame(width: layout.itemSize.width, height: layout.itemSize.height)
//            .position(layout.location(ofItemAt: index))
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
