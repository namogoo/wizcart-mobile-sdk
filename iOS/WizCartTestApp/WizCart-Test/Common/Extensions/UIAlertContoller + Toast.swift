
//
//  UIAlertContoller + Toast.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 28/05/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import UIKit

extension UIAlertController
{
    static func presentToast(with message: String, and duration: Double = 1.0, on viewController: UIViewController)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        viewController.present(alertController, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alertController.dismiss(animated: true)
        }
    }
}
