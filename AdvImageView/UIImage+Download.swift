//
//  UIImage+Download.swift
//  AdvImageView
//
//  Created by Jim on 2018/6/7.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit

extension UIImageView{
    
//    var Loading = UIActivityIndicatorView?.self
    //Extensions must not contain stored properties 錯誤示範
    
    static var currentTask = [String:URLSessionDataTask]()  //用String 來區別Task
    
    
    func showImage(url:URL) {
        
//        print("self.description:\(self.description) ")
        
        //Ckeck if we should canecl exist download task.
        if let existTask = UIImageView.currentTask[self.description] {//
            
            existTask.cancel()
            UIImageView.currentTask.removeValue(forKey: self.description)
            print("A exist task is canceled.")
        }
        
        
        //Check if we should use file from cash directly.
        let filename = String(format: "Cache_%ld", url.hashValue)//hashValue會拿出int （唯一的數字當檔名）
        print("想看 \(filename)\n" )

        guard let cashesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first// urls是陣列 取得第一個（因該也只有一個）
            else {//for 這邊指會搜尋
            return
        }
        
        let fullFileURL = cashesURL.appendingPathComponent(self.description) //（完整路徑）硬碟某個檔案的路徑
        print("Cashes:  \(cashesURL)\n" )
        
        if let image = UIImage(contentsOfFile: fullFileURL.path){ //url格式 與路徑格式 可以轉換
            //Exist cash file , let's sue it and return immediately
            self.image=image
            return
        }//可以判斷存不存在 並路徑在不在 一行做了兩件事
        //Keep going to download process
        
        
        let loadingView = perpareLoadingView()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //這邊會 URLsession 會開始執行背景程式
        let task = session.dataTask(with: url) { (data, response , error) in
            //repone 會拿到底層 的200 400 等code
            //有錯誤會帶出 異常 所以這邊顯示出來
            
            
            defer{//英文延後的意思
                DispatchQueue.main.async { //只要是 一對大括號{}執行後結束就會執行defer ex:  if func
                    loadingView.stopAnimating()
                }//
            }//可以把多個defer 想成堆疊 (由上至下執行)
            
            if let error = error{//下載失敗
                print("Down fail:  \(error)")
                return
                //Maybe show a default image
            }
            
            guard let data = data else{//有資料 才做下面的事情
                assertionFailure("data is nil")     //邏輯上是 不該來到這的 會閃退
                return
            }
            
            defer{//練習
                //...會被上面ㄉ的guard 擋住 而變成只有第一個defer
            }
            
            let image = UIImage(data: data) //raw data
            //Very very Important
            DispatchQueue.main.async {//切回main thread
                //竟然可以 在沒有圖檔就這樣寫self
                self.image = image
                
                //還有不要讓main thrad 做太多事情 不然一定會卡
                //可以自己造水管 == 背景thread  不是呼叫mian 是另外開thread
                
                //之後用activty indicatorView  只要開始 跟停止指令
            }
            //不該在非ui thread 讀寫任何資料
//            loadingView.stopAnimating()  錯誤
            
            //Save data as cashes file.
            try? data.write(to: fullFileURL)  //只想知道 成功或失敗 失敗會回傳nil
            
            
//            try! data.write(to: fullFileURL)  // 假設一定成功 失敗crash      ？選擇的意味 ！警告的意味（西方標示）
            
//            do{
//                try data.write(to: fullFileURL)
//            }catch{
//                print("Write cache file fail: \(error)")//error 是隱藏的參數 列出原因
//            }
            
            //Remove task from currentTask.
            UIImageView.currentTask.removeValue(forKey: self.description)  //結束任務時 清除字典
        }
        
        task.resume() // Important  開始任務
        //Keep the running task.
        UIImageView.currentTask[self.description] = task  //description 不會重複
        
        
        loadingView.startAnimating()
        //轉轉轉開始跑
        
//        task.cancel()//任務取消
//        task.suspend()//掛起

    }
    
    
    
    private func perpareLoadingView() -> UIActivityIndicatorView{//不該重複叫轉轉轉 降低效能
        //Find out exist loadingView.
//        for view in self.subviews{   //只要addview 加入的 都會到self.subviews
//            if view is UIActivityIndicatorView{
//                return view as! UIActivityIndicatorView
//            }//找到veiw 在做處理
//        }
        
        let tag = 98765
        if let view = self.viewWithTag(tag) as? UIActivityIndicatorView{  //tag 會在sub的所以階層往下找
            return view
        }//這段是使用 veiw中的tag id找到對應的view
        
        
        let frame = CGRect(origin: .zero, size: self.frame.size) //auto layout前身
        //frame 很大   整個frame蓋住 元件特性 會保持原樣 不會跟者放大
//        result.autoresizingMask = [.flexibleHeight ,.flexibleWidth ]
        //上面這行可以讓轉轉轉 可以至中
        let result = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)//這邊是style
        
        result.frame = frame
        result.color = .blue
        result.autoresizingMask = [.flexibleHeight ,.flexibleWidth ]
        
        result.hidesWhenStopped = true //若無再跑 會隱藏
        result.tag = tag
        
        self.addSubview(result)
        
        return result
        
    }
    
    
    
    
}

