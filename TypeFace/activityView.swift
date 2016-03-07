
//
//  activityView.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/10/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import Parse
import Bolts
var friends : [NSDictionary] = []
var activities : [NSDictionary] = []
class activityView: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var activityTable: UITableView!
    @IBOutlet weak var noFriendsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if (activities.count == 0)
        {
            noFriendsView.hidden = false
        }
    }

    override func viewDidAppear(animated: Bool) {

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
