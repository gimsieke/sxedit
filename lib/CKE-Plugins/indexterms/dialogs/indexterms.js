


CKEDITOR.dialog.add("indextermsDialog", function(editor){
    return {
        "title": "Index Term Properties",
        "minWidth": 400,
        "minHeight": 100,

        "contents": [
            {
                "id": "indexterm",
                "label": "Index Term",
                "elements":[
                    {
                        "type": 'text',
                        "id": 'iterm-primary',
                        "label": 'Primary Indexterm',
                        "validate": CKEDITOR.dialog.validate.notEmpty("Primary Index-Term cannot be empty")
                    },
                    {
                        "type": 'text',
                        "id": 'iterm-secondary',
                        "label": 'Secondary Indexterm'
                    },
                    {
                        "type": 'text',
                        "id": 'iterm-tertiary',
                        "label": 'Tertiary Indexterm'
                    }
                ]
            }
        ],

        "onOk": function(){
            var primaryIT = this.getValueOf("indexterm", "iterm-primary");
            var secondaryIT = this.getValueOf("indexterm", "iterm-secondary");
            var tertiaryIT = this.getValueOf("indexterm", "iterm-tertiary");

            console.log(primaryIT);

            var indexSpan = editor.document.createElement("span");

            indexSpan.setAttribute("class", "indexterm");

            var priSpan = editor.document.createElement("span");
            priSpan.setAttribute("class", "indexterm-pri");
            priSpan.setText(primaryIT);

            var secSpan = editor.document.createElement("span");
            secSpan.setAttribute("class", "indexterm-sec");
            if(typeof(secondaryIT) !== "string" || secondaryIT.length > 0)
                secSpan.setText(secondaryIT);


            var terSpan = editor.document.createElement("span");
            terSpan.setAttribute("class", "indexterm-ter");
            if(typeof(tertiaryIT) !== "string" || tertiaryIT.length > 0)
                terSpan.setText(tertiaryIT);
            

            indexSpan.append(priSpan);
            indexSpan.append(secSpan);
            indexSpan.append(terSpan);

            editor.insertElement(indexSpan);
        }
    }
});
