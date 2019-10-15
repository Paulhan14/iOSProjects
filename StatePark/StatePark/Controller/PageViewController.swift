//
//  PageViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/13/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    let introModel = IntroModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.view.backgroundColor = .white
        // Set start page
        if let startIntroPage = self.viewControllerAt(0) {
            setViewControllers([startIntroPage], direction: .forward, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Build the next page on request
    func viewControllerAt(_ index: Int) -> UIViewController? {
        guard index >= 0 && index < introModel.pageNum else {return nil}
        
        if let introViewController = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController") as? IntroViewController {
            // Set page content
            let descriptionForPage = introModel.descriptions[index]
            let imageName = introModel.imageNames[index]
            introViewController.configureWith(index, descriptionForPage, imageName)
            return introViewController
        }
        return nil
    }
    
    // Support for NEXT button
    func nextPagePresent(_ index: Int) {
        if let nextIntroPage = self.viewControllerAt(index) {
            setViewControllers([nextIntroPage], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    // Data source functions
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! IntroViewController).index
        index -= 1
        return self.viewControllerAt(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! IntroViewController).index
        index += 1
        return self.viewControllerAt(index)
    }
    
}
