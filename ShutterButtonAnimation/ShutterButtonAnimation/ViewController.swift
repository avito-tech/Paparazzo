import UIKit
import JNWSpringAnimation

class ViewController: UIViewController {
    
    @IBOutlet weak var minScaleSlider: UISlider!
    @IBOutlet weak var minScaleLabel: UILabel!
    @IBOutlet weak var dampingSlider: UISlider!
    @IBOutlet weak var dampingLabel: UILabel!
    @IBOutlet weak var stiffnessSlider: UISlider!
    @IBOutlet weak var stiffnessLabel: UILabel!
    @IBOutlet weak var massSlider: UISlider!
    @IBOutlet weak var massLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.backgroundColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
        button.layer.cornerRadius = 32
        button.addTarget(
            self,
            action: #selector(ViewController.onShutterButtonTouchDown(_:)),
            forControlEvents: .TouchDown
        )
        button.addTarget(
            self,
            action: #selector(ViewController.onShutterButtonTouchUp(_:)),
            forControlEvents: .TouchUpInside
        )
        
        [minScaleSlider, dampingSlider, stiffnessSlider, massSlider].forEach { slider in
            
            adjustValueTextForSlider(slider)
            
            slider.addTarget(
                self,
                action: #selector(ViewController.onSliderValueChange(_:)),
                forControlEvents: .ValueChanged
            )
        }
    }
    
    func onSliderValueChange(slider: UISlider) {
        adjustValueTextForSlider(slider)
    }
    
    func adjustValueTextForSlider(slider: UISlider) {
        labelForSlider(slider).text = String(slider.value)
    }
    
    func labelForSlider(slider: UISlider) -> UILabel! {
        switch slider {
        case minScaleSlider:
            return minScaleLabel
        case dampingSlider:
            return dampingLabel
        case stiffnessSlider:
            return stiffnessLabel
        case massSlider:
            return massLabel
        default:
            return nil
        }
    }
    
    func onShutterButtonTouchDown(button: UIButton) {
        animateShutterButtonToScale(CGFloat(minScaleSlider.value))
    }
    
    func onShutterButtonTouchUp(button: UIButton) {
        animateShutterButtonToScale(1)
    }
    
    func animateShutterButtonToScale(scale: CGFloat) {
        
        let keyPath = "transform.scale"
        
        let animation = JNWSpringAnimation(keyPath: keyPath)
        animation.damping = CGFloat(dampingSlider.value)
        animation.stiffness = CGFloat(stiffnessSlider.value)
        animation.mass = CGFloat(massSlider.value)
        
        let presentationLayer = button.layer.presentationLayer()
        let layer = presentationLayer ?? button.layer
        
        animation.fromValue = layer.valueForKeyPath(keyPath)
        animation.toValue = scale
        
        button.layer.setValue(animation.toValue, forKeyPath: keyPath)
        
//        print("animate scale from \(animation.fromValue) to \(animation.toValue)")
        
        button.layer.addAnimation(animation, forKey: keyPath)
    }
}

