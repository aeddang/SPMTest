//
//  CoreData.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/16.
//

import Foundation

extension ContentCoreData {
    static func encode<T:Encodable>(data:T?) -> String? {
        guard let data = data else { return nil }
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
    
    static func decode<T:Decodable>(jsonString:String)->T?{
        let jsonData = jsonString.data(using: .utf8)!
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
            return decodedData
        } catch {
            DataLog.e(error.localizedDescription, tag: " ContentCoreData")
            return nil
        }

    }
}

struct ContentCoreData{
    var contentId:String
    var title:String
    var metaData:String
    var createDate:Date
}

class ContentCoreDataManager:PageProtocol {
   
    func creteTable() {
       
    }
    
    func setData(contentId:String, title:String="", metaDataJsonString:String = ""){
        
    }
    func deleteAllData(){
       
    }
    func deleteData(contentId:String){
        
    }
    
    func getAllDatas()->[ContentCoreData]{
        return []
        
    }
    func getData(contentId:String)->(ContentCoreData)?{
        
        return nil
    }
}
