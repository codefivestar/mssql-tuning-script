----------------------------------------------------------------------------------------------------------
-- Author      : Hidequel Puga
-- Date        : 2021-07-21
-- Description : Find Statistics of the Whole Database
-- Ref         : https://blog.sqlauthority.com/2016/07/24/find-outdated-statistics-interview-question-week-081/
----------------------------------------------------------------------------------------------------------

-- Script 1: Modification Counter and Last Updated Statistics

	SELECT DISTINCT OBJECT_NAME(s.[object_id]) AS TableName
		 , c.name AS ColumnName
		 , s.name AS StatName
		 , STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated
		 , DATEDIFF(d, STATS_DATE(s.[object_id], s.stats_id), getdate()) DaysOld
		 , dsp.modification_counter
		 , s.auto_created
		 , s.user_created
		 , s.no_recompute
		 , s.[object_id]
		 , s.stats_id
		 , sc.stats_column_id
		 , sc.column_id
      FROM sys.stats s
INNER JOIN sys.stats_columns sc
	    ON sc.[object_id] = s.[object_id]
	   AND sc.stats_id = s.stats_id
INNER JOIN sys.columns c
	    ON c.[object_id] = sc.[object_id]
	   AND c.column_id = sc.column_id
INNER JOIN sys.partitions par
	    ON par.[object_id] = s.[object_id]
INNER JOIN sys.objects obj
	    ON par.[object_id] = obj.[object_id]
     CROSS APPLY sys.dm_db_stats_properties(sc.[object_id], s.stats_id) AS dsp
     WHERE OBJECTPROPERTY(s.OBJECT_ID, 'IsUserTable') = 1
	   AND (s.auto_created = 1 OR s.user_created = 1)
  ORDER BY DaysOld;
  
  
-- Script 2: Update Statistics for Database
EXEC sp_updatestats;
GO