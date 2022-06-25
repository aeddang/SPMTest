//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct SelectButton: View, SelecterbleProtocol{
    var icon:String? = nil
    let text:String
    var tipA:String? = nil
    var tipB:String? = nil
    var index: Int = 0
    var isSelected: Bool
    var isCenter: Bool = false
    var disable: Bool? = false
    var textModifier:TextModifier = TextModifier(
        family: Font.family.bold,
        size: Font.size.regular,
        color: Color.app.white,
        activeColor: Color.app.white
    )
    var size:CGFloat = Dimen.button.medium
    let action: (_ idx:Int) -> Void

    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:0){
                    if let img = icon {
                        Image(img, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                            .padding(.trailing, 10)
                            .foregroundColor(self.disable! ? Color.app.black40 : textModifier.color)
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                    }
                    
                    if self.disable! {
                        Text(self.text)
                            .font(.custom(icon != nil ? Font.family.medium : textModifier.family, size: textModifier.size))
                            .foregroundColor( Color.app.black40)
                    }
                    else{
                        Text(self.text)
                            .font(.custom(icon != nil ? Font.family.medium : textModifier.family, size: textModifier.size))
                            .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    }
                    if !self.isCenter {
                        if self.tipA == nil, self.tipB == nil {
                            Spacer()
                        }
                        else {
                            Spacer().modifier(MatchParent())
                        }
                    }
                    
                    if self.tipA != nil {
                        Text(self.tipA!)
                            .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.white))
                            .padding(.horizontal, Dimen.margin.thin)
                            .frame(height:Dimen.button.thin)
                            .background(Color.brand.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
                    }
                    if self.tipB != nil {
                        Text(self.tipB!)
                            .modifier(MediumTextStyle(size: Font.size.thin, color: Color.brand.primary))
                            .padding(.horizontal, Dimen.margin.thin)
                            .frame(height:Dimen.button.thin)
                            .overlay(
                                RoundedRectangle(cornerRadius: Dimen.radius.regular)
                                    .stroke(Color.brand.primary, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, Dimen.margin.medium)
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.isSelected ? Color.app.blue60 : Color.app.blue70 )
        }
        .disabled(self.disable!)
        
    }
}
#if DEBUG
struct SelectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SelectButton(
                text: "test",
                tipA: "A",
                tipB: "B",
                index: 0,
                isSelected: false,
                disable: true
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif

