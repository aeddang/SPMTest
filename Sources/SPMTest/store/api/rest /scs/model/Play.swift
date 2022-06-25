//
//  Play.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/27.
//

import Foundation
struct Play : Decodable {
    private(set) var IF: String? = nil   // 인터페이스 아이디
    private(set) var ver: String? = nil  // 인터페이스 버전
    private(set) var ui_name: String? = nil   // UI 구분자
    private(set) var svc_name: String? = nil  // 서비스 명
    private(set) var result: String? = nil   // 성공여부 0000:성공, xxxx:오류
    private(set) var reason: String? = nil  // 메시지, 오류코드 명세 참조
    private(set) var epsd_id: String? = nil  // 에피소드 ID
    private(set) var sris_id: String? = nil // 시리즈 ID
    private(set) var STB_ID: String? = nil  // STB ID
    private(set) var PREPAID: String? = nil  // 이전 구매 여부 0:미지불, 1ㅣ지불 * 해당 값이 1이면 구매 권한이 있다(무료일때는 0으로 내려온다.)
    private(set) var PURCHASE_TIME: String? = nil  // 구매 시간 Prepaid 가 지불인경우
    private(set) var CHARGE_PERIOD: String? = nil  // LGS CDR_LOG(4번) 이벤트 기준 시점 (5)
    private(set) var CUR_TIME: String? = nil  // H/E DB 서버 시간
    private(set) var POPUP: String? = nil  // 구매창 및 시청기간 만료 창 팝업 여부 -1:error 0:이미 구매된 상품 1:유료 구매창 팝업 2:시청 만료 구매창 3:추가 광고 시청 할인 구매창(금액)
                                                                //4:추가 광고 무료 시청 5:맛보기 상품 6:상품 변경 유도 7:추가 광고 할인 && 시청 기간 만료 8:무료 9:예약 10:선물 받은 상품 * 재생 권한 은 해당 POPUP 로 판단하면 된다.
    private(set) var CTS_INFO:PlayInfo? = nil  // 컨텐츠 정보
    private(set) var PROD_INFO:[ProductInfo]? = nil  // 상품 정보
    private(set) var verf_res_data: String? = nil  // 암호화 된 검증 data
}

struct ProductInfoItem : Decodable {
    private(set) var PID: String? = nil   // 상품 ID * 해당 값을 LGS에 넘겨준다.
    private(set) var PNAME: String? = nil   // 상품명
    private(set) var ID_MCHDSE: String? = nil   // vod+상품 시 ID 값
    private(set) var PROD_DESC: String? = nil   // 상품 설명
    private(set) var PRICE: String? = nil   // 상품 가격
    private(set) var V_PRICE: String? = nil  // 부가세 포함 상품가격
    private(set) var DUETIME: String? = nil  // 상품 시청 가능 시간 (48)
    private(set) var DUETIME_PERIOD: String? = nil   // 상품 시청 가능 기간 (2일)
    private(set) var DUETIME_STR: String? = nil   // 상품 시청 가능 기간 (2017년 02월 04일 01시 까지)
    private(set) var CLTYN: String? = nil   // 소장용 여부 Y:소장용, N or null:비소장용
    private(set) var IFTYN: String? = nil   // 365일 여부 정보
    private(set) var PPM_PROD_TYPE: String? = nil   // 월정액 상품 타입 0:일반 1:프리미어 월정액 2:방송사 월정액 3:지상파 월정액
    private(set) var PPM_PROD_IMG_PATH: String? = nil   // 월정액 상품 이미지 패스정보
    private(set) var IPTV_SET_PROD_FLAG: String? = nil   // VOD 및 VOD+IPTV채널 상품 구분 0 or null:VOD 상품 1:IPTV 채널 + VOD 세트상품
    private(set) var IPTV_SET_PROD_TYPE: String? = nil   // IPTV채널+VOD세트상품 타입 10:VOD 단독구매 불가 20:단편구매가능 30:VOD 월정액만 구매 가능 40:단편,월정액 구매 가능
    private(set) var IPTV_CH_TITLE: String? = nil   // 대표 채널명
    private(set) var IPTV_ID_SVC: String? = nil   // 대표 채널 ID 서비스 정보
    private(set) var IPTV_CH_NO: String? = nil   // 대표 채널 번호
}

struct ProductInfo : Decodable {
    private(set) var PTYPE: String? = nil   // 상품 타입 10 : PPV(단일상품) 20 : PPS (시리즈상품) 30 : PPM(월정액 상품) 41 : PPP (패키지)
    private(set) var PTYPE_STR: String? = nil   // 상품타입 명칭
    private(set) var TARGET_PAYMENT: String? = nil   // 신규 결제수단 10:핸드폰, 90:후불, 2:TV페이(신용카드)
    private(set) var PROD_DTL:[ProductInfoItem]? = nil  // 상품 상세 정보
}




struct PlayInfo : Decodable {
    private(set) var CID: String? = nil     // Content ID
    private(set) var RTSP_CNT_URL: String? = nil    // 콘텐츠 경로(RTSP)
    private(set) var HLS_CNT_URL: String? = nil     // "콘텐츠 경로(HLS) 프로토콜을 HLS로 요청하지 않았을경우, 콘텐츠의 HLS 재생 URL 없을경우, 요청 시스템이 BTVPLUS인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_SD: String? = nil   // "모바일 콘텐츠 경로(SD) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_HD: String? = nil  // "모바일 콘텐츠 경로(HD) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_FHD: String? = nil   // "모바일 콘텐츠 경로(FHD) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var CNT_URL_NS_AUTO: String? = nil     // "모바일 콘텐츠 경로(AUTO) 요청 시스템이 BTV인 경우 값이 내려가지 않는다."
    private(set) var HLS_LICENSE_URL: String? = nil     // HLS DRM 라이선스 URL
    private(set) var FGQUALITY: String? = nil   // "화질 구분 10:SD, 20:HD, 30:UHD, 35:UHD+HDR"
    private(set) var REQ_DRM: String? = nil     // DRM 종류
    private(set) var REQ_MV: String? = nil  // "매크로비전 적용 여부 0:미적용, 1:적용"
    private(set) var YN_WATER_MARK: String? = nil   // 워터마크 유무
    private(set) var EXTENSION: String? = nil   // "워터마크 관련 정보 재생 %, 반복간격, 반복횟수"
    private(set) var WM_MODE: String? = nil     // "워터마크 모드 0:invisible 1:visible 2:invisible + visible"
    private(set) var NSCREEN: String? = nil    // "N-Screen 상품여부 (Y:N-Screen 상품)"
    private(set) var YN_BIND: String? = nil     // 합본 여부
    private(set) var VOC_LAG: String? = nil     // "음성언어 (01 : 우리말, 02: 한글자막, 03: 영어자막, 04: 영어더빙, 05: 중국어더빙, 13: 기타, 15: 외국어자막서비스)"
    private(set) var PREVIEW_TIME: String? = nil    // 미리보기 시간(초)
    private(set) var QUALITY_MEDIA: String? = nil   // 미디어 품질
    private(set) var SAMPLING: String? = nil
    
    private(set) var HLS_SD_LICENSE_URL: String? = nil    // drm
    private(set) var HLS_HD_LICENSE_URL: String? = nil    // drm
    private(set) var HLS_FHD_LICENSE_URL: String? = nil    // drm
    private(set) var HLS_AUTO_LICENSE_URL: String? = nil    // drm

}
