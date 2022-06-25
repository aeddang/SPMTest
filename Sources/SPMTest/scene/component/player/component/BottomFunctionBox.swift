//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct BottomFunctionBox: PageView {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var viewModel: TVPlayerModel = TVPlayerModel()
    
    @State var isLock:Bool = false
    @State var hasCaption:Bool = false
    @State var textRate:String? = nil
    @State var currentLang:String? = nil
    @State var currentPlayId:String? = nil
    @State var isSeekAble = false
    var body: some View {
        HStack(alignment: .center, spacing: Dimen.margin.heavy) {
            if self.isSeekAble {
                ImageButton(
                    defaultImage: Asset.player.rate,
                    text: self.textRate ?? String.player.rateDefault
                ){ idx in
                    self.viewModel.selectOptionType = .rate
                }
            }
            if self.hasCaption {
                ImageButton(
                    defaultImage: Asset.player.cc,
                    text: self.currentLang ?? String.player.caption
                ){ idx in
                    self.viewModel.isCaptionSelect = true
                }
            }
            if self.isSeekAble, let playId = self.currentPlayId {
                DownLoadStatusButton(
                    viewModel:self.viewModel,
                    fileId:playId
                )
            }
            ImageButton(
                defaultImage: Asset.player.lock,
                activeImage: Asset.player.lockOn,
                isSelected: self.isLock
            ){ idx in
                self.viewModel.isLock = !self.isLock
            }
        }
        .onReceive(self.viewModel.$rate) { r in
            if r == 1.0 {
                self.textRate = String.player.rateDefault
            } else {
                self.textRate = "x" + r.description
            }
        }
        .onReceive(self.viewModel.$isLock) { lock in
            if lock == self.isLock {return}
            withAnimation{ self.isLock = lock }
        }
        .onReceive(self.viewModel.$isSeekAble) { able in
            guard let able = able else {return}
            self.isSeekAble = able
        }
        .onReceive(self.viewModel.$subtitles){ langs in
            self.hasCaption = langs?.isEmpty == false
        }
        .onReceive(self.viewModel.$selectedCaptionLang) { lang in
            self.currentLang = lang
        }
        .onReceive(self.viewModel.$currentPlayId) { playId in
            self.currentPlayId = playId
        }
    }
}
#if DEBUG
struct BottomFunctionBox_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            BottomFunctionBox()
            .frame(width: 375, alignment: .center)
        }
    }
}
#endif
