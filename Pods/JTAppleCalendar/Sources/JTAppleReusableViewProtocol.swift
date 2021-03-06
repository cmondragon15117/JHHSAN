//  Code Created by JayT Received from GitHub
//  https://github.com/jonathantribouharet/JTCalendar.git
//  All Credit goes to Jonathan Tribouharet

//  JTAppleReusableViewProtocol.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-10-02.
//
//

internal protocol JTAppleReusableViewProtocol: class {
    associatedtype ViewType: UIView
    func setupView(_ cellSource: JTAppleCalendarViewSource, leftToRightOrientation: ReadingOrientation)
    var view: ViewType? {get set}
}

extension JTAppleReusableViewProtocol {
    func setupView(_ cellSource: JTAppleCalendarViewSource, leftToRightOrientation: ReadingOrientation) {
        if (self as? UIView)?.transform.a != 1 && leftToRightOrientation == .leftToRight {
            (self as? UIView)!.transform.a = 1
        } else if (self as? UIView)?.transform.a != -1 && leftToRightOrientation == .rightToLeft {
            (self as? UIView)!.transform.a = -1
        }
        
        if let nonNilView = view {
            nonNilView.setNeedsLayout()
            return
        }
        
        switch cellSource {
        case let .fromXib(xibName, bundle):
            let bundleToUse = bundle ?? Bundle.main
            let viewObject = bundleToUse
                .loadNibNamed(xibName, owner: self, options: [:])
            guard let view = viewObject?[0] as? ViewType else {
                print("xib: \(xibName) file class does not conform to the JTAppleViewProtocol")
                assert(false)
                return
            }
            self.view = view
            break
        case let .fromClassName(className, bundle):
            let bundleToUse = bundle ?? Bundle.main
            guard let theCellClass = bundleToUse.classNamed(className) as? ViewType.Type else {
                print("Error loading registered class: '\(className)'")
                print("Make sure that: \n\n(1) It is a subclass of: 'UIView' and conforms to 'JTAppleViewProtocol'")
                print("(2) You registered your class using the fully qualified name like so --> 'theNameOfYourProject.theNameOfYourClass'\n")
                assert(false)
                return
            }
            self.view = theCellClass.init()
            break
        case let .fromType(cellType):
            guard let theCellClass = cellType as? ViewType.Type else {
                print("Error loading registered class: '\(cellType)'")
                print("Make sure that: \n\n(1) It is a subclass of: 'UIiew' and conforms to 'JTAppleViewProtocol'\n")
                assert(false)
                return
            }
            self.view = theCellClass.init()
            break
        }
        guard let validView = view else {
            print("Error setting up views. \(developerErrorMessage)")
            return
        }
        (self as? UIView)?.addSubview(validView)
    }
}
