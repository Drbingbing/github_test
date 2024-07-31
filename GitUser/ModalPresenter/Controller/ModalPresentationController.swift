//
//  ModalPresentationController.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import UIKit

open class ModalPresentationController: UIPresentationController {
    
    struct Constants {
        static let indicatorYOffset = CGFloat(8.0)
        static let snapMovementSensitivity = CGFloat(0.7)
        static let dragIndicatorSize = CGSize(width: 36.0, height: 5.0)
    }
    
    public enum PresentationState {
        
        case medium
        case large
    }
    
    /// Background view used as an overlay over the presenting view
    private lazy var backgroundView: DimmedView = {
        let view: DimmedView
        if let color = presentable?.modalBackgroundColor {
            view = DimmedView(dimColor: color)
        } else {
            view = DimmedView()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDimmedViewTapped))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    /// A wrapper around the presented view so that we can modify
    /// the presented view apperance without changing
    /// the presented view's properties
    private lazy var modalContainerView: ModalContainerView = {
        let frame = containerView?.frame ?? .zero
        return ModalContainerView(presentedView: presentedViewController.view, frame: frame)
    }()
    
    private lazy var dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = presentable?.grabberColor
        view.layer.cornerRadius = Constants.dragIndicatorSize.height / 2.0
        return view
    }()
    
    /// Gesture recognizer to detect & track pan gestures
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPanOnPresentedView))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    /// An observer for the scroll view content offset
    private var scrollObserver: NSKeyValueObservation?
    
    /// The y content offset value of the embedded scroll view
    private var scrollViewYOffset: CGFloat = 0.0
    
    /// A flag to track if the presented view is animating
    private var isPresentedViewAnimating = false
    
    /// Determine anchoredYPosition based on the `anchorModalToLarge` flag
    private var anchorModalToLongForm = true
    
    /// A flag to determine if scrolling should seamlessly transition
    /// from the pan modal container view to the scroll view
    /// once the scroll limit has been reached.
    private var extendsPanScrolling = true
    
    /// The y value for the medium presentation state
    private var mediumYposition: CGFloat = 0
    
    /// The y value for the large presentation state
    private var largeYposition: CGFloat = 0
    
    private var anchoredYPosition: CGFloat {
        let defaultTopOffset = presentable?.topOffset ?? 0
        return anchorModalToLongForm ? largeYposition : defaultTopOffset
    }
    
    private var presentable: ModalPresentable? {
        return presentedViewController as? ModalPresentable
    }
    
    public override var presentedView: UIView {
        return modalContainerView
    }
    
    // MARK: - Life Cycle
    open override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        configureViewLayout()
    }
    
    open override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView else {
            return
        }
        
        layoutBackgroundView(in: containerView)
        layoutPresentedView(in: containerView)
        configureScrollViewInsets()
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.dimState = .max
            return
        }
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.backgroundView.dimState = .max
            self?.presentedViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if completed { return }
        
        backgroundView.removeFromSuperview()
    }
    
    override public func dismissalTransitionWillBegin() {
        presentable?.modalWillDismiss()
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            backgroundView.dimState = .off
            return
        }
        
        // Drag indicator is drawn outside of view bounds
        // so hiding it on view dismiss means avoiding visual bugs
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.dragIndicatorView.alpha = 0.0
            self?.backgroundView.dimState = .off
            self?.presentingViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed { return }
        
        presentable?.modalDidDismiss()
    }
    
    /// Update presented view size in response to size class changes
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard
                let self = self,
                let presentable = self.presentable
            else { return }
            
            self.adjustPresentedViewFrame()
            if presentable.preferredCornerRadius > 0 {
                self.addRoundedCorners(to: self.presentedView)
            }
        })
    }
}

private extension ModalPresentationController {
    
    @objc func didDimmedViewTapped() {
        if let backgroundInteraction = self.presentable?.backgroundInteraction {
            
            switch backgroundInteraction {
            case .dismiss:
                self.presentedViewController.dismiss(animated: true)
            case .forward:
                backgroundView.hitTestHandler = { [weak self] (point, event) in
                    return self?.presentingViewController.view.hitTest(point, with: event)
                }
            case .absorbs: break
            }
            
        }
    }
    
