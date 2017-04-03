<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" extension-element-prefixes="saxon"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <!-- xsl to: 
        * Find and list all unique paths in the source file
        * Find and list all non BasicLatin characters (optionally - set check-characters=yes if needed)
    -->
    
    <!-- tab character -->
    <xsl:variable name="tab">&#x0009;</xsl:variable>
    <xsl:variable name="re">&#x000D;&#x000A;</xsl:variable>
    
    <!-- parameter to turn on checking of non-basic latin characters -->
    <xsl:param name="check-characters"/>

    <xsl:key name="elements-by-path"
        match="//node() | //@*"
        use="replace(saxon:path(), '[0-9\[\]]', '')"/>

    <xsl:template match="/">
        <!-- first report lists each unique path, the exact path to the first occurrence, and the number of occurrences
            (frequency) -->
        <xsl:result-document method="text" encoding="utf-8" href="UniquePaths.txt">
            <xsl:value-of select="concat('Node Name', $tab, 'Path', $tab, 'First Occurrence', $tab, 'Frequency', $re)"/>
            <xsl:for-each
                select="//(element() | @*)[. is key('elements-by-path', replace(saxon:path(), '[0-9\[\]]', ''))[1]]">
                <xsl:value-of
                    select="concat(name(), $tab, replace(saxon:path(), '[0-9\[\]]', ''), $tab, saxon:path(), 
                    $tab, count(key('elements-by-path', replace(saxon:path(), '[0-9\[\]]', ''))), $re)"
                />
            </xsl:for-each>
        </xsl:result-document>
        

        <!-- second report finds all unique non basic latin characters, outputs report in us-ascii so you have utf-8 hex codes -->
        <xsl:if test="$check-characters = 'yes'">
            <xsl:result-document method="html" encoding="utf-8" href="UniqueNonBasicCharacters.txt"
                saxon:character-representation="hex">
                <!-- And yes, we are using method=html here (to output to a text file), since text output method does not allow (direct) use of
                    @saxon:character-representation that helps encode utf-8 as hex entity references (for easier
                    reading) -->
                <xsl:value-of select="concat('Non Basic Latin Characters', $re)"/>
                <!-- variable to stow non-basic latin text -->
                <xsl:variable name="all-text-with-nonBasicLatin">
                    <!-- get all nodes with non-basic latin characters -->
                    <xsl:for-each select="*//text()[matches(., '[\P{IsBasicLatin}]')]">
                        <!-- filter out the basic latin, put spaces between non-basics so they can be tokenized -->
                        <xsl:for-each
                            select="replace(replace(., '[\p{IsBasicLatin}]', ''), '([\P{IsBasicLatin}])', '$1 ')">
                            <xsl:value-of select="."/>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:variable>
                <!-- find all the distinct non-basic latin characters and output -->
                <xsl:for-each select="distinct-values(tokenize($all-text-with-nonBasicLatin, ' '))">
                    <xsl:value-of select="concat(., $re)"/>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
