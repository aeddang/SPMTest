//
//  ImageButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct ImageButton: View, SelecterbleProtocol{
    var isSelected: Bool
    let index: Int
    let defaultImage:String
    let activeImage:String
    let size:CGSize
    let text:String?
    let textSize:CGFloat
    let defaultTextColor:Color
    let activeTextColor:Color
    
    let action: (_ idx:Int) -> Void
    init(
        defaultImage:String,
        activeImage:String? = nil,
        text:String? = nil,
        isSelected:Bool? = nil,
        index: Int = 0,
        size:CGSize = CGSize(width: Dimen.icon.regular, height: Dimen.icon.regular),
        textSize:CGFloat = Font.size.light,
        defaultTextColor:Color = Color.app.white,
        activeTextColor:Color = Color.app.white,
        action:@escaping (_ idx:Int) -> Void
    )
    {
        self.defaultImage = defaultImage
        self.activeImage = activeImage ?? defaultImage
        self.text = text
        self.index = index
        self.isSelected = isSelected ?? false
        self.size = size
        self.textSize = textSize
        self.defaultTextColor = defaultTextColor
        self.activeTextColor = activeTextColor
        self.action = action
    }
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            HStack(spacing:0){
                Image(self.isSelected ?
                      self.activeImage : self.defaultImage, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                if self.text != nil {
                    Text(self.text!)
                        .modifier(BoldTextStyle(
                            size: self.textSize,
                            color: self.isSelected ?
                                self.activeTextColor : self.defaultTextColor
                        ))
                }
            }
            .background(Color.transparent.clearUi)
        }
    }
}

#if DEBUG
struct ImageButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ImageButton(defaultImage:Asset.noImg16_9){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
