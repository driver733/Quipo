

import UIKit
import OAuthSwift

class WebVC: OAuthWebViewController, UIWebViewDelegate {
    
    let kNavBarHeight = CGFloat(64)
    let webViewScrollIsDragging = Bool()
    let webViewScrollIsDecelerating = Bool()

    var targetURL: NSURL = NSURL()
    let webView: UIWebView = UIWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        webView.scalesPageToFit = true
        webView.delegate = self
        self.navigationController?.addChildViewController(self)
        self.view.addSubview(webView)
        
        //     _ = UIApplication.sharedApplication().statusBarFrame.size.height
        let insets = UIEdgeInsets(top: kNavBarHeight, left: 0, bottom: 0, right: 0)
        let p = CGPointMake(0, -kNavBarHeight)

        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets
        webView.scrollView.contentOffset = p
        webView.scrollView.delegate = webView
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, kNavBarHeight))
        navigationBar.backgroundColor = UIColor.whiteColor()
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Login"
      
        let leftButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel_btn_clicked")
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
        
        loadAddressURL()
        
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
     func cancel_btn_clicked(){
        dismissWebViewController()
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func handle(url: NSURL) {
        targetURL = url
        super.handle(url)
    }
    func loadAddressURL() {
        let req = NSURLRequest(URL: targetURL)
        webView.loadRequest(req)
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL where (url.scheme == "oauth-swift"){
            self.dismissWebViewController()
        }
        return true
    }
}
