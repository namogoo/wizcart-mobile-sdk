//
//  ConfirmationViewController.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 31/05/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import UIKit
import WizCart

class ConfirmationViewController: UIViewController
{
    //MARK: - IBOutlets
    @IBOutlet weak var backToStoreBackgroundView: UIView!
    
    private let manager = AppManager.shared
    
    //MARK: - Life cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.setupViews()
        self.sendTrackPageViewRequest()
        self.manager.cartId = UUID().uuidString
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.setupWizCartDelegate()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - private funcs
    private func setupViews()
    {
        self.backToStoreBackgroundView.drawRoundedCorners(with: App.defaultCornerRadius, and: App.Colors.tealSolid.color.cgColor)
        self.backToStoreBackgroundView.drawShadow()
    }
    
    private func setupWizCartDelegate()
    {
        WizCartSDK.setDelegate(with: self)
    }
    
    //MARK: - IBActions
    @IBAction func instagramButtonTapped(_ sender: Any)
    {
        guard let webUrl        = URL(string: "https://www.instagram.com/namogoo_official/")    else { return }
        guard let facebookURL   = URL(string: "instagram://user?username=namogoo_official")     else { return }
        
        if UIApplication.shared.canOpenURL(facebookURL)
        {
            UIApplication.shared.open(facebookURL)
        }
        else if UIApplication.shared.canOpenURL(webUrl)
        {
            UIApplication.shared.open(webUrl)
        }
    }
    
    @IBAction func googlePlusButtonTapped(_ sender: Any)
    {
        //Google plus is dead!
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any)
    {
        guard let webUrl        = URL(string: "https://www.facebook.com/namogoo/")  else { return }
        guard let facebookURL   = URL(string: "fb://page?id=849381121776002")       else { return }
        
        if UIApplication.shared.canOpenURL(facebookURL)
        {
            UIApplication.shared.open(facebookURL)
        }
        else if UIApplication.shared.canOpenURL(webUrl)
        {
            UIApplication.shared.open(webUrl)
        }
    }
    
    @IBAction func backToStoreButtonTapped(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Requests
    private func sendTrackPageViewRequest()
    {
        let cart                            = manager.getCart()
        let referer                         = manager.referrer
        let pageReferer                     = manager.pageReferrer
        let couponCode                      = manager.coupon
        let hasDisplayedWizCartIncentive    = manager.hasDisplayedWizCartIncentive
        
        WizCartSDK.trackPageView(pageView: .confirmationPage,
                                 cart: cart,
                                 referrer: referer,
                                 pageReferrer: pageReferer,
                                 couponCode: couponCode,
                                 hasDisplayedWizCartIncentive: hasDisplayedWizCartIncentive)
    }
}

//MARK: - WizCart delegate
extension ConfirmationViewController: WizCartDelegate
{
    func trackResult(with trackResponse: WizCartTrackResponse?, and error: Error?)
    {
        print(String(describing: trackResponse))
        print(String(describing: error))
    }
}
