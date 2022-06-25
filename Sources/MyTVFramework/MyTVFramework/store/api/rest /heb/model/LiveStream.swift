//
//  LiveStream.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/22.
//

import Foundation

struct LiveStream : Codable {
    private(set) var code:String? = nil
    private(set) var message:String? = nil
    private(set) var data:LiveStreamData? = nil
}
struct LiveStreamData : Codable {
    private(set) var channels:Array<LiveStreamChannel>? = nil
}

struct LiveStreamChannel : Codable {
    private(set) var id:String? = nil
    private(set) var type:String? = nil
    private(set) var no:String? = nil
    private(set) var name:String? = nil
    private(set) var auth_type:String? = nil
    //private(set) var preview_time:Double? = nil
    private(set) var images:Array<ImageTypeItem>? = nil
    private(set) var skb_channel_id:String? = nil
    private(set) var pay_channel_yn:String? = nil
    private(set) var vod_control_yn:String? = nil
    private(set) var stream_info:LiveStreamItem? = nil
}

struct LiveStreamItem : Codable {
    private(set) var auth_type:String? = nil
    private(set) var limit_time:String? = nil
    private(set) var stream_urls:Array<StreamInfo>? = nil
}

struct StreamInfo : Codable {
    private(set) var quality: String? = nil
    private(set) var bitrate: String? = nil
    private(set) var url: String? = nil
} 
