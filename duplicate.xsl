<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="/">
	

	<xsl:for-each select="//*[@faims_attribute_name]">
		<xsl:variable name="path">"<xsl:if test="normalize-space(../../../../@ref)"><xsl:value-of select="normalize-space(../../../../@ref)"/>/<xsl:value-of select="normalize-space(../../../@ref)"/>/<xsl:value-of select="normalize-space(@ref)"/></xsl:if><xsl:if test="normalize-space(../../../../@ref) = ''"><xsl:value-of select="normalize-space(../../@ref)"/>/<xsl:value-of select="normalize-space(../@ref)"/>/<xsl:value-of select="normalize-space(@ref)"/></xsl:if>"</xsl:variable>
attributes.add(createEntityAttribute("<xsl:value-of select="normalize-space(@faims_attribute_name)"/>", getFieldAnnotation(<xsl:copy-of select="$path" />), <xsl:if test="name() = 'select' or name() = 'select1'">getFieldValue(<xsl:copy-of select="$path" />)</xsl:if><xsl:if test="name() != 'select' and name() != 'select1'">null</xsl:if>, <xsl:if test="name() = 'input'">getFieldValue(<xsl:copy-of select="$path" />)</xsl:if><xsl:if test="name() != 'input'">null</xsl:if>, getFieldCertainty(<xsl:copy-of select="$path" />)));</xsl:for-each> 
</xsl:template>

</xsl:stylesheet>

