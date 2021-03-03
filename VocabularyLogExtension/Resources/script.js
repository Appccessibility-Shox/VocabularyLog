document.addEventListener("DOMContentLoaded", function(event) {
    safari.extension.dispatchMessage("Hello World!");
});

document.addEventListener("contextmenu", handleContextMenu, false);
function handleContextMenu(event) {
    var selectedText =  window.getSelection().toString().trim();
    let surroundingBlurb = window.getSelection().baseNode.parentElement.innerText
    var exampleSentences = surroundingBlurb.match( /[^\.!\?]+[\.!\?]+/g )
    if (exampleSentences == null) {
        exampleSentences = [window.getSelection().baseNode.textContent]
    }
    console.log(exampleSentences)
    var appropriateSentence = ""
    for (var sentence of exampleSentences) {
        if (sentence.includes(selectedText)) {
            appropriateSentence = sentence.trim()
            console.log("appropriateSentence", appropriateSentence)
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
