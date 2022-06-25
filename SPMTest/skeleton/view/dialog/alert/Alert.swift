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
    func alert(isShowing: Binding<Bool>,
               title: String? = nil,
               image: UIImage? = nil,
               text: String? = nil,
               subText: String? = nil,
               referenceText: String? = nil,
               alignment: HorizontalAlignment = .center,
               buttons:[AlertBtnData]? = nil,
               action: @escaping (_ idx:Int) -> Void ) -> some View {
        
        var alertBtns:[AlertBtnData] = buttons ?? []
        if buttons == nil {
            let btns = [
                String.app.cancel,
                String.app.confirm
            ]
            let range = 0 ..< btns.count
            alertBtns = zip(range,btns).map {index, text in AlertBtnData(title: text, index: index)}
        }
        
        return Alert(
            isShowing: isShowing,
            presenting: { self },
            title:title,
            image:image,
            text:text,
            subText:subText,
            referenceText: referenceText,
            alignment: alignment,
            buttons: alertBtns,
            action:action)
    }
    
}
struct AlertBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    var img:String = ""
    let index:Int
}



struct Alert<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let maxTextCount:Int = 200
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    var title: String?
    var image: UIImage?
    var text: String?
    var subText: String?
    var referenceText: String?
    var alignment: HorizontalAlignment = .center
    var buttons: [AlertBtnData]
    let action: (_ idx:Int) -> Void
    
    @State var safeAreaBottom:CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .center) {
            if UIAccessibility.isVoiceOverRunning {
                Spacer().modifier(MatchParent()).background(Color.transparent.clearUi)
                    .accessibility(label: Text(self.text ?? self.title ?? ""))
            }
            AlertBox(
                isShowing: self.$isShowing,
                title: self.title,
                image: self.image,
                text: self.text,
                subText: self.subText,
                referenceText: self.referenceText,
                alignment: self.alignment,
                buttons: self.buttons,
                action: self.action)
        }
        .padding(.bottom, self.safeAreaBottom)
        .modifier(MatchParent())
        .background( Color.transparent.black70 )
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
    }
}


#if DEBUG
struct Alert_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: .constant(true),
            title:"TEST",
            text: "text",
            subText: "subtext",
            buttons: nil
        ){ _ in
        
        }

    }
}
#endif