    /// Add the presented view to the given container view
    /// & configures the view elements such as drag indicator, rounded corners
    /// based on the modal presentable
    func layoutPresentedView(in containerView: UIView) {
        /// If the presented view controller does not conform to modal presentable
        /// don't configure
        guard let presentable = presentable else { return }
        
        /// If this class is Not used in conjunction with the `ModalPresentationAnimator`
        /// & `ModalPresentable`, the presented view should be added to the container view
        /// in the presentation animator instead of here
        containerView.addSubview(presentedView)
        if presentable.backgroundInteraction != .forward {
            containerView.addGestureRecognizer(panGestureRecognizer)
        }
        
        if presentable.prefersGrabberVisible {
            addDragIndicatorView(to: presentedView)
        }
        
        if presentable.preferredCornerRadius > 0 {
            addRoundedCorners(to: presentedView)
        }
        
        setNeedsLayoutUpdate()
        adjustPanContainerBackgroundColor()
    }
    
    /// Add a background color to the modal container view
    /// in order to avoid a gap at the bottom
    /// during initial view presentation in large (when view bounces)
    func adjustPanContainerBackgroundColor() {
        modalContainerView.backgroundColor = presentedViewController.view.backgroundColor
        ?? presentable?.modalScrollView?.backgroundColor
    }
    
    func layoutBackgroundView(in containerView: UIView) {
        containerView.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    func addDragIndicatorView(to view: UIView) {
        view.addSubview(dragIndicatorView)
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicatorView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -Constants.indicatorYOffset).isActive = true
        dragIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dragIndicatorView.widthAnchor.constraint(equalToConstant: Constants.dragIndicatorSize.width).isActive = true
        dragIndicatorView.heightAnchor.constraint(equalToConstant: Constants.dragIndicatorSize.height).isActive = true
    }
    
    func configureViewLayout() {
        
        guard let presentable = presentedViewController as? (ModalPresentable & UIViewController) else {
            return
        }
        
        mediumYposition = presentable.mediumYPos
        largeYposition = presentable.largeYPos
        anchorModalToLongForm = presentable.anchorModalToLarge
        extendsPanScrolling = presentable.allowsExtendedScrolling
        
        containerView?.isUserInteractionEnabled = presentable.isUserInteractionEnabled
    }
    
