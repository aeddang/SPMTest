//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct ScsNetwork : Network{
    var enviroment: NetworkEnvironment = ServerConst.SCS2_STG//ApiPath.getRestApiPath(.SCS2)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request, useMykey: true)
    }
    func sendCLSLog(_ method:APIMethod, _ urlString:String) {
        /*
        if method == .request {
            CLSLog(urlString)
        }
        else{
            CLSLog("ScsNetwork Response 응답완료")
        }*/
    }
}
extension ScsNetwork{
    static let RESPONSE_FORMET = "json"
    static let VERSION = "1.0"
    static let TARGET = "MYTV"
    static let DEVICETYPE = ApiPrefix.os
    static func getUserAgentParameter() -> String{
        return SystemEnvironment.model + ";"
            + ApiPrefix.os + "/" + SystemEnvironment.systemVersion + ";"
            + ApiPrefix.service + "/" + SystemEnvironment.bundleVersion
    }
    static func getPlainText(stbId:String,macAdress:String, epsdRsluId:String?) -> String{
        return stbId + "^" + macAdress + "^" + (epsdRsluId ?? "")
    }
    static func getPlainText(stbId:String, epsdRsluId:String?) -> String{
        return stbId + "^" + (epsdRsluId ?? "")
    }
    
    static func getReqData(date:Date) -> String{
        return date.toDateFormatter(dateFormat: "yyyy-MM-dd_HH:mm:ss", local: "en_US_POSIX")
    }
    
}

class Scs: Rest{
    
    /**
     * 상품정보 조회(Btv Plus) (IF-SCS-PRODUCT-UI512-007)
     * @param epsdRsluId 에피소드 해상도 ID
     */
    func getPlay(
        epsdRsluId:String?, isPersistent:Bool = true,
        completion: @escaping (Play) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let date = Date()
        var params = [String:Any]()
        params["if"] = "IF-SCS-PRODUCT-021"
        params["ver"] = ScsNetwork.VERSION
        params["devicetype"] = ScsNetwork.DEVICETYPE
        params["useragent"] = ScsNetwork.getUserAgentParameter()
        params["req_date"] = ScsNetwork.getReqData(date:date)
        params["target_system"] = ScsNetwork.TARGET
        params["epsd_rslu_id"] = epsdRsluId
        params["m_drm"] = "fairplay"
        params["method"] = "post"
        params["swVersion"] = SystemEnvironment.bundleVersion
        params["drm_persistent"] = isPersistent ? "Y" : "N"
        params["downloadtype"] =  "normal"
            
        fetch(route: ScsPlay(body: params), completion: completion, error:error)

    }
    
    
    
}

struct ScsPlay:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/scs/mytv/play"
    var query: [String : String]? = nil
    var body: [String : Any]? = nil
    var overrideHeaders: [String : String]? = nil
}



