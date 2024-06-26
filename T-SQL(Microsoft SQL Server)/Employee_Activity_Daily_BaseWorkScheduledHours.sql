﻿USE [T_Ops_DW]
GO
/****** Object:  StoredProcedure [dbo].[SSP_Transform_EToT_Employee_Activity_Daily_BaseWorkScheduledHours]    Script Date: 1/12/2024 1:15:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SSP_Transform_EToT_Employee_Activity_Daily_BaseWorkScheduledHours]
(
@FlagValue varchar(50),
@StartDate date  = null 
)
AS 
BEGIN
/*
28-02-2022 SB 40000450 created
*/
Declare @month int 
Declare @year int
Declare @workday int 
--Check the first day of month 
IF(DAY(DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) =  DAY(GETDATE()))
BEGIN 
SET @month = MONTH(GETDATE())-1 
	 
END 
ELSE 
BEGIN
SET @month = MONTH(GETDATE())
END
 
--Check the first day of year
IF (DAY(DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)) = 1 AND MONTH(GETDATE()) = 1 AND DAY(GETDATE()) = 1  )
BEGIN
SET @year = Year(GETDATE()) - 1
END
ELSE 
BEGIN
SET @year = Year(GETDATE())
END 

CREATE TABLE #TempCorporateHoliday
(
	[user_id] INT, 
	[CorporateHoliday_Hours_minute] VARCHAR(50),
	[DailyDate] date,
	[win_id] VARCHAR(20),
	[Holiday_day_date] date,
	[CH_Workday] INT
)

CREATE TABLE #TempLastDayActualWorkHours 
(
	[created] date,
	[DailyDate] date,
	[Holiday_day_date] date,
	[User] VARCHAR(50),
	[User - User ID] VARCHAR(50),
	[Resources - Base work schedule hours] VARCHAR(50),
	[Adjusted Work Scheduled hours ] VARCHAR(50),
	[CorporateHoliday_Hours_minute] VARCHAR(50),
	[workday] INT
)

CREATE TABLE #TempLastTwoMonthsActualWorkHours 
(
	[DailyDate] date,
	[Holiday_day_date] date,
	[User] VARCHAR(50),
	[User - User ID] VARCHAR(50),
	[Resources - Base work schedule hours] VARCHAR(50),
	[Adjusted Work Scheduled hours ] VARCHAR(50),
	[CorporateHoliday_Hours_minute] VARCHAR(50)
)
CREATE TABLE #TempDeletedCorporateHoliday
(
	[user_id] INT, 
	[CorporateHoliday_Hours_minute] VARCHAR(50),
	[DailyDate] date,
	[win_id] VARCHAR(20),
	[Holiday_day_date] date,
	[CH_Workday] INT
)

CREATE TABLE #TempLastDayActualWorkHoursList 
(
	[User - User ID] VARCHAR(50),
	[Resources - Base work schedule hours] VARCHAR(50),
	[workday] INT
)

CREATE TABLE #TempLastTwoMonthWorkHoursList 
(
	[User - User ID] VARCHAR(50),
	[Last_Work_Schedule_hours] VARCHAR(50)
)
CREATE TABLE #TempUpdateLastTwoMonthWorkHoursUsersList 
(
	[User - User ID] VARCHAR(50),
	[Resources - Base work schedule hours] VARCHAR(50)
)

-- CorporateHoliday Hours for calculating actual hours
IF(@FlagValue = 'fullload')
BEGIN
TRUNCATE TABLE [dbo].[T_Fact_EmployeeScheduleDaily] 
INSERT INTO #TempCorporateHoliday ([user_id],[CorporateHoliday_Hours_minute],[DailyDate],[win_id],[Holiday_day_date],[CH_Workday])
SELECT [user_id] ,SUM([CorporateHoliday_Hours_minute]),[DailyDate],[win_id],[Holiday_day_date],[CH_Workday] FROM 
(
	SELECT distinct [user_id] ,[date],[Holiday_day_date],CAST(GETDATE() -1 AS DATE) AS [DailyDate] ,[win_id],ABS([CorporateHoliday_Hours_minute]) [CorporateHoliday_Hours_minute],
	CASE WHEN [Holiday_day_date] >= @StartDate THEN 1 ELSE 0 END AS Daily_Flag, 
	[CH_Workday] 
	FROM 
		(
			SELECT T.[date] , CAST(T.[date] AS DATE) [Holiday_day_date],
			((DATEPART(WEEKDAY, T.[date]))-2)[CH_Workday]
			,U.[nickname][win_id],
			Convert(NUMERIC(18, 2),(T.[hour] *60 + T.[minute] )/60,2)[CorporateHoliday_Hours_minute],T.[user_id] [user_id]  
			FROM [xxxxx].[Openair].[xxx] T
			LEFT JOIN [xxxxx].[Openair].[xxx] PT ON PT.[id] = T.[project_task_id] 
			LEFT JOIN [xxxxx].[Openair].[xxx] U ON T.[user_id] = U.[id]
			WHERE  PT.[name] ='Corporate Holiday' AND T.[deleted] != 1	
			
	
		) Temp
) AS FinalResults WHERE Daily_Flag = 1
Group By [user_id] ,[DailyDate],[win_id],[Holiday_day_date],[CH_Workday]
	
