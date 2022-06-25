//
//  GestureViewData.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/23.
//

import Foundation
extension GestureViewer {
    
    func onApiResultResponds(_ res:ApiResultResponds?){
        guard let res = res else {return}
        switch res.type {
        case .getChannel :
            self.respondBandChannel(res: res)
        case .getRace :
            guard let data = res.data as? RaceData else {
                self.myTvModel.errorChannel(id: res.id)
                return
            }
            self.myTvModel.updatedChannel(id: res.id, data: data)
        case .getEpg :
            guard let data = res.data as? EpgData else {
                self.myTvModel.errorChannel(id: res.id)
                return
            }
            self.myTvModel.updatedChannel(id: res.id, data: data)
        case .getLiveStreaming :
            guard let data = res.data as? LiveStream else {
                self.myTvModel.errorChannel(id: res.id)
                return
            }
            self.myTvModel.updatedChannel(id: res.id, data: data)
        case .getPlay(let epsdRsluId, let isPersistent) :
            guard let data = res.data as? Play else {return self.stop(error: .play)}
            self.play(data: data, epsdRsluId: epsdRsluId, isPersistent: isPersistent)
        default : break
        }
    }
    
    func onApiResultError(_ err:ApiResultError?){
        guard let err = err else {return}
        switch err.type {
        case .getChannel : self.respondBandChannel(err: err)
        case .getRace, .getEpg, .getLiveStreaming: self.myTvModel.errorChannel(id: err.id)
        default : break
        }
    }
    
    func requestBandChannel(){
        if self.dataProvider.bands.allBands.isEmpty {
            self.dataProvider.bands.setData(channelData: ChannelData())
            return
        }
        self.dataProvider.bands.allBands.forEach{ band in
            self.requestBandKey.append(band.channelId)
            self.dataProvider.requestData(q: .init(id:band.channelId, type: band.api))
        }
    }
    func respondBandChannel(res:ApiResultResponds){
        guard let find = self.requestBandKey.firstIndex(of: res.id) else { return }
        self.requestBandKey.remove(at: find)
        guard let data = res.data as? ChannelData else {
            self.dataProvider.bands.setData(channelData: ChannelData())
            return
        }
        self.dataProvider.bands.setData(channelData: data)
    }
    func respondBandChannel(err:ApiResultError){
        guard let find = self.requestBandKey.firstIndex(of: err.id) else { return }
        self.requestBandKey.remove(at: find)
        self.dataProvider.bands.setData(channelData: ChannelData())
    }
    func setupBandChannel(){
        if !self.requestBandKey.isEmpty {return}
        self.isReady = true
        self.changeStatus(.ready)
        self.myTvModel.setupChannel(self.dataProvider.bands.allChannels, initChannel: self.initChannel)
        self.initChannel = nil
    }
}
