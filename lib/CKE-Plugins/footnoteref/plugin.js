


CKEDITOR.plugins.add('footnoteref', {
    "icons": "footnoteref",
    "init" : function(editor){
        editor.addCommand("footnoterefDialog", new CKEDITOR.dialogCommand("footnoterefDialog"));
        editor.ui.addButton("footnoteref", {
            "label": "Insert Footnote Reference", 
            "command" : "footnoterefDialog",
            "toolbar": "insert"});

        CKEDITOR.dialog.add("footnoterefDialog", this.path + "dialogs/footnoteref.js");
    }
});