Declare @monthsCount INT =  (SELECT DATEDIFF(month, @StartDate, GETDATE()))

DECLARE @cnt INT = 0;
WHILE (@cnt <= @monthsCount )
BEGIN

	Declare @monthDaysCount INT  = (SELECT DATEDIFF(DAY, @StartDate, EOMONTH(@StartDate)))

	DECLARE @dayscnt INT = 0;
	DECLARE @incrementdayDate DATE = @StartDate;

	WHILE (@dayscnt <= @monthDaysCount)
		BEGIN
			IF(@incrementdayDate <= GETDATE()-1)
			BEGIN
				DECLARE @WeekDayDate DATETIME = CAST (@incrementdayDate  AS datetime)
				IF (DATENAME(weekday,@WeekDayDate) = 'Sunday')
				BEGIN 
					set @workday = 6 ;
				END
				IF (DATENAME(weekday,@WeekDayDate) = 'Monday')
				BEGIN 
					set @workday = 0 ;
				END 
				IF (DATENAME(weekday,@WeekDayDate) = 'Tuesday')
				BEGIN 
					set @workday = 1 ;
				END 
				IF (DATENAME(weekday,@WeekDayDate) = 'Wednesday')
				BEGIN 
					set @workday = 2 ;
				END 
				IF (DATENAME(weekday,@WeekDayDate) = 'Thursday')
				BEGIN 
					set @workday = 3 ;
				END
				IF (DATENAME(weekday,@WeekDayDate) = 'Friday')
				BEGIN 
					set @workday = 4 ;
				END
				IF (DATENAME(weekday,@WeekDayDate) = 'Saturday')
				BEGIN 
					set @workday = 5 ;
				END
				
				INSERT INTO #TempLastDayActualWorkHours ([DailyDate],[Holiday_day_date],[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute],[workday])
				SELECT  @incrementdayDate,CH.Holiday_day_date,U.[name] [User],U.[nickname][User - User ID],
				ISNULL(WWH.[workhours],0) [Resources - Base work schedule hours],
				(ISNULL(WWH.[workhours],0) - ISNULL([CorporateHoliday_Hours_minute],0)) [Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute] , @workday
				FROM [xxxxx].[Openair].[xxx] U 
				LEFT JOIN [xxxxx].[Openair].[xx] W ON W.[user_id] =U.[id] AND W.[id] = U.[workschedule_id]
				LEFT JOIN [xxxxx].[Openair].[xxx] WWH ON WWH.[workschedule_id] = W.[account_workschedule_id] AND WWH.[workday]=@workday
				LEFT JOIN #TempCorporateHoliday CH ON CH.[user_id] = U.[id] AND  CH.[Holiday_day_date] = @incrementdayDate
				WHERE  U.[custom_90] != '' AND  U.[nickname] NOT IN (SELECT [User - User ID] FROM [dbo].[Fact_DummyUsersLookup]) 			
				ORDER BY U.[nickname]
			END
			SET @dayscnt = @dayscnt + 1
			SET @incrementdayDate =  CAST (DATEADD(dd, DATEDIFF(d,0,@incrementdayDate) + 1,0) AS DATE)				
		END

	UPDATE #TempLastDayActualWorkHours SET [Resources - Base work schedule hours] = 0,[Adjusted Work Scheduled hours ] = 0 ,[CorporateHoliday_Hours_minute] = 0 
	WHERE [workday] IN (5,6)

	INSERT INTO [dbo].[xxxxxxxx]([DailyDate],[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute],[T_date_Pulled])
	SELECT [DailyDate] ,[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],ISNULL([CorporateHoliday_Hours_minute],0),GETDATE() FROM #TempLastDayActualWorkHours	
	TRUNCATE TABLE #TempLastDayActualWorkHours
	
	SET @cnt = @cnt + 1
	SET @StartDate =   DATEADD(MONTH, 1, @StartDate)
