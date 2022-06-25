//
//  Repository.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import VideoSubscriberAccount
enum RepositoryStatus:Equatable{
    case initate, ready, reset, error(ApiResultError?)
    var description: String {
        switch self {
        case .initate: return "initate"
        case .ready: return "ready"
        case .reset: return "reset"
        case .error: return "error"
            
        }
    }
    
    static func ==(lhs: RepositoryStatus, rhs: RepositoryStatus) -> Bool {
        switch (lhs, rhs) {
        case ( .initate, .initate):return true
        case ( .ready, .ready):return true
        case ( .reset, .reset):return true
        default: return false
        }
    }
}

enum RepositoryEvent{
    case updatedWatchLv, updatedAdultAuth, reset
}

class Repository:ObservableObject, PageProtocol{
    @Published var status:RepositoryStatus = .initate
    @Published var event:RepositoryEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    private(set) var appSceneObserver:AppSceneObserver? = nil
    private(set) var dataProvider:DataProvider? = nil
    private(set) var downLoadTaskProvider:DownLoadTaskProvider? = nil
    let apiCoreDataManager = ApiCoreDataManager()
    let storage = LocalStorage()
    let downloadManager = DownloadManager()
    private(set) var apiManager:ApiManager = ApiManager()
   

    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
    private(set) var isFirstLaunch = false
    init(){
        apiCoreDataManager.creteTable()
        
    }
    
    func setupEnvironmentObject(
        dataProvider:DataProvider? = nil,
        appSceneObserver:AppSceneObserver? = nil,
        downLoadTaskProvider:DownLoadTaskProvider? = nil
      
    ) {
        //let local = NSLocale.current.currencyCode
        DataLog.d("setupEnvironmentObject", tag:self.tag)
        self.dataProvider = dataProvider
        self.downLoadTaskProvider = downLoadTaskProvider
        self.appSceneObserver = appSceneObserver
        self.isFirstLaunch = self.setupSetting()
        self.setupDataProvider()
        self.setupDownLoadTaskProvider()
        self.setupApiManager()
       
    }
    
    deinit {
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
    }
    
    func reset(){
        DataLog.d("reset", tag:self.tag)
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
        self.apiManager.clear()
        self.apiManager = ApiManager()
        self.setupApiManager()
        self.status = .reset
    }
    private func setupSetting()->Bool{
        if self.storage.initate {
            self.storage.initate = false
            SystemEnvironment.firstLaunch = true
            return true
        }
        return false
    }
    
    private func setupDataProvider(){
       self.dataProvider?.$request.sink(receiveValue: { req in
            guard let apiQ = req else { return }
            if apiQ.isLock {
                self.appSceneObserver?.isLock = true
            } else if !apiQ.isOptional && !apiQ.isLog {
                self.appSceneObserver?.isLoading = true
            }
            if let coreDatakey = apiQ.type.coreDataKey(){
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            } else{
                self.apiManager.load(q: apiQ)
            }
        }).store(in: &anyCancellable)
    }
    
    private func setupDownLoadTaskProvider(){
       self.downLoadTaskProvider?.addAllLoadedFiles(self.downloadManager.getAllFiles())
       self.downLoadTaskProvider?.$request.sink(receiveValue: { req in
           guard let q = req else { return }
           let id = q.fildID
           if q.type == .delete {
               self.downloadManager.deleteFile(id: id)
               self.downLoadTaskProvider?.removeTask(id: id)
               return
           }
           
           let task = self.downloadManager.download(
            id: id, path: q.path, ckcURL: q.ckcURL, licenseData:q.licenseKey, isStart: q.isStart){
               path , err in
               if let err = err {
                   self.downLoadTaskProvider?.errorTask(id: id, err: err)
               }
               if let path = path {
                   self.downLoadTaskProvider?.completedTask(id: id, path: path, file:self.downloadManager.getFile(id: id))
               }
               
           }
           self.downLoadTaskProvider?.addTask(task, q:q)
           
        }).store(in: &anyCancellable)
    }
    
    private func setupApiManager(){
        self.apiManager.initateApi()
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            self.respondApi(res)
            self.dataProvider?.result = res
            if !res.isOptional && !res.isLog {
                self.appSceneObserver?.isLoading = false
                self.appSceneObserver?.isLock = false
            }
        }).store(in: &dataCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            if self.status != .ready && !err.isOptional && !err.isLog{
                self.status = .error(err)
            }
            self.dataProvider?.error = err
            if !err.isOptional && !err.isLog {
                self.appSceneObserver?.alert = .apiError(err)
                self.appSceneObserver?.isLoading = false
                self.appSceneObserver?.isLock = false
            }
            
        }).store(in: &dataCancellable)
        
        
        self.apiManager.$status.sink(receiveValue: { status in
            if status == .ready { self.onReadyApiManager() }
        }).store(in: &dataCancellable)
    }
    
    
    
    private func requestApi(_ apiQ:ApiQ, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            var coreData:Codable? = nil
            switch apiQ.type {
                case .getGnb:
                    if let savedData:GnbBlock = self.apiCoreDataManager.getData(key: coreDatakey){
                        coreData = savedData
                        DispatchQueue.main.async {
                            DataLog.d("respond coreData getGnb", tag:self.tag)
                            self.onReadyRepository(gnbData: savedData)
                        }
                    }
                default: break
            }
             
            DispatchQueue.main.async {
                if let coreData = coreData {
                    self.dataProvider?.result = ApiResultResponds(
                        id: apiQ.id,
                        type: apiQ.type,
                        data: coreData,
                        isOptional: apiQ.isOptional,
                        isLog: apiQ.isLog
                        )
                    self.appSceneObserver?.isLoading = false
                }else{
                    self.apiManager.load(q: apiQ)
                }
            }
        }
    }
    private func respondApi(_ res:ApiResultResponds, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            switch res.type {
                case .getGnb :
                    guard let data = res.data as? GnbBlock  else { return }
                    DataLog.d("save coreData getGnb", tag:self.tag)
                    self.apiCoreDataManager.setData(key: coreDatakey, data: data)
                    DispatchQueue.main.async {
                        self.onReadyRepository(gnbData: data)
                    }
                default: break
            }
        }
    }
    private func respondApi(_ res:ApiResultResponds){
        if let coreDatakey = res.type.coreDataKey(){
            self.respondApi(res, coreDatakey: coreDatakey)
        }
        switch res.type {
        case .getGnb :
            guard let data = res.data as? GnbBlock  else { return }
            if data.gnbs == nil || data.gnbs!.isEmpty {
                self.status = .error(nil)
                return
            }
            self.onReadyRepository(gnbData: data)
        
        default: break
        }
    }
    
    private func onReadyApiManager(){
        DataLog.d("onReadyApiManager", tag:self.tag)
        self.dataProvider?.requestData(q: .init(type: .getGnb))
    }
    
    private func onReadyRepository(gnbData:GnbBlock){
        self.dataProvider?.bands.setData(gnbData)
        //self.appSceneObserver?.event = .toast("onReadyRepository " + (SystemEnvironment.isStage ? "STAGE" : "RELEASE"))
        DataLog.d("onReadyRepository " + self.status.description , tag:self.tag)
        DataLog.d("onReadyRepository " + (gnbData.total_count?.description ?? "nodata") , tag:self.tag)
        if self.status == .reset {
            self.event = .reset
            self.status = .ready
            
        }else if self.status != .ready {
            self.status = .ready
        }
    }
    
    func retryRepository()
    {
        self.status = .reset
        self.reset()
    }
}
