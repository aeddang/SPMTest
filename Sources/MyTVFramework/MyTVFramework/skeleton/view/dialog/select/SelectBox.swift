//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

extension SelectBox {
    static let scrollNum:Int = 5
}
struct SelectBox: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    @Binding var index: Int
    var buttons: [SelectBtnData]
    let action: (_ idx:Int) -> Void
    
    var isCancel:Bool
    var completCancel:Bool
    
    @State var safeAreaBottom:CGFloat = 0
    
    var body: some View {
        VStack{
            VStack (alignment: .leading, spacing:0){
                if self.buttons.count > Self.scrollNum {
                    ScrollView(.vertical, showsIndicators: false){
                        SelectBoxBody(index: self.$index, buttons: self.buttons, isCancel: self.isCancel, action: self.action)
                            .padding(.bottom, isCancel ? Dimen.margin.thin : 0)
                    }
                    .modifier(MatchHorizontal(height: Dimen.button.medium * CGFloat(Self.scrollNum)))
                } else {
                    SelectBoxBody(index: self.$index, buttons: self.buttons, isCancel: self.isCancel, action: self.action)
                        .padding(.bottom, isCancel ? Dimen.margin.thin : 0)
                }
                if isCancel {
                    Divider().background(Color.transparent.white10)
                    FillButton(text: String.app.cancel, action: { idx in
                        self.action( -1 )
                        withAnimation{
                            self.isShowing = false
                        }
                    })
                    .frame( alignment: .leading)
                    .background(Color.app.blue70)
                }
                else{
                    FillButton(
                        text: String.app.close,
                        isSelected: true
                    ){idx in
                        if self.completCancel {
                            self.action( self.index )
                        }
                        withAnimation{
                            self.isShowing = false
                        }
                        
                    }
                }
            }
            .padding(.top, isCancel ? Dimen.margin.thin : Dimen.margin.medium)
            .padding(.bottom, self.safeAreaBottom)
            .background(Color.app.blue70)
            .offset(y:self.isShowing ? 0 : 200)
        }
        .onReceive(self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ pos in
            //if self.editType == .nickName {return}
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
    }
}

struct SelectBoxBody: PageComponent{
    @Binding var index: Int
    var buttons: [SelectBtnData]
    var isCancel: Bool
    let action: (_ idx:Int) -> Void
    var body: some View {
        VStack(alignment: .center, spacing:0){
            ForEach(self.buttons) { btn in
                SelectButton(
                    icon: btn.icon,
                    text: btn.title ,
                    tipA: btn.tipA, tipB: btn.tipB,
                    index: btn.index,
                    isSelected: btn.index == self.index,
                    isCenter: true,
                    disable: btn.disable){idx in
                    
                    self.index = idx
                    self.action(idx)
                }
            }
        }
    }
}
