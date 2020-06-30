//
//  GetCouponResponse.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 08/06/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import Foundation

public struct GetCouponResponse: Decodable
{
    enum CodingKeys: String, CodingKey
    {
        case id             = "id"
        case createDate     = "createDate"
        case customerId     = "customer_id"
        case couponCode     = "coupon_code"
        case couponValue    = "coupon_value"
        case couponKey      = "coupon_key"
        case issueDate      = "issue_date"
        case purchasedDate  = "purchased_date"
        case expirationDate = "expiration_date"
    }
    
    let id              : Int
    let customerId      : Int
    let couponValue     : Int
    let couponCode      : String
    let createDate      : String
    let couponKey       : String
    let issueDate       : String
    let expirationDate  : String
    let purchasedDate   : String?
    
    public init(from decoder: Decoder) throws
    {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id             = try container.decodeIfPresent(Int.self, forKey: .id)                  ?? 0
        self.customerId     = try container.decodeIfPresent(Int.self, forKey: .customerId)          ?? 0
        self.couponValue    = try container.decodeIfPresent(Int.self, forKey: .couponValue)         ?? 0
        self.couponCode     = try container.decodeIfPresent(String.self, forKey: .couponCode)       ?? kEmptyString
        self.createDate     = try container.decodeIfPresent(String.self, forKey: .createDate)       ?? kEmptyString
        self.couponKey      = try container.decodeIfPresent(String.self, forKey: .couponKey)        ?? kEmptyString
        self.issueDate      = try container.decodeIfPresent(String.self, forKey: .issueDate)        ?? kEmptyString
        self.expirationDate = try container.decodeIfPresent(String.self, forKey: .expirationDate)   ?? kEmptyString
        self.purchasedDate  = try container.decodeIfPresent(String.self, forKey: .purchasedDate)    ?? kEmptyString
    }
}
