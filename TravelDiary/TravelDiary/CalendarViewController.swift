//
//  CalendarViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Calendar components
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
    
    @IBOutlet weak var nextPost: UIButton!
    @IBOutlet weak var lastPost: UIButton!
    
    let postController = PostController.postController
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var allPostDate = [String]()
    var displayedYear = Calendar.current.component(.year, from: Date())
    var displayedMonth = Calendar.current.component(.month, from: Date())
    var dateSelected = String()
    var currentDay = Date()
    var color: UIColor?
    
    var currentDayIndex = 0
    var dayPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let colorT = ColorTheme()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colorT.noflashWhite]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(goToToday))
        dateView.dataSource = self
        dateView.delegate = self
        setupCalendar()
        detailView.isHidden = true
        let tapOnDetail = UITapGestureRecognizer(target: self, action: #selector(showDetail))
        detailView.addGestureRecognizer(tapOnDetail)
        nextPost.isHidden = true
        lastPost.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllPostsDate()
        setupCalendar()
    }

    // MARK: - Data source
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
        cell.dotView.isHidden = true
        if indexPath.row < (weekDayOf1st - 1) {
            cell.dateLabel.text = ""
        } else {
            cell.dateLabel.text = "\(indexPath.row + 2 - weekDayOf1st)"
            for date in allPostDate {
                if date == self.getSelectedDate(indexPath) {
                    cell.dotView.isHidden = false
                }
            }
        }
        
        let format = DateFormatter()
        format.dateFormat = "MM/d/yyyy"
        let dateString = format.string(from: currentDay)
        if dateString == self.getSelectedDate(indexPath) {
             cell.dateLabel.textColor = .red
        } else {
            cell.dateLabel.textColor = .orange
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        nextPost.isHidden = true
        lastPost.isHidden = true
        
        var _dayPost = [Post]()
        for i in 0..<allPostDate.count {
            let date = self.getSelectedDate(indexPath)
            if allPostDate[i] == date {
                _dayPost.append(postController.posts[i])
            }
        }
        dayPosts = _dayPost
        
        currentDayIndex = 0
        
        if dayPosts.count != 0 {
            populateViewWith(dayPosts[currentDayIndex])
            if dayPosts.count > 1 {
                nextPost.isHidden = false
                lastPost.isHidden = true
            } else if dayPosts.count == 1 {
                nextPost.isHidden = true
                lastPost.isHidden = true
            }
        } else {
            detailView.isHidden = true
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
        detailView.isHidden = true
        nextPost.isHidden = true
        lastPost.isHidden = true
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        displayedMonth += 1
        if displayedMonth == 13 {
            displayedYear += 1
            displayedMonth = 1
        }
        setupCalendar()
        detailView.isHidden = true
        nextPost.isHidden = true
        lastPost.isHidden = true
    }
    
    @objc func goToToday() {
        displayedYear = Calendar.current.component(.year, from: Date())
        displayedMonth = Calendar.current.component(.month, from: Date())
        setupCalendar()
    }
    
    @IBAction func moveToNextPost(_ sender: Any) {
        guard currentDayIndex + 1 < dayPosts.count else { return }
        currentDayIndex += 1
        populateViewWith(dayPosts[currentDayIndex])
        // This is the last one today
        if currentDayIndex == dayPosts.count - 1 {
            nextPost.isHidden = true
            lastPost.isHidden = false
        } else {
            nextPost.isHidden = false
            lastPost.isHidden = false
        }
        
    }
    
    @IBAction func moveBackToLastPost(_ sender: Any) {
        guard currentDayIndex - 1 >= 0 else { return }
        currentDayIndex -= 1
        populateViewWith(dayPosts[currentDayIndex])
        // This is the first one today
        if currentDayIndex == 0 {
            nextPost.isHidden = false
            lastPost.isHidden = true
        } else {
            nextPost.isHidden = false
            lastPost.isHidden = false
        }
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
        } else {
            imageWidth.constant = 0
        }
    }
    
    @objc func showDetail() {
        let postView = storyboard!.instantiateViewController(withIdentifier: Constant.StoryBoardID.postView)
        let singleView = postView.children[0] as! PostViewController
        singleView.closureBlock =  {self.dismiss(animated: true, completion: nil)}
        singleView.segueType = "My"
        singleView.postToShow = dayPosts[currentDayIndex]
        self.present(postView, animated: true, completion: nil)
    }
    
    func findPostByDate() {
        
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
