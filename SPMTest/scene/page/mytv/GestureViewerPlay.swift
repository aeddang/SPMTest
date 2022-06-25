//
//  GestureViewerPlay.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/18.
//

import Foundation
import SwiftUI

extension GestureViewer {
    func setupProgram(){
        guard let program = self.program else {return self.stop(error:.program)}
        guard let item = program.currentItem else {return self.stop(error: .play)}
        self.playStartTime = item.playTime
        if let file = item.file {
            self.currentPlayId = nil
            self.play(hls: file)
        } else if let stream = item.streamData {
            self.currentPlayId = nil
            self.play(data: stream)
        } else {
            if item.epsdRsluId == self.currentPlayId {
                self.tvPlayerModel.event = .seekTime(self.playStartTime, true, isUser: false)
                return
            }
            self.currentPlayId = item.epsdRsluId
            if let file = self.downLoadTaskProvider.loadedFiles[item.epsdRsluId] {
                self.play(hls: file)
            } else {
                self.isOfflinePlay = false
                self.dataProvider.requestData(q: .init(type: .getPlay(epsdRsluId: item.epsdRsluId, isPersistent: false)))
            }
           
        }
    }
    
    func play(hls:HLSFile?){
        
        self.isOfflinePlay = true
        #if TARGET_IPHONE_SIMULATOR
        self.stop(error: .simulator)
        #else
        guard let hls = hls else {return self.stop(error:.play)}
        self.isAuto = hls.isAuto
        if hls.isExfire {return self.stop(error:.play)}
        self.tvPlayerModel.setData(data: hls,
                                   continuousTime: self.playStartTime)
        #endif
    }
    
    func play(data:Play, epsdRsluId:String?, isPersistent:Bool){
        self.isOfflinePlay = false
        guard let item = self.program?.currentItem else {return}
        if item.epsdRsluId != epsdRsluId {return}
        guard let info = data.CTS_INFO else {return self.stop(error:.play)}
        #if TARGET_IPHONE_SIMULATOR
        self.stop(error: .simulator)
        #else
        self.tvPlayerModel.setData(data: info, currentPlayId: self.currentPlayId,
                                   continuousTime: self.playStartTime,
                                   isSeekAble: self.program?.seekAble)
        #endif
    }
    func play(data:LiveStreamItem){
        self.isOfflinePlay = false
        #if TARGET_IPHONE_SIMULATOR
        self.stop(error: .simulator)
        #else
        self.tvPlayerModel.setData(data: data)
        #endif
    }
    func onPlayerEvent(_ evt:PlayerUIEvent?){
        guard let evt = evt else {return}
        switch evt {
        case .resumeDisable(_): self.channelUpdate()
        default : break
        }
    }
    func onPlayerEvent(_ evt:PlayerStreamEvent?){
        guard let evt = evt else {return}
        switch evt {
        case .loaded :
            self.changeStatus(.ready)
            if self.program?.type == .live && self.tvPlayerModel.autoPlay {
                self.tvPlayerModel.event = .resume(isUser: false)
            }
        case .resumed :
            if self.status == .ready {
                self.changeStatus(.play)
            }
        case .completed :
            self.changeStatus(.complete)
            self.onPlayerCompleted()
        default : break
        }
    }
    
    func onPlayerError(_ error:PlayerError){
        var errMsg = ""
        switch error {
        case .connect(let msg) : errMsg = "Connect : " + msg
        case .stream(let err) : errMsg = "Stream : " + err.getDescription()
        case .drm(let err): errMsg = "Drm : " + err.getDescription()
        case .asset(let e) : errMsg = "Asset : " + e.getDescription()
        default : break
        }
        self.appSceneObserver.event = .toast(errMsg)
    }
    
    func onPlayerCompleted(){
        if self.program?.type == .liveVod || self.program?.type == .live {
            self.channelUpdate() 
        }
    }
}
