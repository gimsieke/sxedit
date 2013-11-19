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

  <xsl:key name="by-id" match="*" use="@id"/>

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
    <!--<xsl:call-template name="sxedit:compile-schematrons">
      <xsl:with-param name="schema-uris" select="$sxedit:initial-html-schematron-uris"/>
    </xsl:call-template>-->
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
    <div class="jumbotron">
      <div class="row">
        <div id="sxedit-main" class="col-md-8" contenteditable="true">
          <h2>This is a Dummy Heading</h2>
          <p>Start writing <br/>or load a document if there is a database or file access form above.</p>
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
    <xsl:result-document href="#sxedit-main" method="ixsl:replace-content">
      <xsl:apply-templates select="$content" mode="sxedit:render"/>
    </xsl:result-document>
    <xsl:variable name="notes" as="element(html:div)*">
      <xsl:apply-templates select="$content" mode="sxedit:render-notes"/>
    </xsl:variable>
    <!--<xsl:result-document href="#sxedit-notes" method="ixsl:replace-content">
      
    </xsl:result-document>-->
  </xsl:template>

  <xsl:template match="*[@id = 'sxedit-schematron-button']" mode="ixsl:onclick">
    <xsl:variable name="xmldoc" as="document-node(element(*))">
      <xsl:document>
        <xsl:apply-templates select="ancestor::*:div[last()]//*[@id = 'sxedit-main']" mode="sxedit:restore"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="xmldoc-obj" select="ixsl:eval(concat('Saxon.parseXML(''', ixsl:serialize-xml($xmldoc), ''')'))"/>
    <xsl:variable name="svrls" as="document-node(element(svrl:schematron-output))*"
      select="for $s in $sxedit:compiled-html-schematrons return sxedit:validate-with-schematron($xmldoc-obj, $s)"/>
    <xsl:variable name="serialized" as="xs:string+" select="for $svrl in $svrls return ixsl:serialize-xml($svrl)"/>
    <xsl:message select="'SVRLS: ', $serialized"/>
  </xsl:template>

  <xsl:template match="*[@id = 'sxedit-download-button']" mode="ixsl:onclick">
    <xsl:variable name="xmldoc" as="element(*)">
      <xsl:apply-templates select="ancestor::*:div[last()]//*[@id = 'sxedit-main']" mode="sxedit:restore"/>
    </xsl:variable>
    <xsl:variable name="serialized" as="xs:string" select="ixsl:serialize-xml($xmldoc)"/>
    <xsl:variable name="filename" select="ancestor::*:div[last()]//*[@id = 'download-file-name']/@prop:value" as="xs:string*"/>
    <xsl:sequence select="ixsl:call(ixsl:window(), 'Sxedit.saveTextAsFile', $serialized, $filename)"/>
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
    <!--<xsl:message select="'COMP: ', ixsl:serialize-xml($compiled)"/>-->
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
    <xsl:param name="compiled-schema" as="document-node(element(xsl:stylesheet))"/><!-- an XSLT2 stylesheet -->
    <xsl:message select="'COMPILED: ', ixsl:serialize-xml($compiled-schema/*/*:template[18])"/>
    <xsl:sequence select="sxedit:transform($input-doc, $compiled-schema, '')"/>
    <!--<xsl:document>
      <svrl:schematron-output/>
    </xsl:document>-->
  </xsl:function>
  

</xsl:stylesheet>
