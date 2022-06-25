//
//  PageTest.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine

/*
struct SampleVideos: Codable {
    var name: String?
    var samples: [SampleVideo]?
}
struct SampleVideo: Codable {
    var name: String?
    var contentId: String?
    var uri: String?
    var drm_scheme: String?
    var drm_license_url: String?
}*/
struct SampleVideo: Codable {
    var name: String?
    var contentsURL: String?
    var licenseURL: String?
}


class VideoListData:InfinityData{
    var title:String = "sample"
    var subTitle:String = ""
    var ckcURL:String? = nil
    var contentId:String? = nil
    var videoPath:String = ""//"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
    init(title:String) {
        self.title = title
    }
    func setData(_ data:SampleVideo) -> VideoListData {
        subTitle = data.name ?? ""
        ckcURL = data.licenseURL?.isEmpty == false ? data.licenseURL : nil
       
        videoPath = data.contentsURL ?? ""
        return self
    }
}

struct VideoListItem: PageView {
    var data:VideoListData

    var body: some View {
        VStack(spacing:Dimen.margin.thin){
            Text(data.title)
                .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.black40))
                .lineLimit(1)
            Text(data.subTitle)
                .modifier(BoldTextStyle(size: Font.size.thin))
                .lineLimit(1)
                
        }
        .padding(.all, Dimen.margin.tiny)
        .background(Color.app.blue100)
    }
}



struct TestList:View, PageProtocol{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
     
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    @State var lists:[VideoListData] = []
    var apiPath:String = ""
    let action: (_ data:VideoListData?) -> Void
    var body: some View {
        VStack(alignment: .center)
        {
            
            InfinityScrollView(
                viewModel: self.viewModel,
                axes: .vertical,
                marginVertical: 0,
                marginHorizontal: 0,
                spacing: Dimen.margin.thin,
                useTracking: false
            ){
                ForEach(self.lists) { data in
                    VideoListItem( data:data )
                    .onTapGesture {
                        self.action(data)
                    }
                }
            }
            FillButton(text:"close"){_ in
                self.action(nil)
            }
        }//VStack
        
        .modifier(PageFull())
        .onAppear{
            if !self.apiPath.isEmpty {
                self.load(apiPath: self.apiPath)
            } else {
               // self.loadAsset()
            }
        }
    
    }//body
    /*
    private func loadAsset(){
        let url = Bundle.main.url(forResource: "ios_sample", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        do {
            let sets = try decoder.decode([SampleVideo].self, from: data)
            sets.forEach{ sample in
                self.lists = sample.samples?.map{ VideoListData(title: sample.name ?? "").setData($0)} ?? []
            }
        } catch let e {
            PageLog.e("parse error " + e.localizedDescription, tag: self.tag)
        }
       
       
    }
    */
    private func load(apiPath:String){
        let net = TestNetwork(enviroment: apiPath)
        let rest = TestRest(network: net)
        rest.getList(
            completion: {res in
                self.lists =  res.map{ sample in
                  VideoListData(title: "").setData(sample)
                }
                /*
                res.forEach{ sample in
                    self.lists = sample.samples?.map{ VideoListData(title: sample.name ?? "").setData($0)} ?? []
                }*/
            },
            error: {err in
                PageLog.e("error " + apiPath, tag: self.tag)
                self.appSceneObserver.event = .toast("API 형식이 다릅니다")
            }
        )
    }

    struct TestNetwork : Network{
        var enviroment: NetworkEnvironment
        func sendCLSLog(_ method:APIMethod, _ urlString:String) {}
    }
    
    class TestRest: Rest{
        
        func getList(
            completion: @escaping ([SampleVideo]) -> Void, error: ((_ e:Error) -> Void)? = nil){
            fetch(route: TestRoute(), completion: completion, error:error)
        }
    }
    
    struct TestRoute:NetworkRoute{
        var method: HTTPMethod = .get
        var path: String = ""
    }
}



