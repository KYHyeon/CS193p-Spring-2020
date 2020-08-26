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
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            // + - 버튼
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor) {
//                .sheet(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: self.$chosenPalette, isShowing: self.$showPaletteEditor)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
//        .onAppear { self.chosenPalette = self.document.defaultPalette }
    }
}

struct PaletteEditor: View {
    // ViewModel을 전달할 때에는 @EnvironmentObject를 사용한다.
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: { Text("Done") }).padding()
                }
            }
            Divider()
            // Form: 사용가능한 모든 공간을 사용하므로 아래에 Spacer가 필요하지 않다.
            // Section을 사용하여 공간을 분리한다.
            Form {
//                Section(header: Text("Palette Name")) {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                    .padding()
//                }
//                Section {
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                        .padding()
                }
                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                        }
                    }
                    .frame(height: self.height)
                }
            }
//            Spacer()
        }
        .onAppear { self.paletteName = self.document.paletteNames[self.chosenPalette] ?? ""}
    }
    
    // MARK: - Drawing Constants
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 // * 70
    }
    
    var fontSize: CGFloat = 40
}

struct PalletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        // 라이브 바인딩이 들어갈 수 도 있음
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
