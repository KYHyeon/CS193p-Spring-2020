//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by 현기엽 on 2020/08/22.
//  Copyright © 2020 현기엽. All rights reserved.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    // @State var almost private
    @Binding var chosenPalette: String
    
    var body: some View {
        HStack {
            // + - 버튼
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
//        .onAppear { self.chosenPalette = self.document.defaultPalette }
    }
}

struct PalletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        // 라이브 바인딩이 들어갈 수 도 있음
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