    func configureScrollViewInsets() {
        
        guard let scrollView = presentable?.modalScrollView,
              !scrollView.isScrolling
        else { return }
        
        /// Disable vertical scroll indicator until we start to scroll
        /// to avoid visual bugs
        scrollView.showsVerticalScrollIndicator = false
        
        /// Set the appropriate contentInset as the configuration within this class
        /// offset it
        scrollView.contentInset.bottom = presentedViewController.view.safeAreaInsets.bottom
        
        /// As we adjust the bounds during `handleScrollViewTopBounce`
        /// we should assume that contentInsetAdjustmentBehavior will not be correct
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    func adjustPresentedViewFrame() {
        
        guard let frame = containerView?.frame else { return }
        
        let adjustedSize = CGSize(width: frame.size.width, height: frame.size.height - anchoredYPosition)
        let modalFrame = modalContainerView.frame
        
        if ![mediumYposition, largeYposition].contains(modalFrame.origin.y) {
            // if the container is already in the correct position, no need to adjust positioning
            // (rotations & size changes cause positioning to be out of sync)
            let yPosition = modalFrame.origin.y - modalFrame.height + frame.height
            presentedView.frame.origin.y = max(yPosition, anchoredYPosition)
        }
        
        modalContainerView.frame.origin.x = frame.origin.x
        presentedViewController.view.frame = CGRect(origin: .zero, size: adjustedSize)
    }
    
    /// Create & stores an observer on the given scroll view's content offset.
    /// This allow us to track scrolling without overriding the scrollview detegate
    func observe(scrollView: UIScrollView?) {
        scrollObserver?.invalidate()
        scrollObserver = scrollView?.observe(\.contentOffset, changeHandler: { [weak self] scrollView, change in
            guard self?.containerView != nil else {
                return
            }
            
            self?.didPanOnScrollView(scrollView, change: change)
        })
    }
    
    var isPresentedViewAnchored: Bool {
        if !isPresentedViewAnimating
            && extendsPanScrolling
            && presentedView.frame.minY.rounded() <= anchoredYPosition.rounded() {
            return true
        }
        return false
    }
    
    /// Scroll view content offset change event handler
    ///
    /// Also when scrollView is scrolled to the top, we disable the scroll indicator
    /// otherwise glitchy behaviour occurs
    ///
    /// This is also shown in Apple Maps (reverse engineering)
    /// which allow us to seamless tranistion scrolling from modalContainer to the scrollview
    func didPanOnScrollView(_ scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        guard !presentedViewController.isBeingDismissed,
              !presentedViewController.isBeingPresented
        else { return }
        
        // Hold the scrollView in place if we're actively scrolling and not handling top bounce
        if !isPresentedViewAnchored && scrollView.contentOffset.y > 0 {
            haltScrolling(scrollView)
        }
        
        else if scrollView.isScrolling || isPresentedViewAnimating {
            
            if isPresentedViewAnchored {
                
                // While we're scrolling upwards on the scrollView,
                // store the last content offset position
                trackScrolling(scrollView)
            } else {
                
                haltScrolling(scrollView)
            }
        } else if presentedViewController.view.isKind(of: UIScrollView.self)
                    && !isPresentedViewAnimating && scrollView.contentOffset.y <= 0 {
            
            //  In the case where we drag down quickly on the scroll view and let go,
            // `handleScrollViewTopBounce` adds a nice elegant touch.
            handleScrollViewTopBounce(scrollView: scrollView, change: change)
        } else {
            trackScrolling(scrollView)
        }
    }
    
    /// Halt the scroll of a given scroll view & anchor it at the `scrollViewYOffset`
    func haltScrolling(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollViewYOffset), animated: false)
        scrollView.showsVerticalScrollIndicator = false
    }
    
    
    /// As the user scrolls, track & save the scroll view y offset.
    /// This helps halt scrolling when we want to hold the scroll view in place.
    func trackScrolling(_ scrollView: UIScrollView) {
        scrollViewYOffset = max(scrollView.contentOffset.y, 0)
        scrollView.showsVerticalScrollIndicator = true
    }
    
    /// To ensure that the scroll transition between the scrollView & the modal
    /// is completely seamless, we need to handle the case where content offset is negative.
    ///
    /// In this case, we follow the curve of the decelerating scroll view.
    /// This give the effect that the modal view the scroll view are on view entirely.
    ///
    /// - Note: This works best where the view behind view controller is a UIScrollView.
    /// So for exmaple, a UITableViewController.
    func handleScrollViewTopBounce(scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        
        guard let oldYValue = change.oldValue?.y, scrollView.isDecelerating else {
            return
        }
        
        let yOffset = scrollView.contentOffset.y
        let presentedSize = containerView?.frame.size ?? .zero
        
        /// Decrease the view bounds by the y offset so the scroll view stays in place
        /// and we can still get updates on its content offset
        presentedView.bounds.size = CGSize(width: presentedSize.width, height: presentedSize.height)
        
        if oldYValue > yOffset {
            /// Move the view in opposite direction to the decreasing bounds
            /// until half way through the deceleration so that appears
            /// as if we're transferring the scrollView drag momentum to the entire view
            
            presentedView.frame.origin.y = largeYposition - yOffset
        } else {
            scrollViewYOffset = 0
            snap(toYPosition: largeYposition)
        }
        
        scrollView.showsVerticalScrollIndicator = false
    }
}

extension ModalPresentationController: UIGestureRecognizerDelegate {
    
    /// Do note required any other gesture to fail
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /// Allow simultaneous gesture recognizers only when the other gesture recognizer's view
    /// is the modal scrollable view
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view == presentable?.modalScrollView
    }
}

private extension ModalPresentationController {
    
