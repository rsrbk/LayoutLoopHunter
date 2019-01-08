/*
 MIT License
 Copyright (c) 2019 Ruslan Serebriakov <rsrbk1@gmail.com>
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

public struct LayoutLoopHunter {
    
    struct RuntimeConstants {
        static let Prefix = "runtime"
        
        // Associated objects keys
        static var CounterKey = "_counter"
        static var ResetWorkItemKey = "_resetWorkItem"
    }
    
    public static func setUp(for view: UIView, threshold: Int = 100, onLoop: @escaping () -> ()) {
        // We create the name for our new class based on the prefix for our feature and the original class name
        let classFullName = "\(RuntimeConstants.Prefix)_\(String(describing: view.self))"
        let originalClass = type(of: view)
        
        if let trackableClass = objc_allocateClassPair(originalClass, classFullName, 0) {
            // This class hasn't been created during the current runtime session
            // We need to register our class and swap is with the original view's class
            objc_registerClassPair(trackableClass)
            object_setClass(view, trackableClass)
            
            // Now we can create the associated object
            objc_setAssociatedObject(view, &RuntimeConstants.CounterKey, 0, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Adding our layoutSubviews implementation
            let layoutSubviews: @convention(block) (Any?) -> () = { nullableSelf in
                guard let _self = nullableSelf else { return }
                
                let selector = #selector(originalClass.layoutSubviews)
                let originalImpl = class_getMethodImplementation(originalClass, selector)
                
                // @convention(c) tells Swift this is a bare function pointer (with no context object)
                // All Obj-C method functions have the receiver and message as their first two parameters
                // Therefore this denotes a method of type `() -> Void`, which matches up with `layoutSubviews`
                typealias ObjCVoidVoidFn = @convention(c) (Any, Selector) -> Void
                let originalLayoutSubviews = unsafeBitCast(originalImpl, to: ObjCVoidVoidFn.self)
                originalLayoutSubviews(view, selector)
                
                if let counter = objc_getAssociatedObject(_self, &RuntimeConstants.CounterKey) as? Int {
                    if counter == threshold {
                        onLoop()
                    }
                    
                    objc_setAssociatedObject(view, &RuntimeConstants.CounterKey, counter+1, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
                
                // Dispatch work item for reseting the counter on every new run loop iteration
                if let previousResetWorkItem = objc_getAssociatedObject(view, &RuntimeConstants.ResetWorkItemKey) as? DispatchWorkItem {
                    previousResetWorkItem.cancel()
                }
                let counterResetWorkItem = DispatchWorkItem { [weak view] in
                    guard let strongView = view else { return }
                    objc_setAssociatedObject(strongView, &RuntimeConstants.CounterKey, 0, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
                DispatchQueue.main.async(execute: counterResetWorkItem)
                objc_setAssociatedObject(view, &RuntimeConstants.ResetWorkItemKey, counterResetWorkItem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            let implementation = imp_implementationWithBlock(layoutSubviews)
            class_addMethod(trackableClass, #selector(originalClass.layoutSubviews), implementation, "v@:")
        } else if let trackableClass = NSClassFromString(classFullName) {
            // We've previously allocated a class with the same name in this runtime session
            // We can get it from our raw string and swap with our view the same way
            object_setClass(view, trackableClass)
        }
    }
}
