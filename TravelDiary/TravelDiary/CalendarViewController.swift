//
//  CalendarViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var nextMonthButton: DesignableButton!
    @IBOutlet weak var backMonthButton: DesignableButton!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var dateView: UICollectionView!
    // MARK: - Detail view
    @IBOutlet weak var detailView: DesignableView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    let postController = PostController.postController
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var allPostDate = [String]()
    var displayedYear = Calendar.current.component(.year, from: Date())
    var displayedMonth = Calendar.current.component(.month, from: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        dateView.dataSource = self
        dateView.delegate = self
        setupCalendar()
        detailView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllPostsDate()
//        dateView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfDays() + self.getWeekDay() - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier:
                Constant.CellIdentifier.dateCell, for: indexPath) as! DateCollectionViewCell
        let weekDayOf1st = self.getWeekDay()
        cell.dateLabel.layer.borderWidth = 0
        cell.dateLabel.layer.borderColor = UIColor.gray.cgColor
        if indexPath.row < (weekDayOf1st - 1) {
            cell.dateLabel.text = ""
        } else {
            cell.dateLabel.text = "\(indexPath.row + 2 - weekDayOf1st)"
            for date in allPostDate {
                if date == self.getSelectedDate(indexPath) {
                    cell.dateLabel.layer.borderWidth = 2.0
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<allPostDate.count {
            if allPostDate[i] == self.getSelectedDate(indexPath) {
                populateViewWith(postController.posts[i])
                break
            } else {
                detailView.isHidden = true
            }
        }
    }
    
    // MARK: - Buttons
    @IBAction func backPressed(_ sender: Any) {
        displayedMonth -= 1
        if displayedMonth == 0 {
            displayedYear -= 1
            displayedMonth = 12
        }
        setupCalendar()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        displayedMonth += 1
        if displayedMonth == 13 {
            displayedYear += 1
            displayedMonth = 1
        }
        setupCalendar()
    }
    
    
    
    // MARK: - Helpers
    func setupCalendar() {
        let displayText = months[displayedMonth - 1] + " \(displayedYear)"
        monthYearLabel.text = displayText
        self.dateView.reloadData()
    }
    
    // Get the number of days in a month
    func numberOfDays() -> Int {
        let dateComponents = DateComponents(year: displayedYear, month: displayedMonth)
        let date = Calendar.current.date(from: dateComponents)!
        let range = Calendar.current.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }
    
    // Get the weekday at which a month start with
    func getWeekDay() -> Int {
        let dateComponents = DateComponents(year: displayedYear, month: displayedMonth)
        let date = Calendar.current.date(from: dateComponents)!
        return Calendar.current.component(.weekday, from: date)
    }
    
    func getSelectedDate(_ indexPath: IndexPath) -> String {
        let startDay = self.getWeekDay()
        let dateToday = indexPath.row - startDay + 2
        let dateString = "\(displayedMonth)/\(dateToday)/\(displayedYear)"
        return dateString
    }
    
    func getAllPostsDate() {
        var _allPostsDate = [String]()
        for post in postController.posts {
            if let postDate = post.time {
                let format = DateFormatter()
                format.dateFormat = "MM/d/yyyy"
                let postDateString = format.string(from: postDate)
                _allPostsDate.append(postDateString)
            }
        }
        self.allPostDate = _allPostsDate
    }
    
    func populateViewWith(_ post: Post) {
        detailView.isHidden = false
        textField.text = post.text ?? ""
        if let weather = post.weather {
            weatherImage.image = UIImage(named: weather)
            weatherLabel.text = weather
        }
        if let steps = post.steps {
            stepLabel.text = steps
        }
        if let imageData = post.image {
            if imageData.description == "0 bytes" {
                imageWidth.constant = 0
            } else {
                imageWidth.constant = 134
                imageView.image = ImageManager.shared.convertToImage(data: imageData)
            }
            
        }
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7.0
        let itemSize = CGSize(width: width, height: 50.0)
        return itemSize
    }
}
