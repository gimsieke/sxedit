
(function(){
    footnoteStore = function(){
        this.footnotes = {};
        this.usedLabels = [];
        this.iterator = 0;
    };

    footnoteStore.prototype.createSlug = function(label) {
        return label.replace(/ /g, "-")
                    .replace(/\(/g, "_")
                    .replace(/\)/g, "_");
    };

    footnoteStore.prototype.createKey = function(label){
        var slug = this.createSlug(label);
        var key = "fn-" + slug;
        var fncounter = 0;
        
        while(key in this.footnotes){
            fncounter++;
            key = "fn-" + slug + "-" + fncounter
        };

        return key;
    };

    footnoteStore.prototype.updateFN = function(key, label, text){
        if(this.footnotes[key]){
            this.footnotes[key]["label"] = label;
            this.footnotes[key]["text"] = text;
        }
        else{
            console.log("CKE-Footnotes: footnote " + key + " not found");
            return null;
        }
    };
    
    footnoteStore.prototype.addFN = function(label, text){
        var key = this.createKey(label);
        this.footnotes[key] = {
            "label" : label,
            "text" : text
        };

        this.iterator++;
        return key;
    };

    footnoteStore.prototype.removeFN = function(key){
        if (!(key in this.footnotes)){
            console.log("CKE-Footnotes: footnote " + key + " not found");
            return false;
        }
        else{
            delete this.footnotes[key];
            return true;
        }
    };
    
    footnoteStore.prototype.getFN = function(key){
        if (!(key in this.footnotes)){
            console.log("footnote not found: " + key)
            return null;
        }
        else{
            return this.footnotes[key];
        }
    };

    footnoteStore.prototype.getKeyArray = function(){
        var returnArray = [];

        for (var elem in this.footnotes){
            returnArray.push(elem);
        }

        return returnArray;
    };
    
    footnoteStore.prototype.renderFootnotesBox = function(){
        var fnTable = document.createElement('table');
        fnTable.setAttribute("class", "cke-footnotes-table");
        
        var fnThead = "<thead><tr><td>del</td><td>label</td><td>description</td></tr></thead>";
        var fnTbody = document.createElement("tbody");

        for(var elem in this.footnotes){
            if(elem in CKEDITOR.instances){
                CKEDITOR.instances[elem].destroy();
            }
            
            var label = this.footnotes[elem].label;
            var text = this.footnotes[elem].text;
            var row = document.createElement("tr");

            var fnDel = document.createElement("td");
            fnDel.setAttribute("id", "delete-" + elem);
            fnDel.setAttribute("class", "cke-footnote-delete");
            fnDel.innerHTML = "⨯";

            fnDel.onclick = function(evt){
                var fnid = this.id.replace("delete-", "");
                var fnrefs = document.getElementsByName("fnref-" + fnid);

                while(fnrefs.length > 0){
                    var reference = fnrefs[0];
                    var parent = reference.parentNode;
                    parent.removeChild(reference);
                };

                var fnLabel = CKEDITOR.ckeFNStore.getFN(fnid).label;
                var labelIndex = CKEDITOR.ckeFNStore.usedLabels.indexOf(fnLabel);

                if(labelIndex > -1){
                    CKEDITOR.ckeFNStore.usedLabels.splice(labelIndex, 1);                    
                }

                CKEDITOR.ckeFNStore.removeFN(fnid);
                CKEDITOR.ckeFNStore.renderFootnotesBox();
            };


            var fnLabel = document.createElement("td");
            fnLabel.setAttribute("id", "label-" + elem);
            fnLabel.setAttribute("class", "cke-footnote-label");
            fnLabel.innerHTML = label;

            var fnCell = document.createElement("td");
            var fnDescription = document.createElement("div");

            fnDescription.setAttribute("id", elem);
            fnDescription.setAttribute("class", "cke-footnote");
            fnDescription.setAttribute("contenteditable", "true");
            fnDescription.innerHTML = text;

            fnCell.appendChild(fnDescription);

            row.appendChild(fnDel);
            row.appendChild(fnLabel);
            row.appendChild(fnCell);

            fnTbody.appendChild(row);
        }

        fnTable.innerHTML = fnThead;
        fnTable.appendChild(fnTbody);

        var fnDiv = document.getElementById("cke-footnotes");

        if(fnDiv !== undefined && fnDiv !== null){
            fnDiv.innerHTML = "";
            fnDiv.appendChild(fnTable);
            
            for(var elem in this.footnotes){
                CKEDITOR.inline(elem, {
                    "on":{
                        "configLoaded": function(evt){
                            // Todo: remove further unneccessary plugins from fn-editor-instances
                            this.config.removePlugins = "autosave,tableresize";
                        },
                        "blur": function(evt){
                            var newContent = this.getData();
                            var key = this.name;
                            var oldFN = CKEDITOR.ckeFNStore.getFN(key);

                            CKEDITOR.ckeFNStore.updateFN(key, oldFN.label, newContent);
                            CKEDITOR.ckeFNStore.renderFootnotesBox();
                        }
                    },
                    "toolbar": [
                        {
                            "name": "basic", 
                            "items": ['Bold', 'Italic', 'Underline', "Strike", "Subscript", "Superscript", "RemoveFormat"]
                        },
                        {
                            "name": "linking", 
                            "items": ["Link", "Unlink","Anchor"]
                        },
                        {
                            "name": "structures", 
                            "items": ["NumberedList", "BulletedList", "Outdent", "Indent", "Blockquote", "Table"]
                        },
                        {
                            "name": "box-objects", 
                            "items": ["CreatePlaceholder", "Image", "Flash", "Iframe", "CreateDiv"]
                        }
                    ]
                });
            }
        }
    };

    if(typeof(CKEDITOR["ckeFNStore"]) == "undefined")
        CKEDITOR["ckeFNStore"] = new footnoteStore();

})();

