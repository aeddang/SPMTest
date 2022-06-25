//
//  Bands.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

enum BandsStatus{
    case initate, ready
}

enum BandsEvent{
    case update, updated, updatedBand, updatedChannels
}

class Bands:ObservableObject, PageProtocol {
    @Published private(set) var status:BandsStatus = .initate
    @Published private(set) var event:BandsEvent? = nil
    private(set) var datas:Array<Band> = []
    
    private(set) var allBands:Array<Channel> = []
    private(set) var allChannels:Array<Channel> = []
    
    func resetData(){
        self.datas = []
        self.status = .initate
        self.event = .update
        self.event = nil
    }
    
    func setData(_ data:GnbBlock?){
        guard let data = data else { return }
        if let gnbs = data.gnbs {
            self.datas = gnbs.map{ gnb in
                return Band().setData(gnb)
            }
        }
        self.status = .ready
        self.event = .updated
        DataLog.d("UPDATEED GNBDATA", tag:self.tag)
        self.event = nil
        self.updateBand()
    }

    func updateBand(){
        self.allBands.removeAll()
        self.allChannels.removeAll()
        var idx = 0
        self.datas.forEach{ band in
            band.blocks.forEach{ block in
                let channel = Channel().setData(block, index: idx)
                if channel.type == .recommand {
                    self.allChannels.append(channel)
                    idx += 1
                } else {
                    self.allBands.append(channel)
                }
            }
            
        }
        self.event = .updatedBand
    }
    
    
    func setData(channelData:ChannelData){
        if let groups = channelData.chnl_grp {
            var idx = self.allChannels.count
            groups.forEach{ group in
                if let channels = group.channels {
                    let adds:[Channel] = channels.map{ channel in
                        let program = Channel().setData(channel, index: idx)
                        idx += 1
                        return program
                    }
                    self.allChannels.append(contentsOf: adds)
                }
            }
        }
        self.event = .updatedChannels
    }
    
    func getData(menuId:String)-> Band? {
        guard let band = self.datas.first(
                where: { $0.menuId == menuId }) else { return nil }
        return band
    }
    
    func getData(gnbTypCd:String)-> Band? {
        guard let band = self.datas.first(
                where: { $0.gnbTypCd.subString(start: 0, len: 5) == gnbTypCd.subString(start: 0, len: 5) }) else { return nil }
        return band
    }
    
    func getHome()-> Band? {
        return self.datas.first
    }
}

class Band {
    private(set) var name:String = ""
    private(set) var menuId:String = ""
    private(set) var gnbTypCd:String = ""

    private(set) var blocks:Array<BlockItem> = []
    
    func setData(_ data:GnbItem) -> Band{
        name = data.menu_nm ?? ""
        menuId = data.menu_id ?? ""
        gnbTypCd = data.gnb_typ_cd ?? ""
        blocks = data.blocks ?? []
        return self
    }
}


