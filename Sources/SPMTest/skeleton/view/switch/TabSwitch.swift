//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct TabSwitch : PageComponent {
    var tabs:[String] = []
    var selectedIdx:Int = 0
    var height:CGFloat = Dimen.tab.light
    var fontSize:CGFloat = Font.size.thin
    var bgColor:Color = Color.app.white
    var useCheck:Bool = true
    let action: (_ idx:Int) -> Void
   
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading){
                if !self.tabs.isEmpty {
                    Spacer()
                        .modifier(MatchVertical(width: geometry.size.width/CGFloat(self.tabs.count) ))
                        .background(Color.brand.primaryLight)
                        .clipShape( RoundedRectangle(cornerRadius: Dimen.radius.medium))
                        .offset(
                            x: floor(geometry.size.width/CGFloat(self.tabs.count)*CGFloat(self.selectedIdx))
                        )
                }
                HStack(spacing:0){
                    ForEach( Array(self.tabs.enumerated()), id: \.1){idx,  tab in
                        Button(
                            action: { self.action(idx)}
                        ){
                            
                            HStack(alignment: .center, spacing:Dimen.margin.micro){
                                if idx == self.selectedIdx && self.useCheck {
                                    Image(Asset.shape.checkBoxOn)
                                    .renderingMode(.original).resizable()
                                    .scaledToFit()
                                    .frame(width: Dimen.icon.micro)
                                }
                                Text(tab)
                                    .kerning(Font.kern.thin)
                                    .modifier(
                                        BoldTextStyle(
                                            size: self.fontSize,
                                            color: idx == self.selectedIdx
                                                ? Color.app.white : Color.app.stateOrange
                                    ))
                            }
                            .padding(.horizontal, Dimen.margin.tiny)
                        }
                        .modifier(MatchParent())
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .frame(height: self.height)
            .background(self.bgColor)
            .clipShape( RoundedRectangle(cornerRadius: 0)) 
            .onAppear(){
                
            }
        }//geo
    }//body
}


#if DEBUG
struct TabSwitch_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            TabSwitch(
                tabs: [
                    "TEST0", "TEST11", "TEST222","TEST333" ,"TEST444"
                ]
            ){ _ in
                
            }
            .frame( width:320, alignment: .center)
            
        }
        .background(Color.app.white)
    }
}
#endif
