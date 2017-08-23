<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <!-- suppress TEI header -->
    <xsl:template match="tei:teiHeader"/>
    
    <!-- create a new HTML document for each witness -->
    <!-- @exclude-result-prefixes will ensure that you don't end up with a tei namespace declared on every element -->
    <xsl:template match="tei:surfaceGrp">
        <xsl:variable name="fileName" select="//tei:sourceDoc/@xml:id"></xsl:variable>
        <xsl:result-document exclude-result-prefixes="#all" indent="yes" method="html" omit-xml-declaration="no" href="{$fileName}.html">
            <html>
                <head>
                    <link type="text/css" rel="stylesheet" href="bladerunner.css"/>
                </head>
                <body><xsl:apply-templates/></body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!-- convert TEI <surface> elements to HTML <div>s -->
    <xsl:template match="tei:surface">
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
    
    <!-- match every TEI <zone> element with an HTML <p> -->
    <xsl:template match="tei:zone">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <!-- put each TEI <note> element into an HTML <span> and assign it an ID of whatever @xml:id on <note> is -->
    <!-- DISPLAY NOTE: Notes should be displayed with an asterisk an on-click or with hover  -->
    <xsl:template match="tei:note">
        <xsl:variable name="note-id" select="@xml:id"/>
        <span class="anchor">
            <xsl:text>*</xsl:text><span class="note"><xsl:apply-templates/></span>
        </span>
    </xsl:template>
    
    <!-- TEI <lb/> should be replaced with HTML <br/> -->
    <xsl:template match="tei:lb"><br/></xsl:template>
    
    <!-- match TEI <fw> with an HTML <span> element with a @class of "pageNum" -->
    <!-- use inline CSS (@style) to specify the placement of the page number, based on the information recorded in the @place attribute -->
    <xsl:template match="tei:fw">
        <span>
            <xsl:attribute name="class">pageNum</xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- match the TEI <s> element -->
    <xsl:template match="tei:s">
        <!-- create a variable called "sentenceNum" whose value is the value of the @n attribute on <s> -->
        <xsl:variable name="sentenceNum" select="@n"/>
        <xsl:choose>
            <!-- if @n contains a vertical bar, simply keep digging down the tree (don't surround with HTML attributes, but still process the children/text nodes within) -->
            <xsl:when test="@n[contains(.,'|')]"><xsl:apply-templates/></xsl:when>
            <!-- if it *does* contain a vertical bar, surround in HTML <span> with a @class of "icesp-comparable" and give it an id of whatever the sentenceNum (@n on <tei:s>) is -->
            <!-- process the children further down the tree -->
            <xsl:otherwise><span class="icesp-comparable"><xsl:attribute name="id"><xsl:value-of select="$sentenceNum"/></xsl:attribute><xsl:apply-templates/></span></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- match the TEI <subst> element, put it in an HTML <span> tag, match all attributes (specified below), process all nodes, and display all text -->
    <xsl:template match="tei:subst">
        <span><xsl:apply-templates select="@* | node() | text()"></xsl:apply-templates></span>
    </xsl:template>
    
    <!-- match the TEI <del> element -->
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
    <xsl:template match="tei:add">
        <xsl:variable name="rotate" select="@rendition"/>
        <xsl:if test="@place='inline'">
            <!-- find all the TEI <add> elements with @place="inline" -->
            <sup><xsl:apply-templates select="@* | node() | text()"/></sup>
        </xsl:if>
        <!-- if @place on <add> is "supralinear", stick it in an HTML <sup> tag -->
        <xsl:if test="@place='supralinear'">
            <sup><xsl:apply-templates select="@* | node() | text()"/></sup>
        </xsl:if>
        <!-- if @place on <add> is "infralinear", stick it in an HTML <sub> tag -->
        <xsl:if test="@place='infralinear'">
            <sub><xsl:apply-templates select="@* | node() | text()"/></sub>
        </xsl:if>
        <!-- if @place is margintop, -bottom, -left, or -right, stick it in an HTML <span> tag with a @class whose value is whatever the value of @place is -->
        <xsl:if test="@place='margintop'">
            <span><xsl:apply-templates select="@* | node() | text()"/></span>
        </xsl:if>
        <xsl:if test="@place='marginbottom'">
            <span><xsl:apply-templates select="@* | node() | text()"/></span>
        </xsl:if>
        <xsl:if test="@place='marginleft'">
            <xsl:choose>
                <xsl:when test="@rendition">
                    <span><xsl:attribute name="class"><xsl:value-of select="$rotate"/> marginleft</xsl:attribute>
                        <xsl:attribute name="style"></xsl:attribute>
                        <xsl:apply-templates select="@hand | node() | text()"/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <span><xsl:apply-templates select="@* | node() | text()"/></span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@place='marginright'">
            <span><xsl:apply-templates select="@* | node() | text()"/></span>
        </xsl:if>
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
    
    <xsl:template match="tei:seg">
        <span class="transpose"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="tei:hi">
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
    
    <xsl:template match="tei:delSpan">
        <xsl:variable name="delspan_id">
            <xsl:analyze-string select="@spanTo" regex="#(delspants\d_\d)">
                <xsl:matching-substring><xsl:value-of select="regex-group(1)"/></xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <a>
            <xsl:attribute name="id"><xsl:value-of select="$delspan_id"/></xsl:attribute>
        </a>
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
    
    <xsl:template match="@place">
        <xsl:choose>
            <xsl:when test=".='marginleft'">
                <xsl:attribute name="class">marginleft</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='marginleft'">
                <xsl:attribute name="class">marginleft</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='marginright'">
                <xsl:attribute name="class">marginright</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='margintop'">
                <xsl:attribute name="class">margintop</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='marginbottom'">
                <xsl:attribute name="class">marginbottom</xsl:attribute>
            </xsl:when>
            <xsl:when test=".='infralinear'"/>
            <xsl:when test=".='supralinear'"/>
            <xsl:when test=".='inline'"/>
        </xsl:choose>
    </xsl:template>
    
    <!-- @status and @instant should not match onto anything -->
    <xsl:template match="@status"/>
    <xsl:template match="@instant"/>
    <xsl:template match="@rendition"/>
    
</xsl:stylesheet>