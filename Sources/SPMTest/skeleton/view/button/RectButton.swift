//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RectButton: View, SelecterbleProtocol{
    let text:String
    var textTrailing:String = ""
    var index: Int = 0
    var isSelected: Bool = false
    var textModifier:TextModifier = TextModifier(
        family:Font.family.regular,
        size:Font.size.tiny,
        color: Color.app.darkBlue40,
        activeColor: Color.app.white
    )
    var bgColor = Color.transparent.clearUi
    var bgActiveColor = Color.brand.primary
    var fixSize:CGFloat? = nil
    var progress:Float = 0
    var cornerRadius:CGFloat = Dimen.radius.heavy
    var padding:CGFloat = Dimen.margin.lightExtra
    var icon:String? = nil
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                if self.fixSize != nil {
                    ZStack(alignment: .leading){
                        Spacer().frame( width: self.fixSize! )
                        Spacer()
                            .modifier(MatchVertical(width:self.fixSize! * CGFloat(self.progress)))
                            .background(self.bgActiveColor)
                    }
                }
                HStack( spacing: Dimen.margin.micro ){
                    Text(self.text)
                        .font(.custom(
                            self.isSelected ? Font.family.bold : textModifier.family,
                            size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    + Text(self.textTrailing)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor( textModifier.activeColor )
                    
                    if self.icon != nil {
                        Image(self.icon!, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    }
                }
                    
            }
            .padding(.horizontal, self.padding)
            .frame(height:Dimen.button.thin)
            .background(self.isSelected ? self.bgActiveColor : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            
        }
    }
}
#if DEBUG
struct RectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RectButton(
            text: "test",
                textTrailing: "1/6",
                fixSize: 100,
                progress: 0.5,
                padding: 0
                ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
