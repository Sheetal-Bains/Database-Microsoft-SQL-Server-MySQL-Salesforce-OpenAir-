﻿USE [xxx]
GO
/****** Object:  StoredProcedure [dbo].[SP_AR_DataLoads]    Script Date: 1/12/2024 1:08:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_AR_DataLoads]

AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
	
	/*insert data to [xxx].[dbo].[xxxxx]*/
	TRUNCATE TABLE [xxx].[dbo].[T_Dim_xxxxx]
	INSERT INTO [xxx].[dbo].[T_Dim_xxxxx]([Client Name],[Customer],[ID], [T_Date_Pulled])
	
	SELECT ACL.[Client Name], ACL.[Customer #][Customer],SUBSTRING(ACL.[Customer #], CHARINDEX('-',ACL.[Customer #])+1, LEN(ACL.[Customer #])) [ID]   
	,CAST(GETDATE() AS DATE)
	FROM [xx].[dbo].[xxxxx] ACL	
	SELECT 'T_Dim_xxxxx',COUNT(*) FROM [xxx].[dbo].[T_Dim_xxxxx]
	
	/*Fetch Maxdate Email sent and insert data to [xxx].[dbo].[xxxx]*/	
	SELECT ARC.[ID][NetSuite Customer ID],MAX(ACPR.[Email Sent]) [Max_Email_Sent] 
	INTO #tempLast_Contact_Date
	FROM [xx].[dbo].[xxxx] ACPR 
	LEFT JOIN [xxx].[dbo].[T_Dim_xxxxx] ARC ON ACPR.[Client Name] = ARC.[Client Name]
	GROUP BY ARC.[ID]
	/*insert data to [xxx].[dbo].[T_Dim_xxxx]*/
	TRUNCATE TABLE [xxx].[dbo].[T_Dim_xxxx]
	INSERT INTO [xxx].[dbo].[T_Dim_xxxx]
	(	
		[Region] ,[Client Name] ,[Invoice #] ,[Invoice Date] ,[Due Date] ,[Email Sent] ,[Amount Paid] ,[Balance] ,[Status] ,[Contact Name] ,[Email] ,[Client Executive] ,
		[Client Invoiced ID] ,[Id] ,[Message Id] ,[Related To ID] ,[NetSuite Customer ID], [Last_Contact], [T_Date_Pulled]  
	)
	SELECT ACPR.[Region] ,ACPR.[Client Name] ,ACPR.[Invoice #] ,ACPR.[Invoice Date] ,ACPR.[Due Date] ,ACPR.[Email Sent] ,ACPR.[Amount Paid] ,ACPR.[Balance] ,ACPR.[Status] ,
	ACPR.[Contact Name] ,ACPR.[Email] ,ACPR.[Client Executive] ,ACPR.[Client Invoiced ID] ,	ACPR.[Id] ,ACPR.[Message Id] ,ACPR.[Related To ID],ARC.[ID][NetSuite Customer ID],
	LCD.[Max_Email_Sent] [Last_Contact], CAST(GETDATE() AS DATE)
	FROM [xx].[dbo].[xxxx] ACPR 
	LEFT JOIN [xxx].[dbo].[T_Dim_xxxxx] ARC ON ACPR.[Client Name] = ARC.[Client Name]
	LEFT JOIN #tempLast_Contact_Date LCD ON LCD.[NetSuite Customer ID] = ARC.ID
	

	SELECT 'xxxx',COUNT(*) FROM [xxx].[dbo].[T_Dim_xxxx]
	TRUNCATE TABLE [xxx].[dbo].[xxxx]
	INSERT INTO [xxx].[dbo].[xxxx] 
	(
		[Name] ,[Customer #] ,[Subsidiary] ,[Name1] ,[Currency] ,[Date] ,[Due Date],[Invoice #] ,[Payment Terms] ,
		[Is Percent] ,[Late Fee Percentage] ,[Late Fee Schedule Name] ,[Balance] ,[Amount Paid] ,[NetSuite Customer ID],[T_Date_Pulled]
	)
	SELECT ARL.[Name] ,ARL.[Customer #] ,ARL.[Subsidiary] ,ARL.[Name1] ,ARL.[Currency] ,ARL.[Date] ,ARL.[Due Date],ARL.[Invoice #] ,ARL.[Payment Terms] ,
		ARL.[Is Percent] ,ARL.[Late Fee Percentage] ,ARL.[Late Fee Schedule Name] ,ARL.[Balance] ,ARL.[Amount Paid] ,ARC.ID [NetSuite Customer ID],CAST(GETDATE() AS DATE)
	FROM [xx].[dbo].[xxxx] ARL
	LEFT JOIN [xxx].[dbo].[T_Dim_xxxxx] ARC ON ARL.[Name] = ARC.[Client Name] 

	SELECT 'xxxx',COUNT(*) FROM [xxx].[dbo].[xxxx]

	select DR.forex_date,DR.[symbol],DR.[custom_usd],DR.[custom_gbp], DR.[custom_cad]   
	INTO #tempDaily_fxRates
	FROM [dbo].[Dim_Daily_Fx_Rates]  DR WHERE DR.[symbol] = 'USD' AND DR.forex_date is not null 
	SELECT '#tempDaily_fxRates',COUNT(*) FROM #tempDaily_fxRates

	;WITH CTE ([forex_date] , [symbol], [custom_usd],[custom_gbp],[custom_cad],DuplicateCount)
	AS  (
			SELECT CAST([forex_date] AS date), [symbol],[custom_usd],	[custom_gbp],[custom_cad], 
			ROW_NUMBER() OVER(PARTITION BY CAST([forex_date] AS date), [symbol] ORDER BY CAST([forex_date] AS date)
		) AS DuplicateCount
		FROM #tempDaily_fxRates
	)
	DELETE FROM CTE
	WHERE DuplicateCount > 1;
   	
	DELETE FROM [dbo].[xxxxx] WHERE YEAR([Date Pulled]) in (YEAR(GETDATE()), YEAR(GETDATE()-1))
	
	INSERT INTO [dbo].[xxxxx] 
				(
					[Company Name] ,[Client] ,[NetSuite Client Internal ID] ,[ID] ,[Account Executive] ,[Location] ,[Transaction Type] ,[Currency] ,[Subsidiary] ,
					[Payment Term] ,[Due Date] ,[Document Number] ,[Transaction Date] ,[Current  Open Balance] ,[(30)  Open Balance] ,[(60)  Open Balance] ,
					[(90)  Open Balance] ,[(>90)  Open Balance] ,[Total  Open Balance] ,[Date Pulled] ,[DAR Flag] ,[DAR Days Bucket] ,[Report_Flag] ,
					[DAR_Days_Bucket_Order] ,[ContactDate] ,[Last_Next7Days_Bucket] ,[EOM_Column] ,[Currency_Custom] ,[Local_TotalBalance], [T_Date_Pulled]  
				)

	SELECT AR.[Company Name] ,AR.[Client] ,AR.[NetSuite Client Internal ID] ,AR.[ID] ,AR.[Account Executive] ,AR.[Location] ,AR.[Transaction Type] ,AR.[Currency] ,
	AR.[Subsidiary] ,AR.[Payment Term] ,AR.[Due Date] ,AR.[Document Number] ,AR.[Transaction Date] ,AR.[Current  Open Balance] ,AR.[(30)  Open Balance] ,
	AR.[(60)  Open Balance] ,AR.[(90)  Open Balance] ,AR.[(>90)  Open Balance] ,AR.[Total  Open Balance] ,AR.[Date Pulled] ,
	CASE WHEN AR.[Due Date] < AR.[Date Pulled] THEN 'DAR' ELSE 'AR' END [DAR Flag],
	CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) > 0 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 30 THEN '0-30 Days' 
	ELSE CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= 31 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 60 THEN '31-60 Days' 
	ELSE CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= 61 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 90 THEN '61-90 Days' 
	ELSE CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= 91  THEN 'Greater than 90 Days' ELSE 'Current' END END END END [DAR Days Bucket],
	CASE WHEN AR.[Total  Open Balance] > 0 THEN 'Include' ELSE 'Exclude' END [Report_Flag],
	CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) > 0 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 30 THEN '0-30' 
	ELSE CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= 31 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 60 THEN '31-60' 
	ELSE CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= 61 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 90 THEN '61-90' 
	ELSE CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= 91  THEN '>90' ELSE 'Current' END END END END [DAR_Days_Bucket_Order],APR.Max_Email_Sent [ContactDate], 
	CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 0 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= -7 THEN 'Going to be Delq. in 7 Days' 
	ELSE CASE WHEN DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) >= 0 AND DATEDIFF(DAY, AR.[Due Date],AR.[Date Pulled] ) <= 7 THEN 'Recent Delq. in Next 7 Days' 
	ELSE 'NA' END END [Last_Next7Days_Bucket],
	CASE WHEN YEAR(AR.[Date Pulled]) = YEAR(GETDATE()) AND MONTH(AR.[Date Pulled]) = MONTH(GETDATE()) THEN AR.[Date Pulled] ELSE EOMONTH(AR.[Date Pulled]) END EOM_Column ,
	CASE WHEN AR.Currency = 'EUR' THEN 'GBP' ELSE AR.Currency END [Currency_Custom],
	CASE WHEN AR.Currency = 'USD' THEN AR.[Total  Open Balance] * DR.[custom_usd] ELSE 
	CASE WHEN AR.Currency ='GBP' OR AR.Currency ='EUR' THEN  AR.[Total  Open Balance] * DR.[custom_gbp]  ELSE 
	CASE WHEN AR.Currency ='CAD' THEN AR.[Total  Open Balance] * DR.[custom_cad]  END END END [Local_TotalBalance]
	,CAST(GETDATE() AS DATE)
	FROM [xx].[dbo].[xxxx] AR 
	LEFT JOIN #tempLast_Contact_Date APR ON AR.[NetSuite Client Internal ID] = APR.[NetSuite Customer ID]
	LEFT JOIN #tempDaily_fxRates DR ON YEAR(DR.forex_date) =YEAR(AR.[Date Pulled]) 
	AND MONTH(DR.forex_date) = MONTH(AR.[Date Pulled]) AND DAY(DR.forex_date) = DAY(AR.[Date Pulled])
	WHERE AR.Subsidiary NOT IN ('DE-Germany','GY- Guernesy','NL-Netherlands','US Acquisitions, Inc.') AND  DR.[symbol] = 'USD' AND DR.forex_date is not null 
	AND AR.[ID] NOT IN (select ID from [xxx].[dbo].[T_Dim_AR_ConduentClients_Exclude])
	AND YEAR(AR.[Date Pulled]) NOT IN(1899) AND YEAR([Date Pulled]) in (YEAR(GETDATE()), YEAR(GETDATE()-1)) 
	AND AR.[NetSuite Client Internal ID] NOT IN ( 34603 ,1478237)
	AND AR.[Company Name] NOT like 'Carrier%' and AR.[Company Name] not like 'RightOpt%' and AR.[Company Name] !='' 
	AND CONCAT(YEAR([Date Pulled]),MONTH([Date Pulled])) NOT IN (20219)
	
	SELECT '[xxxx]',COUNT(*) FROM [dbo].[xxxxx] 

	SELECT MAX([Date Pulled])[Max_Date_Pulled] INTO #temp_Max_Date  FROM  [dbo].[xxxxx]
	WHERE YEAR([Date Pulled]) = YEAR(GETDATE()) AND MONTH([Date Pulled]) = MONTH(GETDATE())

	UPDATE [dbo].[xxxxx] SET EOM_Column = NULL WHERE EOM_Column != [Date Pulled]
	
	UPDATE [dbo].[xxxxx] SET EOM_Column = NULL WHERE YEAR([Date Pulled]) = YEAR(GETDATE()) AND MONTH([Date Pulled]) = MONTH(GETDATE())
	
	UPDATE [dbo].[xxxxx] SET EOM_Column = Max_Date_Pulled 
	FROM #temp_Max_Date MD INNER JOIN [dbo].[xxxxx] AD  ON AD.[Date Pulled] = MD.Max_Date_Pulled
	WHERE YEAR([Date Pulled]) = YEAR(GETDATE()) AND MONTH([Date Pulled]) = MONTH(GETDATE())
	
	TRUNCATE TABLE [xxx].[dbo].[xxxx] 
    INSERT INTO [xxx].[dbo].[xxxx] ([ClientName],[Client - NetSuite Customer ID],[T_Date_Pulled])
    SELECT [ClientName]
      ,[Client - NetSuite Customer ID]
      ,CAST(GETDATE() AS DATE)
    FROM [xx].[dbo].[xxxx]
	
	DROP TABLE #tempLast_Contact_Date
	DROP TABLE #tempDaily_fxRates
	DROP TABLE #temp_Max_Date

END

