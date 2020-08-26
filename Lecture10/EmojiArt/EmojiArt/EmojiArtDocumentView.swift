//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 현기엽 on 2020/08/09.
//  Copyright © 2020 현기엽. All rights reserved.
//

// 'EmojiArtDocumentView_Previews' is not a member type of 'EmojiArt' : 구조체의 이름이 앱의 이름과 똑같아서 발생하는 에러

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    // Published의 $ : State
    // State의 $ : Binding
    
    init(document: EmojiArtDocument) {
        self.document = document
        // 초기화 중이기 때문에 동작하지 않는다.
        //        self.chosenPalette = self.document.defaultPalette
        // 대신 실제 변수를 초기화 한다.
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                
                ScrollView(.horizontal) {
                    HStack {
                        // \.self : Key-Path Expression (https://docs.swift.org/swift-book/ReferenceManual/Expressions.html)
                        // A key-path expression refers to a property or subscript of a type
                        // KeyPath 를 이용하여 KVC를 할 때 주로 사용한다
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                //                .onAppear { self.chosenPalette = self.document.defaultPalette }
                //            .layoutPriority(1)
            }
            //            .padding(.horizontal)
            // ZStack을 사용하지 않고 overlay를 사용하지 않는 것은 Rectangle 사이즈에 맞춰 키우기 싶었기 때문에(Image 사이즈가 아니라)
            
            GeometryReader { geometry in
                ZStack {
                    //Rectangle().foregroundColor(.white)
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                    // SwiftUI의 뷰는 기본적으로 경계를 벗어나는 것을 허용한다.
                    // Clipped를 사용하면 경계에서 이미지가 잘린다.
                    .clipped()
                    .gesture(self.panGesture())
                    .gesture(self.zoomGesture())
                    // SafeArea : 노치나 네비게이션 바 등이 있는 구역을 제외한 안전한 구역
                    .edgesIgnoringSafeArea([.horizontal, .bottom])
                    .onReceive(self.document.$backgroundImage) { image in
                        self.zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    // location은 global 좌표계 (rectangle 이 아닌)
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != self.document.backgroundURL {
                        self.confirmBackgroundPaste = true
                    } else {
                        self.explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: self.$explainBackgroundPaste) {
                            return Alert(
                                title: Text("Paste Background"),
                                message: Text("Copy the URL of an image to the clip board and touch button to make it the background of your document."),
                                dismissButton: .default(Text("OK"))
                            )
                    }
                }))
            }
        .zIndex(-1)
        }
        .alert(isPresented: self.$confirmBackgroundPaste) {
            return Alert(
                title: Text("Paste Background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                primaryButton: .default(Text("OK")) {
                    self.document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false

    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            // $var : binding
            //            .updating($gestureZoomScale) { latestGestureScale, ourGestureStateInOut, transaction in
            // ourGestureStateInOut 변수를 수정하면 gestureZoomScale이 변경된다.
            // 직접 변수를 사용하지 않는 이유는 @GestureState 를 사용하기 때문
            // 제스쳐가 진행되는 동안 변했다가 종료되면 다시 초기값(1.0)으로 돌아감
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
        }
        .onEnded { finalGestureScale in
            self.document.steadyStateZoomScale *= finalGestureScale
        }
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }
        .onEnded { finalDragGestureValue in
            self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
    }
    
    
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    //    private func font(for emoji: EmojiArt.Emoji) -> Font {
    //        Font.system(size: emoji.fontSize * zoomScale)
    //    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            //            print("dropped \(url)")
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}

//extension String: Identifiable {
//    public var id: String { self }
//}

struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
