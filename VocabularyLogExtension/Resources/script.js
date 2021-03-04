document.addEventListener("DOMContentLoaded", function(event) {
    safari.extension.dispatchMessage("Hello World!");
});

document.addEventListener("contextmenu", handleContextMenu, false);
function handleContextMenu(event) {
    var selectedText =  window.getSelection().toString().trim();
    var startsOnCharacterNumber = window.getSelection().baseOffset
    var endsOnCharacterNumber = startsOnCharacterNumber + selectedText.length
    var nodeText = window.getSelection().baseNode.textContent.toString()
    var bufferedText = nodeText.slice(Math.max(startsOnCharacterNumber-3, 0), endsOnCharacterNumber+3)
    let surroundingBlurb = window.getSelection().baseNode.parentElement.innerText
    var exampleSentences = nlp(surroundingBlurb).sentences().data().map(object => object.text)
    if (exampleSentences == null) {
        exampleSentences = [window.getSelection().baseNode.textContent]
    }
    var appropriateSentence = ""
    for (var sentence of exampleSentences) {
        if (sentence.includes(bufferedText)) {
            appropriateSentence = sentence.trim()
            console.log("appropriateSentence", appropriateSentence)
        }
    } // insufficient to grab things like "he" in "Yolo. He is the man" since the buffered text isn't in any of those sentences (it includes a period). Hence, the next loop is needed.
    if (appropriateSentence == "") {
        for (var sentence of exampleSentences) {
            if (sentence.includes(selectedText)) {
                appropriateSentence = sentence.trim()
                console.log("appropriateSentence", appropriateSentence)
            }
        }
    }
    safari.extension.setContextMenuEventUserInfo(event,
        { "term": selectedText, "exampleSentence": appropriateSentence, "url": window.location.href });
}

safari.self.addEventListener("message", printToConsole)
function printToConsole(event) {
    if (event.name == "printToConsole") {
        console.log(event.message)
    }
}

// problem: multiple occurences of a word in text can cause it to grab the wrong sentece.
