//
//  OnlineTableViewController.swift
//  音乐播放器2
//
//  Created by 李鑫 on 14-8-1.
//  Copyright (c) 2014年 李鑫. All rights reserved.
//

import UIKit

class OnlineTableViewController: UITableViewController {
    
    var channelList: Array<Channel> = Array()
    var currentChannel: Channel!
    
    func loadChannelList() {
        let url = NSURL(string: "https://gitcafe.com/wcrane/XXXYYY/raw/master/baidu.json")
        let request = NSURLRequest(URL: url)
        //发送异步请求
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var httpResponse = response as NSHTTPURLResponse
            if httpResponse.statusCode == 200 {
                //把得到的data转化为json
                let json: NSArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSArray
                
                for dic in json {
                    var channel = dic as NSDictionary
                    self.channelList.append(Channel(dict: channel))
                }
                
                self.tableView.reloadData()
            }
            
            })
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        loadChannelList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.channelList.count
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel.text = channelList[indexPath.row].title

        return cell
    }

    override func tableView(tableView: UITableView!, willSelectRowAtIndexPath indexPath: NSIndexPath!) -> NSIndexPath! {
        currentChannel = self.channelList[indexPath.row]
        return indexPath
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        (segue.destinationViewController as OnlineViewController).channel = currentChannel
    }
   

}
