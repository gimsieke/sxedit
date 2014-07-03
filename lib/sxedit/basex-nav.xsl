<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="2.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:sxedit="http://www.le-tex.de/namespace/sxedit"
  xmlns:rfc="http://www.ietf.org/rfc"
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
  xmlns:prop="http://saxonica.com/ns/html-property"
  xmlns:js="http://saxonica.com/ns/globalJS"
  xmlns:style="http://saxonica.com/ns/html-style-property"
  xmlns:rest="http://basex.org/rest"
  xmlns="http://www.w3.org/1999/xhtml"
  extension-element-prefixes="ixsl"
  >

  <!-- you can submit the fragment URL in the GET query parameter for debugging purposes, e.g. 
    frag=http://localhost:8984/content/frag/PG_32856_TEI/32856.tei.xml?xpath=%2FQ%7Bhttp%3A%2F%2Fwww.tei-c.org%2Fns%2F1.0%7DTEI%5B1%5D
    -->
  
  <xsl:template name="sxedit:nav">
    
    <xsl:variable name="initial-uri" as="xs:string" select="'http://localhost:8984/content/dbs'"/>
    
    <footer xmlns="http://www.w3.org/1999/xhtml" class="bs-footer">
      <nav class="navbar navbar-default" role="navigation">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">BaseX</a>
        </div>
        <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
          <div class="navbar-form navbar-left" role="search">
            <div class="form-group">
              <input id="db-url" type="text" size="42" class="form-control" value="{$initial-uri}"/>
            </div>
            <button id="basex-databases-button" type="submit" class="btn btn-default">look for DBs</button>
          </div>
          <div id="basex-dbs"/>
          <div class="navbar-form navbar-left" role="search">
            <button id="basex-save-button" type="submit" class="btn btn-default" style="display:none">save</button>
          </div>
        </div>
      </nav>
    </footer>
  </xsl:template>

  <xsl:template match="html:*[@id eq 'basex-databases-button']" mode="ixsl:onclick">
    <xsl:variable name="db-url" as="xs:string" select="id('db-url', ixsl:page())/@prop:value"/>
    <xsl:variable name="db-url" as="xs:string" select="if ($sxedit:doc-condition) 
                                                       then concat($db-url, '?doc-condition=', sxedit:escape-html-uri($sxedit:doc-condition))
                                                       else $db-url"/>
    <xsl:message select="'dbs: ', $db-url"/>
    <xsl:result-document href="#basex-dbs" method="ixsl:replace-content">
      <ul class="nav navbar-nav">
        <xsl:apply-templates select="document($db-url)" mode="sxedit:nav"/>
      </ul>
    </xsl:result-document>
    <xsl:for-each select="//*:button[@id='basex-save-button']">
      <ixsl:set-attribute name="style:display" select="'none'"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[@id eq 'basex-save-button']" mode="ixsl:onclick">
    <xsl:message select="'GGGGGG: ', ancestor::*:div[last()]/descendant-or-self::*:div[@id = 'sxedit-main']/@data-xpath"/>
    <xsl:variable name="xmldoc" as="document-node(element(*))">
      <xsl:document>
        <frag xmlns="http://www.le-tex.de/namespace/sxedit" db="PG32856" doc="32856.tei.xml"
          xpath="{ancestor::*:div[last()]/descendant-or-self::*:div[@id = 'sxedit-main']/@data-xpath}">
          <xsl:call-template name="sxedit:restore"/>
        </frag>
      </xsl:document>
    </xsl:variable>
    <!-- Note that the XQuery in the storage tier has to handle unescaping <______head> and <_____body> -->  
    <xsl:variable name="serialized" as="xs:string" select="sxedit:serialize-xml($xmldoc, false())"/>
    <xsl:sequence select="ixsl:call(ixsl:window(), 'Sxedit.post', $serialized, 'http://localhost:8984/content/save-frag')"/>
  </xsl:template>
    
  <xsl:template match="response[db | doc | frag]" mode="sxedit:nav">
    <li class="dropdown">
      <a href="#" class="dropdown-toggle" data-toggle="dropdown">
        <xsl:apply-templates select="*[1]" mode="sxedit:response-type"/>
        <b class="caret"/></a>
      <ul class="dropdown-menu">
        <xsl:apply-templates mode="#current">
          <xsl:sort select="@name"/>
        </xsl:apply-templates>
      </ul>
    </li>
  </xsl:template>
  
  <xsl:template match="*" mode="sxedit:response-type" as="element(html:span)">
    <span>
      <xsl:choose>
        <xsl:when test="self::db">Databases</xsl:when>
        <xsl:when test="self::doc">Documents</xsl:when>
        <xsl:when test="self::frag">Fragments</xsl:when>
      </xsl:choose>
    </span>
  </xsl:template>
  
  <xsl:template match="db" mode="sxedit:response-url" as="xs:string">
    <xsl:message select="'db: ', base-uri()"/>
    <xsl:variable name="r" as="xs:string" select="replace(base-uri(), '/dbs', concat('/db/', @name))"/>
