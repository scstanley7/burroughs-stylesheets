<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <xsl:variable name="fileName" select="//tei:sourceDoc/@xml:id"/>
    <xsl:variable name="docName" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
    
    <xsl:template match="tei:teiHeader"/>
    
    <xsl:template match="tei:surface" exclude-result-prefixes="#all">
        <xsl:variable name="fileName" select="@facs"/>
        <xsl:variable name="pn" select="@n"/>
        <xsl:variable name="side" select="@rend"/>
        <div>
            <xsl:attribute name="id">
                <xsl:value-of select="@facs"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="@ana">
                    <xsl:attribute name="class">handwritten</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">typewritten</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <p class="page-number"><xsl:value-of select="$pn"/><xsl:text> </xsl:text><xsl:value-of select="$side"></xsl:value-of></p>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:zone">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="tei:anchor">
        <xsl:variable name="note-ptr" select="@corresp"/>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="$note-ptr"/></xsl:attribute>
            <xsl:text>*</xsl:text>
        </a>
    </xsl:template>
    
    <!-- Notes should be displayed with an asterisk an on-click or with hover  -->
    <xsl:template match="tei:note">
        <xsl:variable name="note-id" select="@xml:id"/>
        <span class="note">
            <xsl:attribute name="id"><xsl:value-of select="$note-id"/></xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:lb"><br/></xsl:template>
    
    <xsl:template match="tei:fw">
        <span>
            <xsl:attribute name="class">pageNum</xsl:attribute>
            <xsl:attribute name="style">
                <xsl:choose>
                    <xsl:when test="@place='top-center'">align:center;</xsl:when>
                    <xsl:when test="@place='top-left'">align:left;</xsl:when>
                    <xsl:when test="@place='top-right'">align:right;</xsl:when>
                    <xsl:when test="@place='bottom-center'">align:center;</xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:s">
        <xsl:variable name="sentenceNum" select="@n"/>
        <xsl:choose>
            <xsl:when test="@n[contains(.,'|')]"><xsl:apply-templates/></xsl:when>
            <xsl:otherwise><span class="icesp-comparable"><xsl:attribute name="id"><xsl:value-of select="$sentenceNum"/></xsl:attribute><xsl:apply-templates/></span></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:del">
        <xsl:choose>
            <xsl:when test="@rend">
                <span><xsl:apply-templates select="@* | text()"></xsl:apply-templates></span>
            </xsl:when>
            <xsl:when test="@type">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <del><xsl:apply-templates/></del>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- this is an unacceptably hacky solution, but it works for the time being -->
    <!-- while we use this, we need to test documents for <gap> elements where @extent > 50 (this is unlikely) -->
    <xsl:template match="tei:gap">
        <xsl:variable name="missing-chars" select="@extent"/>
        <xsl:variable name="exes" select="substring('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',1,$missing-chars)"/>
        <span class="gap"><xsl:value-of select="$exes"/></span>
    </xsl:template>
    
    <xsl:template match="tei:add">
        <xsl:if test="@place='inline'">
            <xsl:choose>
                <xsl:when test="parent::tei:subst">
                    <a><xsl:apply-templates/></a>
                </xsl:when>
                <xsl:otherwise>
                    <i><xsl:apply-templates/></i>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@place='supralinear'">
            <sup><xsl:apply-templates/></sup>
        </xsl:if>
        <xsl:if test="@place='infralinear'">
            <sub><xsl:apply-templates/></sub>
        </xsl:if>
        <xsl:if test="@place='margintop'">
            <span class="margintop"><xsl:apply-templates/></span>
        </xsl:if>
        <xsl:if test="@place='marginbottom'">
            <span class="marginbottom"><xsl:apply-templates/></span>
        </xsl:if>
        <xsl:if test="@place='marginleft'">
            <span class="marginleft"><xsl:apply-templates/></span>
        </xsl:if>
        <xsl:if test="@place='marginright'">
            <span class="marginright"><xsl:apply-templates/></span>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@hand">
        <xsl:if test=".='#WSB1'">
            <xsl:attribute name="style">color:blue;</xsl:attribute>
        </xsl:if>
        <xsl:if test=".='#WSB2'">
            <xsl:attribute name="style">color:grey;</xsl:attribute>
        </xsl:if>
        <xsl:if test=".='proofreader1'">
            <xsl:attribute name="style">color:blue;</xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@rend">
        <xsl:if test=".='overwritten'">
            <xsl:attribute name="style">del-hover</xsl:attribute>
        </xsl:if>
        <xsl:if test=".='overtyped'">
            <xsl:attribute name="style">del-hover</xsl:attribute>
        </xsl:if>
        <xsl:if test=".='erased'">
            <xsl:attribute name="style">erased</xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@status"/>
    <xsl:template match="@instant"/>
    
</xsl:stylesheet>