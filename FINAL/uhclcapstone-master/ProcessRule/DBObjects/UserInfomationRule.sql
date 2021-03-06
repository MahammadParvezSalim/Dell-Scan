USE [CapStone]
GO
/****** Object:  StoredProcedure [dbo].[UserInfomationRule]    Script Date: 10/22/2019 8:28:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [dbo].[UserInfomationRule]

AS
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from

-- interfering with SELECT statements.

SET NOCOUNT ON;

declare @var_LastModifiedUserID varchar(30) = 'Rule Engine'

,@var_LastModifiedDate datetime = getdate()

,@var_RuleID int = 2

,@var_limit int = 2
 
select MCMID, sessionid,@var_RuleID RuleID , 'Multiple Email Address' [Violation] into #result from dbo.userInfo

group by MCMID, sessionid

having count(distinct EmailAddress) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID ,'Multiple FirstName' from dbo.userInfo

group by MCMID, sessionid

having count(distinct FirstName) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID, 'Multiple LastName' from dbo.userInfo

group by MCMID, sessionid

having count(distinct LastName) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID , 'Multiple City' from dbo.userInfo

group by MCMID, sessionid

having count(distinct City) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID, 'Multiple State' from dbo.userInfo

group by MCMID, sessionid

having count(distinct State) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID, 'Multiple PostalCode' from dbo.userInfo

group by MCMID, sessionid

having count(distinct PostalCode) > @var_limit

merge into dbo.RuleViolation as target

using #result as source

on target.MCMID = source.MCMID

and target.SessionID = source.SessionID

and target.RuleID = source.RuleID

and target.Violation = source.Violation

when not matched by target then

insert (MCMID , SessionID, RuleID, Violation,LastModifiedUserID, LastModifiedDate )

values (source.MCMID, source.SessionID, source.RuleID,source.Violation,@var_LastModifiedUserID,@var_LastModifiedDate);

select CONCAT('MCM Session: ',mcmid,' - ','Browsing Session : ', sessionid,' Violation: ', violation) as Message

from dbo.RuleViolation

where LastModifiedDate >= @var_LastModifiedDate

and RuleID= @var_RuleID

END