END

					DELETE S
   FROM [xxx].[dbo].[xxxxxxxxxxxxx] S
   LEFT JOIN xxx.[dbo].[xxxxxxx] E ON E.EE_WIN = S.[User - User ID] AND E.[Report Date] = (SELECT MAX([Report Date]) FROM xxxx.[dbo].[xxxxxxx])
   WHERE (DailyDate > E.[Termination Date]  OR DailyDate < E.LAST_HIRE_DATE ) 

END 
IF(@FlagValue = 'daily')
BEGIN

DECLARE @DailyDayDate DATETIME = CAST (GETDATE()-1  AS datetime);
DECLARE @DailyProcessFlag VARCHAR(50) = '';
IF (DATENAME(weekday,@DailyDayDate) = 'Sunday')
BEGIN 
	set @workday = 6 ;
END
IF (DATENAME(weekday,@DailyDayDate) = 'Monday')
BEGIN 
	set @workday = 0 ;
	set @DailyProcessFlag = 'process';
END 
IF (DATENAME(weekday,@DailyDayDate) = 'Tuesday')
BEGIN 
	set @workday = 1 ;
	set @DailyProcessFlag = 'process';
END 
IF (DATENAME(weekday,@DailyDayDate) = 'Wednesday')
BEGIN 
	set @workday = 2 ;
	set @DailyProcessFlag = 'process';
END 
IF (DATENAME(weekday,@DailyDayDate) = 'Thursday')
BEGIN 
	set @workday = 3 ;
	set @DailyProcessFlag = 'process';
END
IF (DATENAME(weekday,@DailyDayDate) = 'Friday')
BEGIN 
	set @workday = 4 ;
	set @DailyProcessFlag = 'process';
END
IF (DATENAME(weekday,@DailyDayDate) = 'Saturday')
BEGIN 
	set @workday = 5 ;
	
END
--get corporate holidays last two month
INSERT INTO #TempCorporateHoliday ([user_id],[CorporateHoliday_Hours_minute],[DailyDate],[win_id],[Holiday_day_date],[CH_Workday])
SELECT [user_id] ,[CorporateHoliday_Hours_minute],[DailyDate],[win_id],[Holiday_day_date],[CH_Workday] FROM 
(
SELECT [user_id] ,[date],[Holiday_day_date],CAST(GETDATE() -1 AS DATE) AS [DailyDate] ,[win_id],[CorporateHoliday_Hours_minute],
CASE WHEN [Holiday_day_date] >= CAST (DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0) AS DATE) THEN 1 ELSE 0 END AS Daily_Flag, 
[CH_Workday] , deleted 
FROM (
		SELECT [date],[Holiday_day_date],[CH_Workday],[win_id],[CorporateHoliday_Hours_minute], [user_id],deleted,[rank],[updated],[Total_Minutes],
		dense_rank() over ( partition by [Holiday_day_date] , [win_id] order by [Total_Minutes] ASC )  as [rank_Total_Minutes]
		FROM 
		(
			SELECT T.[date] ,CAST(T.[date] AS DATE) [Holiday_day_date],
			((DATEPART(WEEKDAY, T.[date]))-2)[CH_Workday]
			,U.[nickname][win_id],
			Convert(NUMERIC(18, 2),(T.[hour] *60 + T.[minute] )/60,2)[CorporateHoliday_Hours_minute],T.[user_id] [user_id] ,T.deleted, 
			dense_rank() over ( partition by CAST(T.[date] AS DATE) , U.[nickname] order by T.updated desc )  as [rank] , T.updated , 
			DATEDIFF(MINUTE, T.updated, GETDATE() ) [Total_Minutes]
			FROM [xxxxx].[Openair].[xxxx] T
			LEFT JOIN [xxxxx].[Openair].[xxxx] PT ON PT.[id] = T.[project_task_id] 
			LEFT JOIN [xxxxx].[Openair].[xxx] U ON T.[user_id] = U.[id]
			WHERE  PT.[name] ='Corporate Holiday'
		) Temp  WHERE Temp.[rank] = 1		
	) TempFinal WHERE  TempFinal.[rank_Total_Minutes]  = 1  AND deleted != 1
) AS FinalResults WHERE Daily_Flag = 1

