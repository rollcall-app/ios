//
//  RegisterViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
    let REGISTER_URL = "http://rollcall-api.herokuapp.com/api/user/registeruser"
    //let REGISTER_URL = "http://localhost:8080/api/user/registeruser"
    //let REGISTER_URL = "http://Samanthas-MacBook-Pro-2.local:8080/api/event/checkIn"
    let sessionManager = SessionManager()
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var phoneWarningLabel: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    //var emailPassedOver : String?
    //var userData : [String] = []
    //var accessToken : String?
    @IBOutlet weak var yearPicker: UIPickerView!
    let yearArr = ["Freshman", "Sophomore", "Junior", "Senior", "Graduate"]
    var year : String?
    @IBOutlet weak var registerButton: UIButton!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        year = yearArr[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.layer.cornerRadius = 8

        emailField.placeholder = Data.sharedInstance.userData[0]
        emailField.isUserInteractionEnabled = false
        
        yearPicker.delegate = self;
        yearPicker.dataSource = self;
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func validate(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    @IBAction func register(_ sender: Any) {
        //check that no fields are empty
        if(!firstNameField.hasText){
            warningLabel.isHidden = false
            phoneWarningLabel.isHidden = true
            return
        }
        if(!lastNameField.hasText){
            warningLabel.isHidden = false
            phoneWarningLabel.isHidden = true
            return
        }
        if(!phoneField.hasText){
            warningLabel.isHidden = false
            phoneWarningLabel.isHidden = true
            return
        }
        
        //check whether the phone number is formatted properly
        if(!validate(value: phoneField.text!)){
            warningLabel.isHidden = true;
            phoneWarningLabel.isHidden = false
            return
        }
        
        //create the new user in our database
        let parameters: Parameters = [
            "email": Data.sharedInstance.userData[0],
            "first_name": firstNameField.text!,
            "last_name": lastNameField.text!,
            "phone": phoneField.text!,
            "year": year!
        ]
        
        self.sessionManager.adapter = AccessTokenAdapter(accessToken: Data.sharedInstance.accessToken!)
        self.sessionManager.request(self.REGISTER_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    //save the data
                    Data.sharedInstance.userData.append(self.firstNameField.text!)
                    Data.sharedInstance.userData.append(self.lastNameField.text!)
                    Data.sharedInstance.userData.append(self.phoneField.text!)
                    //self.userData.append(self.emailPassedOver!)
                    //self.userData.append(self.firstNameField.text!)
                    //self.userData.append(self.lastNameField.text!)
                    //self.userData.append(self.phoneField.text!)
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goFromRegToHome", sender: self)
                    }
                case 400:
                    self.warningLabel.isHidden = true
                    self.phoneWarningLabel.isHidden = true
                    self.errorLabel.isHidden = false
                default:
                    print("Default \(status)")
                }
            }
        }
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goFromRegToHome"{
//            let barController = segue.destination as! UITabBarController
//            let destinationVC = barController.viewControllers![0] as! HomeViewController
//            destinationVC.userData = self.userData
//            //destinationVC.accessToken = self.accessToken
//        }
//    }
}
