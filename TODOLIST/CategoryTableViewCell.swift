//
//  CategoryTableViewCell.swift
//  TODOLIST
//
//  Created by 홍준기 on 2023/02/06.
//

import UIKit

protocol CellDelegate : AnyObject {
    func categoryButton(cateUUID : UUID?)
}

class CategoryTableViewCell: UITableViewCell {

    var cateUuid : UUID?
    @IBOutlet weak var title: UILabel!
    
    var cellDelegate : CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func tapPlusTodoBtn(_ sender: UIButton) {
        guard let cateUuid = cateUuid else { return }
        cellDelegate?.categoryButton(cateUUID: cateUuid)
    }
    
    
}