INSERT INTO #TempDeletedCorporateHoliday ([user_id],[CorporateHoliday_Hours_minute],[DailyDate],[win_id],[Holiday_day_date],[CH_Workday])
SELECT [user_id] ,[CorporateHoliday_Hours_minute],[DailyDate],[win_id],[Holiday_day_date],[CH_Workday] FROM 
(
SELECT [user_id] ,[date],[Holiday_day_date],CAST(GETDATE() -1 AS DATE) AS [DailyDate] ,[win_id],[CorporateHoliday_Hours_minute],
CASE WHEN [Holiday_day_date] >= CAST (DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0) AS DATE) THEN 1 ELSE 0 END AS Daily_Flag, 
[CH_Workday] , deleted 
FROM (
		SELECT [date],[Holiday_day_date],[CH_Workday],[win_id],[CorporateHoliday_Hours_minute], [user_id],deleted,[rank],[updated],[Total_Minutes],
		dense_rank() over ( partition by [Holiday_day_date] , [win_id] order by [Total_Minutes] ASC )  as [rank_Total_Minutes]
		FROM 
		(
			SELECT T.[date] ,CAST(T.[date] AS DATE) [Holiday_day_date],
			((DATEPART(WEEKDAY, T.[date]))-2)[CH_Workday]
			,U.[nickname][win_id],
			Convert(NUMERIC(18, 2),(T.[hour] *60 + T.[minute] )/60,2)[CorporateHoliday_Hours_minute],T.[user_id] [user_id] ,T.deleted, 
			dense_rank() over ( partition by CAST(T.[date] AS DATE) , U.[nickname] order by T.updated desc )  as [rank] , T.updated , 
			DATEDIFF(MINUTE, T.updated, GETDATE() ) [Total_Minutes]
			FROM [xxxxx].[Openair].[xxxx] T
			LEFT JOIN [xxxxx].[Openair].[xxxx] PT ON PT.[id] = T.[project_task_id] 
			LEFT JOIN [xxxxx].[Openair].[xxxx] U ON T.[user_id] = U.[id]
			WHERE  PT.[name] ='Corporate Holiday'			
		) Temp  WHERE Temp.[rank] = 1		
	) TempFinal WHERE  TempFinal.[rank_Total_Minutes]  = 1  AND deleted = 1
) AS FinalResults WHERE Daily_Flag = 1 

DELETE FROM  #TempDeletedCorporateHoliday  
WHERE  CONCAT(win_id,'_',Holiday_day_date) IN 
(
SELECT CONCAT(DCH.win_id,'_',DCH.Holiday_day_date) FROM #TempCorporateHoliday CH
INNER JOIN #TempDeletedCorporateHoliday DCH ON CH.[win_id] = DCH.[win_id] AND CH.Holiday_day_date = DCH.Holiday_day_date 
)

-- All Employees with actual work hours for last day
INSERT INTO #TempLastDayActualWorkHours ([DailyDate],[Holiday_day_date],[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute],[workday])
SELECT CASE WHEN CH.[DailyDate] is null THEN GETDATE()-1 ELSE CH.[DailyDate] END ,CH.Holiday_day_date,U.[name] [User],U.[nickname][User - User ID],
ISNULL(WWH.[workhours],0) [Resources - Base work schedule hours],
CASE WHEN [CorporateHoliday_Hours_minute] > WWH.[workhours] 
THEN  (ISNULL(WWH.[workhours],0) - ISNULL(WWH.[workhours],0)) 
ELSE (ISNULL(WWH.[workhours],0) - ISNULL([CorporateHoliday_Hours_minute],0)) END  [Adjusted Work Scheduled hours ],
ISNULL([CorporateHoliday_Hours_minute],0),@workday
FROM [xxxxx].[Openair].[xxxx] U 
LEFT JOIN [xxxxx].[Openair].[xxxx] W ON W.[user_id] =U.[id] AND W.[id] = U.[workschedule_id]
LEFT JOIN [xxxxx].[Openair].[xxxxxxxx] WWH ON WWH.[workschedule_id] = W.[account_workschedule_id] AND WWH.[workday]= @workday
LEFT JOIN #TempCorporateHoliday CH ON CH.[user_id] = U.[id] AND  CH.[Holiday_day_date] = CAST(GETDATE() -1 AS DATE)
WHERE  U.[custom_90] != '' AND  U.[nickname] NOT IN (SELECT [User - User ID] FROM [dbo].[xxxxx])
ORDER BY U.[nickname]

