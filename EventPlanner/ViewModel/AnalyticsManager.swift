//
//  AnalyticsManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 1.09.2023.
//

import Foundation
import FirebaseAnalytics
import FirebaseAnalyticsSwift

final class AnalyticsManager{
    
    static let shared = AnalyticsManager()
    private init(){}
    
    func logEvent(name:String,params:[String:Any]? = nil){
        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserId(userId:String){
        Analytics.setUserID(userId)
    }
    
    func setuserProperty(value:String?, property: String){
        Analytics.setUserProperty(value, forName: property)
    }
}
