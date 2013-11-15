sxedit
======

XML editor based on Saxon CE, CKEditor, and BaseX

As file storage, sxedit currently relies on a BaseX server with RESTXQ. 
You need to install a custom [XQuery module](lib/basex/restxq/sxedit.xqm) 
in its webapp directory.

Editing files on your hard disk is possible in principle, but there is
currently no cross-browser, sans-plugin way to save your work. We will
be adding an XML serialization via data: URI so that you can copy and 
paste the results from a browser tab.

sxedit needs to be customized for each XML vocabulary. There is currently
a [TEI P5 customization](customizations/TEI_P5) in preparation.
