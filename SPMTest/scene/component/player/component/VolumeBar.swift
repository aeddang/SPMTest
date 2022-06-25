//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct VolumeBar: PageView {
    @ObservedObject var viewModel: TVPlayerModel = TVPlayerModel()
    @State var progress: Float = 0
    @State var isSelected:Bool = false
    var body: some View {
        VStack(alignment: .center, spacing: Dimen.margin.micro) {
            
            ImageButton(
                defaultImage: Asset.player.volumeOn,
                activeImage: Asset.player.volumeOff,
                isSelected: self.isSelected,
                size: CGSize(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
            ){ idx in

                if self.progress == 0 {
                    self.viewModel.event = .volume(0.5, isUser: true)
                } else {
                    self.viewModel.event = .volume(0, isUser: true)
                }
            }
            ControlBar(progress: self.progress){ pro in
                self.viewModel.event = .volume(pro, isUser: true)
            }
            .modifier(MatchHorizontal(height: 125))
        }
        .frame(width: Dimen.icon.thinExtra)
        .onReceive(self.viewModel.$volume){ v in
            self.progress = v
            self.isSelected = self.progress == 0
        }
        
    }
    
    
}
#if DEBUG
struct VolumeBar_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            VolumeBar()
            .frame(width: 375, alignment: .center)
        }
    }
}
#endif
