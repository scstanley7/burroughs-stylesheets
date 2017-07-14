<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <!-- variables used to create names for new documents -->
    <xsl:variable name="fileName" select="//tei:sourceDoc/@xml:id"/>
    <xsl:variable name="docName" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
    
    <!-- suppress TEI header -->
    <xsl:template match="tei:teiHeader"/>
    
    <!-- create a new HTML document for each witness -->
    <!-- @exclude-result-prefixes will ensure that you don't end up with a tei namespace declared on every element -->
    <xsl:template match="tei:surfaceGrp">
        <xsl:result-document exclude-result-prefixes="#all" indent="yes" method="html" omit-xml-declaration="no" href="{$fileName}.html">
            <html>
                <head></head>
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
    
    <!-- insert an asterisk wherever there's a TEI <anchor/> element -->
    <!-- surround each asterisk with an HTML <a> tag whose @href is the value of @corresp on <anchor/> -->
    <xsl:template match="tei:anchor">
        <xsl:variable name="note-ptr" select="@corresp"/>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="$note-ptr"/></xsl:attribute>
            <xsl:text>*</xsl:text>
        </a>
    </xsl:template>
    
    <!-- put each TEI <note> element into an HTML <span> and assign it an ID of whatever @xml:id on <note> is -->
    <!-- DISPLAY NOTE: Notes should be displayed with an asterisk an on-click or with hover  -->
    <xsl:template match="tei:note">
        <xsl:variable name="note-id" select="@xml:id"/>
        <span class="note">
            <xsl:attribute name="id"><xsl:value-of select="$note-id"/></xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- TEI <lb/> should be replaced with HTML <br/> -->
    <xsl:template match="tei:lb"><br/></xsl:template>
    
    <!-- match TEI <fw> with an HTML <span> element with a @class of "pageNum" -->
    <!-- use inline CSS (@style) to specify the placement of the page number, based on the information recorded in the @place attribute -->
    <xsl:template match="tei:fw">
        <span>
            <xsl:attribute name="class">pageNum</xsl:attribute>
            <xsl:attribute name="style">
                <xsl:choose>
                    <xsl:when test="@place='top-left'">align:left;</xsl:when>
                    <xsl:when test="@place='top-right'">align:right;</xsl:when>
                    <xsl:otherwise>align:center;</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
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
    
    <!-- match the TEI <del> element -->
    <xsl:template match="tei:del">
        <xsl:choose>
            <!-- if <del> has the @rend attribute, put it in a span tag, display any text/process any nodes contained within -->
            <!-- also, match any attributes **see section below for more information on how attributes match** -->
            <xsl:when test="@rend">
                <span style="color:black;"><xsl:apply-templates select="@rend | node() | text()"></xsl:apply-templates></span>
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
                    <a class="add"><xsl:apply-templates/></a>
                </xsl:when>
                <!-- if its parent is anything other than TEI <subst>, stick it in an HTML <i> tag -->
                <xsl:otherwise>
                    <i class="add"><xsl:apply-templates/></i>
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
    
    <!-- match all TEI <metamark> elements -->
    <xsl:template match="tei:metamark">
        <xsl:choose>
            <!--             if it has a value of "insert" on @function, display a carrot within the HTML <i> element with a @class of "insert" -->
            <xsl:when test="@function='insert'"><i class="add">^</i></xsl:when>
            <!-- TBD, although I suspect this will involve inline CSS, unfortunately --> 
            <xsl:when test="@rend='upconnect'"><span class="upconnect"><xsl:apply-templates/></span></xsl:when>
            <xsl:when test="@rend='updownconnect'"><span class="updownconnect"><xsl:apply-templates/></span></xsl:when>
            <xsl:when test="@rend='downconnect'"><span class="downconnect"><xsl:apply-templates/></span></xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:seg"><xsl:apply-templates/></xsl:template>
    
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