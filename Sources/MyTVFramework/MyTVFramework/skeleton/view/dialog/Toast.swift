//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
struct ToastData{
    var character: String = Asset.character.toast1
    var text: String = ""
    var position: CGFloat = Dimen.margin.regular
    var duration:Double = 1.0
    var btns:[String] = []
}


extension View {
    func toast(isShowing: Binding<Bool>, data: ToastData, action: ((_ idx:Int) -> Void)? = nil) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              character: data.character,
              text: data.text,
              toastPosition: data.position,
              duration: data.duration,
              buttons: zip(0 ..< data.btns.count,data.btns).map{ idx, btn in AlertBtnData(title: btn, index: idx) },
              action: action
        )
    }
    func toast(isShowing: Binding<Bool>,
               character: String = Asset.character.toast1,
               text: String, toastPosition:CGFloat = 0 , duration:Double = 1.0) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              character: character,
              text: text,
              toastPosition: toastPosition,
              duration: duration
        )
    }
    
}

struct Toast<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var character: String
    var text: String
    var toastPosition:CGFloat
    var duration:Double = 1.0
    var buttons:[AlertBtnData] = []
    var action: ((_ idx:Int) -> Void)? = nil
    var body: some View {
        ZStack(alignment: .bottom) {
            self.presenting()
            ZStack(alignment: .bottomLeading){
                HStack(spacing:0){
                    Spacer().frame(width: Dimen.item.character.width-30 , height: 1)
                    Text(self.text)
                        .modifier(RegularTextStyle(size: Font.size.light, color: Color.app.white))
                        .multilineTextAlignment(.center)
                        .padding(.all, Dimen.margin.thin)
                    
                    HStack(spacing:Dimen.margin.tinyExtra){
                        ForEach(self.buttons) { btn in
                            FillButton(
                                text: btn.title,
                                index: btn.index,
                                isSelected: btn.index == self.buttons.count-1,
                                textModifier: TextModifier(
                                    family: Font.family.medium,
                                    size: Font.size.regular,
                                    color: Color.app.black,
                                    activeColor: Color.app.white
                                ),
                                size: Dimen.button.mediumRect.height
                                
                            ){idx in
                                self.action?(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                            }
                            .frame(width: Dimen.button.mediumRect.width)
                        }
                    }
                }
                .background( Color.app.darkBlue100)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
                .padding(.leading, 30)
                .padding(.bottom, 4)
                Image(self.character, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.item.character.width, height: Dimen.item.character.height)
                    
            }
            .padding(.bottom, self.toastPosition)
            .opacity(self.isShowing ? 1 : 0)
        }
        .onReceive( [self.isShowing].publisher ) { show in
            if !show  { return }
            if !self.buttons.isEmpty {return}
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.duration) {
                DispatchQueue.main.async {
                    withAnimation {self.isShowing = false}
                }
            }
            
        }
    }
    
    @State var autoHidden:AnyCancellable?
    func delayAutoHidden(){
        self.autoHidden?.cancel()
        self.autoHidden = Timer.publish(
            every: self.duration, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.autoHidden?.cancel()
                withAnimation {
                   self.isShowing = false
                }
            }
    }
}
