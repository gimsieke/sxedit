


// options -- default values

if(!FNoptions){
    var FNoptions = {
        "fndecorator": ")",
        "numeration" : "numeric"
    };
}

(function(opts){
    romanNumber = function(num){
        if(!+num)
            return false;

        var digits = String(+num).split("");
        var key = ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM", 
                   "", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC", 
                   "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];

        var roman = "";
        var i = 3;

        while(i--){
            roman = (key[+digits.pop() + (i*10)] || "") + roman;
        }

        return Array(+digits.join("") + 1).join("M") + roman;
    }

    alphabeticOrder = function(alphabet){
        this.alphabet = alphabet;
        this.base = alphabet.length;
    };

    alphabeticOrder.prototype.yield = function(numeral){
        var returnValue = "";

        do{
            returnValue = this.alphabet[numeral % this.base] + returnValue;
            numeral = Math.floor(numeral/this.base);
        }while(numeral-- != 0);

        return returnValue;
    };

    footnoteStore = function(){
        this.footnotes = {};
        this.deco = opts.fndecorator;
        this.iterator = 0;
        this.numeration = opts.numeration;
        this.upperLatin = new alphabeticOrder("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        this.lowerLatin = new alphabeticOrder("abcdefghijklmnopqrstuvwxyz");
        this.lowerGreek = new alphabeticOrder("αβγδεζηθικλμνξοπρστυφχψω");
        this.upperGreek = new alphabeticOrder("ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ");
    };

    footnoteStore.prototype.getKeyArray = function(){
        var keyArray = [];
        
        for(elem in this.footnotes){
            keyArray.push(elem);
        }
        
        return keyArray;
    };

    footnoteStore.prototype.getIteratedLabel = function(){
        var returnLabel = "";
        
        switch(this.numeration){
            case "lowerlatin": {
                returnLabel = this.lowerLatin.yield(this.iterator);
                break;
            }
            case "upperlatin": {
                returnLabel = this.upperLatin.yield(this.iterator);
                break;
            }
            case "lowergreek":{
                returnLabel = this.lowerGreek.yield(this.iterator);
                break;
            }
            case "uppergreek":{
                returnLabel = this.upperGreek.yield(this.iterator);
                break;
            }
            case "roman":{
                returnLabel = romanNumber(this.iterator);
                break;
            }
            case "numeric": {
                returnLabel = ""+this.iterator;
                break;
            }
            default: {
                console.log("CKE-Footnotes: unknown numeration type, using numerical order");
                returnLabel = ""+this.iterator;
                break;
            }
        }

        return returnLabel;
    };

    footnoteStore.prototype.createSlug = function(label) {
        return label.replace(/ /g, "_");
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
            
            var label = this.footnotes[elem].label + ckeFNStore.deco;
            var text = this.footnotes[elem].text;
            var row = document.createElement("tr");

            var fnDel = document.createElement("td");
            fnDel.setAttribute("id", "delete-" + elem);
            fnDel.setAttribute("class", "cke-footnote-delete");
            fnDel.innerHTML = "X";

            fnDel.onclick = function(evt){
                var fnid = this.id.replace("delete-", "");
                var fnrefs = document.getElementsByName("fnref-" + fnid);

                while(fnrefs.length > 0){
                    var reference = fnrefs[0];
                    var parent = reference.parentNode;
                    parent.removeChild(reference);
                };

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
                        "blur": function(evt){
                            var newContent = this.getData();
                            var key = this.name;
                            var oldFN = ckeFNStore.getFN(key);

                            ckeFNStore.updateFN(key, oldFN.label, newContent);
                            ckeFNStore.renderFootnotesBox();
                        }
                    }
                });
            }
        }
    };

    window["ckeFNStore"] = new footnoteStore();

})(FNoptions);


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
                        "onShow": function(){
                            var iterLabel = ckeFNStore.getIteratedLabel();
                            this.setValue(iterLabel);
                        },
                        "validate": CKEDITOR.dialog.validate.notEmpty("Label field cannot be empty")
                    },
                    {
                        "type": "text",
                        "id": "text",
                        "label": "Footnote Text",
                        "validate": CKEDITOR.dialog.validate.notEmpty("Label field cannot be empty")
                    }
                ]
            }
        ],

        "onLoad": function(){
            this.getContentElement("fn-basic", "label").disable();
        },

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
                fnAnchor.setText(label + ckeFNStore.deco);

                fnElement.setAttribute("class", "cke-footnote");
                fnElement.append(fnAnchor);
            }

            editor.insertElement(fnElement);
            ckeFNStore.renderFootnotesBox();
        }
    }
});
