<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:mods="http://www.loc.gov/mods/v3" xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="xlink marc" version="1.0">
	<xsl:include href="http://www.loc.gov/marcxml/xslt/MARC21slimUtils.xsl"/>
	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<!--
Revision 1.14 - Fixed template isValid and fields 010, 020, 022, 024, 028, and 037 to output additional identifier elements 
  with corresponding @type and @invalid eq 'yes' when subfields z or y (in the case of 022) exist in the MARCXML ::: 2007/01/04 17:35:20 cred

Revision 1.13 - Changed order of output under cartographics to reflect schema  2006/11/28 tmee
	
Revision 1.12 - Updated to reflect MODS 3.2 Mapping  2006/10/11 tmee
		
Revision 1.11 - The attribute objectPart moved from <mods:languageTerm> to <mods:language>
      2006/04/08  jrad

Revision 1.10 MODS 3.1 revisions to language and classification elements  
				(plus ability to find marc:collection embedded in wrapper elements such as SRU zs: wrappers)
				2006/02/06  ggar

Revision 1.9 subfield $y was added to field 242 2004/09/02 10:57 jrad

Revision 1.8 Subject chopPunctuation expanded and attribute fixes 2004/08/12 jrad

Revision 1.7 2004/03/25 08:29 jrad

Revision 1.6 various validation fixes 2004/02/20 ntra

Revision 1.5  2003/10/02 16:18:58  ntra
MODS2 to MODS3 updates, language unstacking and 
de-duping, chopPunctuation expanded

Revision 1.3  2003/04/03 00:07:19  ntra
Revision 1.3 Additional Changes not related to MODS Version 2.0 by ntra

Revision 1.2  2003/03/24 19:37:42  ckeith
Added Log Comment

-->
	<xsl:output omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="//marc:collection">
				<mods:modsCollection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
					xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
					<xsl:for-each select="//marc:collection/marc:record">
						<mods:mods version="3.2">
							<xsl:call-template name="marcRecord"/>
						</mods:mods>
					</xsl:for-each>
				</mods:modsCollection>
			</xsl:when>
			<xsl:otherwise>
				<mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
					<xsl:for-each select="//marc:record">
						<xsl:call-template name="marcRecord"/>
					</xsl:for-each>
				</mods:mods>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="marcRecord">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag='008']"/>
		<xsl:variable name="typeOf008">
			<xsl:choose>
				<xsl:when test="$leader6='a'">
					<xsl:choose>
						<xsl:when
							test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'"
							>BK</xsl:when>
						<xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">SE</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$leader6='t'">BK</xsl:when>
				<xsl:when test="$leader6='p'">MM</xsl:when>
				<xsl:when test="$leader6='m'">CF</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
				<xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'"
					>VM</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'"
					>MU</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="marc:datafield[@tag='245']">
			<mods:titleInfo>   
				<xsl:variable name="title">
					<xsl:choose>
						<xsl:when test="marc:subfield[@code='b']">
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="axis">b</xsl:with-param>
								<xsl:with-param name="beforeCodes">afgknp</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">abfgknp</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="titleChop">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="$title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<!-- May 19, 2009  Added mapping to display the intitial articles in the mods:title. Applied "greater than or equal to" processing script. Bridget  -->
				<!-- November 19, 2009 Incorporated subtitle from 245 |b into main title, separated by colon. Alex-->
				<xsl:if test="@ind2&gt;=0">
					<mods:title>
						<xsl:value-of select="$titleChop"/>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldColon">    <!-- colon. Apr1, 10 alex-->
									<xsl:with-param name="axis">b</xsl:with-param>
									<xsl:with-param name="anyCodes">b</xsl:with-param>
									<xsl:with-param name="afterCodes">afgk</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
				</xsl:if>
				<xsl:call-template name="part"/>
			</mods:titleInfo>
		</xsl:for-each>
		
<xsl:for-each select="marc:datafield[@tag='246']">
			<!--RBD 4/6/12 All ind2 values need to map to Alternative Title, commenting this out: <xsl:if test="@ind2=' ' or @ind2=0">-->
				<mods:titleInfo type="alternative">		
				<xsl:variable name="displaylabel">	
					<xsl:for-each select="marc:subfield[@code='i']">
						<xsl:value-of select="text()"/>
					</xsl:for-each>
				</xsl:variable>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">af</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:text> </xsl:text>
						<xsl:call-template name="CSPLsubtitle"/>
						<xsl:if test="not(string-length($displaylabel) = 0)">   <!-- test since there might be ind2=' '|0 and NO subfield i -->
							<xsl:text>(</xsl:text>
							<xsl:call-template name="chopPunctuation"> 
								<xsl:with-param name="chopString">
									<xsl:value-of select="$displaylabel"/>	
								</xsl:with-param>
							</xsl:call-template>
							<xsl:text>)</xsl:text>
						</xsl:if>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			<!--</xsl:if>-->
</xsl:for-each>
		<!--old uniform title missing |a RBD 4/6/12. 
		<xsl:for-each
			select="marc:datafield[@tag='130']|marc:datafield[@tag='240'][@ind2!='2']">
			<mods:titleInfo type="uniform">
				<mods:title>
					<xsl:variable name="str">
						<xsl:for-each select="marc:subfield">
							<xsl:if
								test="(contains('adfkmor',@code) and (not(../marc:subfield[@code='l' or @code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
								<xsl:value-of select="text()"/>
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
						</xsl:with-param>
					</xsl:call-template>
							<xsl:variable name="partaName">
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="anyCodes">lnp</xsl:with-param>
								<xsl:with-param name="afterCodes">a</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>

						<xsl:if test="string-length(normalize-space($partaName))">
							<xsl:text>. </xsl:text>  
							<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="chopString" select="$partaName"/>
								</xsl:call-template>
						</xsl:if>
			</mods:title>
					<xsl:call-template name="part"/>
			</mods:titleInfo>
			</xsl:for-each>
		-->
			
<xsl:for-each select="marc:datafield[@tag='130']|marc:datafield[@tag='240']">
				<mods:titleInfo type="uniform">		
				<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">alnp</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:text> </xsl:text>
						<xsl:call-template name="CSPLsubtitle"/>
						</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
		
