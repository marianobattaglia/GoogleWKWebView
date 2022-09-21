//
//  ViewController.swift
//  GoogleWKWebView
//
//  Created by Mariano Battaglia on 21/09/2022.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!

    // MARK: - Private constants
    private let searchBar = UISearchBar()
    private var webView: WKWebView!
    private let refreshControl = UIRefreshControl()
    private let baseUrl = "https://www.google.com"
    private let searchPath = "/search?q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
    }
    
    func setupUI() {
        /// Navigation Buttons
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        /// Search bar
        self.navigationItem.titleView = searchBar
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
    }
    
    func setupWebView() {
        let webViewPrefs = WKPreferences()
        webViewPrefs.javaScriptEnabled = true
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true
        let webViewConf = WKWebViewConfiguration()
        webViewConf.preferences = webViewPrefs
        webView = WKWebView(frame: view.frame, configuration: webViewConf)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //webView.scrollView.keyboardDismissMode = .onDrag
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        // RefreshControl
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        view.bringSubviewToFront(refreshControl)
        
        load(url: baseUrl)
    }

    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        webView.goForward()
    }
    
    // MARK: - Private methods
    private func load(url: String) {
        var urlToLoad: URL!
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            urlToLoad = url
        } else {
            urlToLoad = URL(string: "\(baseUrl)\(searchPath)\(url)")
        }
        webView.load(URLRequest(url: urlToLoad))
    }
    
    @objc private func reload() {
        webView.reload()
    }
    
}

// MARK: - Extensions
extension ViewController: UISearchBarDelegate {
    // Hides keyboard when search button is tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        load(url: searchBar.text ?? "")
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        refreshControl.beginRefreshing()
        searchBar.text = webView.url?.absoluteString
    }
}
