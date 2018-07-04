//
//  RepeatingTimer.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 24.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import Foundation

class RepeatingTimer {

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: .seconds(1))
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here
         https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
}
