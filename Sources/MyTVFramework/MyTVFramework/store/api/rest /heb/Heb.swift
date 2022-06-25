//
//  Euxp.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/09.
//

import Foundation
struct HebNetwork : Network{
    var enviroment: NetworkEnvironment = ServerConst.HEB_STG//ApiPath.getRestApiPath(.HEB)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
    func sendCLSLog(_ method:APIMethod, _ urlString:String) {
        //CLSLog(urlString)
    }
}

extension HebNetwork{
    static let SERIAL_NO = "BA00000142000352"
    static let VERSION = "1.0.0"

}

class Heb: Rest{
    /**
     * HEB-BOOT-001
     */
    func getBoot(
        completion: @escaping (Boot) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
            params["v"] = HebNetwork.VERSION
            params["sn"] = HebNetwork.SERIAL_NO
        
        fetch(route: HebBoot(query: params), completion: completion, error:error)
    }
    
    /**
     * HEB-FAST-001
     */
    func getLiveStreaming( csvId:String?,
        completion: @escaping (LiveStream) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
            params["if_id"] = "IF-HEB-FAST-001"
            params["stb_id"] = SystemEnvironment.deviceId
            
            params["poc_type"] = "P002"
            params["episode_id"] = ""
            params["channel_id"] = csvId
        
        fetch(route: HebFast(query: params), completion: completion, error:error)
    }
}

struct HebBoot:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/heb/v1/boot"
   var query: [String : String]? = nil
}

struct HebFast:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/heb/v1/fastchannel/fast"
   var query: [String : String]? = nil
}










