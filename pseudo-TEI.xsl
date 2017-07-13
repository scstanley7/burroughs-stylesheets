<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <xsl:template match="tei:teiHeader"/>
    
    <xsl:template match="tei:surface">
        <xsl:variable name="fileName" select="@facs"/>
        <xsl:result-document exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="no" method="xml" byte-order-mark="no" href="{$fileName}.content.xml">
            <xsl:copy-of select="."/>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>