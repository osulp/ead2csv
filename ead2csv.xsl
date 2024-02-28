<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns="urn:isbn:1-931666-22-9" xpath-default-namespace="urn:isbn:1-931666-22-9"
    exclude-result-prefixes="#all" version="2.0">

    <!-- 
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * This stylesheet converts a collection of Encoded Archival Description (EAD) XML   * 
        * finding aid documents into a single CSV. It focuses on the Archival Description   *
        * (`archdesc`) metadata elements. The source XML is assumed to be located in a flat *
        * directory, with each file named using the convention {uniqueID.xml}.              *
        *                                                                                   *
        * Elements may be edited to suit the user's needs. Elements can be excluded by      *
        * commenting out the relevant lines of code, and additional elements may be added   *
        * where missing. Note that to update the included fields, they must be added or     *
        * removed in three locations: the header row, the collection row logic, and the     *
        * component row logic.                                                              *
        *                                                                                   *
        * A separate "Collection Information" document with collection management details   *
        * not found in the EAD is expected, but not required. See documentation and         *
        * examples for guidance.                                                            *
        *                                                                                   *
        * This was designed for use with finding aids from Oregon State University          *
        * Libraries and Press (OSULP) Special Collections and Archives Research Center      *
        * (SCARC), which at the time of creation were stored in Archon v3.21. It may be     *
        * adapted for use by other repositories or institutions.                            *
        *                                                                                   *
        * Created by Cara M. Key, OSULP Digital Repository Librarian                        *
        * Last updated February 2024                                                        *
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    -->

    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- 
        ATTENTION USER:
        Specify the character(s) or character code(s) to use for the delimiter, separator, newline, and quote characters.
    -->
    <xsl:param name="delim" select="','"/>
    <!--<xsl:param name="delim" select="'&#9;'"/>-->
    <xsl:param name="separator" select="'||'"/>
    <xsl:param name="newline" select="'&#10;'"/>
    <xsl:param name="quote" select="'&quot;'"/>

    <!-- 
        ATTENTION USER: 
        Specify the following using the parameters:
            * folder_name = The name of the directory containing the source EAD XML files
            * folder_path = The relative path to the directory containing the source EAD XML files
            * csv_name = The intended filename and relative path for the CSV output
    -->
    <xsl:param name="folder_name" select="'ead_xml'"/>
    <xsl:param name="folder_path" select="'../source_xml/'"/>
    <xsl:param name="csv_name" select="'finding_aid_data.csv'"/>

    <!-- Construct the path to the directory containing the EAD XML files; specify XML files only. -->
    <xsl:variable name="ead_files"
        select="collection(concat($folder_path,$folder_name, '/?select=*.xml'))"/>

    <!-- 
        ATTENTION USER:
        Fill in details for the Collection Information document using the parameters:
            * coll_info_csv = The name and relative path to the Collection Information reference XML, if available
            * identifier_field = The name of the field in which the unique identifier matching the EAD XML filename is stored in the document
            * desc_level_field = The name of the field in which the Description Level value is stored in the document
            * coll_type_field = The name of the field in which the Collection Type value is stored in the document

    -->
    <xsl:param name="coll_info_csv" select="'collection_info.xml'"/>
    <xsl:param name="identifier_field" select="'archon_id'"/>
    <xsl:param name="desc_level_field" select="'description_level'"/>
    <xsl:param name="coll_type_field" select="'collection_type'"/>

    <!-- Set up the Collection Information file as a reference document for building the CSV. -->
    <xsl:variable name="coll_info" select="document($coll_info_csv)"/>

    <xsl:template match="/">

        <!-- Send output to a document with filename as specified. -->
        <xsl:result-document href="{$csv_name}">

            <!-- Create header row with element names. -->
            <xsl:text>Identifier</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Collection ID</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Collection Title</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Description Level</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Collection Type</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Unit Level</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Unit ID</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Extent</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Container ID</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Unit Title</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Creator</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Date</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Abstract</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Scope and Content</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Biographical Note</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Subjects</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Personal Names</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Corporate Names</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:text>Geographics</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="$newline"/>

            <!-- Apply the rest of the template to each EAD XML file in the specified directory -->
            <xsl:for-each select="$ead_files">

                <!-- Derive the Identifier from the source document filename -->
                <xsl:variable name="identifier"
                    select="substring-after(substring-before(base-uri(), '.xml'), concat($folder_name, '/'))"/>
                <xsl:variable name="coll_id" select="/ead/archdesc/did/unitid"/>
                <xsl:variable name="coll_title" select="/ead/archdesc/did/unittitle/replace(.,$quote,concat($quote,$quote))"/>
                
                <!-- Fetch Description Level and Collection Type from Collection Information document -->
                <xsl:variable name="coll_info_entry" select="$coll_info//*[local-name()='collection'][*[local-name()=$identifier_field] = $identifier]"/>
                <xsl:variable name="desc_level" select="$coll_info_entry/*[local-name() = $desc_level_field]"/>
                <xsl:variable name="coll_type" select="$coll_info_entry/*[local-name() = $coll_type_field]"/>
                
                <!-- Create a row for the collection level description -->
                <xsl:call-template name="coll_row">
                    <xsl:with-param name="identifier" select="$identifier"/>
                    <xsl:with-param name="coll_id" select="$coll_id"/>
                    <xsl:with-param name="coll_title" select="$coll_title"/>
                    <xsl:with-param name="desc_level" select="$desc_level"/>
                    <xsl:with-param name="coll_type" select="$coll_type"/>
                </xsl:call-template>

                <!-- ATTENTION USER: Choose from the following options or update as needed -->

                <!-- Option 1: Create a row for each component level description *FOR EVERY UNIT LEVEL* -->
                <xsl:for-each select="//dsc//*[did]">
                    <xsl:call-template name="dsc_row">
                        <xsl:with-param name="identifier" select="$identifier"/>
                        <xsl:with-param name="coll_id" select="$coll_id"/>
                        <xsl:with-param name="coll_title" select="$coll_title"/>
                        <xsl:with-param name="desc_level" select="$desc_level"/>
                        <xsl:with-param name="coll_type" select="$coll_type"/>
                    </xsl:call-template>
                </xsl:for-each>

                <!-- Option 2: Create a row for each component level description *WITH UNIT LEVEL "SERIES"* -->
                <!--<xsl:for-each select="//dsc//*[@level='series']">
                    <xsl:call-template name="dsc_row">
                        <xsl:with-param name="identifier" select="$identifier"/>
                    </xsl:call-template>
                </xsl:for-each>-->

            </xsl:for-each>

        </xsl:result-document>

    </xsl:template>

    <xsl:template name="coll_row">

        <xsl:param name="identifier"/>
        <xsl:param name="coll_id"/>
        <xsl:param name="coll_title"/>
        <xsl:param name="desc_level"/>
        <xsl:param name="coll_type"/>

        <!-- Establish variables to shorten frequently used xpaths -->
        <xsl:variable name="archesc" select="/ead/archdesc"/>
        <xsl:variable name="coll_did" select="$archesc/did"/>
        <xsl:variable name="controlaccess" select="$archesc/controlaccess/controlaccess"/>

        <!-- Create collection row -->

        <!--Identifier-->
        <xsl:value-of select="concat($quote,$identifier,$quote,$delim)"/>
        
        <!--Collection ID-->
        <xsl:value-of select="concat($quote,$coll_id,$quote,$delim)"/>
        
        <!--Collection Title-->
        <xsl:value-of select="concat($quote,$coll_title,$quote,$delim)"/>
        
        <!--Description Level-->
        <xsl:value-of select="concat($quote,$desc_level,$quote,$delim)"/>
        
        <!-- Collection Type-->
        <xsl:value-of select="concat($quote,$coll_type,$quote,$delim)"/>
        
        <!--Unit Level-->
        <xsl:value-of select="concat($quote,'collection',$quote,$delim)"/>

        <!--Unit ID-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$coll_did/unitid"/>
        </xsl:call-template>
        
        <!--Extent-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$coll_did/physdesc/extent"/>
        </xsl:call-template>

        <!--Container ID-->
        <xsl:value-of select="'N/A', $delim"/>

        <!--Unit Title-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$coll_did/unittitle"/>
        </xsl:call-template>
        
        <!-- Creator -->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$coll_did/origination/*[@role='creator']"/>
        </xsl:call-template>

        <!--Date-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$coll_did/unitdate"/>
        </xsl:call-template>

        <!--Abstract-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$coll_did/abstract"/>
        </xsl:call-template>

        <!--Scope and Content-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$archesc/scopecontent/*"/>
        </xsl:call-template>

        <!--Biographical Note-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$archesc/bioghist/*"/>
        </xsl:call-template>

        <!--Subjects-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$controlaccess/subject"/>
        </xsl:call-template>

        <!--Personal Names-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$controlaccess/persname"/>
        </xsl:call-template>

        <!--Corporate Names-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$controlaccess/corpname"/>
        </xsl:call-template>

        <!--Geographics-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="$controlaccess/geogname"/>
        </xsl:call-template>

        <!-- End of collection record/row -->
        <xsl:value-of select="$newline"/>

    </xsl:template>

    <xsl:template name="dsc_row">

        <xsl:param name="identifier"/>
        <xsl:param name="coll_id"/>
        <xsl:param name="coll_title"/>
        <xsl:param name="desc_level"/>
        <xsl:param name="coll_type"/>

        <!-- Create component row -->
        
        <!--Identifier-->
        <xsl:value-of select="concat($quote,$identifier,$quote,$delim)"/>

        <!--Collection ID-->
        <xsl:value-of select="concat($quote,$coll_id,$quote,$delim)"/>
        
        <!--Collection Title-->
        <xsl:value-of select="concat($quote,$coll_title,$quote,$delim)"/>

        <!--Description Level-->
        <xsl:value-of select="concat($quote,$desc_level,$quote,$delim)"/>
        
        <!-- Collection Type-->
        <xsl:value-of select="concat($quote,$coll_type,$quote,$delim)"/>

        <!--Unit Level-->
        <xsl:choose>
            <xsl:when test="@level = ''">
                <xsl:value-of select="'unknown'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@level"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$delim"/>

        <!--Unit ID-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="did/unitid"/>
        </xsl:call-template>

        <!--Extent: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>

        <!--Container ID-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="did/container"/>
        </xsl:call-template>
        
        <!--Unit Title-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="did/unittitle"/>
        </xsl:call-template>
        
        <!--Creator: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>
        
        <!--Date-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="did/unitdate"/>
        </xsl:call-template>

        <!--Abstract: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>

        <!--Scope and Content-->
        <xsl:call-template name="cell">
            <xsl:with-param name="path" select="scopecontent/*"/>
        </xsl:call-template>

        <!--Biographical Note: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>

        <!--Subjects: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>

        <!--Personal Names: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>

        <!--Corporate Names: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>

        <!--Geographics: SKIP-->
        <xsl:value-of select="concat('N/A', $delim)"/>

        <!-- End of component record/row -->
        <xsl:value-of select="$newline"/>

    </xsl:template>

    <xsl:template name="cell">

        <!-- Populate the cell using the value(s) at the xpath specified -->

        <xsl:param name="path"/>
        
        <xsl:value-of select="$quote"/>

        <xsl:choose>
            <!-- Test whether there is a value -->
            <xsl:when test="$path[//text()]">
                <xsl:for-each select="$path[//text()]">
                    <!-- If a value is found, copy:
                        - normalize white space
                        - enclose in quotation marks to avoid CSV cell issues
                        - replace existing quotation marks with apostrophes to further avoid CSV cell issues -->
                    <xsl:value-of select="replace(normalize-space(.),$quote,concat($quote,$quote))"/>

                    <!-- Handle multiple values with a separater -->
                    <xsl:if test="not(position() = last())">
                        <xsl:value-of select="$separator"/>
                    </xsl:if>

                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- If no value, then insert a filler value; N/F for Not Found -->
                <xsl:text>N/F</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:value-of select="$quote"/>
        <xsl:value-of select="$delim"/>

    </xsl:template>

</xsl:stylesheet>