--update hrs zero for saturday and sunday

UPDATE #TempLastDayActualWorkHours SET [Resources - Base work schedule hours] = 0,[Adjusted Work Scheduled hours ] = 0 ,[CorporateHoliday_Hours_minute] = 0 
WHERE [workday] IN (5,6)

-- list of last day workschedule hours 
TRUNCATE TABLE #TempLastDayActualWorkHoursList
INSERT INTO #TempLastDayActualWorkHoursList([User - User ID], [workday] , [Resources - Base work schedule hours])
SELECT [User - User ID], [workday] , [Resources - Base work schedule hours] FROM #TempLastDayActualWorkHours

--insert last day records 
INSERT INTO [dbo].[xxxxxxxxx]
	(
		[DailyDate],[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute],[T_date_Pulled]
	)
SELECT [DailyDate],[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute],GETDATE()  
FROM #TempLastDayActualWorkHours

--delete last day corporate holiday
DELETE FROM  #TempCorporateHoliday  WHERE [Holiday_day_date] =  CAST(GETDATE() -1 AS DATE)
INSERT INTO #TempLastTwoMonthsActualWorkHours ([DailyDate],[Holiday_day_date],[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute])
SELECT CH.[DailyDate],[Holiday_day_date],U.[name] [User],U.[nickname][User - User ID],
ISNULL(WWH.[workhours],0) [Resources - Base work schedule hours],
CASE WHEN [CorporateHoliday_Hours_minute] > WWH.[workhours] 
THEN  (ISNULL(WWH.[workhours],0) - ISNULL(WWH.[workhours],0)) 
ELSE (ISNULL(WWH.[workhours],0) - ISNULL([CorporateHoliday_Hours_minute],0)) END  [Adjusted Work Scheduled hours ],
[CorporateHoliday_Hours_minute]
FROM [xxxxx].[Openair].[xxxxxxx] U 
LEFT JOIN #TempCorporateHoliday CH ON CH.[user_id] = U.[id] AND CH.[Holiday_day_date] <= CAST(GETDATE() -1 AS DATE)
LEFT JOIN [xxxxx].[Openair].[xxx] W ON W.[user_id] =U.[id] AND W.[id] = U.[workschedule_id]
LEFT JOIN [xxxxx].[Openair].[xxxxx] WWH ON WWH.[workschedule_id] = W.[account_workschedule_id] AND WWH.[workday]=CH.[CH_Workday]
WHERE  U.[custom_90] != ''  AND  U.[nickname] NOT IN (SELECT [User - User ID] FROM [dbo].[xxxxx]) 
ORDER BY U.[nickname]

--Update Last Two Months Records

UPDATE 
	ESD
SET
    ESD.[Adjusted Work Scheduled hours ]  =  TMA.[Adjusted Work Scheduled hours ], [CorporateHoliday_Hours_minute] = ISNULL( TMA.CorporateHoliday_Hours_minute,0),
	[T_date_Pulled] = GETDATE()    
FROM 
  [dbo].[T_Fact_EmployeeScheduleDaily] ESD
  INNER JOIN #TempLastTwoMonthsActualWorkHours TMA ON ESD.[User - User ID] = TMA.[User - User ID] AND ESD.DailyDate = TMA.Holiday_day_date 

TRUNCATE TABLE #TempLastTwoMonthsActualWorkHours
DELETE FROM  #TempDeletedCorporateHoliday  WHERE [Holiday_day_date] =  CAST(GETDATE() -1 AS DATE)

INSERT INTO #TempLastTwoMonthsActualWorkHours ([DailyDate],[Holiday_day_date],[User],[User - User ID],[Resources - Base work schedule hours],[Adjusted Work Scheduled hours ],[CorporateHoliday_Hours_minute])
SELECT CH.[DailyDate],[Holiday_day_date],U.[name] [User],U.[nickname][User - User ID],
ISNULL(WWH.[workhours],0) [Resources - Base work schedule hours],
CASE WHEN [CorporateHoliday_Hours_minute] > WWH.[workhours] 
THEN  ISNULL(WWH.[workhours],0) 
ELSE ISNULL(WWH.[workhours],0) - 0 END  [Adjusted Work Scheduled hours ],
0 as [CorporateHoliday_Hours_minute]
FROM [xxxxx].[Openair].[xxxxx] U 
LEFT JOIN #TempDeletedCorporateHoliday CH ON CH.[user_id] = U.[id] AND CH.[Holiday_day_date] <= CAST(GETDATE() -1 AS DATE)
LEFT JOIN [xxxxx].[Openair].[xxxx] W ON W.[user_id] =U.[id] AND W.[id] = U.[workschedule_id]
LEFT JOIN [xxxxx].[Openair].[xxx] WWH ON WWH.[workschedule_id] = W.[account_workschedule_id] AND WWH.[workday]=CH.[CH_Workday]
WHERE  U.[custom_90] != ''  AND  U.[nickname] NOT IN (SELECT [User - User ID] FROM [dbo].[xxxx]) 
ORDER BY U.[nickname]

