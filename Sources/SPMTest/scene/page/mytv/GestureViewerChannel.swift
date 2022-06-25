//
//  GestureViewer_Channel.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/16.
//

import Foundation
extension GestureViewer {
    func channelUpdate(){
        guard let channel = self.myTvModel.currentChannel else {return}
        self.currentChannelId = channel.channelId
        self.title = channel.currentTitle
        self.isAuto = false
        if channel.needUpdate == true {
            self.dataProvider.requestData(q: .init(id:self.currentChannelId, type: channel.api))
        } else {
            self.channelUpdated(channel)
        }
    }
    func channelUpdated(_ channel:Channel){
        if self.currentChannelId != channel.channelId {return}
        if channel.type == .recommand {
            channel.addMyfile(files: self.downLoadTaskProvider.loadedFiles)
        }
        self.myChannelModel.setupProgram(channel)
        
    }
    func channelUpdateError(_ channel:Channel){
        if self.currentChannelId != channel.channelId {return}
        self.programEmpty(error: .channel)
    }
    
    func programUpdate(){
        guard let program = self.myChannelModel.currentProgram else {
            self.programEmpty(error: .program)
            return
        }
        self.isAuto = false
        self.currentProgramId = program.programId
        self.program = program
        self.programImage = program.currentImage
        if program.needUpdate == true {
            //self.dataProvider.requestData(q: .init(id:self.currentChannelId, type: .getChannel(menuId: channel.menuId)))
            self.programUpdated(program)
        } else {
            self.programUpdated(program)
        }
    }
    func programUpdated(_ program:Program){
        if self.currentProgramId != program.programId {return}
        self.setupProgram()
        
    }
    
    func programEmpty(error:Error){
        self.program = nil
        self.programImage = nil
        self.stop(error: error)
    }
}
