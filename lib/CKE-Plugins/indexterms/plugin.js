

(function(){
    var cssClasses = ["cke-index-primary", "cke-index-secondary", "cke-index-tertiary", "cke-index-reference"];
    var defaultText = ["primary", "secondary", "tertiay", "see ..."];

    IndexTermManager = function(){
        this.indexterms = {};
        this.termCount = 0;
        this.globalVisibility = true;
    };

    IndexTermManager.prototype.removeTerm = function(key){
        delete this.indexterms[key];
        //TODO: remove span in dom
    };


    IndexTermManager.prototype.addTerm = function(term){
        var key = this.createSlug();
        this.indexterms[key] = term;

        return key;
    };

    IndexTermManager.prototype.createSlug = function(){
        var base = "cke-indexterm-";
        var count = this.termCount;

        slug = base + this.termCount;
        
        while(slug in this.indexterms){
            count++;
            slug = base + count;
        };

        return slug;
    };

    IndexTermManager.prototype.toggleGlobalVisibility = function(){
        this.globalVisibility = this.globalVisibility?false:true;
        for(term in this.indexterms){
            this.indexterms[term].setVisibility(this.globalVisibility);
        }
    };

    CKEDITOR["IndexTermManager"] = new IndexTermManager(this.globalVisibility);


    IndexTerm = function(editor){
        this.editor = editor;
        this.visible = true;

        this.id = null;
        this.indexSpan = null;
        this.termSpans = [];

        this.registerTerm();
        this.renderSpan();
    };

    IndexTerm.prototype.registerTerm = function(){
        this.id = CKEDITOR["IndexTermManager"].addTerm(this);
    }

    IndexTerm.prototype.renderSpan = function() {
        var selectedText = this.editor.getSelection().getSelectedText();

        this.indexSpan = this.editor.document.createElement("span");
        this.indexSpan.setAttribute("class", "cke-indexterm");

        for(var i=0; i<4; i++){
            var span = this.editor.document.createElement("span");
            span.setAttribute("class", cssClasses[i]);

            if(selectedText.length > 0){
                if(i===0){
                    span.setText(selectedText);
                }
                else{
                    span.$.innerHTML = "&#160;";
                }
            }
            else{
                span.setText(defaultText[i]);
            }

            this.termSpans.push(span);

            this.indexSpan.setAttribute("id", this.id);
            this.indexSpan.append(span);
        };

        this.editor.insertElement(this.indexSpan);
        this.editor.insertText(selectedText);
    };

    IndexTerm.prototype.setVisibility = function(state){
        this.visible = state;

        if(state) 
            this.indexSpan.setAttribute("class", "cke-indexterm");
        else 
            this.indexSpan.setAttribute("class", "cke-indexterm-hidden");

        
        for(var i in this.termSpans){
            if(state){
                this.termSpans[i].setAttribute("class", cssClasses[i]);
            }
            else{
                this.termSpans[i].setAttribute("class", cssClasses[i] + "-hidden");
            }
        }
    };

    CKEDITOR.plugins.add('indexterms', {
        "icons": "indexterms", 
        "init" : function(editor){
            editor.addCommand("add_iterm", {
                "exec": function(editor){
                    var term = new IndexTerm(editor);
                }
            });

            editor.addCommand("toggle_indexterms", {
                "exec": function(editor){
                    CKEDITOR.IndexTermManager.toggleGlobalVisibility();
                }
            });

            editor.ui.addButton("indexterms", {
                "label": "Insert Index Term", 
                "command" : "add_iterm",
                "toolbar": "insert"
            });
            
            editor.ui.addButton("toggle_indexterms", {
                "icon" : this.path + "icons/toggle_indexterms.png",
                "label": "Toggle index term visibility", 
                "command" : "toggle_indexterms",
                "toolbar": "insert"
            });
        }
    });
})();
