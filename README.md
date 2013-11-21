sxedit
======

XML editor based on Saxon CE, CKEditor, and BaseX

As file storage, sxedit currently relies on a BaseX server with RESTXQ. 
You need to install a custom [XQuery module](lib/basex/restxq/sxedit.xqm) 
in its webapp directory.

But you can also start editing from scratch and download the XML file
to your hard disk. Please note that due to security constraints of the browsers,
you need to serve the main editor page, currently only 
[for TEI P5](customizations/TEI_P5/sxedit_TEI.html), from a Web server.
Editing with a local editor page is possible if you set an appropriate option in your
browser. For Chrome, it is `-allow-file-access-from-files`. In Firefox,
go to (about:config) and switch `security.fileuri.strict_origin_policy`
to `false`.

After editing, you can download the XML file. This seems to be working
in Chrome only, for the time being.

sxedit needs to be customized for each XML vocabulary and for each
storage backend. Please look
at the [TEI P5 customization](customizations/TEI_P5) for an example.
