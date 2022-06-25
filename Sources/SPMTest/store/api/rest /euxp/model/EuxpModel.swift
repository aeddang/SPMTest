//
//  EuxpModel.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/09.
//

import Foundation

struct ContentItem : Codable {
    private(set) var sris_id:String? = nil // 시리즈 ID
    private(set) var sort_seq:Int? = nil // 정렬순서
    private(set) var brcast_tseq_nm:String? = nil // 방송회차
    private(set) var title:String? = nil // 제목
    private(set) var epsd_id:String? = nil // 에피소드 ID
    private(set) var epsd_rslu_id:String? = nil 
    private(set) var synon_typ_cd:String? = nil // 진입할 시놉시스 유형(타이틀01/시즌02/콘텐츠팩03/관련상품팩04/전시용콘텐츠팩05)
    private(set) var wat_lvl_cd:String? = nil // 시청등급코드
    private(set) var adlt_lvl_cd:String? = nil // 성인등급코드
    private(set) var badge_typ_nm:String? = nil // 뱃지 유형명
    private(set) var first_epsd_id:String? = nil // 1회차 에피소드 ID
    private(set) var bas_badge_img_path:String? = nil // 기본 뱃지 이미지 경로(상단 노출 뱃지)
    private(set) var user_badge_img_path:String? = nil // 사용자 등록 뱃지 이미지(하단 노출 이벤트 이미지)
    private(set) var user_badge_wdt_img_path:String? = nil // 사용자 등록 뱃지 가로 이미지(하단 노출 이벤트 이미지)
    private(set) var icon_exps_fr_dt:String? = nil // 뱃지(이벤트) 노출 시작 일자
    private(set) var icon_exps_to_dt:String? = nil // 뱃지(이벤트) 노출 종료 일자
    private(set) var poster_filename_h:String? = nil // 가로 포스터
    private(set) var poster_filename_v:String? = nil // 세로 포스터
    private(set) var thumbnail_filename_h:String? = nil //  포스터
    private(set) var meta_typ_cd:String? = nil // 메타 유형 코드
    private(set) var kids_yn:String? = nil // 키즈 시놉 여부
    private(set) var svc_fr_dt:String? = nil // 서비스 시작일
    private(set) var svc_to_dt:String? = nil // 서비스 종료일
    private(set) var sris_dist_fir_svc_dt:String? = nil // 시리즈 동기화승인일
    private(set) var epsd_dist_fir_svc_dt:String? = nil // 에피소드 동기화승인일
    private(set) var cacbro_yn:String? = nil // 결방여부
    private(set) var rslu_typ_cd:String? = nil // 상품해상도
    //private(set) var sale_prc:DynamicValue? = nil // 판매가격
    //private(set) var sale_prc_vat:DynamicValue? = nil // 판매가격 부가세 포함
    //private(set) var prd_prc:DynamicValue? = nil // 상품가격(원가격)
    //private(set) var prd_prc_vat:DynamicValue? = nil // 상품가격(원가격) 부가세 포함
    private(set) var prd_prc_id:String? = nil // 상품가격ID(현재콘텐츠가 속한 월정액 PID[우선순위 정해서 하나만])
    private(set) var ppm_grid_icon_img_path:String? = nil
    private(set) var sris_cmpt_yn:String? = nil // 시리즈 완료 여부
    private(set) var ppv_uabl_yn:String? = nil // ppv불가여부
    private(set) var meta_sub_typ_cd:String? = nil // 메타 서브 유형 코드 (00501: 일반, 00502 캐릭터 AI) (null일경우 일반으로 처리)
    private(set) var rsv_orgnz_yn:String? = nil //예약판매Y/N ( Y:예약판매상품, Y 가 아닐경우 : 예약판매상품 아님) 시즌일경우 회차중 예약판매 컨텐츠가 포함되어 있을 경우 Y
    private(set) var tseq_orgnz_yn:String? = nil //회차 편성 여부
    private(set) var play_tms_hms: String? = nil   //클립 재생 시간 (시분초) 
    private(set) var i_img_cd:String? = nil // 벳지 이미지var
    private(set) var svc_typ_cd: String? = nil // 서비스 유형 코드
    private(set) var episode_title: String? = nil // 회차 타이틀
    private(set) var keywrd_val: String? = nil //  클립 본편 타이틀keywrd_val
    private(set) var epsd_lag_capt_typ_cd: String? = nil // 에피소드 언어 자막 유형 코드
    private(set) var sris_lag_capt_typ_cd: String? = nil // 시리즈 언어 자막 유형 코드
    private(set) var track_id: String? = nil
    private(set) var recommend_comment: String? = nil
    init(json: [String:Any]) throws {}
}

struct ProgramItem : Codable {
    private(set) var start_time:String? = nil
    private(set) var end_time:String? = nil
    private(set) var title:String? = nil
    private(set) var type_code:String? = nil
    private(set) var type_name:String? = nil
    private(set) var episode_seq:String? = nil
    private(set) var rating:String? = nil
    private(set) var images:Array<ImageTypeItem>? = nil
    private(set) var dolby:String? = nil
    
    private(set) var subtitles:String? = nil
    private(set) var commentary:String? = nil
    private(set) var series_id:String? = nil
    private(set) var episode_id:String? = nil
    private(set) var episode_rslu_id:String? = nil
    private(set) var vod_dp_yn:String? = nil
    //private(set) var synopsis:String? = nil
    //private(set) var people:Array<String>? = nil
    init(json: [String:Any]) throws {}
}


struct ImagePathItem : Codable {
    private(set) var img_path:String? = nil
    init(json: [String:Any]) throws {}
}

struct ImageTypeItem : Codable {
    private(set) var type:String? = nil
    private(set) var url:String? = nil
    init(json: [String:Any]) throws {}
}
