//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct CheckBox: View, SelecterbleProtocol {
    enum CheckBoxStyle {
        case small, normal, white
        var check:String{
            get{
                switch self {
                case .white: return Asset.shape.checkBoxOffWhite
                default : return Asset.shape.checkBoxOff
                }
            }
        }
        var disable:String{
            get{
                switch self {
                case .white: return Asset.shape.checkBoxDisable
                default : return Asset.shape.checkBoxDisable
                }
            }
        }
        var checkOn:String{
            get{
                switch self {
                case .white: return Asset.shape.checkBoxOn
                case .small: return Asset.shape.checkBoxOn
                default : return Asset.shape.checkBoxOn2
                }
            }
        }
        var textColor:Color {
            get{
                switch self {
                case .white: return Color.app.black40
                default : return Color.app.white
                }
            }
        }
        var textSize:CGFloat {
            get{
                switch self {
                case .white: return   SystemEnvironment.isTablet ? Font.size.tiny : Font.size.thin
                case .small: return  Font.size.tiny
                default : return  Font.size.light
                }
            }
        }
    }
    
    var style:CheckBoxStyle = .normal
    var isChecked: Bool
    var isCheckAble: Bool = true
    var text:String? = nil
    var subText:String? = nil
    var isStrong:Bool = false
    var isSimple:Bool = false
    var isFill:Bool = true
    var alignment:VerticalAlignment = .center
    var textColor:String? = nil
    var textSize:String? = nil
    var more: (() -> Void)? = nil
    var action: ((_ check:Bool) -> Void)? = nil
    
    
    var body: some View {
        HStack(alignment: self.alignment, spacing: 0){
            HStack(alignment: self.alignment, spacing: Dimen.margin.thin){
               ImageButton(
                defaultImage: self.isCheckAble ? self.style.check : self.style.disable,
                activeImage: self.isCheckAble
                    ? self.isStrong
                        ? Asset.shape.checkBoxOn : self.style.checkOn
                    : self.style.disable,
                    isSelected: self.isChecked,
                    size: CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin)
                    ){_ in
                        if !self.isCheckAble {return}
                        if let action = self.action {
                            action(!self.isChecked)
                        }
                }
                if !self.isSimple {
                    VStack(alignment: .leading, spacing: 0){
                        if isFill {
                            Spacer().modifier(MatchHorizontal(height: 0))
                        }
                        if self.text != nil {
                            if self.isStrong {
                                Text(self.text!)
                                    .kerning(Font.kern.thin)
                                    .modifier( BoldTextStyle(
                                                size: self.style.textSize,
                                                color: self.style.textColor)
                                    )
                                    .fixedSize(horizontal:false, vertical:true)
                            }else{
                                Text(self.text!)
                                    .kerning(Font.kern.thin)
                                    .modifier( MediumTextStyle(
                                            size: self.style.textSize,
                                            color: self.style.textColor)
                                    )
                                    .fixedSize(horizontal:false, vertical:true)
                            }

                        }
                        if self.subText != nil {
                            Text(self.subText!)
                                .kerning(Font.kern.thin)
                                .modifier(MediumTextStyle(
                                    size: self.style.textSize,
                                    color: Color.app.black40))
                        }
                    }
                }
            }
            .accessibilityElement()
            .accessibility(label:
                Text((self.text ?? self.subText ?? "")
                    + " "
                    + (self.isChecked ? String.button.active : String.button.passive)
                ))
            .accessibilityAction {
                if !self.isCheckAble {return}
                if let action = self.action {
                    action(!self.isChecked)
                }
            }
            
            if let more = self.more {
                TextButton(
                    defaultText: String.button.view,
                    textModifier:TextModifier(
                        family:Font.family.medium,
                        size:Font.size.thin,
                        color: self.style.textColor),
                    isUnderLine: true)
                {_ in
                    more()
                }
            }
        }
        
    }
}

#if DEBUG
struct CheckBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CheckBox(
                isChecked: true,
                text:"asdafafsd",
                more:{
                    
                },
                action:{ ck in
                
                }
            )
            .frame( alignment: .center)
            .background(Color.brand.bg)
        }
        
    }
}
#endif

