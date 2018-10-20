//
//  Calculator.swift
//  Calculator
//
//  Created by Natsuko Nishikata on 2018/10/08.
//  Copyright © 2018年 Natsuko Nishikata. All rights reserved.
//

import Foundation

enum CalculateError: Error {
    case noError
    case fatal
    case negativeValue
    case calculateOverflow
    case inputOverflow
}

class Calculator {
    
    private let operators = "+-*/="
    private let digits = "01234567890"
    private let doubleZero = "00"
    private let clear:Character = "C"
    private let period:Character = "."
    
    private var formatter:NumberFormatter
    private let maximumIntegerDigits:Int
    private let maximumFractionDigits:Int
    private let negativeEnabled:Bool
    
    var valueString:String // 表示される値の文字列
    var lastValue:Double // 前回入力された演算対象の値
    var lastOperator:Character? // 前回入力された演算子
    var continueToInput:Bool // 数字の入力を継続するかどうか
    
    init() {
        
        maximumIntegerDigits = 14
        maximumFractionDigits = 3
        negativeEnabled = false
        
        formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        
        valueString = "0"
        lastValue = 0
        lastOperator = nil
        continueToInput = false
    }
    
    convenience init(intValue value:Int) {
        self.init()
        self.valueString = String(format:"%ld", value)
    }
    
    func reset() {
        valueString = "0"
        lastValue = 0
        lastOperator = nil
        continueToInput = false
    }
    
    func inputDigit(_ t:String) -> Bool{
        let digit = Character(t)
        guard digits.contains(digit) else {
            return false
        }
        if !continueToInput {
            if digit == "0" && lastOperator == nil {
                reset()
                return true
            }
            valueString = t
            continueToInput = true
        } else {
            let comps = valueString.components(separatedBy: String(period))
            let maxDigits = comps.count == 1 ? maximumIntegerDigits : maximumFractionDigits
            if comps.last!.count == maxDigits {
                return false
            }
            valueString.append(digit)
        }
        return true
    }
    
    func inputDoubleZero() -> Bool{
        if inputDigit("0") {
            _ = inputDigit("0") // 2つ目のゼロは入力できなくてもエラーにはしない
            return true
        } else { // 何も入力できないときのみエラー
            return false
        }
    }
    
    func inputPeriod() {
        if !continueToInput {
            // 非入力モードでピリオドが最初に入力されたら"0."になる
            valueString = "0"
            valueString.append(".")
            continueToInput = true
        } else {
            if !valueString.contains(period) {
                valueString.append(period)
            }
        }
    }
    
    func inputClear() {
        reset()
    }
    
    func calculate(_ t:String) throws {
        let inputOperator = Character(t)
        guard operators.contains(Character(t)) else {
            throw CalculateError.fatal
        }
        let value = Double(valueString)!
        
        if !continueToInput { // 入力モードではない
            lastValue = value // 現在の値を計算対象にする
        } else {
            if lastOperator == nil { // 演算中ではない
                lastValue = value // 現在の値を計算対象にする
            } else { // 演算中
                switch lastOperator { // 計算対象となる値を更新
                case "+":
                    lastValue += value
                case "-":
                    lastValue -= value
                case "/":
                    lastValue /= value
                case "*":
                    lastValue *= value
                default:
                    break
                }
                if !negativeEnabled && lastValue < 0 { // 負の数を許容しない
                    reset()
                    throw CalculateError.negativeValue
                }
                valueString = String(format:"%f", lastValue) // 表示用の値を更新
            }
            
            let comps = valueString.components(separatedBy: ".")
            if comps[0].count > maximumIntegerDigits {// 整数部分がオーバーフロー
                reset()
                throw CalculateError.calculateOverflow
            } else if comps.count == 2 { // 小数点あり
                var fraction = comps[1] // 少数部分
                for c in comps[1].reversed() { // 小数点以下の末尾の0を削除
                    if c == "0" {
                        fraction.removeLast()
                    } else {
                        break
                    }
                }
                valueString = comps[0] // 整数部分
                if fraction.count > 0 { // 小数点以下が0ではない
                    valueString.append(".")
                    valueString.append(fraction) // 少数部分を付加
                }
            }
        }
        lastOperator = inputOperator == "=" ? nil : inputOperator // 演算子を記憶
        continueToInput = false // 入力中モードの解除
        
    }
    
    func input(text:String) -> CalculateError {
        if text.count == 1 && digits.contains(Character(text)) { // 数字入力
            if !inputDigit(text)  {
                return .inputOverflow
            }
        } else if text == doubleZero { // "00"入力
            if !inputDoubleZero() {
                return .inputOverflow
            }
        } else if text.count == 1 && operators.contains(Character(text)) { // 演算子入力（"="も含む）
            do {
                try calculate(text)
            } catch CalculateError.negativeValue {
                return .negativeValue
            } catch CalculateError.calculateOverflow {
                return .calculateOverflow
            } catch {
                return .fatal
            }
        } else if text == String(period) { // ピリオド入力
            inputPeriod()
        } else if text == String(clear) { // クリア
            inputClear()
        }
        return .noError
    }
    
    func displayString() -> String {
        let comps = valueString.components(separatedBy: String(period))
        if comps.count == 2 {
            formatter.minimumFractionDigits = min(maximumFractionDigits, comps[1].count)
        } else {
            formatter.minimumFractionDigits = 0
        }
        let value = Double(valueString)!
        var string = formatter.string(from: NSNumber(value: value))!
        if valueString.last == period {
            string.append(period)
        }
        return string
    }
    
    func doubleValue() -> Double {
        return Double(valueString)!
    }
    
    func intValue() -> Int {
        
        return Int(floor(doubleValue()))
    }
}
