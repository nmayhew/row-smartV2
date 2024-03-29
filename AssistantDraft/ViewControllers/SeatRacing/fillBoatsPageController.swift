//
//  fillBoats.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 30/07/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import UIKit



class fillBoats: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource  {
    
    lazy var orderedViewControllers: [UIViewController] = []
    
    //Contains dots for page control
    var pageControl = UIPageControl()
    var parentController: FillBoatsOverviewViewController?
    var seatRace: SeatRace?
    var seatRaceBoats: [SeatRaceBoat]?
    
    //Sets up first view
    override func viewDidLoad() {
        super.viewDidLoad()
        orderedViewControllers = configureBoatViews()
        self.dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true, completion: nil)
        }
        self.delegate = self
        configurePageControl()
    }
    
    //Adds boat views as needed
    func configureBoatViews() -> [UIViewController] {
        var viewSubControllers: [UIViewController] = []
        for boat in seatRaceBoats! {
            
            switch boat.type {
            case "M8+":viewSubControllers.append(buildEight(boat: boat))
            case "W8+":viewSubControllers.append(buildEight(boat: boat))
            case "LW8+":viewSubControllers.append(buildEight(boat: boat))
            case "LM8+":viewSubControllers.append(buildEight(boat: boat))
            case "M4x":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "LM4x":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "W4x":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "LW4x":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "LM4-":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "M4-":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "LW4-":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "W4-":viewSubControllers.append(buildCoxlessFour(boat: boat))
            case "M4+":viewSubControllers.append(buildCoxFour(boat: boat))
            case "W4+":viewSubControllers.append(buildCoxFour(boat: boat))
            case "LM4+":viewSubControllers.append(buildCoxFour(boat: boat))
            case "LW4+":viewSubControllers.append(buildCoxFour(boat: boat))
            case "M2x":viewSubControllers.append(buildPair(boat: boat))
            case "W2x":viewSubControllers.append(buildPair(boat: boat))
            case "LM2x":viewSubControllers.append(buildPair(boat: boat))
            case "LW2x":viewSubControllers.append(buildPair(boat: boat))
            case "M2-":viewSubControllers.append(buildPair(boat: boat))
            case "W2-":viewSubControllers.append(buildPair(boat: boat))
            case "LW2-":viewSubControllers.append(buildPair(boat: boat))
            case "LM2-":viewSubControllers.append(buildPair(boat: boat))
            case "M1x":viewSubControllers.append(buildSingle(boat: boat))
            case "W1x":viewSubControllers.append(buildSingle(boat: boat))
            case "LM1x":viewSubControllers.append(buildSingle(boat: boat))
            case "LW1x":viewSubControllers.append(buildSingle(boat: boat))
            default:
                print("Oh shit")
            }
        }
        return viewSubControllers
    }
    
    //MARK: Build sub views 
    func buildEight(boat: SeatRaceBoat) -> UIViewController {
        let newView = self.newViewContr(viewController: "eightFill") as! EightFillViewController
        newView.boat = boat
        newView.delegate = parentController
        newView.delegateShouldSend = parentController
        return newView
    }
    
    func buildCoxFour(boat: SeatRaceBoat) -> UIViewController {
        let newView = self.newViewContr(viewController: "coxedFourFill") as! CoxedFourViewController
        newView.boat = boat
        newView.delegate = parentController
        newView.delegateShouldSend = parentController
        return newView
    }
    func buildCoxlessFour(boat: SeatRaceBoat) -> UIViewController {
        let newView = self.newViewContr(viewController: "coxlessFourQuadFill") as! CoxlessFourViewController
        newView.boat = boat
        newView.delegate = parentController
        newView.delegateShouldSend = parentController
        return newView
    }
    func buildPair(boat: SeatRaceBoat) -> UIViewController {
        let newView = self.newViewContr(viewController: "pairFill") as! PairFillViewController
        newView.boat = boat
        newView.delegate = parentController
        newView.delegateShouldSend = parentController
        return newView
    }
    func buildSingle(boat: SeatRaceBoat) -> UIViewController {
        let newView = self.newViewContr(viewController: "singleFill") as! SingleFillViewController
        newView.boat = boat
        newView.delegate = parentController
        newView.delegateShouldSend = parentController
        return newView
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
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    //MARK: Delegate methords
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
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
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
