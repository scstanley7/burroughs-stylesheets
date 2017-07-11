<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.loc.gov/mods/v3">
    
    <xsl:output method="xml"/>
    
    <xsl:variable name="authority" select="//tei:fileDesc/tei:publicationStmt/tei:authority"/>
    
    <xsl:variable name="licence" select="//tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:availability/tei:licence"/>
    
    <xsl:variable name="distributor" select="//tei:publicationStmt/tei:distributor"/>
    
    <xsl:variable name="title" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title[not(@type)]"/>
    
    <xsl:variable name="subtitle" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title[@type]"/>
    
    <xsl:variable name="edition" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:editionStmt/tei:edition"/>
    
    <xsl:variable name="authorfirst" select="//tei:author/tei:persName/tei:forename"></xsl:variable>
    
    <xsl:variable name="authormiddle" select="//tei:author/tei:persName/tei:addName"></xsl:variable>
    
    <xsl:variable name="authorlast" select="//tei:author/tei:persName/tei:surname"></xsl:variable>
    
    <xsl:variable name="authordates" select="//tei:author/tei:date"></xsl:variable>
    
    <xsl:variable name="createDateStart" select="//tei:biblFull/tei:publicationStmt/tei:date/@from"/>
    
    <xsl:variable name="createDateEnd" select="//tei:biblFull/tei:publicationStmt/tei:date/@to"/>
    
    <xsl:variable name="address" select="//tei:addrLine"/>
    
    <xsl:variable name="metadataCreate" select="//tei:change[@type='metadata-creation']/@when"/>
    
    <xsl:variable name="IID" select="//tei:idno[@type='IID']"/>
    
    <!--<xsl:variable name="extent" select="//tei:biblFull/tei:extent"/>-->
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader"/>
    
    <xsl:template match="tei:surface" xml:space="preserve">
        <xsl:variable name="IID-ext" select="@n"/>
        <xsl:variable name="fileName" select="@facs"/>
        <xsl:result-document  exclude-result-prefixes="#all" indent="yes" method="xml" byte-order-mark="no" href="{$fileName}.mods.xml">    
            <mods xmlns="http://www.loc.gov/mods/v3"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:mods="http://www.loc.gov/mods/v3" xmlns:flvc="info:flvc/manifest/v1"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">
            <extension>
                <flvc:flvc>
                    <flvc:owningInstitution><xsl:value-of select="$authority"/></flvc:owningInstitution>
                    <flvc:submittingInstitution><xsl:value-of select="$distributor"/></flvc:submittingInstitution>
                </flvc:flvc>
            </extension>
            <accessCondition xlink:href="http://rightsstatements.org/vocab/InC/1.0/"
                type="use and reproduction">
                <xsl:value-of select="$licence"/>
            </accessCondition>
            <titleInfo>
                <title><xsl:value-of select="$title"/></title>
                <subTitle><xsl:value-of select="$subtitle"></xsl:value-of></subTitle>
                <partName><xsl:value-of select="$edition"/></partName>
                <partNumber><xsl:value-of select="$IID-ext"/></partNumber>
            </titleInfo>
            <name valueURI="http://id.loc.gov/authorities/names/n79026862"
                authorityURI="http://id.loc.gov/authorities/names" authority="lcnaf" type="personal">
                <namePart type="family"><xsl:value-of select="$authorlast"/></namePart>
                <namePart type="given"><xsl:value-of select="$authorfirst"/> <xsl:value-of select="$authormiddle"/></namePart>
                <namePart type="date"><xsl:value-of select="$authordates"></xsl:value-of></namePart>
            </name>
            <typeOfResource>text</typeOfResource>
            <genre authority="lcgft"
                valueURI="http://id.loc.gov/authorities/genreForms/gf2014026339"
                authorityURI="http://id.loc.gov/authorities/genreForms">Fiction</genre>
            <originInfo>
                <dateCreated encoding="w3cdtf" qualifier="approximate" point="start"><xsl:value-of select="$createDateStart"/></dateCreated>
                <dateCreated encoding="w3cdtf" qualifier="approximate" point="end"><xsl:value-of select="$createDateEnd"/></dateCreated>
            </originInfo>
            <language>
                <languageTerm authority="iso639-2b" type="code">eng</languageTerm>
                <languageTerm authority="iso639-2b" type="text">English</languageTerm>
            </language>
            <physicalDescription>
                <digitalOrigin>reformatted digital</digitalOrigin>
            </physicalDescription>
            <location>
                <physicalLocation><xsl:value-of select="$address"/></physicalLocation>
            </location>
            <identifier type="IID"><xsl:value-of select="$IID"/>_<xsl:value-of select="$IID-ext"/></identifier>
            <recordInfo>
                <recordCreationDate><xsl:value-of select="$metadataCreate"/></recordCreationDate>
                <descriptionStandard>aacr2</descriptionStandard>
            </recordInfo>
        </mods>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
