USE [CapStone]
GO
/****** Object:  StoredProcedure [dbo].[CreditCardRule]    Script Date: 10/22/2019 8:28:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec dbo.CreditCardRule
-- =============================================
ALTER PROCEDURE  [dbo].[CreditCardRule]

AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from

-- interfering with SELECT statements.

SET NOCOUNT ON;

　

declare @var_LastModifiedUserID varchar(30) = 'Rule Engine'

,@var_LastModifiedDate datetime = getdate()

,@var_RuleID int = 1

,@var_limit int = 1
 

select MCMID, sessionid,@var_RuleID RuleID, 'Multiple Credit Cards' [Violation] into #result from dbo.CheckOutPage

group by MCMID, sessionid

having count(distinct CreditNumber) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID , 'Multiple Security Codes' from dbo.CheckOutPage

group by MCMID, sessionid,CreditNumber

having count(distinct SecurityCode) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID ,'Multiple Expiry Month' from dbo.CheckOutPage

group by MCMID, sessionid,CreditNumber

having count(distinct ExpiryMonth) > @var_limit

union all

select MCMID, sessionid,@var_RuleID RuleID, 'Multiple Expiry Year' from dbo.CheckOutPage

group by MCMID, sessionid,CreditNumber

having count(distinct ExpiryYear) > @var_limit
 
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
