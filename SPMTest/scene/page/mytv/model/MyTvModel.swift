//
//  MyTvModel.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/17.
//

import Foundation

enum MyTvStatus{
    case initate
}

enum MyTvEvent{
    case channelChanged, channelUpdated(Channel), channelUpdateError(Channel)
}

class MyTvModel:ObservableObject{
    @Published private(set) var status:MyTvStatus = .initate
    @Published private(set) var event:MyTvEvent? = nil
    
    private(set) var channels:[Channel] = []
    private(set) var currentChannel:Channel? = nil
    private(set) var upChannel:Channel? = nil
    private(set) var downChannel:Channel? = nil
    private var maxVerticalIndex:Int = 0
    private var currentVerticalIndex:Int = 0
    
    func setupChannel(_ channels:[Channel], initChannel:String? = nil){
        if channels.isEmpty {return}
        self.channels = channels
        self.maxVerticalIndex = channels.count
        if let initChannel = initChannel {
            if self.moveChannel(id: initChannel) {return}
        }
        
        if let current = self.currentChannel {
            let find = channels.first(where: {$0.channelId == current.channelId}) ?? channels.first!
            self.selectChannel(find)
        } else {
            self.selectChannel(channels.first!)
        }
        
    }
    @discardableResult
    func moveChannel(id:String)-> Bool{
        guard let find = self.channels.first(where: {$0.channelId == id}) else {return false}
        self.selectChannel(find)
        return true
    }
    
    func moveableChannel(_ vector:Int)-> Bool{
        let willPos = currentVerticalIndex + vector
        if willPos < 0 {return false}
        if willPos >= maxVerticalIndex {return false}
        return true
    }
    
    @discardableResult
    func moveChannel(_ vector:Int)-> Bool{
        let willPos = currentVerticalIndex + vector
        if willPos < 0 {return false}
        if willPos >= maxVerticalIndex {return false}
        selectChannel(self.channels[willPos])
        return true
    }
    
    func getChannel(directon:Viewer.Direction)->Channel?{
        switch directon {
        case .top : return self.upChannel
        case .bottom : return self.downChannel
        default : return nil
        }
    }
    
    func updatedChannel(id:String, data:RaceData){
        if let channel = self.channels.first(where: {$0.channelId == id }) {
            channel.setData(channelData: data) 
            self.event = .channelUpdated(channel)
        }
    }
    func updatedChannel(id:String, data:EpgData){
        if let channel = self.channels.first(where: {$0.channelId == id }) {
            channel.setData(channelData: data)
            self.event = .channelUpdated(channel)
        }
    }
    
    func updatedChannel(id:String, data:LiveStream){
        if let channel = self.channels.first(where: {$0.channelId == id }) {
            channel.setData(channelData: data)
            self.event = .channelUpdated(channel)
        }
    }
    func errorChannel(id:String){
        if let channel = self.channels.first(where: {$0.channelId == id }) {
            self.event = .channelUpdateError(channel)
        }
    }
    private func selectChannel(_ channel:Channel){
        self.currentChannel = channel
        self.currentVerticalIndex = channel.index
        let up = channel.index - 1
        let down = channel.index + 1
        self.upChannel = up >= 0 ? self.channels[up] : nil
        self.downChannel = down < self.channels.count ? self.channels[down] : nil
        self.event = .channelChanged
    }
    
}
