<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="ISO-8859-1"/>
  <xsl:param name="S_">S_</xsl:param>
  <xsl:param name="C_">C_</xsl:param>
  <xsl:param name="D_">D_</xsl:param>
  <xsl:param name="ComponentDataElementSeparator">:</xsl:param>
  <xsl:param name="DataElementSeparator">+</xsl:param>
  <xsl:param name="DecimalNotation">.</xsl:param>
  <xsl:param name="ReleaseIndicator">?</xsl:param>
  <xsl:param name="Reserved-for-future-use" select="string('&#x20;')"/>
  <xsl:param name="SegmentTerminator">'</xsl:param>
  <xsl:param name="EOL" select="string('&#x0D;&#x0A;')"/>
  <xsl:template match="/*">
    <!-- UNA -->
    <xsl:text>UNA</xsl:text>
    <xsl:value-of select="$ComponentDataElementSeparator"/>
    <xsl:value-of select="$DataElementSeparator"/>
    <xsl:value-of select="$DecimalNotation"/>
    <xsl:value-of select="$ReleaseIndicator"/>
    <xsl:value-of select="$Reserved-for-future-use"/>
    <xsl:value-of select="$SegmentTerminator"/>
    <xsl:value-of select="$EOL"/>
    <!-- Segments -->
    <xsl:for-each select="//*[substring(local-name(), 1, 2) = $S_]">
      <xsl:value-of select="substring-after(local-name(), $S_)"/>
      <xsl:for-each select="*">
        <!-- Composite Data Element -->
        <xsl:if test="self::*[substring(local-name(), 1, 2) = $C_][*[string-length(.) != 0] or following-sibling::*[substring(local-name(), 1, 2) = $C_][*[string-length(.) != 0]] or following-sibling::*[substring(local-name(), 1, 2) = $D_][string-length(.) != 0]]">
          <xsl:value-of select="$DataElementSeparator"/>
          <!-- Data Element within Composite Data Element -->
          <xsl:for-each select="*[substring(local-name(), 1, 2) = $D_][string-length(.) != 0 or following-sibling::*[string-length(.) != 0]]">
            <xsl:call-template name="AddReleaseIndicator">
              <xsl:with-param name="strText" select="text()"/>
            </xsl:call-template>
            <xsl:if test="position() != last()">
              <xsl:value-of select="$ComponentDataElementSeparator"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
        <!-- Data Element within Segment -->
        <xsl:if test="self::*[substring(local-name(), 1, 2) = $D_][string-length(.) != 0 or following-sibling::*[substring(local-name(), 1, 2) = $C_][*[string-length(.) != 0]] or following-sibling::*[substring(local-name(), 1, 2) = $D_][string-length(.) != 0]]">
          <xsl:value-of select="$DataElementSeparator"/>
          <xsl:call-template name="AddReleaseIndicator">
            <xsl:with-param name="strText" select="text()"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
      <xsl:value-of select="$SegmentTerminator"/>
      <xsl:value-of select="$EOL"/>
    </xsl:for-each>
  </xsl:template>
  <!-- AddReleaseIndicator -->
  <xsl:template name="AddReleaseIndicator">
    <xsl:param name="strText"/>
    <xsl:variable name="strTextTemp1">
      <xsl:call-template name="ReplaceAll">
        <xsl:with-param name="strText" select="$strText"/>
        <xsl:with-param name="strReplace" select="$ReleaseIndicator"/>
        <xsl:with-param name="strWith" select="concat($ReleaseIndicator, $ReleaseIndicator)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strTextTemp2">
      <xsl:call-template name="ReplaceAll">
        <xsl:with-param name="strText" select="$strTextTemp1"/>
        <xsl:with-param name="strReplace" select="$DataElementSeparator"/>
        <xsl:with-param name="strWith" select="concat($ReleaseIndicator, $DataElementSeparator)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="ReplaceAll">
      <xsl:with-param name="strText" select="$strTextTemp2"/>
      <xsl:with-param name="strReplace" select="$ComponentDataElementSeparator"/>
      <xsl:with-param name="strWith" select="concat($ReleaseIndicator, $ComponentDataElementSeparator)"/>
    </xsl:call-template>
  </xsl:template>
  <!-- ReplaceAll -->
  <xsl:template name="ReplaceAll">
    <xsl:param name="strText"/>
    <xsl:param name="strReplace"/>
    <xsl:param name="strWith"/>
    <xsl:choose>
      <xsl:when test="contains($strText, $strReplace)">
        <xsl:value-of select="concat(substring-before($strText, $strReplace), $strWith)"/>
        <xsl:call-template name="ReplaceAll">
          <xsl:with-param name="strText" select="substring-after($strText, $strReplace)"/>
          <xsl:with-param name="strReplace" select="$strReplace"/>
          <xsl:with-param name="strWith" select="$strWith"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$strText"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
