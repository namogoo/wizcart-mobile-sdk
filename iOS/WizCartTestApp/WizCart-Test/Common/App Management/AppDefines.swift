//
//  AppDefines.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 28/05/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

typealias GetUserCompletionBlock = (GetUserResponse) -> Void
typealias GetCouponCompletionBlock = (GetCouponResponse?, Error?) -> Void

//Point all default string values to the same string instead of allocating a new string each time.
let kEmptyString = ""

struct App
{
    static let defaultCornerRadius : Double = 4
}

//Segues
extension App
{
    enum Segues
    {
        case cartViewControllerSegue
        case confirmationViewControllerSegue
        
        var segueIdentifier: String
        {
            switch self
            {
            case .cartViewControllerSegue           : return "CartViewControllerSegue"
            case .confirmationViewControllerSegue   : return "ConfirmationViewControllerSegue"
            }
        }
    }
}

//Colors
extension App
{
    enum Colors
    {
        case tealSolid
        case tealTranslucent
        case namogooCubeOuterGradientColor
        case namogooCubeInnerGradientColor

        var color : UIColor
        {
            switch self
            {
            case .tealSolid                     : return UIColor(red: 17 / 255, green: 126 / 255, blue: 137 / 255, alpha: 1)
            case .tealTranslucent               : return UIColor(red: 17 / 255, green: 126 / 255, blue: 137 / 255, alpha: 0.4)
            case .namogooCubeOuterGradientColor : return UIColor(red: 254 / 225, green: 207 / 255, blue: 60 / 255, alpha: 1)
            case .namogooCubeInnerGradientColor : return UIColor(red: 253 / 225, green: 243 / 255, blue: 210 / 255, alpha: 1)
            }
        }
    }
}

extension App
{
    enum UrlConstants : String
    {
        case defaultServer  = "key.personali.com"
        case couponSever    = "coupon.personali.com"
    }

    struct APIDestanations
    {
        enum Urls
        {
            case GetUserType(userRequest: GetUserRequest)
            case GetUserGroup(userRequest: GetUserRequest)
            case GetCoupon(couponRequest: GetCouponRequest)
        }
    }
}

extension App.APIDestanations.Urls: URLConvertible
{
    var host: String
    {
        switch self
        {
        case .GetCoupon : return App.UrlConstants.couponSever.rawValue
        default         : return App.UrlConstants.defaultServer.rawValue
        }
    }
    
    var path: String
    {
        switch self
        {
        case .GetUserType(let userRequest)  : return "/user_to_type_\(userRequest.accountId)"
        case .GetUserGroup(let userRequest) : return "/user_to_group_\(userRequest.accountId)"
        case .GetCoupon                     : return "/"
        }
    }
    
    var query: String
    {
        switch self
        {
        case .GetUserType(let userRequest)  : return "name=\(userRequest.userId)&safe=true"
        case .GetUserGroup(let userRequest) : return "name=\(userRequest.userId)&safe=true"
        case .GetCoupon(let couponRequest)  : return "customer_id=\(couponRequest.customerId)&coupon_key=\(couponRequest.couponHash)"
        }
    }
    
    func asURL() throws -> URL
    {
        var linkURLComponents       = URLComponents()
        
        linkURLComponents.scheme    = "https"
        linkURLComponents.host      = host
        linkURLComponents.path      = path
        linkURLComponents.query     = query
        
        return linkURLComponents.url!
    }
}
