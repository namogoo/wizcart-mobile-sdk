//
//  CartViewController.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 28/05/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import UIKit
import WizCart

class CartViewController: UIViewController
{
    //MARK: - IBOutlets
    @IBOutlet weak var namogooCubeView          : UIView!
    @IBOutlet weak var namogooCouponView        : UIView!
    @IBOutlet weak var couponViewRectangularBox : UIView!
    @IBOutlet weak var payButton                : UIButton!
    @IBOutlet weak var plusButton               : UIButton!
    @IBOutlet weak var minusButton              : UIButton!
    @IBOutlet weak var priceLabel               : UILabel!
    @IBOutlet weak var amountLabel              : UILabel!
    @IBOutlet weak var subtotalLabel            : UILabel!
    @IBOutlet weak var couponLabel              : UILabel!
    @IBOutlet weak var incentiveLabel           : UILabel!
    @IBOutlet weak var promoLabel               : UILabel!
    
    private let manager = AppManager.shared
    
    //MARK: - Life cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupViews()
        self.sendTrackPageViewRequest()
        
        if let incentiveResponse = self.manager.incentiveResponse
        {
            self.handleIncentiveResponse(with: incentiveResponse)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.setupWizCartDelegate()
    }
    
    //MARK: - private funcs
    private func setupNavigationBar()
    {
        let titleGroup = manager.isWizCartGroup ? "Wiz Cart" : "Control"
        self.title = "\(titleGroup) Get Incentive Call"
        
        let backButtonViewFrame = CGRect(x: 0, y: 0, width: 30, height: 44)
        let backButtonFrame     = CGRect(x: -10, y: 0, width: 30, height: 44)
        let backButtonView      = UIView(frame: backButtonViewFrame)
        let backButton          = UIButton(frame: backButtonFrame)
        
        backButton.setImage(UIImage(imageLiteralResourceName: "back button arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        backButtonView.addSubview(backButton)
        
        let backBarButtonItem                   = UIBarButtonItem(customView: backButtonView)
        self.navigationItem.leftBarButtonItem   = backBarButtonItem
    }
    
    private func setupViews()
    {
        self.namogooCubeView.drawNamogooGradient()
        self.namogooCubeView.drawRoundedCorners(with: App.defaultCornerRadius, shouldMaskToBound: true)
        self.payButton.drawRoundedCorners(with: App.defaultCornerRadius)
        self.namogooCouponView.drawRoundedCorners(with: App.defaultCornerRadius)
        self.plusButton.drawRoundedCorners(with: Double(self.plusButton.frame.height) / 2)
        self.minusButton.drawRoundedCorners(with: Double(self.minusButton.frame.height) / 2)
        self.amountLabel.text   = "\(manager.cube.quantity)"
        self.priceLabel.text    = String(format: "\(manager.currentCurrencySymbol)%.2f", manager.cube.price)
        
        self.setSubtotalLabel()
        self.setupCouponView(with: self.manager.incentiveResponse != nil, shouldPresentCouponRectangle: false)
    }
    
    private func setupCouponView(with shouldPresentView: Bool, shouldPresentCouponRectangle: Bool)
    {
        //The view is currently hidden and we are about the present it to the user
        if self.namogooCouponView.isHidden && shouldPresentView
        {
            self.manager.hasDisplayedWizCartIncentive = true
            sendTrackMaximizeView()
        }
        else if !self.namogooCouponView.isHidden && !shouldPresentView //The view is currently not hidden and we should hide it. 
        {
            sendTrackMinimizeView()
        }
        
        self.namogooCouponView.isHidden = !shouldPresentView
        
        if shouldPresentCouponRectangle
        {
            self.couponViewRectangularBox.isHidden      = false
            self.couponLabel.isHidden                   = false
            self.promoLabel.isHidden                    = false

            self.couponViewRectangularBox.removeLayers()
            self.couponViewRectangularBox.drawRoundedCorners(with: 0, lineWidth: 2, and: UIColor.red.cgColor)
        }
        else
        {
            self.couponViewRectangularBox.isHidden  = true
            self.couponLabel.isHidden               = true
            self.promoLabel.isHidden                = true
        }
    }
    
    private func setSubtotalLabel()
    {
        let currentAmountDouble = Double(manager.cube.quantity)
        let subtotal            = currentAmountDouble * manager.cube.price
        self.subtotalLabel.text = String(format: "\(manager.currentCurrencySymbol)%.2f", subtotal)
    }
    
    private func setupWizCartDelegate()
    {
        WizCartSDK.setDelegate(with: self)
    }
    
    //MARK: - IBActions
    @objc func backButtonTapped(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func plusButtonTapped(_ sender: Any)
    {
        self.manager.cube.quantity  = manager.cube.quantity + 1
        self.amountLabel.text       = "\(manager.cube.quantity)"
        
        self.setSubtotalLabel()
        self.sendTrackItemAddedRequest()
        self.sendGetIncentiveRequest()
    }
    
    @IBAction func minusButtonTapped(_ sender: Any)
    {
        guard manager.cube.quantity > 0 else { return }
        
        self.manager.cube.quantity  = manager.cube.quantity - 1
        self.amountLabel.text       = "\(manager.cube.quantity)"

        self.setSubtotalLabel()
        self.sendTrackItemRemovedRequest()
        self.sendGetIncentiveRequest()
    }
    
    @IBAction func payButtonTapped(_ sender: Any)
    {
        if let coupon = self.manager.coupon, coupon != kEmptyString
        {
            self.manager.appliedCoupons.append(coupon) //Assuming we used a coupon from personali
        }
        
        self.sendTrackOrderRequest()
        self.performSegue(withIdentifier: App.Segues.confirmationViewControllerSegue.segueIdentifier, sender: nil)
    }
    
    @IBAction func couponCodeLongTapGestureTapped(_ sender: Any)
    {
        UIPasteboard.general.string = self.couponLabel.text
        
        UIAlertController.presentToast(with: "Copied to clipboard", on: self)
        
        self.sendTrackCopyCouponRequest()
    }
    
    //MARK: - Requests
    private func sendTrackPageViewRequest()
    {
        let cart                            = manager.getCart()
        let referer                         = manager.referrer
        let pageReferer                     = manager.pageReferrer
        let couponCode                      = manager.coupon
        let hasDisplayedWizCartIncentive    = manager.hasDisplayedWizCartIncentive
        
        WizCartSDK.trackPageView(pageView: .cartPage,
                                 cart: cart,
                                 referrer: referer,
                                 pageReferrer: pageReferer,
                                 couponCode: couponCode,
                                 hasDisplayedWizCartIncentive: hasDisplayedWizCartIncentive)
    }
    
    private func sendTrackOrderRequest()
    {
        let cart                = manager.getCart()
        let trackingId          = manager.trackingId
        let wizCartCouponCode   = manager.coupon
        let appliedCoupons      = manager.appliedCoupons
        
        var discountValue : Double = 0
        
        if let discountResult = self.manager.incentiveResponse?.currentTier?.discountResult
        {
            //DiscountResult value is in cents
            //This only takes into account fixed discount.
            //Should account for percent discount as well.
            discountValue = Double(discountResult.value / 100)
        }
        
        //Should only include coupon code if the user acutally used it.
        WizCartSDK.trackCompletedPurchase(pageView: .cartPage,
                                          cart: cart,
                                          trackingId: trackingId,
                                          couponCode: wizCartCouponCode,
                                          appliedCoupons: appliedCoupons,
                                          cartDiscountValueOfWizCart: discountValue,
                                          hasAddedOtherIncentiveTypes: false)
    }
    
    private func sendTrackItemAddedRequest()
    {
        let cart    = manager.getCart()
        let product = manager.getProduct()
        
        WizCartSDK.trackItemAddedToCart(pageView: .cartPage, cart: cart, product: product)
    }
    
    private func sendTrackItemRemovedRequest()
    {
        let cart    = manager.getCart()
        let product = manager.getProduct()
        
        WizCartSDK.trackItemRemovedFromCart(pageView: .cartPage, cart: cart, product: product)
    }
    
    private func sendTrackCopyCouponRequest()
    {
        let cart    = manager.getCart()
        let coupon  = manager.coupon
        
        WizCartSDK.trackCopyCoupon(pageView: .cartPage, cart: cart, couponCode: coupon)
    }
    
    private func sendTrackMaximizeView()
    {
        if self.manager.incentiveResponse?.currentTier != nil
        {
            let cart    = manager.getCart()
            let coupon  = manager.coupon
            
            WizCartSDK.trackMaximizeView(pageView: .cartPage, cart: cart, couponCode: coupon)
        }
    }
    
    private func sendTrackMinimizeView()
    {
        if self.manager.incentiveResponse == nil
        {
            let cart    = manager.getCart()
            let coupon  = manager.coupon
            
            WizCartSDK.trackMinimizeView(pageView: .cartPage, cart: cart, couponCode: coupon)
        }
    }
    
    private func sendGetIncentiveRequest()
    {
        let cart = manager.getCart()

        WizCartSDK.getIncentive(with: cart, pageType: .cartPage)
    }
    
    private func sendGetCouponRequest(for currentTier: WizCartTier)
    {
        let couponCode          = "CHRONODRIVE_\(currentTier.threshold / 100)_\(currentTier.discountResult.value / 100)"
        let hashedCouponCode    = manager.getCouponHash(for: couponCode)
        let request             = GetCouponRequest(couponHash: hashedCouponCode, customerId: Int(manager.accountId)!)
        
        DataService.getCoupon(with: request) { [weak self](response, error)  in
            //This is a demo app, therefore coupon db might be empty so we generate a mock coupon.
            //For real usages avoid generating the coupons yourself.
            let couponCode          = response?.couponCode ?? String(UUID().uuidString.prefix(13))
            self?.manager.coupon    = couponCode
            
            DispatchQueue.main.async {
                self?.couponLabel.text = couponCode
                self?.view.layoutIfNeeded()
                self?.setupCouponView(with: true, shouldPresentCouponRectangle: true)
            }
        }
    }
    
    //MARK: - response handling
    private func handleIncentiveResponse(with incentiveResponse: WizCartIncentiveResponse)
    {
        self.manager.incentiveResponse = incentiveResponse
        
        if let currentTier = incentiveResponse.currentTier
        {
            self.sendGetCouponRequest(for: currentTier)
            
            self.incentiveLabel.text = "You have \(currentTier.discountResult.value / 100)€ discount"
        }
        else if let nextTier = incentiveResponse.nextTier
        {
            if self.manager.cube.quantity < 1
            {
                self.incentiveLabel.text = "Add product to your cart to discover your special offer"
            }
            else
            {
                let currentAmountDouble     = Double(manager.cube.quantity)
                let currentTotal            = currentAmountDouble * manager.cube.price
                let amountToNextTier        = Double(nextTier.threshold / 100) - currentTotal
                let amountToNextTierString  = String(format: "%@%.2f", self.manager.currentCurrencySymbol, amountToNextTier)
                self.incentiveLabel.text    = "Add \(amountToNextTierString) of products and get \(nextTier.discountResult.value / 100)€ discount"
            }
            self.setupCouponView(with: true, shouldPresentCouponRectangle: false)
        }
    }
}

//MARK: - WizCart delegate
extension CartViewController: WizCartDelegate
{
    func trackResult(with trackResponse: WizCartTrackResponse?, and error: Error?)
    {
        //Always succeeds
    }
    
    func getIncentiveResult(with incentiveResponse: WizCartIncentiveResponse?, and error: Error?)
    {
        DispatchQueue.main.async {
            guard error == nil else {
                UIAlertController.presentToast(with: error?.localizedDescription ?? kEmptyString, on: self)
                self.manager.incentiveResponse = nil
                self.setupCouponView(with: false, shouldPresentCouponRectangle: false)
                return
            }
            
            if let response = incentiveResponse
            {
                self.handleIncentiveResponse(with: response)
            }
        }
    }
}
