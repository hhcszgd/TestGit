//
//  VCWithNaviBar.swift
//  mh824appWithSwift
//
//  Created by wangyuanfei on 16/8/25.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

import UIKit

enum VCType {
    case withBackButton
    case withoutBackButton
}


  class VCWithNaviBar: BaseVC  , CustomNaviBarDelegate{
    private var errorView : GDErrorView?
    
    var currentType : VCType = VCType.withBackButton

    var attritNavTitle : NSAttributedString  {
        set{   naviBar.title = newValue  }
        get{ return naviBar.title }
    }

    
     var naviBar : CustomNaviBar = CustomNaviBar(type: NaviBarType.withoutBackBtn)
   init(vcType : VCType){
        super.init(nibName: nil, bundle: nil)

//        super.init()
        currentType = vcType
        switch currentType {
        case .withBackButton:
            //
            naviBar = CustomNaviBar(type: NaviBarType.withBackBtn)
            naviBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64 )
            naviBar.delegate = self
            break
        case .withoutBackButton:
            //
            
            naviBar = CustomNaviBar(type: NaviBarType.withoutBackBtn)
            naviBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64 )
            break
        }
//        naviBar.backgroundColor = UIColor.randomColor()
//        self.view.addSubview(naviBar)//推迟添加 , 否则会提前调用viewdidload()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

//        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(naviBar)
        naviBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64 )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func popToPreviousVC() {
       _ = self.navigationController?.popViewController(animated: true)
        //        print("ClassName->\(#file)_MethodName->\(#function)_LineNumber->\(#line)_\("相应成功")")
    }
    
    //MARK:页面加载错误是调这个方法
    func showErrorView ()  {
        self.errorView = GDErrorView()
        self.errorView?.addTarget(self, action: #selector(errorViewClick), for: UIControlEvents.touchUpInside)
        self.view.insertSubview(errorView!, belowSubview: self.naviBar)
        self.errorView?.frame = self.view.bounds

        
    }
    //MARK://子类重写它 , 在方法中调hiddenErrorView()
    func errorViewClick ()  {
        
    }
    func hiddenErrorView()  {
        self.errorView?.removeFromSuperview()
        self.errorView = nil
    }
}
//extension VCWithNaviBar : CustomNaviBarDelegate {
//    func popToPreviousVC() {
//        self.navigationController?.popViewController(animated: true)
////        print("ClassName->\(#file)_MethodName->\(#function)_LineNumber->\(#line)_\("相应成功")")
//    }
//}
