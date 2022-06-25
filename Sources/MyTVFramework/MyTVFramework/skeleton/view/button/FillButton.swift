//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct FillButton: View, SelecterbleProtocol{
    let text:String
    var subText:String? = nil
    var trailText:String? = nil
    var strikeText:String? = nil
    var moreText:String? = nil
    var index: Int = 0
    var isSelected: Bool = true
    var imageAni:[String]? = nil
    var image:String? = nil
    var imageOn:String? = nil
    var textModifier:TextModifier = TextModifier(
        family: Font.family.medium,
        size: Font.size.medium,
        color: Color.app.black,
        activeColor: Color.app.white
    )
    var size:CGFloat = Dimen.button.regular
    var cornerRadius:CGFloat = Dimen.radius.light
    var imageSize:CGFloat = Dimen.icon.light
    var moreSize:CGFloat = Dimen.icon.regular
    var activeBgColor:Color = Color.brand.primary
    var bgColor:Color = Color.app.darkBlue10
    var strokeWidth:CGFloat = 0
    var strokeColor:Color = Color.app.black40
    var margin:CGFloat = Dimen.margin.regular
    var isNew: Bool = false
    var count: Int? = nil
    var isMore: Bool = false
    var icon:String? = nil
    var iconSize:CGFloat = Dimen.icon.thin
    var isleading: Bool? = false
    
    let action: (_ idx:Int) -> Void
    
    init(
        text:String,
        subText:String? = nil,
        trailText:String? = nil,
        strikeText:String? = nil,
        index: Int = 0,
        isSelected: Bool = true,
        imageAni:[String]? = nil,
        image:String? = nil,
        imageOn:String? = nil,
        textModifier:TextModifier? = nil,
        size:CGFloat? = nil,
        imageSize:CGFloat? = nil,
        margin:CGFloat? = nil,
        bgColor:Color? = nil,
        activeBgColor:Color? = nil,
        strokeWidth:CGFloat? = nil,
        action:@escaping (_ idx:Int) -> Void )
    {
        self.text = text
        self.subText = subText
        self.trailText = trailText
        self.strikeText = strikeText
        self.index = index
        self.isSelected = isSelected
        self.image = image
        self.imageOn = imageOn
        self.action = action
        self.textModifier = textModifier ?? self.textModifier
        self.size = size ?? self.size
       
        self.imageSize = imageSize ?? self.imageSize
        self.bgColor = bgColor ?? self.bgColor
        self.activeBgColor = activeBgColor ?? self.activeBgColor
        self.strokeWidth = strokeWidth ?? self.strokeWidth
        self.margin = margin ?? self.margin
    }
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                HStack(spacing:Dimen.margin.tiny){
                    if self.isMore{
                        Spacer().frame(width: Dimen.margin.thin)
                    }
                    if let ani = self.imageAni  {
                        ImageAnimation(images: ani, isLoof:false, isRunning: .constant(true) )
                            .frame(width: self.imageSize*1.2, height: self.imageSize*1.2)
                    }
                    else if let image = self.image  {
                        Image(self.isSelected ? ( self.imageOn ?? image )  : image,
                              bundle: Bundle(identifier: SystemEnvironment.bundleId))
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: self.imageSize, height: self.imageSize)
                    }
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    if self.isleading! {
                        Spacer()
                    }
                    
                    if let subText = self.subText  {
                        Text(subText)
                            .font(.custom(Font.family.medium, size: textModifier.size))
                            .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                            .lineLimit(1)
                            .padding(.leading, -Dimen.margin.tiny)
                    }
                    if self.trailText != nil || self.strikeText != nil {
                        Spacer()
                        if let strikeText = self.strikeText {
                            Text(strikeText)
                                .font(.custom(textModifier.family, size: Font.size.thin))
                                .strikethrough()
                                .foregroundColor(self.isSelected ? self.textModifier.activeColor : textModifier.color)
                        }
                        if let trailText = self.trailText {
                            Text(trailText )
                                .font(.custom(textModifier.family, size:  self.textModifier.size))
                                .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                        }
                    }
                    if self.isNew {
                        if let count = self.count {
                            Text(count == 99 ? "99+" : count.description  )
                                .kerning(Font.kern.thin)
                                .modifier(BoldTextStyle(
                                    size: SystemEnvironment.isTablet ?  Font.size.micro : Font.size.micro,
                                    color: Color.app.white
                                ))
                                
                                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                .background(Color.brand.primary)
                                .clipShape(Circle())
                            
                        } else {
                            Image(Asset.icon.new, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                        }
                        
                    }
                    if let icon = self.icon {
                        Spacer()
                        Image(icon, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                            .frame(height: self.iconSize)
                    }
                    if self.isMore{
                        Spacer()
                        if let moreText = self.moreText {
                            Text(moreText)
                                .modifier(MediumTextStyle(
                                    size: Font.size.thin,
                                    color: Color.app.black40
                                ))
                        }
                        Image(Asset.icon.more, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: self.moreSize, height: self.moreSize)
                        .padding(.trailing, Dimen.margin.tiny)
                    }
                }
                .padding(.horizontal, self.isMore ? 0 : self.margin)
                
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.isSelected ? self.activeBgColor : self.bgColor )
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .stroke( self.strokeColor ,lineWidth: self.strokeWidth )
            )
        }
        .accessibilityElement()
        .accessibility(label: Text(self.text + (self.isNew ? "new" : "")))
        .accessibility(addTraits: .isButton)
        
    }
}
#if DEBUG
struct FillButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FillButton(
                text: "test"
            ){_ in

            }
            .frame( alignment: .center)
            .background(Color.app.blue70)

        }
    }
}
#endif

