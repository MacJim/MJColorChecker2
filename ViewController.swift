//
//  ViewController.swift
//  MJColorChecker2
//
//  Created by Jim Macintosh Shi on 5/27/19.
//  Copyright © 2019 Creative Sub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: - View presenting stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set monospace system font.
        hexValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: hexValueLabel.font.pointSize, weight: UIFont.Weight.regular)
        valueLabel1.font = UIFont.monospacedDigitSystemFont(ofSize: valueLabel1.font.pointSize, weight: UIFont.Weight.regular)
        valueLabel2.font = UIFont.monospacedDigitSystemFont(ofSize: valueLabel2.font.pointSize, weight: UIFont.Weight.regular)
        valueLabel3.font = UIFont.monospacedDigitSystemFont(ofSize: valueLabel3.font.pointSize, weight: UIFont.Weight.regular)
        valueLabel4.font = UIFont.monospacedDigitSystemFont(ofSize: valueLabel4.font.pointSize, weight: UIFont.Weight.regular)
        
        //Restore last color from user defaults.
        loadSavedColor()
        
        updateViewBackgroundColor()
        
        colorModeSegmentedControl.selectedSegmentIndex = currentColorMode.rawValue
        updateElementsVisibility()
        updateSliderValuesFromCurrentColor()
        updateLabelTextFromSliderValues()
        updateHexValueLabelTextFromCurrentColor()
    }
    
    
    //MARK: UIResponder stuff
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            if (firstTouch.tapCount % 2 == 0) {
                //If the user double taps at the same place for multiple times, they will be considered as a single touch.
                if (isInPreviewMode) {
                    isInPreviewMode = false
                } else {
                    isInPreviewMode = true
                }
                updateElementsVisibility()
            }
        }
    }
    
    
    //MARK: - IB Outlets
    @IBOutlet weak var hexValueLabel: UILabel!
    @IBOutlet weak var copyHexValueButton: UIButton!
    @IBOutlet weak var editHexValueButton: UIButton!
    
    @IBOutlet weak var valueLabel1: UILabel!
    @IBOutlet weak var valueLabel2: UILabel!
    @IBOutlet weak var valueLabel3: UILabel!
    @IBOutlet weak var valueLabel4: UILabel!
    
    @IBOutlet weak var valueSlider1: UISlider!
    @IBOutlet weak var valueSlider2: UISlider!
    @IBOutlet weak var valueSlider3: UISlider!
    @IBOutlet weak var valueSlider4: UISlider!
    
    @IBOutlet weak var editButton1: UIButton!
    @IBOutlet weak var editButton2: UIButton!
    @IBOutlet weak var editButton3: UIButton!
    @IBOutlet weak var editButton4: UIButton!
    
    @IBOutlet weak var colorModeSegmentedControl: UISegmentedControl!
    
    
    //MARK: - IB Actions
    @IBAction func valueSlidersValueChanged(_ sender: UISlider) {
        updateCurrentColorFromSliders()
        updateLabelTextFromSliderValues()
        updateHexValueLabelTextFromCurrentColor()
        updateViewBackgroundColor()
    }
    
    @IBAction func colorModeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        currentColorMode = ColorMode(rawValue: sender.selectedSegmentIndex)
        updateElementsVisibility()
        updateSliderValuesFromCurrentColor()
        updateLabelTextFromSliderValues()
    }
    
    @IBAction func copyHexValueButtonPressed(_ sender: UIButton) {
        UIPasteboard.general.string = hexValueLabel.text
    }
    
    @IBAction func editHexValueButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New hex value?", message: "Current value: " + hexValueLabel.text!, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: {
            textField in
            textField.text = "#"
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [self, weak alertController] (_) in
            let textField = alertController?.textFields![0]
            self.setCurrentColor(hexValueString: textField?.text)
            self.updateViewBackgroundColor()
            self.updateSliderValuesFromCurrentColor()
            self.updateLabelTextFromSliderValues()
            self.updateHexValueLabelTextFromCurrentColor()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - Current color
    var currentColor: UIColor!
    var currentColorMode: ColorMode!
    
    func setCurrentColor(r: CGFloat?, g: CGFloat?, b: CGFloat?) {
        var newR: CGFloat = 0
        var newG: CGFloat = 0
        var newB: CGFloat = 0
        currentColor.getRed(&newR, green: &newG, blue: &newB, alpha: nil)
        
        if let r = r {
            newR = r
        }
        if let g = g {
            newG = g
        }
        if let b = b {
            newB = b
        }
        
        currentColor = UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
    }
    
    func setCurrentColor(h: CGFloat?, s: CGFloat?, b: CGFloat?) {
        var newH: CGFloat = 0
        var newS: CGFloat = 0
        var newB: CGFloat = 0
        currentColor.getHue(&newH, saturation: &newS, brightness: &newB, alpha: nil)
        
        if let h = h {
            newH = h
        }
        if let s = s {
            newS = s
        }
        if let b = b {
            newB = b
        }
        
        currentColor = UIColor(hue: newH, saturation: newS, brightness: newB, alpha: 1.0)
    }
    
    /**
     * - Parameter hexValueString: "#FFFFFF" or "FFFFFF".
     */
    func setCurrentColor(hexValueString: String?) {
        guard let hexValueString = hexValueString else {
            return
        }
        
        let sanitizedHexString = hexValueString.replacingOccurrences(of: "#", with: "")
        guard (sanitizedHexString.count == 6) else {
            return
        }
        
        var rgbValue: UInt32 = 0
        guard Scanner(string: sanitizedHexString).scanHexInt32(&rgbValue) else {
            return
        }
        
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        setCurrentColor(r: r, g: g, b: b)
    }
    
    func updateViewBackgroundColor() {
        self.view.backgroundColor = currentColor
    }
    
    
    //MARK: - Sliders
    func updateCurrentColorFromSliders() {
        switch (currentColorMode!) {
        case .hsb:
            let h = CGFloat(valueSlider2.value)
            let s = CGFloat(valueSlider3.value)
            let b = CGFloat(valueSlider4.value)
            currentColor = UIColor(hue: h, saturation: s, brightness: b, alpha: 1.0)
            
        default:    //Default color mode is RGB
            let r = CGFloat(valueSlider2.value)
            let g = CGFloat(valueSlider3.value)
            let b = CGFloat(valueSlider4.value)
            currentColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        }
    }
    
    func updateSliderValuesFromCurrentColor() {
        switch (currentColorMode!) {
        case .hsb:
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            currentColor.getHue(&h, saturation: &s, brightness: &b, alpha: nil)
            
            valueSlider2.value = Float(h)
            valueSlider3.value = Float(s)
            valueSlider4.value = Float(b)
            
        default:    //Default color mode is RGB
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            currentColor.getRed(&r, green: &g, blue: &b, alpha: nil)
            
            valueSlider2.value = Float(r)
            valueSlider3.value = Float(g)
            valueSlider4.value = Float(b)
        }
    }
    
    
    //MARK: - Labels
    func updateLabelTextFromSliderValues() {
        switch (currentColorMode!) {
        case .hsb:
            let h = CGFloat(valueSlider2.value)
            let s = CGFloat(valueSlider3.value)
            let b = CGFloat(valueSlider4.value)
            
            valueLabel2.text = "H: \(h * 360.0)°"
            valueLabel3.text = "S: \(s * 100.0)%"
            valueLabel4.text = "B: \(b * 100.0)%"
            
        default:    //Default color mode is RGB
            let r = CGFloat(valueSlider2.value)
            let g = CGFloat(valueSlider3.value)
            let b = CGFloat(valueSlider4.value)
            
            valueLabel2.text = "R: \(r * 255.0)"
            valueLabel3.text = "G: \(g * 255.0)"
            valueLabel4.text = "B: \(b * 255.0)"
        }
    }
    
    
    //MARK: - HEX value label
    func updateHexValueLabelTextFromCurrentColor() {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        currentColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        let rInt = Int(round(Double(r * 255.0)))
        let gInt = Int(round(Double(g * 255.0)))
        let bInt = Int(round(Double(b * 255.0)))
        
        /*
         * % defines the format specifier
         * 02 defines the length of the string
         * l casts the value to an unsigned long
         * X prints the value in hexadecimal (0-9 and A-F)
         */
        hexValueLabel.text = String(format: "#%02lX%02lX%02lX", rInt, gInt, bInt)
    }
    
    
    //MARK: - Elements visibility
    override var prefersStatusBarHidden: Bool {
        if (isInPreviewMode) {
            return true
        } else {
            return false
        }
    }
    
    /**
     * Double tap to enter preview mode.
     *
     * In this mode, every element on screen is hidden.
     */
    var isInPreviewMode = false
    func updateElementsVisibility() {
        setNeedsStatusBarAppearanceUpdate()
        
        if (isInPreviewMode) {
            hexValueLabel.isHidden = true
            copyHexValueButton.isHidden = true
            editHexValueButton.isHidden = true
            
            valueLabel1.isHidden = true
            valueLabel2.isHidden = true
            valueLabel3.isHidden = true
            valueLabel4.isHidden = true
            
            valueSlider1.isHidden = true
            valueSlider2.isHidden = true
            valueSlider3.isHidden = true
            valueSlider4.isHidden = true
            
            editButton1.isHidden = true
            editButton2.isHidden = true
            editButton3.isHidden = true
            editButton4.isHidden = true
            
            colorModeSegmentedControl.isHidden = true
        } else {
            hexValueLabel.isHidden = false
            copyHexValueButton.isHidden = false
            editHexValueButton.isHidden = false
            
            valueLabel2.isHidden = false
            valueLabel3.isHidden = false
            valueLabel4.isHidden = false
            
            valueSlider2.isHidden = false
            valueSlider3.isHidden = false
            valueSlider4.isHidden = false
            
            editButton2.isHidden = false
            editButton3.isHidden = false
            editButton4.isHidden = false
            
            colorModeSegmentedControl.isHidden = false
            
            if (currentColorMode == .cmyk) {
                editButton1.isHidden = false
                valueSlider1.isHidden = false
                valueLabel1.isHidden = false
            } else {
                editButton1.isHidden = true
                valueSlider1.isHidden = true
                valueLabel1.isHidden = true
            }
        }
    }
    
    
    //MARK: - Data persistence
    func saveCurrentColor() {
        let userDefaults = UserDefaults.standard
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        currentColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        userDefaults.set(r, forKey: "CurrentColorRed")
        userDefaults.set(g, forKey: "CurrentColorGreen")
        userDefaults.set(b, forKey: "CurrentColorBlue")
        
        userDefaults.set(currentColorMode!.rawValue, forKey: "CurrentColorMode")
    }
    
    /**
     * - Note: This method will NOT update the view background color.
     */
    func loadSavedColor() {
        let userDefaults = UserDefaults.standard
        
        if let r = userDefaults.object(forKey: "CurrentColorRed") as? CGFloat, let g = userDefaults.object(forKey: "CurrentColorGreen") as? CGFloat, let b = userDefaults.object(forKey: "CurrentColorBlue") as? CGFloat {
            currentColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            currentColor = UIColor.white
        }
        
        let savedColorModeRawValue = userDefaults.integer(forKey: "CurrentColorMode")    //Default is 0 (RGB)
        currentColorMode = ColorMode(rawValue: savedColorModeRawValue)
    }
}

