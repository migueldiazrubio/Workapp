//
//  StepViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 1/2/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class StepViewController: UIViewController {
    
    var stepTitle : String?
    var stepSubtitle : String?
    var stepImage : UIImage?
    
    var stepNumber : Int?
    
    var parentPageViewController : DemoViewController!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let titulo = stepTitle {
            self.titleLabel.text = titulo
        }
        if let subtitulo = stepSubtitle {
            self.subtitleLabel.text = subtitulo
        }
        if let imagen = stepImage {
            self.imageView.image = imagen
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("nextView:"))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    func nextView(gesture: UITapGestureRecognizer) {
        parentPageViewController.nextView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        parentPageViewController.currentPage = stepNumber!
    }
    
    // Forzamos la orientación en vertical para el tutorial
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientation.Portrait.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
}
