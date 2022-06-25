//
//  asset.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/15.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct Asset {}
extension Asset {
    public static let appIcon = "AppIcon"
    public static let appLauncher = ""
    public static let noImg16_9 = "thumbnail_default_s"
    public static let test = "test"
}
extension Asset{
    private static let isPad =  AppUtil.isPad()
    struct brand {
        public static let logoLauncher =  ""
        public static let logoSplash =  ""
        public static let characterSplash =  ""
        public static let logoWhite =  ""
        public static let logo = "ic_MYTV"
        
    }
   
    struct icon {
        public static let sort =  ""
        public static let new =  ""
        public static let back = "ic_back"
        public static let more = ""
        public static let close = "ic_close"
        public static let setting = "ic_setting"
        public static let list = "ic_list"
        public static let info = "ic_info"
        public static let auto = "ic_auto_s"
        public static let dropDown = ""
    }
    
    struct player {
        public static let resume = "ic_player_play"
        public static let pause = "ic_player_pause"
        public static let volumeOn = "ic_volume_up"
        public static let volumeOff = "ic_volume_off"
        public static let seekForward = "ic_player_skip_forward"
        public static let seekBackward = "ic_player_skip_back"
        public static let bright = "ic_bright_up"
        public static let lock = "ic_lock_off"
        public static let lockOn = "ic_lock_on"
        public static let rate = "ic_speed"
        public static let cc = "ic_cc"
    }
    
    struct download {
        public static let like = "ic_like_def"
        public static let download = "ic_download_def"
        public static let downloadOn = "ic_download_done"
        public static let loading = ["ic_download_1","ic_download_2","ic_download_3","ic_download_def"]
    }
    
   
    struct shape {
        public static let radioBtnOn = ""
        public static let radioBtnOff = ""
        public static let checkBoxOn = ""
        public static let checkBoxDisable = ""
        public static let checkBoxOn2 = ""
        public static let checkBoxOff = ""
        public static let checkBoxOffWhite = ""
        public static let spinner = ""
        public static let reflash = ""
    }
    
    struct image {
        public static let myEmpty = ""
    }
    struct character {
        public static let alert = "img_popup_character_1"
        public static let toast1 = "toast_character_1"
        public static let toast2 = "toast_character_2"
        public static let toast3 = "toast_character_3"
        
        public static let pose1 = "img_character_pose_1"
        public static let pose2 = "img_character_pose_2"
        public static let pose3 = "img_character_pose_3"
        public static let pose4 = "img_character_pose_4"
    }
    struct age {
        
        static func getIcon(age:String?) -> String {
            switch age {
            case "7": return "ic_synop_age_7"
            case "12": return "ic_synop_age_12"
            case "15": return "ic_synop_age_15"
            case "19": return "ic_synop_age_19"
            default: return "ic_synop_age_all"
            }
        }
        
        static func getRestrictIcon(age:String?) -> String {
            switch age {
            case "7": return "img_age_restrict_7"
            case "12": return "img_age_restrict_12"
            case "15": return "img_age_restrict_15"
            case "19": return "img_age_restrict_19"
            default: return ""
            }
        }
    }
    
    struct ani {
        /*
        static let brightnessList = [
            Asset.player.brightnessLv0,
            Asset.player.brightnessLv1,
            Asset.player.brightnessLv2,
            Asset.player.brightnessLv3,
            Asset.player.brightnessLv4,
            Asset.player.brightnessLv5
        ]
        
        static let volumeList = [
            Asset.player.volumeLv0,
            Asset.player.volumeLv1,
            Asset.player.volumeLv2,
            Asset.player.volumeLv3
        ]
        
        */
        //static let mic:[String] = (1...27).map{ "imgSearchMic" + $0.description.toFixLength(2) }
        static let loading = "icPlayerLoadingSeq01"
        static let loadingList = ["",""]
    }
    
}
