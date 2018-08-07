//
//  ViewController.swift
//  AdvImageView
//
//  Created by Jim on 2018/6/7.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //字串 轉 ＵＲＬ有分險不見得可轉 要符合規範（不能帶中文 與特殊字元    要轉成web 格式％ 空白=>％２０）
//        let urlString = "http://k.softarts.cc/00tmp/Cat14MP.JPG"
//        let urlString = "http://t.softarts.cc/class/北鼻.jpg"
        let urlString = "http://k.softarts.cc/00tmp/Cat14MP.JPG"
        
        
        guard let encodeed = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            //允許改用urlQueryAllowed 做編碼   不用作web格式 檔名修改
            assertionFailure("Fail to encode urlString")
            return
        }
        print("Qriginal:\(urlString)")
        print("Encoded: \(encodeed)")
        
//        guard let url = URL(string: urlString) else {
        guard let url = URL(string: encodeed) else {
            assertionFailure("Invalid URL: \(urlString)")
            return
        }
        imageView1.showImage(url: url)
        imageView1.showImage(url: url)//測試 後面呀前面    測試前要先刪除app
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

