<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="dc marc oai_dc">
	<xsl:import href="http://www.loc.gov/standards/marcxml/xslt/MARC21slimUtils.xsl"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<!-- modification log 
	ntra 01/22/2008:   Suppressed duplicate 520,521.  fixed 752 subfield list, suppressed 856q, added 662.  
     JR 08/21/2007:   Fixed a couple of Dublin Core Links
	ntra 12/11/2006:  Fixed 500 fields.
	JR 05/05/06:  Updated the schemaLocation
	RG 10/07/05: Corrected subject subfields; 10/12/05: added if statement for <language>
	JR 09/05:  Added additional <subject> subfields and 651 for <coverage>
	JR 06/04:  Added ISBN identifier
	NT 01/04:  added collection level element
			and removed attributes   	
   	
-->
	<xsl:template match="/">
		<xsl:if test="marc:collection">
				<xsl:for-each select="marc:collection">
					<xsl:for-each select="marc:record">
						<dc:dc>
							<xsl:apply-templates select="."/>
						</dc:dc>
					</xsl:for-each>
				</xsl:for-each>
		</xsl:if>
		<xsl:if test="marc:record">
			<dc:dc> 
				<xsl:apply-templates select="marc:record"/>
			</dc:dc>
		</xsl:if>
	</xsl:template>
	<xsl:template match="marc:record">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
		<xsl:for-each select="marc:datafield[@tag=245]">
			<dc:title>      <!-- Updated to strain title thru chopPunctuation (remove trailing "/"), similar to Marc2Mods Apr2,10 alex -->
				<xsl:variable name="title">			
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abfgknp</xsl:with-param>
						<xsl:with-param name="delimeter"> : </xsl:with-param>	 <!-- added colon between title and subtitle, to look like MODS title Apr12,10 alex; noideawhyitisnottruncated-->
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="$title"/>
					</xsl:with-param>
				</xsl:call-template>
			</dc:title>
		</xsl:for-each>
		
<!--  04/23/2009   Added mapping for [246] field as customization for Colorado State Pubs.  Bridget -->
<!--  Map primary title only   March31, 10 alex	
		<xsl:for-each select="marc:datafield[@tag='246']">
			<dc:title>
				<xsl:for-each select="marc:subfield[@code='a']">
					<xsl:value-of select="text()"/>
						</xsl:for-each>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">f</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</dc:title>
		</xsl:for-each>
-->		
<!--  04/23/2009  Added mapping for [130] and [240] fields as customization for Colorado State Pubs.  Bridget -->		
<!--  Map primary title only   March31,10 alex	
		<xsl:for-each select="marc:datafield[@tag='130']|marc:datafield[@tag='240']">
			<dc:title>
				<xsl:for-each select="marc:subfield[@code='a']">
					<xsl:value-of select="text()"/>
				</xsl:for-each>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">df</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</dc:title>
		</xsl:for-each>
-->
<!--  04/23/2009  Added mapping for [490] field as customization for Colorado State Pubs.  Bridget -->
<!--  Map primary title only   March31,10 alex	
		<xsl:for-each select="marc:datafield[@tag=490][@ind1=0]">
			<dc:title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">av</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</dc:title>
		</xsl:for-each>
-->	
<!--  04/23/2009  Added mapping for [830] field as customization for Colorado State Pubs.  Bridget -->
<!--  Map primary title only   March31,10 alex	
		<xsl:for-each select="marc:datafield[@tag='830']">
			<dc:title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">adfgklmorsv</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</dc:title>
		</xsl:for-each>
-->
<!--   04/23/2009  Tried to map [310] to <dc:accrualPeriodicity> as per Colorado State Pubs specifications, but it did not work.  Bridget		
		<xsl:for-each select="marc:datafield[@tag=310]">
			<accrualPeriodicity>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ab</xsl:with-param>
				</xsl:call-template>
			</accrualPeriodicity>
		</xsl:for-each>
-->
		
<!--   04/23/2009  Added mapping for [362] to <dc:date> as per Colorado State Pubs specifications.  Bridget -->		
		<xsl:for-each select="marc:datafield[@tag=362]">
			<dc:date>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:date>
		</xsl:for-each>	
		
				
		<xsl:for-each select="marc:datafield[@tag=100]|marc:datafield[@tag=110]|marc:datafield[@tag=111]|marc:datafield[@tag=711]|marc:datafield[@tag=720]">
			<dc:creator>
				<xsl:value-of select="normalize-space(.)"/>
			</dc:creator>
		</xsl:for-each>
		
