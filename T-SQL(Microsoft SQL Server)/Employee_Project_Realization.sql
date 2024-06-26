﻿USE [T_Ops_DW]
GO
/****** Object:  StoredProcedure [dbo].[SSP_Transform_EToT_DO_Employee_Project_Realization_Dataset_Process]    Script Date: 1/12/2024 1:12:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SSP_Transform_EToT_DO_Employee_Project_Realization_Dataset_Process]
(
	@startdate DATE = NULL,
	@enddate DATE = NULL
)
AS
BEGIN
	CREATE TABLE #TempEEDetailsDataset
	(
		[EE_WIN] VARCHAR(20), 
		[EMP_STATUS] VARCHAR(50),
		[FULL_PART_TIME] VARCHAR(50),
		[NetSuite_LOC_Code] INT,
		[Department] VARCHAR(50),
		[Practice] VARCHAR(50),
		[Termination Date] DATE,
		[EMP_TYPE] VARCHAR(50),
		[Salary Grade]  VARCHAR(50),
		[EE_Name] VARCHAR(50),
		[EE Netsuite Location] VARCHAR(50),
		[country] VARCHAR(50)
	) 

	CREATE TABLE #TempUserIdUserDataset
	(
		[User ID] VARCHAR(20), 
		[User Name] VARCHAR(50),
		[User_ID] VARCHAR(20)
	)

	CREATE TABLE #TempEmployeeBillRateDataset
	(
		[nickname] nvarchar(50), 
		[Hourly rate (USD)] decimal(17,6),
		[Month] INT,
		[Year] INT,
		[Client - NetSuite Customer ID] VARCHAR(50),
		[Client Name] VARCHAR(100),
	)
	CREATE TABLE #TempEmployeeBillHrsDataset
	(
		[Client - Country] VARCHAR(50), 
		[Client - Region : Market_departmentId] VARCHAR(50),
		[User - User ID] VARCHAR(50),
		[Client - Client code] VARCHAR(50),
		[Project code] VARCHAR(50),
		[Project - Practice : SubPractice] VARCHAR(50), 
		[Time category] VARCHAR(50),
		[Period] VARCHAR(50) ,
		[Project - Name_ProjectId] VARCHAR(50),
		[NetSuite Project ID] VARCHAR(50), 
		[Client - NetSuite Customer ID] VARCHAR(50),
		[T1 Hours] VARCHAR(50),
		[T2 Hours] VARCHAR(50),
		[Time (Hours)] VARCHAR(50),
		[Project - Name] VARCHAR(500),
		[Project stage] VARCHAR(50),
		[Client Name] VARCHAR(100),
		[Recurring Type] VARCHAR(50),
		[Project Category] VARCHAR(500),
		[Industry] VARCHAR(100),
		[Opp ID] VARCHAR(100),
		[Client- Geo] VARCHAR(50),
		[Client - SFDC Account ID] VARCHAR(100),
		[Client - Region] VARCHAR(50),
		[Client- Market]  VARCHAR(50),
		[PM WIN ID] VARCHAR(50),
		[Project Manager] VARCHAR(50),
		[CE Win ID] VARCHAR(50),
		[Client Executive] VARCHAR(50),
		[ES Win ID] VARCHAR(50),
		[Executive Sponsor] VARCHAR(50),
		[PM Department] VARCHAR(100),
	)
	CREATE TABLE #TempOpenAirDatasetSource
	(
		[Source] varchar (10),
		[DATE] DATE,
		[Period] VARCHAR(50) ,
		[Year] INT,
		[Client - NetSuite Customer ID] VARCHAR(50),
		[Client Name] VARCHAR(100),
		[Parent Client] VARCHAR(200),
		[Client- Geo] VARCHAR(50),
		[Client - Region] VARCHAR(50),
		[Client- Market]  VARCHAR(50),
		[Client - SFDC Account ID] VARCHAR(100),
		[NetSuite Project ID] VARCHAR(50),
		[Project - Name] VARCHAR(500),
		[Customer ID- Client Code+ Netsuite Project ID] VARCHAR(500),
		[Client Name + Project Name] VARCHAR(500),
		[Opp ID] VARCHAR(100),
		[Industry] VARCHAR(100),
		[Recurring Type] VARCHAR(50),
		[CE Win ID] VARCHAR(50),
		[Client Executive] VARCHAR(50),
		[PM WIN ID] VARCHAR(50),
		[Project Manager] VARCHAR(50),
		[PM Department] VARCHAR(100),
		[Project Category] VARCHAR(500),
		[Senior Client Executive] VARCHAR(100),
		[Executive Sponsor] VARCHAR(100),
		[Client Tier]  VARCHAR(100),
		[Project - Practice ] VARCHAR(100),
		[Project - SubPractice] VARCHAR(100),
		[Project stage] VARCHAR(50),
		[EEWIN ID (User-User ID)]  VARCHAR(20) ,
		[EE Name] VARCHAR(50),
		[EE Department] VARCHAR(50),
		[EE Netsuite Location] VARCHAR(50),	
		[EE Country] VARCHAR(50),
		[EE Practice : Subpractice] VARCHAR(100),
		[Salary Grade] VARCHAR(50),
		[Termination Date] DATE,
		[EMP_STATUS] VARCHAR(50),
		[FULL_PART_TIME] VARCHAR(50),
		[EMP_TYPE] VARCHAR(50) ,
		[Hours type] VARCHAR(50),
		[T1 Hours] VARCHAR(50),
		[T2 Hours] VARCHAR(50),
		[Total Billable Hours] VARCHAR(50),  
		[EE full time rate] DECIMAL(10,2),
		[EE T1 standard charges]  DECIMAL(10,2),
		[EE T2 standard charges]  DECIMAL(10,2),
		[EE standard charges] DECIMAL(10,2),
		[Combination-CusIDClientCode+NetsuiteProID+Year] NVARCHAR(500)
	)
	CREATE TABLE #TempAdaptiveClientRevenueDataset
	(
		[startdate] date, 
		[enddate] date, 
		[Customer ID - Client Code] nvarchar(50), 
		[Sum_Type_1_Revenue] decimal(17,2),
		[Sum_Type_2_Revenue] decimal(17,2),
		[Total_Revenue] decimal(17,2),
		[Month] INT,
		[Year] INT,
		[NetSuite Project ID] INT,
		[NetSuite_Project_ID_Flag] INT,
		[Profit] decimal(17,2)
	)
	CREATE TABLE #TempClientEmployeeHrsDataset_with_NetSuiteProjectID
	(
		[startdate] date, 
		[enddate] date, 
		[Customer ID - Client Code] nvarchar(50), 
		[Sum_Type_1_Hrs] decimal(17,2),
		[Sum_Type_2_Hrs] decimal(17,2),
		[Total_Hrs] decimal(17,2),
		[Month] INT,
		[Year] INT,
		[NetSuite Project ID] INT,
		[NetSuite_Project_ID_Flag] INT
	)
	CREATE TABLE #TempClientEmployeeHrsDataset_without_NetSuiteProjectID
	(
		[startdate] date, 
		[enddate] date, 
		[Customer ID - Client Code] nvarchar(50), 
		[Sum_Type_1_Hrs] decimal(17,2),
		[Sum_Type_2_Hrs] decimal(17,2),
		[Total_Hrs] decimal(17,2),
		[Month] INT,
		[Year] INT,
		[NetSuite Project ID] INT,
		[NetSuite_Project_ID_Flag] INT
	)
	CREATE TABLE #TempClientAvgRateAgainstRevenueDataset
	(
		[startdate] date, 
		[enddate] date, 
		[Customer ID - Client Code] nvarchar(50), 
		[Type_1_Avg_Rate] decimal(17,2),
		[Type_2_Avg_Rate] decimal(17,2),
		[Total_Hrs_Avg_Rate] decimal(17,2),
		[Sum_Type_1_Hrs] decimal(17,2),
		[Sum_Type_2_Hrs] decimal(17,2),
		[Total_Hrs] decimal(17,2),
		[Month] INT,
		[Year] INT,
		[NetSuite Project ID] INT,
		[Sum_Type_1_Revenue] decimal(17,2),
		[Sum_Type_2_Revenue] decimal(17,2),
		[Total_Revenue] decimal(17,2),
		[Profit] decimal(17,2)
	)

	CREATE TABLE #TempOpenAirDatasetSourceCombineWithAdaptive
	(
		[DATE] DATE,
		[CE Win ID] VARCHAR(50),
		[Client Executive] VARCHAR(50),
		[PM WIN ID] VARCHAR(50),
		[Project Manager] VARCHAR(50),
		[PM Department] VARCHAR(100),
		[Project Category] VARCHAR(500),
		[Project stage] VARCHAR(50),
		[Combination-CusIDClientCode+NetsuiteProID+Year] NVARCHAR(500),
		[Client - NetSuite Customer ID] VARCHAR(100)
	)
	CREATE TABLE #TempOpenAirDatasetSourceCombineWithAdaptiveWithoutNetSuiteProjectId
	(
		[DATE] DATE,
		[CE Win ID] VARCHAR(50),
		[Client Executive] VARCHAR(50),
		[PM WIN ID] VARCHAR(50),
		[Project Manager] VARCHAR(50),
		[PM Department] VARCHAR(100),
		[Project Category] VARCHAR(500),
		[Project stage] VARCHAR(50),
		[Combination-CusIDClientCode+NetsuiteProID+Year] NVARCHAR(500),
		[Client - NetSuite Customer ID] VARCHAR(100)
	)

	BEGIN TRY
		IF(@startdate IS NULL AND @enddate IS  NULL )
			BEGIN
				SET @startdate = CAST (DATEADD(mm, DATEDIFF(m,0,GETDATE())-3,0) AS DATE)
				SET @enddate = EOMONTH(CAST(DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) AS DATE))
			END
		IF(@startdate IS NOT NULL AND @enddate IS NOT NULL )
			BEGIN
			--All employees detail information Report
			TRUNCATE TABLE #TempEEDetailsDataset
			INSERT INTO #TempEEDetailsDataset 
						(
							[EE_WIN],[EMP_STATUS],[FULL_PART_TIME],[NetSuite_LOC_Code],[Department],[Practice],[Termination Date],[EMP_TYPE],[Salary Grade],
							[EE_Name],[EE Netsuite Location],[country]
						) 
						EXEC [dbo].[SSP_Transform_EToT_Employee_Details]
			--User User ID Report
			TRUNCATE TABLE #TempUserIdUserDataset 
			INSERT INTO #TempUserIdUserDataset 
						(
							[User ID],[User Name],[User_ID]
						) 
						EXEC [dbo].[SSP_Transform_EToT_DO_Userid_Username]
			--Employee Bill Rate of every 2nd day of month 
			TRUNCATE TABLE #TempEmployeeBillRateDataset 
			INSERT INTO #TempEmployeeBillRateDataset 
						(
							[nickname], [Hourly rate (USD)], [Month],[Year]
						) 
						EXEC [dbo].[SSP_Transform_EToT_DO_Employee_Bill_Rate]  @Flag = 'DO'
			--Employee Bill Hrs  
			TRUNCATE TABLE #TempEmployeeBillHrsDataset 
			INSERT INTO #TempEmployeeBillHrsDataset 
						(
							[Client - Country],[Client - Region : Market_departmentId],[User - User ID],[Client - Client code],[Project code],
							[Project - Practice : SubPractice], [Time category],[Period],[Project - Name_ProjectId],
							[NetSuite Project ID], [Client - NetSuite Customer ID],[T1 Hours],[T2 Hours],[Time (Hours)],[Project - Name],[Project stage],
							[Client Name],[Recurring Type],[Project Category],[Industry],[Opp ID],[Client- Geo],[Client - SFDC Account ID],[Client - Region], 
							[Client- Market],[PM WIN ID],[Project Manager],[CE Win ID],[Client Executive],[ES Win ID],[PM Department]
					   )
			EXEC [dbo].[SSP_Transform_EToT_DO_Employee_Monthly_BillableHrs] @startdate = @startdate , @enddate = @enddate
			TRUNCATE TABLE #TempOpenAirDatasetSource
			INSERT INTO #TempOpenAirDatasetSource 
			( 
				[Source],[DATE],[Period],[Year],[Client - NetSuite Customer ID],[Client Name],[Parent Client] ,	[Client- Geo] ,	[Client - Region],[Client- Market],
				[Client - SFDC Account ID],[NetSuite Project ID],[Project - Name],[Customer ID- Client Code+ Netsuite Project ID],[Client Name + Project Name],[Opp ID],
				[Industry],[Recurring Type],[CE Win ID],[Client Executive] ,[PM WIN ID],[Project Manager],[PM Department] ,[Project Category],
				[Senior Client Executive],[Executive Sponsor] ,[Client Tier] ,[Project - Practice ],[Project - SubPractice],[Project stage],
				[EEWIN ID (User-User ID)],[EE Name],[EE Department],[EE Netsuite Location],[EE Country],[EE Practice : Subpractice], 
				[Salary Grade],[Termination Date],[EMP_STATUS],[FULL_PART_TIME],[EMP_TYPE],[Hours type],[T1 Hours],[T2 Hours],[Total Billable Hours],
				[EE full time rate],[EE T1 standard charges],[EE T2 standard charges],[EE standard charges],[Combination-CusIDClientCode+NetsuiteProID+Year] 
			)

			SELECT 'OpenAir' [Source] ,CAST (concat([Period] , '-01') AS DATE) [DATE] ,EBH.[Period] AS [Period], 
			SUBSTRING(EBH.[Period], 0,CHARINDEX('-', EBH.[Period])) AS [Year] ,EBH.[Client - NetSuite Customer ID],	EBH.[Client Name],PT.[Parent Client] ,
			EBH.[Client- Geo],EBH.[Client - Region], EBH.[Client- Market],EBH.[Client - SFDC Account ID],
			EBH.[NetSuite Project ID],EBH.[Project - Name],CONCAT(EBH.[Client - NetSuite Customer ID],ISNULL(TRIM([NetSuite Project ID]),0))[Customer ID- Client Code+ Netsuite Project ID],
			concat(EBH.[Client Name],'-',EBH.[Project - Name])[Client Name + Project Name],
			EBH.[Opp ID],EBH.[Industry],EBH.[Recurring Type],EBH.[CE Win ID],EBH.[Client Executive],EBH.[PM WIN ID],EBH.[Project Manager],EBH.[PM Department],
			EBH.[Project Category],FG.[Sr Client Exec][Senior Client Executive],FG.[Exec Sponsor][Executive Sponsor],
			CASE WHEN PT.[Client Tier] IS NULL OR PT.[Client Tier] = '' THEN 'Other Clients' ELSE PT.[Client Tier] END AS [Client Tier],
			CASE WHEN CHARINDEX(':',  [Project - Practice : SubPractice] )-1 <= 0 THEN [Project - Practice : SubPractice] 
			ELSE LEFT([Project - Practice : SubPractice],CHARINDEX(':',  [Project - Practice : SubPractice])-1) END AS [Project - Practice ],
			CASE WHEN CHARINDEX(':',  [Project - Practice : SubPractice] )-1 <= 0 THEN [Project - Practice : SubPractice] 
			ELSE SUBSTRING([Project - Practice : SubPractice], CHARINDEX(':',  [Project - Practice : SubPractice] )+1, LEN([Project - Practice : SubPractice])) END AS [Project - SubPractice],
			EBH.[Project stage],EED.[EE_WIN] [EEWIN ID (User-User ID)],EED.[EE_Name] [EE Name],EED.[Department] [EE Department],EED.[EE Netsuite Location],	
			EED.[country] [EE Country],EED.[Practice] [EE Practice : Subpractice],EED.[Salary Grade],EED.[Termination Date],LEFT(UPPER(EED.[EMP_STATUS]),1)[EMP_STATUS],
			EED.[FULL_PART_TIME],UPPER(LEFT(EED.[EMP_TYPE],3))[EMP_TYPE],[Time category] [Hours type],EBH.[T1 Hours],EBH.[T2 Hours],
			EBH.[Time (Hours)] [Total Billable Hours] , CAST(EBR.[Hourly rate (USD)] AS DECIMAL(10,2)) [EE full time rate],
			CAST(ISNULL(EBH.[T1 Hours],0)*EBR.[Hourly rate (USD)] AS DECIMAL(10,2)) AS [EE T1 standard charges],
			CAST(ISNULL(EBH.[T2 Hours],0)*EBR.[Hourly rate (USD)] AS DECIMAL(10,2)) AS [EE T2 standard charges],
			CAST(ISNULL(EBH.[Time (Hours)],0)*EBR.[Hourly rate (USD)] AS DECIMAL(10,2))  AS [EE standard charges],
			CONCAT(EBH.[Client - NetSuite Customer ID],ISNULL(EBH.[NetSuite Project ID],0),SUBSTRING(EBH.[Period], 0,CHARINDEX('-', EBH.[Period])))[Combination-CusIDClientCode+NetsuiteProID+Year]
			FROM #TempEEDetailsDataset  EED 
			INNER JOIN #TempEmployeeBillHrsDataset EBH ON EED.[EE_WIN] = EBH.[User - User ID]
			LEFT JOIN #TempEmployeeBillRateDataset EBR ON EED.[EE_WIN] = EBR.[nickname] AND SUBSTRING(EBH.[Period], CHARINDEX('-', EBH.[Period])+1,LEN(EBH.[Period])) = EBR.[Month]	
			AND SUBSTRING(EBH.[Period], 0,CHARINDEX('-', EBH.[Period])) = EBR.[Year]
			LEFT JOIN [dbo].[xxx] PT ON EBH.[Client - NetSuite Customer ID] = PT.[Client - NetSuite Customer ID]
			LEFT JOIN [dbo].[xxx] FG ON EBH.[Client Name] = FG.[ClientName]
			ORDER BY EBH.[Client - NetSuite Customer ID] ASC
			
			TRUNCATE TABLE #TempAdaptiveClientRevenueDataset 
			INSERT INTO #TempAdaptiveClientRevenueDataset 
			(
				[startdate],[enddate],[Customer ID - Client Code],[Sum_Type_1_Revenue],[Sum_Type_2_Revenue],[Total_Revenue],
				[NetSuite Project ID],[NetSuite_Project_ID_Flag],[Profit] 
				--[Month],[Year],
			) 
			EXEC SSP_Transform_EToT_DO_AdaptiveClientRevenue_Dataset @startdate = @startdate , @enddate = @enddate
			
			TRUNCATE TABLE #TempClientEmployeeHrsDataset_with_NetSuiteProjectID 
			INSERT INTO #TempClientEmployeeHrsDataset_with_NetSuiteProjectID 
			(
				[startdate],[enddate],[Customer ID - Client Code],[Sum_Type_1_Hrs],[Sum_Type_2_Hrs],[Total_Hrs],--[Month],[Year],
				[NetSuite Project ID],[NetSuite_Project_ID_Flag] 
			)
			SELECT @startdate [startdate],@enddate [enddate],[Client - NetSuite Customer ID],SUM(CAST([T1 Hours] AS decimal(10,2)))[T1 Hours],
			SUM(CAST([T2 Hours] AS decimal(10,2)))[T2 Hours],SUM(CAST([Total Billable Hours] AS decimal(10,2)))[Total Billable Hours],--MONTH([Date]),YEAR([Date]),
			[NetSuite Project ID],1
			FROM #TempOpenAirDatasetSource WHERE ([NetSuite Project ID] is not null AND [NetSuite Project ID] <> 0)
			GROUP BY [Client - NetSuite Customer ID],[NetSuite Project ID]--,MONTH([Date]),YEAR([Date])
			
			TRUNCATE TABLE #TempClientEmployeeHrsDataset_without_NetSuiteProjectID 
			INSERT INTO #TempClientEmployeeHrsDataset_without_NetSuiteProjectID 
			(
				[startdate],[enddate],[Customer ID - Client Code],[Sum_Type_1_Hrs],[Sum_Type_2_Hrs],[Total_Hrs],--[Month],[Year],
				[NetSuite Project ID],[NetSuite_Project_ID_Flag] 
			)
			SELECT @startdate [startdate],@enddate [enddate],[Client - NetSuite Customer ID],SUM(CAST([T1 Hours] AS decimal(10,2)))[T1 Hours],
			SUM(CAST([T2 Hours] AS decimal(10,2)))[T2 Hours],SUM(CAST([Total Billable Hours] AS decimal(10,2)))[Total Billable Hours],--MONTH([Date]),YEAR([Date]),
			[NetSuite Project ID],0
			FROM #TempOpenAirDatasetSource WHERE ([NetSuite Project ID] is null OR [NetSuite Project ID] = 0)
			GROUP BY [Client - NetSuite Customer ID],[NetSuite Project ID]--,MONTH([Date]),YEAR([Date])
			
			TRUNCATE TABLE #TempOpenAirDatasetSourceCombineWithAdaptive
			INSERT INTO #TempOpenAirDatasetSourceCombineWithAdaptive
			(
				[DATE] ,[CE Win ID],[Client Executive],[PM WIN ID],[Project Manager],[PM Department],[Project Category],--[Project stage],
				[Combination-CusIDClientCode+NetsuiteProID+Year],[Client - NetSuite Customer ID]
			)
			SELECT DISTINCT [DATE] ,[CE Win ID],[Client Executive],[PM WIN ID],[Project Manager],[PM Department],[Project Category],--[Project stage],
				   [Combination-CusIDClientCode+NetsuiteProID+Year]	,[Client - NetSuite Customer ID] 
			FROM #TempOpenAirDatasetSource

			TRUNCATE TABLE #TempOpenAirDatasetSourceCombineWithAdaptiveWithoutNetSuiteProjectId
			INSERT INTO #TempOpenAirDatasetSourceCombineWithAdaptiveWithoutNetSuiteProjectId
			(
				[DATE] ,[CE Win ID],[Client Executive],--[PM WIN ID],[Project Manager],[PM Department],
				[Project Category],--[Project stage],
				[Combination-CusIDClientCode+NetsuiteProID+Year],[Client - NetSuite Customer ID]
			)
			SELECT DISTINCT [DATE] ,[CE Win ID],[Client Executive],--[PM WIN ID],[Project Manager],[PM Department],
			[Project Category],--[Project stage],
				   [Combination-CusIDClientCode+NetsuiteProID+Year]	,[Client - NetSuite Customer ID] 
			FROM #TempOpenAirDatasetSource 
			WHERE ([NetSuite Project ID] is null OR [NetSuite Project ID] = 0)

			IF((SELECT COUNT(*) FROM #TempClientEmployeeHrsDataset_with_NetSuiteProjectID) > 0)
			BEGIN
				TRUNCATE TABLE #TempClientAvgRateAgainstRevenueDataset
				INSERT INTO #TempClientAvgRateAgainstRevenueDataset
				(
					[startdate],[enddate],[Customer ID - Client Code],[Type_1_Avg_Rate],[Type_2_Avg_Rate],[Total_Hrs_Avg_Rate],[Sum_Type_1_Hrs],[Sum_Type_2_Hrs],[Total_Hrs],
					--[Month],[Year],
					[NetSuite Project ID],[Sum_Type_1_Revenue],[Sum_Type_2_Revenue],[Total_Revenue],[Profit]
				)
				SELECT [startdate],[enddate],[Customer ID - Client Code],[Type_1_Avg_Rate],[Type_2_Avg_Rate],[Total_Hrs_Avg_Rate],[Sum_Type_1_Hrs],[Sum_Type_2_Hrs],[Total_Hrs],
				--[Month],[Year],
				[NetSuite Project ID],[Sum_Type_1_Revenue],[Sum_Type_2_Revenue],[Total_Revenue],[Profit]
				FROM 
				(
					SELECT CEHD.startdate,CEHD.enddate,CEHD.[Customer ID - Client Code],CEHD.[Sum_Type_1_Hrs],ACRD.[Sum_Type_1_Revenue],
					CASE WHEN (CEHD.Sum_Type_1_Hrs <> 0 AND ACRD.Sum_Type_1_Revenue <> 0) THEN CAST((ACRD.Sum_Type_1_Revenue/CEHD.Sum_Type_1_Hrs) AS decimal(10,2)) ELSE 0 END [Type_1_Avg_Rate],
					CEHD.[Sum_Type_2_Hrs],ACRD.[Sum_Type_2_Revenue],
					CASE WHEN (CEHD.Sum_Type_2_Hrs <> 0 AND ACRD.Sum_Type_2_Revenue <> 0) THEN CAST((ACRD.Sum_Type_2_Revenue/CEHD.Sum_Type_2_Hrs) AS decimal(10,2)) ELSE 0 END [Type_2_Avg_Rate],
					CEHD.[Total_Hrs],ACRD.Total_Revenue,
					CASE WHEN (CEHD.Total_Hrs <> 0 AND ACRD.Total_Revenue <> 0) THEN CAST((ACRD.Total_Revenue/CEHD.Total_Hrs) AS decimal(10,2)) ELSE 0 END [Total_Hrs_Avg_Rate],
					ACRD.[Month], ACRD.[Year],CEHD.[NetSuite Project ID],ACRD.[Profit]
					FROM #TempClientEmployeeHrsDataset_with_NetSuiteProjectID CEHD 
					INNER JOIN #TempAdaptiveClientRevenueDataset ACRD ON CEHD.[Customer ID - Client Code] = ACRD.[Customer ID - Client Code] AND CEHD.[NetSuite Project ID] = ACRD.[NetSuite Project ID]
					WHERE CEHD.[NetSuite_Project_ID_Flag] =  1 AND ACRD.[NetSuite_Project_ID_Flag] = 1
				) Temp

				
			INSERT INTO [dbo].[xxxxxxx]
						(
							[Source] ,[DATE],[Period],[Year],[Client - NetSuite Customer ID] ,[Client Name] ,[Parent Client] ,[Client- Geo] ,[Client - Region] ,[Client- Market]  ,
							[Client - SFDC Account ID] ,[NetSuite Project ID] ,	[Project - Name] ,[Customer ID- Client Code+ Netsuite Project ID] ,	[Client Name + Project Name] ,
							[Opp ID] ,[Tech Opp ID w/ all sub practices], [Tech Opp ID + Subpractice distinct],[Industry] ,[Recurring Type] ,[CE Win ID] ,[Client Executive] ,[PM WIN ID] ,[Project Manager] ,[PM Department] ,[Project Category] ,
							[Senior Client Executive] ,	[Executive Sponsor] ,[Client Tier]  ,[Project - Practice ] ,[Project - SubPractice] ,[Project stage] ,[EEWIN ID (User-User ID)]   ,
							[EE Name] ,	[EE Department] ,[EE Netsuite Location] ,[EE Country] ,	[EE Practice : Subpractice] ,[Salary Grade] ,[Termination Date] ,[EMP_STATUS] ,
							[FULL_PART_TIME] ,[EMP_TYPE]  ,[Hours type] ,[T1 Hours] ,[T2 Hours] ,[Total Billable Hours] , [EE full time rate] ,[EE T1 standard charges]  ,
							[EE T2 standard charges]  ,	[EE standard charges] ,	[Combination-CusIDClientCode+NetsuiteProID+Year],[%Realization T1] ,[%Realization T2] ,	[Total Realization%] ,
							[%  Profit]  ,[T1 Realized Revenue] ,[T2 Realized Revenue] ,[Realized Revenue] ,[Profit Realized] ,[Type 1 Revenue] ,[Type 2 Revenue] ,[Intercompany-TP] ,
							[Other Revenue] ,[Out of Pocket] ,[TIC] ,[Type 1] ,	[Type 2] ,[Write_Downs] ,[TOTAL REVENUE] ,[Implementation Flag] ,[CapEx Costs] ,[Type 2 Billable Cost] ,
							[Type 1 Cost] ,	[Out Of Pocket Expense] ,[Total Expense] ,[Total Profit] 
						)
			SELECT [Source],[DATE],[Period],[Year],[Client - NetSuite Customer ID],[Client Name],[Parent Client],[Client- Geo],[Client - Region],[Client- Market],[Client - SFDC Account ID],[NetSuite Project ID],
				   [Project - Name],[Customer ID- Client Code+ Netsuite Project ID],[client Name + Project Name],[Opp ID], PR.[Tech Opp ID] [Tech Opp ID w/ all sub practices],
				   PRS.[Tech Opp ID] [Tech Opp ID + Subpractice distinct],[Industry] ,[Recurring Type],[CE Win ID],[Client Executive],[PM WIN ID],
				   [Project Manager],[PM Department],[Project Category],[Senior Client Executive],[Executive Sponsor],[Client Tier],[Project - Practice],[Project - SubPractice],[Project stage],
				   [EEWIN ID (User-User ID)],[EE Name],[EE Department],[EE Netsuite Location],[EE Country],[EE Practice : Subpractice],[Salary Grade],
				   CAST([Termination Date] AS VARCHAR(50)) [Termination Date],[EMP_STATUS],[FULL_PART_TIME],
				   [EMP_TYPE],[Hours type],[T1 Hours],[T2 Hours],[Total Billable Hours],[EE full time rate],[EE T1 standard charges],[EE T2 standard charges],[EE standard charges],[Combination-CusIDClientCode+NetsuiteProID+Year],
				   CONCAT(ISNULL([%Realization T1],0),'%')[%Realization T1],CONCAT(ISNULL([%Realization T2],0),'%')[%Realization T2],CONCAT(ISNULL([Total Realization%],0),'%')[Total Realization%],
				   CONCAT(ISNULL([%  Profit],0),'%')[%  Profit],CAST([T1 Realized Revenue] AS decimal(10,2)) [T1 Realized Revenue],CAST([T2 Realized Revenue] AS decimal(10,2)) [T2 Realized Revenue],
				   CAST([Realized Revenue] AS decimal(10,2)) [Realized Revenue],CAST([Profit Realized] AS decimal(10,2)) [Profit Realized],CAST([Type 1 Revenue] AS decimal(10,2)) [Type 1 Revenue],
				   CAST([Type 2 Revenue] AS decimal(10,2)) [Type 2 Revenue],[Intercompany-TP],[Other Revenue],[Out of Pocket],[TIC],[Type 1],[Type 2],CAST([Write_Downs] as decimal(10,2)) [Write_Downs],
				   [TOTAL REVENUE],[Implementation Flag],[CapEx Costs],[Type 2 Billable Cost],CAST([Type 1 Cost] as decimal(10,2)) [Type 1 Cost], [Out Of Pocket Expense],[Total Expense],[Total Profit]
			FROM 
				(
					SELECT TempFinal.*,CAST([EE standard charges] * [Total Realization%] /100 AS decimal(10,0)) [Realized Revenue], 
					CAST((([EE standard charges] * [Total Realization%] /100) * [%  Profit]) /100 AS decimal(10,0))  [Profit Realized],
					0 [Type 1 Revenue],0 [Type 2 Revenue],0 [Intercompany-TP],0 [Other Revenue],0 [Out of Pocket],0 [TIC],CAST(0.0 AS decimal(10,2))[Type 1] ,
					CAST(0.0 AS decimal(10,2))[Type 2], 0  [Write_Downs],CAST(0.0 AS decimal(10,2)) [TOTAL REVENUE],0 [Implementation Flag] ,0 [CapEx Costs],
					CAST(0.0 AS decimal(10,2)) [Type 2 Billable Cost],0 [Type 1 Cost],0 [Out Of Pocket Expense],CAST(0.0 as decimal(10,2)) [Total Expense],
					CAST(0.0 AS decimal(10,2)) [Total Profit]				
					FROM 
					(
						SELECT OAD.*, 
						CASE WHEN (OAD.[EE T1 standard charges] = 0 AND CARA.[Sum_Type_1_Hrs] = 0 ) THEN 0 ELSE CAST(((OAD.[T1 Hours] * NULLIF(CARA.[Type_1_Avg_Rate],0))*100 / CARA.[Sum_Type_1_Revenue] ) AS decimal(10,0))  END AS [%Realization T1],
						CASE WHEN (OAD.[EE T2 standard charges] = 0 AND CARA.[Sum_Type_2_Hrs] = 0 ) THEN 0 ELSE CAST(((OAD.[T2 Hours] * NULLIF(CARA.[Type_2_Avg_Rate],0))*100  / CARA.[Sum_Type_2_Revenue]  ) AS decimal(10,0))   END AS [%Realization T2],
						CASE WHEN (OAD.[EE standard charges] = 0 AND CARA.[Total_Hrs] = 0) THEN 0 ELSE CAST(((NULLIF(CARA.[Total_Hrs],0) * NULLIF(CARA.[Total_Hrs_Avg_Rate],0))*100  / CARA.[Total_Revenue] )  AS decimal(10,0))   END AS [Total Realization%], 
						CASE WHEN (CARA.[Total_Revenue] = 0 AND CARA.[Profit] = 0) THEN  0 ELSE CAST (((NULLIF(CARA.[Profit],0)/NULLIF(CARA.[Total_Revenue],0)) *100) AS decimal(10,0))  END AS [%  Profit],
						CASE WHEN (OAD.[EE T1 standard charges] = 0 AND CARA.[Sum_Type_1_Hrs] = 0 ) THEN 0 ELSE CAST(OAD.[T1 Hours] * CARA.[Type_1_Avg_Rate] AS decimal(10,2))  END AS [T1 Realized Revenue],
						CASE WHEN (OAD.[EE T2 standard charges] = 0 AND CARA.[Sum_Type_2_Hrs]  = 0 ) THEN 0 ELSE CAST(OAD.[T2 Hours] * CARA.[Type_2_Avg_Rate] AS decimal(10,2))  END AS [T2 Realized Revenue]
						--CARA.* 
						FROM #TempOpenAirDatasetSource  OAD 
						LEFT JOIN #TempClientAvgRateAgainstRevenueDataset CARA ON OAD.[Client - NetSuite Customer ID] = CARA.[Customer ID - Client Code] AND OAD.[NetSuite Project ID] = CARA.[NetSuite Project ID]
						WHERE (OAD.[NetSuite Project ID] is not null AND OAD.[NetSuite Project ID] <> 0)
											
					) TempFinal

					UNION ALL 

					SELECT 'Adaptive' [Source], ARU.[Date],convert(varchar(7), ARU.[Date], 126) [Period],YEAR(ARU.[Date]) [Year],ARU.[Customer ID - Client Code],
					ARU.[Client - Nickname],ARU.[Parent Client],ARU.[Geo] [Client- Geo], 
					CASE WHEN CHARINDEX(':',  ARU.[Client - Region  :  Market] )-1 <= 0 THEN ARU.[Client - Region  :  Market]
					ELSE LEFT(ARU.[Client - Region  :  Market],CHARINDEX(':',  ARU.[Client - Region  :  Market])-1) END AS [Client - Region],
					CASE WHEN CHARINDEX(':', ARU.[Client - Region  :  Market] )-1 <= 0 THEN ARU.[Client - Region  :  Market] 
					ELSE SUBSTRING(ARU.[Client - Region  :  Market], CHARINDEX(':',  ARU.[Client - Region  :  Market] )+1, LEN(ARU.[Client - Region  :  Market])) END AS [Client- Market],
					ARU.[Client - Salesforce Account ID] ,ARU.[NetSuite Project ID],ARU.[Project Name], Concat(ARU.[Customer ID - Client Code],ISNULL(ARU.[NetSuite Project ID],0),YEAR(ARU.[Date])) [Customer ID- Client Code+ Netsuite Project ID],
					CONCAT([Client - Nickname], '-',[Project Name]) [Client Name + Project Name],
					ARU.[OPP ID],ARU.[Industry Code],ARU.[Recurring type],DSC.[CE Win ID], ARU.[Client Executive],DSC.[PM WIN ID],DSC.[Project Manager],DSC.[PM Department],
					DSC.[Project Category], ARU.[Senior Client Executive],
					ARU.[Executive Sponsor],ARU.[Client Tier],ARU.[Practices] [Project - Practice],ARU.[Sub_Practice][Project - SubPractice],
					DSC.[Project stage],'' [EEWIN ID (User-User ID)],'' [EE Name],'' [EE Department],'' [EE Netsuite Location],'' [EE Country],'' [EE Practice : Subpractice], 
					'' [Salary Grade], '' [Termination Date],'' [EMP_STATUS],'' [FULL_PART_TIME],'' [EMP_TYPE],'' [Hours type],'' [T1 Hours], ''[T2 Hours], '' [Total Billable Hours],
					CAST (0.0 AS DECIMAL(10,2))[EE full time rate],CAST(0.0 AS DECIMAL(10,2)) [EE T1 standard charges],CAST(0.0 AS DECIMAL(10,2)) [EE T2 standard charges],
					CAST(0.0 AS DECIMAL(10,2)) [EE standard charges],
					Concat(ARU.[Customer ID - Client Code],ARU.[NetSuite Project ID],YEAR(ARU.[Date])) [Combination-CusIDClientCode+NetsuiteProID+Year],0 [%Realization T1],
					0 [%Realization T2],0 [Total Realization%],0 [%  Profit],0 [T1 Realized Revenue], 0 [T2 Realized Revenue],0 [Realized Revenue],0 [Profit Realized],
					ARU.[Type 1][Type 1 Revenue],ARU.[Type 2][Type 2 Revenue],
					ARU.[Intercompany-TP],ARU.[Other Revenue],ARU.[Out of Pocket],ARU.[TIC],CAST(ARU.[Type 1] AS decimal(10,2))[Type 1] ,CAST(ARU.[Type 2] AS decimal(10,2))[Type 2],
					ARU.[Write_Downs],CAST(ARU.[TOTAL REVENUE] AS decimal(10,2)) [TOTAL REVENUE],'' [Implementation Flag] ,ARU.[CapEx Costs],
					CAST(ARU.[Type 2 Billable Cost] AS decimal(10,2)) [Type 2 Billable Cost],ARU.[Type 1 Cost],ARU.[Out Of Pocket Expense],
					CAST(ARU.[TOTAL COST] as decimal(10,2)) [Total Expense],CAST(ARU.PROFIT AS decimal(10,2)) [Total Profit]
					FROM [dbo].T_Fact_AdaptiveRevenue_Updated ARU 
					LEFT JOIN #TempOpenAirDatasetSourceCombineWithAdaptive DSC ON Concat(ARU.[Customer ID - Client Code],ARU.[NetSuite Project ID],YEAR(ARU.[Date])) = DSC.[Combination-CusIDClientCode+NetsuiteProID+Year]
					AND MONTH(DSC.[DATE]) = MONTH(ARU.[Date])
					WHERE ARU.[Date] >= @startdate and ARU.[Date]  <= @enddate 	AND ([NetSuite Project ID] is not null AND [NetSuite Project ID] <> 0)
					
				) AS FinalResults 
				LEFT JOIN [dbo].[xxxx] PR ON FinalResults.[Project - SubPractice] = PR.Project_SubPractice
				LEFT JOIN [dbo].[xxxx] PRS ON FinalResults.[Project - SubPractice]  = PRS.[Practice_SubPractice_(TU)]
				
			END
			
			IF((SELECT COUNT(*) FROM #TempClientEmployeeHrsDataset_without_NetSuiteProjectID) > 0)
			BEGIN
				TRUNCATE TABLE #TempClientAvgRateAgainstRevenueDataset
				INSERT INTO #TempClientAvgRateAgainstRevenueDataset
				(
					[startdate],[enddate],[Customer ID - Client Code],[Type_1_Avg_Rate],[Type_2_Avg_Rate],[Total_Hrs_Avg_Rate],[Sum_Type_1_Hrs],[Sum_Type_2_Hrs],[Total_Hrs],
					--[Month],[Year],
					[NetSuite Project ID],[Sum_Type_1_Revenue],[Sum_Type_2_Revenue],[Total_Revenue],[Profit]
				)
				SELECT [startdate],[enddate],[Customer ID - Client Code],[Type_1_Avg_Rate],[Type_2_Avg_Rate],[Total_Hrs_Avg_Rate],[Sum_Type_1_Hrs],[Sum_Type_2_Hrs],[Total_Hrs],
				--[Month],[Year],
				[NetSuite Project ID],[Sum_Type_1_Revenue],[Sum_Type_2_Revenue],[Total_Revenue],[Profit]
				FROM 
				(
					SELECT CEHD.startdate,CEHD.enddate,CEHD.[Customer ID - Client Code],CEHD.[Sum_Type_1_Hrs],ACRD.[Sum_Type_1_Revenue],
					CASE WHEN (CEHD.Sum_Type_1_Hrs <> 0 AND ACRD.Sum_Type_1_Revenue <> 0) THEN CAST((ACRD.Sum_Type_1_Revenue/CEHD.Sum_Type_1_Hrs) AS decimal(10,2)) ELSE 0 END [Type_1_Avg_Rate],
					CEHD.[Sum_Type_2_Hrs],ACRD.[Sum_Type_2_Revenue],
					CASE WHEN (CEHD.Sum_Type_2_Hrs <> 0 AND ACRD.Sum_Type_2_Revenue <> 0) THEN CAST((ACRD.Sum_Type_2_Revenue/CEHD.Sum_Type_2_Hrs) AS decimal(10,2)) ELSE 0 END [Type_2_Avg_Rate],
					CEHD.[Total_Hrs],ACRD.Total_Revenue,
					CASE WHEN (CEHD.Total_Hrs <> 0 AND ACRD.Total_Revenue <> 0) THEN CAST((ACRD.Total_Revenue/CEHD.Total_Hrs) AS decimal(10,2)) ELSE 0 END [Total_Hrs_Avg_Rate],
					ACRD.[Month], ACRD.[Year],CEHD.[NetSuite Project ID],ACRD.[Profit]
					FROM #TempClientEmployeeHrsDataset_without_NetSuiteProjectID CEHD 
					INNER JOIN #TempAdaptiveClientRevenueDataset ACRD ON CEHD.[Customer ID - Client Code] = ACRD.[Customer ID - Client Code] 
					--AND CEHD.[Month] = ACRD.[Month] 	AND CEHD.[Year] = ACRD.[Year] 
					WHERE CEHD.[NetSuite_Project_ID_Flag] =  0 AND ACRD.[NetSuite_Project_ID_Flag] = 0
				) Temp
			
			INSERT INTO [dbo].[xxxxxxxx]
						(
							[Source] ,[DATE],[Period],[Year],[Client - NetSuite Customer ID] ,[Client Name] ,[Parent Client] ,[Client- Geo] ,[Client - Region] ,[Client- Market]  ,
							[Client - SFDC Account ID] ,[NetSuite Project ID] ,	[Project - Name] ,[Customer ID- Client Code+ Netsuite Project ID] ,	[Client Name + Project Name] ,
							[Opp ID] ,[Tech Opp ID w/ all sub practices], [Tech Opp ID + Subpractice distinct],[Industry] ,[Recurring Type] ,[CE Win ID] ,[Client Executive] ,[PM WIN ID] ,[Project Manager] ,[PM Department] ,[Project Category] ,
							[Senior Client Executive] ,	[Executive Sponsor] ,[Client Tier]  ,[Project - Practice ] ,[Project - SubPractice] ,[Project stage] ,[EEWIN ID (User-User ID)]   ,
							[EE Name] ,	[EE Department] ,[EE Netsuite Location] ,[EE Country] ,	[EE Practice : Subpractice] ,[Salary Grade] ,[Termination Date] ,[EMP_STATUS] ,
							[FULL_PART_TIME] ,[EMP_TYPE]  ,[Hours type] ,[T1 Hours] ,[T2 Hours] ,[Total Billable Hours] , [EE full time rate] ,[EE T1 standard charges]  ,
							[EE T2 standard charges]  ,	[EE standard charges] ,	[Combination-CusIDClientCode+NetsuiteProID+Year],[%Realization T1] ,[%Realization T2] ,	[Total Realization%] ,
							[%  Profit]  ,[T1 Realized Revenue] ,[T2 Realized Revenue] ,[Realized Revenue] ,[Profit Realized] ,[Type 1 Revenue] ,[Type 2 Revenue] ,[Intercompany-TP] ,
							[Other Revenue] ,[Out of Pocket] ,[TIC] ,[Type 1] ,	[Type 2] ,[Write_Downs] ,[TOTAL REVENUE] ,[Implementation Flag] ,[CapEx Costs] ,[Type 2 Billable Cost] ,
							[Type 1 Cost] ,	[Out Of Pocket Expense] ,[Total Expense] ,[Total Profit] 
						) 
			SELECT [Source],[DATE],[Period],[Year],[Client - NetSuite Customer ID],[Client Name],[Parent Client],[Client- Geo],[Client - Region],[Client- Market],[Client - SFDC Account ID],[NetSuite Project ID],
				   [Project - Name],[Customer ID- Client Code+ Netsuite Project ID],[client Name + Project Name],[Opp ID],PRS.[Tech Opp ID][Tech Opp ID w/ all sub practices],
				   PR.[Tech Opp ID] [Tech Opp ID + Subpractice distinct],[Industry] ,[Recurring Type],[CE Win ID],[Client Executive],[PM WIN ID],
				   [Project Manager],[PM Department],[Project Category],[Senior Client Executive],[Executive Sponsor],[Client Tier],[Project - Practice],[Project - SubPractice],[Project stage],
				   [EEWIN ID (User-User ID)],[EE Name],[EE Department],[EE Netsuite Location],[EE Country],[EE Practice : Subpractice],[Salary Grade],
				   CAST([Termination Date] AS VARCHAR(50)) [Termination Date],[EMP_STATUS],[FULL_PART_TIME],
				   [EMP_TYPE],[Hours type],[T1 Hours],[T2 Hours],[Total Billable Hours],[EE full time rate],[EE T1 standard charges],[EE T2 standard charges],[EE standard charges],[Combination-CusIDClientCode+NetsuiteProID+Year],
				   CONCAT(ISNULL([%Realization T1],0),'%')[%Realization T1],CONCAT(ISNULL([%Realization T2],0),'%')[%Realization T2],CONCAT(ISNULL([Total Realization%],0),'%')[Total Realization%],
				   CONCAT(ISNULL([%  Profit],0),'%')[%  Profit],CAST([T1 Realized Revenue] AS decimal(10,2)) [T1 Realized Revenue],CAST([T2 Realized Revenue] AS decimal(10,2)) [T2 Realized Revenue],
				   CAST([Realized Revenue] AS decimal(10,2)) [Realized Revenue],CAST([Profit Realized] AS decimal(10,2)) [Profit Realized],CAST([Type 1 Revenue] AS decimal(10,2)) [Type 1 Revenue],
				   CAST([Type 2 Revenue] AS decimal(10,2)) [Type 2 Revenue],[Intercompany-TP],[Other Revenue],[Out of Pocket],[TIC],[Type 1],[Type 2],CAST([Write_Downs] as decimal(10,2)) [Write_Downs],
				   [TOTAL REVENUE],[Implementation Flag],[CapEx Costs],[Type 2 Billable Cost],CAST([Type 1 Cost] as decimal(10,2)) [Type 1 Cost], [Out Of Pocket Expense],[Total Expense],[Total Profit]
			FROM 
				(
					SELECT TempFinal.*,CAST([EE standard charges] * [Total Realization%] /100 AS decimal(10,0)) [Realized Revenue], 
					CAST((([EE standard charges] * [Total Realization%] /100) * [%  Profit]) /100 AS decimal(10,0))  [Profit Realized],
					0 [Type 1 Revenue],0 [Type 2 Revenue],0 [Intercompany-TP],0 [Other Revenue],0 [Out of Pocket],0 [TIC],CAST(0.0 AS decimal(10,2))[Type 1] ,
					CAST(0.0 AS decimal(10,2))[Type 2], 0  [Write_Downs],CAST(0.0 AS decimal(10,2)) [TOTAL REVENUE],0 [Implementation Flag] ,0 [CapEx Costs],
					CAST(0.0 AS decimal(10,2)) [Type 2 Billable Cost],0 [Type 1 Cost],0 [Out Of Pocket Expense],CAST(0.0 as decimal(10,2)) [Total Expense],
					CAST(0.0 AS decimal(10,2)) [Total Profit]				
					FROM 
					(
						SELECT OAD.*, 
						CASE WHEN (OAD.[EE T1 standard charges] = 0 AND CARA.[Sum_Type_1_Hrs] = 0 ) THEN 0 ELSE CAST(((OAD.[T1 Hours] * NULLIF(CARA.[Type_1_Avg_Rate],0))*100 / CARA.[Sum_Type_1_Revenue] ) AS decimal(10,0))  END AS [%Realization T1],
						CASE WHEN (OAD.[EE T2 standard charges] = 0 AND CARA.[Sum_Type_2_Hrs] = 0 ) THEN 0 ELSE CAST(((OAD.[T2 Hours] * NULLIF(CARA.[Type_2_Avg_Rate],0))*100  / CARA.[Sum_Type_2_Revenue]  ) AS decimal(10,0))   END AS [%Realization T2],
						CASE WHEN (OAD.[EE standard charges] = 0 AND CARA.[Total_Hrs] = 0) THEN 0 ELSE CAST(((NULLIF(CARA.[Total_Hrs],0) * NULLIF(CARA.[Total_Hrs_Avg_Rate],0))*100  / CARA.[Total_Revenue] )  AS decimal(10,0))   END AS [Total Realization%], 
						CASE WHEN (CARA.[Total_Revenue] = 0 AND CARA.[Profit] = 0) THEN  0 ELSE CAST (((NULLIF(CARA.[Profit],0)/NULLIF(CARA.[Total_Revenue],0)) *100) AS decimal(10,0))  END AS [%  Profit],
						CASE WHEN (OAD.[EE T1 standard charges] = 0 AND CARA.[Sum_Type_1_Hrs] = 0 ) THEN 0 ELSE CAST(OAD.[T1 Hours] * CARA.[Type_1_Avg_Rate] AS decimal(10,2))  END AS [T1 Realized Revenue],
						CASE WHEN (OAD.[EE T2 standard charges] = 0 AND CARA.[Sum_Type_2_Hrs]  = 0 ) THEN 0 ELSE CAST(OAD.[T2 Hours] * CARA.[Type_2_Avg_Rate] AS decimal(10,2))  END AS [T2 Realized Revenue]
						--CARA.* 
						FROM #TempOpenAirDatasetSource  OAD 
						LEFT JOIN #TempClientAvgRateAgainstRevenueDataset CARA ON OAD.[Client - NetSuite Customer ID] = CARA.[Customer ID - Client Code] 
						WHERE (OAD.[NetSuite Project ID] is null OR OAD.[NetSuite Project ID] = 0)
					) TempFinal 

					UNION ALL

					SELECT 'Adaptive' [Source], ARU.[Date],convert(varchar(7), ARU.[Date], 126) [Period],YEAR(ARU.[Date]) [Year],ARU.[Customer ID - Client Code],
					ARU.[Client - Nickname],ARU.[Parent Client],ARU.[Geo] [Client- Geo], 
					CASE WHEN CHARINDEX(':',  ARU.[Client - Region  :  Market] )-1 <= 0 THEN ARU.[Client - Region  :  Market]
					ELSE LEFT(ARU.[Client - Region  :  Market],CHARINDEX(':',  ARU.[Client - Region  :  Market])-1) END AS [Client - Region],
					CASE WHEN CHARINDEX(':', ARU.[Client - Region  :  Market] )-1 <= 0 THEN ARU.[Client - Region  :  Market] 
					ELSE SUBSTRING(ARU.[Client - Region  :  Market], CHARINDEX(':',  ARU.[Client - Region  :  Market] )+1, LEN(ARU.[Client - Region  :  Market])) END AS [Client- Market],
					ARU.[Client - Salesforce Account ID] ,ARU.[NetSuite Project ID],ARU.[Project Name], Concat(ARU.[Customer ID - Client Code],ISNULL(ARU.[NetSuite Project ID],0),YEAR(ARU.[Date])) [Customer ID- Client Code+ Netsuite Project ID],
					CONCAT([Client - Nickname], '-',[Project Name]) [Client Name + Project Name],
					ARU.[OPP ID],ARU.[Industry Code],ARU.[Recurring type],DSC.[CE Win ID], ARU.[Client Executive],DSC.[PM WIN ID],DSC.[Project Manager],DSC.[PM Department],
					DSC.[Project Category], ARU.[Senior Client Executive],
					ARU.[Executive Sponsor],ARU.[Client Tier],ARU.[Practices] [Project - Practice],ARU.[Sub_Practice][Project - SubPractice],
					DSC.[Project stage],'' [EEWIN ID (User-User ID)],'' [EE Name],'' [EE Department],'' [EE Netsuite Location],'' [EE Country],'' [EE Practice : Subpractice], 
					'' [Salary Grade],'' [Termination Date],'' [EMP_STATUS],'' [FULL_PART_TIME],'' [EMP_TYPE],'' [Hours type],'' [T1 Hours], ''[T2 Hours], '' [Total Billable Hours],
					CAST (0.0 AS DECIMAL(10,2))[EE full time rate],CAST(0.0 AS DECIMAL(10,2)) [EE T1 standard charges],CAST(0.0 AS DECIMAL(10,2)) [EE T2 standard charges],
					CAST(0.0 AS DECIMAL(10,2)) [EE standard charges],
					Concat(ARU.[Customer ID - Client Code],ARU.[NetSuite Project ID],YEAR(ARU.[Date])) [Combination-CusIDClientCode+NetsuiteProID+Year],0 [%Realization T1],
					0 [%Realization T2],0 [Total Realization%],0 [%  Profit],0 [T1 Realized Revenue], 0 [T2 Realized Revenue],0 [Realized Revenue],0 [Profit Realized],
					ARU.[Type 1][Type 1 Revenue],ARU.[Type 2][Type 2 Revenue],
					ARU.[Intercompany-TP],ARU.[Other Revenue],ARU.[Out of Pocket],ARU.[TIC],CAST(ARU.[Type 1] AS decimal(10,2))[Type 1] ,CAST(ARU.[Type 2] AS decimal(10,2))[Type 2],
					ARU.[Write_Downs],CAST(ARU.[TOTAL REVENUE] AS decimal(10,2)) [TOTAL REVENUE],'' [Implementation Flag] ,ARU.[CapEx Costs],
					CAST(ARU.[Type 2 Billable Cost] AS decimal(10,2)) [Type 2 Billable Cost],ARU.[Type 1 Cost],ARU.[Out Of Pocket Expense],
					CAST(ARU.[TOTAL COST] as decimal(10,2)) [Total Expense],CAST(ARU.PROFIT AS decimal(10,2)) [Total Profit]
					FROM [dbo].xxxx ARU 
					LEFT JOIN #TempOpenAirDatasetSourceCombineWithAdaptiveWithoutNetSuiteProjectId DSC ON Concat(ARU.[Customer ID - Client Code],MONTH(ARU.[Date]),YEAR(ARU.[Date])) =  Concat(DSC.[Client - NetSuite Customer ID],MONTH(DSC.[Date]),YEAR(DSC.[Date]))
					AND MONTH(DSC.[DATE]) = MONTH(ARU.[Date])
					WHERE ARU.[Date] >= @startdate and ARU.[Date]  <= @enddate 	AND (ARU.[NetSuite Project ID] IS NULL OR ARU.[NetSuite Project ID] = 0)
					
				) AS FinalResults 
				LEFT JOIN [dbo].[xxxx] PR ON FinalResults.[Project - SubPractice] = PR.Project_SubPractice
				LEFT JOIN [dbo].[xxxx] PRS ON FinalResults.[Project - SubPractice]  = PRS.[Practice_SubPractice_(TU)]
				
			END
			UPDATE [dbo].[xxxxxx] SET [Termination Date] = '' WHERE [Termination Date] IN ('1900-01-01')
		
		END
		ELSE
		BEGIN 
			IF(@startdate IS NULL)
			BEGIN
				SELECT '---start date can not be null---'
			END
			IF(@enddate IS NULL)
			BEGIN
				SELECT '---end date can not be null---'
			END			
	    END
	END TRY
	BEGIN CATCH
	  SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
	END CATCH;

DROP TABLE #TempEEDetailsDataset
DROP TABLE #TempUserIdUserDataset
DROP TABLE #TempEmployeeBillRateDataset
DROP TABLE #TempEmployeeBillHrsDataset
DROP TABLE #TempOpenAirDatasetSource
DROP TABLE #TempAdaptiveClientRevenueDataset
DROP TABLE #TempClientEmployeeHrsDataset_with_NetSuiteProjectID
DROP TABLE #TempClientEmployeeHrsDataset_without_NetSuiteProjectID
DROP TABLE #TempClientAvgRateAgainstRevenueDataset
DROP TABLE #TempOpenAirDatasetSourceCombineWithAdaptive
DROP TABLE #TempOpenAirDatasetSourceCombineWithAdaptiveWithoutNetSuiteProjectId
END