</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='100']">
			<mods:name type="personal">
				<xsl:call-template name="nameABCQ"/>    <!-- do not pass 100 subfield d  Apr02,10 -->
				<xsl:call-template name="affiliation"/>
				<mods:role>
					<mods:roleTerm authority="marcrelator" type="text">creator</mods:roleTerm>
				</mods:role>
				<!-- Role hardcoded RBD 4/6/12 <xsl:call-template name="role"/>-->
			</mods:name>
		</xsl:for-each>
		<!--  all 110 in one line Nov16,09 alex  -->
		<xsl:variable name="exist-110" select="marc:datafield[@tag='110']"> </xsl:variable>
		<xsl:if test="$exist-110">
			<mods:name type="corporate">
				<mods:namePart>
					<xsl:for-each select="marc:datafield[@tag='110']">
						<xsl:call-template name="nameABCDN_CSPL"/>
					</xsl:for-each>
				</mods:namePart>
				<mods:role>
     			 <mods:roleTerm authority="marcrelator" type="text">creator</mods:roleTerm>
				</mods:role>
			</mods:name>
		</xsl:if>
		<xsl:for-each select="marc:datafield[@tag='111']">
			<mods:name type="conference">
				<xsl:call-template name="nameACDEQ"/>
			</mods:name>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='700'][not(marc:subfield[@code='t'])]">
			<mods:name type="personal">
				<xsl:call-template name="nameABCQ"/>   <!-- do not pass 700 subfield d  Apr02,10 -->
				<xsl:call-template name="affiliation"/>
				<mods:role>
					<mods:roleTerm authority="marcrelator" type="text">contributor</mods:roleTerm>
				</mods:role>
				<!-- Role hardcoded RBD 4/6/12 <xsl:call-template name="role"/>-->
			</mods:name>
		</xsl:for-each>

		<!-- "Corporate" (710) all in one line  Nov16,09 alex -->
		<xsl:for-each select="marc:datafield[@tag='710'][not(marc:subfield[@code='t'])]">
			<mods:name type="corporate">
				<mods:namePart>									
				<xsl:call-template name="nameABCDN_CSPL"/>   
				</mods:namePart>
					<mods:role>
						<mods:roleTerm authority="marcrelator" type="text">contributor</mods:roleTerm>
					</mods:role>
				<!-- Role hardcoded RBD 4/6/12 <xsl:call-template name="role"/>-->
			</mods:name>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='711'][not(marc:subfield[@code='t'])]">
			<mods:name type="conference">
				<xsl:call-template name="nameACDEQ"/>
				<xsl:call-template name="role"/>
			</mods:name>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='720'][not(marc:subfield[@code='t'])]">
			<mods:name>
				<xsl:if test="@ind1=1">
					<xsl:attribute name="type">
						<xsl:text>personal</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<mods:namePart>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</mods:namePart>
				<!-- Role hardcoded RBD 4/6/12 <xsl:call-template name="role"/>-->
			</mods:name>
		</xsl:for-each>
		<mods:typeOfResource>
			<xsl:if test="$leader7='c'">
				<xsl:attribute name="collection">yes</xsl:attribute>
			</xsl:if>
			<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
				<xsl:attribute name="manuscript">yes</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
				<xsl:when test="$leader6='i'">sound recording-nonmusical</xsl:when>
				<xsl:when test="$leader6='j'">sound recording-musical</xsl:when>
				<xsl:when test="$leader6='k'">still image</xsl:when>
				<xsl:when test="$leader6='g'">moving image</xsl:when>
				<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
				<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
				<xsl:when test="$leader6='p'">mixed material</xsl:when>
			</xsl:choose>
		</mods:typeOfResource>

		<mods:originInfo>

		<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='a']">
				<xsl:if test="not(contains(.,'S.l.'))"> <!-- "we’ve decided to not populate Place of Publication if there is S.l. in $a." apr07,10 alex -->
				<mods:place>
					<mods:placeTerm>
						<xsl:attribute name="type">text</xsl:attribute>
						<xsl:call-template name="chopPunctuationFront">
							<xsl:with-param name="chopString">
								<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="punctuation">:,;/] </xsl:with-param>
									<xsl:with-param name="chopString" select= "translate(.,'[]','')" />   <!-- remove ALL brackets alex apr6,10-->
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:placeTerm>
				</mods:place>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each
				select="marc:datafield[@tag=260]/marc:subfield[@code='b' or @code='c' or @code='g']">
				<xsl:choose>
					<xsl:when test="@code='b' and not(contains(.,'s.n.'))" > <!-- "If $b has s.n. do not populate name of publisher." apr07,10 alex -->
						<mods:publisher>
							<xsl:call-template name="chopPunctuation">
								<xsl:with-param name="chopString" select="translate(.,'[]','')"/>  <!-- remove ALL brackets alex apr6,10-->
								<xsl:with-param name="punctuation">
									<xsl:text>:,;/ </xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</mods:publisher>
					</xsl:when>
					<xsl:when test="@code='c'">
						<mods:dateIssued keyDate="yes">
							<xsl:call-template name="chopPunctuation">
								<xsl:with-param name="chopString" select="translate(.,'[]','')"/>
							</xsl:call-template>
						</mods:dateIssued>
						</xsl:when>
					<xsl:when test="@code='g'">
						<mods:dateCreated>
							<xsl:value-of select="."/>
						</mods:dateCreated>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=250]">
				<mods:edition>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</mods:edition>
			</xsl:for-each>
			<xsl:for-each select="marc:leader">
				<!--	<mods:issuance>  29Oct09 Alex
					<xsl:choose>
						<xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">monographic</xsl:when>
						<xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">continuing</xsl:when>
					</xsl:choose>
				</mods:issuance>
				-->
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=310]|marc:datafield[@tag=321]">
				<mods:frequency>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">ab</xsl:with-param>
					</xsl:call-template>
				</mods:frequency>
			</xsl:for-each>
		</mods:originInfo>
		<xsl:variable name="controlField008-35-37"
			select="normalize-space(translate(substring($controlField008,36,3),'|#',''))"/>
		<xsl:if test="$controlField008-35-37">
			<mods:language>
				<mods:languageTerm authority="iso639-2b" type="code">
					<xsl:value-of select="substring($controlField008,36,3)"/>
				</mods:languageTerm>
			</mods:language>
		</xsl:if>
		<xsl:for-each select="marc:datafield[@tag=300]">
			<mods:physicalDescription>
			<mods:extent>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abce</xsl:with-param>
					</xsl:call-template>
			</mods:extent>
				</mods:physicalDescription>	
		</xsl:for-each>
	<!--Select form fields to transform but not display RD 2012.02.13 -->	
		<xsl:variable name="physicalDescription">
		<xsl:if test="marc:datafield[@tag=240]/marc:subfield[@code='h']">
				<mods:form authority="gmd">
					<xsl:call-template name="chopBrackets">
						<xsl:with-param name="chopString">
							<xsl:value-of select="marc:datafield[@tag=240]/marc:subfield[@code='h']"
							/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:form>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag=242]/marc:subfield[@code='h']">
				<mods:form authority="gmd">
					<xsl:call-template name="chopBrackets">
						<xsl:with-param name="chopString">
							<xsl:value-of select="marc:datafield[@tag=242]/marc:subfield[@code='h']"
							/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:form>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag=245]/marc:subfield[@code='h']">
				<mods:form authority="gmd">
					<xsl:call-template name="chopBrackets">
						<xsl:with-param name="chopString">
							<xsl:value-of select="marc:datafield[@tag=245]/marc:subfield[@code='h']"
							/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:form>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag=246]/marc:subfield[@code='h']">
				<mods:form authority="gmd">
					<xsl:call-template name="chopBrackets">
						<xsl:with-param name="chopString">
							<xsl:value-of select="marc:datafield[@tag=246]/marc:subfield[@code='h']"
							/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:form>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag=730]/marc:subfield[@code='h']">
				<mods:form authority="gmd">
					<xsl:call-template name="chopBrackets">
						<xsl:with-param name="chopString">
							<xsl:value-of select="marc:datafield[@tag=730]/marc:subfield[@code='h']"
							/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:form>
			</xsl:if>
			<xsl:for-each select="marc:datafield[@tag=256]/marc:subfield[@code='a']">
				<mods:form>
					<xsl:value-of select="."/>
				</mods:form>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($physicalDescription))">
			<mods:physicalDescription>
				<xsl:copy-of select="$physicalDescription"/>
			</mods:physicalDescription>
		</xsl:if>
		
		<!--  2009/04/09  - Mapped [362] using <mods:extension>. -->
		<xsl:for-each select="marc:datafield[@tag=362][marc:subfield[@code='a']]">
			<mods:extension xmlns:marc="http://www.loc.gov/MARC21/slim">
				<marc:datafield tag="362" ind1="0" ind2=" ">
					<marc:subfield code="a">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">a</xsl:with-param>
						</xsl:call-template>
					</marc:subfield>
				</marc:datafield>
			</mods:extension>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=520]">
			<mods:abstract>
				<xsl:call-template name="uri"/>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ab</xsl:with-param>
				</xsl:call-template>
			</mods:abstract>
		</xsl:for-each>

