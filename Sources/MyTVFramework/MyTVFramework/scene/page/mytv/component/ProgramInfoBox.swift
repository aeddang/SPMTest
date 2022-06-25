//
//  ProgramInfoBox.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/17.
//

import Foundation
import SwiftUI

struct ProgramInfoBox:View {
    var program:Program? = nil
    var programImage:ImageSet? = nil
    var title:String = ""
    var isAuto:Bool = false
    var type:Viewer.Direction? = nil
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            Image(Asset.character.pose1, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 119, height: 127)
            VStack(alignment: .leading){
                Spacer().modifier(MatchParent())
                VStack(alignment: .leading, spacing: 0){
                    if let program = self.program {
                        HStack(spacing:Dimen.margin.thin){
                            if self.isAuto {
                                Image(Asset.icon.auto, bundle: Bundle(identifier: SystemEnvironment.bundleId))
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height:  13)
                            }
                            if let commentary = program.currentCommentary ?? self.title {
                                Text(commentary)
                                    .modifier(BoldTextStyle(size: Font.size.light, color: Color.app.darkBlue10))
                            }
                        }
                        if let title = program.currentTitle {
                            Text(title)
                                .modifier(RegularTextStyle(size: Font.size.bold, color: Color.app.white))
                        }
                        if let item = program.currentItem {
                            HStack(spacing:Dimen.margin.thin){
                                if let txt = item.date?.toDateFormatter(dateFormat:"yyyy") {
                                    Text(txt)
                                        .modifier(RegularTextStyle(size: Font.size.tinyExtra, color: Color.app.white))
                                }
                                if let age = item.age {
                                    Image(Asset.age.getIcon(age: age), bundle: Bundle(identifier: SystemEnvironment.bundleId))
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.tinyExtra, height:  Dimen.icon.tinyExtra)
                                }
                                if let txt = item.duration {
                                    Text(txt)
                                        .modifier(RegularTextStyle(size: Font.size.tinyExtra, color: Color.app.white))
                                }
                                if let txt = program.genre {
                                    Text(txt)
                                        .modifier(RegularTextStyle(size: Font.size.tinyExtra, color: Color.app.white))
                                }
                                if program.type != .live, let id = program.currentItemKey {
                                    ImageButton(
                                        defaultImage: Asset.icon.info
                                    ){ idx in
                                        
                                    }
                                    .padding(.leading, -9)
                                }
                            }
                            .frame(height: Dimen.icon.regular)
                            .padding(.top, -4)
                        }
                    }
                }
            }
            .padding(.leading, 93)
        }
        .padding(.all, Dimen.margin.light)
        .background(Color.transparent.black50)
    }
}
