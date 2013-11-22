<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xslout="bogo"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0"
  >

  <xsl:param name="top-level-div-id" select="'sxedit-main'" as="xs:string"/>

  <xsl:output method="xml" indent="yes"  />

  <xsl:namespace-alias stylesheet-prefix="xslout" result-prefix="xsl"/>
  
  <xsl:template match="svrl:text" mode="messages">
    
  </xsl:template>
  
  <xsl:template match="/" mode="#default">
    <xslout:stylesheet version="2.0">

      <!--<xslout:output method="xhtml" cdata-section-elements="script"/>-->

      <xslout:template match="/*">
        <xslout:copy copy-namespaces="no">
          <xsl:apply-templates select="svrl:ns-prefix-in-attribute-values" mode="#default"/>
          <xslout:apply-templates select="@* | node()" mode="#current"/>
        </xslout:copy>
      </xslout:template>

      <xslout:template match="@* " mode="#default">
        <xsl:copy/>
      </xslout:template>
      
      <xslout:template match="@* | *" mode="#default">
        <xslout:param name="mark" as="xs:boolean?" tunnel="yes"/>
        <xslout:copy>
          <xslout:apply-templates select="@*" mode="#current"/>
          <xslout:if test="$mark">
            <xslout:attribute name="class" select="string-join((@class, 'sxedit-mark-underline'), ' ')"/>
          </xslout:if>
          <xslout:apply-templates mode="#current"/>
        </xslout:copy>
      </xslout:template>
      
      <xslout:template match="*[tokenize(@class, '\s+') = 'sxedit-schematron']" mode="#default"/>
      
      <xsl:for-each-group select=".//svrl:text" group-by="../@location">
        <xslout:template match="*:div[@id = '{$top-level-div-id}']{replace(replace(../@location, '\[namespace-uri[^\]]+\]', ''), '^/(\*:)div\[1\]', '')}">
          <div class="sxedit-schematron">
            <p>
              <button type="button" class="btn btn-default btn-sm sxedit-close-message">close message</button>
            </p>
            <xsl:apply-templates select="current-group()"/>
          </div>
          <xslout:next-match>
            <xslout:with-param name="mark" select="true()" tunnel="yes"/>
          </xslout:next-match>
        </xslout:template>
      </xsl:for-each-group>

    </xslout:stylesheet>
  </xsl:template>

  <xsl:template match="svrl:text">
    <p class="sxedit-schematron-message {../@role}">
      <xsl:value-of select="."/>
    </p>
  </xsl:template>

  <xsl:template match="svrl:ns-prefix-in-attribute-values">
    <xslout:namespace name="{@prefix}" select="@uri" />    
  </xsl:template>
    
</xsl:stylesheet>
