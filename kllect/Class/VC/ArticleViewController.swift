//
//  ArticleViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-09-06.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit
import WebKit
import Crashlytics

class ArticleViewController: UIViewController, UIGestureRecognizerDelegate {
	
	fileprivate var webView: WKWebView!
	@IBOutlet weak var backButton: UIBarButtonItem!
	@IBOutlet weak var forwardButton: UIBarButtonItem!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	@IBOutlet weak var safariButton: UIBarButtonItem!
	@IBOutlet weak var urlBar: UITextField!
	
	var articleTitle: String!
	var url: URL!
	
	override func viewDidLoad() {
		self.webView = WKWebView()
		self.view.addSubview(webView)
		self.webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
		self.setToolbarItems([self.backButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.forwardButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.shareButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.safariButton], animated: false)
		self.webView.scrollView.panGestureRecognizer.addTarget(self, action: #selector(ArticleViewController.panRecognizer(_:)))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		print(self)
		self.webView.frame = self.view.bounds
		self.backButton.isEnabled = false
		self.forwardButton.isEnabled = false
		self.webView.load(URLRequest(url: self.url))
		self.navigationController?.isNavigationBarHidden = false
		self.navigationController?.isToolbarHidden = false
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		self.webView.removeObserver(self, forKeyPath: "loading")
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "loading" {
			self.backButton.isEnabled = self.webView.canGoBack
			self.forwardButton.isEnabled = self.webView.canGoForward
			self.urlBar.text = self.webView.url?.absoluteString
		}
	}

	@IBAction func goBack(_ sender: UIBarButtonItem) {
		self.webView.goBack()
	}
	
	@IBAction func goForward(_ sender: UIBarButtonItem) {
		self.webView.goForward()
	}
	
	@IBAction func share(_ sender: UIBarButtonItem) {
		//TODO Change this to be specific to method shared
		Answers.logShare(withMethod: "Generic", contentName: self.url.absoluteString, contentType: "url", contentId: nil, customAttributes: ["Title": self.articleTitle])
	}
	
	@IBAction func openInSafari(_ sender: UIBarButtonItem) {
		
	}
	
	@IBAction func doneButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func panRecognizer(_ sender: UIPanGestureRecognizer) {
		print(sender.translation(in: self.webView))
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
}
