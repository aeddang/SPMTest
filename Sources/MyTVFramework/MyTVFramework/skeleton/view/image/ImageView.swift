//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine




struct ImageView : View, PageProtocol {
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    let url:String?
    var contentMode:ContentMode  = .fill
    var isFull:Bool = false
    var noImg:String? = nil
    @State var image:UIImage? = nil
    @State var opacity:Double =  0.3
    
    var body: some View {
        if isFull {
            Image(uiImage: self.image ?? self.getNoImage())
                .renderingMode(.original)
                .resizable()
                .opacity( self.opacity )
                .onReceive(self.imageLoader.$event) { evt in
                    self.onImageEvent(evt: evt)
                }
                .onAppear(){
                    self.creatAutoReload()
                    self.imageLoader.cash(url: self.url)
                }
                .onDisappear(){
                    self.clearAutoReload()
                    self.imageLoader.cancel()
                }
        } else {
            Image(uiImage: self.image ?? self.getNoImage())
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: self.contentMode)
                .opacity( self.image != nil ? self.opacity : 1 )
                .onReceive(self.imageLoader.$event) { evt in
                    self.onImageEvent(evt: evt)
                }
                .onAppear(){
                    if self.image != nil {return}
                    self.creatAutoReload()
                    self.imageLoader.cash(url: self.url)
                }
                .onDisappear(){
                    self.clearAutoReload()
                    self.imageLoader.cancel()
                }
        }
        
        
    }
    
    func getNoImage() -> UIImage {
        return (self.noImg != nil)
        ? UIImage(named: SystemEnvironment.bundleId + "/" + self.noImg!) ?? UIImage.from(color: Color.transparent.clear.uiColor())
        : UIImage.from(color: Color.transparent.clear.uiColor())
    }
    
    @State var anyCancellable = Set<AnyCancellable>()
    func resetImage(){
        self.clearAutoReload()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1 ) {
            let loader = ImageLoader()
            loader.$event.sink(receiveValue: { evt in
                self.onImageEvent(evt: evt)
            }).store(in: &anyCancellable)
            loader.reload(url: self.url)
        }
    }
    
    private func onImageEvent(evt:ImageLoaderEvent?){
        guard let  evt = evt else { return }
        switch evt {
        case .reset :
            self.resetImage()
            break
        case .complete(let img) :
            self.clearAutoReload()
            DispatchQueue.main.async {
                self.image = img
                withAnimation{self.opacity = 1.0}
            }
            
        case .error :
            self.clearAutoReload()
            self.image = nil
            break
        }
    }
    
    @State var autoReloadSubscription:AnyCancellable?
    func creatAutoReload() {
        var count = 0
        self.autoReloadSubscription?.cancel()
        guard let url = self.url  else {
            self.image = nil
            return
        }
        self.autoReloadSubscription = Timer.publish(
            every: count == 0 ? 0.3 : 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                count += 1
                self.imageLoader.load(url: url)
                if count == 5 {
                    DataLog.d("autoReload fail " + (url ?? " nil") , tag:self.tag)
                    self.resetImage()
                }
            }
    }
    func clearAutoReload() {
        self.autoReloadSubscription?.cancel()
        self.autoReloadSubscription = nil
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
    }
}



