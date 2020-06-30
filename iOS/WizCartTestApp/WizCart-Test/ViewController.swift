//
//  MainViewController.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 18/05/2020.
//  Copyright © 2020 Gini-Apps. All rights reserved.
//

import UIKit
import WizCart

class MainViewController: UIViewController {

    let tealTranslucentColor = UIColor(red: 17 / 255, green: 126 / 255, blue: 137 / 255, alpha: 0.4)
    let tealSolidColor = UIColor(red: 17 / 255, green: 126 / 255, blue: 137 / 255, alpha: 1)
    
    @IBOutlet weak var groupTypeSwitch: UISwitch!
    @IBOutlet weak var trackingCallBackgroundView: UIView!
    @IBOutlet weak var getIncentiveCallBackgroundView: UIView!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews()
    {
        getIncentiveCallBackgroundView.drawRoundedCorners(with: 4, and: tealSolidColor.cgColor)
        trackingCallBackgroundView.drawRoundedCorners(with: 4, and: tealSolidColor.cgColor)
        getIncentiveCallBackgroundView.setShadow()
        trackingCallBackgroundView.setShadow()
        
        
    }
    
    @IBAction func groupTypeSwitchToggled(_ sender: UISwitch)
    {
        if sender.isOn
        {
            self.groupTypeSwitch.backgroundColor = .clear
        }
        else
        {
            self.groupTypeSwitch.backgroundColor = tealTranslucentColor
        }
    }
}

