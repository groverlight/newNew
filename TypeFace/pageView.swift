//
//
// 
// Page View Controller
// 
//  
//

import UIKit

class pageView: UIPageViewController {
    
    var pageViewDelegate: pageDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newColoredViewController("Green"),
            self.newColoredViewController("Red"),
            self.newColoredViewController("Blue")]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
       
            scrollToViewController(orderedViewControllers[1])
        
        
        pageViewDelegate?.PageView(self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                viewControllerAfterViewController: visibleViewController) {
                    scrollToViewController(nextViewController)
        }
    }
    
    private func newColoredViewController(color: String) -> UIViewController {
        
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(color)ViewController")
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     */
    private func scrollToViewController(viewController: UIViewController) {
        setViewControllers([viewController],
            direction: .Forward,
            animated: true,
            completion: { (finished) -> Void in
                // Setting the view controller programmatically does not fire
                // any delegate methods, so we have to manually notify the
                // 'tutorialDelegate' of the new index.
                
                self.notifypageDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifypageDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.indexOf(firstViewController) {
                    pageViewDelegate?.PageView(self,
                    didUpdatePageIndex: index)
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension pageView: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
           //     return orderedViewControllers.last
                return nil;
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
                }

    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }

            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                //return orderedViewControllers.first
                return nil;
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
}

/*extension pageView: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            //print ("new view") // enter logic
            if (finished){
                
            }
            
        notifypageDelegateOfNewIndex()
    }
    
}*/


protocol pageDelegate {
    

    func PageView(PageView: pageView, didUpdatePageCount count: Int)
    //pageControl.numberOfPages = count
    
    
    func PageView(PageView: pageView, didUpdatePageIndex index: Int)
    //pageControl.currentPage = index
    
    
}
