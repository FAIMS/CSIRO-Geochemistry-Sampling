<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:variable name="lessThan" select="'&#x3C;'"/>

<xsl:template match="/">
	

<xsl:for-each select="//*[@faims_attribute_name]"><xsl:variable name="path">"<xsl:if test="normalize-space(../../../../@ref)"><xsl:value-of select="normalize-space(../../../../@ref)"/>/<xsl:value-of select="normalize-space(../../../@ref)"/>/<xsl:value-of select="normalize-space(@ref)"/></xsl:if><xsl:if test="normalize-space(../../../../@ref) = ''"><xsl:value-of select="normalize-space(../../@ref)"/>/<xsl:value-of select="normalize-space(../@ref)"/>/<xsl:value-of select="normalize-space(@ref)"/></xsl:if>"</xsl:variable>
<xsl:if test="name() = 'input' or name() = 'select1'">addAttribute(attributes, "<xsl:value-of select="normalize-space(@faims_attribute_name)"/>", <xsl:copy-of select="$path" />, <xsl:if test="name() = 'select1'">false</xsl:if><xsl:if test="name() = 'input'">true</xsl:if>);
</xsl:if>
<xsl:if test="name() = 'select' and not(@faims_sync)">addMultSelectionAttribute(attributes,"<xsl:value-of select="normalize-space(@faims_attribute_name)"/>", <xsl:copy-of select="$path" />);
</xsl:if>
</xsl:for-each> 
</xsl:template>

</xsl:stylesheet>

