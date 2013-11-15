


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
                            if(window["ckeFNStore"]){
                                var firstSelector = document.createElement("option");
                                firstSelector.textContent = "---Select a footnote---";
                                firstSelector.value = 0;

                                var selectElement = this.getInputElement().$;
                                var footnotesKeyArray = ckeFNStore.getKeyArray();

                                while(selectElement.firstChild){
                                    selectElement.removeChild(selectElement.firstChild);
                                }

                                selectElement.appendChild(firstSelector);

                                for(key in footnotesKeyArray){
                                    var elem = footnotesKeyArray[key];
                                    var label = ckeFNStore.getFN(elem)["label"];
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
            if(window['ckeFNStore']){
                var dlg = this;
                var fnElement = editor.document.createElement("span");
                
                var fnKey = dlg.getValueOf("fnref", "fnref-key");
                var fn = ckeFNStore.getFN(fnKey);

                if(fn !== null){
                    var label = fn['label'];
                    
                    if(fnKey !== 0){
                        fnElement.setAttribute("name", "fnref-" + fnKey)
                        var fnAnchor = editor.document.createElement("a");
                        
                        fnAnchor.setAttribute("href", "#"+fnKey);
                        fnAnchor.setText(label + ckeFNStore.deco);
                        
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
