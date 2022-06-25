//
//  Boot.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/07.
//

import Foundation
struct Boot : Codable {
    private(set) var code:String? = nil
    private(set) var message:String? = nil
    private(set) var data:BootData? = nil
}
struct BootData : Codable {
    private(set) var release_date:String? = nil
    private(set) var mode:String? = nil
    private(set) var settings:BootSettings? = nil
    private(set) var server_info:[HostSetting]? = nil
}
struct BootSettings : Codable {
    private(set) var epg_cache_time:Float = 60
}
struct HostSetting : Codable {
    private(set) var id:String? = nil
    private(set) var address:String? = nil
    private(set) var port:String? = nil
}
