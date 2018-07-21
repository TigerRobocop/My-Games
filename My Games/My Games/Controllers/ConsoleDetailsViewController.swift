//
//  ConsoleDetailsViewController.swift
//  My Games
//
//  Created by Aluno on 21/07/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit

class ConsoleDetailsViewController: UIViewController {

    var console: Console!
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lbName.text = console.name
        
        
        if let image = console.icon as? UIImage {
            ivIcon.image = image
        } else {
            ivIcon.image = UIImage(named: "noCoverFull")
        }
      
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AddEditConsoleViewController
        vc.console = console
    }

}
