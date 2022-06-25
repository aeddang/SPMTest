//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation


class PersistContentKeyCoreDataManager:PageProtocol {
   
    
    func creteTable() {
        
    }
    
    func setData(contentId:String, data:Data, fileId:String=""){
       
    }
    func deleteAllData(){
       
    }
    func deleteData(contentId:String, fileId:String=""){
        
    }
    
    func getAllDatas()->[(String, Data, Date)]{
        return []
        
    }
    func getData(contentId:String, fileId:String="")->(String, Data, Date)?{
        
        return nil
    }
    
    //group
    func setData(fileId:String, contentIds:[String]){
        
    }
    func deleteData(fileId:String){
       
    }
    func getData(fileId:String)->([String], Date)?{
        return nil
       
    }
}
