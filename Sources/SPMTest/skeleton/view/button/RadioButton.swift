//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RadioButton: View, SelecterbleProtocol {
    var isChecked: Bool
    var size:CGSize = CGSize(width: Dimen.icon.light, height: Dimen.icon.light)
    var text:String? = nil
    var textSize:CGFloat = Font.size.light
    
    var action: ((_ check:Bool) -> Void)? = nil
    var body: some View {
        HStack(alignment: .center, spacing: Dimen.margin.thin){
            ImageButton(
                defaultImage: Asset.shape.radioBtnOff,
                activeImage: Asset.shape.radioBtnOn,
                isSelected: self.isChecked,
                size: self.size
                ){_ in
                    //self.isChecked.toggle()
                    if self.action != nil {
                        self.action!(!self.isChecked)
                    }
            }
            .buttonStyle(BorderlessButtonStyle())
            if self.text != nil {
                Button(action: {
                   // self.isChecked.toggle()
                    if self.action != nil {
                        self.action!(!self.isChecked)
                    }
                    
                }) {
                    Text(self.text!)
                        .modifier(BoldTextStyle(
                            size: self.textSize
                        ))
                    
                }
            }
        }
        .accessibilityElement()
        .accessibility(label:Text(
            (self.text ?? "toggle button")
            + " "
            + (self.isChecked ? String.button.active : String.button.passive)
        ))
        .accessibilityAction {
            if self.action != nil {
                self.action!(!self.isChecked)
            }
        }
    }
}

#if DEBUG
struct RadioButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RadioButton(
                isChecked: true,
                text:"asdafafsd"
            )
            .frame( alignment: .center)
            .background(Color.brand.bg)
        }
        
    }
}
#endif

