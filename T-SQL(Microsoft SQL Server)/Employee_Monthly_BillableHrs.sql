﻿USE [T_Ops_DW]
GO
/****** Object:  StoredProcedure [dbo].[SSP_Transform_EToT_DO_Employee_Monthly_BillableHrs]    Script Date: 1/12/2024 1:11:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SSP_Transform_EToT_DO_Employee_Monthly_BillableHrs]
(
	@startdate DATE = NULL,
	@enddate DATE = NULL
)
AS 
BEGIN 
/*
	28-03-2022 SB 40000450 created
*/
IF(@startdate IS NULL AND @enddate IS  NULL )
BEGIN
	SET @startdate = CAST (DATEADD(mm, DATEDIFF(m,0,GETDATE())-6,0) AS DATE)
	SET @enddate = EOMONTH(CAST(DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) AS DATE))
END
CREATE TABLE #TempEmployeeBillHrsReport
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
	[Project - Name]  VARCHAR(500),
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
	[PM Department] VARCHAR(100),
	T_date_Pulled datetime
)

TRUNCATE TABLE #TempEmployeeBillHrsReport
INSERT INTO #TempEmployeeBillHrsReport 
			(
				[Client - Country],[Client - Region : Market_departmentId],[User - User ID],[Client - Client code],[Project code],
				[Project - Practice : SubPractice], [Time category],[Period],[Project - Name_ProjectId],
				[NetSuite Project ID], [Client - NetSuite Customer ID],[T1 Hours],[T2 Hours],[Time (Hours)],[Project - Name],[Project stage] ,
				[Client Name],[Recurring Type],[Project Category],[Industry],[Opp ID],[Client- Geo],[Client - SFDC Account ID],[Client - Region], [Client- Market] ,
				[PM WIN ID],[Project Manager],[CE Win ID],[Client Executive],[ES Win ID],[PM Department],
				T_date_Pulled
	        )

SELECT [Client - Country],[Client - Region : Market_departmentId],[User - User ID],[Client - Client code],[Project code],
	   [Project - Practice : SubPractice], [Time category],[Period],[Project - Name_ProjectId],
	   [NetSuite Project ID], [Client - NetSuite Customer ID],
	   CASE WHEN [Time category] = 'Type 1 (T1)' THEN SUM([Time (Hours)]) ELSE 0 END AS [T1 Hours],CASE WHEN [Time category] = 'Type 1 (T1)' THEN 0 ELSE SUM([Time (Hours)]) END AS [T2 Hours],
	   SUM ([Time (Hours)]) [Time (Hours)],[Project - Name],[Project stage],
	   [Client Name],[Recurring Type],[Project Category],[Industry],[Opp ID],[Client- Geo],[Client - SFDC Account ID],[Client - Region], [Client- Market], 
	   [PM WIN ID],[Project Manager],[CE Win ID],[Client Executive],[ES Win ID],[PM Department],
	   T_date_Pulled
