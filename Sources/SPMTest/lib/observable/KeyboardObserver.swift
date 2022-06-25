//
//  KeyboardObserver.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import SwiftUI
import Combine
import UIKit
enum KeyboardObserverEvent {
    case cancel
}
class KeyboardObserver: ObservableObject {
    private var cancellable: AnyCancellable?
    
    @Published var event: KeyboardObserverEvent? = nil
    {
        didSet{
            if self.event == nil { return }
            self.event = nil
        }
    }

    @Published private(set) var keyboardHeight: CGFloat = 0
    {
        didSet(oldVal){
            //ComponentLog.d("oldVal " + oldVal.description, tag: "SceneObserver")
            if oldVal == keyboardHeight { return }
            if self.keyboardHeight == 0.0 && self.isOn  { self.isOn = false }
            else if self.keyboardHeight > 0.0 && !self.isOn { self.isOn = true }
            
            //ComponentLog.d("isOn  " + isOn .description, tag: "SceneObserver")
            ComponentLog.d("keyboardHeight " + keyboardHeight.description, tag: "SceneObserver")
           
        }
    }

    @Published private(set) var isOn:Bool = false
    

    private let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }

    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ -> CGFloat in 0 }


    func start(){
        self.isOn = self.keyboardHeight != 0
        if cancellable != nil { return }
           cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
                   .subscribe(on: RunLoop.main)
                   .assign(to: \.keyboardHeight, on: self)
        }

    func cancel(){
        cancellable?.cancel()
        cancellable = nil
        keyboardHeight = 0
        self.isOn = false
    }

    deinit {
        cancel()
    }
}
