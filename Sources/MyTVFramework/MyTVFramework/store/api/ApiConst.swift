//
//  ApiConst.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit

struct ApiPath {
    static func getRestApiPath(_ server:ApiServer) -> String {
        /*
        if let vmsPath = SystemEnvironment.serverConfig[server.configKey] {
            DataLog.d(server.configKey + " : " +  vmsPath, tag: "ApiPath")
            if vmsPath != "" { return vmsPath }
        }*/
        return server.getPath(isStage: SystemEnvironment.isStage)
    }
}

struct ApiGateway{
    static let API_KEY = "l7xx159a8ca72966400b886a93895ec9e2e3"
    static let DEBUG_API_KEY = "l7xx159a8ca72966400b886a93895ec9e2e3"
    
    static func setGatewayheader( request:URLRequest, useMykey:Bool = false ) -> URLRequest{
        var authorizationRequest = request
        authorizationRequest.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Accept")
        
        
        let timestamp = Date().toDateFormatter(dateFormat: "yyyyMMddHHmmss.SSS", local: "en_US_POSIX")
        
        //let token = ""
        //let inputData = Data((token+timestamp).utf8)
        //let authVal = CryptoKit.SHA256.hash(data: inputData).data.base64EncodedString()
        
        authorizationRequest.setValue("I7xx6e7b667188364c329cac10f97e38a238", forHTTPHeaderField: "Api_Key")
        authorizationRequest.setValue( SystemEnvironment.apolloToken, forHTTPHeaderField: "Auth_Val")
        authorizationRequest.setValue( timestamp, forHTTPHeaderField: "TimeStamp")
        
        
        authorizationRequest.setValue( SystemEnvironment.deviceId , forHTTPHeaderField: "Client_ID")
        authorizationRequest.setValue( AppUtil.getIPAddress() ?? "" , forHTTPHeaderField: "Client_IP")
        authorizationRequest.setValue( SystemEnvironment.bundleVersion, forHTTPHeaderField: "Client_SWVer")
        authorizationRequest.setValue( "BIP-EB100" , forHTTPHeaderField: "Client_Model")

        authorizationRequest.setValue( "MyTV^APIGW" , forHTTPHeaderField: "Trace")
        authorizationRequest.setValue( "close" , forHTTPHeaderField: "Connection")
        if useMykey {
            authorizationRequest.setValue( SystemEnvironment.apolloToken, forHTTPHeaderField: "mytv_auth_key")
            //authorizationRequest.setValue( SystemEnvironment.apolloToken, forHTTPHeaderField: "Auth_Val")
        }
        return authorizationRequest
    }
    
    static func setDefaultheader( request:URLRequest) -> URLRequest{
        var authorizationRequest = request
        authorizationRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        authorizationRequest.setValue(
            SystemEnvironment.model+"/"+SystemEnvironment.model, forHTTPHeaderField: "x-device-info")
        authorizationRequest.setValue(
            ApiPrefix.iphone+"/"+SystemEnvironment.systemVersion, forHTTPHeaderField: "x-os-info")
        authorizationRequest.setValue(
            ApiPrefix.service+"/"+SystemEnvironment.bundleVersion , forHTTPHeaderField: "x-service-info")
        authorizationRequest.setValue(
            SystemEnvironment.deviceId , forHTTPHeaderField: "x-did-info")
        return authorizationRequest
    }
    
}

struct ApiPrefix {
    static let os =  "ios"
    static let iphone = "iphone"
    static let ipad = "ipad"
    static let service = "btvplus"
    static let device = "I"
}

struct ApiConst {
   
    static let defaultStbId = "{00000000-0000-0000-0000-000000000000}"
    static let defaultMacAdress = "ff:ff:ff:ff:ff:ff"
    
}

struct ApiCode {
    static let ok = "OK"
    static let success = "0000"
    static let success2 = "000"
    
    static let duplication = "2001"
}

enum ApiAction:String{
    case password
}

enum ApiValue:String{
    case video
}

enum ApiServer:String{
    case HEB, IMAGE, EUXP,IIP, SCS2
    var configKey:String {
        get {
            switch self {
            case .IMAGE: return "image"
            case .EUXP: return "euxp"
            case .IIP: return "iip"
            case .SCS2: return "scs2"
            default : return ""
            }
        }
    }
    func getPath(isStage:Bool)->String {
        switch self {
        case .IMAGE: return ServerConst.IMAGE
        case .HEB: return isStage ? ServerConst.HEB_STG : ServerConst.HEB
        case .EUXP: return isStage ? ServerConst.EUXP_STG : ServerConst.EUXP
        case .IIP: return isStage ? ServerConst.IIP_STG : ServerConst.IIP
        case .SCS2: return isStage ? ServerConst.SCS2_STG : ServerConst.SCS2
        }
    }

}
