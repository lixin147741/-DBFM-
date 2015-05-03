//
//  ViewController.swift
//  DBFM
//
//  Created by lixin on 14-7-8.
//  Copyright (c) 2014year lixin. All rights reserved.


import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController, UITableViewDelegate, HttpPrototol, ChannelProtocol {
    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
    
    
    @IBOutlet var tv : UITableView!
    @IBOutlet var iv : UIImageView!
    @IBOutlet var progress : UIProgressView!
    @IBOutlet var nowTime : UILabel!
    @IBOutlet var tap : UITapGestureRecognizer!
    @IBOutlet var btnPlay : UIImageView!
    
    var doHttp : HttpController = HttpController()
    var songData : NSArray = NSArray()
    var channelData = NSArray()
    var imageCache = Dictionary<String, UIImage>()
    
    var vedioPlayer = MPMoviePlayerController()
    
    var timer : NSTimer?
    
    //页面加载完成运行
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //从豆瓣提供的api上面下载歌曲列表
        doHttp.delegate = self
        doHttp.getRequest("http://www.douban.com/j/app/radio/channels")
        doHttp.getRequest("http://douban.fm/j/mine/playlist?channel=0")
        progress.progress = 0.0
        iv.addGestureRecognizer(tap)
    }

    //内存警告是运行
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //点击界面上的按钮式运行
    @IBAction func onTap(sender : UITapGestureRecognizer) {
        if sender.view == iv {
            //暂停歌曲
            vedioPlayer.pause()
            btnPlay.hidden = false
            btnPlay.addGestureRecognizer(tap)
            iv.removeGestureRecognizer(tap)
        } else if sender.view == btnPlay {
            //播放歌曲
            vedioPlayer.play()
            btnPlay.hidden = true
            btnPlay.removeGestureRecognizer(tap)
            iv.addGestureRecognizer(tap)
        }
    }
    //显示界面前调用
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var channelC : ChannelController = segue.destinationViewController as! ChannelController
        channelC.dalegate = self
        channelC.channelData = self.channelData
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    //显示歌曲列表
        func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        let rowCell : NSDictionary = self.songData[indexPath.row] as! NSDictionary
        cell.textLabel!.text = rowCell["title"] as? String
        cell.detailTextLabel?.text = rowCell["artist"] as? String
        cell.imageView!.image = UIImage(named:"detail.jpg")
        let url = rowCell["picture"] as! String
        if let image = self.imageCache[url] as UIImage? {
            cell.imageView!.image = image
        } else {
            let imageURL = NSURL(string: url)
            let request = NSURLRequest(URL: imageURL!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!?, data:NSData?, error:NSError?)->Void in
                if let imgData = data {
                    let img = UIImage(data:imgData)
                    cell.imageView!.image = img
                    self.imageCache[url] = img
                }
                })
        }
        return cell
    }
    
    //选择歌曲时切换
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        let song : NSDictionary = songData[indexPath.row] as! NSDictionary
        loadImage(song["picture"] as! String)
        loadSong(song["url"] as! String)
    }
    
    //设置动画效果
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {cell.layer.transform = CATransform3DMakeScale(1, 1, 1)})
    }
    
    //点击选择频道按钮是运行
    func onChangeChannel(channel: String) {
        doHttp.getRequest("http://douban.fm/j/mine/playlist?"+channel)
    }

    
    //加载歌单
    func didReceiveResults(results: NSDictionary) {
        if results["song"] != nil {
            self.songData = results["song"] as! NSArray
            self.tv.reloadData()
            
            //play the first of music
            let firstSong = self.songData[0] as! NSDictionary
            loadSong(firstSong["url"] as! String)
            loadImage(firstSong["picture"] as! String)
            
        } else if results["channels"] != nil {
            println("l")
            self.channelData = results["channels"] as! NSArray
        } else {
            
        }
    }
    //加载音乐
    func loadSong(url:String) {
        timer?.invalidate()
        nowTime.text = "00:00"
        self.vedioPlayer.stop()
        self.vedioPlayer.contentURL = NSURL(string:url)
        self.vedioPlayer.play()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        btnPlay.removeGestureRecognizer(tap)
        btnPlay.hidden = true
        iv.addGestureRecognizer(tap)
    }
    //计算时间并且显示
    func onUpdate() {
        let currentTime = vedioPlayer.currentPlaybackTime
        if currentTime>0.0 {
            let totalTime = vedioPlayer.duration
            let p : Float = Float(currentTime/totalTime)
            progress.setProgress(p, animated: true)
            
            var time = ""
            let s:Int = Int(totalTime%60)
            let m:Int = Int(totalTime/60)
            if m>=10 {
                time += "\(m)"
            } else {
                time += "0\(m)"
            }
            time += ":"
            if s>=10 {
                time += "\(s)"
            } else {
                time += "0\(s)"
            }
            nowTime.text = time
        }
    }
    
    //加载大图片
    func loadImage(url:String) {
        if let image = self.imageCache[url] as UIImage? {
            self.iv.image = image
        } else {
            let imageURL = NSURL(string: url)
            let request = NSURLRequest(URL: imageURL!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!, data:NSData!, error:NSError!)->Void in
                let img = UIImage(data:data)
                self.iv.image = img
                self.imageCache[url] = img
                })
        }
    }
}

