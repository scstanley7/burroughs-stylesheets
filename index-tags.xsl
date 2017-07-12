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
    
    <!--<xsl:template match="tei:subst">
        <xsl:apply-templates/>
    </xsl:template>-->
    
    <!--<xsl:template match="tei:subst/text()">
        <xsl:value-of select="normalize-space()"></xsl:value-of>
    </xsl:template>-->
    
    <xsl:template match="tei:add[parent::tei:zone]"/>
    <!--
    <xsl:template match="tei:add[parent::tei:s] | tei:add[parent::tei:subst]">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>-->
    
    <xsl:template match="tei:lb[not(@break)]">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!--<xsl:template match="tei:add/text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>-->
    
    <!--<xsl:template match="tei:del">
        <del><xsl:apply-templates/></del>
    </xsl:template>-->
    
    <xsl:template match="tei:metamark"/>
    
    <xsl:template match="tei:note"/>
    
    <xsl:template match="tei:seg[not(parent::tei:s)]"/>
    
    <xsl:template match="tei:gap[not(parent::tei:s)]"></xsl:template>
    
    <xsl:template match="tei:del">
        <xsl:choose>
            <!-- if <del> has the @rend attribute, put it in a span tag, display any text/process any nodes contained within -->
            <!-- also, match any attributes **see section below for more information on how attributes match** -->
            <xsl:when test="@rend">
                <span><xsl:apply-templates select="@* | node() | text()"></xsl:apply-templates></span>
            </xsl:when>
            <!-- if it has a @type attribute just process the children -->
            <!-- NOTE: these documents do not have any <del> with both @rend and @status -->
            <!-- this particular <xsl:choose> would not work if there were <del> elements with both of these attributes -->
            <xsl:when test="@status">
                <xsl:apply-templates/>
            </xsl:when>
            <!-- if the TEI <del> element has neither a @status nor a @rend attribute, put it in an HTML <del> tag -->
            <xsl:otherwise>
                <del><xsl:apply-templates/></del>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- find each TEI <gap/> element -->
    <xsl:template match="tei:gap">
        <!-- create a variable whose value is the value of @extent (this should always be an integer) -->
        <xsl:variable name="missingChars" select="@extent"/>
        <!-- for the length of $missingChars (@extent) put an "x" character (e.g. if the `extent="3"` print "xxx"; if `extent="5"` print "xxxxx" -->
        <span class="gap"><xsl:for-each select="1 to $missingChars"><xsl:text>x</xsl:text></xsl:for-each></span>
    </xsl:template>
    
    <!-- match the TEI <subst> element, put it in an HTML <span> tag, match all attributes (specified below), process all nodes, and display all text -->
    <xsl:template match="tei:subst">
        <span><xsl:apply-templates select="@* | node() | text()"></xsl:apply-templates></span>
    </xsl:template>
    
    <!-- match the TEI <add> element -->
    <xsl:template match="tei:add">
        <xsl:if test="@place='inline'">
            <!-- find all the TEI <add> elements with @place="inline" -->
            <xsl:choose>
                <!-- if its direct parent is TEI <subst> put it in an <a> tag -->
                <!-- this part is not done yet; have to figure out how to display the corresponding <del> tag (hover? on click?) -->
                <xsl:when test="parent::tei:subst">
                    <a><xsl:apply-templates/></a>
                </xsl:when>
                <!-- if its parent is anything other than TEI <subst>, stick it in an HTML <i> tag -->
                <xsl:otherwise>
                    <i><xsl:apply-templates/></i>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <!-- if @place on <add> is "supralinear", stick it in an HTML <sup> tag -->
        <xsl:if test="@place='supralinear'">
            <sup><xsl:apply-templates/></sup>
        </xsl:if>
        <!-- if @place on <add> is "infralinear", stick it in an HTML <sub> tag -->
        <xsl:if test="@place='infralinear'">
            <sub><xsl:apply-templates/></sub>
        </xsl:if>
        <!-- if @place is margintop, -bottom, -left, or -right, stick it in an HTML <span> tag with a @class whose value is whatever the value of @place is -->
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
    
    <!-- match all instances of @rend -->
    <!-- values of "overwritten" and "overtyped" should be given a @class of "del-hover"; "erased" should be given a class of "erased" -->
    <xsl:template match="@rend">
        <xsl:if test=".='overwritten'">
            <xsl:attribute name="class">del-hover</xsl:attribute>
        </xsl:if>
        <xsl:if test=".='overtyped'">
            <xsl:attribute name="class">del-hover</xsl:attribute>
        </xsl:if>
        <xsl:if test=".='erased'">
            <xsl:attribute name="class">erased</xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <!-- @status and @instant should not match onto anything -->
    <xsl:template match="@status"/>
    <xsl:template match="@instant"/>
    
</xsl:stylesheet>