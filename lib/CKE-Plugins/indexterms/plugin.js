


CKEDITOR.plugins.add('indexterms', {
    "icons": "indexterms",
    "init" : function(editor){
        editor.addCommand("indextermsDialog", new CKEDITOR.dialogCommand("indextermsDialog"));
        editor.ui.addButton("indexterms", {
            "label": "Insert Index Term", 
            "command" : "indextermsDialog",
            "toolbar": "insert"});

        CKEDITOR.dialog.add("indextermsDialog", this.path + "dialogs/indexterms.js");
    }
});
