import UIKit

protocol HttpPrototol {
    func didReceiveResults(results:NSDictionary)
}

class HttpController {
    
    var delegate:HttpPrototol?
    
    init() {
        
    }
    
    func getRequest(url:String) {
        var nsUrl = NSURL(string: url)
        var request = NSURLRequest(URL: nsUrl!)
        NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!, data:NSData!, error:NSError!)->Void in
            var jsonRequest : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
            self.delegate!.didReceiveResults(jsonRequest)
        
        })
    }
}