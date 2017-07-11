<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs tei"
    version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <xsl:variable name="fileName" select="//tei:sourceDoc/@xml:id"/>
    
    <xsl:strip-space elements="tei:surface tei:s tei:subst tei:add tei:del tei:unclear tei:hi tei:metamark"/>
    
    <xsl:template match="tei:teiHeader"/>
    
    <xsl:output indent="no"/>
    
    <xsl:template match="tei:surface">
        <xsl:variable name="fileName-generated" select="@facs"/>
        <xsl:result-document exclude-result-prefixes="#all" indent="no" byte-order-mark="no" href="{$fileName-generated}.index.html" omit-xml-declaration="yes" method="xml">
            <xsl:apply-templates/>
        </xsl:result-document>
    </xsl:template>
    
    
    
    <xsl:template match="tei:fw"/>
    
    <xsl:template match="tei:zone/text()">
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:s">
        <xsl:variable name="sentenceNum">
            <xsl:analyze-string select="@n" regex="(\d+?)\.\d.\d">
                <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
                <xsl:non-matching-substring/>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@n[not(contains(.,'|'))]">
                <xsl:for-each select=".">
                    <xsl:value-of select="$sentenceNum"/>||<span class="icesp-comparable"><xsl:apply-templates/></span>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="not(@n)"/>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="tei:s/text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    
    <xsl:template match="tei:s/*//text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    
    <xsl:template match="tei:hi[ancestor-or-self::tei:s]">
        <xsl:choose>
            <xsl:when test="@rend='circled'">
                <span class="circled"><xsl:value-of select="normalize-space()"/></span>
            </xsl:when>
            <xsl:when test="@rend='underline'">
                <span class="underline"><xsl:value-of select="normalize-space()"/></span>
            </xsl:when>
            <xsl:when test="@rend='boxedblock'">
                <span class="boxedblock"><xsl:value-of select="normalize-space()"/></span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:hi[not(ancestor-or-self::tei:s)]"/>
    
    <xsl:template match="tei:subst">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--<xsl:template match="tei:subst/text()">
        <xsl:value-of select="normalize-space()"></xsl:value-of>
    </xsl:template>-->
    
    <xsl:template match="tei:add[parent::tei:zone]"/>
    
    <xsl:template match="tei:add[parent::tei:s] | tei:add[parent::tei:subst]">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>
    
    <xsl:template match="tei:lb[not(@break)]">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!--<xsl:template match="tei:add/text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>-->
    
    <xsl:template match="tei:del">
        <del><xsl:apply-templates/></del>
    </xsl:template>
    
    <xsl:template match="tei:metamark"/>
    
    <xsl:template match="tei:note"/>
    
    <xsl:template match="tei:seg[not(parent::tei:s)]"/>
    
</xsl:stylesheet>