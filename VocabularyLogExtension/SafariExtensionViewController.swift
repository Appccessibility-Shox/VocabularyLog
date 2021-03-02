//
//  SafariExtensionViewController.swift
//  VocabularyLogExtension
//
//  Created by Patrick Botros on 3/1/21.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
