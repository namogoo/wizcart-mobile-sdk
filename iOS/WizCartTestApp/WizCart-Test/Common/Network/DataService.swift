//
//  DataController.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 01/06/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import Foundation
import Alamofire

struct DataService
{
    static func getUserType(with userRequest: GetUserRequest, and completionBlock: @escaping GetUserCompletionBlock)
    {
        let url = App.APIDestanations.Urls.GetUserType(userRequest: userRequest)
        AF.request(url).responseString { (response) in
            let userResponse = GetUserResponse(value: response.value, error: response.error)
            completionBlock(userResponse)
        }
    }
    
    static func getUserGroup(with userRequest: GetUserRequest, and completionBlock: @escaping GetUserCompletionBlock)
    {
        let url = App.APIDestanations.Urls.GetUserGroup(userRequest: userRequest)
        AF.request(url).responseString { (response) in
            let userResponse = GetUserResponse(value: response.value, error: response.error)
            completionBlock(userResponse)
        }
    }
    
    static func getCoupon(with couponRequest: GetCouponRequest, and completionBlock: @escaping GetCouponCompletionBlock)
    {
        let url = App.APIDestanations.Urls.GetCoupon(couponRequest: couponRequest)
        AF.request(url).responseData(completionHandler: { (response) in
            if let error = response.error
            {
                completionBlock(nil, error)
            }
            else if let data = response.value
            {
                do
                {
                    let decoder         = JSONDecoder()
                    let couponResponse  = try decoder.decode(GetCouponResponse.self, from: data)
                    
                    completionBlock(couponResponse, nil)
                }
                catch let error
                {
                    completionBlock(nil, error)
                }
            }
            else
            {
                completionBlock(nil, nil)
            }
        })
    }
}
