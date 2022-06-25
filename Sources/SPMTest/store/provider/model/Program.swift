//
//  Program.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/21.
//

import Foundation
import SwiftUI

enum ProgramType{
    case vod, myFile, liveVod, live
    static func getType(_ value:String?)->ProgramType{
        switch value {
        default : return .liveVod
        }
    }
}
class Program:PageProtocol, Identifiable {
    let id = UUID().uuidString
    private(set) var programId:String = ""
    private(set) var name:String? = nil
    private(set) var genre:String? = nil
    private(set) var type:ProgramType = .vod
    private(set) var index:Int = -1
    private(set) var datas:[PlayItem] = []
    private(set) var needUpdate:Bool = false
    private(set) var image:ImageSet? = nil
    private(set) var seekAble:Bool = false
    
    var currentItem:PlayItem? {
        get{
            if self.type == .liveVod {
                let now = AppUtil.networkTimeDate().timeIntervalSince1970
                if let find = self.datas.first(where: {
                    ($0.endTime-3) > now  //실행하자마자 끊기는 사고 방지 3초
                }) {
                    find.playTime = now - find.startTime
                    return find
                }
                return nil
            } else {
                return datas.first
            }
        }
    }
    var currentImage:ImageSet? {
        get{
            if let path = currentItem?.image {
                return path
            }
            return self.image
        }
    }
    var currentTitle:String? {
        get{
            let title = currentItem?.epsdTitle
            return title ?? self.name
        }
    }
    var currentItemKey:String? {
        get{
            return currentItem?.epsdRsluId
        }
    }
    var currentCommentary:String? {
        get{
            return currentItem?.commentary
        }
    }
    func setData(_ data:HLSFile, index:Int) -> Program{
        self.index = index
        datas.append(PlayItem().setData(data, index: 0))
        type = .myFile
        seekAble = true
        return self
    }
    
    func setData(_ data:ProgramItem, index:Int) -> Program{
        self.index = index
        type = .vod
        programId = data.episode_id ?? ""
        datas.append(PlayItem().setData(data, index: 0))
        seekAble = true
        return self
    }
    
    func setData(_ data:ChannelItem, index:Int) -> Program{
        self.index = index
        name = data.name ?? ""
        programId = data.id ?? ""
        genre = data.genre_name
        type = .liveVod
        if let items = data.programs {
            datas = zip(0 ..< items.count,items).map{ idx, item in
                PlayItem().setData(item, index: idx)
            }
        }
        seekAble = false
        image = ImageSet().setData(datas: data.images)
        return self
    }
    
    func setData(_ data:ContentItem, index:Int) -> Program{
        self.index = index
        programId = data.epsd_id ?? ""
        type = .vod
        datas.append(PlayItem().setData(data, index: 0))
        seekAble = true
        return self
    }
    
    func setData(_ data:LiveStreamChannel, index:Int) -> Program{
        self.index = index
        programId = data.id ?? ""
        type = .live
        datas.append(PlayItem().setData(data, index: 0))
        seekAble = false
        return self
    }
}


class PlayItem:PageProtocol, Identifiable {
    let id = UUID().uuidString
    private(set) var epsdRsluId:String = ""
    private(set) var title:String? = nil
    private(set) var image:ImageSet? = nil
    private(set) var index:Int = -1
    private(set) var programData:ProgramItem? = nil
    private(set) var contentData:ContentItem? = nil
    private(set) var streamData:LiveStreamItem? = nil
   
    private(set) var file:HLSFile? = nil
    private(set) var startTime:Double = 0
    private(set) var endTime:Double = 0
    private(set) var age:String? = nil
    private(set) var seq:String? = nil
    private(set) var date:Date? = nil
    private(set) var commentary:String? = nil
    private(set) var duration:String? = nil
    fileprivate(set) var playTime:Double = 0
    private(set) var updateTime:Date? = nil
    
    var epsdTitle:String? {
        get{
            guard let title = self.title else {return nil}
            if let seq = self.seq {
                return title + " " + seq + String.app.seq
            }
            return title
        }
    }
    
    func setData(_ data:HLSFile, index:Int) -> PlayItem{
        self.index = index
        self.file = data
        self.epsdRsluId = data.id
        if let metaData = data.meta?.metaData {
            if let item:ContentItem = ContentCoreData.decode(jsonString: metaData) {
                return self.setData(item, index: index)
            }
        }
        return self
    }
    func setData(_ data:ProgramItem, index:Int) -> PlayItem{
        self.index = index
        self.epsdRsluId = data.episode_rslu_id ?? ""
        self.title = data.title
        self.commentary = data.commentary
        self.programData = data
        self.startTime = data.start_time?.toDate(dateFormat: "yyyyMMddHHmmss")?.timeIntervalSince1970 ?? 0
        self.endTime = data.end_time?.toDate(dateFormat: "yyyyMMddHHmmss")?.timeIntervalSince1970 ?? 0
        self.image = ImageSet().setData(datas: data.images)
        if data.rating?.isEmpty == false {
            self.age = data.rating
        }
        if data.episode_seq?.isEmpty == false {
            self.seq = data.episode_seq
        }
        return self
    }
    
    func setData(_ data:ContentItem, index:Int) -> PlayItem{
        self.index = index
        self.title = data.title
        self.contentData = data
        self.date = data.svc_fr_dt?.toDate(dateFormat: "yyyyMMddHHmmss")
        self.epsdRsluId = data.epsd_rslu_id ?? ""
        image = ImageSet()
            .setData(still: data.poster_filename_h , thumb: data.thumbnail_filename_h)
        if data.wat_lvl_cd?.isEmpty == false {
            self.age = data.wat_lvl_cd
        }
        if data.brcast_tseq_nm?.isEmpty == false {
            self.seq = data.brcast_tseq_nm
        }
        return self
    }
    
    func setData(_ data:LiveStreamChannel, index:Int) -> PlayItem{
        self.index = index
        self.title = data.name
        self.epsdRsluId = data.id ?? ""
        self.image = ImageSet().setData(datas: data.images)
        
        guard let stream = data.stream_info else {return self}
        //self.updateTime = stream.limit_time?.toDate(dateFormat: "yyyyMMddHHmmss") 이상한 시간줌...
        if stream.stream_urls?.isEmpty == false {
            self.streamData = stream
        }
        return self
    }
    
}
