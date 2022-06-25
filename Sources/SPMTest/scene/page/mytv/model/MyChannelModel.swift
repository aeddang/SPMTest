//
//  MyTvModel.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/17.
//

import Foundation

enum MyChannelStatus{
    case initate
}

enum MyChannelEvent{
    case programChanged, programUpdated(Program), currentChannelUpdated(Channel)
}

class MyChannelModel:ObservableObject{
    @Published private(set) var status:MyChannelStatus = .initate
    @Published private(set) var event:MyChannelEvent? = nil
    private(set) var currentChannel:Channel? = nil
    private(set) var programs:[Program] = []
    private(set) var currentProgram:Program? = nil
    private(set) var leftProgram:Program? = nil
    private(set) var rightProgram:Program? = nil
    
    private var maxHorizontalIndex:Int = 0
    private var currentHorizontalIndex:Int = 0
    var initProgram:String? = nil
    func setupProgram(_ channel:Channel){
        self.currentChannel = channel
        self.event = .currentChannelUpdated(channel)
        self.programs = channel.programs
        self.maxHorizontalIndex = self.programs.count
        if let initProgram = self.initProgram {
            self.initProgram = nil
            if self.moveProgram(id:initProgram) { return }
        }
        if let current = channel.currentProgram {
            self.selectProgram(current)
        } else {
            self.emptyProgram()
        }
        
    }
    
    @discardableResult
    func moveProgram(id:String)-> Bool{
        guard let find = self.programs.first(where: {$0.programId == id}) else {return false}
        self.selectProgram(find)
        return true
    }
    
    func moveableProgram(_ vector:Int)-> Bool{
        let willPos = currentHorizontalIndex + vector
        if willPos < 0 {return false}
        if willPos >= maxHorizontalIndex {return false}
        return true
    }
    
    @discardableResult
    func moveProgram(_ vector:Int)-> Bool{
        let willPos = currentHorizontalIndex + vector
        if willPos < 0 {return false}
        if willPos >= maxHorizontalIndex {return false}
        selectProgram(self.programs[willPos])
        return true
    }
    
    func getProgram(directon:Viewer.Direction)->Program?{
        switch directon {
        case .left : return self.leftProgram
        case .right : return self.rightProgram
        default : return nil
        }
    }
    func updatedProgram(id:String, data:Any? = nil){
        if let program = self.programs.first(where: {$0.programId == id }) {
            //program.setData(channelData: data)
            self.event = .programUpdated(program)
        }
    }

    private func selectProgram(_ program:Program){
        self.currentChannel?.finalIndex = program.index
        self.currentProgram = program
        self.currentHorizontalIndex = program.index
        let left = program.index - 1
        let right = program.index + 1
        self.leftProgram = left >= 0 ? self.programs[left] : nil
        self.rightProgram = right < self.programs.count ? self.programs[right] : nil
        self.event = .programChanged
    }
    
    private func emptyProgram(){
        self.currentProgram = nil
        self.leftProgram = nil
        self.rightProgram = nil
        self.currentHorizontalIndex = 0
        self.event = .programChanged
    }
    
}