<!--  04/23/2009  For some reason, this template did not have the <dc:contributor> element. Mapped [700] and [710] fields for Colorado State Pubs.  Bridget -->
		<xsl:for-each select="marc:datafield[@tag='700'][not(marc:subfield[@code='t'])]">
			<dc:contributor>
				<xsl:value-of select="normalize-space(.)"/>
			</dc:contributor>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='710'][not(marc:subfield[@code='t'])]">
			<dc:contributor>
				<xsl:value-of select="normalize-space(.)"/>
			</dc:contributor>
		</xsl:for-each>

<!--   04/23/2009  Mapping [780] and [785] fields to <dc:title> as per Colorado State Pubs specifications.  Bridget -->
<!--  Map primary title only   March31,10 alex		
		<xsl:for-each select="marc:datafield[@tag=780]">
			<dc:title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">tw</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</dc:title>
		</xsl:for-each>
		
		<xsl:for-each select="marc:datafield[@tag=785]">
			<dc:title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">tw</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</dc:title>
		</xsl:for-each>
-->
		
		<dc:type>
			<xsl:if test="$leader7='c'">
				<!-- nt fix 1/04 -->
				<!--<xsl:attribute name="collection">yes</xsl:attribute>-->
				<xsl:text>collection</xsl:text>
			</xsl:if>
			<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
				<!-- nt fix 1/04 -->
				<!--<xsl:attribute name="manuscript">yes</xsl:attribute> -->
				<xsl:text>manuscript</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
				<xsl:when test="$leader6='i' or $leader6='j'">sound recording</xsl:when>
				<xsl:when test="$leader6='k'">still image</xsl:when>
				<xsl:when test="$leader6='g'">moving image</xsl:when>
				<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
				<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
				<xsl:when test="$leader6='p'">mixed material</xsl:when>
			</xsl:choose>
		</dc:type>
		<xsl:for-each select="marc:datafield[@tag=655]">
			<dc:type>
				<xsl:value-of select="normalize-space(.)"/>
			</dc:type>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=260]">
			<dc:publisher>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ab</xsl:with-param>
				</xsl:call-template>
			</dc:publisher>
		</xsl:for-each>
		
<!--   04/23/2009  Commenting out the default code for <dc:date> for Colorado State Pubs. <dc:date> is mapped to [362] as per their specifications.  Bridget 
		<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='c']">
			<dc:date>
				<xsl:value-of select="."/>
			</dc:date>
		</xsl:for-each>
-->		
		
		<xsl:if test="substring($controlField008,36,3)">
			<dc:language>
				<xsl:value-of select="substring($controlField008,36,3)"/>
			</dc:language>
		</xsl:if>		
		<!--<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q']">
			<dc:format>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each>-->
		<xsl:for-each select="marc:datafield[@tag=520]">
			<dc:description>
				<!-- nt fix 01/04 -->
				<xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/>
			</dc:description>
		</xsl:for-each>
		<!--<xsl:for-each select="marc:datafield[@tag=521]">
			<dc:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:description>
		</xsl:for-each>-->
		<xsl:for-each select="marc:datafield[500 &lt;= number(@tag) and number(@tag) &lt;= 599][not(@tag=506 or @tag=530 or @tag=540 or @tag=546 or @tag=520)]">
			<dc:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:description>
		</xsl:for-each>
	
<!--  04/23/2009  Attempted to map <dc:format> by mimicing <mods:physicalDescription> <mods:digitalOrigin> it did not work. Will need to address later.  Bridget 
	
	05/05/2009   Test to see if <dc:format> works when processed in XML Editor other than Oxygen (could be related to the Oxygen issue of compressing 00X fields)
-->		

<!--  05/05/2009  I can't get <dc:format to work.  Bridget 
		<dc:format>
			<xsl:if test="controlField008 and marc:controlfield[@tag=007][substring(.,12,1)]">
				<xsl:text>digital origin</xsl:text>
				</xsl:if>
			<xsl:choose>
				<xsl:when test="controlField008 and marc:controlfield[@tag=007][substring(.,12,1)='a']">reformatted digital</xsl:when>
				<xsl:when test="controlField008 and marc:controlfield[@tag=007][substring(.,12,1)='b']">digitized microfilm</xsl:when>
				<xsl:when test="controlField008 and marc:controlfield[@tag=007][substring(.,12,1)='d']">digitized other analog</xsl:when>
			</xsl:choose>
			</dc:format>
