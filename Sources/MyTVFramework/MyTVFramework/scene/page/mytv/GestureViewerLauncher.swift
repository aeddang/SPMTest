//
//  GestureViewerLauncher.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/23.
//

import Foundation
extension GestureViewer {
    func onLauncherRequest(_ request:LauncherRequest?){
        switch request {
        case .moveChannel(let channelId) :
            if self.isReady {
                self.myTvModel.moveChannel(id: channelId)
            } else {
                self.initChannel = channelId
            }
        case .moveProgram(let channelId, let programId) :
            if self.isReady {
                self.myTvModel.moveChannel(id: channelId)
            } else {
                self.initChannel = channelId
            }
            self.myChannelModel.initProgram = programId
        default : break
        }
    }
}
