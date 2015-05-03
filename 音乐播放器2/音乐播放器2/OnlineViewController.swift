//
//  OnlineViewController.swift
//  音乐播放器2
//
//  Created by 李鑫 on 14-8-1.
//  Copyright (c) 2014年 李鑫. All rights reserved.
//
import AVFoundation
import UIKit

class OnlineViewController: UIViewController, AVAudioPlayerDelegate {
    
    var channel: Channel!
    var songList: Array<Song> = Array()
    var currentSong: Song!
    var currentIndex: Int!
    var player: AVAudioPlayer!
    var timer: NSTimer!
    
    
    @IBOutlet var songImageView: UIImageView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var songLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBAction func didFavClicked(sender: UIBarButtonItem) {
        //存到本地
        var song = currentSong
        NSKeyedArchiver.archiveRootObject(song, toFile: "/Users/lixin/Desktop/test.plist")
        
        //测试读取
        var song2: Song = NSKeyedUnarchiver.unarchiveObjectWithFile("/Users/lixin/Desktop/test.plist") as Song
    }
    
    @IBAction func valueChanged(sender: UISlider) {
        player.currentTime = NSTimeInterval(sender.value) * player.duration
    }
    
    @IBAction func preClicked(sender: UIButton) {
        player.stop()
        timer.invalidate()
        slider.value = 0
        if currentIndex <= 0{
            
        } else {
            currentIndex = currentIndex - 1
            currentSong = songList[currentIndex]
            loadSongInfo(currentSong.id)
        }
        
    }
    
    @IBAction func nextClicked(sender: UIButton) {
        player.stop()
        timer.invalidate()
        slider.value = 0
        if currentIndex >= songList.count{
            
        } else {
            currentIndex = currentIndex + 1
            currentSong = songList[currentIndex]
            loadSongInfo(currentSong.id)
        }
    }
    
    @IBAction func playClicked(sender: UIButton) {
        if player.playing {
            player.pause()
            sender.titleLabel.text = "暂停"
        } else {
            player.play()
            sender.titleLabel.text = "播放"
        }
        
    }
    
    func showSongInfo() {
        self.artistLabel.text = self.currentSong.artistName
        self.songLabel.text = self.currentSong.songName
    }
    
    func downloadData(path: String, dataHandler: (NSData) -> Void) {
        let url = NSURL(string: path)
        let request = NSURLRequest(URL: url)
        //异步请求
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var httpResponse = response as NSHTTPURLResponse
            if httpResponse.statusCode == 200 {
                dataHandler(data)
            }
            })
    }
    
    func playSong(data: NSData) {
        player = AVAudioPlayer(data: data, error: nil)
        player.prepareToPlay()
        player.delegate = self
        player.play()
        
        //显示时间
        var time = Int(player.duration)
        var min = time / 60
        var sec = time % 60
        
        self.timeLabel.text = "\(min):\(sec)"
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "refreshSlider", userInfo: nil, repeats: true)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        player.stop()
        timer.invalidate()
        slider.value = 0
        
        if currentIndex >= songList.count{
            
        } else {
            currentIndex = currentIndex + 1
            currentSong = songList[currentIndex]
            loadSongInfo(currentSong.id)
        }
        
    }
    
    func refreshSlider() {
        var v = (player.currentTime / player.duration)
        slider.value = Float(v)
    }
    
    //下载歌曲
    func downloadSong(path: String) {
        downloadData(path, dataHandler: {
            (data: NSData) -> Void in
                self.playSong(data)
            })
        
    }
    
    
    func loadSongInfo(id: Int) {
        let url = "http://music.baidu.com/data/music/fmlink?type=mp3&rate=1&format=json&songIds=\(id)"
        downloadData(url, dataHandler: {
            (data: NSData) -> Void in
            
            var dic: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
            var dataDic: NSDictionary = dic["data"] as NSDictionary
            var list: NSArray = dataDic["songList"] as NSArray
            var songDic: NSDictionary = list[0] as NSDictionary
            
            //更新歌曲信息
            self.currentSong.refreshSong(songDic)
            self.showSongInfo()
            self.downloadSong(self.currentSong.songLink)
            
            self.downloadData(self.currentSong.songPicBig, dataHandler: {
                (data: NSData) -> Void in
                    self.songImageView.image = UIImage(data: data)
                })
            
            })
            }
    
    func loadSongList() {
        let url = "http://fm.baidu.com/dev/api/?tn=playlist&special=flash&prepend=&format=json&_=1378945264366&id=" + channel.id
        downloadData(url, dataHandler: {
            (data: NSData) -> Void in
            
            let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
            let list: NSArray = json["list"] as NSArray
            
            for dic in list {
                let song = Song()
                song.id = Int(dic["id"] as NSNumber)
                self.songList.append(song)
            }
            
            if self.songList.count != 0 {
                self.currentSong = self.songList[0]
                self.currentIndex = 0
                self.loadSongInfo(self.currentSong.id)
            }

            
            })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSongList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
