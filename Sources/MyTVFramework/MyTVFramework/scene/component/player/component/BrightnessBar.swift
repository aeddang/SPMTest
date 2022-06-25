//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct BrightnessBar: PageView {
    @State var progress: Float = 0
    @State var isSelected:Bool = false
    var body: some View {
        VStack(alignment: .center, spacing: Dimen.margin.micro) {
            
            ImageButton(
                defaultImage: Asset.player.bright,
                activeImage: Asset.player.bright,
                isSelected: self.isSelected,
                size: CGSize(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
            ){ idx in
                UIScreen.main.brightness = 1.0
                self.progress = 1.0
            }
            ControlBar(progress: self.progress){ pro in
                UIScreen.main.brightness = CGFloat(pro)
                self.progress = pro
            }
            .modifier(MatchHorizontal(height: 125))
        }
        .frame(width: Dimen.icon.thinExtra)
        .onAppear(){
            self.progress = Float(UIScreen.main.brightness)
        }
    }
    
    
}
#if DEBUG
struct BrightnessBar_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            BrightnessBar()
            .frame(width: 375, alignment: .center)
        }
    }
}
#endif
