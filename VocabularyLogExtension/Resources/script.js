document.addEventListener("DOMContentLoaded", function(event) {
    safari.extension.dispatchMessage("Hello World!");
});

document.addEventListener("contextmenu", handleContextMenu, false);
function handleContextMenu(event) {
    var selectedText =  window.getSelection().toString();
    let surroundingBlurb = window.getSelection().baseNode.parentElement.innerText
    let exampleSentences = surroundingBlurb.match( /[^\.!\?]+[\.!\?]+/g )
    var appropriateSentence = ""
    for (var sentence of exampleSentences) {
        if (sentence.includes(selectedText)) {
            appropriateSentence = sentence
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
