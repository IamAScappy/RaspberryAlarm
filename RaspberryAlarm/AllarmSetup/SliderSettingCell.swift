//
//  SliderSettingCell.swift
//  RaspberryAlarm
//
//  Created by 류성두 on 2017. 11. 11..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class SliderSettingCell: UITableViewCell{

    var delegate:SliderSettingCellDelegate!
    @IBOutlet weak var titleLB:UILabel!
    @IBOutlet weak var quantityLB:UILabel!
    @IBOutlet weak var slider:UISlider!

    @IBAction func updateQuantity(_ sender:UISlider){
        quantityLB.text = "\(Int(sender.value))"
        delegate.didSliderValueChanged(titleLB.text!, Int(sender.value))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        quantityLB.text = "\(Int(slider.value))"
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

protocol SliderSettingCellDelegate {
    func didSliderValueChanged(_ changer:String, _ changedValue:Int)
}