    func addRoundedCorners(to view: UIView) {
        let radius = presentable?.preferredCornerRadius ?? 0
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: radius, height: radius))
        
        // Draw around the drag indicator view, if displayed
        let indicatorLeftEdgeXPos = view.bounds.width / 2.0 - Constants.dragIndicatorSize.width / 2.0
        drawAroundDragIndicator(currentPath: path, indicatorLeftEdgeXPos: indicatorLeftEdgeXPos)
        
        // Set path as a mask to display optional drag indicator view & rounded corners
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
        
        // Improve performance by rasterizing the layer
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func drawAroundDragIndicator(currentPath path: UIBezierPath, indicatorLeftEdgeXPos: CGFloat) {
        
        let totalIndicatorOffset = Constants.indicatorYOffset + Constants.dragIndicatorSize.height
        
        // Draw around drag indicator starting from the left
        path.addLine(to: CGPoint(x: indicatorLeftEdgeXPos, y: path.currentPoint.y))
        path.addLine(to: CGPoint(x: path.currentPoint.x, y: path.currentPoint.y - totalIndicatorOffset))
        path.addLine(to: CGPoint(x: path.currentPoint.x + Constants.dragIndicatorSize.width, y: path.currentPoint.y))
        path.addLine(to: CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + totalIndicatorOffset))
    }
    
}


// MARK: - Public API
public extension ModalPresentationController {
    
    func snap(toYPosition yPos: CGFloat) {
        ModalAnimator.animate(config: presentable) { [weak self] in
            self?.adjust(toYPosition: yPos)
            self?.isPresentedViewAnimating = true
        } completion: { [weak self] didComplete in
            self?.isPresentedViewAnimating = !didComplete
        }
    }
    
    /// Set the y position of the presentedView & adjust the backgroundView.
    func adjust(toYPosition yPos: CGFloat) {
        presentedView.frame.origin.y = max(yPos, anchoredYPosition)
        
        guard presentedView.frame.origin.y > mediumYposition else {
            backgroundView.dimState = .max
            return
        }
        
        let yDisplacementFromMedium = presentedView.frame.origin.y - mediumYposition
        
        /// Once presentedView is translated below shortForm, calculate yPos relative to bottom of screen
        /// and apply percentage to backgroundView alpha
        backgroundView.dimState = .percent(1.0 - (yDisplacementFromMedium / presentedView.frame.height))
    }
    
    /// Finds the nearest value to a given number out of a given array of float values
    /// - Parameters:
    /// - Parameters number: reference float we are trying to find the closest value to
    /// - Parameters values: array of floats we would like to compare against
    func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) })
        else { return number }
        return nearestVal
    }
    
    func setNeedsLayoutUpdate() {
        configureViewLayout()
        adjustPresentedViewFrame()
        observe(scrollView: presentable?.modalScrollView)
        configureScrollViewInsets()
    }
    
    func transition(to state: PresentationState) {
        guard presentable?.shouldTransition(to: state) == true else {
            return
        }
        
        presentable?.willTransition(to: state)
        
        switch state {
        case .medium:
            snap(toYPosition: mediumYposition)
        case .large:
            snap(toYPosition: largeYposition)
        }
    }
    
    /// Operation on the scroll view, such as content height changes,
    /// or when inserting/deleting rows can cause the pan modal to jump,
    /// caused by the pan modal responding to content offset changes.
    ///
    /// To avoid this, you can call this method to perform scroll view updates,
    /// with scroll observation temporarily disabled.
    func performUpdates(_ updates: () -> Void) {
        
        guard let scrollView = presentable?.modalScrollView
        else { return }
        
        // Pause scroll observer
        scrollObserver?.invalidate()
        scrollObserver = nil
        
        // Perform updates
        updates()
        
        // Resume scroll observer
        trackScrolling(scrollView)
        observe(scrollView: scrollView)
    }
}