CKEDITOR.dialog.add("footnoterefDialog", function(editor){
    return {
        "title": "Footnote Reference Properties",
        "minWidth": 400,
        "minHeight": 100,

        "contents": [
            {
                "id": "fnref",
                "label": "Footnote Reference Link",
                "elements":[
                    {
                        "type": 'select',
                        "id": 'fnref-key',
                        "label": 'Select a footnote',
                        "items": [["---Select a footnote---", 0]],
                        "onShow": function(){
                            if(CKEDITOR["ckeFNStore"]){
                                var firstSelector = document.createElement("option");
                                firstSelector.textContent = "---Select a footnote---";
                                firstSelector.value = 0;

                                var selectElement = this.getInputElement().$;
                                var footnotesKeyArray = CKEDITOR.ckeFNStore.getKeyArray();

                                while(selectElement.firstChild){
                                    selectElement.removeChild(selectElement.firstChild);
                                }

                                selectElement.appendChild(firstSelector);

                                for(var key in footnotesKeyArray){
                                    var elem = footnotesKeyArray[key];
                                    var label = CKEDITOR.ckeFNStore.getFN(elem)["label"];
                                    var option = document.createElement("option");

                                    option.textContent = '"' + label + '"  -  ' + elem;
                                    option.value = footnotesKeyArray[key];
                                    selectElement.appendChild(option);
                                }
                            }
                        }
                    }
                ]
            }
        ],

        "onOk": function(){
            if(CKEDITOR['ckeFNStore']){
                var dlg = this;
                var fnElement = editor.document.createElement("span");
                
                var fnKey = dlg.getValueOf("fnref", "fnref-key");
                var fn = CKEDITOR.ckeFNStore.getFN(fnKey);

                if(fn !== null){
                    var label = fn['label'];
                    
                    if(fnKey !== 0){
                        fnElement.setAttribute("name", "fnref-" + fnKey)
                        var fnAnchor = editor.document.createElement("a");
                        
                        fnAnchor.setAttribute("href", "#"+fnKey);
                        fnAnchor.setText(label);
                        
                        fnElement.setAttribute("class", "cke-footnote");
                        fnElement.append(fnAnchor);
                        
                        editor.insertElement(fnElement);
                    }
                }
            }
            else{
                console.log("no footnotes found");
            }
        }
    }
});


CKEDITOR.dialog.add("footnotesDialog", function(editor){
    return {
        "title": "Footnote Properties",
        "minWidth": 400,
        "minHeight": 100,

        "contents": [
            {
                "id": "fn-basic",
                "label": "Footnote Settings",
                "elements":[
                    {
                        "type": "text",
                        "id": "label",
                        "label": "Footnote Label",
                        "validate": function(){
                            var value = this.getValue();
                            if(!value){
                                alert('Label must not be empty!' );
                                return false;
                            }
                            else{
                                for(var i in CKEDITOR.ckeFNStore.usedLabels){
                                    if(CKEDITOR.ckeFNStore.usedLabels[i] === value){
                                        alert('Label must not be used twice.');
                                        return false;
                                    }
                                }
                                
                                return true;
                            }
                        }
                    },
                    {
                        "type": "text",
                        "id": "text",
                        "label": "Footnote Text",
                        "validate": CKEDITOR.dialog.validate.notEmpty("Text field cannot be empty")
                    }
                ]
            }
        ],

        "onOk": function(){
            var dlg = this;
            var fnElement = editor.document.createElement("span");

            var label = dlg.getValueOf("fn-basic", "label");
            var text  = dlg.getValueOf("fn-basic", "text");

            var fnKey = CKEDITOR.ckeFNStore.addFN(label, text);
            fnElement.setAttribute("name", "fnref-" + fnKey);

            if(fnKey){
                var fnAnchor = editor.document.createElement("a");

                fnAnchor.setAttribute("href", "#"+fnKey);
                fnAnchor.setText(label);

                fnElement.setAttribute("class", "cke-footnote");
                fnElement.append(fnAnchor);
            }

            CKEDITOR.ckeFNStore.usedLabels.push(label);
            editor.insertElement(fnElement);
            CKEDITOR.ckeFNStore.renderFootnotesBox();
        }
    }
});