FROM
	(
		SELECT CASE WHEN C.[country] = 'United States' 
					THEN 'USA' 
					ELSE C.[country] END [Client - Country], DP.[id] as [Client - Region : Market_departmentId] , U.[nickname] [User - User ID],
		C.[external_id][Client - Client code],LEFT( P.[name],CHARINDEX('-',  P.[name])-1) [Project code],CC.[name][Project - Practice : SubPractice],PPT.[name][Time category],
		CONCAT (YEAR([DATE] ),'-', FORMAT(MONTH([DATE]),'00')) as  [Period],
		Convert(NUMERIC(18, 2),(T.[hour] *60 + T.[minute] )/60,2) AS [Time (Hours)],P.[id] [Project - Name_ProjectId],
		CASE WHEN TRIM(P.[custom_71]) <= 0 THEN 0 ELSE TRIM(P.[custom_71])  END [NetSuite Project ID],
		C.[custom_70] [Client - NetSuite Customer ID] ,P.[name] AS [Project - Name],PS.[name] [Project stage],
		C.[name] [Client Name],P.[custom_92][Recurring Type],P.[custom_206] [Project Category],
		C.[custom_163][Industry],P.[custom_8][Opp ID],
		CASE WHEN C.[country] ='USA' THEN 'US' ELSE CASE WHEN C.[country] ='Canada' THEN 'CA' ELSE 'UK' END END [Client- Geo],
		C.[custom_7] [Client - SFDC Account ID] ,
		CASE WHEN CHARINDEX(':',  DP.[name] )-1 <= 0 
		THEN DP.[name] 
		ELSE LEFT(DP.[name],CHARINDEX(':',  DP.[name])-1) END AS [Client - Region],
		CASE WHEN CHARINDEX(':',  DP.[name] )-1 <= 0 
		THEN DP.[name] 
		ELSE SUBSTRING(DP.[name], CHARINDEX(':',  DP.[name] )+1, LEN(DP.[name])) END AS [Client- Market],
		U1.nickname [PM WIN ID],U1.[name][Project Manager],U2.nickname [CE Win ID],U2.[name][Client Executive] , U3.nickname [ES Win ID],
		C3.[name][PM Department],
		Cast(getdate()as date) as T_date_Pulled
		FROM [xxxx].[Openair].[xxx] T
		LEFT JOIN [xxxx].[Openair].[xxx] P ON T.[project_id] = P.[id]
		LEFT JOIN [xxxx].[Openair].[xxx] C ON C.[id] = T.[customer_id]
		LEFT JOIN [xxxx].[Openair].[xxx] CC ON CC.[id] = P.[cost_center_id]
		LEFT JOIN [xxxx].[Openair].[xxx] PT ON PT.[id] = T.[project_task_id]
		LEFT JOIN [xxxx].[Openair].[xxx] U ON U.[id] = T.[user_id]
		LEFT JOIN [xxxx].[Openair].[xxx] PPT ON PPT.[id] =T.projecttask_type_id
		LEFT JOIN [xxxx].[Openair].[xxx] as DP on C.[custom_57]= DP.[id]
		LEFT JOIN [xxxx].[Openair].[xxx] PS on P.[project_stage_id] = PS.[id]
		LEFT JOIN [xxxx].[Openair].[xxx] U1 on P.[user_id] = U1.[id]
		LEFT JOIN [xxxx].[Openair].[xxx] U2 on C.[user_id] = U2.[id]
		LEFT JOIN [xxxx].[Openair].[xxx] U3 ON U1.[line_manager_id] =  U3.[id]
		LEFT JOIN [xxxx].[Openair].[xxx] C3 ON U1.[custom_181] = C3.[id]
		WHERE  CAST(T.[date] AS date) >= @startdate AND  CAST([date] AS date) <= @enddate
		--YEAR(T.date ) = YEAR(GETDATE()) AND MONTH(T.date ) <= MONTH (GETDATE()) 
		AND T.[deleted] !=1 AND ppt.name in ( 'Type 1 (T1)',
												'Type 2 (T2) - Non-CapX',
												'T2a (Recurring Fixed Fee)',
												'Type 2 (T2) - CapX',
												'T2b (Milestone)',
												'T2c (Volume)',
												'Billing milestone'
											 ) 
											 
						
		
	) AS TempResult
GROUP BY [Client - Country],[Client - Region : Market_departmentId],[User - User ID],[Client - Client code],[Project code],
		[Project - Practice : SubPractice], [Time category],[Period],[Project - Name_ProjectId],
	   [NetSuite Project ID], [Client - NetSuite Customer ID],[Project - Name],[Project stage],
	   [Client Name],[Recurring Type],[Project Category],[Industry],[Opp ID],[Client- Geo],[Client - SFDC Account ID],[Client - Region], [Client- Market] ,
	   [PM WIN ID],[Project Manager],[CE Win ID],[Client Executive],[ES Win ID],[PM Department],
	   T_date_Pulled
ORDER BY [Period] ASC

SELECT [Client - Country],[Client - Region : Market_departmentId],[User - User ID],[Client - Client code],[Project code],
	   [Project - Practice : SubPractice], [Time category],[Period],[Project - Name_ProjectId],
	   [NetSuite Project ID], [Client - NetSuite Customer ID],[T1 Hours],[T2 Hours],[Time (Hours)],[Project - Name],[Project stage],
	   [Client Name],[Recurring Type],[Project Category],[Industry],[Opp ID],[Client- Geo],[Client - SFDC Account ID],[Client - Region], [Client- Market] ,
	   [PM WIN ID],[Project Manager],[CE Win ID],[Client Executive],[ES Win ID],[PM Department]
FROM #TempEmployeeBillHrsReport 

DROP TABLE #TempEmployeeBillHrsReport

END
