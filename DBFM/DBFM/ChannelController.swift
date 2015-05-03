import UIKit
import QuartzCore

protocol ChannelProtocol {
    func onChangeChannel(channel: String)
}

class ChannelController : UIViewController, UITableViewDelegate {
    
    
    @IBOutlet var tv : UITableView!
    var channelData = NSArray()
    var dalegate:ChannelProtocol?
    
    override func viewDidLoad()  {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        let rowData : NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        cell.textLabel!.text = rowData["name"] as? String
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowData : NSDictionary = channelData[indexPath.row] as! NSDictionary
        let channel_id : AnyObject = rowData["channel_id"] as AnyObject!
        let channel = "channel=\(channel_id)"
        dalegate!.onChangeChannel(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {cell.layer.transform = CATransform3DMakeScale(1, 1, 1)})
    }

}
