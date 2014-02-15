


CKEDITOR.plugins.add('footnotes', {
    "icons": "footnotes",
    "init" : function(editor){
        editor.addCommand("footnotesDialog", new CKEDITOR.dialogCommand("footnotesDialog"));
        editor.addCommand("footnoterefDialog", new CKEDITOR.dialogCommand("footnoterefDialog"));

        editor.ui.addButton("footnotes", {
            "label": "Insert Footnote", 
            "command" : "footnotesDialog",
            "toolbar": "insert",
            "icon" : this.path + "icons/footnotes.png"});

        editor.ui.addButton("footnoteref", {
            "label": "Insert Footnote Reference", 
            "command" : "footnoterefDialog",
            "toolbar": "insert",
            "icon": this.path + "icons/footnoteref.png"});

        CKEDITOR.dialog.add("footnotesDialog", this.path + "dialogs/footnotes.js");
    }
});
