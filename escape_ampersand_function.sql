-- escapes ampersand symbols that are NOT HTML Entities
CREATE FUNCTION [dbo].[udf_EscapeAmpersand] (@strInput NVARCHAR(MAX))
RETURNS NVARCHAR(MAX) AS
BEGIN

	DECLARE @strSearch NVARCHAR(max) = @strInput;
	DECLARE @strOutput NVARCHAR(max) = '';

	DECLARE @intCurrentPatIndex INT;
	DECLARE @intTwoLetterHTMLEntity INT;
	DECLARE @intThreeLetterHTMLEntity INT;
	DECLARE @intFourLetterHTMLEntity INT;
	DECLARE @intFiveLetterHTMLEntity INT;

	DECLARE @intMinHTMLEntity INT;

	WHILE PatIndex('%&[^\s]%', @strSearch) > 0 
	BEGIN
		SET @intCurrentPatIndex = PatIndex('%&[^\s]%', @strSearch);

		SET @intTwoLetterHTMLEntity = PatIndex('%&[^ ][^ ];%', @strSearch);
		SET @intThreeLetterHTMLEntity = PatIndex('%&[^ ][^ ][^ ];%', @strSearch);
		SET @intFourLetterHTMLEntity = PatIndex('%&[^ ][^ ][^ ][^ ];%', @strSearch);
		SET @intFiveLetterHTMLEntity = PatIndex('%&[^ ][^ ][^ ][^ ];%', @strSearch);

		WITH intHTMLEntities_cte AS (
			SELECT @intTwoLetterHTMLEntity AS Value 
			UNION 
			SELECT @intThreeLetterHTMLEntity AS Value 
			UNION 
			SELECT @intFourLetterHTMLEntity AS Value 
			UNION 
			SELECT @intFiveLetterHTMLEntity AS Value 
		)
		SELECT @intMinHTMLEntity = CAST(MIN(Value) AS INT) 
		FROM intHTMLEntities_cte
		WHERE Value !=0;

		IF(@intCurrentPatIndex < COALESCE(@intMinHTMLEntity, 0) OR COALESCE(@intMinHTMLEntity, 0) = 0)
			BEGIN
				-- PATINDEX character is a & symbol not a html entity

				-- set this & symbol to &amp;
				SET @strOutput += SUBSTRING(@strSearch, 1, @intCurrentPatIndex - 1) + '&amp;';
				-- set search string to everything after this symbol
				SET @strSearch = SUBSTRING(@strSearch, @intCurrentPatIndex+1, LEN(@strSearch));
			END
		ELSE
			BEGIN
				-- PATINDEX character is a html entity

				-- set fixed search string to existing fixed search string plus up to this & symbol
				SET @strOutput += SUBSTRING(@strSearch, 1, @intCurrentPatIndex);
				-- set search string to everything after this symbol
				SET @strSearch = SUBSTRING(@strSearch, @intCurrentPatIndex + 1, LEN(@strSearch));
			END

	END  

	SET @strOutput += @strSearch;
	
	RETURN @strOutput;
END