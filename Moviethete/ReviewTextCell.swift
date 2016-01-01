//
//  ReviewCell.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 9/3/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit

class ReviewTextCell: UITableViewCell {

  @IBOutlet weak var review: UITextView!
    override func awakeFromNib() {
      super.awakeFromNib()
      review.delegate = self
      review.textColor = UIColor.lightGrayColor()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
  func setCursorToBeginning(textView: UITextView) {
    textView.selectedRange = NSMakeRange(0, 0)
  }
    
}


extension ReviewTextCell: UITextViewDelegate {
  
  func textViewDidChange(textView: UITextView) {
    if textView.textColor == UIColor.lightGrayColor() {
      let firstChar = textView.text.characters[textView.text.characters.startIndex]
      textView.text = String(firstChar)
      textView.textColor = UIColor.blackColor()
    } else {
      if textView.text.isEmpty {
        textView.textColor = UIColor.lightGrayColor()
        textView.text = "Tell your friends what you think about the movie..."
        self.performSelector(Selector("setCursorToBeginning:"), withObject: review, afterDelay: 0.01)
      }
    }
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    if textView.textColor == UIColor.lightGrayColor() {
      self.performSelector(Selector("setCursorToBeginning:"), withObject: review, afterDelay: 0.01)
    }
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Tell your friends what you think about the movie..."
      textView.textColor = UIColor.lightGrayColor()
    }
  }
  
}