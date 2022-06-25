//
//  Api.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
struct ApiError :Error,Identifiable{
    let id = UUID().uuidString
    var message:String? = nil
    static func getViewMessage(message:String?)->String{
        return message ?? String.alert.apiErrorServer
    }
}

struct ApiQ :Identifiable{
    var id:String = UUID().uuidString
    let type:ApiType
    var isOptional:Bool = false
    var isLock:Bool = false
    var isLog:Bool = false
    var isProcess:Bool = false
    func copy(newId:String? = nil) -> ApiQ {
        let nid = newId ?? id
        return ApiQ(id: nid, type: type, isOptional: isOptional, isLock: isLock, isLog:isLog)
    }
}

struct ApiResultResponds:Identifiable{
    let id:String
    let type:ApiType
    let data:Any
    let isOptional:Bool
    let isLog:Bool
}

struct ApiResultError :Identifiable{
    let id:String
    let type:ApiType
    let error:Error
    var isOptional:Bool = false
    var isLog:Bool = false
    var isProcess:Bool = false
}

enum ApiType{
    // EUXP
    case getBoot,
         getGnb, getChannel(menuId:String?),
         getRace(menuId:String?, cwCallId:String?), getEpg(csvId:String?, now:Date? = nil, addTime:Double = 24),
         getSynopsis(SynopsisData)
    //SCS
    case getPlay(epsdRsluId:String?, isPersistent:Bool = false)
    //HEB
    case getLiveStreaming(csvId:String?)
    
    func coreDataKey() -> String? {
        switch self {
        //case .getGnb : return "getGnb"
        default : return nil
        }
    }
    func transitionKey() -> String {
        switch self {
       // case .registHello : return "postHello"
        default : return ""
        }
    }
}


