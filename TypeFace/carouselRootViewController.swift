

import UIKit

class TutorialViewController: UIViewController {

    
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet var headerLabel: UILabel!


    @IBOutlet weak var bottomLabel: UILabel!

    var tutorialPageViewController: TutorialPageViewController? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        pageControl.addTarget(self, action: #selector(TutorialViewController.didChangePageControlValue), forControlEvents: .ValueChanged)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tutorialPageViewController = segue.destinationViewController as? TutorialPageViewController {
            self.tutorialPageViewController = tutorialPageViewController
        }
    }
    
    @IBAction func didTapNextButton(sender: UIButton) {
        tutorialPageViewController?.scrollToNextViewController()
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        tutorialPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension TutorialViewController: TutorialPageViewControllerDelegate {
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageIndex index: Int) {
        if (index == 0){
            self.headerLabel.text = "what"
            self.bottomLabel.text = "Caketalk 🍰 bakes fun into sharing personal updates "
        }
        else if (index == 1){
            self.headerLabel.text = "how"
            self.bottomLabel.text = "Type a statement and record a gesture. Repeat"
        }
        else{
            self.headerLabel.text = "why"
            self.bottomLabel.text =  "Tell your story in the way it was meant to be told"
        }
        pageControl.currentPage = index
    }
    
}
