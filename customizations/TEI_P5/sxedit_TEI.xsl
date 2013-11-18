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
  <xsl:import href="tei2html.xsl"/>
  
  <xsl:variable name="sxedit:editor-name" as="element(html:small)">
    <small xmlns="http://www.w3.org/1999/xhtml">TEI P5</small>
  </xsl:variable>

  <xsl:variable name="sxedit:doc-condition" as="xs:string" select="'[namespace-uri(/*) = ''http://www.tei-c.org/ns/1.0'']'"/>
  <xsl:variable name="sxedit:frag-expression" as="xs:string" select="'//*:div[not(ancestor::*:div)][not(*:divGen)]'"/>
  <xsl:variable name="sxedit:title-expression" as="xs:string" select="'*:head'"/>

<!--  <xsl:variable name="initial-html-schematrons" as="document-node(element(s:schema)*"-->

</xsl:stylesheet>
