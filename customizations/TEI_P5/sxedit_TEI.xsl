<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="2.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:sxedit="http://www.le-tex.de/namespace/sxedit"
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
  xmlns:prop="http://saxonica.com/ns/html-property"
  xmlns:style="http://saxonica.com/ns/html-style-property"
  extension-element-prefixes="ixsl"
  exclude-result-prefixes="#all">

  <xsl:import href="../../lib/sxedit/sxedit.xsl"/>
  <xsl:import href="../../lib/sxedit/basex-nav.xsl"/>
  
  <xsl:variable name="sxedit:editor-name" as="element(html:small)">
    <small xmlns="http://www.w3.org/1999/xhtml">TEI P5</small>
  </xsl:variable>

  <xsl:template match="@* | *" mode="sxedit:render">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div[tei:head]" mode="sxedit:render">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="tei:div[not(tei:head)]" mode="sxedit:render">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*, node()" mode="#current"/>  
    </div>
  </xsl:template>
  
  <xsl:template match="tei:div/tei:head" mode="sxedit:render">
    <xsl:element name="h{tei:heading-level(..)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*, ../@*, node()" mode="#current"/>  
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="tei:heading-level" as="xs:integer">
    <xsl:param name="div" as="element(tei:div)"/>
    <xsl:sequence select="count($div/ancestor::tei:div) + 1"/>
  </xsl:function>

  <xsl:template match="tei:p" mode="sxedit:render">
    <p xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </p>
  </xsl:template>

</xsl:stylesheet>
