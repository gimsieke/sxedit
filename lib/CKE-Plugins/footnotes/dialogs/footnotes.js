
/* TODO:
  [16:05:52] Gerrit Imsieke: Als Löschkreuz kannst Du evtl. ❎ verwenden 
  (http://www.fileformat.info/info/unicode/char/274e/browsertest.htm). 
  Oder ❌ (http://www.fileformat.info/info/unicode/char/274c/browsertest.htm). 
  Skype kann sie nicht darstellen, aber zumindest der FF


  Autosave/Backup-Problematik lösen
*/

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
    
    footnoteStore.prototype.renderFootnotesBox = function(){
        var fnTable = document.createElement('table');
        fnTable.setAttribute("class", "cke-footnotes-table");
        
        var fnThead = "<thead><tr><td>del</td><td>label</td><td>description</td></tr></thead>";
        var fnTbody = document.createElement("tbody");

        for(elem in this.footnotes){
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

                var fnLabel = ckeFNStore.getFN(fnid).label;
                var labelIndex = ckeFNStore.usedLabels.indexOf(fnLabel);

                if(labelIndex > -1){
                    ckeFNStore.usedLabels.splice(labelIndex, 1);                    
                }

                ckeFNStore.removeFN(fnid);
                ckeFNStore.renderFootnotesBox();
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
            
            for(elem in this.footnotes){
                CKEDITOR.inline(elem, {
                    "on":{
                        "configLoaded": function(evt){
                            // Todo: remove further unneccessary plugins from fn-instances
                            this.config.removePlugins = "autosave";
                        },
                        "blur": function(evt){
                            var newContent = this.getData();
                            var key = this.name;
                            var oldFN = ckeFNStore.getFN(key);

                            ckeFNStore.updateFN(key, oldFN.label, newContent);
                            ckeFNStore.renderFootnotesBox();
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
                            "items": ["NumberedList", "BulletedList", "Outdent", "Indent", "Blockquote", "CreateDiv", "Table"]
                        },
                        {
                            "name": "box-objects", 
                            "items": ["CreatePlaceholder", "Image", "Flash", "Iframe"]
                        }
                    ]
                });
            }
        }
    };

    window["ckeFNStore"] = new footnoteStore();

})();


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
                                for(var i in ckeFNStore.usedLabels){
                                    if(ckeFNStore.usedLabels[i] === value){
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

            var fnKey = ckeFNStore.addFN(label, text);
            fnElement.setAttribute("name", "fnref-" + fnKey);

            if(fnKey){
                var fnAnchor = editor.document.createElement("a");

                fnAnchor.setAttribute("href", "#"+fnKey);
                fnAnchor.setText(label);

                fnElement.setAttribute("class", "cke-footnote");
                fnElement.append(fnAnchor);
            }

            ckeFNStore.usedLabels.push(label);
            editor.insertElement(fnElement);
            ckeFNStore.renderFootnotesBox();
        }
    }
});
