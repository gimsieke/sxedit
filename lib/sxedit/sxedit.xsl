<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="2.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:sxedit="http://www.le-tex.de/namespace/sxedit"
  xmlns:rfc="http://www.ietf.org/rfc"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
  xmlns:prop="http://saxonica.com/ns/html-property"
  xmlns:js="http://saxonica.com/ns/globalJS"
  xmlns:style="http://saxonica.com/ns/html-style-property"
  extension-element-prefixes="ixsl"
  exclude-result-prefixes="#all">

  <xsl:include href="saxon-ce-dummy-declarations.xsl"/>

  <xsl:template name="init">
    <xsl:result-document href="#sxedit" method="ixsl:replace-content">
      <div class="page-header">
        <ul class="nav nav-pills pull-right">
          <li>
            <a href="#">About</a>
          </li>
          <li>
            <a href="#">Contact</a>
          </li>
        </ul>
        <h1>
          <xsl:text>sxedit&#x2002;</xsl:text>
          <xsl:apply-templates select="$sxedit:editor-name" mode="sxedit:html"/>
        </h1>
      </div>
      <xsl:call-template name="sxedit:main"/>
      <xsl:call-template name="sxedit:notes"/>
      <xsl:call-template name="sxedit:nav"/>
    </xsl:result-document>
    <ixsl:schedule-action wait="1000">
      <xsl:call-template name="sxedit:custom-init">
        <xsl:with-param name="page-url" select="ixsl:get(ixsl:window(), 'document.location')"/>
      </xsl:call-template>
    </ixsl:schedule-action>
  </xsl:template>
  
  
  <xsl:template name="sxedit:custom-init">
    <!-- override this template, e.g., for prefilling the editor from a URL query parameter -->
  </xsl:template>

  <xsl:template match="html:* | html:*/@*" mode="sxedit:html sxedit:remove-links">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:a[@href]" mode="sxedit:html sxedit:remove-links">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template name="sxedit:nav">
    <!-- will be implemented by an importing stylesheet (that might, for example, import a BaseX navigator
      that implements this template) -->
  </xsl:template>

  <xsl:template name="sxedit:main">
    <div id="sxedit-main" contenteditable="true"><p>Start writing or load a document.</p></div>
    <xsl:sequence select="sxedit:enable-edit('sxedit-main', ())" />
    <script>
      hurz = new CustomEvent(
      "hurz", 
      {
      detail: {
      message: "Hello World!",
      time: new Date(),
      },
      bubbles: true,
      cancelable: true
      }
      );
      
      var b = document.getElementById("sxedit-main");
      b.addEventListener("blur", function() {
      document.getElementById("sxedit-main").dispatchEvent(hurz);
      }, false); 
    </script>
  </xsl:template>
  
  <xsl:template name="sxedit:notes">
    <div id="cke-footnotes">
    </div>
  </xsl:template>
  
  <xsl:template name="sxedit:src">
    <div id="sxedit-src" style="display:none">
    </div>
  </xsl:template>
  
  <xsl:template name="sxedit:render">
    <xsl:param name="content" as="document-node(element(*))"/>
    <xsl:result-document href="#sxedit-main" method="ixsl:replace-content">
      <!--<xsl:call-template name="generatebutton" />-->
      <xsl:apply-templates select="$content" mode="sxedit:render"/>
    </xsl:result-document>
    <xsl:variable name="notes" as="element(html:div)*">
      <xsl:apply-templates select="$content" mode="sxedit:render-notes"/>
    </xsl:variable>
    <!--<xsl:result-document href="#sxedit-notes" method="ixsl:replace-content">
      
    </xsl:result-document>-->
  </xsl:template>

  <xsl:template name="restore">
    <xsl:result-document href="#sxedit-src" method="ixsl:replace-content">
      <xsl:apply-templates select="doc('html:document')/html/body/div[@id = 'sxedit']/*" mode="sxedit:restore"/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template name="generatebutton">
    <div id="download"><input id="generate-button" type="button" value="Generate XML for download">ready</input></div>
  </xsl:template>
  <xsl:template name="downloadbutton">
    <div id="download"><input id="download-button" type="button" value="Download XML">ready</input></div>
  </xsl:template>

  <xsl:template match="input[@id eq 'generate-button']" mode="ixsl:onclick">
    <xsl:call-template name="restore" />
    <xsl:result-document href="#download" method="ixsl:replace-content">
      <xsl:call-template name="downloadbutton" />
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="input[@id eq 'download-button']" mode="ixsl:onclick">
    <xsl:result-document href="#download" method="ixsl:replace-content">
      <xsl:call-template name="generatebutton" />
      <div id="download-link"><a href="data:text/xml;charset=utf-8,{ixsl:call(ixsl:window(), 'xser')}">download here</a></div>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="a[matches(@href, '#[efi]n')]" mode="sxedit:update-extract-notes">
    <aside id="{generate-id(.)}" class="discard-on-update">
      <xsl:variable name="id" select="concat(generate-id(.), '-anonymous-para')" as="xs:string" />
      <p class="sxedit-wrapper unwrap" id="{$id}">
        <!--<xsl:sequence select="sxedit:render-info-popup(.)(:§§§:)" />-->
        new note
      </p>
      <!--<xsl:sequence select="sxedit:enable-edit($id, ())" />-->
    </aside>
  </xsl:template>



  <xsl:template match="script" mode="sxedit:restore" />


  <xsl:template match="*" mode="sxedit:restore-highlight-attributes">
    <xsl:param name="conf" as="element(sxedit:multi-attval-emph-conf)" />
    <xsl:sequence select="$conf/att[@mapsto = local-name(current())]/@val"/>
  </xsl:template>


  <xsl:template match="*[@data-local-name]" mode="sxedit:restore" priority="-0.5">
    <xsl:if test="lower-case(@data-local-name) ne @data-local-name">
      <WHATWG-MEMBERS-MEMBERS-ARE-SMALL-LIKE-THIS>
        <xsl:value-of select="@data-local-name"/>
      </WHATWG-MEMBERS-MEMBERS-ARE-SMALL-LIKE-THIS>
    </xsl:if>
    <xsl:element name="{@data-local-name}" namespace="{@data-namspace-uri}">
      <!--       <xsl:namespace name="{@data-namespace-prefix}" select="@data-namespace-uri" /> -->
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:apply-templates mode="#current" />
      <xsl:if test="lower-case(@data-local-name) ne @data-local-name">
        <WHATWG-MEMBERS-MEMBERS-ARE-SMALL-LIKE-THIS>
          <xsl:value-of select="@data-local-name"/>
        </WHATWG-MEMBERS-MEMBERS-ARE-SMALL-LIKE-THIS>
      </xsl:if>
    </xsl:element>
  </xsl:template>


  <xsl:template match="node()" mode="sxedit:restore-lines">
    <xsl:param name="restricted-to" as="node()+" tunnel="yes" />
    <xsl:choose>
      <xsl:when test="exists(. intersect $restricted-to)">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates mode="#current" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="sxedit:restore sxedit:update" priority="-1">
    <xsl:element name="{name(.)}">
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:apply-templates mode="#current" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*" mode="sxedit:restore sxedit:update" priority="-0.5">
    <xsl:attribute name="{name(.)}" select="." />
  </xsl:template>

  <xsl:template match="@*[starts-with(name(), 'data-sxedit-save-')]" mode="sxedit:restore">
    <xsl:attribute name="{replace(replace(name(), '^data-sxedit-save-', ''), '__', ':')}" select="." />
  </xsl:template>

  <xsl:template match="*[sxedit:contains-token(@class, 'ignore')]" mode="sxedit:restore" priority="-0.75" />

  <xsl:template match="*[sxedit:contains-token(@class, 'unwrap')]" mode="sxedit:restore" priority="-0.75">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="*[sxedit:contains-token(@class, 'discard-on-update')]" mode="sxedit:update sxedit:restore" priority="-0.25" />
    
  <xsl:template match="  @data-namespace-prefix | @data-namespace-uri | @data-local-name
                       | @contenteditable 
                       | @title| @ondblclick | @style | @id" mode="sxedit:restore" />


  <xsl:template match="@data-id" mode="sxedit:restore">
    <xsl:attribute name="xml:id" select="." />
  </xsl:template>

  <xsl:function name="sxedit:contains-token" as="xs:boolean">
    <xsl:param name="string" as="xs:string" />
    <xsl:param name="word" as="xs:string" />
         <xsl:sequence select="$word = tokenize($string, '\s+')" /> 
  </xsl:function>

  <xsl:function name="sxedit:enable-edit" as="element(script)">
    <xsl:param name="id" as="xs:string" />
    <xsl:param name="opts" as="item()*" />
    <script>
      CKEDITOR.inline('<xsl:value-of select="$id"/>')
    </script>
  </xsl:function>

  <xsl:function name="sxedit:escape-html-uri" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:variable name="r" as="xs:string" select="replace($uri, '\{', '%7B')"/>
    <xsl:variable name="r" as="xs:string" select="replace($r, '\}', '%7D')"/>
    <xsl:variable name="r" as="xs:string" select="replace($r, '\[', '%5B')"/>
    <xsl:variable name="r" as="xs:string" select="replace($r, '\]', '%5D')"/>
    <xsl:variable name="r" as="xs:string" select="replace($r, ' ', '%20')"/>
    <xsl:sequence select="escape-html-uri($r)"/>
  </xsl:function>
  
  <xsl:function name="sxedit:get-url-param" as="xs:string?">
    <xsl:param name="param-name" as="xs:string"/>
    <xsl:param name="url" as="xs:string"/>
    <xsl:sequence select="sxedit:parse-url($url)/@*[name() = $param-name]"/>
  </xsl:function>

  <xsl:function name="sxedit:parse-url" as="element(rfc:url)">
    <xsl:param name="url" as="xs:string"/>
    <rfc:url>
      <xsl:analyze-string select="$url" regex="^(.+?)(\?|$)">
        <!-- to do: split the non-query part (@rfc:scheme, @rfc:host, @rfc:port, …); deal with fragment identifiers -->
        <xsl:matching-substring>
          <xsl:attribute name="rfc:base" select="regex-group(1)"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:if test="normalize-space(.)">
            <xsl:for-each select="tokenize(., '[;&amp;]')">
              <xsl:analyze-string select="." regex="^(.+?)(=(.*))?$">
                <xsl:matching-substring>
                  <!-- name/value pairs from the query string will be transformed into attributes in no namespace -->
                  <xsl:attribute name="{regex-group(1)}">
                    <xsl:sequence select="ixsl:call(ixsl:window(), 'decodeURIComponent', regex-group(3))"/>            
                  </xsl:attribute>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:for-each>
          </xsl:if>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </rfc:url>
  </xsl:function>

  <xsl:function name="sxedit:serialize-url" as="xs:string">
    <xsl:param name="url-elt" as="element(rfc:url)"/>
    <xsl:variable name="query-string" as="xs:string" 
      select="string-join(
                for $a in $url-elt/@*[not(namespace-uri() eq 'http://www.ietf.org/rfc')]
                return concat($a/name(), '=', string($a)),
                '&amp;'
              )"/>
    <xsl:sequence select="concat(
                            $url-elt/@rfc:base, 
                            if ($query-string) 
                            then concat('?', sxedit:escape-html-uri($query-string)) 
                            else ''
                          )"/>
  </xsl:function>

  <xsl:function name="sxedit:set-url-param" as="xs:string">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="param-name" as="xs:string"/>
    <xsl:param name="param-value" as="xs:string"/>
    <xsl:variable name="url-elt" as="element(rfc:url)" select="sxedit:parse-url($url)"/>
    <xsl:variable name="url-elt" as="element(rfc:url)">
      <xsl:for-each select="$url-elt">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="{$param-name}" select="sxedit:escape-html-uri($param-value)"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="sxedit:serialize-url($url-elt)"/>
  </xsl:function>

</xsl:stylesheet>
