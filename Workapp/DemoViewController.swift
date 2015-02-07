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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let introVC = storyboard.instantiateViewControllerWithIdentifier("introViewController") as IntroViewController
        introVC.parentPageViewController = self

        let firstVC = storyboard.instantiateViewControllerWithIdentifier("firstViewController") as FirstViewController
        firstVC.parentPageViewController = self

        let secondVC = storyboard.instantiateViewControllerWithIdentifier("secondViewController") as SecondViewController
        secondVC.parentPageViewController = self
        
        let thirdVC = storyboard.instantiateViewControllerWithIdentifier("thirdViewController") as ThirdViewController
        thirdVC.parentPageViewController = self

        let exitVC = storyboard.instantiateViewControllerWithIdentifier("exitViewController") as ExitViewController
        exitVC.parentPageViewController = self

        pages.append(introVC)
        pages.append(firstVC)
        pages.append(secondVC)
        pages.append(thirdVC)
        pages.append(exitVC)
        
        setViewControllers([introVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        dataSource = self
    }
    
}

extension DemoViewController : UIPageViewControllerDataSource {
    
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
    
    func navigateTo(page : Int) {
        let toVC = pages[page]
        setViewControllers([toVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
}
