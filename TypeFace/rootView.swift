///
/// Root View Controller
///
import UIKit

class rootView: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        
        let buttonContainer = UIView()
        buttonContainer.frame = CGRectMake(0, 0, 100, 44)
        buttonContainer.backgroundColor = UIColor.clearColor()
        let button0 = UIButton()
        button0.frame = CGRectMake(0, 0, 100, 44)
        button0.addTarget(self, action: "buttonAction", forControlEvents: UIControlEvents.TouchUpInside)
        button0.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button0.setTitle("Camera", forState: UIControlState.Normal)
        buttonContainer.addSubview(button0)
        navBar.topItem?.titleView = buttonContainer
        
    }
    var PageView: pageView? {
        didSet {
            PageView?.pageViewDelegate = self
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let PageView = segue.destinationViewController as? pageView {
            self.PageView = PageView
        }
    }
    
    func buttonAction() -> Void {
        print("hi")
    }

}

extension rootView: pageDelegate {
    
    func PageView(PageView: pageView,
        didUpdatePageCount count: Int) {
        //pageControl.numberOfPages = count
    }
    
    func PageView(PageView: pageView,
        didUpdatePageIndex index: Int) {
        //pageControl.currentPage = index
    }
    
}
