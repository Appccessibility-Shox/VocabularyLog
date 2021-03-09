// heavy inspiration drawn from Stack Overflow user, stevendaniels.

document.addEventListener("DOMContentLoaded", function(event) {
    safari.extension.dispatchMessage("Hello World!");
});

document.addEventListener("webkitmouseforcedown", function(event) {
    const s = window.getSelection();
    const range = s.getRangeAt(0);
    const node = s.anchorNode;
    console.log(getClickedWord())
    console.log(getAppropriateSentence(range.startOffset, range.endOffset, node, range.toString().trim()))
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
    while (range.toString().replace(/\n/g, " ").indexOf(" ") != 0 && range.startOffset != 0) {
        range.setStart(node, range.startOffset - 1);
    }
    if (range.toString().replace(/\n/g, " ").charAt(0) == " ") {
        range.setStart(node, range.startOffset + 1);
    }
    while (range.toString().replace(/\n/g, " ").indexOf(' ') == -1 && range.toString().trim() != '' && range.endOffset + 1 < s.baseNode.wholeText.length) {
        range.setEnd(node, range.endOffset + 1);
    }
    if (range.toString().replace(/\n/g, " ").charAt(range.endOffset) == " ") {
        range.setEnd(node, range.endOffset - 1);
    }
    const lastChar = range.toString().charAt(range.toString().length - 1);
    if (!/^[a-zA-Z0-9]*$/.test(lastChar)) {
      range.setEnd(node, range.endOffset - 1);
    }
    return range.toString().trim()
}

safari.self.addEventListener("message", printToConsole)

function printToConsole(event) {
    if (event.name == "printToConsole") {
        console.log(event.message)
    }
}
