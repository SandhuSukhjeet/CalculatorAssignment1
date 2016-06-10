//
//  CalculatorBrain.swift
//  CalculatorAssignmentOne
//
//  Created by sukhjeet singh sandhu on 10/06/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import Foundation

class CalculatorBrain {

    fileprivate var accumulator = 0.0
    fileprivate var pending: PendingBinaryOperationInfo?
    fileprivate var currentPrecedence = Int.max
    fileprivate var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    var result: Double {
        return accumulator
    }
    var isPartialResult: Bool {
        return pending != nil
    }

    fileprivate var operations: Dictionary<String,Operation> = [
        "AC" : Operation.clearAll,
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "±": Operation.unaryOperation({ -$0 }, {"-(" + $0 + ")"}),
        "√" : Operation.unaryOperation(sqrt, { "√(" + $0 + ")"}),
        "sin" : Operation.unaryOperation({ __sinpi($0 / 180) }, { "sin(" + $0 + ")"}),
        "cos" : Operation.unaryOperation({ __cospi($0 / 180) }, { "cos(" + $0 + ")"}),
        "×" : Operation.binayOperation({ $0 * $1}, { $0 + " × " + $1 }, 1),
        "÷" : Operation.binayOperation({ $0 / $1}, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.binayOperation({ $0 + $1}, { $0 + " + " + $1 }, 0),
        "-" : Operation.binayOperation({ $0 - $1}, { $0 + " - " + $1 }, 0),
        "=" : Operation.equals
    ]

    fileprivate enum Operation {
        case clearAll
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binayOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case equals
    }

    fileprivate func executePendingBinaryOperation() {
        if let pending = self.pending {
            accumulator = pending.binaryFunction(pending.firstOperand, accumulator)
            descriptionAccumulator = pending.descriptionFunction(pending.descriptionOperand, descriptionAccumulator)
            self.pending = nil
        }
    }

    func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(operand)
    }

    func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .clearAll:
                accumulator = 0
                descriptionAccumulator = "0"
                pending = nil

            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol

            case .unaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)

            case .binayOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)

            case .equals:
                executePendingBinaryOperation()
            }
        }
    }

    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
}
