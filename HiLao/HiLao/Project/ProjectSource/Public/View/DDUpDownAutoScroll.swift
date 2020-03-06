//
//  DDUpDownAutoScroll.swift
//  Project
//
//  Created by WY on 2017/12/1.
//  Copyright © 2017年 HHCSZGD. All rights reserved.
//

import UIKit

protocol GDAutoScrollViewActionDelegate : NSObjectProtocol{
    func performAction(model : DDHotComment)
}

//class DDUpDownAutoScrollModel: NSObject {
//
//}

class DDUpDownAutoScroll: UIView , UICollectionViewDelegate , UICollectionViewDataSource{
    enum GDAlignment {
        case center
        case left
        case right
    }
    
    var models  : [DDHuDong] = [DDHuDong](){
        didSet{
            self.collectionView.reloadData()
            stopAutoScroll()
            addTimer()
        }
    }
    weak var delegate : GDAutoScrollViewActionDelegate?
    var timer : Timer?
    
    var collectionView : UICollectionView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareSubviews()
    }
    func addTimer()  {
        self.invalidTimer()
        timer = Timer.init(timeInterval: 5, target: self, selector: #selector(startAutoScroll), userInfo: nil , repeats: true )
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
    }
    func invalidTimer() {
        self.stopAutoScroll()
        if let tempTimer  = timer {
            tempTimer.invalidate()
            timer = nil
        }
    }
    func stopAutoScroll() {
    }
    deinit {
        self.invalidTimer()
    }
//    @objc func startAutoScroll() {
//        guard let flowLayout =  collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
//        let currentContentOffset = collectionView.contentOffset
//        let itemSize = flowLayout.itemSize
//        if currentContentOffset.x >= itemSize.width * CGFloat(models.count) * 2 {
//            collectionView.setContentOffset(CGPoint(x: currentContentOffset.x -  itemSize.width * CGFloat(models.count) , y: 0), animated: false  )
//        }
//        let newCurrentContentOffset = collectionView.contentOffset
//        let nextContentOffset = CGPoint(x:  newCurrentContentOffset.x + itemSize.width, y: 0)
//        //        mylog("当前下标\(currentContentOffset.x / itemSize.width )")
//        collectionView.setContentOffset(nextContentOffset, animated: true )
//    }
    @objc func startAutoScroll() {
        guard let flowLayout =  collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        let currentContentOffset = collectionView.contentOffset
        let itemSize = flowLayout.itemSize
        if currentContentOffset.y >= itemSize.height * CGFloat(models.count) * 2 {
            collectionView.setContentOffset(CGPoint(x: 0 , y: currentContentOffset.y -  itemSize.height * CGFloat(models.count)), animated: false  )
        }
        let newCurrentContentOffset = collectionView.contentOffset
        let nextContentOffset = CGPoint(x:  0, y: newCurrentContentOffset.y + itemSize.height)
        //        mylog("当前下标\(currentContentOffset.x / itemSize.width )")
        collectionView.setContentOffset(nextContentOffset, animated: true )
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.invalidTimer()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.addTimer()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func prepareSubviews() {
        collectionView = UICollectionView.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout.init())
        self.addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(Item.self , forCellWithReuseIdentifier: "GDAutoScrollViewItem")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupCollectionFrame()
    }
    func setupCollectionFrame()  {
        collectionView.frame = self.bounds
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize =  self.collectionView.bounds.size
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return models.count * 3
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actionModel = DDHotComment()
        let dataModel = models[indexPath.item % models.count]
//        actionModel.keyparamete = (dataModel.title ?? "" ) as AnyObject
        self.delegate?.performAction(model: actionModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "GDAutoScrollViewItem", for: indexPath)
        let itemIndex  = indexPath.item % models.count
        if let realItem  = item as? Item {
            realItem.model = models[itemIndex]
//            realItem.label.text = "数组取值时Index : \(itemIndex) ,真实currentIndex : \(indexPath.item)"
            
        }
        //        mylog("数组取值时Index : \(itemIndex)")
        //        mylog("真是currentIndex : \(indexPath.item)")
        return item
    }
    
    class Item : UICollectionViewCell {
        let label = UILabel.init(frame: CGRect.zero)
        var model : DDHuDong?{
            didSet{
                let nickName = model?.nikename ?? ""
                let hd_title = model?.hd_title ?? ""
                let hd_name = model?.hd_name ?? ""
                let arr = [nickName , hd_title , hd_name]
                let attributedString = arr.setColor(colors: [UIColor.red , UIColor.green , UIColor.blue])
                label.attributedText = attributedString
//                mylog(model?.imageUrl)
//                if let url  =  URL(string:  model?.imageUrl ?? "") {
//                    imageView.sd_setImage(with: url)
//                    self.layoutIfNeeded()
                
//                }
                
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame )
            self.prepareSubviews()
            label.textColor = UIColor.lightGray
            label.font = GDFont.systemFont(ofSize: 13)
//            self.backgroundColor = UIColor.randomColor()
        }
        func prepareSubviews() {
            self.contentView.addSubview(self.label)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            label.frame = self.bounds
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}





enum GDAutoAlignment {
    case center
    case left
    case right
}


protocol GDAutoPageControlDelegate : NSObjectProtocol {
    func currentPageChanged(currentPage:Int )
}


class GDAutoPageControl: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    weak var delegate : GDAutoPageControlDelegate?
    
    var selectedImage : UIImage?
    var normalImage : UIImage?
    
    var previousOffset : CGPoint = CGPoint.zero
    
    weak var scrollView : UIScrollView?{
        didSet{
            
            scrollView?.addObserver(self , forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    
    var align : GDAutoAlignment = GDAutoAlignment.center
    var selectedBtn = UIButton()
    var numberOfPages : Int  = 0 {
        willSet{
            for view  in self.subviews { view.removeFromSuperview() }
            for index  in 0..<newValue {
                let btn = UIButton()
                btn.adjustsImageWhenHighlighted = false
                self.addSubview(btn)
                if index == 0 {
                    if let tempSelectedImg = self.selectedImage {
                        btn.setImage(tempSelectedImg, for: UIControlState.selected)
                    }else{
                        btn.setImage(UIImage(named: "whiteDot"), for: UIControlState.selected)
                    }
                    if let tempNormalImg = self.normalImage {
                        btn.setImage(tempNormalImg, for: UIControlState.normal)
                    }else{
                        btn.setImage(UIImage(named: "blackDot"), for: UIControlState.normal)
                    }
                    self.selectedBtn = btn
                    self.currentPage = 0
                }else{
                    if let tempSelectedImg = self.selectedImage {
                        btn.setImage(tempSelectedImg, for: UIControlState.selected)
                    }else{
                        btn.setImage(UIImage(named: "whiteDot"), for: UIControlState.selected)
                    }
                    if let tempNormalImg = self.normalImage {
                        btn.setImage(tempNormalImg, for: UIControlState.normal)
                    }else{
                        btn.setImage(UIImage(named: "blackDot"), for: UIControlState.normal)
                    }
                }
            }
        }
    }
    var currentPage : Int  = 0 {
        willSet{
            if newValue >= self.subviews.count || newValue < 0{return}
            self.selectedBtn.isSelected = false
            self.selectedBtn = self.subviews[newValue] as! UIButton
            self.selectedBtn.isSelected = true
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let itemW : CGFloat = 10
        let itemH  = itemW
        let margin : CGFloat = 0
        let totalWidth = CGFloat(self.subviews.count) * (itemW + margin) + margin
        let originFrame = self.frame
        if self.align == GDAutoAlignment.center {
            self.bounds = CGRect(x: 0, y: 0, width: totalWidth, height: itemH)
            self.center = CGPoint(x: (self.superview?.center.x)!, y: originFrame.origin.y + itemH / 2)
        }else if (self.align == GDAutoAlignment.left){
            self.frame = CGRect(x: 0, y: originFrame.origin.y, width: totalWidth, height: itemH)
        }else if (self.align == GDAutoAlignment.right){
            self.frame = CGRect(x: (self.superview?.bounds.size.width)! - totalWidth, y: originFrame.origin.y, width: totalWidth, height: itemH)
        }
        for (index , view ) in self.subviews.enumerated() {
            view.frame = CGRect(x: margin + CGFloat(index) * (margin + itemW), y: 0, width: itemW, height: itemH)
        }
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil  {
            self.scrollView?.removeObserver(self , forKeyPath: "contentOffset")
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //    deinit {
    //        self.scrollView.removeObserver(self , forKeyPath: "contentOffset")
    //    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath! == "contentOffset" {
            if let newPoint = change?[NSKeyValueChangeKey.newKey] as? CGPoint{
                //                mylog("监听contentOffset\(newPoint)")//下拉变小
                let offset = newPoint
                var scrollViewWidth : CGFloat =  0
                if let scrollview = self.scrollView {
                    scrollViewWidth = scrollview.bounds.size.width
                }
                let count = scrollView!.contentSize.width / scrollView!.bounds.size.width
                let index  : Int = Int( offset.x / scrollViewWidth )
                if offset.x > self.previousOffset.x { // xiang you
                    if offset.x > scrollView?.contentSize.width   ?? 0 - scrollViewWidth{
                        //                        return
                    }else{
                        
                        let pass = offset.x -  CGFloat(index) * scrollViewWidth
                        if abs(pass) > scrollViewWidth / 2 {
                            if self.currentPage != index + 1 {
                                
                                self.currentPage = (index + 1) % Int(count / 3)//
                                self.delegate?.currentPageChanged(currentPage: self.currentPage)
                            }
                            //                    mylog("nvnvnvnvvnvnvn")
                        }
                    }
                }else{//xiang zuo
                    if offset.x < 0  {
                        //                        return
                    }else{
                        
                        let less = CGFloat(index + 1) * scrollViewWidth - offset.x
                        //                mylog(abs(less))
                        if abs(less) > scrollViewWidth / 2 {
                            if self.currentPage != index {
                                
                                self.currentPage = index % Int(count / 3)
                                self.delegate?.currentPageChanged(currentPage: self.currentPage)
                            }
                        }
                    }
                }
                self.previousOffset = offset
                
                
            }
            //            mylog(self.currentPage)
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}


