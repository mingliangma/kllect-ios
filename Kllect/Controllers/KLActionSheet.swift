//
//  KLActionSheet.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class KLSheetAction {
    var title:String
    var block:() -> ()
    var icon:UIImage?
    var color:UIColor?
    var sheet:KLActionSheet!
    
    init(title:String, icon:UIImage? = nil, color:UIColor? = nil, block:@escaping () -> ()) {
        self.title = title
        self.block = block
        self.icon = icon
        self.color = color
    }
    
    func button() -> UIButton {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = KLActionSheet.font
        button.setTitleColor(self.color ?? UIColor.darkGray, for: .normal)
        button.setImage(self.icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Color.KLDarkPurple
        button.setTitle(title, for: .normal)
        
        button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
        
        return button
    }
    
    @objc func handleTap() {
        sheet.dismissSheet()
        block()
    }
}

class KLActionSheet: UIViewController {
    
    static let font = UIFont(name: "Colfax-Regular", size: 16)!
    static let leftInset = CGFloat(50)
    static let buttonHeight = CGFloat(65)
    static let separatorThickness = CGFloat(1)
    
    var overlayView:UIView?
    
    let extraPadding = CGFloat(20)
    let paddingOffset = CGFloat(-8)
    
    let sheetContainer = UIView()
    
    private var actions:[KLSheetAction] = []
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        triggerAppearAnimation()
    }
    
    func setup() {
        overlayView = UIView(frame: self.view.bounds)
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView?.alpha = 0
        self.view.addSubview(overlayView!)
        
        sheetContainer.backgroundColor = UIColor.white
        sheetContainer.layer.cornerRadius = 20
        sheetContainer.layer.masksToBounds = true
        let sc_w = self.view.bounds.width
        let sc_h = CGFloat(self.actions.count + 1) * KLActionSheet.buttonHeight + extraPadding
        let sc_x = CGFloat(0)
        let sc_y = self.view.bounds.height
        sheetContainer.frame = CGRect(x: sc_x, y: sc_y, width: sc_w, height: sc_h)
        
        let b_w = self.view.bounds.width
        let b_h = KLActionSheet.buttonHeight
        let b_x = CGFloat(0)
        
        for (index, a) in self.actions.enumerated() {
            let b = a.button()
            let b_y = (extraPadding / 2) + paddingOffset + CGFloat(index) * KLActionSheet.buttonHeight
            let frame = CGRect(x: b_x, y: b_y, width: b_w, height: b_h)
            b.frame = frame
            
            b.contentHorizontalAlignment = .left
            b.imageEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 20)
            b.titleEdgeInsets = UIEdgeInsetsMake(0, KLActionSheet.leftInset, 0, 0)
            
            let s = UIView()
            s.backgroundColor = UIColor(white: 0.8, alpha: 1)
            s.frame = CGRect(x: 0, y: b_h - KLActionSheet.separatorThickness, width: b_w, height: KLActionSheet.separatorThickness)
            b.addSubview(s)
            sheetContainer.addSubview(b)
        }
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.titleLabel?.font = KLActionSheet.font
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.lightGray, for: .normal)
        cancelButton.addTarget(self, action: #selector(KLActionSheet.dismissSheet), for: .touchUpInside)
        cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, KLActionSheet.leftInset + 18, 0, 0)
        let b_y = sheetContainer.bounds.height - KLActionSheet.buttonHeight - (extraPadding / 2) + paddingOffset
        let frame = CGRect(x: 0, y: b_y, width: b_w, height: b_h)
        cancelButton.frame = frame
        self.sheetContainer.addSubview(cancelButton)
        
        self.view.addSubview(sheetContainer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissSheet))
        self.view.addGestureRecognizer(tap)
    }
    
    func triggerAppearAnimation() {
        let anims = {
            self.overlayView?.alpha = 1
            var newFrame = self.sheetContainer.frame
            newFrame.origin.y = self.view.bounds.height - newFrame.size.height + (self.extraPadding / 2) - self.paddingOffset
            self.sheetContainer.frame = newFrame
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: anims, completion: nil)
    }

    func dismissSheet() {
        let anims = {
            self.overlayView?.alpha = 0
            var newFrame = self.sheetContainer.frame
            newFrame.origin.y = self.view.bounds.height
            self.sheetContainer.frame = newFrame
        }
        UIView.animate(withDuration: 0.3, animations: anims) { (completed:Bool) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func addAction(action:KLSheetAction) {
        action.sheet = self
        self.actions.append(action)
    }
    
}









