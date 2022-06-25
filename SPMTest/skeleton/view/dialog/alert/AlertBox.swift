//
//  AlertBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/02.
//

import Foundation
import SwiftUI

struct AlertBox: PageComponent {
    let maxTextCount:Int = 200
    @Binding var isShowing: Bool
    
    var title: String?
    var image: UIImage?
    var text: String?
    var subText: String?
    var referenceText: String?
    var alignment: HorizontalAlignment = .center
    var buttons: [AlertBtnData]
    
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        VStack{
            HStack(spacing:0){
                if self.image != nil{
                    ZStack{
                        Image(uiImage: self.image!)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
                            .frame(width: 208, height: 208)
                    }
                    .frame(width:153, height: 232)
                    .clipShape(Rectangle())
                }
                VStack (alignment: .center , spacing:0){
                    if (self.text?.count ?? 0) > self.maxTextCount {
                        ScrollView{
                            AlertBody(title: self.title, text: self.text, subText: self.subText,
                                      referenceText: self.referenceText,
                                      alignment: self.alignment
                            )
                            
                        }
                        .modifier(MatchParent())
                        .padding(.top, Dimen.margin.medium)
                        .padding(.bottom, Dimen.margin.regular)
                    } else {
                        ZStack{
                            AlertBody(title: self.title, text:self.text, subText: self.subText,
                                      referenceText: self.referenceText,
                                      alignment: self.alignment
                            )
                        }
                        .modifier(MatchParent())
                    }
                    HStack(spacing:Dimen.margin.thinExtra){
                        ForEach(self.buttons) { btn in
                            FillButton(
                                text: btn.title,
                                index: btn.index,
                                isSelected: btn.index == self.buttons.count-1
                            ){idx in
                                self.action(idx)
                                withAnimation{
                                    self.isShowing = false
                                }
                            }
                        }
                    }
                }
                .frame(width: 327, height: 213)
            }
            .padding(.horizontal, Dimen.margin.regular)
            .padding(.bottom, Dimen.margin.regular)
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))
            
        }
    }
}

struct AlertBody: PageComponent{
    var title: String?
    var text: String?
    var subText: String?
    var referenceText: String?
    var alignment: HorizontalAlignment = .center
    var body: some View {
        HStack(spacing:0){
            VStack (alignment: .center, spacing:0){
                if self.title != nil{
                    Text(self.title!)
                        .multilineTextAlignment(.center)
                        .modifier(BoldTextStyle(size: Font.size.large))
                        .fixedSize(horizontal: false, vertical: true)
                        
                }
                VStack (alignment: self.alignment, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if self.text != nil{
                        Text(self.text!)
                            .kerning(Font.kern.thin)
                            .multilineTextAlignment(self.alignment == .center ? .center : .leading)
                            .modifier(RegularTextStyle(size: Font.size.light))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, Dimen.margin.thin)
                    }
                    if self.subText != nil{
                        Text(self.subText!)
                            .kerning(Font.kern.thin)
                            .multilineTextAlignment(self.alignment == .center ? .center : .leading)
                            .modifier(RegularTextStyle(size: Font.size.thin))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, Dimen.margin.tiny)
                    }
                    
                    if self.referenceText != nil{
                        Text(self.referenceText!)
                            .kerning(Font.kern.thin)
                            .multilineTextAlignment(self.alignment == .center ? .center : .leading)
                            .modifier(RegularTextStyle(size: Font.size.tiny, color: Color.brand.primaryLight))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, Dimen.margin.tiny)
                    }
                }
            }
        }
        
    }
}
