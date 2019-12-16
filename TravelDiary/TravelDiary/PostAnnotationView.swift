//
//  PostAnnotationView.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/13/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class PostAnnotationView: MKAnnotationView {
    weak var detailViewDelegate: DetailMapViewDelegate?
    weak var detailView: DetailMapView?
    
    override var annotation: MKAnnotation? {
        willSet { detailView?.removeFromSuperview() }
    }
    
    // MARK: - life cycle
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = UIImage(named: "mapPin")!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.image = UIImage(named: "mapPin")!
    }
    
    // MARK: - callout showing and hiding
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.detailView?.removeFromSuperview() // remove old custom callout (if any)
            
            if let newCustomCalloutView = loadDetailMapView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.detailView = newCustomCalloutView
                
                // animate presentation
                if animated {
                    self.detailView!.alpha = 0.0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.detailView!.alpha = 1.0
                    })
                }
            }
        } else {
            if detailView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: 0.3, animations: {
                        self.detailView!.alpha = 0.0
                    }, completion: { (success) in
                        self.detailView!.removeFromSuperview()
                    })
                } else { self.detailView!.removeFromSuperview() }
            }
        }
    }
    
    func loadDetailMapView() -> DetailMapView? {
        if let views = Bundle.main.loadNibNamed("DetailMapView", owner: self, options: nil) as? [DetailMapView], views.count > 0 {
            let detailMapView = views.first!
            detailMapView.delegate = self.detailViewDelegate
            if let postAnnotation = annotation as? PostAnnotation {
                let post = postAnnotation.post
                detailMapView.configureWith(post: post)
            }
            return detailMapView
        }
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.detailView?.removeFromSuperview()
    }
    
    // MARK: - Detecting and reaction to taps on custom callout.
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if detailView != nil {
                return detailView!.hitTest(convert(point, to: detailView!), with: event)
            } else { return nil }
        }
    }
}
