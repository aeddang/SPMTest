//
//  Channel.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/16.
//

import Foundation
import SwiftUI

enum ChannelStatus{
    case initate, ready
}
enum ChannelEvent{
    case updated
}
enum ChannelType{
    case band, live, vodLive, recommand, vod
    static func getType(_ value:String?)->ChannelType{
        switch value {
        case "20": return .recommand //추천
        case "50": return .band // 032 로 서브체널 불러옴
        default : return .vod
        }
    }
    
    var color: Color {
        switch self {
        case .recommand: return Color.app.blue80
        case .live: return Color.app.blue60
        default: return Color.app.darkBlue60
        }
    }
}

class Channel:ObservableObject, PageProtocol, Identifiable {
    let id = UUID().uuidString
    private(set) var name:String? = nil
    private(set) var menuId:String = ""
    private(set) var csvId:String = ""
    private(set) var cwCallId:String = ""
    private(set) var gnbTypCd:String = ""

    private(set) var type:ChannelType = .live
    private(set) var index:Int = -1
    private(set) var updatedTime:Date = Date()
   
    var needUpdate:Bool {
        get{
            if self.programs.isEmpty {return true}
            if let update = self.programs.first?.currentItem?.updateTime {
                return update.timeIntervalSinceNow >= 0 
            }
            return updatedTime.timeIntervalSinceNow > SystemEnvironment.epgUpdateTime
        }
    }
    private(set) var programs:[Program] = []
    var finalIndex:Int = 0
    var channelId:String {
        get{
            return self.csvId+self.menuId+self.cwCallId
        }
    }
    
    var currentProgram:Program? {
        get{
            if programs.isEmpty {return nil}
            if self.finalIndex >= programs.count {return programs.first}
            return programs[self.finalIndex]
        }
    }
    
    var currentTitle:String {
        get{
            return (self.name ?? "") 
        }
    }
    
    var api:ApiType {
        get {
            switch self.type{
            case .band : // 체널 서브 체널 불러오기
                return .getChannel(menuId: self.menuId)
            case .live : //실시간
                return .getLiveStreaming( csvId:self.csvId)
            case .recommand : // 추천
                return .getRace(menuId: self.menuId, cwCallId: self.cwCallId)
            case .vod : // 단편 VOD
                return .getEpg(csvId: self.csvId)
            case .vodLive : //실시간 VOD
                let now = AppUtil.networkTimeDate()
                return .getEpg(csvId: self.csvId, now: now, addTime: 4)
            }
        }
    }
    
    func setData(_ data:BlockItem, index:Int) -> Channel{
        self.index = index
        name = data.menu_nm
        menuId = data.menu_id ?? ""
        cwCallId = data.cw_call_id_val ?? ""
        gnbTypCd = data.gnb_typ_cd ?? ""
        type = ChannelType.getType(data.blk_typ_cd)
        return self
    }
    func setData(_ data:ChannelItem, index:Int) -> Channel{
        self.index = index
        name = data.name
        csvId = data.id ?? ""
        if data.vod_control_yn?.toBool() == false {
            type = .live
        } else {
            type = .vod
        }
        return self
    }
 
    func setData(channelData:RaceData){
        self.updatedTime = AppUtil.networkTimeDate()
        if let groups = channelData.grid {
            self.programs.removeAll()
            var idx = 0
            groups.forEach{ group in
                if let channels = group.block {
                    let adds:[Program] = channels.map{ channel in
                        let program = Program().setData(channel, index: idx)
                        idx += 1
                        return program
                    }
                    self.programs.append(contentsOf: adds)
                }
            }
        }
    }
    func setData(channelData:EpgData){
        self.updatedTime = AppUtil.networkTimeDate()
        self.programs.removeAll()
        guard let channel = channelData.epg?.first else {return}
        if self.type == .vod {
            if let items = channel.programs{
                var idx = 0
                let adds:[Program] = items.map{ item in
                    let program = Program().setData(item, index: idx)
                    idx += 1
                    return program
                }
                self.programs.append(contentsOf: adds)
            }
        } else {
            let program = Program().setData(channel, index: 0)
            self.programs.append(program)
        }
        
    }
    
    func setData(channelData:LiveStream){
        self.programs.removeAll()
        guard let channel = channelData.data?.channels?.first else {return}
        let program = Program().setData(channel, index: 0) 
        self.programs.append(program)
    }
    
    func addMyfile(files:[String:HLSFile]) {
        let prevKeys = self.programs.map{$0.currentItemKey ?? ""}
        var idx = self.programs.count
        files.keys.forEach{ key in
            if prevKeys.first(where: {key == $0}) == nil {
                let file = files[key]
                if file?.isExfire == false, let file = file {
                    self.programs.append(Program().setData(file, index: idx))
                    idx += 1
                }
            } 
        }
    }
    
    func addMyfile(file:HLSFile) {
        let prevKeys = self.programs.map{$0.currentItemKey ?? ""}
        if prevKeys.first(where: {file.id == $0}) == nil {
            self.programs.append(Program().setData(file, index: self.programs.count))
        }
    }
}

