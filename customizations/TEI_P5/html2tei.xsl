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
  xmlns="http://www.tei-c.org/ns/1.0"
  extension-element-prefixes="ixsl"
  exclude-result-prefixes="#all">

  <xsl:template match="/" as="element(tei:body)">
    <body>
      <xsl:call-template name="sxedit:restore"/>
    </body>
  </xsl:template>

  <xsl:template match="*" mode="sxedit:restore">
    <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*" mode="sxedit:restore">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="*:p" mode="sxedit:restore">
    <para>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </para>
  </xsl:template>
  
  <xsl:template name="sxedit:restore">
    
    <!--<xsl:for-each-group select="*" group-starting-with="*[sxedit:has-max-level(.)">
      
    </xsl:for-each-group>-->
  </xsl:template>

  <xsl:function name="sxedit:isHeading" as="xs:boolean"> 
    <xsl:param name="elt" as="element(*)" /> 
    <xsl:value-of select="matches(local-name($elt), '^h\d$')" /> 
  </xsl:function>
  
  <xsl:function name="sxedit:heading-level" as="xs:double"> 
    <xsl:param name="elt" as="element(*)" /> 
    <xsl:value-of select="number(replace(local-name($elt), '^h(\d)$', '$1'))" /> 
  </xsl:function> 
  

</xsl:stylesheet>
