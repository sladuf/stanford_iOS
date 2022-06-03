//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 김민령 on 2022/05/07.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [Any]()
    
    func setOperand(operand : Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private var operations = [
        "π" : Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "×" : Operation.BinaryOperation({ $0*$1 }),
        "÷" : Operation.BinaryOperation({ $0/$1 }),
        "+" : Operation.BinaryOperation({ $0+$1 }),
        "−" : Operation.BinaryOperation({ $0-$1 }),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    
    func performOperation(symbol : String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value) :
                accumulator = value
            case .UnaryOperation(let function) :
                accumulator = function(accumulator)
            case .BinaryOperation(let function) :
                excutePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals :
                excutePendingBinaryOperation()
            }
        }
    }
    
    private func excutePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    var program : PropertyList {
        get {
            return internalProgram as AnyObject
        }
        set {
            clear()
            if let arrayofOps = newValue as? [AnyObject] {
                for op in arrayofOps {
                    if let operand = op as? Double {
                        setOperand(operand : operand)
                    }else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    func clear(){
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    
    private var pending : PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo{
        var binaryFunction : (Double,Double) -> Double
        var firstOperand : Double
    }
    
    var result : Double {
        get {
            return accumulator
        }
    }
    
}
