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
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  extension-element-prefixes="ixsl"
  exclude-result-prefixes="#all">

  <xsl:include href="saxon-ce-dummy-declarations.xsl"/>

  <!-- cannot use key(), unfortunately, because of something that CKE injects into the page. 
       Probably its iframe (even for contenteditable variant). Error messages complain about a QName that is the empty string.
       Need to investigate. -->
  <xsl:key name="by-id" match="*" use="@id"/>

  <!-- Whether the target XML vocabulary contains element such as 'head' or 'body' that need to 
    be escaped regardless of their namespace. Just gotta love browsers, wtf.
    
    Is it a good idea to have an xs:boolean typed xsl:param? -->
  <xsl:param name="sxedit:contains-reserved-element-names" select="false()" as="xs:boolean"/>

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
      <xsl:call-template name="sxedit:nav"/>
      <xsl:call-template name="sxedit:main"/>
      <xsl:call-template name="sxedit:notes"/>
    </xsl:result-document>
    <ixsl:schedule-action wait="1000">
      <xsl:call-template name="sxedit:custom-init">
        <xsl:with-param name="page-url" select="ixsl:get(ixsl:window(), 'document.location')"/>
      </xsl:call-template>
    </ixsl:schedule-action>
  </xsl:template>
  
  <xsl:variable name="sxedit:compiled-html-schematrons" as="item()*">
    <xsl:sequence select="for $u in $sxedit:initial-html-schematron-uris return sxedit:compile-schematron($u)"/>
  </xsl:variable>
  
  <xsl:template name="sxedit:custom-init">
    <xsl:param name="page-url" as="xs:string"/>
    <!-- override this template, e.g., for prefilling the editor from a URL query parameter -->
  </xsl:template>
  
  <xsl:template match="html:*" mode="sxedit:html sxedit:remove-links">
    <xsl:param name="remove" as="element(*)?" tunnel="yes"/>
    <xsl:if test="not(. is $remove)">
      <xsl:copy>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*" mode="sxedit:html sxedit:remove-links">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@class" mode="sxedit:html sxedit:remove-links">
    <xsl:attribute name="class" select="string-join(tokenize(., '\s+')[not(. = 'sxedit-mark-underline')], ' ')"/>
  </xsl:template>
  

  <xsl:template match="* | @*" mode="sxedit:remove-script">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*:script | *[sxedit:contains-token(@class, 'sxedit-schematron')]" mode="sxedit:remove-script"/>

  <xsl:template match="html:a[@href]" mode="sxedit:html sxedit:remove-links">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template name="sxedit:nav">
    <!-- will be implemented by an importing stylesheet (that might, for example, import a BaseX navigator
      that implements this template) -->
  </xsl:template>

  <!-- This template has to be invoked whenever a storage adapter loads a new file -->  
  <xsl:template name="sxedit:set-data-attribute">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="value" as="xs:string"/>
    <xsl:param name="elt" as="element(*)"/>
    <xsl:for-each select="$elt">
      <ixsl:set-attribute name="data-{$name}" select="$value"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="sxedit:main">
    <div class="jumbotron">
      <div class="row">
        <div id="sxedit-main" class="col-md-8" contenteditable="true">
          <h2>This is a Dummy Heading</h2>
          <p>Start writing or load a document if there is a database or file access form above.</p>
        </div>
        <div class="col-md-4">
          <div class="btn-group">
            <button type="button" class="btn btn-default" id="sxedit-schematron-button">Schematron check</button>
          </div>
          <div class="input-group">
            <span class="input-group-btn">
              <button class="btn btn-default" type="button" id="sxedit-download-button">Download XML as file:</button>
            </span>
            <input type="text" id="download-file-name" class="form-control" value="edited.xml"/>
          </div>
          
        </div>
      </div>
    </div>
    <xsl:sequence select="sxedit:enable-edit('sxedit-main', ())" />
  </xsl:template>
  
  <xsl:template name="sxedit:notes">
    <div class="jumbotron">
      <div id="cke-footnotes"> </div>
    </div>
  </xsl:template>
  
  <xsl:template name="sxedit:render">
    <xsl:param name="content" as="document-node(element(*))"/>
    <xsl:param name="fragment-url" as="xs:string?"/>
    <xsl:variable name="sxedit-main-div" select="ancestor::*:div[last()]//*:div[@id = 'sxedit-main']" as="element(*)"/>
    <xsl:result-document href="#sxedit-main" method="ixsl:replace-content">
      <xsl:apply-templates select="$content" mode="sxedit:render"/>
    </xsl:result-document>
    <xsl:variable name="notes" as="element(html:div)*">
      <xsl:apply-templates select="$content" mode="sxedit:render-notes"/>
    </xsl:variable>
    <!--<xsl:result-document href="#sxedit-notes" method="ixsl:replace-content">
      
    </xsl:result-document>-->
    <xsl:if test="$fragment-url">
      <xsl:call-template name="sxedit:set-data-attribute">
        <xsl:with-param name="name" select="'fragment-url'"/>
        <xsl:with-param name="value" select="$fragment-url"/>
        <xsl:with-param name="elt" select="$sxedit-main-div"/>
      </xsl:call-template>
      <xsl:call-template name="sxedit:set-data-attribute">
        <xsl:with-param name="name" select="'xpath'"/>
        <xsl:with-param name="value" select="sxedit:parse-url($fragment-url)/@xpath"/>
        <xsl:with-param name="elt" select="$sxedit-main-div"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="$content" mode="sxedit:create-data-attributes-for-fragment-element">
      <xsl:with-param name="elt" select="$sxedit-main-div"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="sxedit:create-data-attributes-for-fragment-element">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:call-template name="sxedit:set-data-attribute">
      <xsl:with-param name="name" select="'element-name'"/>
      <xsl:with-param name="value" select="name()"/>
      <xsl:with-param name="elt" select="$elt"/>
    </xsl:call-template>
    <xsl:call-template name="sxedit:set-data-attribute">
      <xsl:with-param name="name" select="'namespace-uri'"/>
      <xsl:with-param name="value" select="namespace-uri()"/>
      <xsl:with-param name="elt" select="$elt"/>
    </xsl:call-template>
    <xsl:apply-templates select="@*" mode="#current">
      <xsl:with-param name="elt" select="$elt"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="@*" mode="sxedit:create-data-attributes-for-fragment-element">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:call-template name="sxedit:set-data-attribute">
      <xsl:with-param name="name" select="concat('attribute-', replace(name(), ':', '___'))"/>
      <xsl:with-param name="value" select="."/>
      <xsl:with-param name="elt" select="$elt"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*[@id = 'sxedit-schematron-button']" mode="ixsl:onclick">
    <xsl:variable name="xmldoc">
      <xsl:document>
        <xsl:apply-templates select="ancestor::*:div[last()]//*:div[@id = 'sxedit-main']" mode="sxedit:remove-script"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="xmldoc-obj" select="sxedit:xdm2js($xmldoc)"/>
    <xsl:variable name="svrls" as="document-node(element(svrl:schematron-output))*"
      select="for $s in $sxedit:compiled-html-schematrons return sxedit:validate-with-schematron($xmldoc-obj, $s)"/>
    <!-- The following does not work (empty document when applying the compiled Schematron-XSLT to the fragment). Why? -->
    <!--<xsl:variable name="svrls" as="document-node(element(svrl:schematron-output))*"
      select="for $s in $sxedit:compiled-html-schematrons return sxedit:validate-with-schematron(ixsl:page()//*:div[@id = 'sxedit-main'], $s)"/>-->
    <xsl:variable name="serialized" as="xs:string+" select="for $svrl in $svrls return ixsl:serialize-xml($svrl)"/>
    <!--<xsl:message select="'SVRLS: ', $serialized"/>-->
    <xsl:variable name="patch-xsl" select="sxedit:transform($svrls[1], '../../lib/sxedit/svrl2xsl.xsl', '')"/>
    <!--<xsl:message select="'SVRLXSL: ', ixsl:serialize-xml($patch-xsl, false())"/>-->
    <xsl:variable name="html-frags" select="ixsl:call(
                                              ixsl:window(), 
                                              'Sxedit.transform', 
                                              ixsl:page()//*:div[@id = 'sxedit-main'], 
                                              ixsl:call(
                                                ixsl:window(),
                                                'Sxedit.transform',
                                                $svrls[1],
                                                '../../lib/sxedit/svrl2xsl.xsl',
                                                ''
                                              ),
                                              ''
                                            )"/>
    <!--<xsl:message select="'HTMLFRAGS: ', ixsl:serialize-xml($html-frags)"/>-->
    <xsl:result-document method="ixsl:replace-content" href="#sxedit-main">
      <xsl:sequence select="$html-frags/*/node()"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:function name="sxedit:random-string" as="xs:string">
    <xsl:sequence select="substring(string(ixsl:eval('Math.random()')), 3, 8)"/>
  </xsl:function>
  
  <xsl:function name="sxedit:xdm2js" as="item()*">
    <xsl:param name="xdmnode" as="item()"/>
    <!--<xsl:message select="'XDMNODE: ', ixsl:serialize-xml($xdmnode)"/>-->
    <xsl:sequence select="ixsl:eval(concat('Saxon.parseXML(''', replace(ixsl:serialize-xml($xdmnode), '''', '\\'''), ''')'))"/>
  </xsl:function>

  <xsl:template match="*[@id = 'sxedit-download-button']" mode="ixsl:onclick">
    <xsl:variable name="xmldoc" as="document-node(element(*))">
      <xsl:call-template name="sxedit:restore"/>
    </xsl:variable>
    <xsl:variable name="serialized" as="xs:string" select="sxedit:serialize-xml($xmldoc, $sxedit:contains-reserved-element-names)"/>
    <xsl:variable name="filename" select="ancestor::*:div[last()]//*[@id = 'download-file-name']/@prop:value" as="xs:string*"/>
    <xsl:sequence select="ixsl:call(ixsl:window(), 'Sxedit.saveTextAsFile', $serialized, $filename)"/>
  </xsl:template>

  <xsl:template name="sxedit:restore" as="document-node(element(*))">
    <xsl:variable name="sxedit-div" as="element(*)" 
      select="ancestor::*:div[last()]/descendant-or-self::*:div[@id = 'sxedit']"/>
    <xsl:variable name="sxedit-main-div" as="element(*)" 
      select="$sxedit-div/descendant::*:div[@id = 'sxedit-main']"/>
    <xsl:variable name="sxedit-notes-table" as="element(*)?" 
      select="$sxedit-div/descendant::*:div[@id = 'cke-footnotes']/*:table[sxedit:contains-token(@class, 'cke-footnotes-table')]"/>
    <xsl:document>
      <xsl:apply-templates select="$sxedit-main-div" mode="sxedit:restore"/>
    </xsl:document>
  </xsl:template>

  <xsl:template match="*:script" mode="sxedit:restore" />

  <xsl:template match="*" mode="sxedit:restore-highlight-attributes">
    <xsl:param name="conf" as="element(sxedit:multi-attval-emph-conf)" />
    <xsl:sequence select="$conf/att[@mapsto = local-name(current())]/@val"/>
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

  <xsl:function name="sxedit:contains-token" as="xs:boolean">
    <xsl:param name="string" as="xs:string?" />
    <xsl:param name="word" as="xs:string" />
    <xsl:sequence select="$word = tokenize($string, '\s+')"/> 
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
  
  <!-- URL decomposition &amp; synthesis; query parameter access &amp; manipulation -->
  
  <xsl:function name="sxedit:get-url-param" as="xs:string?">
    <xsl:param name="param-name" as="xs:string"/>
    <xsl:param name="url" as="xs:string"/>
    <xsl:sequence select="sxedit:parse-url($url)/@*[name() = $param-name]"/>
  </xsl:function>

  <xsl:function name="sxedit:parse-url" as="element(rfc:url)">
    <xsl:param name="url" as="xs:string"/>
    <!-- If maps were supported, we’d probably use a map instead of an XML structure -->
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

  <!-- Will set or modify a parameter in the query string of a URL. Parses the URL first
    into an rfc:url data structure, then sets the param via an xsl:attribute instruction
    and then re-serializes the URL -->
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

  <!-- Working around not being able to serialize elements called 'body'
  (no matter what namespace they’re in). 
  By convention, we prepend five underscores to the element name. -->

  <xsl:function name="sxedit:serialize-xml" as="xs:string">
    <xsl:param name="node" as="item()"/>
    <xsl:param name="unescape-reserved-names" as="xs:boolean"/>
    <xsl:sequence select="if ($unescape-reserved-names)
                          then replace(ixsl:serialize-xml($node), '(&lt;/?)_____', '$1')
                          else ixsl:serialize-xml($node)"/>
  </xsl:function>

  <!-- Invoking XSLT transforms -->
  
  <xsl:function name="sxedit:transform" as="document-node(element(*))">
    <xsl:param name="doc" as="item()"/><!-- string, element, or document --> 
    <xsl:param name="stylesheet" as="item()"/><!-- string, element, or document -->
    <xsl:param name="params" as="xs:string"/><!-- e.g., 'param1=foo param2=bar' -->
    <xsl:sequence select="ixsl:call(ixsl:window(), 'Sxedit.transform', $doc, $stylesheet, $params)"/>
  </xsl:function>
  
  
  <!-- Schematron -->
  
  <xsl:function name="sxedit:compile-schematron" as="document-node(element(*))">
    <xsl:param name="schema" as="item()"/><!-- string, element, or document -->
    <xsl:variable name="abstract-expanded" select="sxedit:transform($schema, '../../lib/ISO-Schematron/iso_abstract_expand.xsl', '')" as="document-node(element(s:schema))"/>
    <xsl:variable name="compiled" select="sxedit:transform($abstract-expanded, '../../lib/ISO-Schematron/iso_svrl_for_xslt2.xsl', '')" as="document-node(element(xsl:stylesheet))"/>
    <xsl:sequence select="$compiled"/>
  </xsl:function>
  
  <!--<xsl:template match="*:h2" mode="ixsl:onclick">
    <xsl:result-document href="?select=.." method="ixsl:replace-content">
      <xsl:variable name="context" select="." as="element(*)"/>
      <xsl:apply-templates select="../node()" mode="sxedit:html">
        <xsl:with-param name="modify" select="$context" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="*:h2" mode="sxedit:html">
    <xsl:param name="modify" as="element(*)?" tunnel="yes"/>
    <xsl:if test=". is $modify">
      <p>hurz</p>
    </xsl:if>
    <xsl:copy-of select="."/>
  </xsl:template>
  -->
  
  <xsl:function name="sxedit:validate-with-schematron" as="document-node(element(svrl:schematron-output))">
    <xsl:param name="input-doc" as="item()"/>
    <xsl:param name="compiled-schema" as="document-node(element(xsl:stylesheet))"/>
    <!-- an XSLT2 stylesheet -->
    <!--<xsl:message select="'COMPILED: ', ixsl:serialize-xml($compiled-schema/*/*:template[18])"/>-->
<!--    <xsl:message select="'INPUT: ', ixsl:serialize-xml($input-doc)"/>-->
    <xsl:variable name="svrl" select="sxedit:transform($input-doc, $compiled-schema, '')"
      as="document-node(element(svrl:schematron-output))"/>
    <xsl:message select="'SVRL: ', $svrl/*/*[position() = (1 to 5)]"/>
    <xsl:sequence select="$svrl"/>
  </xsl:function>
  
  <xsl:template match="*:button[sxedit:contains-token(@class, 'sxedit-close-message')]" mode="ixsl:onclick">
    <xsl:variable name="context" select="ancestor::*[sxedit:contains-token(@class, 'sxedit-schematron')]" as="element(*)"/>
    <xsl:result-document method="ixsl:replace-content" href="#sxedit-main">
      <xsl:apply-templates select="ancestor::*:div[@id = 'sxedit-main']/node()" mode="sxedit:html">
        <xsl:with-param name="remove" select="$context" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
