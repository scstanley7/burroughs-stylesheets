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
    
    <xsl:template match="tei:zone/text()">
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:note"/>
    
    <xsl:template match="tei:lb[not(@break)]">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:fw"/>
    
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
        <xsl:if test="preceding-sibling::node()">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space()"/>
        <xsl:if test="following-sibling::node()">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:s/*//text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    
    <xsl:template match="tei:subst">
        <span><xsl:apply-templates select="@* | node() | text()"></xsl:apply-templates></span>
    </xsl:template>
    
    <xsl:template match="tei:del">
        <xsl:choose>
            <!-- if <del> has the @rend attribute, put it in a span tag, display any text/process any nodes contained within -->
            <!-- also, match any attributes **see section below for more information on how attributes match** -->
            <xsl:when test="@rend ='overtyped'">
                <del style="color:black;"><xsl:apply-templates/></del>
            </xsl:when>
            <xsl:when test="@rend ='overwritten'">
                <del style="color:black;"><xsl:apply-templates/></del>
            </xsl:when>
            <xsl:when test="@rend='erased'">
                <span class="erased"><xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text></span>
            </xsl:when>
            <xsl:when test="@rend='crossedOut'">
                <del style="color:black;"><xsl:apply-templates/></del>
            </xsl:when>
            <!-- if it has a @type attribute just process the children -->
            <!-- NOTE: these documents do not have any <del> with both @rend and @status -->
            <!-- this particular <xsl:choose> would not work if there were <del> elements with both of these attributes -->
            <xsl:when test="@status">
                <span style="color:black;"><xsl:apply-templates/></span>
            </xsl:when>
            <!-- if the TEI <del> element has neither a @status nor a @rend attribute, put it in an HTML <del> tag -->
            <xsl:otherwise>
                <del style="color:black;"><xsl:apply-templates/></del>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- match the TEI <add> element -->
    <xsl:template match="tei:add[parent::tei:zone]"/>
    
    <xsl:template match="tei:add[parent::tei:s]">
        <sup><xsl:apply-templates select="@* | node() | text()"/></sup>
    </xsl:template>
    
    <!-- find each TEI <gap/> element -->
    <xsl:template match="tei:gap">
        <!-- create a variable whose value is the value of @extent (this should always be an integer) -->
        <xsl:variable name="missingChars" select="@extent"/>
        <!-- for the length of $missingChars (@extent) put an "x" character (e.g. if the `extent="3"` print "xxx"; if `extent="5"` print "xxxxx" -->
        <span class="gap"><xsl:for-each select="1 to $missingChars"><xsl:text>x</xsl:text></xsl:for-each></span>
    </xsl:template>
    
    <!-- match all TEI <metamark> elements -->
    <xsl:template match="tei:metamark">
        <xsl:choose>
            <!-- if it has a value of "insert" on @function, display a carrot within the HTML <i> element with a @class of "insert" -->
            <xsl:when test="@function='insert'"><i class="add">^</i></xsl:when>
            <xsl:when test="@function='transpose'"><span class="transpose-mark"><xsl:apply-templates/></span></xsl:when>
            <xsl:when test="@rend='upconnect'"><span class="upconnect"><xsl:apply-templates/></span></xsl:when>
            <xsl:when test="@rend='updownconnect'"><span class="updownconnect"><xsl:apply-templates/></span></xsl:when>
            <xsl:when test="@rend='downconnect'"><span class="downconnect"><xsl:apply-templates/></span></xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:seg[not(parent::tei:s)]"/>
    
    <xsl:template match="tei:seg[parent::tei:s]">
        <span class="transpose"><xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match="tei:hi[not(ancestor-or-self::tei:s)]"/>
    
    <xsl:template match="tei:hi[ancestor-or-self::tei:s]">
        <xsl:choose>
            <xsl:when test="@rend='circled'">
                <span class="circled"><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:when test="@rend='underline'">
                <u><xsl:apply-templates/></u>
            </xsl:when>
            <xsl:when test="@rend='boxedblock'">
                <span class="boxedblock"><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ******************************************************* -->
    <!-- ******************************************************* -->
    <!-- ***************** MATCHIN' ATTRIBUTES ***************** -->
    <!-- ******************************************************* -->
    <!-- ******************************************************* -->
    
    <!-- match all instances of @hand with the @style attrubute -->
    <!-- #WSB1 and #proofreader1 are blue -->
    <!-- #WSB2 should display in grey -->
    <!-- don't apply styling information for anything else -->
    <xsl:template match="@hand">
        <xsl:choose>
            <xsl:when test=".='#WSB1'">
                <xsl:attribute name="style">color:blue;</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='#WSB2'">
                <xsl:attribute name="style">color:grey;</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='proofreader1'">
                <xsl:attribute name="style">color:blue;</xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- @status and @instant should not match onto anything -->
    <xsl:template match="@status"/>
    <xsl:template match="@instant"/>
    <xsl:template match="@place"/>
    <xsl:template match="@rendition"/>
    
    
</xsl:stylesheet>