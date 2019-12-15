//
//  CustomCalloutView.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/13/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class CustomCalloutView: UIView {
    
    /// The annotation for which this callout has been created.
    weak var annotation: MKAnnotation?
    
    /// Shape of pointer at the bottom of the callout bubble
    enum BubblePointerType {
        case rounded
        case straight(angle: CGFloat)
    }
    
    /// Shape of pointer at bottom of the callout bubble, pointing at annotation view.
    private let bubblePointerType = BubblePointerType.rounded
    
    /// Insets for rounding of callout bubble's corners
    private let inset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
    
    /// Shape layer for callout bubble
    private let bubbleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.borderColor = UIColor.orange.cgColor
        layer.borderWidth = 2
        layer.fillColor = UIColor.white.cgColor
        layer.lineWidth = 0.5
        return layer
    }()
    
    /// Content view for annotation callout view
    let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    init(annotation: MKAnnotation) {
        self.annotation = annotation
        
        super.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configure the view.
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: inset.top / 2.0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.bottom - inset.right / 2.0),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: inset.left / 2.0),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset.right / 2.0),
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: inset.left + inset.right),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: inset.top + inset.bottom)
            ])
        
        addBackgroundButton(to: contentView)
        
        layer.insertSublayer(bubbleLayer, at: 0)
    }
    
    // if the view is resized, update the path for the callout bubble
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updatePath()
    }
    
    // Override hitTest to detect taps within our callout bubble
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let contentViewPoint = convert(point, to: contentView)
        return contentView.hitTest(contentViewPoint, with: event)
    }
    
    /// Update `UIBezierPath` for callout bubble
    private func updatePath() {
        let path = UIBezierPath()
        var point: CGPoint = CGPoint(x: bounds.size.width - inset.right, y: bounds.size.height - inset.bottom)
        var controlPoint: CGPoint
        
        path.move(to: point)
        
        switch bubblePointerType {
        case .rounded:
            // lower right
            point = CGPoint(x: bounds.size.width / 2.0 + inset.bottom, y: bounds.size.height - inset.bottom)
            path.addLine(to: point)

            // right side of arrow

            controlPoint = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height - inset.bottom)
            point = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height)
            path.addQuadCurve(to: point, controlPoint: controlPoint)

            // left of pointer

            controlPoint = CGPoint(x: point.x, y: bounds.size.height - inset.bottom)
            point = CGPoint(x: point.x - inset.bottom, y: controlPoint.y)
            path.addQuadCurve(to: point, controlPoint: controlPoint)

        case .straight(let angle):
            // lower right
            point = CGPoint(x: bounds.size.width / 2.0 + tan(angle) * inset.bottom, y: bounds.size.height - inset.bottom)
            path.addLine(to: point)

            // right side of arrow
            point = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height)
            path.addLine(to: point)

            // left of pointer
            point = CGPoint(x: bounds.size.width / 2.0 - tan(angle) * inset.bottom, y: bounds.size.height - inset.bottom)
            path.addLine(to: point)
        }
        
        // bottom left
        point.x = inset.left
        path.addLine(to: point)
        
        // lower left corner
        controlPoint = CGPoint(x: 0, y: bounds.size.height - inset.bottom)
        point = CGPoint(x: 0, y: controlPoint.y - inset.left)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        // left
        point.y = inset.top
        path.addLine(to: point)
        
        // top left corner
        controlPoint = CGPoint.zero
        point = CGPoint(x: inset.left, y: 0)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        // top
        point = CGPoint(x: bounds.size.width - inset.left, y: 0)
        path.addLine(to: point)
        
        // top right corner
        controlPoint = CGPoint(x: bounds.size.width, y: 0)
        point = CGPoint(x: bounds.size.width, y: inset.top)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        // right
        point = CGPoint(x: bounds.size.width, y: bounds.size.height - inset.bottom - inset.right)
        path.addLine(to: point)
        
        // lower right corner
        controlPoint = CGPoint(x: bounds.size.width, y: bounds.size.height - inset.bottom)
        point = CGPoint(x: bounds.size.width - inset.right, y: bounds.size.height - inset.bottom)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        path.close()
        
        bubbleLayer.path = path.cgPath
    }
    
    // Add this `CalloutView` to an annotation view
    func add(to annotationView: MKAnnotationView) {
        annotationView.addSubview(self)
        // constraints for this callout with respect to its superview
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: annotationView.topAnchor, constant: annotationView.calloutOffset.y),
            centerXAnchor.constraint(equalTo: annotationView.centerXAnchor, constant: annotationView.calloutOffset.x)
            ])
    }
}

// MARK: - Button in the background

extension CustomCalloutView {
    
    // Add a large button to callout
    fileprivate func addBackgroundButton(to view: UIView) {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        button.addTarget(self, action: #selector(didTouchUpInCallout(_:)), for: .touchUpInside)
    }
    
    // Button tapped
    @objc func didTouchUpInCallout(_ sender: Any) {
        // this is intentionally blank
    }
}

