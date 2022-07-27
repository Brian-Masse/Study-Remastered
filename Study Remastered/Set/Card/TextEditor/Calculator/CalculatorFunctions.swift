import SwiftUI
import Swift
import Combine

class EquationTextHandler: ObservableObject {
    
    static let cursorJumps = [ "[", "]", "\\", "#", ":", "<", ">"]
    enum Direction {
        case left
        case right
    }
    
    @Published var equationText: EquationText
    var textFieldViewModel: RichTextFieldViewModel
    
    lazy var cursorPos: String.Index = text.startIndex
    var observer: AnyCancellable!
    
    var text: String {
        get {
            var value = equationText.text
            value.removeAll(where: { $0 == "|" })
            return value
        }set { equationText.text = newValue }
    }
    
    init(_ textFieldViewModel: RichTextFieldViewModel) {
    
        self.textFieldViewModel = textFieldViewModel
        self.equationText = EquationText(textFieldViewModel, with: textFieldViewModel.text, type: "", isPrimative: false)
    
        self.observer = equationText.objectWillChange.sink(){self.objectWillChange.send()}
        self.text = prepareText()
        moveCursor(direction: .left)
        
        self.setupObserver()
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    func setupObserver() {
        let name = NSNotification.Name(rawValue: RichTextFieldViewModel.attributeDidChangeKey)
        NotificationCenter.default.addObserver(self, selector: #selector(setupEquationText), name: name, object: nil)
    }
    
    @objc func setupEquationText() { equationText.setup() }
    
    func returnDisplayabledText() -> String {
        var copy = text
        copy.removeAll(where: { $0 == "_" || $0 == "|" })
        return copy
    }
    
    func copy() -> EquationTextHandler {
        return EquationTextHandler(self.textFieldViewModel.copy())
    }
    
    //MARK: Spacer function
    
    func fillWithSpace(_ value: String) -> String {
        var text = value
        var activeIndex = text.startIndex
        while activeIndex != text.index(before: text.endIndex) {
        
            if String( text[activeIndex] ) == "["  && String( text[text.index(after: activeIndex)]) == "]" {
                text.insert("_", at: text.index(after: activeIndex))
            }
            
            activeIndex = text.index(after: activeIndex)
        }
        return text
    }
    
    func prepareText() -> String {
        var text = self.text
        text.removeAll(where: {$0 == "_" || $0 == "|"})
        
        if text.count == 0 {return "_"}
        
        text.insert("_", at: text.startIndex)
        text.insert("_", at: text.endIndex)
        text = fillWithSpace(text)
        
        text.insert("|", at: text.index(after: cursorPos))
    
        return text
    }
    
    //MARK: move functions
    
    func moveCursor(direction: Direction) {
        
        if text.isEmpty { return }
        
        func move() {
            if direction == .left && cursorPos != text.startIndex { cursorPos = text.index(before: cursorPos) }
            if direction == .right && cursorPos != text.index(before:  text.endIndex ) { cursorPos = text.index(after: cursorPos) }
        }
        
        move()
        
        var current = String(text[cursorPos])
        var after = cursorPos == text.index(before:  text.endIndex ) ? current : String(text[ text.index(after: cursorPos) ])
        
        while EquationTextHandler.cursorJumps.contains(current) && (EquationTextHandler.cursorJumps.contains(after) || after == "_") {
            
            //jumps over functinos
            if text[cursorPos] == "#" && direction == .right {
                let closure = EquationText.findClosure(type: "<", in: String(text[ cursorPos... ]))
                let index = text.index( cursorPos, offsetBy: String(text[closure]).count + 1 )
                cursorPos = text.index(after: index)
            }
            if text[cursorPos] == ">" && direction == .left {
                let closure = EquationText.findClosure(type: ">", in: String(String(text[ ...cursorPos ]).reversed()) )
                let index = text.index( cursorPos, offsetBy: -String( text[closure] ).count - 1 )
                cursorPos = text.index(before: index)
            }
            
            else { move() }
            if cursorPos == text.startIndex || cursorPos == text.index(before:  text.endIndex ) {break}
            
            current = String(text[cursorPos])
            after = String(text[ text.index(after: cursorPos) ])
        
        }
        
        text = prepareText()
    }

    //MARK: delete functions
    
    func deleteChar(_ text: String) -> String {
        var temp = text
        temp.remove(at: cursorPos)
        cursorPos = text.index(before: cursorPos)
        return temp
    }
    
    func delete() {
        
        var text = self.text
        
        if cursorPos == text.startIndex { return }
        if text[cursorPos] == "_" { cursorPos = text.index(before: cursorPos) }
        if text[cursorPos] == "(" || text[cursorPos] == ")" { text = deleteParenthesis(text[cursorPos]) }
        
        else if !EquationTextHandler.cursorJumps.contains(String(text[cursorPos])) { text = deleteChar( text ) }
        
        //for deleting entire functions
        else if String(text[cursorPos]) == "]" {
            
            let invertedSubString = String(String(text[...cursorPos]).reversed())
            let firstClosure = EquationText.findClosure(type: "]", in: invertedSubString)
            let secondString = String(String(text[...text.index( cursorPos, offsetBy: -String(invertedSubString[firstClosure]).count - 2)]).reversed())
            let secondClosure = EquationText.findClosure(type: ">", in: secondString)
            
            let totalLength = String(invertedSubString[firstClosure]).count + String(secondString[secondClosure]).count + 4
            let newCursor = text.index(cursorPos, offsetBy: -totalLength - 1)
            text.removeSubrange(text.index( cursorPos, offsetBy: -(totalLength ) )...cursorPos)

            cursorPos = newCursor
        }
        
        //deleting a function but keeping the contents
        else if String(text[cursorPos]) == "[" {
            
            let oldCursor = cursorPos
            //find the functin that the component belongs to
            var depth = 0
            while text[cursorPos] != ">" || depth > 0 {
                cursorPos = text.index(before: cursorPos)
                if text[cursorPos] == "]" { depth += 1 }
                if text[cursorPos] == "[" { depth -= 1 }
            }
            
            //extract all the components from that function
            let subString = String(text[cursorPos...])
            let closure = EquationText.findClosure(type: "[", in: subString )
            var content = String(subString[closure])
            
            var extractedItems: [String] = []
            var numOfExtractedItemsToSkip = 0
            
            while content.count != 0 {
                if content.contains("[") {
                    let closure = EquationText.findClosure(type: "[", in: content)
                    
                    let offset = extractedItems.joined().count + (extractedItems.count * 3) + 1 + String(content[closure]).count
                    if text.index( cursorPos, offsetBy: offset ) < oldCursor { numOfExtractedItemsToSkip += 1 }
                    if !(content[closure].count == 1 && content[closure] == "_") {
                        extractedItems.append( String(content[ closure ]) )
                    }else { extractedItems.append("") }
                    content.removeSubrange(...content.index(after: closure.upperBound))
                    
                }else {
                    extractedItems.append(content)
                    content.removeAll()
                }
            }
            
            //destroy from the begining of the function to the end of its content, then reinsert the extracted values
            cursorPos = text.index(after: cursorPos)
            let invertedSubString = String(text[...cursorPos].reversed())
            let functionClosure = EquationText.findClosure(type: ">", in: invertedSubString)
            let start = text.index( cursorPos  , offsetBy: -(String(invertedSubString[functionClosure]).count + 3)  )   //start is the begining of a function
            let count = String(subString[closure]).count + 1                                                            //count is the number of spaces in content
            
            text.removeSubrange(start...text.index(cursorPos, offsetBy: count ))
            cursorPos = text.index(before: start)
            text.insert(contentsOf: extractedItems.joined(), at: cursorPos)
         
            if numOfExtractedItemsToSkip != 0 { cursorPos = text.index(cursorPos, offsetBy:  extractedItems[0..<numOfExtractedItemsToSkip].joined().count ) }
        }
        
        self.text = fillWithSpace(text)
        self.text = prepareText()
//        equationText.setup()
    }
    
    func deleteParenthesis(_ type: Character) -> String {
        
        var text = self.text
        
        let subString = type == "(" ? String(text[ cursorPos... ]) : String(String(text[ ...cursorPos ]).reversed())
        let end = type == "(" ? ")" : "("
        let dir = type == "(" ? 1: -1
        
        var activeIndex = subString.startIndex
        while String(subString[activeIndex]) != end && activeIndex != subString.index(before: subString.endIndex) {
            activeIndex = subString.index(after: activeIndex)
        }
        
        let oldCursor = cursorPos
        
        cursorPos = text.index( cursorPos, offsetBy: (String(subString[..<activeIndex]).count) * dir )
        text = deleteChar(text)
        cursorPos = type == "(" ? oldCursor: text.index(before: oldCursor)
        text = deleteChar(text)
        
        return text
    }
    
    //MARK: add functions
    
    func addString(_ value: String) {
        
        var temp = text
        if (temp[cursorPos] == "_" && cursorPos != temp.startIndex) {
            temp.remove(at: cursorPos)
            cursorPos = temp.index(before: cursorPos)
        }
        temp.insert(contentsOf: value, at: text.index(after: cursorPos) )
        cursorPos = temp.index(cursorPos, offsetBy: value.count )
        text = temp
        text = prepareText()
    }
    
        //type, collects, componentCount
    func addFunc( type: String, componentCount: Int ) {
        var code = ""
        if !CalculatorModel.collectingFunctions.contains(type) || componentCount != 2 {
            code = "#<\(type)>["
            for _ in 0..<componentCount {
                code.append( "\\[_]" )
            }
            code.append(contentsOf: "]")
        } else {
            var content = ""
            insertParenthesis(")")
            cursorPos = text.index(before: cursorPos)
            if text[cursorPos] == "(" {
                content = "_"
                var temp = text
                temp.removeSubrange( cursorPos...text.index(after: cursorPos) )
                text = fillWithSpace(temp)
                cursorPos = text.index(before: cursorPos)
            }
            else {
                let reversedString = String(text[...text.index(after: cursorPos) ].reversed())
                let closure = EquationText.findClosure(type: ")", in: reversedString)
                content = String(String(reversedString[closure]).reversed())
                
                var temp = text
                temp.removeSubrange( text.index(cursorPos, offsetBy: -content.count)...text.index(after: cursorPos)   )
                cursorPos = text.index(cursorPos, offsetBy: -content.count - 1)
                text = fillWithSpace(temp)
                
                text = prepareText()
            }
            code = "#<\(type)>[\\[\(content)]\\[_]]"
        }
        addString(code)
        moveCursor(direction: .left)
        text = prepareText()
//        equationText.setup()
    }
    
    func insertParenthesis(_ type: String) {

        addString(type)
        
        let main = type == "("  ? "[": "]"
        let alt = EquationText.closurers[main]!
        
        let oldCursor = cursorPos
        var depth = 0
        
        var nextIndex = cursorPos
        
        var condition: Bool {
            if type == "(" { return (String(text[nextIndex]) != alt || depth != 0) && nextIndex != text.index(before: text.endIndex) }
            else { return (String(text[text.index(after: nextIndex)]) != alt || depth != 0) && text.index(after: nextIndex) != text.startIndex }
        }
        
        while condition {
            
            if String(text[cursorPos]) == main { depth += 1 }
            if String(text[cursorPos]) == alt {depth -= 1}
            
            cursorPos = nextIndex
            if cursorPos == text.endIndex || cursorPos == text.startIndex { break }
            
            if type == "(" { nextIndex = text.index(after: cursorPos) }
            if type == ")" { nextIndex = text.index(before: cursorPos) }
        }
        addString( EquationText.closurers[type]! )
        cursorPos = type == ")" ? text.index(after: oldCursor) : oldCursor
        text = prepareText()
    }
    
}




// MARK: EquationText
class EquationText: Hashable, ObservableObject {
    
    static let closurers = [ "[": "]",
                             "<": ">",
                             "]": "[",
                             ">": "<",
                             "(": ")",
                             ")": "("
    ]
    
    var textFieldViewModel: RichTextFieldViewModel
    
    @Published var text: String = ""
    {                  //this contains all of the text for the line. It does not contain wehether its wrapper
        didSet { setup() }
    }
    
    var type: String = ""                               //this is the type of its wrapper
    var isPrimative: Bool = true                        //is true if there is only text, there cannot be a wrapper inside it
    @Published var primatives: [EquationText] = []      //these are all of the components DIRECTLY BELOW this one
    
    var hasComponent: Bool = false
    @Published var components: [EquationText] = []      //these are seperated groups of data for things such as fractions and integrals
    
    init (text: String, type: String, hasComponent: Bool = false, isPrimative: Bool = true, textFieldViewModel: RichTextFieldViewModel) {
        self.text = text
        self.type = type
        
        self.textFieldViewModel = textFieldViewModel
        
        self.hasComponent = hasComponent
        self.isPrimative = !isPrimative ? false : self.isPrimative(text: text)
        self.setup()
    }
    
    init (_ textFieldViewModel: RichTextFieldViewModel, with text: String, type: String, hasComponent: Bool = false, isPrimative: Bool = true) {
        
        self.textFieldViewModel = textFieldViewModel
        self.text = text
        self.type = type
        
        self.hasComponent = hasComponent
        self.isPrimative = !isPrimative ? false : self.isPrimative(text: text)
        self.setup()
    }
    
    func setup() {
        
        components.removeAll()
        primatives.removeAll()
        
        if hasComponent { searchForComponents(in: text) }
        else if !self.isPrimative { splitIntoPrimatives(in: text) }
        
        guard let function = textFieldViewModel.setActiveViewModel else { return }
        function( textFieldViewModel )
//        print("setting up: \( TextFieldViewController.getMemoryAdress(of: textFieldViewModel) )")
        
        
    }
    
    @ViewBuilder static func wrapEquationText(primative: EquationText, primatives: [EquationText]) -> some View {
        HStack(spacing: 0) {
            if primative.isPrimative {
                EquationString()
                    .environmentObject(primative)
            }else {
                ForEach(primatives, id:\.self.hashValue) { primative in
                    EquationTextView(text: primative)
                }
            }
        }
    }
    
//    func createNewViewModel(with text: String) -> RichTextFieldViewModel {
//        var mutableText = text
//        mutableText.removeAll(where: { $0 == "_" })
//        let mutableAttributedString = NSMutableAttributedString(string: mutableText)
//        mutableAttributedString.setAttributes( textFieldViewModel.activeAttributes, range: NSRange(location: 0, length: mutableText.count))
//
//        let viewModel = RichTextFieldViewModel(mutableAttributedString, with: textFieldViewModel.activeAttributes, setActiveViewModel: textFieldViewModel.setActiveViewModel)
//
////        viewModel.viewController.setEditability(with: false)
////        viewModel.viewController.toggleAttributes(textFieldViewModel.activeAttributes)
//
//        return viewModel
//    }
    
    func splitIntoPrimatives(in text: String) {

        if text.isEmpty{ return }
        
        for enumeration in text.enumerated() {
    
            //creating non wrapped elements
            if (enumeration.element == "#" || enumeration.offset == text.count - 1)  {
                if !(enumeration.offset == 0 && text.count != 1) {
                    let offset = enumeration.offset == text.count - 1 ? enumeration.offset: enumeration.offset - 1
                        
                    let space = text.count == 1 ? text : String(text[ text.startIndex...text.index(text.startIndex, offsetBy: offset) ])
                    if !space.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        
//                        let newPrimative = EquationText(text: space, type: "" )
                        let newPrimative = EquationText( textFieldViewModel, with: space, type: "")
                        self.primatives.append(newPrimative)
                    }
                }
                
                //creating / pulling out non wrapped elements
                if enumeration.element == "#" {
                    
                    let start = text.index(text.startIndex, offsetBy: enumeration.offset)
                    let stringSubSection = String(text[ start..<text.endIndex ])
                    
                    let content = String(stringSubSection[ EquationText.findClosure(type: "[", in: stringSubSection) ])
                    let type = String(stringSubSection[ EquationText.findClosure(type: "<", in: stringSubSection) ])
                    
//                    let newPrimative = EquationText(text: content, type: type, hasComponent: true)
                    let newPrimative = EquationText(textFieldViewModel, with: content, type: type, hasComponent: true)
                    self.primatives.append( newPrimative )
                    
                    let remainingText = String( text[ text.index(start, offsetBy: content.count + type.count + 5    )... ]  )
                    splitIntoPrimatives(in: remainingText)
                    return
                }
            }
        }
    }
    
    func searchForComponents(in text: String) {
        for enumeration in text.enumerated() {
            if enumeration.element == "\\" || enumeration.element == "#" {
                
                let start = text.index(text.startIndex, offsetBy: enumeration.offset)
                let stringSubSection = String(text[ start..<text.endIndex ])
                let closure = EquationText.findClosure(type: "[", in: stringSubSection)
                
                if enumeration.element == "\\"  {
                    let content = String(stringSubSection[ closure ] )
//                    let newComponent = EquationText(text: content, type: "comp")
                    let newComponent = EquationText(textFieldViewModel, with: content, type: "comp")
                    components.append(newComponent)
                }else {
                    let remainingText = String( stringSubSection[ text.index(closure.upperBound, offsetBy: 2)... ])
                    searchForComponents(in: remainingText)
                    return
                }
            }
        }
    }
    
    func isPrimative( text: String ) -> Bool {
        for enumeration in text.enumerated() {
            if enumeration.element == "#" { return false }
        }
        return true
    }
    
    // given a string, returns the indecies of the cooresponding closure marks
    static func findClosure(type: Character, in text: String) -> ClosedRange<String.Index> {
        let firstIndex = text.firstIndex(of: type)!
        
        let endChar: Character = Character( EquationText.closurers[String(type)]!)
        var depth = 0
        
        var index = text.index(after: firstIndex)
        while text[index] != endChar || depth != 0 {
            if text[index] == type { depth += 1 }
            if text[index] == endChar { depth -= 1 }
            
            index = text.index(after: index)
        }
        return text.index(after: firstIndex)...text.index(before: index)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine( TextFieldViewController.getMemoryAdress(of: self) )
    }
    
    static func == (lhs: EquationText, rhs: EquationText) -> Bool {
        lhs.text == rhs.text && lhs.type == rhs.type
    }
}


//MARK: Equation View
struct EquationTextView: View  {
    