<!--ekf 2012-0404-1535 -->
		<xsl:apply-templates select="marc:datafield[653 &gt;= @tag and @tag &gt;= 600]"/>
		<xsl:apply-templates select="marc:datafield[@tag=656]"/>
<!--ekf 2012-0404-1535 -->

			<xsl:for-each select="marc:datafield[@tag=505]">
			<mods:note>
				<xsl:call-template name="uri"/>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">agrt</xsl:with-param>
				</xsl:call-template>
			</mods:note>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=500]">
			<mods:note>
				<xsl:value-of select="marc:subfield[@code='a']"/>
				<xsl:call-template name="uri"/>
			</mods:note>
		</xsl:for-each>
<xsl:for-each select="marc:datafield[@tag=504]">
			<mods:note>
				<xsl:value-of select="marc:subfield[@code='a']"/>
				<xsl:call-template name="uri"/>
			</mods:note>
</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=508]">
			<mods:note>
				<xsl:value-of select="marc:subfield[@code='a']"/>
				<xsl:call-template name="uri"/>
			</mods:note>
		</xsl:for-each>
		<xsl:for-each
			select="marc:datafield[@tag=501 or @tag=502 or @tag=506 or @tag=507 or
			@tag=510 or @tag=511 or @tag=513 or @tag=514 or @tag=515 or @tag=516 or @tag=522 or @tag=524 or
			@tag=525 or @tag=526 or @tag=533 or @tag=534 or @tag=535 or @tag=536 or @tag=541 or @tag=544 or
			@tag=545 or @tag=546 or @tag=547 or @tag=550 or @tag=552 or @tag=555 or @tag=556 or @tag=561 or
			@tag=562 or @tag=565 or @tag=567 or @tag=580 or @tag=581 or @tage=583 or @tag=584 or @tag=585 or @tag=586]">
			<mods:note>
				<xsl:call-template name="uri"/>
				<xsl:variable name="str">
					<xsl:for-each select="marc:subfield[@code!='6' or @code!='8']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:variable>
				<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
			</mods:note>
		</xsl:for-each>
		
		<xsl:for-each select="marc:datafield[@tag=086][marc:subfield[@code='2']]">
			<mods:classification authority="codocs">
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</mods:classification>
		</xsl:for-each>

		<!--  090604   Added [098] <mods:classification> to meet the local needs of Colorado State Publications.  -->
		<xsl:for-each select="marc:datafield[@tag=098][@ind1=2][ind2=1]">
			<mods:classification authority="codocs">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">aef</xsl:with-param>
				</xsl:call-template>
			</mods:classification>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=440]">
			<mods:relatedItem type="series">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">av</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=490][@ind1=0]">
			<mods:relatedItem type="series">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">av</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag='740'][@ind2!='2']">
			<mods:relatedItem type="constituent">
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">a</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:call-template name="part"/>
			</mods:titleInfo>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=770]|marc:datafield[@tag=774]">
			<mods:relatedItem type="constituent">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=772]|marc:datafield[@tag=773]">
			<mods:relatedItem type="host">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=776]">
			<!-- "We do not want the 776 (related title) to display."(c) Nov19,09 alex
			<mods:relatedItem type="otherFormat">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>			-->
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=780]">
			<mods:relatedItem type="preceding">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=785]">
			<mods:relatedItem type="succeeding">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=786]">
			<mods:relatedItem type="original">
				<xsl:call-template name="relatedItem76X-78X"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=800]">
			<mods:relatedItem type="series">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="specialSubfieldSelect">
									<xsl:with-param name="anyCodes">tfklmorsv</xsl:with-param>
									<xsl:with-param name="axis">t</xsl:with-param>
									<xsl:with-param name="afterCodes">g</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="part"/>
				</mods:titleInfo>
				<mods:name type="personal">
					<mods:namePart>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="specialSubfieldSelect">
									<xsl:with-param name="anyCodes">aq</xsl:with-param>
									<xsl:with-param name="axis">t</xsl:with-param>
									<xsl:with-param name="beforeCodes">g</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:namePart>
					<xsl:call-template name="termsOfAddress"/>
					<xsl:call-template name="nameDate"/>
					<xsl:call-template name="role"/>
				</mods:name>
				<xsl:call-template name="relatedForm"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=810]">
			<mods:relatedItem type="series">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="specialSubfieldSelect">
									<xsl:with-param name="anyCodes">tfklmorsv</xsl:with-param>
									<xsl:with-param name="axis">t</xsl:with-param>
									<xsl:with-param name="afterCodes">dg</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="relatedPartNumName"/>
				</mods:titleInfo>
				<mods:name type="corporate">
					<xsl:for-each select="marc:subfield[@code='a']">
						<mods:namePart>
							<xsl:value-of select="."/>
						</mods:namePart>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code='b']">
						<mods:namePart>
							<xsl:value-of select="."/>
						</mods:namePart>
					</xsl:for-each>
					<mods:namePart>
						<xsl:call-template name="specialSubfieldSelect">
							<xsl:with-param name="anyCodes">c</xsl:with-param>
							<xsl:with-param name="axis">t</xsl:with-param>
							<xsl:with-param name="beforeCodes">dgn</xsl:with-param>
						</xsl:call-template>
					</mods:namePart>
					<xsl:call-template name="role"/>
				</mods:name>
				<xsl:call-template name="relatedForm"/>
			</mods:relatedItem>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=811]">
			<mods:relatedItem type="series">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="specialSubfieldSelect">
									<xsl:with-param name="anyCodes">tfklsv</xsl:with-param>
									<xsl:with-param name="axis">t</xsl:with-param>
									<xsl:with-param name="afterCodes">g</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
					<xsl:call-template name="relatedPartNumName"/>
				</mods:titleInfo>
				<mods:name type="conference">
					<mods:namePart>
						<xsl:call-template name="specialSubfieldSelect">
							<xsl:with-param name="anyCodes">aqdc</xsl:with-param>
							<xsl:with-param name="axis">t</xsl:with-param>
							<xsl:with-param name="beforeCodes">gn</xsl:with-param>
						</xsl:call-template>
					</mods:namePart>
					<xsl:call-template name="role"/>
				</mods:name>
				<xsl:call-template name="relatedForm"/>
			</mods:relatedItem>
		</xsl:for-each>
	
		<xsl:for-each select="marc:datafield[@tag=830]">
			<mods:relatedItem type="series">
				<mods:titleInfo>
					<mods:title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">anp</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</mods:title>
				</mods:titleInfo>
			</mods:relatedItem>
		</xsl:for-each>

		<!-- 1/04 fix added $y -->
		<!--  May 7, 2009  Comment out mapping for [856] field $u as per Colorado State Pubs
			specifications.  Bridget-->
		<!-- 3.2 change tmee 856z  -->
		<mods:recordInfo>
			<xsl:for-each select="marc:datafield[@tag=040]">
							</xsl:for-each>
			<xsl:for-each select="marc:controlfield[@tag=008]">
				
			</xsl:for-each>
			<xsl:for-each select="marc:controlfield[@tag=005]">
				
			</xsl:for-each>
			<xsl:for-each select="marc:controlfield[@tag=001]">
				<mods:recordIdentifier>
					<xsl:if test="../marc:controlfield[@tag=003]">
						<xsl:attribute name="source">
							<xsl:value-of select="../marc:controlfield[@tag=003]"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="substring(substring-after(.,'oc'),2)"/> <!-- all after ocn or ocm Apr20,10 alex-->
					</mods:recordIdentifier>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=040]/marc:subfield[@code='b']">
				<mods:languageOfCataloging>
					<mods:languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="."/>
					</mods:languageTerm>
				</mods:languageOfCataloging>
			</xsl:for-each>
		</mods:recordInfo>
	</xsl:template>
	<xsl:template name="displayForm">
		<xsl:for-each select="marc:subfield[@code='c']">
			<mods:displayForm>
				<xsl:value-of select="."/>
			</mods:displayForm>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="affiliation">
		<xsl:for-each select="marc:subfield[@code='u']">
			<mods:affiliation>
				<xsl:value-of select="."/>
			</mods:affiliation>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="uri">
		<xsl:for-each select="marc:subfield[@code='u']">
			<xsl:attribute name="xlink:href">
				<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="role">
		<xsl:for-each select="marc:subfield[@code='e']">
			<mods:role>
				<mods:roleTerm authority="marcrelator" type="text">
					<xsl:value-of select="."/>
				</mods:roleTerm>
			</mods:role>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='4']">
			<mods:role>
				<mods:roleTerm authority="marcrelator" type="code">
					<xsl:value-of select="."/>
				</mods:roleTerm>
			</mods:role>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="part">
		<xsl:variable name="partNumber">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">n</xsl:with-param>
				<xsl:with-param name="anyCodes">n</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="partName">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">p</xsl:with-param>
				<xsl:with-param name="anyCodes">p</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($partNumber))">
			<mods:partNumber>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="$partNumber"/>
				</xsl:call-template>
			</mods:partNumber>
		</xsl:if>
		<xsl:if test="string-length(normalize-space($partName))">
			<mods:partName>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="$partName"/>
				</xsl:call-template>
			</mods:partName>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedPart">
		<xsl:if test="@tag=773">
			<xsl:for-each select="marc:subfield[@code='g']">
				<mods:part>
					<mods:text>
						<xsl:value-of select="."/>
					</mods:text>
				</mods:part>
			</xsl:for-each>
			<xsl:for-each select="marc:subfield[@code='q']">
				<mods:part>
					<xsl:call-template name="parsePart"/>
				</mods:part>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedPartNumName">
		<xsl:variable name="partNumber">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">g</xsl:with-param>
				<xsl:with-param name="anyCodes">g</xsl:with-param>
				<xsl:with-param name="afterCodes">pst</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="partName">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">p</xsl:with-param>
				<xsl:with-param name="anyCodes">p</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($partNumber))">
			<mods:partNumber>
				<xsl:value-of select="$partNumber"/>
			</mods:partNumber>
		</xsl:if>
		<xsl:if test="string-length(normalize-space($partName))">
			<mods:partName>
				<xsl:value-of select="$partName"/>
			</mods:partName>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedName">
		<xsl:for-each select="marc:subfield[@code='a']">
			<mods:name>
				<mods:namePart>
					<xsl:value-of select="."/>
				</mods:namePart>
			</mods:name>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedForm">
		<xsl:for-each select="marc:subfield[@code='h']">
			<mods:physicalDescription>
				<mods:form>
					<xsl:value-of select="."/>
				</mods:form>
			</mods:physicalDescription>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedExtent">
		<xsl:for-each select="marc:subfield[@code='h']">
			<mods:physicalDescription>
				<mods:extent>
					<xsl:value-of select="."/>
				</mods:extent>
			</mods:physicalDescription>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="relatedNote">
		<xsl:for-each select="marc:subfield[@code='n']">
			<mods:note>
				<xsl:value-of select="."/>
			</mods:note>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedSubject">
		<xsl:for-each select="marc:subfield[@code='j']">
			<mods:subject>
				<mods:temporal encoding="iso8601">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="."/>
					</xsl:call-template>
				</mods:temporal>
			</mods:subject>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedIdentifierISSN">
		<xsl:for-each select="marc:subfield[@code='x']">
			<mods:identifier type="issn">
				<xsl:value-of select="."/>
			</mods:identifier>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedIdentifierLocal">
		<xsl:for-each select="marc:subfield[@code='w']">
			<mods:identifier type="local">
				<xsl:value-of select="."/>
			</mods:identifier>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedIdentifier">
		<xsl:for-each select="marc:subfield[@code='o']">
			<mods:identifier>
				<xsl:value-of select="."/>
			</mods:identifier>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedItem76X-78X">
		<xsl:call-template name="displayLabel"/>
		<xsl:call-template name="relatedTitle76X-78X"/>
		<xsl:call-template name="relatedName"/>
		<xsl:call-template name="relatedOriginInfo"/>
		<xsl:call-template name="relatedLanguage"/>
		<xsl:call-template name="relatedExtent"/>
		<xsl:call-template name="relatedNote"/>
		<xsl:call-template name="relatedSubject"/>
		<xsl:call-template name="relatedIdentifier"/>
		<xsl:call-template name="relatedIdentifierISSN"/>
		<xsl:call-template name="relatedIdentifierLocal"/>
		<xsl:call-template name="relatedPart"/>
	</xsl:template>
	<xsl:template name="subjectGeographicZ">
		<!-- deduplication of geographic names added Apr15,10 alex-->
		<xsl:variable name="geo">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</xsl:variable>
		<xsl:variable name="before"> <!-- unchopped string of all preceding nodes with tag "6xx" and code z -->
			<xsl:for-each select="../preceding-sibling::*[substring(@tag,1,1)='6']/marc:subfield[@code='z']"> 
				<xsl:value-of select="."/>
			</xsl:for-each>		<!-- unchopped string of all preceding nodes with tag "651" and code a -->
			<xsl:for-each select="../preceding-sibling::*[@tag='650']/marc:subfield[@code='a']"> 
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
 		<xsl:if test="not(contains($before, $geo))">
			<mods:geographic>
				<xsl:value-of select="$geo"/>
			</mods:geographic>
		</xsl:if>	
	</xsl:template>
	<xsl:template name="subjectTemporalY">
		<!-- deduplication (modified) of temporal  names added May14,10 alex-->
		<xsl:variable name="teo">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="before"> <!-- unchopped string of all preceding nodes with tag "6xx" and code y -->
			<xsl:for-each select="../preceding-sibling::*[substring(@tag,1,1)='6']/marc:subfield[@code='y']"> 
				<xsl:value-of select="."/>
			</xsl:for-each>		
		</xsl:variable>
		<xsl:if test="not(contains(normalize-space(translate($before,substring($ascii,34,26),substring($ascii,66,26))), (normalize-space(translate($teo,substring($ascii,34,26),substring($ascii,66,26))))))">	
			<mods:temporal>
				<xsl:value-of select="$teo"/>
			</mods:temporal>
		</xsl:if>			
	</xsl:template>
	<xsl:template name="subjectTopic">
		<!-- deduplication (modified and) of topic names added May14,10 alex-->
		<xsl:variable name="teo">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="before"> <!-- unchopped string of all preceding nodes with tag "6xx" and code x -->
			<!-- <xsl:for-each select="../preceding-sibling::*[substring(@tag,1,1)='6']/marc:subfield[@code='x']"> 
				<xsl:value-of select="."/>
			</xsl:for-each>	 -->	<!-- unchopped string of all preceding and following nodes with tag "650" and code a or b -->
			<xsl:for-each select="../preceding-sibling::*[@tag='650']/marc:subfield[@code='a' or @code='b' or
				@code='x']"> 
				<xsl:value-of select="."/>
			</xsl:for-each>
			<xsl:for-each select="../following-sibling::*[@tag='650']/marc:subfield[@code='a' or @code='b' or
				@code='x']"> 
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="not(contains(normalize-space(translate($before,substring($ascii,34,26),substring($ascii,66,26))), (normalize-space(translate($teo,substring($ascii,34,26),substring($ascii,66,26))))))">	
			<mods:topic>
				<xsl:value-of select="$teo"/>
			</mods:topic>
		</xsl:if>		
	</xsl:template>
	<!-- 3.2 change tmee 6xx $v genre -->
	<xsl:template name="subjectGenre">
		<!-- deduplication of Genre added Apr14,10 alex  -->
		<xsl:variable name="gen">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="before"> <!-- unchopped string of all preceding nodes with tag "6xx" and code v -->
			<xsl:for-each select="../preceding-sibling::*[substring(@tag,1,1)='6']/marc:subfield[@code='v']">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="not(contains($before, $gen))">
			<mods:genre>
				<xsl:value-of select="$gen"/>
			</mods:genre>
		</xsl:if>	
	</xsl:template>
	<xsl:template name="nameABCDN">
		<xsl:for-each select="marc:subfield[@code='a']">
			<mods:namePart>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
				<xsl:text>, </xsl:text>
				<!-- can we have a period after the end of subfield a?(c) Nov25,09 alex -->
			</mods:namePart>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='b']">
			<mods:namePart>
				<xsl:value-of select="."/>
			</mods:namePart>
		</xsl:for-each>
		<xsl:if
			test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
			<mods:namePart>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">cdn</xsl:with-param>
				</xsl:call-template>
			</mods:namePart>
		</xsl:if>
	</xsl:template>
	<xsl:template name="nameABCDN_CSPL">
		<!-- (MARC 110, 710, 100, 700) – We would like these to display all on one line if possible (c)  Nov 13, 09 alex -->

		<xsl:for-each select="marc:subfield[@code='a']">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
				<xsl:with-param name="punctuation">:,;/</xsl:with-param>  
			</xsl:call-template>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='b']">
			<xsl:value-of select="."/>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:if
			test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='e']">
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">cde</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>
	<xsl:template name="nameABCDQ">
		<mods:namePart>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">aq</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="punctuation">
					<xsl:text>:,;/ </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</mods:namePart>
		<xsl:call-template name="termsOfAddress"/>
		<xsl:call-template name="nameDate"/>
	</xsl:template>
	<xsl:template name="nameABCQ">     <!-- same as ABCDQ but without "d"/nameDate aApr2,10 alex-->
		<mods:namePart>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">aq</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="punctuation">
					<xsl:text>:,;/ </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</mods:namePart>
		<xsl:call-template name="termsOfAddress"/>
		<!--			<xsl:call-template name="nameDate"/>   -->
	</xsl:template>
	<xsl:template name="nameACDEQ">
		<mods:namePart>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">acdeq</xsl:with-param>
			</xsl:call-template>
		</mods:namePart>
	</xsl:template>
	<xsl:template name="constituentOrRelatedType">
		<xsl:if test="@ind2=2">
			<xsl:attribute name="type">constituent</xsl:attribute>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedTitle">
		<xsl:for-each select="marc:subfield[@code='t']">
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
			</mods:titleInfo>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedTitle76X-78X">
		<xsl:for-each select="marc:subfield[@code='t']">
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:if test="marc:datafield[@tag!=773]and marc:subfield[@code='g']">
					<xsl:call-template name="relatedPartNumName"/>
				</xsl:if>
			</mods:titleInfo>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='p']">
			<mods:titleInfo type="abbreviated">
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:if test="marc:datafield[@tag!=773]and marc:subfield[@code='g']">
					<xsl:call-template name="relatedPartNumName"/>
				</xsl:if>
			</mods:titleInfo>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='s']">
			<mods:titleInfo type="uniform">
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</mods:title>
				<xsl:if test="marc:datafield[@tag!=773]and marc:subfield[@code='g']">
					<xsl:call-template name="relatedPartNumName"/>
				</xsl:if>
			</mods:titleInfo>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="relatedOriginInfo">
		<xsl:if test="marc:subfield[@code='b' or @code='d'] or marc:subfield[@code='f']">
			<mods:originInfo>
				<xsl:for-each select="marc:subfield[@code='d']">
					<mods:publisher>
						<xsl:value-of select="."/>
					</mods:publisher>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='b']">
					<mods:edition>
						<xsl:value-of select="."/>
					</mods:edition>
				</xsl:for-each>
			</mods:originInfo>
		</xsl:if>
	</xsl:template>
	<xsl:template name="relatedLanguage">
		<xsl:for-each select="marc:subfield[@code='e']">
			<xsl:call-template name="getLanguage">
				<xsl:with-param name="langString">
					<xsl:value-of select="."/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="nameDate">
		<xsl:for-each select="marc:subfield[@code='d']">
			<mods:namePart type="date">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</mods:namePart>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="subjectAuthority">
		<xsl:if test="@ind2!=4">
			<xsl:if test="@ind2!=' '">
				<xsl:if test="@ind2!=8">
					<xsl:if test="@ind2!=9">
						<xsl:attribute name="authority">
							<xsl:choose>
								<xsl:when test="@ind2=0">lcsh</xsl:when>
								<xsl:when test="@ind2=1">lcshac</xsl:when>
								<xsl:when test="@ind2=2">mesh</xsl:when>
								<!-- 1/04 fix -->
								<xsl:when test="@ind2=3">nal</xsl:when>
								<xsl:when test="@ind2=5">csh</xsl:when>
								<xsl:when test="@ind2=6">rvm</xsl:when>
								<xsl:when test="@ind2=7">
									<xsl:value-of select="marc:subfield[@code='2']"/>
								</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="subjectAnyOrder">
		<xsl:for-each select="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
			<xsl:choose>
				<xsl:when test="@code='v'">
					<xsl:call-template name="subjectGenre"/>
				</xsl:when>
				<xsl:when test="@code='x'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='y'">
					<xsl:call-template name="subjectTemporalY"/>
				</xsl:when>
				<xsl:when test="@code='z'">
					<xsl:call-template name="subjectGeographicZ"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="specialSubfieldSelect">
		<xsl:param name="anyCodes"/>
		<xsl:param name="axis"/>
		<xsl:param name="beforeCodes"/>
		<xsl:param name="afterCodes"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if
					test="contains($anyCodes, @code)      or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
	</xsl:template>

	<xsl:template name="subfieldColon">  <!-- for inserting colon in front of subtitle. Apr1,10 alex-->
		<xsl:param name="anyCodes"/>
		<xsl:param name="axis"/>
		<xsl:param name="beforeCodes"/>
		<xsl:param name="afterCodes"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if
					test="contains($anyCodes, @code)      or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
					<xsl:text> : </xsl:text>     <!-- colon ( spaces?)  -->
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
	</xsl:template>

	<!-- 3.2 change tmee 6xx $v genre -->
	<xsl:template match="marc:datafield[@tag=600]">
		<mods:subject>
			<xsl:call-template name="subjectAuthority"/>
			<mods:name type="personal">
				<xsl:call-template name="termsOfAddress"/>
				<mods:namePart>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">acdq4</xsl:with-param>
								<xsl:with-param name="delimiter">--</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</mods:namePart>
				<xsl:call-template name="nameDate"/>
				<xsl:call-template name="affiliation"/>
				<xsl:call-template name="role"/>
			</mods:name>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag=610]">
		<mods:subject>
			<xsl:call-template name="subjectAuthority"/>
			<mods:name type="corporate">
				<xsl:for-each select="marc:subfield[@code='a']">
					<mods:namePart>
						<xsl:value-of select="."/>
							<xsl:if test="not(substring(., string-length(.)) = '.')"> 
								<xsl:text>.</xsl:text>
							</xsl:if>
						<xsl:value-of select="../marc:subfield[@code='t']"/> <!-- attach subfield t immediately after,  Apr20,10 alex -->
					</mods:namePart>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='b']">
					<mods:namePart>
						<xsl:value-of select="."/>
					</mods:namePart>
				</xsl:for-each>
				<xsl:if test="marc:subfield[@code='c' or @code='d' or @code='n' or @code='p']">
					<mods:namePart>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">xcdnv</xsl:with-param>
							<xsl:with-param name="delimiter">--</xsl:with-param>
						</xsl:call-template>
					</mods:namePart>
				</xsl:if>
				<xsl:call-template name="role"/>
			</mods:name>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag=611]">
		<mods:subject>
			<xsl:call-template name="subjectAuthority"/>
			<mods:name type="conference">
				<mods:namePart>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">acdnpv</xsl:with-param>
						<xsl:with-param name="delimiter">--</xsl:with-param>
					</xsl:call-template>
				</mods:namePart>
				<xsl:for-each select="marc:subfield[@code='4']">
					<mods:role>
						<mods:roleTerm authority="marcrelator" type="code">
							<xsl:value-of select="."/>
						</mods:roleTerm>
					</mods:role>
				</xsl:for-each>
			</mods:name>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag=630]">
		<mods:subject>
			<xsl:call-template name="subjectAuthority"/>
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">alnpvxy</xsl:with-param>
								<xsl:with-param name="delimiter">--</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="part"/>
				</mods:title>
			</mods:titleInfo>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag=650]">
		<mods:subject>
			<xsl:call-template name="subjectAuthority"/>
			<mods:topic>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="dedupSubfieldSelect">
							<xsl:with-param name="codes">abeyx</xsl:with-param>
							<xsl:with-param name="delimiter">--</xsl:with-param>
							<xsl:with-param name="tag">650</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</mods:topic>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>

	<xsl:template name="dedupSubfieldSelect">  <!-- subfieldSelect with deduplication -->
		<xsl:param name="codes">abcdefghijklmnopqrstuvwxyz</xsl:param>
		<xsl:param name="delimiter">
			<xsl:text> </xsl:text>
		</xsl:param>
		<xsl:param name="tag"> </xsl:param>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
					<xsl:variable name="code">  <xsl:value-of select="@code"/> </xsl:variable>
					<xsl:variable name="content">  <xsl:value-of select="text()"/> </xsl:variable>
					<xsl:variable name="before"> <!-- unchopped string of all preceding nodes with tag  and code  -->
						<xsl:for-each select="../preceding-sibling::*[@tag = $tag]/marc:subfield[@code= $code]"> 
							<xsl:value-of select="."/>
						</xsl:for-each>		
					</xsl:variable>
					<xsl:if test="not(contains($before, $content))">
						<xsl:value-of select="text()"/>
						<xsl:value-of select="$delimiter"/>
					</xsl:if>	
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:value-of select="substring($str,1,string-length($str)-string-length($delimiter))"/>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=651]">
		<mods:subject>
			<xsl:call-template name="subjectAuthority"/>
			<xsl:for-each select="marc:subfield[@code='a']">

				<!-- deduplication of geographic names added Apr15,10 alex-->
				<xsl:variable name="geo">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="."/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="before"> <!-- unchopped string of all preceding nodes with tag "6xx" and code z -->
					<xsl:for-each select="../preceding-sibling::*[substring(@tag,1,1)='6']/marc:subfield[@code='z']"> 
						<xsl:value-of select="."/>
					</xsl:for-each>		<!-- unchopped string of all preceding nodes with tag "651" and code a -->
					<xsl:for-each select="../preceding-sibling::*[@tag='651']/marc:subfield[@code='a']"> <!-- perhaps some day i'll find the way to combine these two in one -->
						<xsl:value-of select="."/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="not(contains($before, $geo))">
					<mods:geographic>
						<xsl:value-of select="$geo"/>
					</mods:geographic>
				</xsl:if>	

		<!--  	<mods:geographic>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="."/>  
					</xsl:call-template>
				</mods:geographic>	-->
			</xsl:for-each>
			<xsl:call-template name="subjectAnyOrder"/>
		</mods:subject>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag=653]">
		<mods:subject>
			<xsl:for-each select="marc:subfield[@code='a']">
				<mods:topic>
					<xsl:value-of select="."/>
				</mods:topic>
			</xsl:for-each>
		</mods:subject>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag=656]">
		<mods:subject>
			<xsl:if test="marc:subfield[@code=2]">
				<xsl:attribute name="authority">
					<xsl:value-of select="marc:subfield[@code=2]"/>
				</xsl:attribute>
			</xsl:if>
			<mods:occupation>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="marc:subfield[@code='a']"/>
					</xsl:with-param>
				</xsl:call-template>
			</mods:occupation>
		</mods:subject>
	</xsl:template>
	<xsl:template name="termsOfAddress">
		<xsl:if test="marc:subfield[@code='b' or @code='c']">
			<mods:namePart type="termsOfAddress">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">bc</xsl:with-param>
							<xsl:with-param name="delimiter">--</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</mods:namePart>
		</xsl:if>
	</xsl:template>
	<xsl:template name="displayLabel">
		<xsl:if test="marc:subfield[@code='i']">
			<xsl:attribute name="displayLabel">
				<xsl:value-of select="marc:subfield[@code='i']"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="marc:subfield[@code='3']">
			<xsl:attribute name="displayLabel">
				<xsl:value-of select="marc:subfield[@code='3']"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	<xsl:template name="isInvalid">
		<xsl:param name="type"/>
		<xsl:if test="marc:subfield[@code='z'] or marc:subfield[@code='y']">
			<mods:identifier>
				<xsl:attribute name="type">
					<xsl:value-of select="$type"/>
				</xsl:attribute>
				<xsl:attribute name="invalid">
					<xsl:text>yes</xsl:text>
				</xsl:attribute>
				<xsl:if test="marc:subfield[@code='z']">
					<xsl:value-of select="marc:subfield[@code='z']"/>
				</xsl:if>
				<xsl:if test="marc:subfield[@code='y']">
					<xsl:value-of select="marc:subfield[@code='y']"/>
				</xsl:if>
			</mods:identifier>
		</xsl:if>
	</xsl:template>

	<xsl:template name="subtitle">
		<xsl:if test="marc:subfield[@code='b']">
			<!-- or @code='c' -->
			<mods:subTitle>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="marc:subfield[@code='b' ]"/>
						<!--   
							
							
							<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">b</xsl:with-param>									
							</xsl:call-template>-->

					</xsl:with-param>
				</xsl:call-template>
			</mods:subTitle>
		</xsl:if>
	</xsl:template>
	<xsl:template name="CSPLsubtitle">
		<xsl:if test="marc:subfield[@code='b']">
			<!-- or @code='c' -->
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:value-of select="marc:subfield[@code='b' ]"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="script">
		<xsl:param name="scriptCode"/>
		<xsl:attribute name="script">
			<xsl:choose>
				<xsl:when test="$scriptCode='(3'">Arabic</xsl:when>
				<xsl:when test="$scriptCode='(B'">Latin</xsl:when>
				<xsl:when test="$scriptCode='$1'">Chinese, Japanese, Korean</xsl:when>
				<xsl:when test="$scriptCode='(N'">Cyrillic</xsl:when>
				<xsl:when test="$scriptCode='(2'">Hebrew</xsl:when>
				<xsl:when test="$scriptCode='(S'">Greek</xsl:when>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	<xsl:template name="parsePart">
		<!-- assumes 773$q= 1:2:3<4
		     with up to 3 levels and one optional start page
		-->
		<xsl:variable name="level1">
			<xsl:choose>
				<xsl:when test="contains(text(),':')">
					<!-- 1:2 -->
					<xsl:value-of select="substring-before(text(),':')"/>
				</xsl:when>
				<xsl:when test="not(contains(text(),':'))">
					<!-- 1 or 1<3 -->
					<xsl:if test="contains(text(),'&lt;')">
						<!-- 1<3 -->
						<xsl:value-of select="substring-before(text(),'&lt;')"/>
					</xsl:if>
					<xsl:if test="not(contains(text(),'&lt;'))">
						<!-- 1 -->
						<xsl:value-of select="text()"/>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sici2">
			<xsl:choose>
				<xsl:when test="starts-with(substring-after(text(),$level1),':')">
					<xsl:value-of select="substring(substring-after(text(),$level1),2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(text(),$level1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="level2">
			<xsl:choose>
				<xsl:when test="contains($sici2,':')">
					<!--  2:3<4  -->
					<xsl:value-of select="substring-before($sici2,':')"/>
				</xsl:when>
				<xsl:when test="contains($sici2,'&lt;')">
					<!-- 1: 2<4 -->
					<xsl:value-of select="substring-before($sici2,'&lt;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sici2"/>
					<!-- 1:2 -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sici3">
			<xsl:choose>
				<xsl:when test="starts-with(substring-after($sici2,$level2),':')">
					<xsl:value-of select="substring(substring-after($sici2,$level2),2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after($sici2,$level2)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="level3">
			<xsl:choose>
				<xsl:when test="contains($sici3,'&lt;')">
					<!-- 2<4 -->
					<xsl:value-of select="substring-before($sici3,'&lt;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sici3"/>
					<!-- 3 -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="page">
			<xsl:if test="contains(text(),'&lt;')">
				<xsl:value-of select="substring-after(text(),'&lt;')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$level1">
			<mods:detail level="1">
				<mods:number>
					<xsl:value-of select="$level1"/>
				</mods:number>
			</mods:detail>
		</xsl:if>
		<xsl:if test="$level2">
			<mods:detail level="2">
				<mods:number>
					<xsl:value-of select="$level2"/>
				</mods:number>
			</mods:detail>
		</xsl:if>
		<xsl:if test="$level3">
			<mods:detail level="3">
				<mods:number>
					<xsl:value-of select="$level3"/>
				</mods:number>
			</mods:detail>
		</xsl:if>
		<xsl:if test="$page">
			<mods:extent unit="page">
				<mods:start>
					<xsl:value-of select="$page"/>
				</mods:start>
			</mods:extent>
		</xsl:if>
	</xsl:template>
	<xsl:template name="getLanguage">
		<xsl:param name="langString"/>
		<xsl:param name="controlField008-35-37"/>
		<xsl:variable name="length" select="string-length($langString)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="$controlField008-35-37=substring($langString,1,3)">
				<xsl:call-template name="getLanguage">
					<xsl:with-param name="langString" select="substring($langString,4,$length)"/>
					<xsl:with-param name="controlField008-35-37" select="$controlField008-35-37"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<mods:language>
					<mods:languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="substring($langString,1,3)"/>
					</mods:languageTerm>
				</mods:language>
				<xsl:call-template name="getLanguage">
					<xsl:with-param name="langString" select="substring($langString,4,$length)"/>
					<xsl:with-param name="controlField008-35-37" select="$controlField008-35-37"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="isoLanguage">
		<xsl:param name="currentLanguage"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="remainingLanguages"/>
		<xsl:choose>
			<xsl:when test="string-length($currentLanguage)=0"/>
			<xsl:when test="not(contains($usedLanguages, $currentLanguage))">
				<mods:language>
					<xsl:if test="@code!='a'">
						<xsl:attribute name="objectPart">
							<xsl:choose>
								<xsl:when test="@code='b'">summary or subtitle</xsl:when>
								<xsl:when test="@code='d'">sung or spoken text</xsl:when>
								<xsl:when test="@code='e'">libretto</xsl:when>
								<xsl:when test="@code='f'">table of contents</xsl:when>
								<xsl:when test="@code='g'">accompanying material</xsl:when>
								<xsl:when test="@code='h'">translation</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<mods:languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="$currentLanguage"/>
					</mods:languageTerm>
				</mods:language>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of
							select="substring($remainingLanguages,4,string-length($remainingLanguages))"
						/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of
							select="substring($remainingLanguages,4,string-length($remainingLanguages))"
						/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="chopBrackets">
		<xsl:param name="chopString"/>
		<xsl:variable name="string">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="$chopString"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="substring($string, 1,1)='['">
			<xsl:value-of select="substring($string,2, string-length($string)-2)"/>
		</xsl:if>
		<xsl:if test="substring($string, 1,1)!='['">
			<xsl:value-of select="$string"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="rfcLanguages">
		<xsl:param name="nodeNum"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="controlField008-35-37"/>
		<xsl:variable name="currentLanguage" select="."/>
		<xsl:choose>
			<xsl:when test="not($currentLanguage)"/>
			<xsl:when
				test="$currentLanguage!=$controlField008-35-37 and $currentLanguage!='rfc3066'">
				<xsl:if test="not(contains($usedLanguages,$currentLanguage))">
					<mods:language>
						<xsl:if test="@code!='a'">
							<xsl:attribute name="objectPart">
								<xsl:choose>
									<xsl:when test="@code='b'">summary or subtitle</xsl:when>
									<xsl:when test="@code='d'">sung or spoken text</xsl:when>
									<xsl:when test="@code='e'">libretto</xsl:when>
									<xsl:when test="@code='f'">table of contents</xsl:when>
									<xsl:when test="@code='g'">accompanying material</xsl:when>
									<xsl:when test="@code='h'">translation</xsl:when>
								</xsl:choose>
							</xsl:attribute>
						</xsl:if>
						<mods:languageTerm authority="rfc3066" type="code">
							<xsl:value-of select="$currentLanguage"/>
						</mods:languageTerm>
					</mods:language>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise> </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>

