<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <xsl:template match="*">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="TEI.2">
    <xsl:text>&#xa;</xsl:text>
    <xsl:processing-instruction name="xml-model">href="tei_math.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
    <xsl:text>&#xa;</xsl:text>
    <TEI>
      <xsl:apply-templates select="@*, node()"/>
    </TEI>
  </xsl:template>
  
  <xsl:template match="@lang | @id">
    <xsl:attribute name="xml:{name()}" select="."/>
  </xsl:template>

  <xsl:template match="language/@id">
    <xsl:attribute name="ident" select="."/>
  </xsl:template>
  
  <xsl:template match="date/@value">
    <xsl:attribute name="when" select="."/>
  </xsl:template>
  
  <xsl:template match="@default[. eq 'NO']">
    <xsl:attribute name="{name()}" select="'false'"/>
  </xsl:template>
  
  <xsl:template match="@anchored[. eq 'yes']">
    <xsl:attribute name="{name()}" select="'true'"/>
  </xsl:template>
  
  <xsl:template match="index/@index">
    <xsl:attribute name="indexName" select="."/>
  </xsl:template>
  
  <xsl:template match="@direct[. eq 'unspecified']"/>

  <xsl:template match="@targOrder[. eq 'U']"/>
  
  <xsl:template match="@cols[. eq '1']"/>

  <xsl:template match="@rows[. eq '1']"/>

  <xsl:template match="@part[. eq 'N']"/>
  
  <xsl:template match="@sample[. eq 'complete']"/>

  <xsl:template match="@org[. eq 'uniform']"/>

  <xsl:template match="encodingDesc[every $n in node() satisfies ($n/self::text()[matches(., '^\s*$')])]"/>
  
  <xsl:template match="pgExtensions"/>
  
  <xsl:template match="@TEIform | @status"/>

  <xsl:template match="*[@reg]">
    <choice>
      <orig>
        <xsl:apply-templates select="@* except @reg, node()"/>
      </orig>
      <reg>
        <xsl:value-of select="@reg"/>
      </reg>
    </choice>
  </xsl:template>

  <xsl:template match="titleStmt">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*, node()"/>
      <xsl:apply-templates select="../../revisionDesc/change/respStmt"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="respStmt">
    <xsl:element name="{name()}">
      <xsl:attribute name="xml:id" select="generate-id()"/>
      <xsl:if test="not(resp)">
        <resp>unspecified</resp>
      </xsl:if>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="revisionDesc/change">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="respStmt" mode="to-who"/>
      <xsl:apply-templates select="@*, node() except respStmt"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="revisionDesc/change/item">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="respStmt" mode="to-who">
    <xsl:attribute name="who" select="concat('#', generate-id())"/>
  </xsl:template>


</xsl:stylesheet>