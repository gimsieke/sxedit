
CKEDITOR.dialog.add("indextermDialog", function(editor){
    return {
        "title": "Indexterm Properties",
        "minWidth": 400,
        "minHeight": 250,

        "contents":[
            {
                "id": "index",
                "label": "Indexterm Properties",
                "elements": [
                    {
                        "type": 'text',
                        "id": "primaryIE",
                        "label": "Primary Index Element",
                        "validate": CKEDITOR.dialog.validate.notEmpty("Primary Index Element field must not be empty"),
                        "setup": function(term){
                            if(term["primaryIE"]){
                                this.setValue(term.primaryIE.getText());
                            }
                        },
                        "commit": function(term){
                            console.log(term);
                            if(term["primaryIE"]){
                                term["primaryIE"].setText(this.getValue());
                            }
                        }
                    },
                    {
                        "type": 'text',
                        "id": "secondaryIE",
                        "label": "Secondary Index Element",
                        "validate":function(){
                            // TODO: if primIE is not empty return true
                            return true;
                        },
                        "setup": function(term){
                            if(term["secondaryIE"]){
                                this.setValue(term.secondaryIE.getText());
                            }
                        },
                        "commit": function(term){
                            if(term["secondaryIE"]){
                                term["secondaryIE"].setText(this.getValue());
                            }
                        }
                    },
                    {
                        "type": 'text',
                        "id": "tertiaryIE",
                        "label": "Tertiary Index Element",
                        "validate":function(){
                            // TODO: if primIE is not empty return true
                            return true;
                        },
                        "setup": function(term){
                            if(term["tertiaryIE"]){
                                this.setValue(term.tertiaryIE.getText());
                            }
                        },
                        "commit": function(term){
                            if(term["tertiaryIE"]){
                                term["tertiaryIE"].setText(this.getValue());
                            }
                        }
                    },
                    {
                        "type": 'text',
                        "id": "referenceE",
                        "label": "Indexterm Reference",
                        "validate":function(){
                            // TODO: if primIE is not empty return true
                            return true;
                        },
                        "setup": function(term){
                            if(term["referenceE"]){
                                this.setValue(term.referenceE.getText());
                            }
                        },
                        "commit": function(term){
                            if(term["referenceE"]){
                                term["referenceE"].setText(this.getValue());
                            }
                        }
                    }
                ]
            }
        ],

        "onOk": function(){
            this.commitContent(this.indexterm);
        },

        "onShow": function(){
            var selection = editor.getSelection();
            var parentSpan = selection.getStartElement().getAscendant("span");

            var indexterm = {
                "parent": parentSpan,
                "primaryIE": parentSpan.getChildren().getItem(0),
                "secondaryIE": parentSpan.getChildren().getItem(1),
                "tertiaryIE": parentSpan.getChildren().getItem(2),
                "referenceE": parentSpan.getChildren().getItem(3)
            };

            this.indexterm = indexterm;
            this.setupContent(this.indexterm);
        }
    }
});