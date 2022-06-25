//
//  Euxp.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/09.
//

import Foundation
struct EuxpNetwork : Network{
    var enviroment: NetworkEnvironment = ServerConst.EUXP_STG//ApiPath.getRestApiPath(.EUXP)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
    func sendCLSLog(_ method:APIMethod, _ urlString:String) {
        //CLSLog(urlString)
    }
}

extension EuxpNetwork{
    static let RESPONSE_FORMET = "json"
    static let MENU_STB_SVC_ID = "BTVAPOLLOV533"// + SystemEnvironment.bundleVersionKey
   
    static let APP_TYPE_CD = "APOLLOMYTV"
    static let VERSION = "0"
    static let PAGE_COUNT = 30
    static let adultCodes:[String?] = ["01", "03"]
    
  
    
    enum SortType: String {
        //case none = "10" // 기본
        case popularity = "10" // 인기
        case latest = "20" // 최신순
        case title = "30" // 타이틀
        case price = "40" // 가격

    }
    
    enum SearchType: String {
        case sris = "1" // 시리즈
        case prd = "2" // 단품
    }
    
   
    enum SrisTypCd: String {
        case none = "00" // error
        case season = "01"
        case title = "02"
        case contentsPack = "04"
    }
    

    enum AsisPrdType: String {
        case ppv, pps, ppm, ppp,none
        static func getType(_ value:String?)->AsisPrdType{
            switch value {
                case "10", "40": return .ppv
                case "20": return .pps
                case "30": return .ppm
                case "41": return .ppp
                default : return .none
            }
        }
        
        var logCategory: String {
            switch self {
            case .ppv: return "PPV"
            case .pps: return "PPS"
            case .ppm: return "PPM"
            case .ppp: return "PPP"
            default: return ""
            }
        }
        
    }
    
    enum CaptionType: String {
        case global = "15"
        case kor = "01"
        case dubbing = "02"
    }
    
    

}
struct SynopsisData{
    var srisId:String? = nil
    var searchType:EuxpNetwork.SearchType = .prd
    var epsdId:String? = nil
    var epsdRsluId:String? = nil
}

class Euxp: Rest{
    /**
     * GNB/블록 전체메뉴 (IF-EUXP-030)
     */
    func getGnbBlock(
        completion: @escaping (GnbBlock) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["stb_id"] = SystemEnvironment.deviceId
        //params["inspect_yn"] = SystemEnvironment.isEvaluation ? "Y" : "N"
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["app_typ_cd"] = EuxpNetwork.APP_TYPE_CD
        params["IF"] = "IF-EUXP-030"
        
        fetch(route: EuxpGnbBlock(query: params), completion: completion, error:error)
    }
    /**
     * EUXP-032(채널Z블록)
     */
    func getChannelBlock( menuId:String?,
        completion: @escaping (ChannelData) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = SystemEnvironment.deviceId
        var params = [String:String]()
        params["stb_id"] = stbId
        //params["inspect_yn"] = SystemEnvironment.isEvaluation ? "Y" : "N"
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["app_typ_cd"] = EuxpNetwork.APP_TYPE_CD
        params["IF"] = "IF-EUXP-032"
            
        params["inspect_yn"] = "N"
        params["poc_typ_cd"] = "50"
        params["bnr_typ_cd"] = "ALL"
        params["menu_id"] = menuId ?? ""
           
        fetch(route: EuxpChannelBlock(query: params), completion: completion, error:error)
    }
    /**
     * EUXP-009(RACE 연동그리드)
     */
    func getRaceBlock(
        menuId:String?, cwCallId:String?,
        completion: @escaping (RaceData) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = SystemEnvironment.deviceId
        var params = [String:String]()
        params["stb_id"] = stbId
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["app_typ_cd"] = EuxpNetwork.APP_TYPE_CD
        params["IF"] = "IF-EUXP-009"
        //params["inspect_yn"] = SystemEnvironment.isEvaluation ? "Y" : "N"
        params["menu_id"] = menuId ?? ""
        params["sort_typ_cd"] = ""
        params["rslu_typ_cd"] = "20"
        params["inspect_yn"] = "Y"
        params["cw_call_id"] = cwCallId ?? ""
        params["type"] = "all"
        //params["psnl_prof_Id"] = NpsNetwork.pairingId
        fetch(route: EuxpRaceBlock(query: params), completion: completion, error:error)
    }
    /**
     * EUXP-033(편성표)
     */
    func getEpg( csvId:String?, now:Date? = nil, addTime:Double = 24,
        completion: @escaping (EpgData) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = SystemEnvironment.deviceId
        var params = [String:String]()
        params["stb_id"] = stbId
        //params["inspect_yn"] = SystemEnvironment.isEvaluation ? "Y" : "N"
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["app_typ_cd"] = EuxpNetwork.APP_TYPE_CD
        params["IF"] = "IF-EUXP-033"
        params["inspect_yn"] = "N"
        params["poc_type"] = "P002"
        params["channels"] = csvId ?? "all"
        var start = now
        if now == nil {
            let nowStr = AppUtil.networkTimeDate().toDateFormatter(dateFormat: "yyyyMMdd") + "000000"
            start = nowStr.toDate(dateFormat:"yyyyMMddHHmmss")
        }
        let to = start?.addingTimeInterval(addTime * 60 * 60)
        params["event_fr_dt"] = start?.toDateFormatter(dateFormat: "yyyyMMddHHmmss")
        params["event_to_dt"] = to?.toDateFormatter(dateFormat: "yyyyMMddHHmmss")
        fetch(route:EuxpEpg(query: params), completion: completion, error:error)
    }
    
    func getSynopsis(
        data:SynopsisData, 
        completion: @escaping (Synopsis) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-010"
        params["sris_id"] = data.srisId ?? ""
        params["epsd_id"] = data.epsdId ?? ""
        params["search_type"] = EuxpNetwork.SearchType.prd.rawValue
        params["epsd_rslu_id"] = data.epsdRsluId ?? ""
        params["yn_recent"] =  "N"
        params["app_typ_cd"] = EuxpNetwork.APP_TYPE_CD
        
        fetch(route: EuxpSynopsis(query: params), completion: completion, error:error)
        
    }
}

struct EuxpGnbBlock:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/menu/gnbBlock/mobilebtv"
   var query: [String : String]? = nil
}
struct EuxpChannelBlock:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/fastchannel/fastchgrid"
   var query: [String : String]? = nil
}

struct EuxpRaceBlock:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/inter/cwgrid"
   var query: [String : String]? = nil
}
struct EuxpEpg:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/fastchannel/epg"
   var query: [String : String]? = nil
}

struct EuxpSynopsis:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/euxp/v5/contents/synopsis"
    var query: [String : String]? = nil
    var overrideHeaders: [String : String]? = nil
}










