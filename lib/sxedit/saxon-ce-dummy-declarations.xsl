<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT" xmlns:js="http://saxonica.com/ns/globalJS"
    version="2.0">

    <!-- dummy definitions of functions to satisfy the Oxygen editor -->

    <xsl:function name="ixsl:page" override="no"/>

    <xsl:function name="ixsl:source" override="no"/>

    <xsl:function name="ixsl:event" override="no"/>

    <xsl:function name="ixsl:window" override="no"/>

    <xsl:function name="ixsl:get" override="no">
        <xsl:param name="object"/>
        <xsl:param name="property"/>
    </xsl:function>

  <xsl:function name="ixsl:call" override="no">
    <xsl:param name="object"/>
    <xsl:param name="method"/>
    <xsl:param name="argument1"/>
    <xsl:param name="argument2"/>
    <xsl:param name="other-arguments"/>
  </xsl:function>

    <xsl:function name="ixsl:eval" override="no">
        <xsl:param name="script"/>
    </xsl:function>

    <xsl:function name="js:includeJS" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

    <xsl:function name="js:makeCommand" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

    <xsl:function name="js:update" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

    <xsl:function name="js:transform" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

    <xsl:function name="js:Saxon.parseXML" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

    <xsl:function name="js:Saxon.requestXML" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

    <xsl:function name="js:Saxon.newXSLT20Processor" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

    <xsl:function name="js:serializeXML" override="no">
        <xsl:param name="arg"/>
    </xsl:function>

  <xsl:function name="ixsl:serialize-xml" override="no">
    <xsl:param name="arg"/>
  </xsl:function>
  

</xsl:stylesheet>
