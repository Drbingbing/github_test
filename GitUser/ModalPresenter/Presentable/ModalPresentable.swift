//
//  ModalPresentable.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import UIKit

public protocol ModalPresentable: AnyObject {
    
    /// The scroll view embedded in the view controller.
    /// Setting this value allows for seamless transition scrolling between the embedded scroll view
    /// and the pan modal container view.
    var modalScrollView: UIScrollView? { get }
    
    /// The offset between the top of the screen and the top of the pan modal container view.
    ///
    /// Default value is the topLayoutGuide.length + 21.0.
    var topOffset: CGFloat { get }
    
    /// The height of the pan modal container view
    /// when in the shortForm presentation state.
    ///
    /// This value is capped to .max, if provided value exceeds the space available.
    ///
    /// Default value is the longFormHeight.
    var mediumHeight: ModalHeight { get }
    
    /// The height of the pan modal container view
    /// when in the longForm presentation state.
    ///
    /// This value is capped to .max, if provided value exceeds the space available.
    ///
    /// Default value is .max.
    var largeHeight: ModalHeight { get }
    
    /// corner radius
    /// Default Value is 8.0.
    var preferredCornerRadius: CGFloat { get }
    
    /// The springDamping value used to determine the amount of 'bounce'
    /// seen when transitioning to short/long form.
    ///
    /// Default Value is 0.8.
    var springDamping: CGFloat { get }
    
    /// The transitionDuration value is used to set the speed of animation during a transition,
    /// including initial presentation.
    ///
    /// Default value is 0.5.
    var transitionDuration: Double { get }
    
    /// The animation options used when performing animations on the PanModal, utilized mostly
    /// during a transition.
    ///
    /// Default value is [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState].
    var transitionAnimationOptions: UIView.AnimationOptions { get }
    
    /// The background view color.
    ///
    /// - Note: This is only utilized at the very start of the transition.
    ///
    /// Default Value is black with alpha component 0.7.
    var modalBackgroundColor: UIColor { get }
    
    /// Grabber color.
    ///
    /// Default value is light gray.
    var grabberColor: UIColor { get }
    
    /// A flag to determine grabber should be displayed
    ///
    /// Default value is YES
    var prefersGrabberVisible: Bool { get }
    
    /// A flag to determine if haptic feedback should be enabled during presentation.
    ///
    /// Default value is YES.
    var isHapticFeedbackEnabled: Bool { get }
    
    /// A flag to toggle user interactions on the container view.
    /// - Note: Return false to forward touches to the presentingViewController.
    ///
    /// Default is YES.
    var isUserInteractionEnabled: Bool { get }
    
    /// Describes what happens when the user interacts the background view.
    ///
    /// Default value is .dismiss
    var backgroundInteraction: ModalPresentBackgroundInteraction { get }
    
    /// modalInPresentation is set on the view controller when you wish to force the presentation hosting the view controller into modal behavior.
    /// When this is disactive, the presentation will prevent interactive dismiss and ignore events outside of
    /// the presented view controller's bounds until this is set to YES.
    var isPresentableInPresentation: Bool { get }
    
    /// A flag to determine if scrolling should be limited to the longFormHeight.
    /// Return false to cap scrolling at .max height.
    ///
    /// Default value is YES.
    var anchorModalToLarge: Bool { get }
    
    /// A flag to determine if scrolling should seamlessly transition from the pan modal container view to
    /// the embedded scroll view once the scroll limit has been reached.
    ///
    /// Default value is false. Unless a scrollView is provided and the content height exceeds the longForm height.
    var allowsExtendedScrolling: Bool { get }
    
    /// A flag to deteremine if view controller should response to view lifecycles.
    /// ex: viewdidappear or viewwilldisappear
    ///
    /// Default value is true.
    var interactorWithTransition: Bool { get }
    
    /// Asks the delegate if the pan modal should respond to the pan modal gesture recognizer.
    ///
    /// Return false to disable movement on the pan modal but maintain gestures on the presented view.
    ///
    /// Default value is true.
    func shouldRespond(to modalGestureRecognizer: UIPanGestureRecognizer) -> Bool
    
    /// Asks the delegate if the pan modal gesture recognizer should be prioritized.
    ///
    /// For example, you can use this to define a region
    /// where you would like to restrict where the pan gesture can start.
    ///
    /// If false, then we rely solely on the internal conditions of when a pan gesture
    /// should succeed or fail, such as, if we're actively scrolling on the scrollView.
    ///
    /// Default return value is false.
    func shouldPrioritize(modalGestureRecognizer: UIPanGestureRecognizer) -> Bool
    
    /// Asks the delegate if the modal should transtion to a new state
    ///
    /// Default value is YES
    func shouldTransition(to state: ModalPresentationController.PresentationState) -> Bool
    
    /// Notify the delegate that the modal is about to transition to a new state.
    ///
    /// Default value is an empty implementation.
    func willTransition(to state: ModalPresentationController.PresentationState)
    
    /// Notifies the delegate that the pan modal is about to be dismissed.
    ///
    /// Default value is an empty implementation.
    func modalWillDismiss()
    
    /// Notifies the delegate after the pan modal is dismissed.
    ///
    /// Default value is an empty implementation.
    func modalDidDismiss()
}
