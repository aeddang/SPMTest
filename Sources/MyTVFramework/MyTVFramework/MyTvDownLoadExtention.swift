//
//  MyTvTest.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/23.
//

import Foundation
import SwiftUI
import BackgroundTasks



public class MyTvBackgroundDownLoadTask:PageProtocol {
    @State var licenseKey:Data? = nil
    @ObservedObject var downLoader: DownLoader = DownLoader()
    public init() {}
    public func setup(){
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.skb.apollo.MyTVFramework.DownloadTask", using: nil) { task in
             self.handleMovieDownload(task: task as! BGProcessingTask)
        }
    }
    
    private func handleMovieDownload(task: BGProcessingTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let blockOperation = BlockOperation {
            self.downLoader.start(path: Self.filePath)
        }
        queue.addOperation(blockOperation)
    }
}

extension MyTvBackgroundDownLoadTask {
    static let filePath:String = "https://devmobilemig.hanafostv.com/vod/99999999_209912312359_99999999990/pa2My2mO0gQ0Xdu90PjKSYUMw5tVAOB%2BjSPHYA6ToNsch7tj8u12AdYWJtjUKCCxuHgCpxVccjMGnx2zfUpquJ%2FgJ0j1biNAvT3zLshRc5rgHe1LQWKTOD5ehF6d2vk%2FKWxcWl%2BKHFm429%2BQPJtZH3QMxN8t6bcgiblKiqF7rrzzN5SmqRapSAMsz5sU10PKFzIPjH7jIJfMEUCYd%2FPhXkrVnJH3IYWWFtGgZ8LQtHHgZ6octQf%2F8xD8j4unUq8rG%2F6lkurcT35u0sm8D5%2BFL7vpl1cPzeZ3WJDNEEsgQQ7rk%2Ba9WW12flJXcnk2MaKrLISH8ECgs7d27ZdpTapEo67mje5bd52e%2B%2FAA5veDVoTC9S2yJi74%2Fl5DPdvx4%2B9oZUmJVle7tm4qjjnkxcuODguAIcFUVKFZmO%2BHrOaruZUaW%2BD3l4ucionyeehLoJt8lPOltNZzdtQTDW7Pl5Pg8EJDobexVnku691XEUbGITfJAI%2BXjwbuIGUc%2BY5PvitXzyCyJBi%2BgodPViJumGXIZEtaD9qtAj5cWNPw3k3enpawmspC2SzW%2BbPRN2IcIzwbRrgJbHmLuEXFMqkq6tr5%2F0dqe3vBATu0UpLFVQq%2Bg50rV2AUfVIq2IqgLp1GC4Z9ouvqKpkRUp9hsTi65hlTwxIE0v29eX%2BNvyk8LaEvj1qiGP1DsIz55t73HoqBJ4FC6eXjaX5h3t9%2BbYTQGn4spLSa4aqkRWf8NtQ%2BYH770z1p5fxopJ9jCPTCETgaXpQr7J5KK3pZSF3kyrDmtLExXkGr7L3CZu8J80sOnhEmLO2QYZYlX%2BcyfnYYlen5Zu4DH6js%2B9PP%2B9UW4uQlS2qvYfCDYB8pvSLBWOuBcViyp6ESn2hufKvySiIZsv7vBLnEnduyu4PgVAqhizZ8JfAOyiXpXceyrZWlacylOsyqVMB6Qhi6shxygEhfU981RbUR/CD1010003913_20210706210703.m3u8"
    static let licensePath:String = "https://ecdnlicense-poc.hanafostv.com/vod/99999999_209912312359_99999999990/pa2My2mO0gQCXlO7TZQbSwM59AvR8BNAYDE2uW7q4GFGEYG%2BlxPkrWEYXxtdYFFAF3jpIvGdD3%2Fd8qC6CDqjLep3UF9BEaP7xZN5EHqDLn6sZ39VSP6JW5waOtkoNkGmA8DHilfM%2BEZ7C%2Flj8cwBSPdJe%2BRfrLM74uW4t6oqBdDlb8aInqee%2BuOwODIDSfdac2sscJhaxU%2BBsPD9Jiag%2FZ8bT6RHqCh3HHpT%2BcIyrUlKm1OZzbirL7rlGXKF7s9GFBI1EUHR504Q1ny%2FVUdync%2FkGHV9WMCApY5umSo5O8qAmtbKOru7UPE7I14qdVu1ZJA33sIDKLJjNrsOw5jg0mlwosQB%2Bp7aqw61aT7Efjg4V4r8jn0nGnCJx4trfITy379FQvBQwajf8WVRpAGdRhEuSWK3n%2B2s2nnchEg%2F%2BF4xAaWQXqbqamv46LRrKzzm8p%2FTwWQg3vcKjglTaZny09F%2BQlA2bOUQ8qRt8%2BKVvOJinKDuYC%2B2X8s5%2BahPNDiEcPQZ4hz1uizWblVALr%2Fx2wRFVUbazk7PIZVtkpm1NVp%2FGZareG3qIMnLl%2ByWSB5wWKlX7SQImppXmqAK6vsSA588Wj0suA%2B3tcaGCvZ9QyQ78DQ8FPpM%2BxUt0ZJDkSRfnHoVz6z%2FpRu49%2BLnt5bQ4NkWuL4iVMBMp527pWMpgRseVFRq42id6UOcmJ%2BPhZztJ0gr64NKZDIDoz%2FbjwG4KkZyyD979BsffFktZrUGDK3D5Ercdooz179kekANmdRIGvG2WRoEQ6Ld9TcRu0aGvhJ0%2BM1uKbxzDSstSh26bcpVAQRHbes%2FDnxenp50OMRhWmaHrH7TPbIRXuevJ8i1ylBuS8EaQbbKFLT3SjeIp%2BClYNj5hkyDwI38Y6lSvrEVwNFs9voyj3YzhRaOYa6EphgkI1beT1ZcWoJKwK7z20DyYedMARPM8gnlmiaVlffZjG74Pze9Fn7jCptcJMtZ%2Fsh%2FyLrdOA8G8MMPaLsrZPo%3D/CD1010003913_20210706210703.m3u8"
}


extension View {
  func onAppCameToForeground(perform action: @escaping () -> Void) -> some View {
    self.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//       action()
    }
  }

  func onAppWentToBackground(perform action: @escaping () -> Void) -> some View {
    self.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
        handleMovieDownloadSumit()
    }
  }
    
    
    func handleMovieDownloadSumit() {
        let request = BGProcessingTaskRequest(identifier: "com.skb.apollo.MyTVFramework.DownloadTask")
        //네트워크 사용여부, 에너지 소모량 옵션도 있습니다.
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule database cleaning: \(error)")
        }

    }
}
