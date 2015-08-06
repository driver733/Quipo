//
//  DetailedPostVC.swift
//  Reviews
//
//  Created by Admin on 06/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class DetailedPostVC: UIViewController {

    @IBOutlet weak var label: UILabel!
    var num:Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = String(num)
     
        
        

        // Do any additional setup after loading the view.
    }
   
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
