//
//  MainViewController.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 18/05/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import UIKit
import WizCart

class MainViewController: UIViewController
{
    //MARK: - IBOutlets
    @IBOutlet weak var trackingCallBackgroundView       : UIView!
    @IBOutlet weak var getIncentiveCallBackgroundView   : UIView!
    @IBOutlet weak var appVersionLabel                  : UILabel!
    @IBOutlet weak var sdkVersionLabel                  : UILabel!
    @IBOutlet weak var groupTypeSwitch                  : UISwitch!
    
    //MARK: - Properties
    private let manager = AppManager.shared

    //MARK: - Life cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupViews()
        
        self.sendGetUserTypeRqeust()
        self.sendGetUserGroupRqeust()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.setupWizCartDelegate()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - private funcs
    private func setupViews()
    {
        self.getIncentiveCallBackgroundView.drawRoundedCorners(with: App.defaultCornerRadius, and: App.Colors.tealSolid.color.cgColor)
        self.trackingCallBackgroundView.drawRoundedCorners(with: App.defaultCornerRadius, and: App.Colors.tealSolid.color.cgColor)
        self.getIncentiveCallBackgroundView.drawShadow()
        self.trackingCallBackgroundView.drawShadow()
        
        let appVersion              = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? kEmptyString
        self.appVersionLabel.text   = "\(appVersionLabel.text ?? kEmptyString) \(appVersion)"
        
        if let frameworkBundle = Bundle(identifier: "com.namogoo.WizCartSDK"),
            let version = frameworkBundle.infoDictionary?["CFBundleShortVersionString"],
            let build = frameworkBundle.infoDictionary?["CFBundleVersion"] as? String
        {
            self.sdkVersionLabel.text = "\(sdkVersionLabel.text ?? kEmptyString) \(version).\(build)"
        }
    }
    
    private func setupWizCartDelegate()
    {
        WizCartSDK.setDelegate(with: self)
    }
    
    //MARK: - IBActions
    @IBAction func groupTypeSwitchToggled(_ sender: UISwitch)
    {
        if sender.isOn
        {
            manager.setRealUserConfiguration()
            self.groupTypeSwitch.backgroundColor = .clear
        }
        else
        {
            manager.setRealUserConfiguration()
            self.groupTypeSwitch.backgroundColor = App.Colors.tealTranslucent.color
        }
        
        self.manager.isWizCartGroup = sender.isOn
        self.manager.clearTrafficSources()
        self.sendGetUserGroupRqeust()
        self.sendGetUserTypeRqeust()
    }
    
    @IBAction func trackingButtonTapped(_ sender: Any)
    {
        self.sendTrackPageViewRequest()
    }
    
    @IBAction func getIncentiveButtonTapped(_ sender: Any)
    {
        self.sendGetIncentiveRequest()
    }
    
    //MARK: - Requests
    private func sendGetUserTypeRqeust()
    {
        let currentUser = groupTypeSwitch.isOn ? manager.wizCartUserRequest : manager.controlUserRequest
        
        DataService.getUserType(with: currentUser) { [weak self](respose) in
            self?.manager.currentUserType = respose
        }
    }
    
    private func sendGetUserGroupRqeust()
    {
        let currentUser = groupTypeSwitch.isOn ? manager.wizCartUserRequest : manager.controlUserRequest

        DataService.getUserGroup(with: currentUser) { [weak self](respose) in
            self?.manager.currentUserGroup = respose
        }
    }
    
    private func sendTrackPageViewRequest()
    {
        let cart                            = manager.getCart()
        let referrer                        = manager.referrer
        let pageReferrer                    = manager.pageReferrer
        let couponCode                      = manager.coupon
        let hasDisplayedWizCartIncentive    = manager.hasDisplayedWizCartIncentive
        
        WizCartSDK.trackPageView(pageView: .homePage,
                                 cart: cart,
                                 referrer: referrer,
                                 pageReferrer: pageReferrer,
                                 couponCode: couponCode,
                                 hasDisplayedWizCartIncentive: hasDisplayedWizCartIncentive)
    }
    
    private func sendGetIncentiveRequest()
    {
        let cart = manager.getCart()

        WizCartSDK.getIncentive(with: cart, pageType: .homePage)
    }
}

//MARK: - WizCart delegate 
extension MainViewController: WizCartDelegate
{
    func getIncentiveResult(with incentiveResponse: WizCartIncentiveResponse?, and error: Error?)
    {
        DispatchQueue.main.async {
            self.manager.incentiveResponse = incentiveResponse
            self.performSegue(withIdentifier: App.Segues.cartViewControllerSegue.segueIdentifier, sender: nil)
        }
    }

    func trackResult(with trackResponse: WizCartTrackResponse?, and error: Error?)
    {
        DispatchQueue.main.async {
            let duration = 2.0
            var message: String

            if trackResponse != nil
            {
                message = "🎉 Success"
            }
            else
            {
                message = "😕 Failure"
            }

            UIAlertController.presentToast(with: message, and:duration, on: self)
        }
    }
}
