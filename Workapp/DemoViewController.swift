//
//  DemoViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 31/1/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class DemoViewController: UIPageViewController {
    
    var currentPage : Int = 1
    var pages : [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIPageControl.appearance().backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        
        self.view.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        
        // Configuramos el DEMO
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstVC = storyboard.instantiateViewControllerWithIdentifier("firstViewController") as! FirstViewController
        firstVC.parentPageViewController = self
        
        let secondVC = storyboard.instantiateViewControllerWithIdentifier("stepViewController") as! StepViewController
        secondVC.parentPageViewController = self
        
        let thirdVC = storyboard.instantiateViewControllerWithIdentifier("stepViewController") as! StepViewController
        thirdVC.parentPageViewController = self
        
        let forthVC = storyboard.instantiateViewControllerWithIdentifier("stepViewController") as! StepViewController
        forthVC.parentPageViewController = self
        
        let fifthVC = storyboard.instantiateViewControllerWithIdentifier("stepViewController") as! StepViewController
        fifthVC.parentPageViewController = self
        
        firstVC.stepTitle = NSLocalizedString("step_1_title", comment: "")
        firstVC.stepSubtitle = NSLocalizedString("step_1_subtitle", comment: "")
        firstVC.stepImage = UIImage(named: "demo_01")
        firstVC.stepNumber = 1
        
        secondVC.stepTitle = NSLocalizedString("step_2_title", comment: "")
        secondVC.stepSubtitle = NSLocalizedString("step_2_subtitle", comment: "")
        secondVC.stepImage = UIImage(named: "demo_01")
        secondVC.stepNumber = 2
        
        thirdVC.stepTitle = NSLocalizedString("step_3_title", comment: "")
        thirdVC.stepSubtitle = NSLocalizedString("step_3_subtitle", comment: "")
        thirdVC.stepImage = UIImage(named: "demo_01")
        thirdVC.stepNumber = 3
        
        forthVC.stepTitle = NSLocalizedString("step_4_title", comment: "")
        forthVC.stepSubtitle = NSLocalizedString("step_4_subtitle", comment: "")
        forthVC.stepImage = UIImage(named: "demo_01")
        forthVC.stepNumber = 4
        
        fifthVC.stepTitle = NSLocalizedString("step_5_title", comment: "")
        fifthVC.stepSubtitle = ""
        fifthVC.stepNumber = 5
        
        pages.append(firstVC)
        pages.append(secondVC)
        pages.append(thirdVC)
        pages.append(forthVC)
        pages.append(fifthVC)
        
        setViewControllers([firstVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: { (Bool) -> Void in
        })
        
        dataSource = self
    }
    
}

extension DemoViewController : UIPageViewControllerDataSource {
    
    func nextView() {

        if (currentPage == pages.count) {

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.showMainViewController()

        } else {
            let nextVC = pages[currentPage]
            currentPage++
            setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if (currentPage < pages.count) {
            return pages[currentPage]
        } else {
            return nil
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if (currentPage > 1) {
            return pages[currentPage-2]
        } else {
            return nil
        }
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return (currentPage - 1)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
}
