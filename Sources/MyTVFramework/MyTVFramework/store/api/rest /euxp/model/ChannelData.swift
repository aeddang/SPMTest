//
//  ChannelData.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/16.
//

import Foundation
struct ChannelData : Codable {
    private(set) var request_time:String? = nil
    private(set) var total_count:Int? = 0 // 전체 개수
    private(set) var chnl_grp:Array<ChannelGroup>? = nil // GNB 목록
}
struct ChannelGroup : Codable {
    private(set) var chnl_grp_id:String? = nil
    private(set) var chnl_grp_nm:String? = nil
    private(set) var sort_seq:Int? = nil
    private(set) var channels:Array<ChannelItem>? = nil
    init(json: [String:Any]) throws {}
}
struct ChannelItem : Codable {
    private(set) var id:String? = nil
    private(set) var type:String? = nil
    private(set) var no:String? = nil
    private(set) var name:String? = nil
    private(set) var genre_code:String? = nil
    private(set) var genre_name:String? = nil
    private(set) var category_code:String? = nil
    private(set) var rank:String? = nil
    private(set) var pay_yn:String? = nil
    private(set) var preview_time:Double? = nil
    private(set) var images:Array<ImageTypeItem>? = nil
    private(set) var poc_type:String? = nil
    private(set) var vod_control_yn:String? = nil
    private(set) var programs:Array<ProgramItem>? = nil
    
    //private(set) var product_ids:Array<String>? = nil
    init(json: [String:Any]) throws {}
}
