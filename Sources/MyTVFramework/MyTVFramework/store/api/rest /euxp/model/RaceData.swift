//
//  RaceData.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/21.
//

import Foundation

import Foundation
struct RaceData : Codable {
    private(set) var total_count:Int? = 0 // 카운트 값과 상관없이 전체 그리드 개수
    private(set) var grid:Array<RaceItem>? = nil // 빅배너 목록
    private(set) var result:String? = nil
    init(json: [String:Any]) throws {}
}

struct RaceItem : Codable {
    private(set) var block_cnt:Double? = 0 //
    private(set) var sub_title:String? = nil //
    private(set) var cw_call_id:String? = nil // 페이지 아이디 (IF-EUXP-010 호출 시 요청 파라미터로 넘겨준다.)
    private(set) var session_id:String? = nil // 세션 아이디 (IF-EUXP-010 호출 시 요청 파라미터로 넘겨준다.)
    private(set) var sectionId:String? = nil //  섹션 아이디
    private(set) var block:Array<ContentItem>? = nil  // 메뉴 ID(콘텐츠 // jdy_todo : 009 와 024가 배너를 제외한 데이타가 동일하여 임시로 변경
    init(json: [String:Any]) throws {}
}
