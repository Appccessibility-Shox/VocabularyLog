// heavy inspiration drawn from Stack Overflow users, stevendaniels, kennytm and k.l. (k-l)

document.addEventListener("DOMContentLoaded", function(event) {
    safari.extension.dispatchMessage("Hello World!");
});

function isLink(element) {
    while (element) {
        if (element.tagName == 'A') {
            return true
        }
        else {
            element = element.parentElement;
        }
    }
    return false
}

var mousedowntarget
var mouseMovedSinceMouseDown = false
var mousePosX
var mousePosY

document.addEventListener("mousedown", function(event) {
    mousedowntarget = event.target
    mouseMovedSinceMouseDown = false
    mousePosX = event.clientX
    mousePosY = event.clientY
})

document.addEventListener('mousemove', function(event) {
    if (Math.abs(event.clientX - mousePosX) > 2 || Math.abs(event.clientY - mousePosY) > 2) {
        mouseMovedSinceMouseDown = true
    }
})

document.addEventListener("webkitmouseforcedown", function(event) {
    const range = window.getSelection().getRangeAt(0);
    const node = window.getSelection().anchorNode;
    anAnchor = isLink(event.target)

    const term = getClickedWord()
    var regExp = /[a-zA-Z]/g;
    if (regExp.test(term) && !anAnchor && mousedowntarget == event.target && !mouseMovedSinceMouseDown){
        const appropriateSentence = getAppropriateSentence(range.startOffset, range.endOffset, node, range.toString().trim())
        safari.extension.dispatchMessage("forcepress", {"term": term, "exampleSentence": appropriateSentence, "url": window.location.href})
    }
})

document.addEventListener("contextmenu", handleContextMenu, false);

function handleContextMenu(event) {
    var selectedText =  window.getSelection().toString().trim();
    var startsOnCharacterNumber = window.getSelection().baseOffset
    var endsOnCharacterNumber = startsOnCharacterNumber + selectedText.length
    var appropriateSentence = getAppropriateSentence(startsOnCharacterNumber, endsOnCharacterNumber, window.getSelection().baseNode, selectedText)
    safari.extension.setContextMenuEventUserInfo(event, {"term": selectedText, "exampleSentence": appropriateSentence, "url": window.location.href});
}

function getAppropriateSentence(startOffset, endOffset, node, selectedText) {
    var startsOnCharacterNumber = startOffset
    var endsOnCharacterNumber = endOffset
    var nodeText = node.textContent.toString()
    var bufferedText = nodeText.slice(Math.max(startsOnCharacterNumber-3, 0), endsOnCharacterNumber+3)
    let surroundingBlurb = node.parentElement.innerText
    var exampleSentences = nlp(surroundingBlurb).sentences().data().map(object => object.text)
    if (exampleSentences == null) {
        exampleSentences = [node.textContent]
    }
    var appropriateSentence = ""
    for (var sentence of exampleSentences) {
        if (sentence.includes(bufferedText)) {
            appropriateSentence = sentence.trim()
        }
    } // insufficient to grab things like "he" in "Yolo. He is the man" since the buffered text isn't in any of those sentences (it includes a period). Hence, the next loop is needed.
    if (appropriateSentence == "") {
        for (var sentence of exampleSentences) {
            if (sentence.includes(selectedText)) {
                appropriateSentence = sentence.trim()
            }
        }
    }
    return appropriateSentence
}

function getClickedWord() {
    const s = window.getSelection();
    var range = s.getRangeAt(0);
    var node = s.anchorNode;
    
    while (!(range.toString().replace(/\n/g, " ").indexOf(" ") == 0 || range.toString().replace(/\n/g, " ").indexOf("-") == 0) && range.startOffset != 0) {
        range.setStart(node, range.startOffset - 1);
    }
    if (range.toString().replace(/\n/g, " ").charAt(0) == " " || range.toString().replace(/\n/g, " ").charAt(0) == "-") {
        range.setStart(node, range.startOffset + 1);
    }
    while (!(range.toString().replace(/\n/g, " ").indexOf(' ') != -1 || range.toString().replace(/\n/g, " ").indexOf('-') != -1) && range.toString().trim() != '' && range.endOffset + 1 < s.baseNode.wholeText.length) {
        // usually returns true. REturns false when " " exists. Want to return false when either
        range.setEnd(node, range.endOffset + 1);
    }
    if (range.toString().replace(/\n/g, " ").charAt(range.endOffset) == " ") {
        range.setEnd(node, range.endOffset - 1);
    }

    var word = range.toString().trim()

    // remove punctuation from word boundary (K.L. on Stack Overflow)
    word = word.replace(/\b[-.,()&$#!\[\]{}"']+\B|\B[-.,()&$#!\[\]{}"']+\b/g, "")
    return word
}

safari.self.addEventListener("message", printToConsole)

function printToConsole(event) {
    if (event.name == "printToConsole") {
        console.log(event.message)
    }
}