--Updated Last Two Months Records aginst deleted corprate holidays 

UPDATE 
	ESD
SET
    ESD.[Adjusted Work Scheduled hours ]  =  TMA.[Adjusted Work Scheduled hours ], [CorporateHoliday_Hours_minute] = ISNULL( TMA.CorporateHoliday_Hours_minute,0),
	[T_date_Pulled] = GETDATE()    
FROM 
  [dbo].[T_Fact_EmployeeScheduleDaily] ESD
  INNER JOIN #TempLastTwoMonthsActualWorkHours TMA ON ESD.[User - User ID] = TMA.[User - User ID] AND ESD.[DailyDate] = TMA.[Holiday_day_date] 

IF(@DailyProcessFlag = 'process')
BEGIN
	TRUNCATE TABLE #TempLastTwoMonthWorkHoursList
	INSERT INTO #TempLastTwoMonthWorkHoursList([User - User ID],[Last_Work_Schedule_hours] ) 
	SELECT [User - User ID] , MAX([Resources - Base work schedule hours]) [Last_Work_Schedule_hours] 
	FROM [dbo].[T_Fact_EmployeeScheduleDaily] 
	WHERE DailyDate >= CAST (DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0) AS DATE)
	group by [User - User ID] 

	TRUNCATE TABLE #TempUpdateLastTwoMonthWorkHoursUsersList
	INSERT INTO #TempUpdateLastTwoMonthWorkHoursUsersList ([User - User ID] ,  [Resources - Base work schedule hours])
	SELECT TDA.[User - User ID],TDA.[Resources - Base work schedule hours] FROM #TempLastDayActualWorkHoursList TDA 
	INNER JOIN  #TempLastTwoMonthWorkHoursList TML ON TDA.[User - User ID] = TML.[User - User ID] AND TDA.[Resources - Base work schedule hours] <>  TML.[Last_Work_Schedule_hours]

	IF((SELECT COUNT([User - User ID]) FROM #TempUpdateLastTwoMonthWorkHoursUsersList) > 0 )
	BEGIN
		UPDATE ESD SET  ESD.[Resources - Base work schedule hours] = TMH.[Resources - Base work schedule hours],
		ESD.[Adjusted Work Scheduled hours ] = CAST( TMH.[Resources - Base work schedule hours] AS numeric(10,2)) - CAST(ESD.[CorporateHoliday_Hours_minute] AS numeric(10,2)),[T_date_Pulled] = GETDATE()   
		FROM [dbo].[xxx] ESD 
		INNER JOIN #TempUpdateLastTwoMonthWorkHoursUsersList TMH ON ESD.[User - User ID] =  TMH.[User - User ID]
		WHERE DailyDate >= CAST (DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0) AS DATE) AND DATEPART(WEEKDAY, DailyDate) NOT IN (1,7)
	END

   DELETE S
   FROM [xxx].[dbo].[xxxx] S
   LEFT JOIN xxx.[dbo].[xxx] E ON E.EE_WIN = S.[User - User ID] AND E.[Report Date] = (SELECT MAX([Report Date]) FROM xx.[dbo].[xxx])
   WHERE (DailyDate > E.[Termination Date]  OR DailyDate < E.LAST_HIRE_DATE ) 

END

END 
DROP TABLE #TempCorporateHoliday
DROP TABLE #TempLastDayActualWorkHours
DROP TABLE #TempLastTwoMonthsActualWorkHours
DROP TABLE #TempDeletedCorporateHoliday
DROP TABLE #TempLastTwoMonthWorkHoursList
DROP TABLE #TempUpdateLastTwoMonthWorkHoursUsersList
DROP TABLE #TempLastDayActualWorkHoursList

END  
