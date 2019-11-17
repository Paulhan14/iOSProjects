//
//  EditViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class EditViewController: UIViewController {

    // MARK: - UI Components
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    // MARK: - Tool Bar
    var controlToolBar: UIToolbar?
    var controlTooBarContainer: UIView?
    // MARK: - Info Views
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var stepImage: UIImageView!
    // MARK: - Support Views
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imagesView: UIView!
    
    
    
    var closureBlock : (() -> Void)?
    var editingPost = postParameters()
    var draft = PostController.postController.draft
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if draft != nil {
            textField.text = draft?.text
        }
        setupKeyboardAccessory()
        loadSetup()
        textField.inputAccessoryView = controlToolBar
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Handler
    @IBAction func cancelButtonPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let discard = UIAlertAction(title: "Discard", style: .destructive) { (action) in
            // Delete the draft
            PostController.postController.deleteDraft()
            // dismiss the view
            if let block = self.closureBlock {
                block()
            }
        }
        let save = UIAlertAction(title: "Save Draft", style: .default) { (action) in
            // Create a new draftMO using the editing post
            self.prepareForClosing()
            PostController.postController.createDraft(self.editingPost)
            // Dismiss the view
            if let block = self.closureBlock {
                block()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(save)
        actionSheet.addAction(discard)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        // Create a new MO using the editing post
        self.prepareForClosing()
        PostController.postController.createPost(self.editingPost)
        PostController.postController.deleteDraft()
        // Dismiss the view
        if let block = closureBlock {
            block()
        }
    }
    
    @objc func dismissKeyboard() {
        textField.endEditing(true)
    }
    
    @objc func openLocationSearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchNavi = storyboard.instantiateViewController(
            withIdentifier: Constant.StoryBoardID.locationSearchView)
        let searchView = searchNavi.children.first! as! LocationSearchViewController
        searchView.closureBlock = {self.dismiss(animated: true, completion: nil)}
        searchNavi.modalPresentationStyle = .overFullScreen
        self.present(searchNavi, animated: true) {
            //
        }
        
    }
    
    // MARK: - Helper
    func prepareForClosing() {
        editingPost.text = textField.text
    }
    
    func setupKeyboardAccessory() {
        controlToolBar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.width, height: 50)))
        var flexibles = [UIBarButtonItem]()
        for _ in 0..<6{
            let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            flexibles.append(flexible)
        }
        let place = UIBarButtonItem(title: "Place", style: .plain, target: self, action: #selector(openLocationSearch))
        let photo = UIBarButtonItem(title: "Photo", style: .plain, target: self, action: nil)
        let weather = UIBarButtonItem(title: "Weather", style: .plain, target: nil, action: nil)
        let steps = UIBarButtonItem(title: "Steps", style: .plain, target: nil, action: nil)
        let key = UIBarButtonItem(title: "V", style: .plain, target: self, action: #selector(dismissKeyboard))
        controlToolBar!.setItems([flexibles[0], place, flexibles[1], photo, flexibles[2], weather, flexibles[3], steps, flexibles[4], key, flexibles[5]], animated: false)
        controlToolBar!.sizeToFit()
        controlToolBar!.backgroundColor = .orange
    }
    
    func loadSetup() {
        self.textField.text = "Write something about your day..."
        self.textField.textColor = .gray
    }
    
    override var canBecomeFirstResponder: Bool { get { return true } }
    override var inputAccessoryView: UIView? {
        get {
            if self.controlTooBarContainer == nil {
                let barFrame = self.controlToolBar!.frame
                let frame = CGRect(origin: CGPoint(x: barFrame.minX, y: barFrame.minY), size: CGSize(width: barFrame.width, height: barFrame.height + self.view.safeAreaInsets.bottom))
                self.controlTooBarContainer = UIView(frame: frame)
            }
            if self.controlToolBar!.superview != self.controlTooBarContainer {
                self.controlToolBar!.translatesAutoresizingMaskIntoConstraints = true
                self.controlTooBarContainer!.addSubview(self.controlToolBar!)
            }
            return self.controlTooBarContainer
        }
    }
}

extension EditViewController {
    //Mark: - Notification Handlers
    @objc func keyboardWillShow(notification:Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        // Handle scroll
        let contentInsets =  UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + controlToolBar!.bounds.height, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        let selectedRange = self.textField.selectedRange
        self.textField.scrollRangeToVisible(selectedRange)
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
    }
}
