<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:pom="http://maven.apache.org/POM/4.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/pom:project">
        <!-- this XML element just serves as a bracket and may be omitted -->
        <xsl:element name="releaseId">
            <xsl:text>&#10;</xsl:text>

            <!-- process coordinates declared at project and project/parent -->
            <xsl:apply-templates select="pom:groupId|pom:parent/pom:groupId" mode="copy-coordinate"/>
            <xsl:apply-templates select="pom:artifactId|pom:parent/pom:artifactId" mode="copy-coordinate"/>
            <xsl:apply-templates select="pom:version|pom:parent/pom:version" mode="copy-coordinate"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*" mode="copy-coordinate">
        <!-- omit parent coordinate if same coordinate is explicitly specified on project level -->
        <xsl:if test="not(../../*[name(.)=name(current())])">

            <!-- write coordinate as XML element without namespace declarations -->
            <xsl:element name="{local-name()}">
               <xsl:value-of select="."/>
            </xsl:element>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
