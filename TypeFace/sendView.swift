//
//  sendView.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/10/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
class sendView: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var sendTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print("sendview loaded")
        sendTable.delegate = self
        sendTable.dataSource = self
        sendTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if (friends.count == 0)
        {
            
        }
    }

    override func viewWillAppear(animated: Bool) {
        sendTable.reloadData()
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("making friends count")
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       // print ("trying to make table")
        let cell:UITableViewCell = sendTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let contact = friends[indexPath.row]
        cell.textLabel?.text = contact["fullName"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
