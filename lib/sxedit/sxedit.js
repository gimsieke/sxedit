Sxedit = {};

var onSaxonLoad = function() {
  Sxedit.parseParams = function (params) {
    var splitList = params.split(/\s+/);
    var retHash = {};
    for (var i = 0; i < splitList.length; i++) {
      var splitParam = splitList[i].split("=");
      retHash[splitParam[0]] = splitParam[1];
    }
    return retHash;
  };
  Sxedit.transform = function(document, stylesheet, params) {
    return Saxon.run( {
      stylesheet: stylesheet,
      source: document,
      method: "transformToDocument",
      parameters: Sxedit.parseParams(params)
    }).getResultDocument();
  };
  Sxedit.transformToHTML = function(node, stylesheet, params) {
    return Saxon.run( {
      stylesheet: stylesheet,
      source: node,
      method: "transformToDocument",
      parameters: Sxedit.parseParams(params)
    }).getResultDocument();
  };
  Sxedit.apply_main_template = function(document, stylesheet) {
    return Saxon.run( {
      stylesheet: stylesheet,
      initialTemplate: "main",
      source: document,
      method: "transformToDocument"
    }).getResultDocument();
  };
  Sxedit.generate_xpath_2_evaluator = function(xpath) {
    return Saxon.run( {
      stylesheet: "xslt/xpath-2-evaluator.xsl",
      initialTemplate: "main",
      parameters: {
        xpath: xpath
      },
      method: "transformToDocument"
    }).getResultDocument();
  };
  Sxedit.generate_xslt_2_evaluator = function(xslt) {
    return Saxon.run( {
      stylesheet: "xslt/xslt-2-evaluator.xsl",
      source: Saxon.parseXML(xslt),
      method: "transformToDocument"
    }).getResultDocument();
  };
}


/*
 * Taken from http://thiscouldbebetter.wordpress.com/2012/12/18/loading-editing-and-saving-a-text-file-in-html5-using-javascrip/
 * Copyright by the anonymous blogger. License unknown. */
Sxedit.saveTextAsFile = function (textToWrite, fileNameToSaveAs)
{
	var textFileAsBlob = new Blob([textToWrite], {type:'application/XML'});

	var downloadLink = document.createElement("a");
	downloadLink.download = fileNameToSaveAs;
	downloadLink.innerHTML = "Download File";
	if (window.webkitURL != null)
	{
		// Chrome allows the link to be clicked
		// without actually adding it to the DOM.
		downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob);
	}
	else
	{
		// Firefox requires the link to be added to the DOM
		// before it can be clicked.
		downloadLink.href = window.URL.createObjectURL(textFileAsBlob);
		downloadLink.onclick = destroyClickedElement;
		downloadLink.style.display = "none";
		document.body.appendChild(downloadLink);
	}

	downloadLink.click();
}
