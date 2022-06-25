//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    private static let isPad =  AppUtil.isPad()
    func loaalized() -> String {
        return NSLocalizedString(self, comment: "")
    }

    struct week {
        static func getDayString(day:Int) -> String{
            switch day {
            case 2 : return "mon"
            case 3 : return "tue"
            case 4 : return "wed"
            case 5 : return "thu"
            case 6 : return "fri"
            case 7 : return "sat"
            case 1 : return "sun"
            default : return ""
            }
        }
    }

    struct player {
        public static let moveSec = "playerMoveSec"
       
        public static let next = "playerNext"
        public static let replay = "playerReplay"
        public static let disable =  "playerDisable"
        public static let recordDisable =  "playerRecordDisable"
        public static let recordDisableText =  "playerRecordDisableText"
        
        public static let resume =  "재생"
        public static let pause =  "정지"
        public static let fullscreen =  "playerFullscreen"
        public static let fullscreenExit =  "playerFullscreenExit"
       
        public static let muteOn =  "playerMuteOn"
        public static let muteOff =  "playerMuteOff"
        public static let qulity =  "playerQulity"
        
        
        
        public static let playTime = "playerPlayTime"
        public static let endTime = "playerEndTime"
        
        public static let back = "back"
        public static let forword = "forword"
        public static let tabBack = "playerTabback"
        public static let tabForword = "playerTabforword"
        
        
        public static let pipOn = "playerPipOn"
        public static let pipOff = "playerPipOff"
        public static let function = "playerFunction"
        public static let lockOn = "playerLockOn"
        public static let lockOff = "playerLockOff"
        
        public static let caption = "자막"
        public static let captionSize = "자막 크기"
        public static let captionOff = "끄기"
    
        public static let captionSizeLv1 = "최소"
        public static let captionSizeLv2 = "증간"
        public static let captionSizeLv3 = "최대"
        
        public static let rate =  "재생 속도"
        public static let rateDefault =  "기본"
    }
}
