<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:variable name="fileName" select="//tei:sourceDoc/@xml:id"/>
    
    <xsl:template match="tei:teiHeader"/>
    
    <xsl:template match="tei:fw"/>
    <xsl:strip-space elements="tei:surface tei:s tei:lb"/>
    
    <xsl:template match="tei:surface">
        <xsl:variable name="fileName-generated" select="@facs"/>
        <xsl:result-document exclude-result-prefixes="#all" indent="no" method="text" byte-order-mark="no" href="{$fileName-generated}.index.txt">
            <xsl:apply-templates/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="tei:zone[not(child::tei:s)]"/>
    
    <xsl:template match="tei:zone/text()">
<xsl:text>
</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="//tei:s">
        <xsl:variable name="sentenceNum">
            <xsl:analyze-string select="@n" regex="(\d+?)\.\d.\d">
                <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
                <xsl:non-matching-substring/>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@n[not(contains(.,'|'))]">
                <xsl:for-each select=".">
                    <xsl:value-of select="$sentenceNum"/>||<xsl:apply-templates/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="not(@n)"/>
            <xsl:otherwise><xsl:analyze-string select="." regex="\n"><xsl:matching-substring><xsl:text></xsl:text></xsl:matching-substring></xsl:analyze-string></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:s/text()">
        <xsl:analyze-string select="." regex="\n\s+">
            <xsl:matching-substring><xsl:text> </xsl:text></xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="tei:del"/>
    
    <xsl:template match="tei:add">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:add/text()">
        <xsl:value-of select="normalize-space()"></xsl:value-of>
    </xsl:template>
    
    <xsl:template match="tei:unclear">
        <xsl:value-of select="normalize-space()"></xsl:value-of>
    </xsl:template>
    
    <xsl:template match="tei:note"/>
    
    <xsl:template match="tei:gap">
        <!-- create a variable whose value is the value of @extent (this should always be an integer) -->
        <xsl:variable name="missingChars" select="@extent"/>
        <!-- for the length of $missingChars (@extent) put an "x" character (e.g. if the `extent="3"` print "xxx"; if `extent="5"` print "xxxxx" -->
        <span class="gap"><xsl:for-each select="1 to $missingChars"><xsl:text>x</xsl:text></xsl:for-each></span>
    </xsl:template>
</xsl:stylesheet>