//
//  Cell.swift
//  Reviews
//
//  Created by Admin on 17/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}