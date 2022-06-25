//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine
enum ApiStatus:String{
    case initate, ready
}

enum ApiEvents{
    case initate
}
enum ApiManagerError: Error {
    case resistHellow(reason:String)
    func getDescription() -> String {
        switch self {
        case .resistHellow(let reason):
            return "resistHellow error " + reason
        }
    }
    
    func getDomain() -> String {
        return "api"
    }
    
    func getCode() -> Int {
        return -1
    }
}


class ApiManager :PageProtocol, ObservableObject{
    @Published var status:ApiStatus = .initate
    @Published var result:ApiResultResponds? = nil {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil {didSet{ if error != nil { error = nil} }}
    @Published var event:ApiEvents? = nil {didSet{ if event != nil { event = nil} }}
    
    private var anyCancellable = Set<AnyCancellable>()
    private var apiQ :[ ApiQ ] = []
    private lazy var euxp:Euxp = Euxp(network: EuxpNetwork())
    private lazy var scs:Scs = Scs(network: ScsNetwork())
    private lazy var heb:Heb = Heb(network: HebNetwork())
    
    var isSystemStop:Bool = false
    
    func clear(){
        if self.status == .initate {return}
        self.euxp.clear()
        self.scs.clear()
        self.apiQ.removeAll()
    }
    
    func initateApi(){
        if self.isSystemStop {return}
        self.heb.getBoot(
            completion:{res in
                if let configs = res.data?.server_info {
                    configs.forEach{ con in
                        if let key = con.id {
                            var value = con.address ?? ""
                            if let port = con.port {
                                value = value + ":" + port
                            }
                            if value.isEmpty == false {
                                SystemEnvironment.serverConfig[key] = value
                                DataLog.d("key " + key + " value " + value, tag:self.tag)
                            }
                        }
                    }
                }
                self.initApi()
            },
            error:{ err in
                DataLog.e("getBoot " + err.localizedDescription, tag:self.tag)
                self.onError(id: "", type: .getBoot, e: err, isOptional: true)
                self.initApi()
            }
        )
    }
    
    func retryApi(){
        self.status = .initate
        initateApi()
    }
    
    func initApi(){
        self.status = .ready
        self.executeQ()
    }
    
    private func executeQ(){
        self.apiQ.forEach{ q in self.load(q: q)}
        self.apiQ.removeAll()
    }
    

    private var transition = [String : ApiQ]()
    func load(q:ApiQ){
        self.load(q.type, resultId: q.id,
                  isOptional: q.isOptional, isLock: q.isLock, isLog:q.isLog, isProcess: q.isProcess)
    }
    

    @discardableResult
    func load(_ type:ApiType, resultId:String = "",
              isOptional:Bool = false, isLock:Bool = false, isLog:Bool = false, isProcess:Bool = false)->String{
        let apiID = resultId //+ UUID().uuidString
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, isOptional: isOptional, isLock: isLock, isLog: isLog))
            return apiID
        }
        
        let error = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional, isLog: isLog, isProcess: isProcess)}
        switch type {
        case .getBoot : self.heb.getBoot(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        case .getGnb : self.euxp.getGnbBlock(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        case .getLiveStreaming(let csvId) : self.heb.getLiveStreaming(csvId: csvId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        case .getChannel(let menuId) : self.euxp.getChannelBlock( menuId: menuId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getRace(let menuId, let cwCallId) : self.euxp.getRaceBlock( menuId: menuId, cwCallId: cwCallId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getEpg(let csvId, let now , let addTime) : self.euxp.getEpg(csvId: csvId, now: now, addTime:addTime,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getSynopsis(let data) : self.euxp.getSynopsis(data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPlay(let epsdRsluId, let isPersistent) : self.scs.getPlay(
            epsdRsluId: epsdRsluId, isPersistent: isPersistent,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        }
        
        return apiID
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:T, isOptional:Bool = false, isLog:Bool = false){
        let result:ApiResultResponds = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
        }
    }
    
    private func complated(id:String, type:ApiType, res:Blank, isOptional:Bool, isLog:Bool){
        let result:ApiResultResponds = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
        }
    }
    
    private func onError(id:String, type:ApiType, e:Error,isOptional:Bool = false, isLog:Bool = false, isProcess:Bool = false){
        if let trans = transition[id] {
            transition.removeValue(forKey: id)
            self.error = .init(id: id, type:trans.type, error: e, isOptional:isOptional, isLog:isLog, isProcess:isProcess)
        }else{
            self.error = .init(id: id, type:type, error: e, isOptional:isOptional, isLog:isLog, isProcess:isProcess)
        }
        
    }

    
}