-->
		
		<!--  05/05/2009  another example of <dc:format that will not work. Bridget
		<xsl:if test="$typeOf008='CF'">
		<xsl:for-each select="$typeOf008='CF' and marc:controlfield[@tag=007]">
		<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a']">
			<format>reformatted digital</format>
		</xsl:if>
		<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='b']">
			<format>digitized microfilm</format>
		</xsl:if>
		<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='d']">
			<format>digitized other analog</format>
		</xsl:if>
		</xsl:for-each>
		-->

		

<!--  04/23/2009  Mapping [086] and [098] to <dc:identifier> as per Colorado State Pubs specification sheet. Bridget -->
		<xsl:for-each select="marc:datafield[@tag=086][marc:subfield[@code='2']]">
			<dc:identifier>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=098][@ind1=2][ind2=1]">
			<dc:identifier>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">aef</xsl:with-param>
				</xsl:call-template>
			</dc:identifier>
		</xsl:for-each>
		
<!--   04/23/2009  Mapping <mods:recordIdentifier> to <dc:identifier> as per Colorado State Pubs specifications.  Bridget -->
		<xsl:for-each select="marc:controlfield[@tag=001]">
			<dc:identifier>
                            <xsl:if test="../marc:controlfield[@tag=003]">
					<xsl:value-of select="../marc:controlfield[@tag=003]"/>
			    </xsl:if>
                            <xsl:value-of select="substring-after(.,'ocn')"/>  <!-- ekf 2009-1104-1313 - idea by alex but blame ekf -->
                        </dc:identifier>
		</xsl:for-each>
		
		<xsl:for-each select="marc:datafield[@tag=600]">
			<dc:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdefghjklmnopqrstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
				<xsl:text>--</xsl:text>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">vxyz</xsl:with-param>
					<xsl:with-param name="delimeter">--</xsl:with-param>
				</xsl:call-template>
				</xsl:if>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=610]">
			<dc:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdefghklmnoprstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=611]">
			<dc:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">acdefghklnpqstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=630]">
			<dc:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">adfghklmnoprst</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=650]">
			<dc:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ae</xsl:with-param></xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=653]">
			<dc:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">a</xsl:with-param>
				</xsl:call-template>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=651]">
			<dc:coverage>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">a</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</dc:coverage>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=662]">
			<dc:coverage>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdefgh</xsl:with-param>
				</xsl:call-template>
			</dc:coverage>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=752]">
			<dc:coverage>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">adcdfgh</xsl:with-param>
				</xsl:call-template>
			</dc:coverage>
		</xsl:for-each>
<!-- ekf 2009-1104-1200	<xsl:for-each select="marc:datafield[@tag=530]"> -->
			<!-- nt 01/04 attribute fix -->
<!-- ekf			<dc:relation> -->
				<!--<xsl:attribute name="type">original</xsl:attribute>-->
<!-- ekf				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdu</xsl:with-param>
				</xsl:call-template>
			</dc:relation>
		</xsl:for-each>
ekf -->
<!--   04/23/2009  removed marc:datafield[@tag=780]|marc:datafield[@tag=785] in order to map the fields to <dc:title> as per Colorado State Pubs specifications.  Bridget -->
		<xsl:for-each select="marc:datafield[@tag=760]|marc:datafield[@tag=762]|marc:datafield[@tag=765]|marc:datafield[@tag=767]|marc:datafield[@tag=770]|marc:datafield[@tag=772]|marc:datafield[@tag=773]|marc:datafield[@tag=774]|marc:datafield[@tag=775]|marc:datafield[@tag=776]|marc:datafield[@tag=777]|marc:datafield[@tag=787]">
			<dc:relation>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ot</xsl:with-param>
				</xsl:call-template>
			</dc:relation>
		</xsl:for-each>
		
		<xsl:for-each select="marc:datafield[@tag=856]">
			<dc:identifier>
				<xsl:value-of select="marc:subfield[@code='u']"/>
			</dc:identifier>
		</xsl:for-each>
		
<!-- 05/05/2009  CDATA command can be used to print elements without processing - or print what ever is contained within the CDATA brackets.
	The  below example allowed DC to process the [856] <dc:identifier> twice with "FIX ME" above the 2nd instance of <dc:identifier>.  Bridget
		<![CDATA[
		FIX ME]]>
		<xsl:for-each select="marc:datafield[@tag=856]">
			<dc:identifier>
				<xsl:value-of select="marc:subfield[@code='u']"/>
			</dc:identifier>
		</xsl:for-each>
-->
		
		
		
		<xsl:for-each select="marc:datafield[@tag=020]">
			<dc:identifier>
				<xsl:text>URN:ISBN:</xsl:text>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=506]">
			<dc:rights>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:rights>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=540]">
			<dc:rights>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dc:rights>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