private extension ModalPresentationController {
    
    
    /// The designated function for handling pan gesture events
    @objc func didPanOnPresentedView(_ recognizer: UIPanGestureRecognizer) {
        
        guard shouldRespond(to: recognizer),
              let containerView = containerView
        else {
            recognizer.setTranslation(.zero, in: recognizer.view)
            return
        }
        
        switch recognizer.state {
        case .began, .changed:
            // Respond accordingly to pan gesture translation
            respond(to: recognizer)
            
            // If presentedView is translated above the longForm threshold, treat as transition
            if presentedView.frame.origin.y == anchoredYPosition && extendsPanScrolling {
                presentable?.willTransition(to: .large)
            }
            
        default:
            
            // Use velocity sensitivity value to restrict snapping
            let velocity = recognizer.velocity(in: presentedView)
            
            if isVelocityWithinSensitivityRange(velocity.y) {
                // If velocity is within the sensitivity range,
                // transition to a presentation state or dismiss entirely.
                //
                // This allows the user to dismiss directly from long form
                // instead of going to the short form state first.
                if velocity.y < 0 {
                    transition(to: .large)
                } else if (nearest(to: presentedView.frame.minY, inValues: [largeYposition, containerView.bounds.height]) == largeYposition
                           && presentedView.frame.minY < mediumYposition)
                            || presentable?.isPresentableInPresentation == true {
                    
                    transition(to: .medium)
                } else {
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            } else {
                
                /// The `containerView.bounds.height` is used to determine
                /// how close the presented view is to the bottom of the screen
                let position = nearest(to: presentedView.frame.minY, inValues: [containerView.bounds.height, mediumYposition, largeYposition])
                
                if position == largeYposition {
                    transition(to: .large)
                    
                } else if position == mediumYposition || presentable?.isPresentableInPresentation == true {
                    transition(to: .medium)
                    
                } else {
                    presentedViewController.dismiss(animated: true)
                }
            }
        }
    }
    
    /// Determine if the pan modal should respond to the gesture reconizer.
    ///
    /// If the pan modal is already being dragged & the delegate return false, ignore until
    /// the recognizer is back to it's original state (.began)
    func shouldRespond(to panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        
        guard
            presentable?.shouldRespond(to: panGestureRecognizer) == true || !(panGestureRecognizer.state == .began || panGestureRecognizer.state == .cancelled)
        else {
            panGestureRecognizer.isEnabled = false
            panGestureRecognizer.isEnabled = true
            return false
        }
        
        return !shouldFail(panGestureRecognizer: panGestureRecognizer)
    }
    
    /// Communicate intentions to presentable and adjust subviews in containerView
    func respond(to panGestureRecognizer: UIPanGestureRecognizer) {
        
        var yDisplacement = panGestureRecognizer.translation(in: presentedView).y
        
        /**
         If the presentedView is not anchored to long form, reduce the rate of movement
         above the threshold
         */
        if presentedView.frame.origin.y < largeYposition {
            yDisplacement /= 2.0
        }
        adjust(toYPosition: presentedView.frame.origin.y + yDisplacement)
        
        panGestureRecognizer.setTranslation(.zero, in: presentedView)
    }
    
    /// Determines if we should fail the gesture recognizer based on certain conditions
    ///
    /// We fail the presented view's pan gesture recognizer if we are actively scrolling on the scroll view
    /// This allows the user to drag whole view controller from outside scrollView touch area.
    ///
    /// Unfortunately, cancelling a gestureRecognizer means that we lose the effect of transition scrolling
    /// from one view to another in the same pan gesture so don't cancel
    func shouldFail(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        
        // Allow api consumers to override the internal conditions &
        // decide if the pan gesture recognizer should be prioritzed
        // This is only time we should be cancelling the panScrollable recognizer,
        // for the purpose of ensuring we're no longer tracking the scrollView
        guard !shouldPrioritize(panGestureRecognizer: panGestureRecognizer) else {
            presentable?.modalScrollView?.panGestureRecognizer.isEnabled = false
            presentable?.modalScrollView?.panGestureRecognizer.isEnabled = true
            
            return false
        }
        
        guard isPresentedViewAnchored,
              let scrollView = presentable?.modalScrollView,
              scrollView.contentOffset.y > 0
        else { return false }
        
        let loc = panGestureRecognizer.location(in: presentedView)
        return (scrollView.frame.contains(loc) || scrollView.isScrolling)
    }
    
    /// Determine if the presented view's panGestureRecognizer should be prioritized over
    /// embedded scrollView's panGestureRecognizer.
    func shouldPrioritize(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return panGestureRecognizer.state == .began &&
        presentable?.shouldPrioritize(modalGestureRecognizer: panGestureRecognizer) == true
    }
    
    /// Check if the given velocity is within the sensitivity range
    func isVelocityWithinSensitivityRange(_ velocity: CGFloat) -> Bool {
        return (abs(velocity) - (1000 * (1 - Constants.snapMovementSensitivity))) > 0
    }
}


private extension UIScrollView {
    
    
    var isScrolling: Bool {
        return isDragging && !isDecelerating || isTracking
    }
    
}