<!--    <xsl:message select="'dbr: ', $r"/>-->
    <xsl:sequence select="$r"/>
  </xsl:template>
  
  <xsl:template match="doc" mode="sxedit:response-url" as="xs:string">
    <xsl:variable name="url-elt" as="element(rfc:url)" select="sxedit:parse-url(base-uri())"/>
    <xsl:variable name="name" as="xs:string" select="sxedit:escape-html-uri(replace(@name, '/', '∕'))"/>
    <xsl:variable name="url-elt" as="element(rfc:url)">
      <xsl:for-each select="$url-elt">
        <xsl:copy>
          <xsl:attribute name="rfc:base" select="replace(@rfc:base, '/db/(.+)', concat('/doc/$1/', $name))"/>
          <xsl:if test="$sxedit:frag-expression">
            <xsl:attribute name="frag-expression" select="sxedit:escape-html-uri($sxedit:frag-expression)"/>  
          </xsl:if>
          <xsl:if test="$sxedit:title-expression">
            <xsl:attribute name="title-expression" select="sxedit:escape-html-uri($sxedit:title-expression)"/>  
          </xsl:if>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="r" as="xs:string" select="sxedit:serialize-url($url-elt)"/>
    <xsl:message select="'docr: ', $r"/>
    <xsl:sequence select="$r"/>
  </xsl:template>

  <xsl:template match="frag" mode="sxedit:response-url" as="xs:string">
    <xsl:variable name="r" as="xs:string" select="sxedit:set-url-param(replace(base-uri(), '/doc/', '/frag/'), 'xpath', @xpath)"/>
    <xsl:message select="'fragr: ', $r"/>
    <xsl:message select="'bu: ', base-uri()"/>
    <xsl:sequence select="$r"/>
  </xsl:template>
  
  
  <xsl:template match="doc | db" mode="sxedit:nav">
    <xsl:variable name="url" as="xs:string">
      <xsl:apply-templates select="." mode="sxedit:response-url"/>
    </xsl:variable>
    <li class="menu-item dropdown dropdown-submenu">
      <a href="#" data-target="{$url}" class="basex-select">
        <xsl:value-of select="@name"/>
      </a>
      <!--<ul class="dropdown-menu internal">
        <li class="menu-item">
          <a href="{$url}">raw <xsl:value-of select="local-name()"/> link</a>
        </li>
      </ul>-->
    </li>
  </xsl:template>

  <xsl:template match="frag" mode="sxedit:nav">
    <xsl:variable name="url" as="xs:string">
      <xsl:apply-templates select="." mode="sxedit:response-url"/>
    </xsl:variable>
    <li class="menu-item dropdown dropdown-submenu">
      <a href="#" data-target="{$url}" class="basex-select">
        <xsl:value-of select="@title"/>
      </a>
      <ul class="dropdown-menu">
        <li class="menu-item">
          <a href="#" data-target="{$url}" class="basex-select">Open</a>
        </li>
        <li class="menu-item">
          <a href="#">Overwrite with buffer</a>
        </li>
        <li class="menu-item">
          <a href="#">Save buffer before</a>
        </li>
        <li class="menu-item">
          <a href="#">Save buffer after</a>
        </li>
        <!--<li class="menu-item internal">
          <a href="{$url}">raw content fragment</a>
        </li>-->

      </ul>
    </li>
  </xsl:template>

  <xsl:template name="sxedit:custom-init">
    <xsl:param name="page-url" as="xs:string"/>
    <xsl:variable name="frag" select="sxedit:get-url-param('frag', $page-url)" as="xs:string?"/>
    <xsl:if test="$frag">
      <xsl:call-template name="sxedit:render">
        <xsl:with-param name="content" select="document(sxedit:escape-html-uri($frag))"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="html:a[sxedit:contains-token(@class, 'basex-select')]" mode="ixsl:onclick">
    <!-- fill the next level: -->
    <!-- §CE: ancestor::*:ul[2] does not seem to work (will complain that context is on the document node) -->
    <xsl:result-document href="?select=../ancestor::*:ul[2]" method="ixsl:replace-content">
      <xsl:apply-templates select="ancestor::*:ul[2]/*[not(. &gt;&gt; current())]" mode="sxedit:html-nav">
        <xsl:with-param name="title-span" select="../../preceding-sibling::*:a[1]/*:span[1]" as="element(html:span)" tunnel="yes"/>
        <xsl:with-param name="title-content" select="." as="xs:string" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="document(sxedit:set-url-param(@data-target, 'rnd', sxedit:random-string()))" mode="sxedit:nav"/>
    </xsl:result-document>
    <xsl:for-each select="//*:button[@id='basex-save-button']">
      <ixsl:set-attribute name="style:display" select="'none'"/>
    </xsl:for-each>
  </xsl:template>

  <!--<xsl:template match="html:input[@type = 'checkbox'][@id = 'internal-links']">
    
  </xsl:template>-->

  <xsl:template match="html:a[sxedit:contains-token(@class, 'basex-select')][matches(@data-target, '/frag/')]" priority="2" mode="ixsl:onclick">
    <!-- replace the fragment heading -->
    <xsl:result-document href="?select=../ancestor::*:li[2]/*:a" method="ixsl:replace-content">
      <span>
        <xsl:value-of select="../ancestor::*:li[1]/*:a"/>
      </span>
      <!-- Dropdown triangle: -->
      <xsl:sequence select="../ancestor::*:li[2]/*:a/*[not(self::*:span)]"/>
    </xsl:result-document>
    <!-- fill the main editor: -->
    <xsl:call-template name="sxedit:render">
      <!-- adding some random string to prevent cached results to appear.-->
      <xsl:with-param name="content" select="document(sxedit:set-url-param(@data-target, 'rnd', sxedit:random-string()))"/>
      <xsl:with-param name="fragment-url" select="@data-target"/>
    </xsl:call-template>
    <xsl:for-each select="//*:button[@id='basex-save-button']">
      <ixsl:set-attribute name="style:display" select="'inline'"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="@* | *" mode="sxedit:html-nav">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:span" mode="sxedit:html-nav">
    <xsl:param name="title-span" as="element(html:span)" tunnel="yes"/>
    <xsl:param name="title-content" as="xs:string" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test=". is $title-span">
        <xsl:copy>
          <xsl:value-of select="$title-content"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>