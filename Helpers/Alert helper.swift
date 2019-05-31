//
//  Alert helper.swift
//  MJColorChecker2
//
//  Created by Jim Macintosh Shi on 5/30/19.
//  Copyright © 2019 Creative Sub. All rights reserved.
//

import UIKit


func showValueEditingAlert(title: String?, message: String?, defaultText: String?, keyboardType: UIKeyboardType, completion: @escaping (String?) -> ()) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addTextField(configurationHandler: {
        textField in
        textField.text = defaultText
        textField.keyboardType = keyboardType
    })
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
        [completion, weak alertController] (_) in
        let textField = alertController?.textFields![0]
        completion(textField?.text)
    }))
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
}
