//
//  HelpController.swift
//  Word Flakes
//


import UIKit

class HelpController: UIViewController {
    
    //var mainController : MainController!
    var menuController : MenuController!

    @IBOutlet weak var textView: UITextView!
   
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func viewDidLayoutSubviews() {
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        EffectsController.formatButton(b:closeButton, orange: true)
        
        let attrs1 : [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "Noteworthy-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        var attriburedString = NSMutableAttributedString(string:textView.text, attributes: attrs1)
        
        attriburedString = insertImage(str: attriburedString, img: "Submit", imgscale: 40, replaced: "PP")
        attriburedString = insertImage(str: attriburedString, img: "snowflake", imgscale: 7, replaced: "NN")
        attriburedString = insertImage(str: attriburedString, img: "Backspace", imgscale: 12, replaced: "BB")
        attriburedString = insertImage(str: attriburedString, img: "question", imgscale: 30, replaced: "WW")
        attriburedString = insertImage(str: attriburedString, img: "BriefCase", imgscale: 50, replaced: "FF")
        attriburedString = insertImage(str: attriburedString, img: "goldball", imgscale: 15, replaced: "GG")
        attriburedString = insertImage(str: attriburedString, img: "bomb2", imgscale: 55, replaced: "SS")
        attriburedString = insertImage(str: attriburedString, img: "Pause", imgscale: 15, replaced: "AA")
        attriburedString = insertImage(str: attriburedString, img: "redPB", imgscale: 15, replaced: "RR")
        attriburedString = insertImage(str: attriburedString, img: "yellowPB", imgscale: 15, replaced: "YY")
        textView.attributedText = attriburedString
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        EffectsController.easySound(m:menuController.mainController)
        self.dismiss(animated:true, completion: {})
    }

    @IBAction func closeButtonTouched(_ sender: UIButton) {
        
        EffectsController.animateButtonPress(sender)
        
    }
    
    func insertImage(str : NSMutableAttributedString, img: String, imgscale: CGFloat, replaced : String) -> NSMutableAttributedString{
   
        let snowflake = NSTextAttachment()
        snowflake.image = UIImage(named: img)
        snowflake.image = UIImage(cgImage: snowflake.image!.cgImage!, scale: imgscale, orientation: .up)
        let attachmentString = NSAttributedString(attachment: snowflake)
        
        let s = str.string as NSString
        let r = s.range(of: replaced)

        str.replaceCharacters(in: r, with: attachmentString)

        return str
   }
}
