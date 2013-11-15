function xser() { 
 	return (new XMLSerializer()).serializeToString(document.getElementById("sxedit-src"))
		.replace(/&nbsp;/g, '&#xa0;')
		.replace(/<whatwg-members-members-are-small-like-this>([^<]+?)<\/whatwg-members-members-are-small-like-this><(\/?)[-_a-z]+/g, '<$2$1')
		.replace(/^<div id="sxedit-src">/s, '<?xml version="1.0" encoding="utf-8"?>')
		.replace(/<\/div>$/s, '')
}

function setStyleForId(id, prop, val) { 
	document.getElementById(id).style[prop] = val;
}
