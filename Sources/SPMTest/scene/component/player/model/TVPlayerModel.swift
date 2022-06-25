//
//  BtvPlayerModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
//

import Foundation
import SwiftUI

struct Quality {
    var name:String
    let path:String
    let drmLicense:String?
}

class TVPlayerModel:PlayerModel{
    private(set) var qualitys:[Quality] = []
    @Published var selectQuality:Quality? = nil
    @Published var currentQuality:Quality? = nil
    @Published private(set) var currentPlayId:String? = nil
    
    @Published var selectOptionType:OptionSelectBox.SelectOptionType? = nil
    
    @Published var isCaptionSelect = false
    @Published var selectedCaptionLang:String = ""
    @Published var selectedCaptionSize:Int = 1
    
    
    var selectedQuality:String? = nil
    var continuousTime:Double = 0
   
    private(set) var autoPlay:Bool = true
    override func reset() {
        self.currentPlayId = nil
        self.currentQuality = nil
        self.qualitys = []
        super.reset()
    }
    

    @discardableResult
    func setData(data:PlayInfo,
                 currentPlayId:String? = nil,
                 autoPlay:Bool? = nil, //자동 재생
                 continuousTime:Double? = nil,
                 isSeekAble:Bool? = nil
    ) -> TVPlayerModel {
        
        
        var isAutoPlay = self.isUserPlay
        self.reset()
        if let able = isSeekAble { self.isSeekAble = able }
        if let autoPlay = autoPlay {
            ComponentLog.d("force setup initPlay " + autoPlay.description , tag: self.tag)
            isAutoPlay = autoPlay
        }
        if let continuousTime = continuousTime {
            ComponentLog.d("force setup continuousTime " + continuousTime.description , tag: self.tag)
            self.continuousTime = continuousTime
        }
        
        if let auto = data.CNT_URL_NS_AUTO {
            self.appendQuality(name: "AUTO", path: auto, drmLicense:data.HLS_AUTO_LICENSE_URL ) }
        if let sd = data.CNT_URL_NS_SD  {
            self.appendQuality(name: "SD", path: sd, drmLicense:data.HLS_SD_LICENSE_URL) }
        if let hd = data.CNT_URL_NS_HD  {
            self.appendQuality(name: "HD", path: hd, drmLicense:data.HLS_HD_LICENSE_URL) }
        if let fhd = data.CNT_URL_NS_FHD {
            self.appendQuality(name: "FHD", path: fhd, drmLicense:data.HLS_FHD_LICENSE_URL) }
        self.autoPlay = isAutoPlay
        self.setupQuality()
        self.currentPlayId = currentPlayId
        return self
    }

    @discardableResult
    func setData(data:LiveStreamItem,
                 autoPlay:Bool? = nil
                
    ) -> TVPlayerModel {
        
        var isAutoPlay = self.isUserPlay
        self.reset()
        self.isSeekAble = false
        if let autoPlay = autoPlay {
            ComponentLog.d("force setup initPlay " + autoPlay.description , tag: self.tag)
            isAutoPlay = autoPlay
        }
        guard let streams = data.stream_urls else {return self}
        streams.forEach{ stream in
            if let path = stream.url {
                let decodePath = AESUtil.decrypt(encoded: path)
                self.appendQuality(name: stream.quality ?? "", path: decodePath)
            }
        }
        self.autoPlay = isAutoPlay
        self.setupQuality()
        return self
    }
    
    @discardableResult
    func setData(data:HLSFile,
                 autoPlay:Bool? = nil,
                 continuousTime:Double? = nil
    ) -> TVPlayerModel {
        
        var isAutoPlay = self.isUserPlay
        self.reset()
        if let autoPlay = autoPlay {
            ComponentLog.d("force setup initPlay " + autoPlay.description , tag: self.tag)
            isAutoPlay = autoPlay
        }
        self.autoPlay = isAutoPlay
        let drm = FairPlayDrm(persistKeys: data.persistKeys)
        self.drm = drm
        self.event = .load(data.filePath, nil, continuousTime ?? 0, seekAble:true)
        self.currentPlayId = data.id
        return self
    }
    
    private func setupQuality(){
        self.currentQuality = self.selectQuality(qualitys: self.qualitys)
    }
    private func appendQuality(name:String, path:String, drmLicense:String? = nil){
        guard let q = self.getQuality(name: name, path: path, drmLicense:drmLicense) else {return}
        self.qualitys.append(q)
    }
    
    @discardableResult
    func getDownLoadData(data:PlayInfo) -> Quality? {
        var qualitys:[Quality] = []
        if let auto = data.CNT_URL_NS_AUTO {
            if let q = self.getQuality(name: "AUTO", path: auto, drmLicense:data.HLS_AUTO_LICENSE_URL ){
                qualitys.append(q)
            }
        }
        if let sd = data.CNT_URL_NS_SD  {
            if let q = self.getQuality(name: "SD", path: sd, drmLicense:data.HLS_SD_LICENSE_URL ){
                qualitys.append(q)
            }
        }
        if let hd = data.CNT_URL_NS_HD  {
            if let q = self.getQuality(name: "HD", path: hd, drmLicense:data.HLS_HD_LICENSE_URL ){
                qualitys.append(q)
            }
        }
        if let fhd = data.CNT_URL_NS_FHD {
            if let q = self.getQuality(name: "FHD", path: fhd, drmLicense:data.HLS_FHD_LICENSE_URL){
                qualitys.append(q)
            }
        }
        return self.selectQuality(qualitys: qualitys)
    }
    
    private func getQuality(name:String, path:String, drmLicense:String? = nil)->Quality?{
        if path.isEmpty {return nil}
        return Quality(name: name, path: path, drmLicense:drmLicense)
    }
    
    private func selectQuality(qualitys:[Quality])->Quality?{
        if !qualitys.isEmpty {
            var willCurrentQuality:Quality? = nil
            let selectQuality = self.selectedQuality ?? "AUTO"
            willCurrentQuality = qualitys.first{$0.name == selectQuality}
            if willCurrentQuality == nil {
                willCurrentQuality = qualitys.first
                ComponentLog.d("firstQuality " + selectQuality, tag:self.tag)
            } else {
                ComponentLog.d("selectQuality " + selectQuality, tag:self.tag)
            }
            return willCurrentQuality
        } else {
            return nil
        }
    }
}

