//
//  AppManager.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 07/06/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import Foundation
import WizCart

class AppManager
{
    //MARK: - Properties
    var hasDisplayedWizCartIncentive    : Bool                      = false
    var isWizCartGroup                  : Bool                      = true
    let currentCurrencySymbol           : String                    = "€"
    let accountId                       : String                    = "264"
    let clientId                        : String                    = "b551882c4a4d6779ef696d2902323cfb"
    let tempClientId                    : String                    = "b551882c4a4d6779ef696d2902323cfb"
    let controlClientId                 : String                    = "fffe3b22ddcc5e887aaa8fd9aa9083ca"
    let controlTempClientId             : String                    = "fffe3b22ddcc5e887aaa8fd9aa9083ca"
    let referrer                        : String                    = "Referrer"
    let pageReferrer                    : String                    = "A Page referrer"
    var coupon                          : String?                   = nil
    var trafficSources                  : Array<String>             = []
    var appliedCoupons                  : Array<String>             = ["A coupon code", "A coupon code2", "A coupon code3"]
    var cube                            : NamogooCube               = NamogooCube()
    var sphere                          : NamogooSphere             = NamogooSphere()
    let wizCartUserRequest              : GetUserRequest            = GetUserRequest(accountId: 264, userId: "b551882c4a4d6779ef696d2902323cfb")
    let controlUserRequest              : GetUserRequest            = GetUserRequest(accountId: 264, userId: "fffe3b22ddcc5e887aaa8fd9aa9083ca")
    var cartId                          : String                    = UUID().uuidString
    //Order number
    let trackingId                      : String                    = UUID().uuidString
    var incentiveResponse               : WizCartIncentiveResponse? = nil
    
    var currentUserType : GetUserResponse!
    {
        didSet
        {
            self.handleTrafficSourceUpdate(for: currentUserType.value ?? kEmptyString)
        }
    }
    
    var currentUserGroup : GetUserResponse!
    {
        didSet
        {
            self.handleTrafficSourceUpdate(for: currentUserGroup.value ?? kEmptyString)
        }
    }
    
    public static let shared = AppManager()
    
    private init(){}
    
    //MARK: - Utils

    public func setRealUserConfiguration()
    {
        let wizCartConfigurations   = WizCartConfigurations(with: self.accountId,
                                                            clientId: self.clientId,
                                                            retailerVisitor: self.clientId,
                                                            trafficSources: self.trafficSources)
       
        WizCartSDK.configure(with: wizCartConfigurations)
    }
       
    public func setControlUserConfiguration()
    {
        let wizCartConfigurations   = WizCartConfigurations(with: self.accountId,
                                                            clientId: self.controlClientId,
                                                            retailerVisitor: self.controlClientId,
                                                            trafficSources: self.trafficSources)

        WizCartSDK.configure(with: wizCartConfigurations)
    }
    
    public func clearTrafficSources()
    {
        self.trafficSources = Array()
    }
    
    public func getCart() -> WizCartCart
    {
        let currentAmountDouble = Double(self.cube.quantity)
        let subtotal            = currentAmountDouble * self.cube.price
        let products            = self.convertNamogooCubeArrayToWizCartProductsArray()
        let totalQuantity       = self.getTotalQuantity(for: products)
        let discountValue       = Double(self.incentiveResponse?.currentTier?.discountResult.value ?? 0)
        var total               = subtotal
        
        if let currentTier = self.incentiveResponse?.currentTier,
            discountValue > 0
        {
            if currentTier.discountResult.type == .fixed
            {
                total = subtotal - (discountValue / 100) //Discount value is in cents
            }
            else
            {
                total = (subtotal / 100) * (100 - discountValue) //Discount is a percent of the total amount.
            }
        }
        
        let cart = WizCartCart("\(self.cartId)", items: products, total: total, subtotal: subtotal, quantity: totalQuantity, discountValue: discountValue)
        return cart
    }
    
    public func getCouponHash(for coupon: String) -> Int64
    {
        var hash: Int32 = 5381

        var currentLastIndex = coupon.index(coupon.endIndex, offsetBy: -1)

        while currentLastIndex >= coupon.startIndex
        {
            let lastCharInString = coupon[currentLastIndex]
            let charASCIIValue = Int32(lastCharInString.asciiValue ?? 0)
            hash = (hash &* 33) ^ charASCIIValue
            
            if currentLastIndex > coupon.startIndex
            {
                currentLastIndex = coupon.index(currentLastIndex, offsetBy: -1)
            }
            else
            {
                break
            }
        }

        return Int64(hash) & 0xffffffff
    }
    
    public func getProduct() -> WizCartProduct
    {
        let namogooCubeProduct = WizCartProduct(self.cube.sku,
                                                productId: self.cube.productId,
                                                price: self.cube.price,
                                                listPrice: self.cube.listPrice,
                                                brand: self.cube.brand,
                                                categories: self.cube.categories,
                                                attributes: self.cube.attributes,
                                                quantity: Int32(self.cube.quantity))
        return namogooCubeProduct
    }
    

    
    private func convertNamogooCubeArrayToWizCartProductsArray() -> Array<WizCartProduct>
    {
        var productsArray = Array<WizCartProduct>()

        if self.cube.quantity > 0
        {
            let namogooCubeProduct = WizCartProduct(self.cube.sku,
                                                    productId: self.cube.productId,
                                                    price: self.cube.price,
                                                    listPrice: self.cube.listPrice,
                                                    brand: self.cube.brand,
                                                    categories: self.cube.categories,
                                                    attributes: self.cube.attributes,
                                                    quantity: Int32(self.cube.quantity))
            
            productsArray.append(namogooCubeProduct)
        }
        
        
        if self.sphere.quantity > 0
        {
            let namogooSphereProduct = WizCartProduct(self.sphere.sku,
                                                      productId: self.sphere.productId,
                                                      price: self.sphere.price,
                                                      listPrice: self.sphere.listPrice,
                                                      brand: self.sphere.brand,
                                                      categories: self.sphere.categories,
                                                      attributes: self.sphere.attributes,
                                                      quantity: Int32(self.sphere.quantity))
        
            productsArray.append(namogooSphereProduct)
        }
        
        return productsArray
    }
    
    private func getTotalQuantity(for products: Array<WizCartProduct>) -> Int32
    {
        var itemsCount: Int32 = 0
        
        for product in products
        {
            itemsCount = itemsCount + product.quantity
        }
        
        return itemsCount
    }
    
    private func handleTrafficSourceUpdate(for trafficSource: String)
    {
        self.trafficSources.append(trafficSource)
        WizCartSDK.setTrafficSources(trafficSources: self.trafficSources)
    }
}