    @ObservedObject var text: EquationText
    
    static let trig =           [ "sin", "cos", "tan", "csc", "sec", "cot" ]
    static let inverseTrig =    [ "Asin", "Acos", "Atan", "Acsc", "Asec", "Acot" ]
    
    var body: some View {
        
        if text.type == "root" { Root(primative: text, primatives: text.primatives ) }
        if text.type == "advRoot" { AdvancedRoot(primative: text, primatives: text.primatives ) }
        else if text.type == "frac" { Fraction(primative: text, primatives: text.primatives) }
        else if text.type == "exp" { Exponent(primative: text, primatives: text.primatives) }
        else if text.type == "abs" { ABS(primative: text, primatives: text.primatives) }
        else if text.type == "log" { Log(primative: text, primatives: text.primatives) }
        else if text.type == "lim" { limit(primative: text, primatives: text.primatives) }
        else if text.type == "deriv" { Derivative(primative: text, primatives: text.primatives) }
        else if text.type == "integ" { Integral(primative: text, primatives: text.primatives) }
        else if text.type == "sum" { Summation(primative: text, primatives: text.primatives) }
        else if text.type == "ln" { ln(primative: text, primatives: text.primatives) }
        
        else if EquationTextView.trig.contains(text.type) { Trig(primative: text, primatives: text.primatives, function: text.type) }
        else if EquationTextView.inverseTrig.contains(text.type) {
            var temp = text.type
            let _ = temp.removeFirst()
            InvsereTrig(primative: text, primatives: text.primatives, function: temp ) }
        
        
        else if text.isPrimative && text.type == "" {
            EquationString()
                .environmentObject(text)
        }
        else {
            HStack(spacing: 0) {
                ForEach(text.primatives, id: \.self.hashValue) { primative in
                    EquationTextView(text: primative)
                }
            }
        }
    }
}





