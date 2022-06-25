//
//  GnbBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation

struct GnbBlock : Codable {
    private(set) var total_count:Int? = 0 // 전체 개수
    private(set) var gnbs:Array<GnbItem>? = nil // GNB 목록
}

struct GnbItem : Codable {
    private(set) var dist_fr_dt:String? = nil // 메뉴배포시작일
    private(set) var dist_to_dt:String? = nil // 메뉴배포종료일
    private(set) var menu_nm:String? = nil    // 메뉴명
    private(set) var lim_lvl_yn:String? = nil // 성인메뉴여부 (제한등급여부)
    private(set) var menu_id:String? = nil    // 메뉴 ID
    private(set) var gnb_typ_cd:String? = nil // GNB 유형 코드(KIDS, PPM 등)
    private(set) var btm_menu_tree_exps_yn:String? = nil  // 하위 메뉴 tree 노출 여부
    private(set) var blocks:Array<BlockItem>? = nil // 블록배열
    init(json: [String:Any]) throws {}
}

struct BlockItem  : Codable {
    private(set) var menu_id:String? = nil    // 메뉴 ID(콘텐츠 블럭을 가진 메뉴ID)
    private(set) var menu_nm:String? = nil    // 메뉴명
    private(set) var cw_call_id_val:String? = nil // CW Call ID
    private(set) var menu_exps_prop_cd:String? = nil  // "메뉴 노출 속성코드 509: UI5.2-KIDS하위메뉴2단노출 510: UI5.2-KIDS하위메뉴1단노출 511: UI5.2-구분메뉴"
    private(set) var scn_mthd_cd:String? = nil    // 상영 방식 코드
    private(set) var lim_lvl_yn:String? = nil // 성인메뉴여부 (제한등급여부)
    private(set) var blk_typ_cd:String? = nil // 블럭유형코드
    private(set) var menu_nm_exps_yn:String? = nil    // 메뉴명 노출 여부
    private(set) var exps_mthd_cd:String? = nil   // 노출방식코드
    private(set) var pst_exps_typ_cd:String? = nil    // "포스터 노출 유형 10 가로 20 세로 30 가로 썸네일(MobileBTV) 40 세로 BIG(MobileBTV)"
    private(set) var gnb_typ_cd:String? = nil // GNB 유형 코드(KIDS, PPM 등)
    private(set) var dist_fr_dt:String? = nil // 메뉴배포시작일
    private(set) var dist_to_dt:String? = nil // 메뉴배포종료일
    
    private(set) var page_path:String? = nil  // 메뉴경로(STB LOG용)
    private(set) var btm_menu_tree_exps_yn:String? = nil  // 하위 메뉴 tree 노출 여부
    private(set) var btm_bnr_blk_exps_cd:String? = nil    
    private(set) var conts_contin_play_yn:String? = nil
 
    init(json: [String:Any]) throws {}
}
