//
//  Delegate.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 22/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

public class Delegate<Input, Output> {
    init() {}
    
    private var block: ((Input) -> Output?)?
    
    func delegate<T: AnyObject>(on target: T, block: ((T, Input) -> Output)?) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block?(target, input)
        }
    }
    
    func call(_ input: Input) -> Output? {
        return block?(input)
    }
}

extension Delegate where Input == Void {
    // To make syntax better for `Void` input.
    func call() -> Output? {
        return call(())
    }
}
