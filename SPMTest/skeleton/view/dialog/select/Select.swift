//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension View {
    func select(isShowing: Binding<Bool>,
               index: Binding<Int>,
               buttons:[SelectBtnData],
                isCancel:Bool? = false,
                completCancel:Bool? = false,
               action: @escaping (_ idx:Int) -> Void) -> some View {
        
        return Select(
            isShowing: isShowing,
            index: index,
            presenting: { self },
            buttons: buttons,
            isCancel:isCancel!,
            completCancel:completCancel!,
            action:action)
    }
    
}
struct SelectBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let hashId:Int = UUID().hashValue
    var icon:String? = nil
    let title:String
    let index:Int
    var tipA:String? = nil
    var tipB:String? = nil
    var disable:Bool? = false
}

struct Select<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    @Binding var index: Int
    let presenting: () -> Presenting
    var buttons: [SelectBtnData]
    var isCancel:Bool
    var completCancel:Bool
    let action: (_ idx:Int) -> Void
    
    @State var safeAreaBottom:CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Button(action: {
                withAnimation{
                    self.isShowing = false
                }
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            
            SelectBox(
                isShowing: self.$isShowing,
                index: self.$index,
                buttons: self.buttons,
                action: self.action, isCancel: self.isCancel, completCancel:self.completCancel)
        }
        //.transition(.slide)
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ pos in
            //if self.editType == .nickName {return}
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
    }
}
#if DEBUG
struct Select_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: .constant(true),
            index: .constant(0),
            buttons: [
                SelectBtnData(title:"test" , index:0, tipA:"T") ,
                SelectBtnData(title:"test1" , index:1)
            ]
        ){ idx in
        
        }
        .environmentObject(PageSceneObserver())
    }
}
#endif
