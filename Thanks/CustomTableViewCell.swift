//
//  CustomTableViewCell.swift
//  Thanks
//
//  Created by 岩男高史 on 2019/03/20.
//  Copyright © 2019 岩男高史. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
  
  @IBOutlet weak var rankinglabel: UILabel!
  @IBOutlet weak var rankingimage: UIImageView!
  @IBOutlet weak var rankingtime: UILabel!
  @IBOutlet weak var rankingname: UILabel!
  

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      //imageviewを丸くする
      rankingimage.layer.borderWidth = 1
      rankingimage.layer.masksToBounds = false
      rankingimage.layer.cornerRadius = rankingimage.frame.height/2
      rankingimage.clipsToBounds = true
      backgroundView?.backgroundColor = UIColor.orange
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
