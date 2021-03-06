//
//  ViewController.swift
//  AlecrimAsyncKitExampleiOS
//
//  Created by Vanderlei Martinelli on 2015-08-27.
//  Copyright © 2015 Alecrim. All rights reserved.
//

import UIKit
import AlecrimAsyncKit

class ViewController: UIViewController {
    
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var t1: NonFailableTask<Void>!
    var t2: NonFailableTask<Void>!
    var t3: NonFailableTask<Void>!
    var t4: NonFailableTask<Void>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // (oh, Xcode template, if you did not tell me I'll never know... but, from a nib? I thought we were in 2015...)
        
        // OK: the user will have to tap the four buttons, after that an image will be loaded asynchronous
        // and there will be much rejoicing (yaaaaaaaay)
        
        // this example is here to demonstrate that tasks can be finished outside their inner blocks and
        // to exemplify that asynchronous tasks can include interface elements and user actions
        // (maybe it is not a common case, but it is good start for an app "coaching" feature, for example)
        
        self.t1 = asyncEx { task in
            // do nothing here, see `oneButtonPressed:` method below
        }
        
        self.t2 = asyncEx { task in
            await(self.t1)
            
            mainThread {
                // interface elements have to be updated on the main thread
                self.twoButton.isEnabled = true
            }
        }

        self.t3 = asyncEx { task in
            await(self.t1)
            await(self.t2)
            
            mainThread {
                self.threeButton.isEnabled = true
            }
        }

        self.t4 = asyncEx { task in
            await(self.t1)
            await(self.t2)
            await(self.t3)
            
            mainThread {
                self.fourButton.isEnabled = true
            }
        }
        
        // normally you will have a already created NSOperationQueue and use it
        // or dispatch the closure ("block" is so 2009) to some GCD queue,
        // here we did it using a helper function (see it at the end of this file)
        backgroundThread {
            // we always wait for a task finishing on background
            // (if we do it on main thread, it will block the app
            // [AlecrimAsyncKit has an assertion to prevent that, anyway])
            await(self.asyncWaitUntilDone())

            // to demonstrate delay condition...
            // (even if we do not wait for this task, it will be started after two seconds anyway)
            let _: Task<Void> = asyncEx(condition: DelayCondition(timeInterval: 2)) { task in
                mainThread {
                    self.doneLabel.text = "And now for something\ncompletely different..."
                    task.finish() // we have always to tell when the task is finished
                }
            }

            // try to load a cool Minion image...
            do {
                let image = try await { self.asyncLoadImage() }
                
                mainThread {
                    self.doneLabel.isHidden = true

                    // OK, we can now eat some bananas... finally!
                    self.imageView.image = image
                    self.imageView.isHidden = false
                }
            }
            catch {
                mainThread {
                    self.doneLabel.text = "Could not load image. :/"
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // (someone even put something here?)
    }

}

extension ViewController {
    
    @IBAction func oneButtonPressed(_ sender: UIButton) {
        sender.isHidden = true
        self.t1.finish() // yes, we can finish the task outside its inner block
    }
    
    @IBAction func twoButtonPressed(_ sender: UIButton) {
        sender.isHidden = true
        self.t2.finish()
    }
    
    @IBAction func threeButtonPressed(_ sender: UIButton) {
        sender.isHidden = true
        self.t3.finish()
    }
    
    @IBAction func fourButtonPressed(_ sender: UIButton) {
        sender.isHidden = true
        self.t4.finish()
    }
    
}

extension ViewController {

    func asyncWaitUntilDone() -> NonFailableTask<Void> {
        return asyncEx { task in
            // OK, we know we'll not fail
            try! await([self.t1, self.t2, self.t3, self.t4].whenAll())
            
            mainThread {
                self.doneLabel.text = "Done!"
                self.doneLabel.isHidden = false
                
                // we can finish the task on any thread, even the main thread
                task.finish()
            }
        }
    }

    func asyncLoadImage() -> Task<UIImage> {
        // an observer is not needed to the task finish its job, but to have a network activity indicator at the top would be nice...
        let networkActivityObserver = UIApplication.shared.networkActivity

        // if you replace 10 for 2, for example, the task will be cancelled before it is finished
        let timeoutObserver = TimeoutObserver(timeout: 10)
        
        // here we have the common case where a func returns a task
        // and the task is finished inside its inner block
        return async(observers: [networkActivityObserver, timeoutObserver]) {
            // remember that since iOS 9 (and OS X 10.11 El Capitan, My Capitan!) we cannot use "http" anymore because...
            // wibbly wobbly... time-y wimey... stuff!
            guard let imageURL = URL(string: "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-90081.jpg"),
                  let imageData = (try? Data(contentsOf: imageURL)), // this is OK for example purposes, in real life use NSURLSession and related classes
                  let image = UIImage(data: imageData)
            else {
                throw NSError(domain: "com.alecrim.AlecrimAsyncKitExampleiOS", code: 1000, userInfo: nil)
            }
            
            await(asyncDelay(timeInterval: 5)) // I think we can let them waiting a little more...
            
            // thank you for the image, Minions and wallhaven.cc :-) 
            // (All rights reserved to its owners. Gru?)
            return image
        }
    }
    
}

private func mainThread(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

private func backgroundThread(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}
