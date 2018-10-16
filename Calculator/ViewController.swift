//
//  ViewController.swift
//  Calculator
//
//  Created by Natsuko Nishikata on 2018/10/04.
//  Copyright © 2018年 Natsuko Nishikata. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    private var calculator:Calculator!

    @IBOutlet weak var displayTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
      
        calculator = Calculator(intValue: Int(arc4random() % 9))
        displayTextField.text = calculator.displayString()
    }

    @IBAction func tap(_ sender: UIButton) {
        
        guard let text = sender.titleLabel?.text else {
            assertionFailure()
            return
        }
        let error = calculator.input(text: text)
        var message:String? = nil
        switch error {
        case .noError:
            break
        case .fatal:
            message = "入力または計算中に問題が発生しました。"
        case .negativeValue:
            message = "計算結果が負の値になりました。負の値は無効です。"
        case .calculateOverflow:
            message = "計算結果が大きすぎます。この値は無効です。"
        case .inputOverflow:
            message = "これ以上入力できません。"
        }
        displayTextField.text = calculator.displayString()
        
        if message != nil {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }

    }
}

