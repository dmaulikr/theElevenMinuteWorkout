//
//  ViewController2.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 4/14/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

class ViewController2: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private var pageViewController: UIPageViewController?
    private let contentTexts = ["Level 1", "Level 2", "Level 3", "Level 4", "Level 5", "Level 6"]
    private var pageIsAnimating = false
    private var userHasFullAccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        setupPageControl()
        pageIsAnimating = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        checkLocalRecordsForFullAccess()
    }
    
    func checkLocalRecordsForFullAccess() {
        userHasFullAccess = NSUserDefaults.standardUserDefaults().boolForKey("fullAccess")
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageIsAnimating = true
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed || finished) {
            pageIsAnimating = false
        }
    }
    
    // a couple of unwind segue callbacks, do nothing
    @IBAction func cancelWorkout(segue: UIStoryboardSegue) {}
    @IBAction func goBackFromSettings(segue: UIStoryboardSegue) {}
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentTexts.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    private func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        pageController.delegate = self
        if contentTexts.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    // going backwards (to a previous page) callback
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if(!pageIsAnimating) {
            let itemController = viewController as! PageItemController
            if itemController.itemIndex > 0 {
                return getItemController(itemController.itemIndex-1)
            }
        }
        return nil
    }
    
  
    // going forwards (to the next page) callback
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if(!pageIsAnimating) {
            let itemController = viewController as! PageItemController
            if itemController.itemIndex + 1 < contentTexts.count {
                    // user has full access, go to the next workout
                    return getItemController(itemController.itemIndex+1)
            }
        }
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PageItemController? {
        if itemIndex < contentTexts.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.userHasFullAccess = self.userHasFullAccess
            pageItemController.labelText = contentTexts[itemIndex]
            return pageItemController
        }
        return nil
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
