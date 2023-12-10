<!--Van Elias De Hondt & Kobe Wijnants-->
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
	<xsl:output method='text'/>
	<xsl:template match='/'>

		<xsl:for-each select='/CountryList/country'>
			<xsl:text>INSERT INTO dbo.country2 (name, code, code3) VALUES ('</xsl:text>
			<xsl:value-of select='normalize-space(@co_name)'/> <!-- name -->
			<xsl:text>', '</xsl:text>
			<xsl:value-of select='normalize-space(@sc)'/> <!-- code -->
			<xsl:text>', '</xsl:text>
			<xsl:value-of select='normalize-space(@lc)'/> <!-- code3 -->
			<xsl:text>');</xsl:text>
			<xsl:text>&#10;</xsl:text> <!--new line!-->
		

			<xsl:for-each select='city'>
				<xsl:text>INSERT INTO dbo.city2 (city_id, city_name, latitude, longitude, postal_code, country_code) VALUES (</xsl:text>
				<xsl:text>(SELECT CAST('' AS XML).value('xs:base64Binary(sql:column("BASE64_COLUMN"))', 'BINARY(16)')</xsl:text>
				<xsl:text>FROM (SELECT '</xsl:text>
				<xsl:value-of select='normalize-space(@city_id)'/> <!-- city_id -->
				<xsl:text>' AS BASE64_COLUMN) A)</xsl:text>
				<xsl:text>,'</xsl:text>
				<xsl:value-of select='normalize-space(translate(@ci_name, "&apos;", ""))'/> <!-- city_name -->
				<xsl:text>','</xsl:text>
				<xsl:value-of select='geo/lat'/> <!-- longitude -->
				<xsl:text>','</xsl:text>
				<xsl:value-of select='geo/long'/> <!-- longtitude -->
				<xsl:text>','</xsl:text>
				<xsl:value-of select='normalize-space(@post)'/> <!-- postal_code -->
				<xsl:text>','</xsl:text>
				<xsl:value-of select='normalize-space(../@sc)'/> <!-- country_code -->
				<xsl:text>');</xsl:text>
				<xsl:text>&#10;</xsl:text> <!--new line!-->
			</xsl:for-each>
		</xsl:for-each>

	</xsl:template>
</xsl:stylesheet>