//
//  NoMomentumScrollView.swift
//  SwiftUIAppDesignAndAppNavigationModule
//
//  Created by Mohan Singh Thagunna on 03/02/25.
//

import SwiftUI
import UIKit


struct ScrollViewWithDelegate<Content: View>: UIViewControllerRepresentable {
    
    var isScrollEnabled: Binding<Bool>
    @ViewBuilder var content: Content
    
    var onScrollEnd: (_ offset: CGPoint, _ scrollFrame: CGRect, _ contentSize: CGSize) -> Void
    
    func makeUIViewController(context: Context) -> UIScrollViewController<Content> {
        let controller = UIScrollViewController(rootView: content, onScrollEnd: onScrollEnd)
        controller.scrollView.isScrollEnabled = isScrollEnabled.wrappedValue
        return controller
    }
    
    func updateUIViewController(_ viewController: UIScrollViewController<Content>, context: Context) {
        viewController.updateContent(content)
    }
}

final class UIScrollViewController<Content: View>: UIViewController, UIScrollViewDelegate {
    
    private let hostingController: UIHostingController<Content>
    private let onScrollEnd: (_ offset: CGPoint, _ scrollFrame: CGRect, _ contentSize: CGSize) -> Void
    private var isFirstLoad = true
    
    lazy public var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.bounces = false
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    init(rootView: Content, onScrollEnd: @escaping (_ offset: CGPoint, _ scrollFrame: CGRect, _ contentSize: CGSize) -> Void) {
        self.hostingController = UIHostingController(rootView: rootView)
        self.onScrollEnd = onScrollEnd
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(hostingController.view)
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentSize = hostingController.view.intrinsicContentSize
        hostingController.view.frame.size = contentSize
        scrollView.contentSize = contentSize
        
        if isFirstLoad {
            isFirstLoad = false
            notifyScrollEnd()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var contentSize = hostingController.view.intrinsicContentSize
        contentSize.width = self.scrollView.frame.width
        hostingController.view.frame.size = contentSize
        scrollView.contentSize = contentSize
    }
    
    func updateContent(_ newContent: Content) {
        hostingController.rootView = newContent
        view.setNeedsLayout()
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyScrollEnd()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyScrollEnd()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        notifyScrollEnd()
    }
    
    private func notifyScrollEnd() {
        let scrollFrame = scrollView.frame
        let contentSize = scrollView.contentSize
        let offset = scrollView.contentOffset
        onScrollEnd(offset, scrollFrame, contentSize)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

//#Preview {
//    ScrollViewWithDelegate {
//        VStack {
//            ForEach(0..<50) { index in
//                Text("Item \(index)")
//                    .padding()
//            }
//        }
//    } onScrollEnd: { offset, frame, size in
//        print("Scroll momentum ended> Content offset: \(offset) and size: \(size) bottom: \(size.height - offset.y - frame.height)")
//    }
//    
//}
