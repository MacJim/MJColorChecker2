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
        
        //TODO: Restore last color from user defaults.
        currentColorMode = .rgb
        currentColor = UIColor.white
        
        updateViewBackgroundColor()
        
        updateElementsVisibility()
        updateSliderValuesFromCurrentColor()
        updateLabelTextFromSliderValues()
    }
    
    
    //MARK: UIResponder stuff
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            if (firstTouch.tapCount == 2) {
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
        updateViewBackgroundColor()
    }
    
    @IBAction func colorModeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        currentColorMode = ColorMode(rawValue: sender.selectedSegmentIndex)
        updateElementsVisibility()
        updateSliderValuesFromCurrentColor()
        updateLabelTextFromSliderValues()
    }
    
    
    //MARK: - Current color
    var currentColor: UIColor!
    var currentColorMode: ColorMode!
    
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
    
    func updateViewBackgroundColor() {
        self.view.backgroundColor = currentColor
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
}

