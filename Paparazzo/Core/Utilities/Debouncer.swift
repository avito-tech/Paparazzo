// 1--------2----3--4-5-6---------789-------
// ^delay.  ^dela^de^d^d^delay.   ^^^delay.
// ------1--------------------6-----------9-
//
// http://rxmarbles.com/#debounce
//
// Real life example:
//
// Л-е-с-на--я------------------------------
// ^d^d^d^^de^delay.
// ----------------suggest("Лесная")--------
//
// NOTE: Access to the resource should be syncronized! See cancel() below.
//

public protocol Debouncable {
    func debounce(_ closure: @escaping () -> ())
    func cancel()
}

public final class Debouncer: Debouncable {
    private var lastFireTime = DispatchTime(uptimeNanoseconds: 0)
    private let queue: DispatchQueue
    private let delay: TimeInterval
    
    public init(delay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.delay = delay
        self.queue = queue
    }
    
    public func debounce(_ closure: @escaping () -> ()) {
        lastFireTime = DispatchTime.now()
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            if let strongSelf = self {
                let now = DispatchTime.now()
                let when = strongSelf.lastFireTime + strongSelf.delay
                if now >= when {
                    closure()
                }
            }
        }
    }
    
    // Text input:        --Л-е-с--ная------- ("Лесная")
    // As events:         --x-x-x--xxx-------
    // Debounce time:       ^-^-^--^^^----.
    // Debounced:         ----------------x--
    // User taps cancel:  -------------y-----
    //
    // Expected result:   -------------y-----
    // Actual result:     -------------y--x-- (without calling cancel())
    //
    // Convenience function: cancel()
    //
    // Note: in ideal world with RX you don't have to use this.
    // It should be a single stream:
    //
    // Text input:        --Л-е-с--ная------- ("Лесная")
    // As events:         --x-x-x--xxx-------
    // User taps cancel:  -------------y-----
    //
    // A single stream:
    // All this merged:   --z-z-z--zzz-z-----
    // Debounce time:       ^-^-^--^^^-^----.
    // Debounced:         ------------------z ("")
    //
    // If data streams aint a mess you will be happy without cancel().
    // However, now in our app data streams are a mess.
    
    public func cancel() {
        // Preempt current operation in debouncer to get expected result as in the example above.
        debounce {}
    }
}
