


CKEDITOR.plugins.add('footnotes', {
    "icons": "footnotes",
    "init" : function(editor){
        editor.addCommand("footnotesDialog", new CKEDITOR.dialogCommand("footnotesDialog"));
        editor.ui.addButton("footnotes", {
            "label": "Insert Footnote", 
            "command" : "footnotesDialog",
            "toolbar": "insert"});

        CKEDITOR.dialog.add("footnotesDialog", this.path + "dialogs/footnotes.js");
    }
});
