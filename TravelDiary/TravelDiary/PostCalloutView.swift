//
//  PostCalloutView.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/13/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//
import UIKit
import MapKit

/// Callout that shows title and subtitle
///
/// This is concrete subclass of `CalloutView` that has two labels. Note, to
/// have the callout resized appropriately, all this class needed to do was
/// update is the constraints between these two labels (which have intrinsic
/// sizes based upon the text contained therein) and the `contentView`.
/// Autolayout takes care of everything else.
///
/// Note, I've added observers for the `title` and `subtitle` properties of
/// the annotation view. Generally you don't need to worry about that, but it
/// can be useful if you're retrieving details about the annotation asynchronously
/// but you want to show the pin while that's happening. You just want to make sure
/// that when the annotation's relevant properties are retrieved, that we update
/// this callout view (if it's being shown at all).

class PostCalloutView: CustomCalloutView {
    
    // Date
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .preferredFont(forTextStyle: .callout)
        
        return label
    }()
    
    // Post Content
    private var textField: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textColor = .black
        text.backgroundColor = UIColor.white
        text.font = UIFont.preferredFont(forTextStyle: .callout)
        
        return text
    }()
    
    // Post image
    private var imageView: UIImageView = {
        let imageHolder = UIImageView()
        imageHolder.isUserInteractionEnabled = false
        imageHolder.contentMode = UIView.ContentMode.scaleAspectFill
        imageHolder.backgroundColor = UIColor.white
        
        return imageHolder
    }()
    
    override init(annotation: MKAnnotation) {
        super.init(annotation: annotation)
        configure()
        updateContents(for: annotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Should not call init(coder:)")
    }
    
    /// Update callout contents
    private func updateContents(for annotation: MKAnnotation) {
        let customAnnotation = annotation as! PostAnnotation
        let post = customAnnotation.post
        let format = DateFormatter()
        format.dateFormat = "MM/d/yyyy"
        let postDateString = format.string(from: post.time!)
        dateLabel.text = postDateString
        textField.text = post.text
        if post.image == nil || post.image?.description == "0 bytes" {
            let newSize = CGSize(width: 0.0, height: imageView.frame.height)
            imageView.frame.size = newSize
        } else {
            imageView.image = ImageManager.shared.convertToImage(data: post.image!)
        }
    }
    
    /// Add constraints for subviews of `contentView`
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(textField)
        
        let views: [String: UIView] = [
            "dateLabel": dateLabel,
            "imageView": imageView,
            "textField": textField
        ]
        
        var allConstraints: [NSLayoutConstraint] = []
        
        let dateVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[dateLabel(25)]",
            metrics: nil,
            views: views)
        allConstraints += dateVerticalConstraints
        
        let textVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[dateLabel]-5-[textField(60)]",
            metrics: nil,
            views: views)
        allConstraints += textVerticalConstraints
        
        let imageVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[dateLabel]-5-[imageView(60)]",
            metrics: nil,
            views: views)
        allConstraints += imageVerticalConstraints
        
        let topRowHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-5-[dateLabel]-5-|",
            metrics: nil,
            views: views)
        allConstraints += topRowHorizontalConstraints
        
        let downRowHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-5-[imageView(80)]-5-[textField(80)]-5-|",
            metrics: nil,
            views: views)
        allConstraints += downRowHorizontalConstraints
        
        contentView.addConstraints(allConstraints)
    }
    
    // This is an example method, defined by `CalloutView`, which is called when you tap on the callout
    // itself (but not one of its subviews that have user interaction enabled).
    
    override func didTouchUpInCallout(_ sender: Any) {
        print("didTouchUpInCallout")
    }
    
    /// Map view
    ///
    /// Navigate up view hierarchy until we find `MKMapView`.
    
    var mapView: MKMapView? {
        var view = superview
        while view != nil {
            if let mapView = view as? MKMapView { return mapView }
            view = view?.superview
        }
        return nil
    }
}

