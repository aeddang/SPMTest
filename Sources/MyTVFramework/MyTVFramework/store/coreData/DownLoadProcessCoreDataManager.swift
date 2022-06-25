//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation



class DownLoadProcessCoreDataManager:PageProtocol {
    
    
    func creteTable() {
        
    }
    
    func setData(q:DownLoadQ){
        self.setData(contentId: q.fildID, path: q.path, ckcURL: q.ckcURL)
    }
    
    func setData(contentId:String, path:String, ckcURL:String){
       
    }
    func deleteAllData(){
        
    }
    func deleteData(contentId:String){
       
    }
    
    func getAllDatas()->[DownLoadQ]{
        return []
        
    }
    
}
