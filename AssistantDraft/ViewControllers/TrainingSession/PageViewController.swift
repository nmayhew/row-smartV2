//
//  PageViewController.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 01/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit



//Controls the different detail views of training session

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    //Ordered Array of Storyboards wanted as pages
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewContr(viewController: "Overview"), self.newViewContr(viewController: "Piece"), self.newViewContr(viewController: "Coach"),self.newViewContr(viewController: "Split")]
    }()
    
    //Contains dots for page control
    private var pageControl = UIPageControl()
    var parentViewContr: TrainingSessionViewController?
    
    //Sets up first view
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true, completion: nil)
        }
        self.delegate = self
        configurePageControl()
    }
   
    //Sets up Page Control variable above
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: self.view.bounds.minY,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.blue
        self.pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
    }
    
    //Name is from Main storyboard in files
    func newViewContr(viewController: String) -> UIViewController {
        if (viewController == "Coach") {
             let newView =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController) as! CoachNotesViewController
            newView.delegate = parentViewContr
            newView.delegateLoaded = parentViewContr
            return newView
            
        } else if (viewController == "Piece")  {
            let newView =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController) as! PiecesViewController
            newView.delegateLoaded = parentViewContr
            newView.delegate = parentViewContr
            return newView
        }
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    

    
    
    // MARK: Delegate methords
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    //Figuring out pages Before with error checking
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    //Figuring out pages after with error checking
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }

}
