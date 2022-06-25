//
//  EpgData.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/21.
//

import Foundation
struct EpgData : Codable {
    private(set) var epg:Array<ChannelItem>? = nil // GNB 목록
}

