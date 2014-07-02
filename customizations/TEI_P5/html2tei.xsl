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

  <xsl:template match="@class" mode="sxedit:restore"/>

  <xsl:template match="*:div[@id = 'sxedit-main']" mode="sxedit:restore">
    <xsl:choose>
      <xsl:when test="@data-element-name">
        <xsl:element name="{@data-element-name}" namespace="{(@data-namespace-uri, '')[1]}">
          <xsl:apply-templates select="@*[starts-with(name(), 'data-attribute-')]" mode="#current"/>
          <xsl:variable name="nested-headings" as="element(*)*">
            <xsl:call-template name="tei:nest-headings">
              <xsl:with-param name="nodes" select="*"/>
              <xsl:with-param name="headings" select="*[sxedit:isHeading(.)]"/>
              <xsl:with-param name="skip-first-level" select="true()"/>
            </xsl:call-template>
          </xsl:variable>
          <!-- could transform in another mode -->
          <xsl:sequence select="$nested-headings"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <TEI>
          <teiHeader>
            <fileDesc>
              <titleStmt>
                <title>Title</title>
              </titleStmt>
              <publicationStmt>
                <p>Publication Information</p>
              </publicationStmt>
              <sourceDesc>
                <p>Information about the source</p>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
          <text>
            <!-- as unbelievable as it is, you cannot serialize an element called 'body' in no matter what namespace -->
            <_____body>
              <xsl:variable name="nested-headings" as="element(*)*">
                <xsl:call-template name="tei:nest-headings">
                  <xsl:with-param name="nodes" select="*"/>
                  <xsl:with-param name="headings" select="*[sxedit:isHeading(.)]"/>
                </xsl:call-template>
              </xsl:variable>
              <!-- could transform in another mode -->
              <xsl:sequence select="$nested-headings"/>
            </_____body>
          </text>
        </TEI>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@*[starts-with(name(), 'data-attribute-')]" mode="sxedit:restore">
    <xsl:attribute name="{replace(replace(name(), '^data-attribute-', ''), '___', ':')}" select="."/>
  </xsl:template>

  <xsl:template name="tei:nest-headings" as="element()*">
    <xsl:param name="nodes" as="element(*)*"/>
    <xsl:param name="headings" as="element(*)*"/>
    <xsl:param name="skip-first-level" as="xs:boolean" select="false()"/>
    <xsl:variable name="min-level" select="min((7, for $n in $headings return sxedit:heading-level($n)))" as="xs:double"/>
    <xsl:choose>
      <xsl:when test="$min-level eq 7">
        <xsl:apply-templates select="$nodes" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each-group select="$nodes"
          group-starting-with="*[exists(. intersect $headings)][sxedit:heading-level(.) = $min-level]">
          <xsl:choose>
            <xsl:when test="sxedit:heading-level(.) = $min-level">
              <xsl:variable name="current-heding-level" as="xs:double" select="sxedit:heading-level(.)"/>
              <xsl:variable name="result" as="node()*">
                <_____head>
                  <xsl:apply-templates select="@*, node()" mode="#current"/>
                </_____head>
                <xsl:call-template name="tei:nest-headings">
                  <xsl:with-param name="nodes" select="current-group()[position() gt 1]"/>
                  <xsl:with-param name="headings" select="$headings[sxedit:heading-level(.) gt $current-heding-level]"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$skip-first-level">
                  <xsl:sequence select="$result"/>
                </xsl:when>
                <xsl:otherwise>
                  <div>
                    <xsl:sequence select="$result"/>
                  </div>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:br" mode="sxedit:restore"/>

  <xsl:function name="sxedit:isHeading" as="xs:boolean"> 
    <xsl:param name="elt" as="element(*)" /> 
    <xsl:value-of select="matches(local-name($elt), '^h\d$')" /> 
  </xsl:function>
  
  <xsl:function name="sxedit:heading-level" as="xs:double"> 
    <xsl:param name="elt" as="element(*)" /> 
    <xsl:value-of select="number(replace(local-name($elt), '^h(\d)$', '$1'))" /> 
  </xsl:function> 
  

</xsl:stylesheet>
