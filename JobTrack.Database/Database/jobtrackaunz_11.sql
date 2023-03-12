-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 12, 2023 at 03:23 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `jobtrackaunz_11`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveCoversheetData` (`p_BPSProductID` VARCHAR(100), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT
A.CoversheetID,
A.CoversheetNumber,
A.CoversheetTier,
A.TaskNumber,
A.BPSProductID,
A.ServiceNumber,
B.UserName AS CurrentOwner,
A.DateUpdated
FROM CoversheetData A
LEFT JOIN jobtrackaunz_userdata.Employee B
ON B.EmployeeID = A.JobOwner
	 WHERE
     (A.OnlineStatus <> 'Completed'
    OR A.OnlineStatus IS NULL)
     AND
     A.BPSProductID = p_BPSProductID
	 AND 
     A.ServiceNumber = p_ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveJobCoversheetData` ()   BEGIN
SELECT
A.JobCoversheetID,
A.BPSProductID,
A.ServiceNumber, 
A.LatestTaskNumber,
A.DateCreated,
A.DateUpdated
FROM JobCoversheetData A
WHERE
     (A.OnlineStatus <> 'Completed'
    OR A.OnlineStatus IS NULL);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveJobData` ()   BEGIN
SELECT 
    A.JobNumber,
    A.ManuscriptTier,
    A.BPSProductID,
    A.ServiceNumber,
    C.PEName AS PEJobOwner,
    C.LEName AS LEJobOwner,
    A.DateCreated,
    D.DateCreated AS DateUpdated
FROM
    JobData A
        LEFT JOIN
    ManuscriptData B ON B.BPSProductID = A.BPSProductID
        AND B.ServiceNumber = A.ServiceNumber
        LEFT JOIN
    PublicationAssignment C ON C.BPSProductID = A.BPSProductID
        AND C.BPSProductID = B.BPSProductID
		LEFT JOIN
	TransactionLog D ON D.BPSProductID = A.BPSProductID
		AND D.ServiceNumber = A.ServiceNumber
WHERE
    B.ManuscriptStatus <> 'Completed'
GROUP BY A.BPSProductID , A.ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveJobDataCodingLog` (`p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(100), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT @rn:=@rn+1 AS rowNumber, 
TransactionLogID, 
CoversheetID, 
BPSProductID,
ServiceNumber,
ValueBefore,
ValueAfter,
DateCreated,
UserName
FROM
(
	SELECT
	D.TransactionLogID,
	D.TransactionLogIdentity AS CoversheetID,
	D.BPSProductID,
	D.ServiceNumber,
	D.ValueBefore,
	D.ValueAfter,
	D.DateCreated,
	D.UserName
	FROM
	TransactionLog D
	WHERE
	TransactionLogName = 'Coversheet'
	AND
	TransactionType = 'JobCoversheetReassignment'
	AND D.BPSProductID = p_BPSProductID
	AND D.ServiceNumber = p_ServiceNumber
    AND D.TransactionLogIdentity = p_CoversheetID
	ORDER BY D.TransactionLogID DESC
) t1, (SELECT @rn:=0) t2;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveJobDataLE` ()   BEGIN
SELECT
D.TransactionLogID,
LPAD(D.TransactionLogIdentity, 8, '0') AS JobNumber,
D.BPSProductID,
D.ServiceNumber,
D.ValueAfter AS CurrentOwner,
NULL AS DateCreated,
D.DateCreated AS DateUpdated
FROM
TransactionLog D
        LEFT JOIN
		ManuscriptData B 
        ON B.BPSProductID = D.BPSProductID
        AND B.ServiceNumber = D.ServiceNumber
WHERE
B.ManuscriptStatus <> 'Completed'
AND
D.TransactionLogName = 'Manuscript'
AND
D.TransactionType = 'JobReassignment LE'
AND D.DateCreated = (
	SELECT MAX(V2.DateCreated) 
    FROM TransactionLog V2 
    WHERE 
    D.BPSProductID = V2.BPSProductID 
    AND 
    D.ServiceNumber = V2.ServiceNumber
    AND V2.TransactionType = 'JobReassignment LE')
GROUP BY D.BPSProductID, D.ServiceNumber
ORDER BY D.DateCreated DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveJobDataLELog` (`p_BPSProductID` VARCHAR(100), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT @rn:=@rn+1 AS rowNumber, 
TransactionLogID, 
JobNumber, 
BPSProductID,
ServiceNumber,
ValueBefore,
ValueAfter,
DateCreated,
UserName
FROM
(
	SELECT
	D.TransactionLogID,
	D.TransactionLogIdentity AS JobNumber,
	D.BPSProductID,
	D.ServiceNumber,
	D.ValueBefore,
	D.ValueAfter,
	D.DateCreated,
	D.UserName
	FROM
	TransactionLog D
	WHERE
	TransactionLogName = 'Manuscript'
	AND
	TransactionType = 'JobReassignment LE'
	AND D.BPSProductID = p_BPSProductID
	AND D.ServiceNumber = p_ServiceNumber
	ORDER BY D.TransactionLogID DESC
) t1, (SELECT @rn:=0) t2;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveJobDataPE` ()   BEGIN
SELECT
D.TransactionLogID,
LPAD(D.TransactionLogIdentity, 8, '0') AS JobNumber,
D.BPSProductID,
D.ServiceNumber,
D.ValueAfter AS CurrentOwner,
NULL AS DateCreated,
D.DateCreated AS DateUpdated
FROM
TransactionLog D
        LEFT JOIN
		ManuscriptData B 
        ON B.BPSProductID = D.BPSProductID
        AND B.ServiceNumber = D.ServiceNumber
WHERE
B.ManuscriptStatus <> 'Completed'
AND
D.TransactionLogName = 'Manuscript'
AND
D.TransactionType = 'JobReassignment PE'
AND D.DateCreated = (
	SELECT MAX(V2.DateCreated) 
    FROM TransactionLog V2 
    WHERE 
    D.BPSProductID = V2.BPSProductID 
    AND 
    D.ServiceNumber = V2.ServiceNumber
    AND V2.TransactionType = 'JobReassignment PE')
GROUP BY D.BPSProductID, D.ServiceNumber
ORDER BY D.DateCreated DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveJobDataPELog` (`p_BPSProductID` VARCHAR(100), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT @rn:=@rn+1 AS rowNumber, 
TransactionLogID, 
JobNumber, 
BPSProductID,
ServiceNumber,
ValueBefore,
ValueAfter,
DateCreated,
UserName
FROM
(
	SELECT
	D.TransactionLogID,
	D.TransactionLogIdentity AS JobNumber,
	D.BPSProductID,
	D.ServiceNumber,
	D.ValueBefore,
	D.ValueAfter,
	D.DateCreated,
	D.UserName
	FROM
	TransactionLog D
	WHERE
	TransactionLogName = 'Manuscript'
	AND
	TransactionType = 'JobReassignment PE'
	AND D.BPSProductID = p_BPSProductID
	AND D.ServiceNumber = p_ServiceNumber
	ORDER BY D.TransactionLogID DESC
) t1, (SELECT @rn:=0) t2;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllBPSProductIDJobs` ()   BEGIN
select distinct BPSProductID
from jobdata
order by BPSProductID asc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllCompletionEmail` ()   BEGIN
SELECT * FROM jobtrackaunz.completionemail_mt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllCoversheetData` ()   BEGIN
SELECT 
*
 FROM CoversheetData;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllEmployee` ()   BEGIN
SELECT 
	A.EmployeeID,
	B.UserAccessName,
    A.Status,
	A.UserName,
	A.FirstName,
	A.LastName,
    A.FullName,
	A.EmailAddress,
	A.IsManager,
	A.IsEditorialContact,
	A.IsEmailList,
	A.IsMandatoryRecepient,
	A.IsShowUser,
    A.DateCreated,
	A.PasswordUpdateDate
FROM 
	jobtrackaunz_userdata.Employee A
	LEFT JOIN jobtrackaunz_userdata.UserAccess_MT B
	ON B.UserAccessID = A.UserAccessID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobCoversheetData` ()   BEGIN
SELECT
JobCoversheetID, 
CoversheetTier, 
BPSProductID,
ServiceNumber, 
-- TargetPressDate, ActualPressDate,
LatestTaskNumber,
CodingStatus, 
PDFQAStatus, 
OnlineStatus, 
DateCreated
FROM JobCoversheetData;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobCoversheetDataByUserNameLE` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT
	A.JobCoversheetID, 
    A.CoversheetTier, 
    A.BPSProductID,
	A.ServiceNumber, 
    A.TargetPressDate, 
    A.ActualPressDate,
	A.LatestTaskNumber,
	A.CodingStatus, 
    A.PDFQAStatus, 
    A.OnlineStatus, 
    A.DateCreated
    -- C.UserName
FROM JobCoversheetData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.ValueAfter
WHERE C.EmployeeID = p_EmployeeID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobCoversheetDataByUserNamePE` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT
	A.JobCoversheetID, 
    A.CoversheetTier, 
    A.BPSProductID,
	A.ServiceNumber, 
    A.TargetPressDate, 
    A.ActualPressDate,
	A.LatestTaskNumber,
	A.CodingStatus, 
    A.PDFQAStatus, 
    A.OnlineStatus, 
    A.DateCreated
    -- C.UserName
FROM JobCoversheetData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.ValueAfter
WHERE C.EmployeeID = p_EmployeeID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobData` ()   BEGIN
SELECT 
JobID, JobNumber, ManuscriptTier, BPSProductID,
ServiceNumber, TargetPressDate, ActualPressDate,
CopyEditStatus, CodingStatus, OnlineStatus, STPStatus, DateCreated
FROM JobData;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobDataByUserName` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee
WHERE Username = p_Username;

SELECT 
A.JobID, 
A.JobNumber, 
A.ManuscriptTier, 
A.BPSProductID,
A.ServiceNumber, 
A.TargetPressDate, 
A.ActualPressDate,
A.CopyEditStatus, 
A.CodingStatus, 
A.OnlineStatus, 
A.STPStatus, 
A.DateCreated
FROM JobData A
LEFT JOIN jobtrackaunz_userdata.Employee B
ON B.EmployeeID = A.CreatedEmployeeID
WHERE A.CreatedEmployeeID = p_EmployeeID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobDataByUserNameLE` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT
A.JobID, 
A.JobNumber, 
A.ManuscriptTier, 
A.BPSProductID,
A.ServiceNumber, 
A.TargetPressDate, 
A.ActualPressDate,
A.CopyEditStatus, 
A.CodingStatus, 
A.OnlineStatus, 
A.STPStatus, 
A.DateCreated
FROM JobData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.ValueAfter
WHERE C.EmployeeID = p_EmployeeID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobDataByUserNamePE` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT
A.JobID, 
A.JobNumber, 
A.ManuscriptTier, 
A.BPSProductID,
A.ServiceNumber, 
A.TargetPressDate, 
A.ActualPressDate,
A.CopyEditStatus, 
A.CodingStatus, 
A.OnlineStatus, 
A.STPStatus, 
A.DateCreated
FROM JobData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.ValueAfter
WHERE C.EmployeeID = p_EmployeeID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllJobTrackData` ()   BEGIN
SELECT 
A.JobID, B.ManuscriptID, B.JobNumber,
A.ManuscriptTier, A.BPSProductID, A.ServiceNumber, 
B.ManuscriptLegTitle, B.ManuscriptStatus,
A.TargetPressDate, A.ActualPressDate, 
B.LatupAttribution, B.DateReceivedFromAuthor, A.DateCreated as JobDateCreated, B.DateCreated as ManuscriptDateCreated, B.UpdateType,
B.JobSpecificInstruction, B.TaskType,
B.PEGuideCard, B.PECheckbox, B.PETaskNumber, B.RevisedOnlineDueDate,
B.CopyEditDueDate, B.CopyEditStartDate, B.CopyEditDoneDate, B.CopyEditStatus as ManuscriptCopyEditStatus,
B.CodingDueDate, B.CodingDoneDate, B.CodingStatus as ManuscriptCodingStatus,
B.OnlineDueDate, B.OnlineDoneDate, B.OnlineStatus as ManuscriptOnlineStatus,
B.PESTPStatus as ManuscriptSTPStatus, 
B.EstimatedPages, B.ActualTurnAroundTime,
B.OnlineTimeliness, B.ReasonIfLate, B.PECoversheetNumber,
A.CopyEditStatus as JobEditStatus, A.CodingStatus as JobCodingStatus,
A.OnlineStatus as JobOnlineStatus, A.STPStatus as JobOnlineStatus
FROM JOBDATA A
LEFT JOIN MANUSCRIPTDATA B
ON A.BPSPRODUCTID = B.BPSPRODUCTID
AND A.SERVICENUMBER = B.SERVICENUMBER
Order By JobId ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllLegislation` ()   BEGIN
SELECT * FROM jobtrackaunz.legislationdata;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllLegislationData` ()   BEGIN
SELECT 
*
 FROM LegislationNewData;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllManuscriptData` ()   BEGIN
SELECT 
*
FROM 
Manuscriptdata
ORDER BY ManuscriptID DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllProductLevel` ()   BEGIN
SELECT * FROM PRODUCTLEVEL;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllProducts` ()   BEGIN
SELECT 
OwnerUserID,
LegalEditor,
OriginalID,
BPSProductID,
ProductName,
ChargeCode,
TargetPressDate,
RevisedPressDate,
Month,
Tier,
Team,
ServiceNo,
ChargeType,
BPSSublist,
ReasonForRevisedPressDate,
isSPI,
ServiceUpdate,
ForecastPages,
ActualPages
 FROM Product_MT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPublicationAssignmentData` ()   BEGIN
SELECT * FROM jobtrackaunz.publicationassignment;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPublicationAssignmentLEUsers` ()   BEGIN
SELECT DISTINCT LEUserName from publicationassignment;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPublicationAssignmentPEUsers` ()   BEGIN
SELECT DISTINCT PEUserName from publicationassignment;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPubschedBPSProductID` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT 
A.BPSProductID
FROM PublicationAssignment A
LEFT JOIN PubSched_MT B
ON B.BPSProductID = A.BPSProductID
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = A.LEUserName
WHERE C.EmployeeID = p_EmployeeID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPubschedBPSProductIDServiceNumber` ()   BEGIN
select BPSProductID, ServiceNumber
from pubsched_mt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPubschedServiceNumber` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100))   BEGIN
IF (p_ServiceNumber IS NULL) THEN
select PubSchedTier, bpsproductid, servicenumber, 
CASE WHEN 
budgetpressdate <> '1900-01-01' 
THEN budgetpressdate 
ELSE revisedpressdate END 
AS TargetPressDate
-- COALESCE(NULLIF(budgetpressdate, '1900-01-01'), revisedpressdate) as TargetPressDate, 
from pubsched_mt
where
BPSProductID = p_BPSProductID
order by ServiceNumber asc;
END IF;
IF (p_ServiceNumber IS NOT NULL) THEN
select PubSchedTier, bpsproductid, servicenumber, 
CASE WHEN 
budgetpressdate <> '1900-01-01' 
THEN budgetpressdate 
ELSE revisedpressdate END 
AS TargetPressDate
-- COALESCE(NULLIF(budgetpressdate, '1900-01-01'), revisedpressdate) as TargetPressDate, 
from pubsched_mt
where
BPSProductID = p_BPSProductID
and
ServiceNumber = p_ServiceNumber
order by ServiceNumber asc;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPubschedTier` ()   BEGIN
select distinct PubSchedTier
from pubsched_mt
order by pubschedtier asc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPubschedTierJobs` ()   BEGIN
select distinct PubSchedTier
from jobdata
order by pubschedtier asc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPubSched_MT` ()   BEGIN
SELECT * FROM jobtrackaunz.pubsched_mt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllSendToPrintData` ()   BEGIN
SELECT 
*
 FROM SendToPrintData;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllSendToPrintDataByUserNamePE` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT
	A.SendToPrintID,
    A.SendToPrintNumber,
    A.SendToPrintTier, 
    A.BPSProductID,
	A.ServiceNumber,
    A.CurrentTask,
    A.SendToPrintStatus,
    A.TargetPressDate, 
    A.ActualPressDate,
    
    A.ConsoHighlightStartDate,
    A.ConsoHighlightDoneDate,
    A.FilingInstructionStartDate,
    A.FilingInstructionDoneDate,
    A.DummyFiling1StartDate,
    A.DummyFiling1DoneDate,
    A.DummyFiling2StartDate,
    A.DummyFiling2DoneDate,
    A.UECJStartDate,
    A.UECJDoneDate,
    A.PC1PC2StartDate,
    A.PC1PC2DoneDate,
    A.PostingBackToStableDataStartDate,
    A.PostingBackToStableDataDoneDate,
    A.UpdatingOfEBinderStartDate,
    A.UpdatingOfEBinderDoneDate,
    
    A.DateCreated
FROM SendToprintData A
WHERE A.CreatedEmployeeID = p_EmployeeID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllSendToPrintDataByUserNameSTP` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT
	A.SendToPrintID,
    A.SendToPrintNumber,
    A.SendToPrintTier, 
    A.BPSProductID,
	A.ServiceNumber,
    A.CurrentTask,
    A.SendToPrintStatus,
    A.TargetPressDate, 
    A.ActualPressDate,
    
    A.ConsoHighlightStartDate,
    A.ConsoHighlightDoneDate,
    A.FilingInstructionStartDate,
    A.FilingInstructionDoneDate,
    A.DummyFiling1StartDate,
    A.DummyFiling1DoneDate,
    A.DummyFiling2StartDate,
    A.DummyFiling2DoneDate,
    A.UECJStartDate,
    A.UECJDoneDate,
    A.PC1PC2StartDate,
    A.PC1PC2DoneDate,
    A.PostingBackToStableDataStartDate,
    A.PostingBackToStableDataDoneDate,
    A.UpdatingOfEBinderStartDate,
    A.UpdatingOfEBinderDoneDate,
    
    A.DateCreated
FROM SendToprintData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.ValueAfter
WHERE C.EmployeeID = p_EmployeeID
AND find_in_set(A.SendToPrintID, B.TransactionLogIdentity);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllServiceNumberJobs` ()   BEGIN
select distinct ServiceNumber
from jobdata
order by ServiceNumber asc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllTaskLevel` ()   BEGIN
SELECT * FROM TASKLEVEL;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllTurnAroundTime` ()   BEGIN
SELECT
TurnAroundTimeID,
A.ManusType as UpdateType,
B.TaskType,
DaysPerTaskEdit as TATCopyEdit,
DaysPerTaskProcess as TATCoding,
DaysPerTaskApproval as TATApproval,
DaysPerTaskOnline as TATOnline,
A.BenchMarkDays
FROM jobtrackaunz.turnaroundtime_mt A
LEFT JOIN jobtrackaunz.updatetype_mt B
ON A.ManusType = B.UpdateType;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUpdateTypes` ()   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT UpdateType,
TaskType,
CopyEditDays,
ProcessDays,
OnlineDays,
PDFQADays,
BenchMarkDays,
IsEdit FROM UpdateType_MT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUpdateTypesID` ()   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT 
ID
UpdateType,
TaskType,
CopyEditDays,
ProcessDays,
OnlineDays,
PDFQADays,
BenchMarkDays,
IsEdit FROM UpdateType_MT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUserAccess` ()   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT ID as UserAccessID, UserAccess FROM UserAccess_MT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUserNames` ()   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT
UserName
From Employee;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUserPassword` ()   BEGIN
 SELECT
 A.EmployeeID,
 A.UserName,
 A.Password,
 A.FirstName,
 A.LastName,
 B.UserAccessName
 FROM 
 Employee A
 LEFT JOIN 
 UserAccess_MT B
 ON A.UserAccessID = B.UserAccessID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUsers` ()   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT 
	A.ID as EmployeeID,
	B.UserAccess,
	CreatedDate,
	Username,
	FirstName,
	LastName,
	EmailAddress,
	IsManager,
	IsEditoralContact,
	IsEmailList,
	IsMandatoryRecepient,
	IsShowUser,
	PasswordUpdateDate
FROM 
	Employee A
	LEFT JOIN UserAccess_MT B
	ON B.ID = A.UserAccessID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCallToActionData` (`p_CallToActionIdentity` INT, `p_CallToActionName` VARCHAR(100), `p_BPSProductID` VARCHAR(100), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT 
*
 FROM CallToActionData
 WHERE CallToActionIdentity = p_CallToActionIdentity
 AND CallToActionName = p_CallToActionName
 AND BPSProductID = p_BPSProductID
 AND ServiceNumber = p_ServiceNumber
 ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetByProductIDServiceNumber` (`p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT * FROM jobtrackaunz.coversheet_mt
WHERE 
BPSProductID = p_BPSProductID
AND
ServiceNumber = p_ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetCreatedEmail` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_RealUpdateType varchar(50);
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
	SELECT
	EmailAddress
	FROM jobtrackaunz_userdata.Employee A
	LEFT JOIN CoversheetData B
	ON A.EmployeeID = B.CreatedEmployeeID
	WHERE
	B.CoversheetID = p_CoversheetID
	AND B.JobOwner = p_EmployeeID;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetDataAll` ()   BEGIN
SELECT
A.CoversheetID,
A.CoversheetNumber,
A.CoversheetTier,
A.TaskNumber,
A.BPSProductID,
A.ServiceNumber,
A.GuideCard,
A.LocationOfManuscript,
A.FurtherInstruction,
A.CurrentTask,
A.TaskStatus,
A.TargetPressDate,
A.ActualPressDate,
A.CodingDueDate,
A.CodingStartDate,
A.CodingDoneDate,
A.OnlineDueDate,
A.OnlineStartDate,
A.OnlineDoneDate,
A.OnlineTimeliness,
A.ReasonIfLate,
B.UserName AS JobOwner,
A.CoversheetCheckbox,
A.OnlineStatus
FROM CoversheetData A
LEFT JOIN jobtrackaunz_userdata.Employee B
ON B.EmployeeID = A.JobOwner;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetDataByCoding` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100), `p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT
A.CoversheetID,
A.CoversheetNumber,
A.CoversheetTier,
A.TaskNumber,
A.BPSProductID,
A.ServiceNumber,
A.GuideCard,
A.LocationOfManuscript,
A.FurtherInstruction,
A.CurrentTask,
A.TaskStatus,
A.TargetPressDate,
A.ActualPressDate,
A.CodingDueDate,
A.CodingStartDate,
A.CodingDoneDate,
A.OnlineDueDate,
A.OnlineStartDate,
A.OnlineDoneDate,
A.OnlineTimeliness,
A.ReasonIfLate,
B.ValueAfter AS JobOwner
FROM CoversheetData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
WHERE 
A.JobOwner = p_EmployeeID
AND
B.ValueAfter = p_Username
AND
A.BPSProductID = p_BPSProductID
AND
A.ServiceNumber = p_ServiceNumber
AND
B.TransactionType = 'JobCoversheetReassignment';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetDataByCoversheetID` (`p_CoversheetID` INT)   BEGIN
SELECT 
*
 FROM CoversheetData
 WHERE coversheetid = p_CoversheetID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetDataByID` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT
A.CoversheetID,
A.CoversheetNumber,
A.CoversheetTier,
A.TaskNumber,
A.BPSProductID,
A.ServiceNumber,
A.GuideCard,
A.LocationOfManuscript,
A.FurtherInstruction,
A.CurrentTask,
A.TaskStatus,
A.TargetPressDate,
A.ActualPressDate,
A.CodingDueDate,
A.CodingStartDate,
A.CodingDoneDate,
A.OnlineDueDate,
A.OnlineStartDate,
A.OnlineDoneDate,
A.OnlineTimeliness,
A.ReasonIfLate,
B.UserName AS JobOwner,
A.CoversheetCheckbox,
A.OnlineStatus
FROM CoversheetData A
LEFT JOIN jobtrackaunz_userdata.Employee B
ON B.EmployeeID = A.JobOwner
	 WHERE A.BPSProductID = p_BPSProductID
	 AND A.ServiceNumber = p_ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetDataBySendToPrintID` (`p_SendToPrintID` INT(11))   BEGIN
SELECT
A.CoversheetID,
A.CoversheetTier,
A.BPSProductID,
A.ServiceNumber,
A.CoversheetNumber,
A.GuideCard,
A.LocationOfManuscript,
A.FurtherInstruction
FROM CoversheetData A
	LEFT JOIN
	SendToPrintData B
    ON 
    find_in_set(A.CoversheetID, B.CoversheetID)
WHERE 
B.SendToPrintID = p_SendToPrintID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCoversheetDataMax` (`p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_coversheetids` VARCHAR(50))   BEGIN
SELECT 
A.CoversheetID,
A.CoversheetTier,
A.BPSProductID,
A.ServiceNumber,
A.TargetPressDate,
A.DateCreated
 FROM CoversheetData A
 WHERE find_in_set(CoversheetID, p_coversheetids)
 AND BPSProductID = p_BPSProductID
 AND ServiceNumber = p_ServiceNumber
 ORDER BY A.DateCreated ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetJobCoversheetData` (`p_Username` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT DISTINCT
	A.JobCoversheetID, 
    A.CoversheetTier, 
    A.BPSProductID,
	A.ServiceNumber, 
    A.TargetPressDate, 
    A.ActualPressDate,
	A.LatestTaskNumber,
	A.CodingStatus, 
    A.PDFQAStatus, 
    A.OnlineStatus, 
    A.DateCreated
FROM JobCoversheetData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.ValueAfter
WHERE C.EmployeeID = p_EmployeeID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetJobCoversheetDataByJobCoversheetID` (`p_JobCoversheeetID` INT)   BEGIN
SELECT 
*
 FROM JobCoversheetData
 WHERE jobcoversheetid = p_JobCoversheeetID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetJobCoversheetDataByUserNameLE` (`p_Username` VARCHAR(45))   BEGIN
SELECT DISTINCT
	A.JobCoversheetID, 
    A.CoversheetTier, 
    A.BPSProductID,
	A.ServiceNumber, 
    A.TargetPressDate, 
    A.ActualPressDate,
	A.LatestTaskNumber,
	A.CodingStatus, 
    A.PDFQAStatus, 
    A.OnlineStatus, 
    A.DateCreated
    -- C.UserName
FROM JobCoversheetData A
LEFT JOIN PublicationAssignment B
ON B.BPSProductID = A.BPSProductID
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.LEUserName
WHERE C.EmployeeID = p_EmployeeID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetJobCoversheetDataByUserNamePE` (`p_Username` VARCHAR(45))   BEGIN
SELECT DISTINCT
	A.JobCoversheetID, 
    A.CoversheetTier, 
    A.BPSProductID,
	A.ServiceNumber, 
    A.TargetPressDate, 
    A.ActualPressDate,
	A.LatestTaskNumber,
	A.CodingStatus, 
    A.PDFQAStatus, 
    A.OnlineStatus, 
    A.DateCreated
    -- C.UserName
FROM JobCoversheetData A
LEFT JOIN PublicationAssignment B
ON B.BPSProductID = A.BPSProductID
LEFT JOIN jobtrackaunz_userdata.Employee C
ON C.UserName = B.PEUserName
WHERE C.EmployeeID = p_EmployeeID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetJobDataByID` (`p_JobNumber` INT(8))   BEGIN
SELECT 
*
 FROM JobData
 WHERE
 JobNumber = p_JobNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetJobManuscript` ()   BEGIN
SELECT 
*
 FROM jobtrackaunz.jobdata
 inner join jobtrackaunz.manuscript
 on jobdata.BPSProductID = manuscript.BPSProductID
 and jobdata.ServiceNumber = manuscript.ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLastInsertedJobID` ()   BEGIN
SELECT IFNULL(MAX(JobID), 0) AS JobID FROM jobdata;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLastInsertedManuscriptID` ()   BEGIN
SELECT MAX(ManuscriptID) AS ManuscriptID FROM manuscript;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLegislationDataBySendToPrintID` (`p_SendToPrintID` INT(11))   BEGIN
SELECT
A.LegislationID,
A.BPSProductID,
A.ServiceNumber,
A.PrincipalLegislation,
A.AmendingLegislation,
A.CommencementDate,
A.UpdateType,
A.GuideCard,
A.TaskNumber,
A.OnlineActualDueDate,
A.CodingActualDate,
A.OnlineActualDate,
A.TotalOutput,
A.LegislationMaterialStatus,
A.SendToPrintID
FROM LegislationNewData A
	 WHERE A.SendToPrintID = p_SendToPrintID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetManuscriptByID` (`p_ManuscriptID` INT(11))   BEGIN
SELECT 
*
 FROM Manuscript
 WHERE ManuscriptID = p_ManuscriptID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetManuscriptDataByID` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT 
*
 FROM Manuscriptdata
 WHERE BPSProductID = p_BPSProductID
 AND ServiceNumber = p_ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetManuscriptDataByManuscriptID` (`p_ManuscriptID` INT)   BEGIN
SELECT 
*
 FROM Manuscriptdata
 WHERE manuscriptid = p_ManuscriptID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetManuscriptDataDateCreated` (`p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_manuscriptids` VARCHAR(50))   BEGIN
SELECT
A.DateCreated
 FROM Manuscriptdata A
 WHERE find_in_set(ManuscriptID, p_manuscriptids)
 AND BPSProductID = p_BPSProductID
 AND ServiceNumber = p_ServiceNumber
 ORDER BY A.DateCreated ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetManuscriptDataMaxTurnAroundTime` (`p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_manuscriptids` VARCHAR(50))   BEGIN
SELECT 
A.ManuscriptID,
A.ManuscriptTier,
A.BPSProductID,
A.ServiceNumber,
A.TargetPressDate,
A.UpdateType,
A.TaskType,
A.PEGuideCard,
A.CodingDueDate,
A.OnlineDueDate,
A.DateCreated
 FROM Manuscriptdata A
 LEFT JOIN turnaroundtime_mt B
 ON B.ManusType = A.UpdateType
 WHERE find_in_set(ManuscriptID, p_manuscriptids)
 AND BPSProductID = p_BPSProductID
 AND ServiceNumber = p_ServiceNumber
 ORDER BY B.TurnAroundTimeID DESC, A.DateCreated ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductByProductName` (`p_varchar_productName` VARCHAR(100))   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT 
ID, 
ProductName,
OwnerUserID,
LegalEditor,
OriginalID,
BPSProductID,
ProductName,
ChargeCode,
TargetPressDate,
RevisedPressDate,
Month,
Tier,
Team,
ServiceNo,
ChargeType,
BPSSublist,
REasonForREvisedPressDate,
isSPI,
ServiceUpdate,
ForecastPages,
ActualPages
FROM Product_MT
WHERE ProductName = p_varchar_productName;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductDatabaseByID` (`p_PubSchedID` INT(11))   BEGIN
SELECT 
*
 FROM jobtrackaunz.pubsched_mt
 WHERE PubSchedID = p_PubSchedID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSendToPrintDataAll` ()   BEGIN
SELECT
	A.SendToPrintID,
    A.SendToPrintNumber,
    A.SendToPrintTier, 
    A.BPSProductID,
	A.ServiceNumber,
    A.CurrentTask,
    A.SendToPrintStatus,
    A.TargetPressDate, 
    A.ActualPressDate,
    
    A.ConsoHighlightStartDate,
    A.ConsoHighlightDoneDate,
    A.FilingInstructionStartDate,
    A.FilingInstructionDoneDate,
    A.DummyFiling1StartDate,
    A.DummyFiling1DoneDate,
    A.DummyFiling2StartDate,
    A.DummyFiling2DoneDate,
    A.UECJStartDate,
    A.UECJDoneDate,
    A.PC1PC2StartDate,
    A.PC1PC2DoneDate,
    A.PostingBackToStableDataStartDate,
    A.PostingBackToStableDataDoneDate,
    A.UpdatingOfEBinderStartDate,
    A.UpdatingOfEBinderDoneDate,
    
    A.DateCreated
FROM SendToprintData A;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSendToPrintDataByID` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT
A.SendToPrintID,
A.SendToPrintNumber,
A.SendToPrintTier,
A.BPSProductID,
A.ServiceNumber,
A.CurrentTask,
A.TaskStatus,
--
A.TargetPressDate,
A.ActualPressDate,
--
A.ConsoHighlightStartDate,
A.ConsoHighlightDoneDate,
A.FilingInstructionStartDate,
A.FilingInstructionDoneDate,
A.DummyFiling1StartDate,
A.DummyFiling1DoneDate,
A.DummyFiling2StartDate,
A.DummyFiling2DoneDate,
A.UECJStartDate,
A.UECJDoneDate,
A.PC1PC2StartDate,
A.PC1PC2DoneDate,
A.PostingBackToStableDataStartDate,
A.PostingBackToStableDataDoneDate,
A.UpdatingofEBinderStartDate,
A.UpdatingofEBinderDoneDate,

B.UserName AS JobOwner,
A.SendToPrintCheckbox,
A.SendToPrintStatus
FROM CoversheetData A
LEFT JOIN jobtrackaunz_userdata.Employee B
ON B.EmployeeID = A.JobOwner
	 WHERE A.BPSProductID = p_BPSProductID
	 AND A.ServiceNumber = p_ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSendToPrintDataBySendToPrintID` (`p_SendToPrintID` INT)   BEGIN
SELECT
A.SendToPrintID,
A.SendToPrintNumber,
A.BPSProductID,
A.ServiceNumber,
A.SendToPrintTier,
A.TargetPressDate,
A.PathOfInputFiles,
A.SpecialInstruction,
A.LegislationMaterials,
A.AcceptedDate,
A.JobOwner,
A.SendToPrintStatus,
A.UpdateEmailCC,
A.DateCreated,
	A.ConsoHighlight,
    A.FilingInstruction,
    A.DummyFiling1,
    A.DummyFiling2,
    A.UECJ,
    A.PC1PC2,
    A.ReadyToPrint,
    A.SendingFinalPagesToPuddingburn,
    A.PostingBackToStableData,
    A.UpdatingOfEBinder,
		A.ConsoHighlightOwner,
		A.ConsoHighlightStartDate,
		A.ConsoHighlightDoneDate,
        A.ConsoHighlightStatus,
	A.FilingInstructionOwner,
	A.FilingInstructionStartDate,
	A.FilingInstructionDoneDate,
	A.FilingInstructionStatus,
		A.DummyFiling1Owner,
		A.DummyFiling1StartDate,
		A.DummyFiling1DoneDate,
		A.DummyFiling1Status,
	A.DummyFiling2Owner,
	A.DummyFiling2StartDate,
	A.DummyFiling2DoneDate,
	A.DummyFiling2Status,
		A.UECJOwner, 
		A.UECJStartDate,
		A.UECJDoneDate,
		A.UECJStatus,
	A.PC1PC2Owner,
	A.PC1PC2StartDate,
	A.PC1PC2DoneDate,
	A.PC1PC2Status,
 A.ReadyToPrintAttachmentBody, 
 A.ReadyToPrintAttachmentName, 
 A.ReadyToPrintAttachmentSize,
 A.ReadyToPrintStatus,
 A.PuddingburnAttachmentBody,
 A.PuddingburnAttachmentName, 
 A.PuddingburnAttachmentSize,
 A.PuddingburnStatus,
	A.PostingBackToStableDataOwner,
	A.PostingBackToStableDataStartDate,
	A.PostingBackToStableDataDoneDate, 
	A.PostingBackToStableDataStatus,
		A.UpdatingOfEBinderOwner,
		A.UpdatingOfEBinderStartDate,
		A.UpdatingOfEBinderDoneDate,
		A.UpdatingOfEBinderStatus,
A.ReadyToPrintAttachmentBody,
A.ReadyToPrintStatus,
A.PuddingburnAttachmentBody,
A.PuddingburnStatus
FROM 
SendToPrintData A
	WHERE 
	A.SendToPrintID = p_SendToPrintID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSendToPrintDataBySTP` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100), `p_Username` VARCHAR(45))   BEGIN

SELECT DISTINCT
A.SendToPrintID,
A.SendToPrintNumber,
A.BPSProductID,
A.ServiceNumber,
A.SendToPrintTier,
A.TargetPressDate,
A.PathOfInputFiles,
A.SpecialInstruction,
A.LegislationMaterials,
A.AcceptedDate,
A.JobOwner,
A.SendToPrintStatus,
A.UpdateEmailCC,
A.DateCreated,
	A.ConsoHighlight,
    A.FilingInstruction,
    A.DummyFiling1,
    A.DummyFiling2,
    A.UECJ,
    A.PC1PC2,
    A.ReadyToPrint,
    A.SendingFinalPagesToPuddingburn,
    A.PostingBackToStableData,
    A.UpdatingOfEBinder,
		A.ConsoHighlightOwner,
		A.ConsoHighlightStartDate,
		A.ConsoHighlightDoneDate,
        A.ConsoHighlightStatus,
	A.FilingInstructionOwner,
	A.FilingInstructionStartDate,
	A.FilingInstructionDoneDate,
	A.FilingInstructionStatus,
		A.DummyFiling1Owner,
		A.DummyFiling1StartDate,
		A.DummyFiling1DoneDate,
		A.DummyFiling1Status,
	A.DummyFiling2Owner,
	A.DummyFiling2StartDate,
	A.DummyFiling2DoneDate,
	A.DummyFiling2Status,
		A.UECJOwner, 
		A.UECJStartDate,
		A.UECJDoneDate,
		A.UECJStatus,
	A.PC1PC2Owner,
	A.PC1PC2StartDate,
	A.PC1PC2DoneDate,
	A.PC1PC2Status,
 A.ReadyToPrintAttachmentBody, 
 A.ReadyToPrintAttachmentName, 
 A.ReadyToPrintAttachmentSize,
 A.ReadyToPrintStatus,
 A.PuddingburnAttachmentBody,
 A.PuddingburnAttachmentName, 
 A.PuddingburnAttachmentSize,
 A.PuddingburnStatus,
	A.PostingBackToStableDataOwner,
	A.PostingBackToStableDataStartDate,
	A.PostingBackToStableDataDoneDate, 
	A.PostingBackToStableDataStatus,
		A.UpdatingOfEBinderOwner,
		A.UpdatingOfEBinderStartDate,
		A.UpdatingOfEBinderDoneDate,
		A.UpdatingOfEBinderStatus,
B.ValueAfter AS JobOwner
FROM 
SendToPrintData A
LEFT JOIN 
TransactionLog B
ON 
B.BPSProductID = A.BPSProductID
AND
B.ServiceNumber = A.ServiceNumber
WHERE
B.ValueAfter = p_Username
AND
A.BPSProductID = p_BPSProductID
AND
A.ServiceNumber = p_ServiceNumber
AND (
		B.TransactionType = 'SendToPrintReassignment'
        OR
        B.TransactionType LIKE 'SendToPrintOwnerReassignment%'
);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSendToPrintOwnerEmail` (`p_SendToPrintID` INT(11))   BEGIN
IF p_SendToPrintID IS NOT NULL
THEN
	SELECT DISTINCT src.SendToPrintID, src.EmployeeID, A.EmailAddress from
	(
	SELECT 
	SendToPrintID, CreatedEmployeeID AS EmployeeID, 'col1' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, ConsoHighlightOwner AS EmployeeID, 'col2' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, FilingInstructionOwner AS EmployeeID, 'col3' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, DummyFiling1Owner AS EmployeeID, 'col4' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, DummyFiling2Owner AS EmployeeID, 'col5' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, UECJOwner AS EmployeeID, 'col6' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, PC1PC2Owner AS EmployeeID, 'col7' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, UpdatingOfEBinderOwner AS EmployeeID, 'col8' descrip
	FROM
	SendToPrintData
	UNION ALL
	SELECT 
	SendToPrintID, PostingBackToStableDataOwner AS EmployeeID, 'col9' descrip
	FROM
	SendToPrintData
	) src
	LEFT JOIN jobtrackaunz_userdata.Employee A
	ON A.EmployeeID = src.EmployeeID
	WHERE
	src.SendToPrintID = p_SendToPrintID;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSpecificJobData` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT 
*
 FROM jobtrackaunz.jobdata
 WHERE BPSProductID = p_BPSProductID
 AND ServiceNumber = p_ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSpecificPubSchedData` (`p_BPSProductID` VARCHAR(10), `p_ServiceNumber` VARCHAR(100))   BEGIN
SELECT 
A.BPSProductID,
A.ServiceNumber,
A.LegalEditor AS Editor,
A.ProductChargeCode AS ChargeCode
FROM
PubSched_MT A
	 WHERE A.BPSProductID = p_BPSProductID
	 AND A.ServiceNumber = p_ServiceNumber;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUpdateTypeIDByUpdateTypeName` (`p_varchar_updateType` VARCHAR(50))   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT ID
FROM UpdateType_MT
WHERE UpdateType = p_varchar_updateType;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserByUserID` (`p_UserID` INT)   BEGIN
SELECT 
	A.EmployeeID as EmployeeID,
	B.UserAccess,
	CreatedDate,
	Username,
	FirstName,
	LastName,
	EmailAddress,
	IsManager,
	IsEditoralContact,
	IsEmailList,
	IsMandatoryRecepient,
	IsShowUser,
	PasswordUpdateDate
FROM 
	jobtrackaunz_userdata.Employee A
	LEFT JOIN UserAccess_MT B
	ON B.ID = A.UserAccessID
WHERE A.ID = p_UserID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserByUserName` (`pUserName` VARCHAR(45), `pPassword` VARCHAR(200))   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
SELECT
A.EmployeeID AS EmployeeID,
A.UserName,
A.Password,
A.FirstName,
A.LastName,
B.UserAccess
FROM 
jobtrackaunz_userdata.Employee A
LEFT JOIN 
UserAccess_MT B
ON A.UserAccessID = B.UserAccessID
WHERE A.UserName = pUserName
AND
A.Password = pPassword;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserExist` (`p_UserName` VARCHAR(45), `p_EmailAddress` VARCHAR(200))   BEGIN

SELECT
A.EmployeeID AS EmployeeID,
A.Username,
A.EmailAddress
FROM 
jobtrackaunz_userdata.Employee A
WHERE A.UserName = p_UserName
OR
A.EmailAddress = p_EmailAddress;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserIDByUserName` (`p_varchar_userName` VARCHAR(45))   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
Select EmployeeID from jobtrackaunz_userdata.Employee where UserName = p_varchar_userName;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserNameByUserID` (`p_int_userID` INT)   BEGIN
-- SQLINES DEMO *** OR EVALUATION USE ONLY
-- SQLINES LICENSE FOR EVALUATION USE ONLY
Select UserName from jobtrackaunz_userdata.Employee where EmployeeID = p_int_userID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertCoversheet` (`p_Username` VARCHAR(45), `p_CoversheetNumber` VARCHAR(200), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_TaskNumber` VARCHAR(100), `p_CoversheetTier` VARCHAR(50), `p_Editor` VARCHAR(100), `p_ChargeCode` VARCHAR(100), `p_TargetPressDate` DATETIME, `p_TaskType` VARCHAR(50), `p_GuideCard` VARCHAR(500), `p_LocationOfManuscript` VARCHAR(500), `p_UpdateType` VARCHAR(50), `p_GeneralLegRefCheck` VARCHAR(45), `p_GeneralTOC` VARCHAR(45), `p_GeneralTOS` VARCHAR(45), `p_GeneralReprints` VARCHAR(45), `p_GeneralFascicleInsertion` VARCHAR(45), `p_GeneralGraphicLink` VARCHAR(45), `p_GeneralGraphicEmbed` VARCHAR(45), `p_GeneralHandtooling` VARCHAR(45), `p_GeneralNonContent` VARCHAR(45), `p_GeneralSamplePages` VARCHAR(45), `p_GeneralComplexTask` VARCHAR(45), `p_FurtherInstruction` VARCHAR(2000), `p_CodingDueDate` DATETIME, `p_IsXMLEditing` VARCHAR(50), `p_OnlineDueDate` DATETIME, `p_IsOnline` VARCHAR(50), `p_ManuscriptID` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
INSERT INTO coversheetdata(CoversheetNumber, BPSProductID, ServiceNumber, TaskNumber, CoversheetTier, Editor, ChargeCode,
			TargetPressDate,
            TaskStatus, TaskType, GuideCard, 
            LocationOfManuscript, UpdateType,
            GeneralLegRefCheck, GeneralTOC, GeneralTOS, GeneralReprints, GeneralFascicleInsertion, GeneralGraphicLink,
            GeneralGraphicEmbed, GeneralHandtooling, GeneralNonContent, GeneralSamplePages, GeneralComplexTask,
			FurtherInstruction, CodingDueDate, 
            IsXMLEditing, OnlineDueDate, IsOnline, DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID, ManuscriptID)
VALUES( 
p_CoversheetNumber, p_BPSProductID, p_ServiceNumber, p_TaskNumber, p_CoversheetTier, p_Editor, p_ChargeCode,
p_TargetPressDate,
"New", p_TaskType, p_GuideCard, 
p_LocationOfManuscript, p_UpdateType,
p_GeneralLegRefCheck, p_GeneralTOC, p_GeneralTOS, p_GeneralReprints, p_GeneralFascicleInsertion, p_GeneralGraphicLink,
p_GeneralGraphicEmbed, p_GeneralHandtooling, p_GeneralNonContent, p_GeneralSamplePages, p_GeneralComplexTask,
p_FurtherInstruction, p_CodingDueDate,
p_IsXMLEditing, p_OnlineDueDate, p_IsOnline, CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID, p_ManuscriptID
);

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertJob` (`p_Username` VARCHAR(45), `p_ManuscriptTier` VARCHAR(50), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_ManuscriptLegTitle` VARCHAR(1000), `p_TargetPressDate` DATE, `p_LatupAttribution` VARCHAR(1000), `p_DateReceivedFromAuthor` DATE, `p_UpdateType` VARCHAR(50), `p_JobSpecificInstruction` VARCHAR(500), `p_TaskType` VARCHAR(50), `p_CopyEditDueDate` DATETIME, `p_CodingDueDate` DATETIME, `p_OnlineDueDate` DATETIME, `p_CopyEditStatus` VARCHAR(50))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_RealUpdateType varchar(50);
DECLARE p_JobNumber INT(8);
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
SELECT A.ManusType as UpdateType INTO p_RealUpdateType
FROM jobtrackaunz.turnaroundtime_mt A
LEFT JOIN jobtrackaunz.updatetype_mt B
ON A.ManusType = B.UpdateType
WHERE TurnAroundTimeID = p_UpdateType;

-- SELECT COALESCE(MAX(ManuscriptID), 0) + 1 as ManuscriptID INTO p_JobNumber
-- from jobtrackaunz.manuscriptdata;

IF p_EmployeeID IS NOT NULL
THEN
INSERT INTO JobData(ManuscriptTier, BPSProductID, ServiceNumber, TargetPressDate,
			CopyEditStatus, CodingStatus, OnlineStatus, STPStatus, DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID)
VALUES( 
p_ManuscriptTier, p_BPSProductID, p_ServiceNumber, p_TargetPressDate,
p_CopyEditStatus, "New", "New", "New", CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID);

Update JobData set JobNumber=LAST_INSERT_ID() where jobid=LAST_INSERT_ID();

INSERT INTO manuscriptdata(JobNumber, ManuscriptTier, BPSProductID, ServiceNumber, ManuscriptLegTitle, ManuscriptStatus, TargetPressDate,
			LatupAttribution, DateReceivedFromAuthor, UpdateType, JobSpecificInstruction, 
			TaskType, CopyEditDueDate, CodingDueDate, OnlineDueDate, CopyEditStatus, CodingStatus, OnlineStatus, PESTPStatus, DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID)
VALUES( 
LAST_INSERT_ID(), p_ManuscriptTier, p_BPSProductID, p_ServiceNumber, p_ManuscriptLegTitle, "New", p_TargetPressDate,
p_LatupAttribution, p_DateReceivedFromAuthor, p_RealUpdateType, p_JobSpecificInstruction,
p_TaskType, p_CopyEditDueDate, p_CodingDueDate, p_OnlineDueDate, p_CopyEditStatus, "New", "New", "New", CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID
);

END IF;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertJobCoversheet` (`p_Username` VARCHAR(45), `p_CoversheetNumber` VARCHAR(200), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_TaskNumber` VARCHAR(100), `p_CoversheetTier` VARCHAR(50), `p_Editor` VARCHAR(100), `p_ChargeCode` VARCHAR(100), `p_TargetPressDate` DATETIME, `p_TaskType` VARCHAR(50), `p_GuideCard` VARCHAR(500), `p_LocationOfManuscript` VARCHAR(500), `p_UpdateType` VARCHAR(50), `p_GeneralLegRefCheck` VARCHAR(45), `p_GeneralTOC` VARCHAR(45), `p_GeneralTOS` VARCHAR(45), `p_GeneralReprints` VARCHAR(45), `p_GeneralFascicleInsertion` VARCHAR(45), `p_GeneralGraphicLink` VARCHAR(45), `p_GeneralGraphicEmbed` VARCHAR(45), `p_GeneralHandtooling` VARCHAR(45), `p_GeneralNonContent` VARCHAR(45), `p_GeneralSamplePages` VARCHAR(45), `p_GeneralComplexTask` VARCHAR(45), `p_FurtherInstruction` VARCHAR(2000), `p_CodingDueDate` DATETIME, `p_IsXMLEditing` VARCHAR(50), `p_OnlineDueDate` DATETIME, `p_IsOnline` VARCHAR(50), `p_ManuscriptID` VARCHAR(45))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;


IF p_EmployeeID IS NOT NULL
THEN

INSERT INTO JobCoversheetData(CoversheetTier, BPSProductID, ServiceNumber, TargetPressDate,
			CodingStatus, PDFQAStatus, OnlineStatus, DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID)
VALUES( 
p_CoversheetTier, p_BPSProductID, p_ServiceNumber, p_TargetPressDate,
"New", "New", "New", CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID);

INSERT INTO coversheetdata(CoversheetNumber, BPSProductID, ServiceNumber, TaskNumber, CoversheetTier, Editor, ChargeCode,
			TargetPressDate,
            TaskStatus, TaskType, GuideCard, 
            LocationOfManuscript, UpdateType,
            GeneralLegRefCheck, GeneralTOC, GeneralTOS, GeneralReprints, GeneralFascicleInsertion, GeneralGraphicLink,
            GeneralGraphicEmbed, GeneralHandtooling, GeneralNonContent, GeneralSamplePages, GeneralComplexTask,
			FurtherInstruction, CodingDueDate, 
            IsXMLEditing, OnlineDueDate, IsOnline, DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID, ManuscriptID)
VALUES( 
p_CoversheetNumber, p_BPSProductID, p_ServiceNumber, p_TaskNumber, p_CoversheetTier, p_Editor, p_ChargeCode,
p_TargetPressDate,
"New", p_TaskType, p_GuideCard, 
p_LocationOfManuscript, p_UpdateType,
p_GeneralLegRefCheck, p_GeneralTOC, p_GeneralTOS, p_GeneralReprints, p_GeneralFascicleInsertion, p_GeneralGraphicLink,
p_GeneralGraphicEmbed, p_GeneralHandtooling, p_GeneralNonContent, p_GeneralSamplePages, p_GeneralComplexTask,
p_FurtherInstruction, p_CodingDueDate,
p_IsXMLEditing, p_OnlineDueDate, p_IsOnline, CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID, p_ManuscriptID
);

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertManuscript` (`p_Username` VARCHAR(45), `p_ManuscriptTier` VARCHAR(50), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_ManuscriptLegTitle` VARCHAR(1000), `p_TargetPressDate` DATETIME, `p_LatupAttribution` VARCHAR(1000), `p_DateReceivedFromAuthor` DATETIME, `p_UpdateType` VARCHAR(50), `p_JobSpecificInstruction` VARCHAR(500), `p_TaskType` VARCHAR(50), `p_CopyEditDueDate` DATETIME, `p_CodingDueDate` DATETIME, `p_OnlineDueDate` DATETIME, `p_CopyEditStatus` VARCHAR(50))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_RealUpdateType varchar(50);
DECLARE p_JobNumber INT(8);
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
SELECT A.ManusType as UpdateType INTO p_RealUpdateType
FROM jobtrackaunz.turnaroundtime_mt A
LEFT JOIN jobtrackaunz.updatetype_mt B
ON A.ManusType = B.UpdateType
WHERE TurnAroundTimeID = p_UpdateType;

-- SELECT COALESCE(MAX(ManuscriptID), 0) + 1 as ManuscriptID INTO p_JobNumber
-- from jobtrackaunz.manuscriptdata;

select JobNumber INTO p_JobNumber
from jobtrackaunz.jobdata
where BPSProductID = p_BPSProductID
and ServiceNumber = p_ServiceNumber;

IF p_EmployeeID IS NOT NULL
THEN

INSERT INTO manuscriptdata(JobNumber, ManuscriptTier, BPSProductID, ServiceNumber, ManuscriptLegTitle, ManuscriptStatus, TargetPressDate,
			LatupAttribution, DateReceivedFromAuthor, UpdateType, JobSpecificInstruction, 
			TaskType, CopyEditDueDate, CodingDueDate, OnlineDueDate, CopyEditStatus, CodingStatus, OnlineStatus, PESTPStatus, DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID)
VALUES( 
p_JobNumber, p_ManuscriptTier, p_BPSProductID, p_ServiceNumber, p_ManuscriptLegTitle, "New", p_TargetPressDate,
p_LatupAttribution, p_DateReceivedFromAuthor, p_RealUpdateType, p_JobSpecificInstruction,
p_TaskType, p_CopyEditDueDate, p_CodingDueDate, p_OnlineDueDate, p_CopyEditStatus, "New", "New", "New", CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID
);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertProduct` (`p_int_ownerUserID` INT, `p_varchar_legalEditor` VARCHAR(100), `p_int_originalID` INT, `p_int_bpsProductID` INT, `p_varchar_productName` VARCHAR(45), `p_varchar_chargeCode` VARCHAR(45), `p_datetime_targetPressDate` DATETIME(0), `p_datetime_revisedPressDate` DATETIME(0), `p_int_month` INT, `p_varchar_tier` VARCHAR(100), `p_varchar_team` VARCHAR(100), `p_varchar_serviceNo` VARCHAR(45), `p_varchar_chargeType` VARCHAR(100), `p_varchar_BPSSublist` VARCHAR(100), `p_varchar_ReasonForRevisedPressDate` VARCHAR(200), `p_tinyint_isSPI` SMALLINT, `p_varchar_serviceUpdate` VARCHAR(45), `p_int_forecastPages` INT, `p_int_actualPages` INT)   BEGIN
INSERT INTO Product_MT(OwnerUserID,
LegalEditor,
OriginalID,
BPSProductID,
ProductName,
ChargeCode,
TargetPressDate,
RevisedPressDate,
Month,
Tier,
Team,
ServiceNo,
ChargeType,
BPSSublist,
ReasonForRevisedPressDate,
isSPI,
ServiceUpdate,
ForecastPages,
ActualPages)
VALUES( 
p_int_ownerUserID,
p_varchar_legalEditor,
p_int_originalID,
p_int_bpsProductID,
p_varchar_productName,
p_varchar_chargeCode,
p_datetime_targetPressDate,
p_datetime_revisedPressDate,
p_int_month,
p_varchar_tier,
p_varchar_team,
p_varchar_serviceNo,
p_varchar_chargeType,
p_varchar_BPSSublist,
p_varchar_ReasonForRevisedPressDate,
p_tinyint_isSPI,
p_varchar_serviceUpdate,
p_int_forecastPages,
p_int_actualPages
);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertSendToPrint` (`p_Username` VARCHAR(45), `p_SendToPrintNumber` VARCHAR(100), `p_BPSProductID` VARCHAR(100), `p_ServiceNumber` VARCHAR(100), `p_SendToPrintTier` VARCHAR(50), `p_TargetPressDate` DATETIME, `p_LegislationMaterials` VARCHAR(50), `p_PathOfInputFiles` VARCHAR(2000), `p_SpecialInstruction` VARCHAR(2000), `p_ConsoHighlight` VARCHAR(45), `p_FilingInstruction` VARCHAR(45), `p_DummyFiling1` VARCHAR(45), `p_DummyFiling2` VARCHAR(45), `p_UECJ` VARCHAR(45), `p_PC1PC2` VARCHAR(45), `p_ReadyToPrint` VARCHAR(45), `p_SendingFinalPagesToPuddingburn` VARCHAR(45), `p_PostingBackToStableData` VARCHAR(45), `p_UpdatingOfEBinder` VARCHAR(45), `p_CoversheetID` VARCHAR(50))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
INSERT INTO sendtoprintdata(SendToPrintNumber, BPSProductID, ServiceNumber, SendToPrintTier, TargetPressDate,
            LegislationMaterials, PathOfInputFiles, SpecialInstruction,
            ConsoHighlight, FilingInstruction, DummyFiling1, DummyFiling2, UECJ, PC1PC2,
            ReadyToPrint, SendingFinalPagesToPuddingburn, PostingBackToStableData, UpdatingOfEBinder,
            SendToPrintStatus,
			DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID, CoversheetID)
VALUES( 
			p_SendToPrintNumber, p_BPSProductID, p_ServiceNumber, p_SendToPrintTier, p_TargetPressDate,
			p_LegislationMaterials, p_PathOfInputFiles, p_SpecialInstruction,
			p_ConsoHighlight, p_FilingInstruction, p_DummyFiling1, p_DummyFiling2, p_UECJ, p_PC1PC2,
			p_ReadyToPrint, p_SendingFinalPagesToPuddingburn, p_PostingBackToStableData, p_UpdatingOfEBinder,
            "New",
			CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID, p_CoversheetID
);
SELECT MAX(SendToPrintID) FROM sendtoprintdata;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertSubsequentPass` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_CoversheetNumber` VARCHAR(200), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_AttachmentBody` VARCHAR(1000), `p_ActionType` VARCHAR(500), `p_ActionStatus` VARCHAR(500), `p_PDFQAStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

IF p_EmployeeID IS NOT NULL
THEN

UPDATE CoversheetData
SET 
    PDFQAStatus = p_PDFQAStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

INSERT INTO subsequentpassdata(CoversheetID, CoversheetNumber, BPSProductID, ServiceNumber, AttachmentBody, ActionType, ActionStatus,
			DateCreated, CreatedEmployeeID, DateUpdated, UpdateEmployeeID)
VALUES( 
			p_CoversheetID, p_CoversheetNumber, p_BPSProductID, p_ServiceNumber, p_AttachmentBody, p_ActionType, p_ActionStatus,
			CURRENT_TIMESTAMP, p_EmployeeID, CURRENT_TIMESTAMP, p_EmployeeID
);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransactionLogJobCoversheetReassignment` (`p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(50), `p_JobOwner` INT(11), `p_UserName` VARCHAR(45))   BEGIN

DECLARE is_exist INT;
DECLARE p_JobOwner_UserName varchar(500);

SET is_exist = ( 
SELECT COUNT(*) TransactionType
FROM TransactionLog
WHERE
TransactionLogIdentity = p_CoversheetID
AND
BPSProductID = p_BPSProductID
AND 
ServiceNumber = p_ServiceNumber
AND
TransactionType = 'JobCoversheetReassignment');

IF is_exist = 0
THEN
	SELECT UserName INTO p_JobOwner_UserName 
    FROM jobtrackaunz_userdata.Employee
    WHERE EmployeeID = p_JobOwner;
    
	IF p_JobOwner IS NOT NULL
	THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, TransactionType, ValueAfter, DateCreated, UserName)
		VALUES(p_CoversheetID, 'Coversheet', p_BPSProductID, p_ServiceNumber, 'JobCoversheetReassignment', p_JobOwner_UserName, CURRENT_TIMESTAMP, p_UserName);
	END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransactionLogJobReassignment` (`p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(50), `p_UserName` VARCHAR(45))   BEGIN

DECLARE is_exist INT;
DECLARE p_PEUserName varchar(45);
DECLARE p_LEUserName varchar(45);    
DECLARE p_JobID int;


SET is_exist = ( 
SELECT COUNT(*) TransactionType
FROM TransactionLog
WHERE 
BPSProductID = p_BPSProductID
AND 
ServiceNumber = p_ServiceNumber
AND
TransactionType LIKE 'JobReassignment%');

IF is_exist = 0
THEN
	SELECT PEUserName, LEUserName
	INTO p_PEUsername, p_LEUserName
	FROM PublicationAssignment
	WHERE BPSProductID = p_BPSProductID
    LIMIT 1;

	SELECT MAX(JobID) INTO p_JobID
	FROM JobData
	WHERE 
	BPSProductID = p_BPSProductID
	AND 
	ServiceNumber = p_ServiceNumber;

	IF p_LEUserName IS NOT NULL
	THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, TransactionType, ValueAfter, DateCreated, UserName)
		VALUES(p_JobID, 'Manuscript', p_BPSProductID, p_ServiceNumber, 'JobReassignment LE', p_LEUserName, CURRENT_TIMESTAMP, p_UserName);
	END IF;
	IF p_PEUsername IS NOT NULL
	THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, TransactionType, ValueAfter, DateCreated, UserName)
		VALUES(p_JobID, 'Manuscript', p_BPSProductID, p_ServiceNumber, 'JobReassignment PE', p_PEUserName, CURRENT_TIMESTAMP, p_UserName);
	END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransactionLogJobReassignmentCoding` (`p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(50), `p_CodingUserName` VARCHAR(45), `p_Username` VARCHAR(45))   BEGIN
DECLARE p_ValueBefore varchar(45);
DECLARE p_EmployeeCodingID INT;
DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeCodingID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_CodingUserName;

SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;

SELECT ValueAfter INTO p_ValueBefore
FROM TransactionLog
WHERE TransactionType = 'JobCoversheetReassignment'
AND TransactionLogIdentity = p_CoversheetID
AND BPSProductID = p_BPSProductID
AND ServiceNumber = p_ServiceNumber
ORDER BY TransactionLogID DESC
LIMIT 1;

	IF p_CodingUserName IS NOT NULL
	THEN
		   UPDATE CoversheetData a
           SET
           --
           a.JobOwner = p_EmployeeCodingID,
           a.DateUpdated = CURRENT_TIMESTAMP,
           a.UpdateEmployeeID = p_EmployeeID
           WHERE
           a.CoversheetID = p_CoversheetID
           AND
           a.BPSProductID = p_BPSProductID
           AND 
           a.ServiceNumber = p_ServiceNumber;
           
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, 
        TransactionType, ValueBefore, ValueAfter, DateCreated, UserName)
		VALUES(p_CoversheetID, 'Coversheet', p_BPSProductID, p_ServiceNumber, 
        'JobCoversheetReassignment', p_ValueBefore, p_CodingUserName, CURRENT_TIMESTAMP, p_Username);
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransactionLogJobReassignmentLE` (`p_JobNumber` INT, `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(50), `p_LEUserName` VARCHAR(45), `p_Username` VARCHAR(45))   BEGIN
DECLARE p_ValueBefore varchar(45);

SELECT ValueAfter INTO p_ValueBefore
FROM TransactionLog
WHERE TransactionType = 'JobReassignment LE'
AND TransactionLogIdentity = p_JobNumber
AND BPSProductID = p_BPSProductID
AND ServiceNumber = p_ServiceNumber
ORDER BY TransactionLogID DESC
LIMIT 1;

	IF p_LEUserName IS NOT NULL
	THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, 
        TransactionType, ValueBefore, ValueAfter, DateCreated, UserName)
		VALUES(p_JobNumber, 'Manuscript', p_BPSProductID, p_ServiceNumber, 
        'JobReassignment LE', p_ValueBefore, p_LEUserName, CURRENT_TIMESTAMP, p_Username);
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransactionLogJobReassignmentPE` (`p_JobNumber` INT, `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(50), `p_PEUserName` VARCHAR(45), `p_Username` VARCHAR(45))   BEGIN
DECLARE p_ValueBefore varchar(45);

SELECT ValueAfter INTO p_ValueBefore
FROM TransactionLog
WHERE TransactionType = 'JobReassignment PE'
AND TransactionLogIdentity = p_JobNumber
AND BPSProductID = p_BPSProductID
AND ServiceNumber = p_ServiceNumber
ORDER BY TransactionLogID DESC
LIMIT 1;

	IF p_PEUserName IS NOT NULL
	THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, 
        TransactionType, ValueBefore, ValueAfter, DateCreated, UserName)
		VALUES(p_JobNumber, 'Manuscript', p_BPSProductID, p_ServiceNumber, 
        'JobReassignment PE', p_ValueBefore, p_PEUserName, CURRENT_TIMESTAMP, p_Username);
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransactionLogSendToPrintOwnerReassignment` (`p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(50), `p_JobOwner` INT(11), `p_UserName` VARCHAR(45), `p_TransactionType` VARCHAR(200))   BEGIN

DECLARE is_Ownerexist INT;
DECLARE p_JobOwner_UserName varchar(500);
DECLARE p_ValueBefore varchar(45);

	SELECT UserName INTO p_JobOwner_UserName 
    FROM jobtrackaunz_userdata.Employee
    WHERE EmployeeID = p_JobOwner;

	SELECT ValueAfter INTO p_ValueBefore
	FROM TransactionLog
	WHERE TransactionType = p_TransactionType
	AND TransactionLogIdentity = p_SendToPrintID
	AND BPSProductID = p_BPSProductID
	AND ServiceNumber = p_ServiceNumber
	-- AND ValueAfter = p_JobOwner_UserName
	ORDER BY TransactionLogID DESC
	LIMIT 1;
    
	SET is_Ownerexist = ( 
	SELECT COUNT(*) TransactionType
	FROM TransactionLog
	WHERE TransactionType = p_TransactionType
	AND TransactionLogIdentity = p_SendToPrintID
	AND BPSProductID = p_BPSProductID
	AND ServiceNumber = p_ServiceNumber
	-- AND ValueAfter = p_JobOwner_UserName
	ORDER BY TransactionLogID DESC
	LIMIT 1);

IF is_Ownerexist = 0
THEN
    
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, TransactionType, ValueAfter, DateCreated, UserName)
		VALUES(p_SendToPrintID, 'SendToPrint', p_BPSProductID, p_ServiceNumber, p_TransactionType, p_JobOwner_UserName, CURRENT_TIMESTAMP, p_UserName);
END IF;
IF is_Ownerexist > 0
THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, 
        TransactionType, ValueBefore, ValueAfter, DateCreated, UserName)
		VALUES(p_SendToPrintID, 'SendToPrint', p_BPSProductID, p_ServiceNumber, 
        p_TransactionType, p_ValueBefore, p_JobOwner_UserName, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransactionLogSendToPrintReassignment` (`p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(50), `p_JobOwner` INT(11), `p_UserName` VARCHAR(45))   BEGIN

DECLARE is_exist INT;
DECLARE p_JobOwner_UserName varchar(500);
DECLARE p_ValueBefore varchar(45);

	SELECT UserName INTO p_JobOwner_UserName 
    FROM jobtrackaunz_userdata.Employee
    WHERE EmployeeID = p_JobOwner;

	SELECT ValueAfter INTO p_ValueBefore
	FROM TransactionLog
	WHERE TransactionType = 'SendToPrintReassignment'
	AND TransactionLogIdentity = p_SendToPrintID
	AND BPSProductID = p_BPSProductID
	AND ServiceNumber = p_ServiceNumber
	ORDER BY TransactionLogID DESC
	LIMIT 1;

	SET is_exist = ( 
	SELECT COUNT(*) TransactionType
	FROM TransactionLog
	WHERE
    TransactionType = 'SendToPrintReassignment'
    AND
	TransactionLogIdentity = p_SendToPrintID
	AND
	BPSProductID = p_BPSProductID
	AND 
	ServiceNumber = p_ServiceNumber
	);

IF is_exist = 0
THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, TransactionType, ValueAfter, DateCreated, UserName)
		VALUES(p_SendToPrintID, 'SendToPrint', p_BPSProductID, p_ServiceNumber, 'SendToPrintReassignment', p_JobOwner_UserName, CURRENT_TIMESTAMP, p_UserName);
END IF;
IF is_exist > 0
THEN
		INSERT INTO TransactionLog(TransactionLogIdentity, TransactionLogName, BPSProductID, ServiceNumber, 
        TransactionType, ValueBefore, ValueAfter, DateCreated, UserName)
		VALUES(p_SendToPrintID, 'SendToPrint', p_BPSProductID, p_ServiceNumber, 
        'SendToPrintReassignment', p_ValueBefore, p_JobOwner_UserName, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUpdateType` (`p_varchar_updateType` VARCHAR(50), `p_varchar_TaskType` VARCHAR(50), `p_int_CopyEditDays` INT, `p_int_ProcessDays` INT, `p_int_OnlineDays` INT, `p_int_PDFQADays` INT, `p_int_BenchMarkDays` INT, `p_int_IsEdit` SMALLINT)   BEGIN
INSERT INTO UpdateType_MT(
UpdateType,
TaskType,
CopyEditDays,
ProcessDays,
OnlineDays,
PDFQADays,
BenchMarkDays,
IsEdit)
VALUES
(p_varchar_updateType,
p_varchar_TaskType,
p_int_CopyEditDays,
p_int_ProcessDays,
p_int_OnlineDays,
p_int_PDFQADays,
p_int_BenchMarkDays,
p_int_IsEdit
);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUser` (`p_UserAccess` VARCHAR(50), `p_FirstName` VARCHAR(150), `p_LastName` VARCHAR(150), `p_EmailAddress` VARCHAR(100), `p_UserName` VARCHAR(45))   BEGIN

DECLARE p_UserAccessID INT;    
SELECT ID INTO p_UserAccessID   
FROM UserAccess_MT   
WHERE UserAccess = p_UserAccess;  

IF p_UserAccessID IS NOT NULL
THEN
INSERT INTO Employee(UserAccessID, UserName, Password, FirstName, LastName, EmailAddress, IsManager, IsEditoralContact,IsEmailList, IsMandatoryRecepient, IsShowUser,
CreatedDate, PasswordUpdateDate )
VALUES( 
p_UserAccessID,
p_UserName,
p_UserName,
p_FirstName,
p_LastName,
p_EmailAddress,
1,
1,
1,
1,
1,
CURRENT_TIMESTAMP,
CURRENT_TIMESTAMP
);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheet` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_CoversheetNumber` VARCHAR(200), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_LocationOfManuscript` VARCHAR(500), `p_GuideCard` VARCHAR(500), `p_GeneralLegRefCheck` VARCHAR(45), `p_GeneralTOC` VARCHAR(45), `p_GeneralTOS` VARCHAR(45), `p_GeneralReprints` VARCHAR(45), `p_GeneralFascicleInsertion` VARCHAR(45), `p_GeneralGraphicLink` VARCHAR(45), `p_GeneralGraphicEmbed` VARCHAR(45), `p_GeneralHandtooling` VARCHAR(45), `p_GeneralNonContent` VARCHAR(45), `p_GeneralSamplePages` VARCHAR(45), `p_GeneralComplexTask` VARCHAR(45), `p_FurtherInstruction` VARCHAR(2000), `p_RevisedOnlineDueDate` DATETIME, `p_ReasonIfLate` VARCHAR(1000))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
	LocationOfManuscript = p_LocationOfManuscript,
    GuideCard = p_GuideCard,
		GeneralLegRefCheck = p_GeneralLegRefCheck,
		GeneralTOC = p_GeneralTOC,
		GeneralTOS = p_GeneralTOS,
		GeneralReprints = p_GeneralReprints,
		GeneralFascicleInsertion = p_GeneralFascicleInsertion,
		GeneralGraphicLink = p_GeneralGraphicLink,
		GeneralGraphicEmbed = p_GeneralGraphicEmbed,
		GeneralHandtooling = p_GeneralHandtooling,
		GeneralNonContent = p_GeneralNonContent,
		GeneralSamplePages = p_GeneralSamplePages,
		GeneralComplexTask = p_GeneralComplexTask,
    FurtherInstruction = p_FurtherInstruction,
    RevisedOnlineDueDate = p_RevisedOnlineDueDate,
    ReasonIfLate = p_ReasonIfLate,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    CoversheetNumber = p_CoversheetNumber AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetCodingDoneDate` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_CodingDoneDate` DATETIME, `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_CodingStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    CodingDoneDate = p_CodingDoneDate,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    CodingStatus = p_CodingStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_CoversheetID, "Coversheet", p_BPSProductID, p_ServiceNumber,
		"CODING DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetCodingStartDate` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_CodingStartDate` DATETIME, `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_CodingStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	SELECT ManuscriptID INTO p_ManuscriptID   
	FROM CoversheetData   
	WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    CodingStartDate = p_CodingStartDate,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    CodingStatus = p_CodingStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

UPDATE ManuscriptData 
SET 
    CodingStartDate = p_CodingStartDate,
    CodingStatus = p_CodingStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber AND
    ManuscriptID IN (p_ManuscriptID);
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_CoversheetID, "Coversheet", p_BPSProductID, p_ServiceNumber,
		"CODING START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetDoneDateCoding` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_CodingDoneDate` DATETIME, `p_TaskStatus` VARCHAR(500))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeIDID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    CodingDoneDate = p_CodingDoneDate,
    TaskStatus = p_TaskStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID,
	CurrentTask = 'XML Editing'
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetJobOwner` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11), `p_UpdateEmailCC` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    JobOwner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID,
	-- CurrentTask = 'XML Editing',
    UpdateEmailCC = p_UpdateEmailCC
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetOnlineDoneDate` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_OnlineDoneDate` DATETIME, `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_OnlineStatus` VARCHAR(100), `p_OnlineTimeliness` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	SELECT ManuscriptID INTO p_ManuscriptID   
	FROM CoversheetData   
	WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    OnlineDoneDate = p_OnlineDoneDate,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    OnlineStatus = p_OnlineStatus,
    OnlineTimeliness = p_OnlineTimeliness,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

UPDATE ManuscriptData 
SET 
    OnlineDoneDate = p_OnlineDoneDate,
    OnlineStatus = p_OnlineStatus,
    OnlineTimeliness = p_OnlineTimeliness,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber AND
    ManuscriptID IN (p_ManuscriptID);
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_CoversheetID, "Coversheet", p_BPSProductID, p_ServiceNumber,
		"ONLINE DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetOnlineStartDate` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_OnlineStartDate` DATETIME, `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_OnlineStatus` VARCHAR(100), `p_OnlineTimeliness` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	SELECT ManuscriptID INTO p_ManuscriptID   
	FROM CoversheetData   
	WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    OnlineStartDate = p_OnlineStartDate,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    OnlineStatus = p_OnlineStatus,
    OnlineTimeliness = p_OnlineTimeliness,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

UPDATE ManuscriptData 
SET 
    OnlineStartDate = p_OnlineStartDate,
    OnlineStatus = p_OnlineStatus,
    OnlineTimeliness = p_OnlineTimeliness,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber AND
    ManuscriptID IN (p_ManuscriptID);
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_CoversheetID, "Coversheet", p_BPSProductID, p_ServiceNumber,
		"ONLINE START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetPDFQCDoneDate` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_PDFQCDoneDate` DATETIME, `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_CodingStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee
	WHERE Username = p_Username;

	SELECT ManuscriptID INTO p_ManuscriptID   
	FROM CoversheetData   
	WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    PDFQCDoneDate = p_PDFQCDoneDate,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    CodingStatus = p_CodingStatus,
    -- PDFQAStatus = p_PDFQAStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;
    
UPDATE ManuscriptData 
SET 
    CodingDoneDate = p_PDFQCDoneDate,
    CodingStatus = p_CodingStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber AND
    ManuscriptID IN (p_ManuscriptID);
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_CoversheetID, "Coversheet", p_BPSProductID, p_ServiceNumber,
		"PDFQC DONE", p_CodingStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetPDFQCStartDate` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_PDFQCStartDate` DATETIME, `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    PDFQCStartDate = p_PDFQCStartDate,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    -- PDFQAStatus = p_PDFQAStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_CoversheetID, "Coversheet", p_BPSProductID, p_ServiceNumber,
		"PDFQC START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoversheetStartDateCoding` (`p_Username` VARCHAR(45), `p_CoversheetID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_CodingStartDate` DATETIME, `p_TaskStatus` VARCHAR(500))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE CoversheetData
SET 
    CodingStartDate = p_CodingStartDate,
    TaskStatus = p_TaskStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID,
	CurrentTask = 'XML Editing'
WHERE
	CoversheetID = p_CoversheetID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateManuscript` (`p_Username` VARCHAR(45), `p_ManuscriptID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_LatupAttribution` VARCHAR(1000), `p_UpdateType` VARCHAR(50), `p_TaskType` VARCHAR(50), `p_CopyEditDueDate` DATETIME, `p_CodingDueDate` DATETIME, `p_OnlineDueDate` DATETIME, `p_PEGuideCard` VARCHAR(1000), `p_RevisedOnlineDueDate` DATETIME, `p_EstimatedPages` INT(11), `p_ReasonIfLate` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE ManuscriptData
SET 
	LatupAttribution = p_LatupAttribution,
    UpdateType = p_UpdateType,
    TaskType = p_TaskType,
	PEGuideCard = p_PEGuideCard,
    RevisedOnlineDueDate = p_RevisedOnlineDueDate,
	EstimatedPages = p_EstimatedPages,
    ReasonIfLate = p_ReasonIfLate,
    CopyEditDueDate = p_CopyEditDueDate,
    CodingDueDate = p_CodingDueDate,
    OnlineDueDate = p_OnlineDueDate,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	ManuscriptID = p_ManuscriptID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateManuscriptDoneDate` (`p_Username` VARCHAR(45), `p_ManuscriptID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_CopyEditDoneDate` DATETIME, `p_CopyEditStatus` VARCHAR(500))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE ManuscriptData
SET 
    CopyEditDoneDate = p_CopyEditDoneDate,
    CopyEditStatus = p_CopyEditStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
    
WHERE
	ManuscriptID = p_ManuscriptID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_ManuscriptID, "Manuscript", p_BPSProductID, p_ServiceNumber,
		"DONE", p_CopyEditStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateManuscriptStartDate` (`p_Username` VARCHAR(45), `p_ManuscriptID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_CopyEditStartDate` DATETIME, `p_CopyEditStatus` VARCHAR(500))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE ManuscriptData
SET 
    CopyEditStartDate = p_CopyEditStartDate,
    CopyEditStatus = p_CopyEditStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID,
	ManuscriptStatus = 'On-Going'
WHERE
	ManuscriptID = p_ManuscriptID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_ManuscriptID, "Manuscript", p_BPSProductID, p_ServiceNumber,
		"START", p_CopyEditStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdatePostingBackToStableDataDoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_PostingBackToStableDataDoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_PostingBackToStableDataStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    PostingBackToStableDataDoneDate = p_PostingBackToStableDataDoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    PostingBackToStableDataStatus = p_PostingBackToStableDataStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

UPDATE
ManuscriptData b
LEFT JOIN
CoversheetData c
ON
	(c.BPSProductID = b.BPSProductID 
	AND c.ServiceNumber = b.ServiceNumber
    AND find_in_set(b.ManuscriptID, c.ManuscriptID))
LEFT JOIN
SendToPrintData d
ON
	(d.BPSProductID = c.BPSProductID 
	AND d.ServiceNumber = c.ServiceNumber
     AND find_in_set(c.CoversheetID, d.CoversheetID))
SET b.PESTPStatus = 'Completed'
WHERE d.SendToPrintID = p_SendToPrintID;
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"STABLE DATA DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdatePostingBackToStableDataStartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_PostingBackToStableDataStartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_PostingBackToStableDataStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    PostingBackToStableDataStartDate = p_PostingBackToStableDataStartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    PostingBackToStableDataStatus = p_PostingBackToStableDataStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"STABLE DATA START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateProductByProductID` (`p_int_productID` INT, `p_int_ownerUserID` INT, `p_varchar_legalEditor` VARCHAR(100), `p_int_originalID` INT, `p_int_bpsProductID` INT, `p_varchar_productName` VARCHAR(45), `p_varchar_chargeCode` VARCHAR(45), `p_datetime_targetPressDate` DATETIME(0), `p_datetime_revisedPressDate` DATETIME(0), `p_int_month` INT, `p_varchar_tier` VARCHAR(100), `p_varchar_team` VARCHAR(100), `p_varchar_serviceNo` VARCHAR(45), `p_varchar_chargeType` VARCHAR(100), `p_varchar_BPSSublist` VARCHAR(100), `p_varchar_ReasonForRevisedPressDate` VARCHAR(200), `p_tinyint_isSPI` SMALLINT, `p_varchar_serviceUpdate` VARCHAR(45), `p_int_forecastPages` INT, `p_int_actualPages` INT)   BEGIN
UPDATE Product_MT SET 
OwnerUserID = p_int_ownerUserID,
LegalEditor = p_varchar_legalEditor,
OriginalID = p_int_originalID,
BPSProductID = p_int_bpsProductID,
ProductName = p_varchar_productName,
ChargeCode = p_varchar_chargeCode,
TargetPressDate = p_datetime_targetPressDate,
RevisedPressDate = p_datetime_revisedPressDate,
Month = p_int_month,
Tier = p_varchar_tier,
Team = p_varchar_team,
ServiceNo = p_varchar_serviceNo,
ChargeType = p_varchar_chargeType,
BPSSublist = p_varchar_BPSSublist,
ReasonForRevisedPressDate = p_varchar_ReasonForRevisedPressDate,
isSPI = p_tinyint_isSPI,
ServiceUpdate= p_varchar_serviceUpdate,
ForecastPages = p_int_forecastPages,
ActualPages = p_int_actualPages
WHERE ID = p_int_productID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintConsoHighlightDoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_ConsoHighlightDoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_ConsoHighlightStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    ConsoHighlightDoneDate = p_ConsoHighlightDoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    ConsoHighlightStatus = p_ConsoHighlightStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"CONSO HIGHLIGHT DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintConsoHighlightOwner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    ConsoHighlightOwner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintConsoHighlightStartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_ConsoHighlightStartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_ConsoHighlightStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    ConsoHighlightStartDate = p_ConsoHighlightStartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    ConsoHighlightStatus = p_ConsoHighlightStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

UPDATE
ManuscriptData b
LEFT JOIN
CoversheetData c
ON
	(c.BPSProductID = b.BPSProductID 
	AND c.ServiceNumber = b.ServiceNumber
    AND find_in_set(b.ManuscriptID, c.ManuscriptID))
LEFT JOIN
SendToPrintData d
ON
	(d.BPSProductID = c.BPSProductID 
	AND d.ServiceNumber = c.ServiceNumber
     AND find_in_set(c.CoversheetID, d.CoversheetID))
SET b.PESTPStatus = 'On-Going'
WHERE d.SendToPrintID = p_SendToPrintID;
    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"CONSO HIGHLIGHT START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintDummyFiling1DoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_DummyFiling1DoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_DummyFiling1Status` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    DummyFiling1DoneDate = p_DummyFiling1DoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    DummyFiling1Status = p_DummyFiling1Status,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"DUMMY FILING 1 DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintDummyFiling1Owner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    DummyFiling1Owner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintDummyFiling1StartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_DummyFiling1StartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_DummyFiling1Status` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    DummyFiling1StartDate = p_DummyFiling1StartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    DummyFiling1Status = p_DummyFiling1Status,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"DUMMY FILING 1 START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintDummyFiling2DoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_DummyFiling2DoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_DummyFiling2Status` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    DummyFiling2DoneDate = p_DummyFiling2DoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    DummyFiling2Status = p_DummyFiling2Status,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"DUMMY FILING 2 DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintDummyFiling2Owner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    DummyFiling2Owner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintDummyFiling2StartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_DummyFiling2StartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_DummyFiling2Status` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    DummyFiling2StartDate = p_DummyFiling2StartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    DummyFiling2Status = p_DummyFiling2Status,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"DUMMY FILING 2 START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintFilingInstructionDoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_FilingInstructionDoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_FilingInstructionStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    FilingInstructionDoneDate = p_FilingInstructionDoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    FilingInstructionStatus = p_FilingInstructionStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"FILING INSTRUCTION DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintFilingInstructionOwner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    FilingInstructionOwner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintFilingInstructionStartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_FilingInstructionStartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_FilingInstructionStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    FilingInstructionStartDate = p_FilingInstructionStartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    FilingInstructionStatus = p_FilingInstructionStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"FILING INSTRUCTION START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintJobOwner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11), `p_UpdateEmailCC` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    JobOwner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID,
	-- CurrentTask = 'XML Editing',
    UpdateEmailCC = p_UpdateEmailCC
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintPC1PC2DoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_PC1PC2DoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_PC1PC2Status` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    PC1PC2DoneDate = p_PC1PC2DoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    PC1PC2Status = p_PC1PC2Status,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"PC1/PC2 DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintPC1PC2Owner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    PC1PC2Owner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintPC1PC2StartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_PC1PC2StartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_PC1PC2Status` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    PC1PC2StartDate = p_PC1PC2StartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    PC1PC2Status = p_PC1PC2Status,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"PC1/PC2 START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintPostingBackToStableDataOwner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    PostingBackToStableDataOwner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintPuddingburn` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_PuddingburnAttachmentBody` VARCHAR(1000), `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_PuddingburnStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    PuddingburnAttachmentBody = p_PuddingburnAttachmentBody,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    PuddingburnStatus = p_PuddingburnStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"PUDDINGBURN DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintReadyToPrint` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_ReadyToPrintAttachmentBody` VARCHAR(1000), `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_ReadyToPrintStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    ReadyToPrintAttachmentBody = p_ReadyToPrintAttachmentBody,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    ReadyToPrintStatus = p_ReadyToPrintStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"READY TO PRINT DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintUECJDoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_UECJDoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_UECJStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    UECJDoneDate = p_UECJDoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    UECJStatus = p_UECJStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"UECJ DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintUECJOwner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    UECJOwner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintUECJStartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_UECJStartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_UECJStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    UECJStartDate = p_UECJStartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    UECJStatus = p_UECJStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"UECJ START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintUpdatingOfEBinderDoneDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_UpdatingOfEBinderDoneDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_UpdatingOfEBinderStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    UpdatingOfEBinderDoneDate = p_UpdatingOfEBinderDoneDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    UpdatingOfEBinderStatus = p_UpdatingOfEBinderStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"EBINDER DONE", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintUpdatingOfEBinderOwner` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_JobOwner` INT(11))   BEGIN

DECLARE p_EmployeeID INT;
      
SELECT EmployeeID INTO p_EmployeeID   
FROM jobtrackaunz_userdata.Employee   
WHERE Username = p_Username;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    UpdatingOfEBinderOwner = p_JobOwner,
    AcceptedDate = CURRENT_TIMESTAMP,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
	-- CurrentTask = 'XML Editing',
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSendToPrintUpdatingOfEBinderStartDate` (`p_Username` VARCHAR(45), `p_SendToPrintID` INT(11), `p_BPSProductID` VARCHAR(50), `p_ServiceNumber` VARCHAR(100), `p_UpdatingOfEBinderStartDate` DATETIME, `p_SendToPrintStatus` VARCHAR(500), `p_CurrentTask` VARCHAR(500), `p_TaskStatus` VARCHAR(500), `p_UpdatingOfEBinderStatus` VARCHAR(100))   BEGIN

DECLARE p_EmployeeID INT;
-- DECLARE p_ManuscriptID VARCHAR(100);
      
	SELECT EmployeeID INTO p_EmployeeID   
	FROM jobtrackaunz_userdata.Employee   
	WHERE Username = p_Username;

	-- SELECT ManuscriptID INTO p_ManuscriptID   
	-- FROM CoversheetData   
	-- WHERE
	-- CoversheetID = p_CoversheetID AND
    -- BPSProductID = p_BPSProductID AND
    -- ServiceNumber = p_ServiceNumber;
    
IF p_EmployeeID IS NOT NULL
THEN
UPDATE SendToPrintData
SET 
    UpdatingOfEBinderStartDate = p_UpdatingOfEBinderStartDate,
    SendToPrintStatus = p_SendToPrintStatus,
    CurrentTask = p_CurrentTask,
    TaskStatus = p_TaskStatus,
    UpdatingOfEBinderStatus = p_UpdatingOfEBinderStatus,
    DateUpdated = CURRENT_TIMESTAMP,
    UpdateEmployeeID = p_EmployeeID
WHERE
	SendToPrintID = p_SendToPrintID AND
    BPSProductID = p_BPSProductID AND
    ServiceNumber = p_ServiceNumber;

    
INSERT INTO CallToActionData(CallToActionIdentity, CallToActionName, BPSProductID, ServiceNumber,
			CallToActionType, CallToActionStatus, DateCreated, UserName)
VALUES(p_SendToPrintID, "SendToPrint", p_BPSProductID, p_ServiceNumber,
		"EBINDER START", p_TaskStatus, CURRENT_TIMESTAMP, p_Username);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUpdateTypeByUpdateTypeID` (`p_int_updateTypeID` INT, `p_varchar_updateType` VARCHAR(50), `p_varchar_TaskType` VARCHAR(50), `p_int_CopyEditDays` INT, `p_int_ProcessDays` INT, `p_int_OnlineDays` INT, `p_int_PDFQADays` INT, `p_int_BenchMarkDays` INT, `p_int_IsEdit` SMALLINT)   BEGIN
UPDATE UpdateType_MT SET
UpdateType = p_varchar_updateType,
TaskType = p_varchar_TaskType,
CopyEditDays = p_int_CopyEditDays,
ProcessDays = p_int_ProcessDays,
OnlineDays = p_int_OnlineDays,
PDFQADays = p_int_PDFQADays,
BenchMarkDays = p_int_BenchMarkDays,
IsEdit = p_int_IsEdit
WHERE ID = p_int_updateTypeID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserByUserID` (`p_int_userID` INT, `p_varchar_userName` VARCHAR(45), `p_int_userAccessID` INT, `p_varchar_firstName` VARCHAR(150), `p_varchar_lastName` VARCHAR(150), `p_varchar_emailAddress` VARCHAR(100), `p_tinyint_isManager` SMALLINT, `p_tinyint_isEditoralContact` SMALLINT, `p_tinyint_isEmailList` SMALLINT, `p_tinyint_isMandatoryRecepient` SMALLINT, `p_tinyint_isShowUser` SMALLINT)   BEGIN
UPDATE jobtrackaunz_userdata.Employee
SET UserName = p_varchar_userName,
FirstName = p_varchar_firstName,
LastName = p_varchar_lastName,
EmalAddress = p_varchar_emailAddress,
IsManager = p_tinyint_isManager,
IsEditoralContact = p_tinyint_isEditoralContact,
IsEmailList = p_tinyint_isEmailList,
IsMandatoryRecepient = p_tinyint_isMandatoryRecepient,
IsShowUser = p_tinyint_isShowUser,
UserAccessID = p_int_userAccessID
WHERE ID = p_int_userID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserPasswordByUserID` (`p_int_userID` INT, `p_varchar_newPassword` VARCHAR(200))   BEGIN
UPDATE jobtrackaunz_userdata.Employee
SET Password = p_varchar_newPassword,
PasswordUpdateDate = CURRENT_TIMESTAMP
WHERE EmployeeID = p_int_userID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `assignedroles`
--

CREATE TABLE `assignedroles` (
  `AssignedRolesID` int(11) NOT NULL,
  `AssignToAdmin` int(11) DEFAULT NULL,
  `CreatedBy` int(11) DEFAULT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `RegistrationID` int(11) NOT NULL,
  `Status` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audittb`
--

CREATE TABLE `audittb` (
  `AuditID` int(11) NOT NULL,
  `UserID` longtext DEFAULT NULL,
  `SessionID` longtext DEFAULT NULL,
  `IPAddress` longtext DEFAULT NULL,
  `PageAccessed` longtext DEFAULT NULL,
  `LoggedInAt` datetime(3) DEFAULT NULL,
  `LoggedOutAt` datetime(3) DEFAULT NULL,
  `LoginStatus` longtext DEFAULT NULL,
  `ControllerName` longtext DEFAULT NULL,
  `ActionName` longtext DEFAULT NULL,
  `UrlReferrer` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `calltoactiondata`
--

CREATE TABLE `calltoactiondata` (
  `CallToActionID` int(11) NOT NULL,
  `CallToActionIdentity` int(11) NOT NULL,
  `CallToActionName` varchar(100) NOT NULL,
  `BPSProductID` varchar(100) NOT NULL,
  `ServiceNumber` varchar(100) NOT NULL,
  `CallToActionType` varchar(100) NOT NULL,
  `CallToActionStatus` varchar(100) NOT NULL,
  `DateCreated` datetime NOT NULL,
  `UserName` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `calltoactiondata`
--

INSERT INTO `calltoactiondata` (`CallToActionID`, `CallToActionIdentity`, `CallToActionName`, `BPSProductID`, `ServiceNumber`, `CallToActionType`, `CallToActionStatus`, `DateCreated`, `UserName`) VALUES
(1, 1, 'Manuscript', 'ABCA', '37', 'START', 'On-Going', '2022-07-28 18:25:33', 'PE'),
(2, 1, 'Manuscript', 'ABCA', '37', 'DONE', 'Completed', '2022-07-28 18:30:40', 'PE'),
(3, 1, 'Coversheet', 'ABCA', '37', 'CODING START', 'On-Going', '2022-07-28 18:53:40', 'Coding'),
(4, 1, 'Coversheet', 'ABCA', '37', 'CODING DONE', 'On-Going', '2022-07-28 18:59:02', 'Coding'),
(5, 1, 'Coversheet', 'ABCA', '37', 'PDFQC START', 'On-Going', '2022-07-28 19:19:15', 'Coding'),
(6, 1, 'Coversheet', 'ABCA', '37', 'PDFQC DONE', 'Completed', '2022-07-28 19:42:57', 'Coding'),
(7, 2, 'Manuscript', 'ABCE', '71', 'START', 'On-Going', '2022-07-28 20:04:40', 'PE'),
(8, 2, 'Manuscript', 'ABCE', '71', 'DONE', 'Completed', '2022-07-28 20:05:23', 'PE'),
(9, 2, 'Coversheet', 'ABCE', '71', 'CODING START', 'On-Going', '2022-07-28 20:16:34', 'Coding'),
(10, 2, 'Coversheet', 'ABCE', '71', 'CODING DONE', 'On-Going', '2022-07-28 20:18:01', 'Coding'),
(11, 2, 'Coversheet', 'ABCE', '71', 'PDFQC START', 'On-Going', '2022-07-28 20:19:09', 'Coding'),
(12, 2, 'Coversheet', 'ABCE', '71', 'PDFQC DONE', 'Completed', '2022-07-28 20:19:41', 'Coding'),
(13, 3, 'Manuscript', 'BC', '61', 'START', 'On-Going', '2022-07-29 14:57:57', 'PEUser'),
(14, 3, 'Manuscript', 'BC', '61', 'DONE', 'Completed', '2022-07-29 14:58:00', 'PEUser'),
(15, 3, 'Coversheet', 'BC', '61', 'CODING START', 'On-Going', '2022-07-29 15:37:07', 'Coding2'),
(16, 3, 'Coversheet', 'BC', '61', 'CODING DONE', 'On-Going', '2022-07-29 15:39:04', 'Coding2'),
(17, 3, 'Coversheet', 'BC', '61', 'PDFQC START', 'On-Going', '2022-07-29 15:39:25', 'Coding2'),
(18, 3, 'Coversheet', 'BC', '61', 'PDFQC DONE', 'Completed', '2022-07-29 15:39:48', 'Coding2'),
(19, 4, 'Manuscript', 'BC', '62', 'START', 'On-Going', '2022-07-29 16:36:39', 'PEUser'),
(20, 4, 'Manuscript', 'BC', '62', 'DONE', 'Completed', '2022-07-29 16:36:56', 'PEUser'),
(21, 4, 'Coversheet', 'BC', '62', 'CODING START', 'On-Going', '2022-07-29 16:39:58', 'Coding2'),
(22, 4, 'Coversheet', 'BC', '62', 'CODING DONE', 'On-Going', '2022-07-29 16:40:35', 'Coding2'),
(23, 4, 'Coversheet', 'BC', '62', 'PDFQC START', 'On-Going', '2022-07-29 16:40:53', 'Coding2'),
(24, 4, 'Coversheet', 'BC', '62', 'PDFQC DONE', 'Completed', '2022-07-29 16:41:37', 'Coding2'),
(25, 3, 'Coversheet', 'BC', '61', 'ONLINE START', 'On-Going', '2022-08-01 14:58:52', 'Coding2'),
(26, 3, 'Coversheet', 'BC', '61', 'ONLINE DONE', 'Completed', '2022-08-01 16:18:11', 'Coding2'),
(27, 6, 'Manuscript', 'DEF', '91', 'START', 'On-Going', '2022-08-04 15:47:41', 'Chelsea.Mercado'),
(28, 6, 'Manuscript', 'DEF', '91', 'DONE', 'Completed', '2022-08-04 15:47:56', 'Chelsea.Mercado'),
(29, 10, 'Manuscript', 'DEF', '92', 'START', 'On-Going', '2022-08-08 14:54:13', 'Chelsea.Mercado'),
(30, 10, 'Manuscript', 'DEF', '92', 'DONE', 'Completed', '2022-08-08 14:54:20', 'Chelsea.Mercado'),
(31, 11, 'Manuscript', 'DEF', '92', 'START', 'On-Going', '2022-08-08 14:55:31', 'Chelsea.Mercado'),
(32, 11, 'Manuscript', 'DEF', '92', 'DONE', 'Completed', '2022-08-08 14:55:39', 'Chelsea.Mercado'),
(33, 12, 'Manuscript', 'DEF', '92', 'START', 'On-Going', '2022-08-08 14:55:46', 'Chelsea.Mercado'),
(34, 12, 'Manuscript', 'DEF', '92', 'DONE', 'Completed', '2022-08-08 14:55:53', 'Chelsea.Mercado'),
(35, 15, 'Manuscript', 'PL', '91', 'DONE', 'Completed', '2022-08-26 14:50:39', 'Chelsea.Mercado'),
(36, 15, 'Manuscript', 'PL', '91', 'START', 'On-Going', '2022-08-26 14:51:21', 'Chelsea.Mercado'),
(37, 16, 'Manuscript', 'PL', '91', 'START', 'On-Going', '2022-08-26 14:52:37', 'Chelsea.Mercado'),
(38, 16, 'Manuscript', 'PL', '91', 'DONE', 'Completed', '2022-08-26 14:52:54', 'Chelsea.Mercado'),
(39, 17, 'Manuscript', 'PL', '91', 'START', 'On-Going', '2022-08-26 15:35:06', 'Chelsea.Mercado'),
(40, 17, 'Manuscript', 'PL', '91', 'DONE', 'Completed', '2022-08-26 15:35:15', 'Chelsea.Mercado'),
(41, 19, 'Coversheet', 'DEF', '91', 'CODING START', 'On-Going', '2022-08-30 14:53:57', 'Coding1'),
(42, 19, 'Coversheet', 'DEF', '91', 'CODING DONE', 'On-Going', '2022-08-30 14:54:46', 'Coding1'),
(43, 19, 'Coversheet', 'DEF', '91', 'PDFQC START', 'On-Going', '2022-08-30 15:00:03', 'Coding1'),
(44, 19, 'Coversheet', 'DEF', '91', 'PDFQC DONE', 'Completed', '2022-08-30 15:00:14', 'Coding1'),
(45, 13, 'Manuscript', 'PL', '90', 'START', 'On-Going', '2022-08-30 16:04:20', 'Chelsea.Mercado'),
(46, 13, 'Manuscript', 'PL', '90', 'DONE', 'Completed', '2022-08-30 16:04:36', 'Chelsea.Mercado'),
(47, 23, 'Manuscript', 'IPC', '160', 'START', 'On-Going', '2022-09-19 17:38:04', 'Chelsea.Mercado'),
(48, 23, 'Manuscript', 'IPC', '160', 'DONE', 'Completed', '2022-09-19 17:38:16', 'Chelsea.Mercado'),
(49, 25, 'Manuscript', 'IPC', '160', 'START', 'On-Going', '2022-09-22 06:00:41', 'Chelsea.Mercado'),
(50, 25, 'Manuscript', 'IPC', '160', 'DONE', 'Completed', '2022-09-22 06:00:55', 'Chelsea.Mercado'),
(51, 26, 'Manuscript', 'IPC', '160', 'START', 'On-Going', '2022-09-22 06:01:08', 'Chelsea.Mercado'),
(52, 26, 'Manuscript', 'IPC', '160', 'DONE', 'Completed', '2022-09-22 06:01:15', 'Chelsea.Mercado'),
(53, 27, 'Manuscript', 'IPC', '160', 'START', 'On-Going', '2022-09-22 06:17:40', 'Chelsea.Mercado'),
(54, 27, 'Manuscript', 'IPC', '160', 'DONE', 'Completed', '2022-09-22 06:17:48', 'Chelsea.Mercado'),
(55, 28, 'Manuscript', 'IPC', '160', 'START', 'On-Going', '2022-09-22 06:17:55', 'Chelsea.Mercado'),
(56, 28, 'Manuscript', 'IPC', '160', 'DONE', 'Completed', '2022-09-22 06:18:02', 'Chelsea.Mercado'),
(57, 29, 'Manuscript', 'PL', '92', 'START', 'On-Going', '2022-09-23 16:35:22', 'Chelsea.Mercado'),
(58, 29, 'Manuscript', 'PL', '92', 'DONE', 'Completed', '2022-09-23 16:35:30', 'Chelsea.Mercado'),
(59, 30, 'Manuscript', 'PL', '92', 'START', 'On-Going', '2022-09-23 16:39:27', 'Chelsea.Mercado'),
(60, 30, 'Manuscript', 'PL', '92', 'DONE', 'Completed', '2022-09-23 16:39:36', 'Chelsea.Mercado'),
(61, 31, 'Manuscript', 'PL', '92', 'START', 'On-Going', '2022-09-23 16:39:43', 'Chelsea.Mercado'),
(62, 31, 'Manuscript', 'PL', '92', 'DONE', 'Completed', '2022-09-23 16:39:51', 'Chelsea.Mercado'),
(63, 19, 'Coversheet', 'DEF', '91', 'ONLINE START', 'On-Going', '2022-09-30 22:16:41', 'Coding1'),
(64, 19, 'Coversheet', 'DEF', '91', 'ONLINE DONE', 'Completed', '2022-09-30 22:16:54', 'Coding1'),
(65, 32, 'Manuscript', 'DEF', '91', 'START', 'On-Going', '2022-09-30 22:27:51', 'Chelsea.Mercado'),
(66, 32, 'Manuscript', 'DEF', '91', 'DONE', 'Completed', '2022-09-30 22:28:01', 'Chelsea.Mercado'),
(67, 14, 'SendToPrint', 'DEF', '91', 'CONSO HIGHLIGHT START', 'On-Going', '2022-10-03 05:33:07', 'STPe2'),
(68, 14, 'SendToPrint', 'DEF', '91', 'CONSO HIGHLIGHT DONE', 'On-Going', '2022-10-03 05:41:21', 'STPe2'),
(69, 14, 'SendToPrint', 'DEF', '91', 'FILING INSTRUCTION START', 'On-Going', '2022-10-03 05:58:03', 'STPe2'),
(70, 14, 'SendToPrint', 'DEF', '91', 'FILING INSTRUCTION DONE', 'On-Going', '2022-10-03 05:58:20', 'STPe2'),
(71, 14, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 1 START', 'On-Going', '2022-10-11 15:14:32', 'STPe2'),
(72, 14, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 1 DONE', 'On-Going', '2022-10-11 15:21:22', 'STPe2'),
(73, 14, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 2 START', 'On-Going', '2022-10-11 15:25:12', 'STPe1'),
(74, 14, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 2 DONE', 'On-Going', '2022-10-11 15:29:23', 'STPe1'),
(75, 14, 'SendToPrint', 'DEF', '91', 'UECJ START', 'On-Going', '2022-10-11 15:35:04', 'STPe2'),
(76, 14, 'SendToPrint', 'DEF', '91', 'UECJ DONE', 'On-Going', '2022-10-11 15:38:01', 'STPe2'),
(77, 14, 'SendToPrint', 'DEF', '91', 'PC1/PC2 START', 'On-Going', '2022-10-11 15:55:31', 'STPe1'),
(78, 14, 'SendToPrint', 'DEF', '91', 'PC1/PC2 DONE', 'On-Going', '2022-10-11 15:59:34', 'STPe1'),
(81, 14, 'SendToPrint', 'DEF', '91', 'READY TO PRINT DONE', 'On-Going', '2022-10-19 19:23:15', 'Chelsea.Mercado'),
(82, 14, 'SendToPrint', 'DEF', '91', 'PUDDINGBURN DONE', 'On-Going', '2022-10-19 19:27:40', 'Chelsea.Mercado'),
(83, 14, 'SendToPrint', 'DEF', '91', 'EBINDER START', 'On-Going', '2022-10-20 15:40:27', 'STPe2'),
(84, 14, 'SendToPrint', 'DEF', '91', 'EBINDER DONE', 'On-Going', '2022-10-20 15:44:35', 'STPe2'),
(85, 14, 'SendToPrint', 'DEF', '91', 'STABLE DATA START', 'On-Going', '2022-10-20 15:57:05', 'Chelsea.Mercado'),
(86, 14, 'SendToPrint', 'DEF', '91', 'STABLE DATA DONE', 'Completed', '2022-10-20 16:03:45', 'Chelsea.Mercado'),
(87, 15, 'SendToPrint', 'DEF', '91', 'CONSO HIGHLIGHT START', 'On-Going', '2022-10-21 19:20:01', 'STPe1'),
(88, 15, 'SendToPrint', 'DEF', '91', 'CONSO HIGHLIGHT DONE', 'On-Going', '2022-10-21 19:40:13', 'STPe1'),
(89, 15, 'SendToPrint', 'DEF', '91', 'FILING INSTRUCTION START', 'On-Going', '2022-10-21 19:40:23', 'STPe1'),
(90, 15, 'SendToPrint', 'DEF', '91', 'FILING INSTRUCTION DONE', 'On-Going', '2022-10-21 19:50:53', 'STPe1'),
(91, 15, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 1 START', 'On-Going', '2022-10-21 19:51:04', 'STPe1'),
(92, 15, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 1 DONE', 'On-Going', '2022-10-21 19:51:10', 'STPe1'),
(93, 15, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 2 START', 'On-Going', '2022-10-21 19:51:17', 'STPe1'),
(94, 15, 'SendToPrint', 'DEF', '91', 'DUMMY FILING 2 DONE', 'On-Going', '2022-10-21 19:51:24', 'STPe1'),
(95, 15, 'SendToPrint', 'DEF', '91', 'UECJ START', 'On-Going', '2022-10-21 19:51:30', 'STPe1'),
(96, 15, 'SendToPrint', 'DEF', '91', 'UECJ DONE', 'On-Going', '2022-10-21 19:51:36', 'STPe1'),
(97, 15, 'SendToPrint', 'DEF', '91', 'PC1/PC2 START', 'On-Going', '2022-10-21 19:51:43', 'STPe1'),
(98, 15, 'SendToPrint', 'DEF', '91', 'PC1/PC2 DONE', 'On-Going', '2022-10-21 19:51:49', 'STPe1'),
(99, 15, 'SendToPrint', 'DEF', '91', 'READY TO PRINT DONE', 'On-Going', '2022-10-21 19:52:32', 'Chelsea.Mercado'),
(100, 15, 'SendToPrint', 'DEF', '91', 'PUDDINGBURN DONE', 'On-Going', '2022-10-21 19:53:03', 'Chelsea.Mercado'),
(101, 15, 'SendToPrint', 'DEF', '91', 'EBINDER START', 'On-Going', '2022-10-21 19:53:30', 'STPe1'),
(102, 15, 'SendToPrint', 'DEF', '91', 'EBINDER DONE', 'On-Going', '2022-10-21 19:53:37', 'STPe1'),
(103, 15, 'SendToPrint', 'DEF', '91', 'STABLE DATA START', 'On-Going', '2022-10-21 19:53:44', 'STPe1'),
(104, 15, 'SendToPrint', 'DEF', '91', 'STABLE DATA DONE', 'Completed', '2022-10-21 19:56:00', 'STPe1'),
(105, 38, 'Manuscript', 'CIV', '51', 'START', 'On-Going', '2022-10-24 02:21:36', 'Renalyn.Masu-ay'),
(106, 37, 'Manuscript', 'CIV', '51', 'START', 'On-Going', '2022-10-24 02:21:47', 'Renalyn.Masu-ay'),
(107, 36, 'Manuscript', 'CIV', '51', 'START', 'On-Going', '2022-10-24 02:21:55', 'Renalyn.Masu-ay'),
(108, 35, 'Manuscript', 'CIV', '51', 'START', 'On-Going', '2022-10-24 02:22:09', 'Renalyn.Masu-ay'),
(109, 33, 'Manuscript', 'CIV', '51', 'START', 'On-Going', '2022-10-24 02:22:19', 'Renalyn.Masu-ay'),
(110, 38, 'Manuscript', 'CIV', '51', 'DONE', 'Completed', '2022-10-24 02:29:01', 'Renalyn.Masu-ay'),
(111, 37, 'Manuscript', 'CIV', '51', 'DONE', 'Completed', '2022-10-24 02:29:17', 'Renalyn.Masu-ay'),
(112, 36, 'Manuscript', 'CIV', '51', 'DONE', 'Completed', '2022-10-24 02:29:27', 'Renalyn.Masu-ay'),
(113, 35, 'Manuscript', 'CIV', '51', 'DONE', 'Completed', '2022-10-24 02:29:34', 'Renalyn.Masu-ay'),
(114, 33, 'Manuscript', 'CIV', '51', 'DONE', 'Completed', '2022-10-24 02:29:41', 'Renalyn.Masu-ay'),
(115, 34, 'Coversheet', 'CIV', '51', 'CODING DONE', 'On-Going', '2022-10-24 02:41:59', 'sierrakx.coding'),
(116, 34, 'Coversheet', 'CIV', '51', 'PDFQC START', 'On-Going', '2022-10-24 02:42:14', 'sierrakx.coding'),
(117, 35, 'Coversheet', 'CIV', '51', 'CODING DONE', 'On-Going', '2022-10-24 14:12:18', 'sierrakx.coding2'),
(118, 35, 'Coversheet', 'CIV', '51', 'PDFQC START', 'On-Going', '2022-10-24 14:12:37', 'sierrakx.coding2'),
(119, 36, 'Coversheet', 'CIV', '51', 'CODING START', 'On-Going', '2022-10-24 14:21:01', 'sierrak.coding3'),
(120, 36, 'Coversheet', 'CIV', '51', 'CODING DONE', 'On-Going', '2022-10-24 14:21:09', 'sierrak.coding3'),
(121, 36, 'Coversheet', 'CIV', '51', 'PDFQC START', 'On-Going', '2022-10-24 14:21:26', 'sierrak.coding3'),
(122, 36, 'Coversheet', 'CIV', '51', 'PDFQC DONE', 'Completed', '2022-10-24 14:21:34', 'sierrak.coding3'),
(123, 36, 'Coversheet', 'CIV', '51', 'ONLINE START', 'On-Going', '2022-10-24 14:29:05', 'sierrak.coding3'),
(124, 36, 'Coversheet', 'CIV', '51', 'ONLINE DONE', 'Completed', '2022-10-24 14:29:05', 'sierrak.coding3'),
(125, 16, 'SendToPrint', 'CIV', '51', 'CONSO HIGHLIGHT START', 'On-Going', '2022-10-24 14:43:15', 'sierrakx.stp1'),
(126, 16, 'SendToPrint', 'CIV', '51', 'CONSO HIGHLIGHT DONE', 'On-Going', '2022-10-24 14:43:29', 'sierrakx.stp1'),
(127, 16, 'SendToPrint', 'CIV', '51', 'FILING INSTRUCTION START', 'On-Going', '2022-10-24 14:44:11', 'sierrakx.stp2'),
(128, 16, 'SendToPrint', 'CIV', '51', 'FILING INSTRUCTION DONE', 'On-Going', '2022-10-24 14:44:18', 'sierrakx.stp2'),
(129, 16, 'SendToPrint', 'CIV', '51', 'DUMMY FILING 1 START', 'On-Going', '2022-10-24 14:44:49', 'sierrakx.stp3'),
(130, 16, 'SendToPrint', 'CIV', '51', 'DUMMY FILING 1 DONE', 'On-Going', '2022-10-24 14:45:09', 'sierrakx.stp3'),
(131, 16, 'SendToPrint', 'CIV', '51', 'DUMMY FILING 2 START', 'On-Going', '2022-10-24 14:45:31', 'sierrakx.stp4'),
(132, 16, 'SendToPrint', 'CIV', '51', 'DUMMY FILING 2 DONE', 'On-Going', '2022-10-24 14:45:38', 'sierrakx.stp4'),
(133, 16, 'SendToPrint', 'CIV', '51', 'UECJ START', 'On-Going', '2022-10-24 14:50:44', 'sierrakx.stp1'),
(134, 16, 'SendToPrint', 'CIV', '51', 'UECJ DONE', 'On-Going', '2022-10-24 14:50:58', 'sierrakx.stp1'),
(135, 16, 'SendToPrint', 'CIV', '51', 'PC1/PC2 START', 'On-Going', '2022-10-24 16:27:21', 'sierrakx.stp2'),
(136, 16, 'SendToPrint', 'CIV', '51', 'PC1/PC2 DONE', 'On-Going', '2022-10-24 16:27:35', 'sierrakx.stp2'),
(137, 16, 'SendToPrint', 'CIV', '51', 'READY TO PRINT DONE', 'On-Going', '2022-10-24 16:58:14', 'Renalyn.Masu-ay'),
(138, 16, 'SendToPrint', 'CIV', '51', 'PUDDINGBURN DONE', 'On-Going', '2022-10-24 17:00:55', 'Renalyn.Masu-ay'),
(139, 16, 'SendToPrint', 'CIV', '51', 'EBINDER START', 'On-Going', '2022-10-24 17:15:31', 'sierrakx.stp3'),
(140, 16, 'SendToPrint', 'CIV', '51', 'EBINDER DONE', 'On-Going', '2022-10-24 17:15:39', 'sierrakx.stp3'),
(141, 16, 'SendToPrint', 'CIV', '51', 'STABLE DATA START', 'On-Going', '2022-10-24 17:16:11', 'Renalyn.Masu-ay'),
(142, 16, 'SendToPrint', 'CIV', '51', 'STABLE DATA DONE', 'Completed', '2022-10-24 17:16:19', 'Renalyn.Masu-ay'),
(143, 46, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:11:25', 'MarkAnthony.Grande'),
(144, 45, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:13:33', 'MarkAnthony.Grande'),
(145, 44, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:13:40', 'MarkAnthony.Grande'),
(146, 43, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:13:52', 'MarkAnthony.Grande'),
(147, 42, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:14:11', 'MarkAnthony.Grande'),
(148, 41, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:14:19', 'MarkAnthony.Grande'),
(149, 40, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:14:28', 'MarkAnthony.Grande'),
(150, 39, 'Manuscript', 'PEV', '241', 'START', 'On-Going', '2022-10-24 20:14:48', 'MarkAnthony.Grande'),
(151, 46, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:18:47', 'MarkAnthony.Grande'),
(152, 45, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:18:54', 'MarkAnthony.Grande'),
(153, 44, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:19:06', 'MarkAnthony.Grande'),
(154, 43, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:19:17', 'MarkAnthony.Grande'),
(155, 42, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:19:32', 'MarkAnthony.Grande'),
(156, 41, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:19:44', 'MarkAnthony.Grande'),
(157, 40, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:19:51', 'MarkAnthony.Grande'),
(158, 39, 'Manuscript', 'PEV', '241', 'DONE', 'Completed', '2022-10-24 20:19:59', 'MarkAnthony.Grande'),
(159, 37, 'Coversheet', 'PEV', '241', 'CODING START', 'On-Going', '2022-10-26 16:53:09', 'sierrakx.coding'),
(160, 37, 'Coversheet', 'PEV', '241', 'CODING DONE', 'On-Going', '2022-10-26 16:53:34', 'sierrakx.coding'),
(161, 37, 'Coversheet', 'PEV', '241', 'PDFQC START', 'On-Going', '2022-10-26 16:53:49', 'sierrakx.coding'),
(162, 37, 'Coversheet', 'PEV', '241', 'PDFQC DONE', 'Completed', '2022-10-26 16:54:08', 'sierrakx.coding'),
(163, 40, 'Coversheet', 'PEV', '241', 'CODING START', 'On-Going', '2022-11-04 14:16:48', 'sierrakx.coding'),
(164, 40, 'Coversheet', 'PEV', '241', 'CODING DONE', 'On-Going', '2022-11-04 14:16:58', 'sierrakx.coding'),
(165, 40, 'Coversheet', 'PEV', '241', 'PDFQC START', 'On-Going', '2022-11-04 14:17:08', 'sierrakx.coding'),
(166, 40, 'Coversheet', 'PEV', '241', 'PDFQC DONE', 'Completed', '2022-11-04 14:17:18', 'sierrakx.coding'),
(167, 40, 'Coversheet', 'PEV', '241', 'ONLINE START', 'On-Going', '2022-11-04 14:19:02', 'sierrakx.coding'),
(168, 40, 'Coversheet', 'PEV', '241', 'ONLINE DONE', 'Completed', '2022-11-04 14:19:04', 'sierrakx.coding'),
(169, 54, 'Manuscript', 'FRAN', '68', 'START', 'On-Going', '2022-11-21 23:54:59', 'Chelsea.Mercado'),
(170, 53, 'Manuscript', 'FRAN', '68', 'START', 'On-Going', '2022-11-21 23:55:11', 'Chelsea.Mercado'),
(171, 52, 'Manuscript', 'FRAN', '68', 'START', 'On-Going', '2022-11-21 23:55:21', 'Chelsea.Mercado'),
(172, 51, 'Manuscript', 'FRAN', '68', 'START', 'On-Going', '2022-11-21 23:55:31', 'Chelsea.Mercado'),
(173, 51, 'Manuscript', 'FRAN', '68', 'DONE', 'Completed', '2022-11-22 00:05:15', 'Chelsea.Mercado'),
(174, 52, 'Manuscript', 'FRAN', '68', 'DONE', 'Completed', '2022-11-22 00:05:25', 'Chelsea.Mercado'),
(175, 53, 'Manuscript', 'FRAN', '68', 'DONE', 'Completed', '2022-11-22 00:05:33', 'Chelsea.Mercado'),
(176, 54, 'Manuscript', 'FRAN', '68', 'DONE', 'Completed', '2022-11-22 00:05:54', 'Chelsea.Mercado'),
(177, 46, 'Coversheet', 'FRAN', '68', 'CODING DONE', 'On-Going', '2022-11-22 00:24:36', 'sierrakx.coding2'),
(178, 60, 'Manuscript', 'BC', '60', 'START', 'On-Going', '2022-12-09 18:50:06', 'EleanorAnne.Reyes'),
(179, 60, 'Manuscript', 'BC', '60', 'DONE', 'Completed', '2022-12-09 18:51:03', 'EleanorAnne.Reyes'),
(180, 58, 'Manuscript', 'BC', '60', 'START', 'On-Going', '2022-12-09 19:01:32', 'EleanorAnne.Reyes'),
(181, 58, 'Manuscript', 'BC', '60', 'DONE', 'Completed', '2022-12-09 19:01:59', 'EleanorAnne.Reyes'),
(182, 56, 'Manuscript', 'BC', '60', 'START', 'On-Going', '2022-12-09 19:21:25', 'EleanorAnne.Reyes'),
(183, 56, 'Manuscript', 'BC', '60', 'DONE', 'Completed', '2022-12-09 19:21:59', 'EleanorAnne.Reyes'),
(184, 48, 'Coversheet', 'BC', '60', 'CODING DONE', 'On-Going', '2022-12-09 19:35:52', 'Coding1'),
(185, 50, 'Coversheet', 'BC', '60', 'CODING START', 'On-Going', '2022-12-09 19:36:49', 'Coding1'),
(186, 50, 'Coversheet', 'BC', '60', 'CODING DONE', 'On-Going', '2022-12-09 19:37:11', 'Coding1'),
(187, 48, 'Coversheet', 'BC', '60', 'PDFQC START', 'On-Going', '2022-12-09 20:19:38', 'Coding1'),
(188, 49, 'Coversheet', 'BC', '60', 'CODING START', 'On-Going', '2022-12-09 20:30:13', 'Coding2'),
(189, 49, 'Coversheet', 'BC', '60', 'CODING DONE', 'On-Going', '2022-12-09 20:30:37', 'Coding2'),
(190, 49, 'Coversheet', 'BC', '60', 'PDFQC START', 'On-Going', '2022-12-09 20:30:56', 'Coding2'),
(191, 49, 'Coversheet', 'BC', '60', 'PDFQC DONE', 'Completed', '2022-12-09 20:31:18', 'Coding2'),
(192, 72, 'Manuscript', 'CIV', '49', 'START', 'On-Going', '2023-01-10 16:01:40', 'Renalyn.Masu-ay'),
(193, 72, 'Manuscript', 'CIV', '49', 'DONE', 'Completed', '2023-01-10 16:01:53', 'Renalyn.Masu-ay'),
(194, 72, 'Manuscript', 'CIV', '49', 'DONE', 'Completed', '2023-01-10 16:01:59', 'Renalyn.Masu-ay'),
(195, 71, 'Manuscript', 'CIV', '49', 'START', 'On-Going', '2023-01-10 16:03:22', 'Renalyn.Masu-ay'),
(196, 71, 'Manuscript', 'CIV', '49', 'DONE', 'Completed', '2023-01-10 16:03:30', 'Renalyn.Masu-ay'),
(197, 55, 'Coversheet', 'CIV', '49', 'CODING DONE', 'On-Going', '2023-01-10 16:11:18', 'sierrakx.coding'),
(198, 55, 'Coversheet', 'CIV', '49', 'PDFQC START', 'On-Going', '2023-01-10 16:11:26', 'sierrakx.coding'),
(199, 17, 'SendToPrint', 'PEV', '241', 'CONSO HIGHLIGHT START', 'On-Going', '2023-01-10 16:25:55', 'sierrakx.stp1'),
(200, 74, 'Manuscript', 'FRAN', '68', 'START', 'On-Going', '2023-02-17 14:55:12', 'Chelsea.Mercado'),
(201, 74, 'Manuscript', 'FRAN', '68', 'DONE', 'Completed', '2023-02-17 14:55:33', 'Chelsea.Mercado'),
(202, 73, 'Manuscript', 'FRAN', '68', 'START', 'On-Going', '2023-02-17 14:55:42', 'Chelsea.Mercado'),
(203, 73, 'Manuscript', 'FRAN', '68', 'DONE', 'Completed', '2023-02-17 14:55:52', 'Chelsea.Mercado'),
(204, 56, 'Coversheet', 'FRAN', '68', 'CODING DONE', 'On-Going', '2023-02-17 15:00:33', 'sierrakx.coding'),
(205, 56, 'Coversheet', 'FRAN', '68', 'PDFQC START', 'On-Going', '2023-02-17 15:01:19', 'sierrakx.coding'),
(206, 76, 'Manuscript', 'ABCE', '68', 'START', 'On-Going', '2023-03-01 20:49:00', 'Patricia.Artajo'),
(207, 76, 'Manuscript', 'ABCE', '68', 'DONE', 'Completed', '2023-03-01 20:49:09', 'Patricia.Artajo'),
(208, 57, 'Coversheet', 'ABCE', '68', 'CODING DONE', 'On-Going', '2023-03-01 20:55:58', 'sierrakx.coding'),
(209, 57, 'Coversheet', 'ABCE', '68', 'PDFQC START', 'On-Going', '2023-03-01 20:56:39', 'sierrakx.coding');

-- --------------------------------------------------------

--
-- Table structure for table `completionemaildata`
--

CREATE TABLE `completionemaildata` (
  `CompletionEmailDataID` int(11) NOT NULL,
  `CompletionEmailID` int(11) NOT NULL,
  `CoversheetID` int(11) NOT NULL,
  `AttachmentName` varchar(1000) DEFAULT NULL,
  `AttachmentSize` varchar(500) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `completionemail_mt`
--

CREATE TABLE `completionemail_mt` (
  `CompletionEmailID` int(11) NOT NULL,
  `CompletionEmailType` varchar(100) DEFAULT NULL,
  `CompletionEmailReceipient` varchar(500) DEFAULT NULL,
  `CompletionEmailSubject` varchar(500) DEFAULT NULL,
  `CompletionEmailBody` varchar(1000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `completionemail_mt`
--

INSERT INTO `completionemail_mt` (`CompletionEmailID`, `CompletionEmailType`, `CompletionEmailReceipient`, `CompletionEmailSubject`, `CompletionEmailBody`) VALUES
(1, 'Coversheet – XML Editing', NULL, 'Completed XML Editing - [Product]_[Service No.]_[Coversheet no.]', NULL),
(2, 'Coversheet – Online', NULL, 'Completed Online - [Product]_[Service No.]_[Coversheet no.]', NULL),
(3, 'Subsequent Pass requested', NULL, 'Subsequent Pass Required - [Product]_[Service No.]_[Coversheet no.]', NULL),
(4, 'Subsequent Pass completion', NULL, 'Completed Subsequent Pass - [Product]_[Service No.]_[Coversheet no.]', NULL),
(5, 'Proceed to Online', NULL, 'Proceed to Online - [Product]_[Service No.]_[Coversheet no.]', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `coversheetdata`
--

CREATE TABLE `coversheetdata` (
  `CoversheetID` int(11) NOT NULL,
  `CoversheetNumber` varchar(200) NOT NULL,
  `BPSProductID` varchar(100) NOT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `TaskNumber` varchar(100) NOT NULL,
  `CoversheetTier` varchar(50) DEFAULT NULL,
  `Editor` varchar(100) DEFAULT NULL,
  `ChargeCode` varchar(100) DEFAULT NULL,
  `TargetPressDate` datetime DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `CurrentTask` varchar(1000) DEFAULT NULL,
  `TaskStatus` varchar(1000) DEFAULT NULL,
  `TaskType` varchar(50) DEFAULT NULL,
  `GuideCard` varchar(500) DEFAULT NULL,
  `LocationOfManuscript` varchar(500) DEFAULT NULL,
  `GeneralLegRefCheck` varchar(45) DEFAULT NULL,
  `GeneralTOC` varchar(45) DEFAULT NULL,
  `GeneralTOS` varchar(45) DEFAULT NULL,
  `GeneralReprints` varchar(45) DEFAULT NULL,
  `GeneralFascicleInsertion` varchar(45) DEFAULT NULL,
  `GeneralGraphicLink` varchar(45) DEFAULT NULL,
  `GeneralGraphicEmbed` varchar(45) DEFAULT NULL,
  `GeneralHandtooling` varchar(45) DEFAULT NULL,
  `GeneralNonContent` varchar(45) DEFAULT NULL,
  `GeneralSamplePages` varchar(45) DEFAULT NULL,
  `GeneralComplexTask` varchar(45) DEFAULT NULL,
  `FurtherInstruction` varchar(2000) DEFAULT NULL,
  `UpdateType` varchar(50) DEFAULT NULL,
  `AcceptedDate` datetime DEFAULT NULL,
  `JobOwner` varchar(500) DEFAULT NULL,
  `UpdateEmailCC` varchar(1000) DEFAULT NULL,
  `IsXMLEditing` varchar(50) DEFAULT NULL,
  `CodingDueDate` datetime DEFAULT NULL,
  `CodingStartDate` datetime DEFAULT NULL,
  `CodingDoneDate` datetime DEFAULT NULL,
  `CodingStatus` varchar(100) DEFAULT NULL,
  `Subtask` varchar(1000) DEFAULT NULL,
  `PDFQCStartDate` datetime DEFAULT NULL,
  `PDFQCDoneDate` datetime DEFAULT NULL,
  `PDFQAStatus` varchar(100) DEFAULT NULL,
  `XMLStatus` varchar(50) DEFAULT NULL,
  `IsOnline` varchar(50) DEFAULT NULL,
  `OnlineDueDate` datetime DEFAULT NULL,
  `OnlineStartDate` datetime DEFAULT NULL,
  `OnlineDoneDate` datetime DEFAULT NULL,
  `OnlineStatus` varchar(500) DEFAULT NULL,
  `OnlineTimeliness` varchar(500) DEFAULT NULL,
  `ReasonIfLate` varchar(1000) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL,
  `ManuscriptID` varchar(50) DEFAULT NULL,
  `RevisedOnlineDueDate` datetime DEFAULT NULL,
  `CoversheetCheckbox` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `coversheetdata`
--

INSERT INTO `coversheetdata` (`CoversheetID`, `CoversheetNumber`, `BPSProductID`, `ServiceNumber`, `TaskNumber`, `CoversheetTier`, `Editor`, `ChargeCode`, `TargetPressDate`, `ActualPressDate`, `CurrentTask`, `TaskStatus`, `TaskType`, `GuideCard`, `LocationOfManuscript`, `GeneralLegRefCheck`, `GeneralTOC`, `GeneralTOS`, `GeneralReprints`, `GeneralFascicleInsertion`, `GeneralGraphicLink`, `GeneralGraphicEmbed`, `GeneralHandtooling`, `GeneralNonContent`, `GeneralSamplePages`, `GeneralComplexTask`, `FurtherInstruction`, `UpdateType`, `AcceptedDate`, `JobOwner`, `UpdateEmailCC`, `IsXMLEditing`, `CodingDueDate`, `CodingStartDate`, `CodingDoneDate`, `CodingStatus`, `Subtask`, `PDFQCStartDate`, `PDFQCDoneDate`, `PDFQAStatus`, `XMLStatus`, `IsOnline`, `OnlineDueDate`, `OnlineStartDate`, `OnlineDoneDate`, `OnlineStatus`, `OnlineTimeliness`, `ReasonIfLate`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`, `ManuscriptID`, `RevisedOnlineDueDate`, `CoversheetCheckbox`) VALUES
(1, 'ABCA_37_1', 'ABCA', '37', 'Task1', 'Tier 2', 'Jennifer Murray', 'ABCA', '2022-03-10 00:00:00', NULL, 'PDF QC', 'On-Going', 'COMMENTARY', 'example', 'example', '1', '0', '1', '0', '1', '0', '1', '0', '0', '0', '0', 'example', 'Manus-Light', '2022-08-22 15:27:51', '5', 'Coding2@example.com', '1', '2022-08-08 00:00:00', '2022-07-28 18:53:00', '2022-07-28 18:59:00', 'Completed', NULL, '2022-07-28 19:19:00', '2022-07-28 19:42:00', 'Completed', 'Completed', '1', '2022-08-10 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-07-28 18:31:15', 3, '2022-12-14 07:06:11', 28, '1', NULL, 'Checked'),
(2, 'ABCE_71_1', 'ABCE', '71', 'Task1', 'Tier 3', 'Andrew Badaoui', 'ABC', '2022-03-25 00:00:00', NULL, 'PDF QC', 'On-Going', 'COMMENTARY', 'example', 'example', '1', '1', '1', '1', '1', '1', '0', '0', '0', '0', '0', 'example', 'Manus-Light', '2022-08-22 15:31:54', '4', 'Coding@sample.com', '1', '2022-08-08 00:00:00', '2022-07-28 20:16:00', '2022-07-28 20:17:00', 'Completed', NULL, '2022-07-28 20:19:00', '2022-07-28 20:19:00', 'On-Going', 'Completed', '1', '2022-08-10 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-07-28 20:13:15', 3, '2022-08-22 15:31:54', 7, '2', NULL, NULL),
(3, 'BC_61_1', 'BC', '61', 'Task1', 'Tier 3', 'Rose Thomsen', 'BC', '2022-02-16 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'new example', 'new example', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', 'new example', 'Manus-Medium', '2022-08-22 15:32:30', '5', 'Coding2@example.com', '1', '2022-08-17 00:00:00', '2022-07-29 15:37:00', '2022-07-29 15:39:00', 'Completed', NULL, '2022-07-29 15:39:00', '2022-07-29 15:39:00', 'Completed', NULL, '1', '2022-08-19 00:00:00', '2022-08-01 14:58:00', '2022-08-01 16:18:00', 'Completed', 'Ahead', NULL, '2022-07-29 14:58:52', 3, '2022-08-22 15:32:30', 7, '3', NULL, NULL),
(4, 'BC_62_1', 'BC', '62', 'Task1', 'Tier 3', 'Rose Thomsen', 'BC', '2022-07-13 00:00:00', NULL, 'PDF QC', 'On-Going', 'COMMENTARY', 'example today', 'example today', '1', '0', '1', '0', '1', '0', '1', '0', '1', '0', '1', 'example today', 'Manus-Heavy', '2022-08-22 15:30:31', '5', 'Coding2@example.com', '1', '2022-08-31 00:00:00', '2022-07-29 16:39:00', '2022-07-29 16:40:00', 'Completed', NULL, '2022-07-29 16:40:00', '2022-07-29 16:41:00', 'Completed', NULL, '1', '2022-09-02 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-07-29 16:37:36', 3, '2022-08-22 15:30:31', 7, '4', NULL, NULL),
(19, 'DEF_91_1', 'DEF', '91', 'Task1', 'Tier 2', 'Genevieve Corish', 'DEF', '2021-05-13 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'second guide card', 'second guide card', '1', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0', 'second guide card', 'Manus-Heavy', '2022-08-22 15:29:23', '4', 'Coding1@example.com', '1', '2022-09-07 00:00:00', '2022-08-30 14:53:00', '2022-08-30 14:54:00', 'Completed', NULL, '2022-08-30 15:00:00', '2022-08-30 15:00:00', 'Completed', NULL, '1', '2022-09-09 00:00:00', '2022-09-30 22:16:00', '2022-09-30 22:16:00', 'Completed', 'Delay', NULL, '2022-08-08 14:30:34', 28, '2022-10-03 00:13:17', 28, '7,8', NULL, 'Checked'),
(21, 'DEF_92_1', 'DEF', '92', 'Task1', 'Tier 2', 'Genevieve Corish', 'DEF', '2021-08-12 00:00:00', NULL, NULL, 'New', 'COMMENTARY', '\"dump guidecard\"', '\"dump guidecard\"', '1', '0', '1', '0', '1', '0', '0', '0', '0', '0', '0', '\"dump guidecard\"', 'Manus-Heavy', '2022-08-22 15:31:14', '5', 'Coding1@example.com', '1', '2022-09-08 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-09-12 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-08-08 14:57:54', 28, '2022-09-19 16:00:24', 28, '10,11', NULL, 'Checked'),
(24, 'DEF_92_2', 'DEF', '92', 'Task2', 'Tier 2', 'Genevieve Corish', 'DEF', '2021-08-12 00:00:00', NULL, NULL, 'New', 'COMMENTARY', '\"new guide\"\n\'card\'', '\"new guide\"\n\'card\'', '0', '0', '1', '0', '1', '0', '1', '0', '1', '0', '1', '\"new guide\"\n\'card\'', 'Manus-Heavy', NULL, NULL, NULL, '1', '2022-09-08 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-09-12 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-08-08 15:12:46', 28, '2022-09-19 15:47:14', 28, '12', '2022-08-09 00:00:00', 'Checked'),
(25, 'DEF_91_2', 'DEF', '91', 'Task2', 'Tier 2', 'Genevieve Corish', 'DEF', '2021-05-13 00:00:00', NULL, NULL, 'New', 'LEGISLATION', 'fourth guide card', 'fourth guide card', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0', 'fourth guide card', 'Key Leg', '2022-08-22 15:30:00', '5', 'Coding2@example.com', '1', '2022-08-17 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-08-19 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-08-09 02:43:04', 28, '2022-09-29 01:28:58', 28, '9', NULL, 'Checked'),
(26, 'PL_91_Task1_N12345', 'PL', '91', 'Task1', 'Tier 3', 'Genevieve Corish', 'PL', '2021-07-15 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'N12345', 'N12345', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'N12345', 'Manus-Medium', NULL, NULL, NULL, '1', '2022-09-02 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-09-06 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-08-23 15:50:10', 28, '2022-09-22 06:50:50', 28, '15', NULL, 'Checked'),
(27, 'IPC_160_Task1_guidecard', 'IPC', '160', 'Task1', 'Tier 1', 'Genevieve Corish', 'IPC', '2021-06-29 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'guidecard', 'manuscript', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'further instruction', 'Manus-Heavy', '2022-11-04 14:06:09', '32', 'katherine.sierra@spi-global.com', '1', '2022-09-30 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-10-04 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-09-19 17:38:49', 28, '2022-11-04 14:06:09', 31, '23', NULL, 'Checked'),
(29, 'IPC_160_Task2_guidecard', 'IPC', '160', 'Task2', 'Tier 1', 'Genevieve Corish', 'IPC', '2021-06-29 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'guidecards', 'guidecard', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'guidecard', 'Manus-Heavy', NULL, NULL, NULL, '1', '2022-10-25 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-10-27 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-09-22 06:30:26', 28, '2022-09-22 06:35:59', 28, '27,28', NULL, 'Checked'),
(30, 'PL_91_Task2_new guidecard', 'PL', '91', 'Task2', 'Tier 3', 'Genevieve Corish', 'PL', '2021-07-15 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'new guidecard', 'new guidecard', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', 'new guidecard', 'Manus-Light', NULL, NULL, NULL, '1', '2022-08-25 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-08-29 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-09-22 06:46:35', 28, '2022-09-22 06:50:50', 28, '17,16', NULL, 'Checked'),
(31, 'PL_92_Task1_example', 'PL', '92', 'Task1', 'Tier 3', 'Genevieve Corish', 'PL', '2021-10-14 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'example', 'example', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'example', 'Manus-Light', NULL, NULL, NULL, '1', '2022-10-04 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-10-06 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-09-23 16:36:28', 28, '2022-09-23 17:04:49', 28, '29', NULL, 'Checked'),
(32, 'PL_92_Task2_example 2', 'PL', '92', 'Task2', 'Tier 3', 'Genevieve Corish', 'PL', '2021-10-14 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'example 2', 'example 2', '1', '0', '1', '0', '1', '0', '0', '0', '0', '0', '0', 'example 2', 'Manus-Heavy', NULL, NULL, NULL, '1', '2022-10-26 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-10-28 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-09-23 16:41:01', 28, '2022-09-23 17:04:49', 28, '31,30', NULL, 'Checked'),
(33, 'DEF_91_Task3_third', 'DEF', '91', 'Task3', 'Tier 2', 'Genevieve Corish', 'DEF', '2021-05-13 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'third', 'third', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'third', 'Manus-Heavy', NULL, NULL, NULL, '1', '2022-11-02 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-11-04 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-09-30 22:34:08', 28, '2022-10-03 00:13:17', 28, '32', NULL, 'Checked'),
(34, 'CIV_51_Task1_LPA, Latup', 'CIV', '51', 'Task1', 'Tier 3', 'Andrew Badaoui', 'CIV', '2021-11-27 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'LPA, Latup', 'D:\\Backup2022\\tools\\Jobtrack\\AUNZ', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '[External Email]-Avoid clicking links or opening attachments unless you trust the sender.\n\n\nCheckpoint #443714167 Release 024 Master for Pub08495 was created as Product Ready by BUFAMX on 2022-10-21  14:32:38\n\nRelease Master Checkpoint.\n', 'Manus-Light', '2022-10-24 02:38:23', '32', 'katherine.sierra@spi-global.com', '1', '2022-11-02 00:00:00', '2022-10-24 02:41:00', '2022-10-24 02:41:00', 'Completed', NULL, '2022-10-24 02:42:00', '2022-10-24 02:42:00', 'Completed', NULL, '1', '2022-11-04 00:00:00', '2022-10-24 02:45:00', '2022-10-24 02:46:00', 'Completed', 'Ahead', NULL, '2022-10-24 02:32:10', 27, '2022-10-24 14:32:04', 27, '36,33', NULL, 'Checked'),
(35, 'CIV_51_Task2_GENPRINC, Latup\n', 'CIV', '51', 'Task2', 'Tier 3', 'Andrew Badaoui', 'CIV', '2021-11-27 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'GENPRINC, Latup\n', 'D:\\Backup2022\\tools\\Jobtrack\\AUNZ', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '[External Email]-Avoid clicking links or opening attachments unless you trust the sender.\n\n\nCheckpoint #443714167 Release 024 Master for Pub08495 was created as Product Ready by BUFAMX on 2022-10-21  14:32:38\n\nRelease Master Checkpoint.\n', 'Manus-Light', '2022-10-24 02:38:59', '35', 'katherine.sierra@spi-global.com', '1', '2022-11-02 00:00:00', '2022-10-24 14:12:00', '2022-10-24 14:12:00', 'Completed', NULL, '2022-10-24 14:12:00', '2022-10-24 14:12:00', 'Completed', NULL, '1', '2022-11-04 00:00:00', '2022-10-24 14:17:00', '2022-10-24 14:17:00', 'Completed', 'Ahead', NULL, '2022-10-24 02:33:07', 27, '2022-10-24 14:32:04', 27, '37,35', NULL, 'Checked'),
(36, 'CIV_51_Task3_GENPRINC, Latup\n', 'CIV', '51', 'Task3', 'Tier 3', 'Andrew Badaoui', 'CIV', '2021-11-27 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'GENPRINC, Latup\n', 'D:\\Backup2022\\tools\\Jobtrack\\AUNZ', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '[External Email]-Avoid clicking links or opening attachments unless you trust the sender.\n\n\nCheckpoint #443714167 Release 024 Master for Pub08495 was created as Product Ready by BUFAMX on 2022-10-21  14:32:38\n\nRelease Master Checkpoint.\n', 'Manus-Light', '2022-10-24 02:39:40', '36', 'katherine.sierra@spi-global.com', '1', '2022-11-02 00:00:00', '2022-10-24 14:20:00', '2022-10-24 14:21:00', 'Completed', NULL, '2022-10-24 14:21:00', '2022-10-24 14:21:00', 'Completed', NULL, '1', '2022-11-04 00:00:00', '2022-10-24 14:29:00', '2022-10-24 14:29:00', 'Completed', 'Ahead', NULL, '2022-10-24 02:36:33', 27, '2022-10-24 14:32:04', 27, '38', NULL, 'Checked'),
(37, 'PEV_241_Task1_PL, PAC, VPP, PC, WPA, LATUP\n', 'PEV', '241', 'Task1', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, 'PDF QC', 'On-Going', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'CONFIDENTIALITY NOTICE: This email, including its attachments, is intended for the use of the person/s it is addressed to. It may contain personal data, or information that is protected or privileged, which are protected from unauthorized use or disclosure by law. \n \nIf you are not the intended recipient, any dissemination, retention or use of any information contained in this email is prohibited. If you have received this email in error, please promptly notify the sender by reply email and delete the original email and any backup copies without reading them. \n \nIf you have questions or clarifications regarding any matter relating to data protection, you may write to the Straive Data Protection Office at dpo@straive.com. You may also file a complaint or report a security incident involving personal data by writing to: dpo@straive.com \n', 'Manus-Medium', '2022-10-24 20:51:45', '32', 'katherine.sierra@spi-global.com', '1', '2022-11-10 00:00:00', '2022-10-26 16:53:00', '2022-10-26 16:53:00', 'Completed', NULL, '2022-10-26 16:53:00', '2022-10-26 16:54:00', NULL, NULL, '1', '2022-11-14 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-10-24 20:30:29', 26, '2022-11-04 14:29:48', 26, '46', NULL, 'Checked'),
(38, 'PEV_241_Task2_PL, PAC, VPP, PC, WPA, LATUP', 'PEV', '241', 'Task2', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 2\n', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Hello Everyone,\n\nThank you for attending our Management Review for Editorial Production last Thursday. Below are the items discussed.\n\nAttached is your copy of the updated deck with the list of attendees as well as the minutes of the meeting below. \n', 'Manus-Light', '2022-10-24 20:52:02', '35', 'katherine.sierra@spi-global.com', '1', '2022-11-02 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-11-04 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-10-24 20:31:51', 26, '2022-10-24 20:52:02', 31, '45', NULL, NULL),
(39, 'PEV_241_Task3_PL, PAC, VPP, PC, WPA, LATUP\n', 'PEV', '241', 'Task3', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 2\n', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', 'Hi All,            \n   \nThis is a reminder to register and use the Self-Service Password Portal by Straive IT.            \n           \nThe Self-Service Password Portal can be used to reset your password or unlock your account by yourself without having to reach out to Straive Service Desk. You can use this portal from the office and while away from the office using your home computer or phone.            \n           \nIt’s easy! Three simple steps!            \n1. Navigate to the portal -  https://spiadselfservice.spi-global.com/authorization.do            \n2. Log in with your Straive account            \n3. Enroll yourself by registering your responses to your selected secret questions (Your registered responses are like passwords, nobody has access to it)            \n', 'Manus-Heavy', '2022-10-24 20:52:20', '36', 'katherine.sierra@spi-global.com', '1', '2022-11-24 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-11-28 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-10-24 20:37:00', 26, '2022-10-24 20:52:20', 31, '44', NULL, NULL),
(40, 'PEV_241_Task4_PL, PAC, VPP, PC, WPA, LATUP\n', 'PEV', '241', 'Task4', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 2\n', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', 'Hi All,            \n   \nThis is a reminder to register and use the Self-Service Password Portal by Straive IT.            \n           \nThe Self-Service Password Portal can be used to reset your password or unlock your account by yourself without having to reach out to Straive Service Desk. You can use this portal from the office and while away from the office using your home computer or phone.            \n           \nIt’s easy! Three simple steps!            \n1. Navigate to the portal -  https://spiadselfservice.spi-global.com/authorization.do            \n2. Log in with your Straive account            \n3. Enroll yourself by registering your responses to your selected secret questions (Your registered responses are like passwords, nobody has access to it)            \n', 'Manus-Light', '2022-10-24 20:52:34', '32', 'katherine.sierra@spi-global.com', '1', '2022-11-02 00:00:00', '2022-11-04 14:16:00', '2022-11-04 14:16:00', 'Completed', NULL, '2022-11-04 14:17:00', '2022-11-04 14:17:00', 'Completed', NULL, '1', '2022-11-04 00:00:00', '2022-11-04 14:18:00', '2022-11-04 14:19:00', 'Completed', 'Delay', NULL, '2022-10-24 20:37:39', 26, '2022-11-04 14:29:48', 26, '43', NULL, 'Checked'),
(41, 'PEV_241_Task5_PL, PAC, VPP, PC, WPA, LATUP\n', 'PEV', '241', 'Task5', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 2\n', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', 'Hi All,            \n   \nThis is a reminder to register and use the Self-Service Password Portal by Straive IT.            \n           \nThe Self-Service Password Portal can be used to reset your password or unlock your account by yourself without having to reach out to Straive Service Desk. You can use this portal from the office and while away from the office using your home computer or phone.            \n           \nIt’s easy! Three simple steps!            \n1. Navigate to the portal -  https://spiadselfservice.spi-global.com/authorization.do            \n2. Log in with your Straive account            \n3. Enroll yourself by registering your responses to your selected secret questions (Your registered responses are like passwords, nobody has access to it)            \n', 'Manus-Medium', '2022-10-24 20:53:30', '32', 'katherine.sierra@spi-global.com', '1', '2022-11-10 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-11-14 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-10-24 20:38:08', 26, '2022-10-24 20:53:30', 31, '42', NULL, NULL),
(42, 'PEV_241_Task6_PL, PC, PAC, WPA, EOL, LATUP\n', 'PEV', '241', 'Task6', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'PL, PC, PAC, WPA, EOL, LATUP\n', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 2\n', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Hi All,            \n   \nThis is a reminder to register and use the Self-Service Password Portal by Straive IT.            \n           \nThe Self-Service Password Portal can be used to reset your password or unlock your account by yourself without having to reach out to Straive Service Desk. You can use this portal from the office and while away from the office using your home computer or phone.            \n           \nIt’s easy! Three simple steps!            \n1. Navigate to the portal -  https://spiadselfservice.spi-global.com/authorization.do            \n2. Log in with your Straive account            \n3. Enroll yourself by registering your responses to your selected secret questions (Your registered responses are like passwords, nobody has access to it)            \n', 'Manus-Light', '2022-10-24 20:53:52', '35', 'katherine.sierra@spi-global.com', '1', '2022-11-02 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-11-04 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-10-24 20:38:31', 26, '2022-10-24 20:53:52', 31, '41', NULL, NULL),
(43, 'PEV_241_Task7_PL, PC, PAC, WPA, EOL, LATUP\n', 'PEV', '241', 'Task7', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'PL, PC, PAC, WPA, EOL, LATUP\n', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 2\n', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Hi All,            \n   \nThis is a reminder to register and use the Self-Service Password Portal by Straive IT.            \n           \nThe Self-Service Password Portal can be used to reset your password or unlock your account by yourself without having to reach out to Straive Service Desk. You can use this portal from the office and while away from the office using your home computer or phone.            \n           \nIt’s easy! Three simple steps!            \n1. Navigate to the portal -  https://spiadselfservice.spi-global.com/authorization.do            \n2. Log in with your Straive account            \n3. Enroll yourself by registering your responses to your selected secret questions (Your registered responses are like passwords, nobody has access to it)            \n', 'Manus-Heavy', '2022-10-24 20:54:07', '36', 'katherine.sierra@spi-global.com', '1', '2022-11-24 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-11-28 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-10-24 20:40:28', 26, '2022-10-24 20:54:07', 31, '40', NULL, NULL),
(44, 'PEV_241_Task8_PL, PC, PAC, WPA, EOL, LATUP\n', 'PEV', '241', 'Task8', 'Tier 1', 'Nina Packman', 'PEV', '2021-11-26 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'PL, PC, PAC, WPA, EOL, LATUP_with edit\n', 'Y:\\EdProc\\pev\\Service 241\\Manuscript\\Edited\\Task 3\n', '0', '1', '0', '1', '0', '0', '0', '0', '0', '0', '0', 'Hi All,            \n   \nThis is a reminder to register and use the Self-Service Password Portal by Straive IT.            \n           \nThe Self-Service Password Portal can be used to reset your password or unlock your account by yourself without having to reach out to Straive Service Desk. You can use this portal from the office and while away from the office using your home computer or phone.       \nAdded instruction     \n           \nIt’s easy! Three simple steps!            \n1. Navigate to the portal -  https://spiadselfservice.spi-global.com/authorization.do            \n2. Log in with your Straive account            \n3. Enroll yourself by registering your responses to your selected secret questions (Your registered responses are like passwords, nobody has access to it)            \n', 'Manus-Medium', '2022-10-24 20:54:19', '32', 'katherine.sierra@spi-global.com', '1', '2022-11-10 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-11-14 00:00:00', NULL, NULL, NULL, NULL, 'add the revised online due date', '2022-10-24 20:41:14', 26, '2022-10-24 21:57:43', 26, '39', '2022-10-25 00:00:00', NULL),
(45, 'FRAN_68_Task1_gc1', 'FRAN', '68', 'Task1', 'Tier 3', 'Marcus Frajman', 'FRN', '2021-10-25 00:00:00', NULL, 'XML Editing', 'On-Going', 'COMMENTARY', 'gc1', 'D:\\Backup2022\\tools\\PDF Proofing\\Format review\\US\\LN-US_Format_Review_20-11-22', '0', '0', '0', '0', '0', '0', '1', '0', '1', '0', '0', 'instruction sample_1', 'Manus-Heavy', '2022-11-22 00:16:25', '32', 'katherine.sierra@spi-global.com', '1', '2022-12-22 00:00:00', '2022-11-22 00:17:00', NULL, 'On-Going', NULL, NULL, NULL, NULL, NULL, '1', '2022-12-26 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-11-22 00:13:54', 28, '2022-11-22 00:17:31', 32, '54,53', NULL, NULL),
(46, 'FRAN_68_Task2_gc 2', 'FRAN', '68', 'Task2', 'Tier 3', 'Marcus Frajman', 'FRN', '2021-10-25 00:00:00', NULL, 'XML Editing', 'On-Going', 'COMMENTARY', 'gc 2', 'D:\\Backup2022\\tools\\PDF Proofing\\Format review\\US\\LN-US_Format_Review_20-11-22', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'special instruction2', 'Manus-Heavy', '2022-11-22 00:16:52', '35', 'katherine.sierra@spi-global.com', '1', '2022-12-22 00:00:00', '2022-11-22 00:24:00', '2022-11-22 00:24:00', 'On-Going', NULL, NULL, NULL, NULL, NULL, '1', '2022-12-26 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-11-22 00:14:24', 28, '2022-11-22 00:24:36', 35, '52,51', NULL, NULL),
(47, 'CLSA_192_Task1_DFDF', 'CLSA', '192', 'Task1', 'Tier 1', 'David Worswick', 'CLS', '2021-12-06 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'DFDF', 'DFDF', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'DXVFD', 'Index', NULL, NULL, NULL, '1', '2022-12-01 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-12-05 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-11-28 13:21:09', 23, '2022-11-28 13:21:09', 23, '55,47', NULL, NULL),
(48, 'BC_60_Task1_Handbook', 'BC', '60', 'Task1', 'Tier 3', 'Rose Thomsen', 'BC', '2021-10-01 00:00:00', NULL, 'PDF QC', 'On-Going', 'COMMENTARY', 'Handbook', 'Z:\\EdProc\\BC\\BC 60\\Manuscript\\Edited\\Task 3', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', '1. Please make amendments to the commentary in the guide cards mentioned above as per tracked changes in the documents saved at Y:\\EdProc\\BC\\BC 60\\Manuscript\\Edited\\Task 3.\n\n2. For the purposes of content enrichment of all updated material in Lexis Advance, please update currency statements to \"Last updated/ Last reviewed:July 2021\".\n\n3. Please update currency statements of Annotated Legislation \"Commentary last updated/ last reviewed: July 2021 \".\n\n4. Kindly update any and all Table of Contents that may be affected by the updates (eg, Guidecard TOC, Main TOC, Quick indices).\n\n5. Make sure to create a link for references (statutes, case citations and paragraph references).\n\n6. Please ensure that the currency statement in LATUP and in the affected guidecard is updated to July 2021.\n\nLATUP:\nJuly 2021\nCommentary\nAlan Cullen significantly updated or inserted the following commentaries to:\nTendering and Construction Law Handbook at: [200,014], [201,585], [202,452].', 'Manus-Medium', '2022-12-09 20:36:10', '5', 'Coding2@example.com', '1', '2022-12-28 00:00:00', '2022-12-09 19:34:00', '2022-12-09 19:35:00', 'Completed', NULL, '2022-12-09 20:19:00', '2022-12-09 20:20:00', NULL, NULL, '1', '2022-12-30 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-12-09 19:13:29', 30, '2022-12-09 20:36:10', 7, '60,58', NULL, NULL),
(49, 'BC_60_Task2_INDEX', 'BC', '60', 'Task2', 'Tier 3', 'Rose Thomsen', 'BC', '2021-10-01 00:00:00', NULL, 'PDF QC', 'On-Going', 'COMMENTARY', 'INDEX', 'Z:\\EdProc\\BC\\BC 60\\Index', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', 'Please process BC Index current to service 59 .txt file that can be located in the path provided above.\n\nCurrent to: Service 59\nStart page: 2101\nNext page: 3001\n\nPath: Y:\\EdProc\\BC\\BC 60\\Index', 'Index', '2022-12-09 20:36:51', '4', 'Coding1@example.com', '1', '2022-12-14 00:00:00', '2022-12-09 20:30:00', '2022-12-09 20:30:00', 'Completed', NULL, '2022-12-09 20:30:00', '2022-12-09 20:31:00', NULL, NULL, '1', '2022-12-16 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-12-09 19:18:10', 30, '2022-12-09 20:36:51', 7, '59', NULL, NULL),
(50, 'BC_60_Task3_Handbook', 'BC', '60', 'Task3', 'Tier 3', 'Rose Thomsen', 'BC', '2021-10-01 00:00:00', NULL, 'XML Editing', 'On-Going', 'COMMENTARY', 'Handbook', 'Z:\\EdProc\\BC\\BC 60\\Manuscript\\Edited\\Task 1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', '1. Please make amendments to the commentary in the guide cards mentioned above as per tracked changes in the documents saved at \"Y:\\EdProc\\BC\\BC 60\\Manuscript\\Edited\\Task 1\".\n\n2. For the purposes of content enrichment of all updated material in Lexis Advance, please update currency statements to \"Last updated/ Last reviewed: June 2021\".\n\n3. Please update currency statements of Annotated Legislation \"Commentary last updated/ last reviewed: June 2021\".\n\n4. Kindly update any and all Table of Contents that may be affected by the updates (eg, Guidecard TOC, Main TOC, Quick indices).\n\n5. Make sure to create a link for references (statutes, case citations and paragraph references).\n\n6. Please ensure that the currency statement in LATUP and in the affected guidecard is updated to June 2021.\n\nLATUP:\n\nJune 2021\nCommentary\nAlan Cullen significantly updated or inserted the following commentaries to:\nTendering and Construction Law Handbook at: [202,726].', 'Manus-Light', '2022-12-09 20:38:52', '5', 'Coding2@example.com', '1', '2022-12-20 00:00:00', '2022-12-09 19:36:00', '2022-12-09 19:37:00', 'On-Going', NULL, NULL, NULL, NULL, NULL, '1', '2022-12-22 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-12-09 19:25:01', 30, '2022-12-09 20:38:52', 7, '56', NULL, NULL),
(51, 'MTN_183_Task1_TRI', 'MTN', '183', 'Task1', 'Tier 2', 'Ragnii Ommanney', 'MTN', '2021-11-24 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'TRI', 'u87i8i', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'uik', 'Ed Mns-Med', NULL, NULL, NULL, '1', '2022-12-19 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-12-21 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-12-12 15:37:49', 28, '2022-12-12 15:37:49', 28, '63', NULL, NULL),
(52, 'CPACT_132_Task1_CHILD', 'CPACT', '132', 'Task1', 'Tier 2', 'Ragnii Ommanney', 'CPA', '2021-11-05 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'CHILD', 'ND', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'RFGTRG', 'Ed Mns-Hvy', NULL, NULL, NULL, '1', '2022-12-27 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-12-29 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-12-13 13:57:16', 28, '2022-12-13 13:57:16', 28, '67', NULL, NULL),
(53, 'IPC_159_Task1_GRFFG', 'IPC', '159', 'Task1', 'Tier 1', 'Genevieve Corish', 'IPC', '2021-03-30 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'GRFFG', 'FGFG', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'FGFG', 'Ed Mns-Hvy', NULL, NULL, NULL, '1', '2022-09-13 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2022-09-15 00:00:00', NULL, NULL, NULL, NULL, NULL, '2022-12-13 14:03:52', 28, '2022-12-13 14:03:52', 28, '22', NULL, NULL),
(54, 'ACTD_85_Task1_FOLLOW', 'ACTD', '85', 'Task1', 'Tier 2', 'Ragnii Ommanney', 'ATD', '2021-10-29 00:00:00', NULL, NULL, 'New', 'COMMENTARY', 'FOLLOW', 'Z:Edproc', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', 'Links should be embedded.', 'Index', NULL, NULL, NULL, '1', '2023-01-10 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', '2023-01-12 00:00:00', NULL, NULL, NULL, NULL, NULL, '2023-01-05 07:21:19', 28, '2023-01-05 07:21:19', 28, '68', NULL, NULL),
(55, 'CIV_49_Task1_Sample Guide', 'CIV', '49', 'Task1', 'Tier 3', 'Andrew Badaoui', 'CIV', '2021-05-28 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'Sample Guide', 'location test', '0', '0', '0', '1', '0', '0', '1', '0', '0', '0', '0', 'Test ', 'Manus-Medium', '2023-01-10 16:10:04', '32', 'katherine.sierra@spi-global.com', '1', '2023-01-27 00:00:00', '2023-01-10 16:10:00', '2023-01-10 16:11:00', 'Completed', NULL, '2023-01-10 16:11:00', '2023-01-10 16:11:00', 'Completed', NULL, '1', '2023-01-31 00:00:00', '2023-01-10 16:14:00', '2023-01-10 16:14:00', 'Completed', 'Ahead', NULL, '2023-01-10 16:06:56', 27, '2023-03-01 15:39:02', 27, '72,71', NULL, 'Checked'),
(56, 'FRAN_68_Task3_Guide card_1', 'FRAN', '68', 'Task3', 'Tier 3', 'Marcus Frajman', 'FRN', '2021-10-25 00:00:00', NULL, 'PDF QC', 'On-Going', 'COMMENTARY', 'Guide card_1', 'D:\\Backup2022\\tools\\Jobtrack\\AUNZ', '0', '1', '1', '1', '1', '0', '0', '0', '0', '0', '0', 'testtesttesttesttesttesttesttesttesttesttest', 'Manus-Medium', '2023-02-17 14:59:10', '32', 'katherine.sierra@spi-global.com', '1', '2023-03-08 00:00:00', '2023-02-17 14:59:00', '2023-02-17 15:00:00', 'Completed', NULL, '2023-02-17 15:01:00', '2023-02-17 15:01:00', 'On-Going', NULL, '1', '2023-03-10 00:00:00', NULL, NULL, NULL, NULL, NULL, '2023-02-17 14:57:19', 28, '2023-02-17 15:02:13', 32, '74,73', NULL, NULL),
(57, 'ABCE_68_Task1_guide 1', 'ABCE', '68', 'Task1', 'Tier 3', 'Andrew Badaoui', 'ABC', '2021-02-26 00:00:00', NULL, 'Online', 'Completed', 'COMMENTARY', 'guide 1', 'guide 1', '1', '0', '1', '0', '1', '0', '1', '0', '0', '0', '0', 'special !@#$%^&*()*(&^%$#@!', 'Ed Mns-Hvy', '2023-03-01 20:53:29', '32', 'katherine.sierra@spi-global.com', '1', '2023-03-15 00:00:00', '2023-03-01 20:55:00', '2023-03-01 20:55:00', 'Completed', NULL, '2023-03-01 20:56:00', '2023-03-01 20:56:00', 'Completed', NULL, '1', '2023-03-17 00:00:00', '2023-03-01 20:58:00', '2023-03-01 20:58:00', 'Completed', 'Ahead', NULL, '2023-03-01 20:51:09', 24, '2023-03-01 21:02:16', 24, '76,75', NULL, 'Checked');

-- --------------------------------------------------------

--
-- Table structure for table `coversheetquery`
--

CREATE TABLE `coversheetquery` (
  `CoversheetNo` varchar(200) NOT NULL,
  `QueryID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `coversheetstp`
--

CREATE TABLE `coversheetstp` (
  `STPNo` varchar(200) NOT NULL,
  `CoversheetNo` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `coversheet_mt`
--

CREATE TABLE `coversheet_mt` (
  `CoversheetID` int(11) NOT NULL,
  `CoversheetTier` varchar(50) DEFAULT NULL,
  `CoversheetName` varchar(1000) DEFAULT NULL,
  `BPSProductID` varchar(50) NOT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `ManuscriptFile` varchar(1000) DEFAULT NULL,
  `LatupAttribution` varchar(500) DEFAULT NULL,
  `DateReceivedFromAuthor` datetime DEFAULT NULL,
  `DateEnteredIntoTracker` datetime DEFAULT NULL,
  `UpdateType` varchar(100) DEFAULT NULL,
  `GuideCard` varchar(500) DEFAULT NULL,
  `TaskNumber` varchar(100) DEFAULT NULL,
  `RevisedOnlineDueDate` datetime DEFAULT NULL,
  `DepositedBy` varchar(500) DEFAULT NULL,
  `LEInstructions` varchar(1000) DEFAULT NULL,
  `PickUpBy` varchar(500) DEFAULT NULL,
  `PickUpDate` datetime DEFAULT NULL,
  `QABy` varchar(500) DEFAULT NULL,
  `QADate` datetime DEFAULT NULL,
  `QACompletionDate` datetime DEFAULT NULL,
  `QueryLog` varchar(1000) DEFAULT NULL,
  `QueryForApprovalStartDate` datetime DEFAULT NULL,
  `QueryForApprovalEndDate` datetime DEFAULT NULL,
  `QueryForApprovalAge` int(50) DEFAULT NULL,
  `Process` varchar(500) DEFAULT NULL,
  `PETargetCompletion` datetime DEFAULT NULL,
  `LatupTargetCompletion` datetime DEFAULT NULL,
  `EndingDueDate` datetime DEFAULT NULL,
  `PEActualCompletion` datetime DEFAULT NULL,
  `CodingDueDate` datetime DEFAULT NULL,
  `CodingActualCompletion` datetime DEFAULT NULL,
  `ActualPages` int(100) DEFAULT NULL,
  `OnlineDueDate` datetime DEFAULT NULL,
  `OnlineActualCompletion` datetime DEFAULT NULL,
  `LNRedCheckingActualCompletion` datetime DEFAULT NULL,
  `AffectedPages` int(100) DEFAULT NULL,
  `NoOfMSSFile` int(100) DEFAULT NULL,
  `ActualTAT` int(10) DEFAULT NULL,
  `BenchmarkMET` varchar(100) NOT NULL,
  `FilePath` varchar(1000) NOT NULL,
  `PEStatus` varchar(1000) NOT NULL,
  `TaskType` varchar(100) DEFAULT NULL,
  `TaskReadyDate` datetime DEFAULT NULL,
  `PDFQA_PE` varchar(500) DEFAULT NULL,
  `QMSID` int(100) DEFAULT NULL,
  `CodingStatus` varchar(1000) DEFAULT NULL,
  `CoversheetRemarks` varchar(1000) DEFAULT NULL,
  `DateCreated` datetime DEFAULT NULL,
  `CreatedEmployeeID` int(11) DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `UpdateEmployeeID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `coversheet_mt`
--

INSERT INTO `coversheet_mt` (`CoversheetID`, `CoversheetTier`, `CoversheetName`, `BPSProductID`, `ServiceNumber`, `ManuscriptFile`, `LatupAttribution`, `DateReceivedFromAuthor`, `DateEnteredIntoTracker`, `UpdateType`, `GuideCard`, `TaskNumber`, `RevisedOnlineDueDate`, `DepositedBy`, `LEInstructions`, `PickUpBy`, `PickUpDate`, `QABy`, `QADate`, `QACompletionDate`, `QueryLog`, `QueryForApprovalStartDate`, `QueryForApprovalEndDate`, `QueryForApprovalAge`, `Process`, `PETargetCompletion`, `LatupTargetCompletion`, `EndingDueDate`, `PEActualCompletion`, `CodingDueDate`, `CodingActualCompletion`, `ActualPages`, `OnlineDueDate`, `OnlineActualCompletion`, `LNRedCheckingActualCompletion`, `AffectedPages`, `NoOfMSSFile`, `ActualTAT`, `BenchmarkMET`, `FilePath`, `PEStatus`, `TaskType`, `TaskReadyDate`, `PDFQA_PE`, `QMSID`, `CodingStatus`, `CoversheetRemarks`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 'Tier 2', 'ABCA 37_Task 1_CHAP7', 'ABCA', '37', 'Chapter 7 corrections', '-', '2021-12-03 00:00:00', '2021-12-03 00:00:00', 'Ed Mns-Lgt', 'CHAP7', 'Task 1', '2021-12-23 00:00:00', 'Nina Packman', '-', 'Patricia Artajo', '2021-12-03 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-08 00:00:00', '2021-12-08 00:00:00', 286, '2021-12-10 00:00:00', '2021-12-10 00:00:00', '1900-01-01 00:00:00', 21, 2, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 1', '07_For XML Edit', 'Commentary', '2021-12-06 00:00:00', '-', 862329, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(2, 'Tier 2', 'ABCA 37_Task 2_CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'ABCA', '37', 'ABCA Ch 9 Jan 2022- edited', '-', '2022-01-11 00:00:00', '2022-01-13 00:00:00', 'Ed Mns-Lgt', 'CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'Task 2', '1900-01-01 00:00:00', 'Jennifer Murray', '-', 'Patricia Artajo', '2022-01-14 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-18 00:00:00', '2022-01-18 00:00:00', 70, '2022-01-20 00:00:00', '2022-01-20 00:00:00', '2022-02-24 00:00:00', 70, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 886067, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(3, 'Tier 2', 'ABCA 37_Task 2_CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'ABCA', '37', 'ABCA ASIC Ch Jan 2022- edited', '-', '2022-01-11 00:00:00', '2022-01-13 00:00:00', 'Ed Mns-Lgt', 'CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'Task 2', '1900-01-01 00:00:00', 'Jennifer Murray', '-', 'Patricia Artajo', '2022-01-14 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-18 00:00:00', '2022-01-18 00:00:00', 109, '2022-01-20 00:00:00', '2022-01-20 00:00:00', '2022-02-24 00:00:00', 100, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 886067, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(4, 'Tier 2', 'ABCA 37_Task 2_CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'ABCA', '37', 'ABCA Ch 1 Definitions Jan 2022- edited', '-', '2022-01-10 00:00:00', '2022-01-13 00:00:00', 'Ed Mns-Lgt', 'CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'Task 2', '1900-01-01 00:00:00', 'Jennifer Murray', '-', 'Patricia Artajo', '2022-01-14 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-18 00:00:00', '2022-01-18 00:00:00', 46, '2022-01-20 00:00:00', '2022-01-20 00:00:00', '2022-02-24 00:00:00', 50, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 886067, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(5, 'Tier 2', 'ABCA 37_Task 2_CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'ABCA', '37', 'ABCA ch 5 External Administration Jan 2022- edited', '-', '2022-01-10 00:00:00', '2022-01-13 00:00:00', 'Ed Mns-Lgt', 'CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'Task 2', '1900-01-01 00:00:00', 'Jennifer Murray', '-', 'Patricia Artajo', '2022-01-14 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-18 00:00:00', '2022-01-18 00:00:00', 294, '2022-01-20 00:00:00', '2022-01-20 00:00:00', '2022-02-24 00:00:00', 200, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 886067, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(6, 'Tier 2', 'ABCA 37_Task 2_CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'ABCA', '37', 'ABCA Ch 7 Financial Services jan 2022- edited', '-', '2022-01-10 00:00:00', '2022-01-13 00:00:00', 'Ed Mns-Lgt', 'CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'Task 2', '1900-01-01 00:00:00', 'Jennifer Murray', '-', 'Patricia Artajo', '2022-01-14 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-18 00:00:00', '2022-01-18 00:00:00', 230, '2022-01-20 00:00:00', '2022-01-20 00:00:00', '2022-02-24 00:00:00', 100, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 886067, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(7, 'Tier 2', 'ABCA 37_Task 2_CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'ABCA', '37', 'ABCA Ch 10 Transitional Jan 2022- edited', '-', '2022-01-10 00:00:00', '2022-01-13 00:00:00', 'Ed Mns-Lgt', 'CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'Task 2', '1900-01-01 00:00:00', 'Jennifer Murray', '-', 'Patricia Artajo', '2022-01-14 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-18 00:00:00', '2022-01-18 00:00:00', 77, '2022-01-20 00:00:00', '2022-01-20 00:00:00', '2022-02-24 00:00:00', 50, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 886067, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(8, 'Tier 2', 'ABCA 37_Task 2_CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'ABCA', '37', 'ABCA IPSC Jan 2022- edited', '-', '2022-01-10 00:00:00', '2022-01-13 00:00:00', 'Ed Mns-Lgt', 'CHAP9, ASICA, CHAP1, CHAP5, CHAP7, CHAP10, SCHED', 'Task 2', '1900-01-01 00:00:00', 'Jennifer Murray', '-', 'Patricia Artajo', '2022-01-14 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-18 00:00:00', '2022-01-18 00:00:00', 5, '2022-01-20 00:00:00', '2022-01-20 00:00:00', '2022-02-24 00:00:00', 5, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 886067, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(9, 'Tier 2', 'ABCA 37_Task 3_LATUP', 'ABCA', '37', 'LATUP', 'Justice AJ Black', '1900-01-01 00:00:00', '2022-01-19 00:00:00', 'Manus-Light', 'LATUP', 'Task 3', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-01-19 00:00:00', 'Laiza Remotin', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-01-19 00:00:00', '2022-01-19 00:00:00', '2022-01-25 00:00:00', '2022-01-19 00:00:00', '2022-01-28 00:00:00', '2022-01-22 00:00:00', 1, '2022-02-01 00:00:00', '2022-01-26 00:00:00', '2022-02-21 00:00:00', 1, 1, 5, 'Y', 'Y:EdProcabcaServicesService 37ManuscriptEditedTask 3', '07_For XML Edit', 'Commentary', '2022-01-19 00:00:00', '-', 886064, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(10, 'Tier 3', 'ABCE 71_Task 1_Index', 'ABCE', '71', 'Index', '-', '1900-01-01 00:00:00', '2021-12-27 00:00:00', 'Index', 'Index', 'Task 1', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2021-12-27 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-27 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-30 00:00:00', '2021-12-29 00:00:00', 40, '2022-01-03 00:00:00', '2021-12-30 00:00:00', '1900-01-01 00:00:00', 38, 1, 3, 'Y', 'Y:EdProcABCEServicesService 71Index', '07_For XML Edit', 'Index', '2021-12-27 00:00:00', '-', 873700, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(11, 'Tier 3', 'ABCE 71_Task 2_DHW, ID, RW, RD, Latup', 'ABCE', '71', 'Various', 'Troy Anderson SC', '2022-02-15 00:00:00', '2022-02-15 00:00:00', 'Manus-Medium', 'DHW, ID, RW, RD, Latup', 'Task 2', '1900-01-01 00:00:00', 'Andrew Badaoui', '-', 'Mark Grande', '2022-02-15 00:00:00', 'Patricia Artajo', '2022-02-16 00:00:00', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-02-25 00:00:00', '2022-02-22 00:00:00', '2022-02-25 00:00:00', '2022-02-22 00:00:00', '2022-03-04 00:00:00', '2022-02-28 00:00:00', 49, '2022-03-08 00:00:00', '2022-03-02 00:00:00', '1900-01-01 00:00:00', 68, 5, 11, 'Y', 'Z:EdProcABCEServicesService 71ManuscriptRawTask 1', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 907429, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(12, 'Tier 2', 'ACLL 207_Task 1_ASIC', 'ACLL', '207', 'Practice material', '-', '1900-01-01 00:00:00', '2021-11-29 00:00:00', 'Prac Mat', 'ASIC', 'Task 1', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2021-11-29 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-11-29 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-23 00:00:00', '2021-12-06 00:00:00', 0, '2021-12-27 00:00:00', '2021-12-07 00:00:00', '1900-01-01 00:00:00', 76, 1, 6, 'Y', 'Y:EdProcacllService 207Practice materialTask 1', '07_For XML Edit', 'Commentary', '2021-11-29 00:00:00', '-', 860329, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(13, 'Tier 2', 'ACLL 207_Task 2_CA, ASICA, CR', 'ACLL', '207', 'Overlapping pages', '-', '1900-01-01 00:00:00', '2022-01-20 00:00:00', 'Other', 'CA, ASICA, CR', 'Task 2', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-01-20 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-20 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-27 00:00:00', '2022-01-20 00:00:00', 6, '2022-01-31 00:00:00', '2022-01-31 00:00:00', '1900-01-01 00:00:00', 6, 1, 7, 'Y', 'Y:EdProcacllService 207ManuscriptEditedTask 2', '07_For XML Edit', 'General Corrections', '2022-01-20 00:00:00', '-', 890161, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(14, 'Tier 2', 'ACLL 208_Task 1_ASIC', 'ACLL', '208', 'Practice material', '-', '1900-01-01 00:00:00', '2022-02-03 00:00:00', 'Prac Mat', 'ASIC', 'Task 1', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-02-03 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-01 00:00:00', '2022-02-07 00:00:00', 12, '2022-03-03 00:00:00', '2022-02-08 00:00:00', '2022-02-17 00:00:00', 14, 1, 3, 'Y', 'Y:EdProcacllService 208Practice materialTask 1', '07_For XML Edit', 'Commentary', '2022-02-03 00:00:00', '-', 894254, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(15, 'Tier 1', 'ACLPP 215_Task 1_Index', 'ACLPP', '215', 'Index', 'Index', '1900-01-01 00:00:00', '2021-12-24 00:00:00', 'Index', 'Index', 'Task 1', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2021-12-24 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-29 00:00:00', '2021-12-29 00:00:00', 170, '2021-12-31 00:00:00', '2021-12-30 00:00:00', '1900-01-01 00:00:00', 168, 1, 4, 'Y', 'Y:EdProcaclppService 215Index', '07_For XML Edit', 'Index', '2021-12-24 00:00:00', '-', 873699, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(16, 'Tier 1', 'ACLPP 215_Task 2_GN, LATUP', 'ACLPP', '215', 'Practice materials', '-', '1900-01-01 00:00:00', '2021-12-27 00:00:00', 'Prac Mat', 'GN, LATUP', 'Task 2', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2021-12-27 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-27 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-20 00:00:00', '2022-01-17 00:00:00', 28, '2022-01-24 00:00:00', '2022-01-19 00:00:00', '2022-02-15 00:00:00', 27, 2, 17, 'Y', 'Y:EdProcaclppService 215Practice materialTask 2', '07_For XML Edit', 'Commentary', '2021-12-27 00:00:00', '-', 882818, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(17, 'Tier 1', 'ACLPP 215_Task 3_GN, LATUP', 'ACLPP', '215', 'Practice material', '-', '1900-01-01 00:00:00', '2022-01-04 00:00:00', 'Prac Mat', 'GN, LATUP', 'Task 3', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-01-04 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-04 00:00:00', '2022-01-04 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-28 00:00:00', '2022-01-07 00:00:00', 6, '2022-02-01 00:00:00', '2022-01-12 00:00:00', '2022-02-14 00:00:00', 5, 1, 6, 'Y', 'Y:EdProcaclppService 215Practice materialTask 3', '07_For XML Edit', 'Commentary', '2022-01-04 00:00:00', '-', 879212, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(18, 'Tier 2', 'ACP 131_Task 1_ACP.OS', 'ACP', '131', 'ACP Chapter 17-edited', '-', '2022-02-18 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', 'ACP.OS', 'Task 1', '1900-01-01 00:00:00', 'Jennifer Murray', 'N/A', 'Margot Antivola', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-21 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-24 00:00:00', '1900-01-01 00:00:00', 3, 1, 3, 'Y', 'Z:EdProcACPServicesService 131ManuscriptEditedTask 1', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 902462, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(19, 'Tier 2', 'ACP 131_Task 2_ACP.ASCPA', 'ACP', '131', 'ACP Chapters 28, 29, 30 currency statement update', '-', '1900-01-01 00:00:00', '2022-02-24 00:00:00', 'Other', 'ACP.ASCPA', 'Task 2', '1900-01-01 00:00:00', 'Margot Antivola', 'Update currency statements for chapters 28. 29 and 30', 'Margot Antivola', '2022-02-24 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-03 00:00:00', '2022-02-24 00:00:00', 3, '2022-03-07 00:00:00', '2022-02-24 00:00:00', '1900-01-01 00:00:00', 1, 1, 0, 'Y', 'Z:EdProcACPServicesService 131ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2022-02-24 00:00:00', '-', 902457, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(20, 'Tier 2', 'ACP 131_Task 3_ACP.DF, ACP.AS', 'ACP', '131', 'ACP Chapters 19, 21, 22 currency statement update', '-', '2022-02-24 00:00:00', '2022-02-24 00:00:00', 'Other', 'ACP.DF, ACP.AS', 'Task 3', '1900-01-01 00:00:00', 'Margot Antivola', 'Update currency statements for chapters 19, 21 and 22', 'Margot Antivola', '2022-02-24 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-03 00:00:00', '2022-02-28 00:00:00', 98, '2022-03-07 00:00:00', '2022-03-02 00:00:00', '1900-01-01 00:00:00', 1, 1, 4, 'Y', 'Z:EdProcACPServicesService 131ManuscriptEditedTask 3', '07_For XML Edit', 'Commentary', '2022-02-24 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(21, 'Tier 2', 'ACTD 85_Task 1_TRIAL, LATUP', 'ACTD', '85', '\\corp.regn.netsydpublishingEdProcactdService 85ManuscriptsRawTask 1', 'Sydney Tilmouth QC', '2022-01-10 00:00:00', '2022-02-08 00:00:00', 'Ed Mns-Med', 'TRIAL, LATUP', 'Task 1', '1900-01-01 00:00:00', 'Ragnii Ommanney', 'Send PDF proof after it has been coded.', 'Patricia Artajo', '2022-02-08 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-15 00:00:00', '2022-02-12 00:00:00', 29, '2022-02-17 00:00:00', '2022-03-02 00:00:00', '1900-01-01 00:00:00', 30, 4, 16, 'N', 'Y:EdProcactdService 85ManuscriptsEditedTask 1', '07_For XML Edit', 'Commentary', '2022-02-09 00:00:00', '-', 898803, '27_Completed – QA Online', 'waiting for LE\'s approval', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(22, 'Tier 2', 'ACTD 85_Task 2_TRIAL, LATUP', 'ACTD', '85', '\\corp.regn.netsydpublishingEdProcactdService 85ManuscriptsRawTask 2', 'Sydney Tilmouth QC', '2022-01-18 00:00:00', '2022-02-08 00:00:00', 'Ed Mns-Med', 'TRIAL, LATUP', 'Task 2', '2022-02-21 00:00:00', 'Ragnii Ommanney', 'Send PDF proof after it has been coded.', 'Patricia Artajo', '2022-02-08 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-15 00:00:00', '2022-02-16 00:00:00', 65, '2022-02-17 00:00:00', '2022-03-02 00:00:00', '1900-01-01 00:00:00', 76, 4, 16, 'N', 'Y:EdProcactdService 85ManuscriptsEditedTask 2', '07_For XML Edit', 'Commentary', '2022-02-09 00:00:00', '-', 900981, '27_Completed – QA Online', 'waiting for LE\'s approval', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(23, 'Tier 2', 'ACTD 85_Task 3_ACC, LATUP', 'ACTD', '85', '\\corp.regn.netsydpublishingEdProcactdService 85ManuscriptsRawTask 3', 'Sydney Tilmouth QC', '2022-01-10 00:00:00', '2022-02-08 00:00:00', 'Ed Mns-Lgt', 'ACC, LATUP', 'Task 3', '1900-01-01 00:00:00', 'Ragnii Ommanney', 'Send PDF proof after it has been coded.', 'Patricia Artajo', '2022-02-08 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-11 00:00:00', '2022-02-11 00:00:00', 15, '2022-02-15 00:00:00', '2022-03-02 00:00:00', '1900-01-01 00:00:00', 11, 1, 16, 'N', 'Y:EdProcactdService 85ManuscriptsEditedTask 3', '07_For XML Edit', 'Commentary', '2022-02-09 00:00:00', '-', 898455, '27_Completed – QA Online', 'waiting for LE\'s approval', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(24, 'Tier 2', 'ACTD 85_Task 4_SUM, LATUP', 'ACTD', '85', '\\corp.regn.netsydpublishingEdProcactdService 85ManuscriptsRawTask 4', 'Sydney Tilmouth QC', '2022-01-10 00:00:00', '2022-02-08 00:00:00', 'Ed Mns-Med', 'SUM, LATUP', 'Task 4', '1900-01-01 00:00:00', 'Ragnii Ommanney', 'Send PDF proof after it has been coded.', 'Patricia Artajo', '2022-02-08 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-15 00:00:00', '2022-02-15 00:00:00', 12, '2022-02-17 00:00:00', '2022-03-02 00:00:00', '2022-03-03 00:00:00', 14, 2, 16, 'N', 'Y:EdProcactdService 85ManuscriptsEditedTask 4', '07_For XML Edit', 'Commentary', '2022-02-09 00:00:00', '-', 898807, '27_Completed – QA Online', 'waiting for LE\'s approval', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(25, 'Tier 2', 'ACTD 85_Task 5_TOS', 'ACTD', '85', 'Table of Statutes', '-', '1900-01-01 00:00:00', '2022-02-24 00:00:00', 'TOS', 'TOS', 'Task 5', '1900-01-01 00:00:00', 'Ren Masu-ay', '-', 'Ren Masu-ay', '2022-02-25 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-25 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-03 00:00:00', '2022-02-26 00:00:00', 6, '1900-01-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 20, 8, 0, '-', 'Z:EdProcactdService 85Coversheets', '07_For XML Edit', 'Commentary', '2022-02-25 00:00:00', '-', 905398, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(26, 'Tier 2', 'ACV 167_Task 1_INDEX', 'ACV', '167', 'acv166.ind', '-', '1900-01-01 00:00:00', '2021-12-03 00:00:00', 'Index', 'INDEX', 'Task 1', '2021-12-23 00:00:00', 'Puddingburn', '-', 'Margot Antivola', '2021-12-03 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-08 00:00:00', '2021-12-07 00:00:00', 58, '2021-12-10 00:00:00', '2021-12-07 00:00:00', '2022-03-01 00:00:00', 58, 1, 2, 'Y', 'Z:EdProcACVACV 167Index for taskingTask 1', '07_For XML Edit', 'Commentary', '2021-12-03 00:00:00', '-', 864125, '27_Completed – QA Online', 'Online only', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(27, 'Tier 2', 'ACV 167_Task 2_ACA, WIRC', 'ACV', '167', 'ACV update_January 2022_edited', 'Gregory Wicks', '2022-01-28 00:00:00', '2022-02-07 00:00:00', 'Ed Mns-Med', 'ACA, WIRC', 'Task 2', '1900-01-01 00:00:00', 'Tim Patrick', 'N/A', 'Margot Antivola', '2022-02-07 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-07 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-14 00:00:00', '2022-02-15 00:00:00', 39, '2022-02-16 00:00:00', '2022-02-16 00:00:00', '2022-02-18 00:00:00', 41, 13, 7, 'Y', 'Z:EdProcACVACV 167ManuscriptEditedTask 2ACV update_January 2022_edited', '07_For XML Edit', 'Commentary', '2022-02-07 00:00:00', '-', 898427, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(28, 'Tier 2', 'ACV 167_Task 3_ACA', 'ACV', '167', 'ACV update_ACA s 5.1.81.55', 'Gregory Wicks', '2022-03-04 00:00:00', '2022-03-04 00:00:00', 'Ed Mns-Lgt', 'ACA', 'Task 3', '1900-01-01 00:00:00', 'Reem Ernst', '-', 'Margot Antivola', '2022-03-04 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-03-04 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-09 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-11 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 1, 1, 0, '-', 'Y:EdProcclqCLQ 207ManuscriptsTask 1', '07_For XML Edit', 'Commentary', '2022-03-04 00:00:00', '-', 0, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(29, 'Newsletter', 'AER 36.5_Task 1_', 'AER', '36.5', '01_Floro_Bushfire Suvrivors', '-', '1900-01-01 00:00:00', '2022-02-02 00:00:00', 'Ed Mns-Hvy', '-', 'Task 1', '1900-01-01 00:00:00', 'David Worswick', 'N/A', 'Margot Antivola', '2022-02-02 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-16 00:00:00', '2022-02-09 00:00:00', 6, '2022-02-18 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 11, 1, 0, '-', 'Z:EdProcaer36.5copyedited manuscript', '07_For XML Edit', 'Newsletter', '2022-02-03 00:00:00', '-', 895580, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(30, 'Newsletter', 'AER 36.5_Task 1_', 'AER', '36.5', '02_deZwart_Space Law', '-', '1900-01-01 00:00:00', '2022-02-02 00:00:00', 'Ed Mns-Hvy', '-', 'Task 1', '1900-01-01 00:00:00', 'David Worswick', 'N/A', 'Margot Antivola', '2022-02-02 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-16 00:00:00', '2022-02-09 00:00:00', 5, '2022-02-18 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 8, 1, 0, '-', 'Z:EdProcaer36.5copyedited manuscript', '07_For XML Edit', 'Newsletter', '2022-02-03 00:00:00', '-', 895580, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(31, 'Newsletter', 'AER 36.5_Task 1_', 'AER', '36.5', '03_Hartford-Davies_Directors Duties', '-', '1900-01-01 00:00:00', '2022-02-02 00:00:00', 'Ed Mns-Hvy', '-', 'Task 1', '1900-01-01 00:00:00', 'David Worswick', 'N/A', 'Margot Antivola', '2022-02-02 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-16 00:00:00', '2022-02-09 00:00:00', 6, '2022-02-18 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 13, 1, 0, '-', 'Z:EdProcaer36.5copyedited manuscript', '07_For XML Edit', 'Newsletter', '2022-02-03 00:00:00', '-', 895580, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(32, 'Newsletter', 'AER 36.5_Task 1_', 'AER', '36.5', '04_Musgrave_KEPCO Bylong', '-', '1900-01-01 00:00:00', '2022-02-02 00:00:00', 'Ed Mns-Hvy', '-', 'Task 1', '1900-01-01 00:00:00', 'David Worswick', 'N/A', 'Margot Antivola', '2022-02-02 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-16 00:00:00', '2022-02-09 00:00:00', 5, '2022-02-18 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 10, 1, 0, '-', 'Z:EdProcaer36.5copyedited manuscript', '07_For XML Edit', 'Newsletter', '2022-02-03 00:00:00', '-', 895580, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(33, 'Tier 2', 'AL 187_Task 1_CARS, GIAA, AJAP, Latup', 'AL', '187', 'Task 1 Cth Admin Rev System', 'Lex Holcombe', '2021-09-22 00:00:00', '2021-10-11 00:00:00', 'Manus-Light', 'CARS, GIAA, AJAP, Latup', 'Task 1', '1900-01-01 00:00:00', 'Ragnii Ommaney', '-', 'Ren Masu-ay', '2021-10-11 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-09-14 00:00:00', '2021-09-14 00:00:00', '2021-10-15 00:00:00', '2021-09-14 00:00:00', '2021-10-20 00:00:00', '2021-10-18 00:00:00', 0, '2021-10-22 00:00:00', '2021-10-21 00:00:00', '1900-01-01 00:00:00', 2, 2, 8, 'Y', 'Z:EdProcalAL_187ManuscriptEditedTask 1', '07_For XML Edit', 'Commentary', '2021-10-15 00:00:00', '-', 831544, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(34, 'Tier 2', 'AL 187_Task 1_CARS, GIAA, AJAP, Latup', 'AL', '187', 'Task 2 Gen Info', 'Lex Holcombe', '2021-10-11 00:00:00', '2021-10-11 00:00:00', 'Manus-Light', 'CARS, GIAA, AJAP, Latup', 'Task 1', '1900-01-01 00:00:00', 'Ragnii Ommaney', '-', 'Ren Masu-ay', '2021-10-11 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-09-14 00:00:00', '2021-09-14 00:00:00', '2021-10-15 00:00:00', '2021-09-14 00:00:00', '2021-10-20 00:00:00', '2021-10-18 00:00:00', 0, '2021-10-22 00:00:00', '2021-10-21 00:00:00', '1900-01-01 00:00:00', 2, 1, 8, 'Y', 'Z:EdProcalAL_187ManuscriptEditedTask 1', '07_For XML Edit', 'Commentary', '2021-10-15 00:00:00', '-', 831544, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(35, 'Tier 2', 'AL 187_Task 1_CARS, GIAA, AJAP, Latup', 'AL', '187', 'Task 3 Admin App Trib', 'Lex Holcombe', '2021-09-23 00:00:00', '2021-10-11 00:00:00', 'Manus-Light', 'CARS, GIAA, AJAP, Latup', 'Task 1', '1900-01-01 00:00:00', 'Ragnii Ommaney', '-', 'Ren Masu-ay', '2021-10-11 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-09-14 00:00:00', '2021-09-14 00:00:00', '2021-10-15 00:00:00', '2021-09-14 00:00:00', '2021-10-20 00:00:00', '2021-10-18 00:00:00', 0, '2021-10-22 00:00:00', '2021-10-21 00:00:00', '1900-01-01 00:00:00', 2, 2, 8, 'Y', 'Z:EdProcalAL_187ManuscriptEditedTask 1', '07_For XML Edit', 'Commentary', '2021-10-15 00:00:00', '-', 831544, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(36, 'Tier 2', 'AL 187_Task 2_CARS, Latup', 'AL', '187', '952', 'Lex Holcombe', '2021-11-12 00:00:00', '2021-11-15 00:00:00', 'Manus-Medium', 'CARS, Latup', 'Task 2', '1900-01-01 00:00:00', 'Ragnii Ommaney', '-', 'Ren Masu-ay', '2021-11-15 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-11-24 00:00:00', '2021-11-24 00:00:00', '2021-11-25 00:00:00', '2021-11-24 00:00:00', '2021-12-02 00:00:00', '2021-11-25 00:00:00', 0, '2021-12-06 00:00:00', '2021-11-29 00:00:00', '1900-01-01 00:00:00', 2, 1, 10, 'Y', 'Z:EdProcalAL_187ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2021-11-24 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(37, 'Tier 2', 'AL 187_Task 2_CARS, Latup', 'AL', '187', '953A (New)', 'Lex Holcombe', '2021-11-12 00:00:00', '2021-11-15 00:00:00', 'Manus-Medium', 'CARS, Latup', 'Task 2', '1900-01-01 00:00:00', 'Ragnii Ommaney', '-', 'Ren Masu-ay', '2021-11-15 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-11-24 00:00:00', '2021-11-24 00:00:00', '2021-11-25 00:00:00', '2021-11-24 00:00:00', '2021-12-02 00:00:00', '2021-11-25 00:00:00', 0, '2021-12-06 00:00:00', '2021-11-29 00:00:00', '1900-01-01 00:00:00', 4, 1, 10, 'Y', 'Z:EdProcalAL_187ManuscriptEditedTask 2', '07_For XML Edit', 'Commentary', '2021-11-24 00:00:00', '-', 855219, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(38, 'Tier 2', 'AL 187_Task 3_Index', 'AL', '187', 'Index', '-', '1900-01-01 00:00:00', '2021-11-17 00:00:00', 'Index', 'Index', 'Task 3', '1900-01-01 00:00:00', 'Ren Masu-ay', '-', 'Ren Masu-ay', '2021-11-17 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-11-17 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-11-22 00:00:00', '2021-11-19 00:00:00', 0, '2021-11-24 00:00:00', '2021-11-22 00:00:00', '1900-01-01 00:00:00', 36, 1, 3, 'Y', 'Y:EdProcalAL_187Index', '07_For XML Edit', 'Index', '2021-11-17 00:00:00', '-', 851574, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(39, 'Tier 2', 'AL 187_Task 4_CARS, Latup', 'AL', '187', '258', 'Lex Holcombe', '2021-11-23 00:00:00', '2021-11-25 00:00:00', 'Manus-Light', 'CARS, Latup', 'Task 4', '2021-12-23 00:00:00', 'Ragnii Ommanney', '-', 'Ren Masu-ay', '2021-11-25 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-11-29 00:00:00', '2021-12-01 00:00:00', '2021-12-01 00:00:00', '2021-12-01 00:00:00', '2021-12-06 00:00:00', '2021-12-06 00:00:00', 0, '2021-12-08 00:00:00', '2021-12-08 00:00:00', '1900-01-01 00:00:00', 4, 1, 9, 'Y', 'Z:EdProcalAL_187ManuscriptEditedTask 4', '07_For XML Edit', 'Commentary', '2021-12-01 00:00:00', '-', 860970, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(40, 'Tier 2', 'AL 187_Task 5_CARS, Latup', 'AL', '187', '872', 'Lex Holcombe', '2021-12-16 00:00:00', '2021-12-16 00:00:00', 'Manus-Medium', 'CARS, Latup', 'Task 5', '1900-01-01 00:00:00', 'Ragnii Ommaney', '-', 'Ren Masu-ay', '2021-12-16 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-12-27 00:00:00', '2021-12-27 00:00:00', '2021-12-28 00:00:00', '2021-12-27 00:00:00', '2022-01-04 00:00:00', '2021-12-30 00:00:00', 2, '2022-01-06 00:00:00', '2021-12-30 00:00:00', '2022-02-15 00:00:00', 2, 1, 10, 'Y', 'Z:EdProcalAL_187ManuscriptRawTask 5', '07_For XML Edit', 'Commentary', '2021-12-27 00:00:00', '-', 872402, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(41, 'Tier 2', 'AL 187_Task 6_TOS', 'AL', '187', 'Table of Statutes', '-', '1900-01-01 00:00:00', '2022-01-20 00:00:00', 'TOS', 'TOS', 'Task 6', '1900-01-01 00:00:00', 'Ren Masu-ay', '-', 'Ren Masu-ay', '2022-01-20 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-20 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-27 00:00:00', '2022-01-25 00:00:00', 12, '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 10, 1, 0, '-', '-', '07_For XML Edit', 'Commentary', '2022-01-20 00:00:00', '-', 886167, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(42, 'Tier 2', 'AL 187_Task 7_CARS, Latup', 'AL', '187', '\\corp.regn.netsydpublishingEdProcalAL_187ManuscriptRawTask 7', 'Lex Holcombe', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 'Manus-Light', 'CARS, Latup', 'Task 7', '1900-01-01 00:00:00', 'Ragnii Ommaney', '-', 'Mark Grande', '2022-01-31 00:00:00', 'Patricia Artajo', '2022-02-01 00:00:00', '2022-02-03 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-02-04 00:00:00', '2022-02-04 00:00:00', '2022-02-04 00:00:00', '2022-02-04 00:00:00', '2022-02-09 00:00:00', '2022-02-05 00:00:00', 5, '2022-02-11 00:00:00', '2022-02-09 00:00:00', '2022-02-15 00:00:00', 4, 1, 7, 'Y', 'Z:EdProcalAL_187ManuscriptRawTask 7', '07_For XML Edit', 'Commentary', '2022-02-04 00:00:00', '-', 893514, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(43, 'Tier 2', 'AL 188_Task 1_CARS, Latup', 'AL', '188', '\\corp.regn.netsydpublishingEdProcalAL_188ManuscriptRawTask 1', '-', '2022-02-26 00:00:00', '2022-03-03 00:00:00', 'Ed Mns-Lgt', 'CARS, Latup', 'Task 1', '1900-01-01 00:00:00', 'Ragnii Ommanney', '-', 'Ren/Margot/Chelsea', '2022-03-03 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-03-04 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-08 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 12, 4, 0, '-', 'Z:EdProcalAL_188ManuscriptRawTask 1', '01_For PE Processing', 'Commentary', '1900-01-01 00:00:00', '-', 0, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(44, 'Tier 3', 'AML 19_Task 1_CHAP5', 'AML', '19', 'Chapter 4: International Initiatives to Fight Financial Crime', 'Dr. Doron Goldbarsht', '1900-01-01 00:00:00', '2021-09-17 00:00:00', 'Manus-Heavy', 'CHAP5', 'Task 1', '1900-01-01 00:00:00', 'Johnny Mannah', '-', 'El Reyes', '2021-09-17 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-09-22 00:00:00', '2021-10-06 00:00:00', '2021-10-06 00:00:00', '2021-10-06 00:00:00', '2021-10-20 00:00:00', '2021-10-22 00:00:00', 0, '2021-10-22 00:00:00', '2021-10-21 00:00:00', '1900-01-01 00:00:00', 32, 1, 24, 'Y', 'Y:EdProcamlService 19ManuscriptRawTask 1', '07_For XML Edit', 'Commentary', '2021-10-07 00:00:00', '-', 854949, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(45, 'Tier 3', 'AML 19_Task 1_CHAP8', 'AML', '19', 'Chapter 7: Developments in International Money Laundering Requirements', 'Dr. Doron Goldbarsht', '1900-01-01 00:00:00', '2021-09-17 00:00:00', 'Manus-Heavy', 'CHAP8', 'Task 1', '1900-01-01 00:00:00', 'Johnny Mannah', '-', 'El Reyes', '2021-09-17 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-09-22 00:00:00', '2021-10-06 00:00:00', '2021-10-06 00:00:00', '2021-10-06 00:00:00', '2021-10-20 00:00:00', '2021-10-22 00:00:00', 0, '2021-10-22 00:00:00', '2021-10-22 00:00:00', '1900-01-01 00:00:00', 13, 1, 25, 'Y', 'Y:EdProcamlService 19ManuscriptRawTask 1', '07_For XML Edit', 'Commentary', '2021-10-07 00:00:00', '-', 854949, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(46, 'Tier 3', 'AML 20_Task 1_CHAP2,CHAP3', 'AML', '20', 'Chapter 2: Overview of Financial Crime in Australia', '-', '2022-01-05 00:00:00', '2022-01-11 00:00:00', 'Manus-Heavy', 'CHAP2,CHAP3', 'Task 1', '1900-01-01 00:00:00', 'Johnny Mannah', 'N/A', 'El Reyes', '2022-01-11 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '2022-01-14 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-01-17 00:00:00', '2022-01-14 00:00:00', '2022-01-28 00:00:00', '2022-01-14 00:00:00', '2022-02-11 00:00:00', '2022-02-10 00:00:00', 36, '2022-02-15 00:00:00', '2022-02-14 00:00:00', '1900-01-01 00:00:00', 9, 1, 24, 'Y', 'Y:EdProcamlService 20RawTask 1', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 896778, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(47, 'Tier 3', 'AML 20_Task 1_CHAP2,CHAP3', 'AML', '20', 'Chapter 3: Legal Issues Arising out of Financial Crime', '-', '2021-12-15 00:00:00', '2022-01-11 00:00:00', 'Manus-Heavy', 'CHAP2,CHAP3', 'Task 1', '1900-01-01 00:00:00', 'Johnny Mannah', 'N/A', 'El/Raeven', '2022-01-11 00:00:00', 'Patricia Artajo', '2022-01-18 00:00:00', '2022-01-27 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-01-18 00:00:00', '2022-01-18 00:00:00', '2022-01-28 00:00:00', '2022-01-18 00:00:00', '2022-02-11 00:00:00', '2022-02-10 00:00:00', 0, '2022-02-15 00:00:00', '2022-02-14 00:00:00', '1900-01-01 00:00:00', 24, 1, 24, 'Y', 'Y:EdProcamlService 20RawTask 1', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 896778, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(48, 'Tier 3', 'ANNLR 16_Task 1_CHAP3, LATUP', 'ANNLR', '16', 'ANNLR Ch 3 Continuous Disclosure_HF 6-1-22', 'N/A', '1900-01-01 00:00:00', '2022-01-07 00:00:00', 'Manus-Heavy', 'CHAP3, LATUP', 'Task 1', '1900-01-01 00:00:00', 'Vida Long', 'N/A', 'Chelsea Mercado', '2022-01-07 00:00:00', 'Laiza Remotin', '2022-01-13 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-01-17 00:00:00', '2022-01-17 00:00:00', '2022-01-26 00:00:00', '2022-01-17 00:00:00', '2022-02-09 00:00:00', '2022-01-28 00:00:00', 101, '2022-02-11 00:00:00', '2022-02-11 00:00:00', '1900-01-01 00:00:00', 0, 1, 25, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-17 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(49, 'Tier 3', 'ANNLR September_2021_annlr tables', 'ANNLR', 'September', 'ANNLR_TableofWaivers_September_2021 + Fit', '-', '1900-01-01 00:00:00', '2021-10-22 00:00:00', 'Other', 'annlr tables', '2021', '1900-01-01 00:00:00', 'Chelsea Mercado', '-', 'Chelsea Mercado', '2021-10-25 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-10-25 00:00:00', '2021-10-25 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-10-29 00:00:00', '2021-10-29 00:00:00', 0, '2021-11-02 00:00:00', '2021-11-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 7, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-10-25 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(50, 'Tier 3', 'ANNLR TableofWaivers__October 2021', 'ANNLR', 'TableofWaivers', 'ANNLRTableofWaivers', '-', '1900-01-01 00:00:00', '2021-11-29 00:00:00', 'Other', 'October 2021', '-', '2021-12-23 00:00:00', 'Chelsea Mercado', '-', 'Chelsea Mercado', '2021-11-29 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-11-29 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-06 00:00:00', '2021-12-07 00:00:00', 0, '2021-12-08 00:00:00', '2021-12-08 00:00:00', '1900-01-01 00:00:00', 0, 1, 7, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-11-30 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(51, 'Tier 3', 'ANNLR TableofWaivers_November_2021', 'ANNLR', 'TableofWaivers', 'Z:EdProcannlrTABLE OF WAIVERS_servicesMANUSCRIPTS2021', '-', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 'Ed Mns-Lgt', '2021', 'November', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-05 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-05 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-10 00:00:00', '2022-01-07 00:00:00', 11, '2022-01-12 00:00:00', '2022-01-11 00:00:00', '1900-01-01 00:00:00', 11, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-05 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(52, 'Tier 3', 'ANNLR TableofWaivers_December_2021', 'ANNLR', 'TableofWaivers', 'Z:EdProcannlrTABLE OF WAIVERS_servicesMANUSCRIPTS2021', '-', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 'Ed Mns-Lgt', '2021', 'December', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-31 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-31 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-03 00:00:00', '2022-02-03 00:00:00', 12, '2022-02-07 00:00:00', '2022-02-07 00:00:00', '1900-01-01 00:00:00', 20, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-31 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(53, 'Tier 3', 'ANNLR TableofWaivers_January_2022', 'ANNLR', 'TableofWaivers', 'Z:EdProcannlrTABLE OF WAIVERS_servicesMANUSCRIPTS2022', '-', '2022-02-22 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Med', '2022', 'January', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-01 00:00:00', '2022-02-25 00:00:00', 6, '2022-03-03 00:00:00', '2022-03-01 00:00:00', '1900-01-01 00:00:00', 10, 2, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(54, 'Newsletter', 'APLB 37.1_Task 1_NL', 'APLB', '37.1', 'APLB - Article on Artesian Hospitality - Heads of Agreement - edited', '-', '2022-02-08 00:00:00', '2022-02-09 00:00:00', 'Manus-Light', 'NL', 'Task 1', '1900-01-01 00:00:00', 'Kim Hodge', '-', 'Mark Grande', '2022-02-09 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '2022-02-15 00:00:00', '1900-01-01 00:00:00', '2022-02-18 00:00:00', '1900-01-01 00:00:00', 0, '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 1, 0, '-', 'Z:EdProcAPLBplbVolume 3737.1ManuscriptEditedTask 1', '07_For XML Edit', 'Newsletter', '2022-02-09 00:00:00', '-', 0, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(55, 'Newsletter', 'APLB 37.1_Task 1_NL', 'APLB', '37.1', 'APLB - Carter v Mehmet_Pallavicini - edited', '-', '2022-02-08 00:00:00', '2022-02-09 00:00:00', 'Manus-Medium', 'NL', 'Task 1', '1900-01-01 00:00:00', 'Kim Hodge', '-', 'Mark Grande', '2022-02-09 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '2022-02-28 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 1, 0, '-', 'Z:EdProcAPLBplbVolume 3737.1ManuscriptEditedTask 1', '07_For XML Edit', 'Newsletter', '2022-02-09 00:00:00', '-', 0, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(56, 'Newsletter', 'APLB 37.1_Task 1_NL', 'APLB', '37.1', 'APLB - Marbryde Pty Ltd v Mainland Property Holdings No 8 Pty Ltd - edited', '-', '2022-02-08 00:00:00', '2022-02-09 00:00:00', 'Manus-Medium', 'NL', 'Task 1', '1900-01-01 00:00:00', 'Kim Hodge', '-', 'Mark Grande', '2022-02-09 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '2022-02-28 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 1, 0, '-', 'Z:EdProcAPLBplbVolume 3737.1ManuscriptEditedTask 1', '07_For XML Edit', 'Newsletter', '2022-02-09 00:00:00', '-', 0, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(57, 'Newsletter', 'APLB 37.1_Task 1_NL', 'APLB', '37.1', 'APLB - Unsuccessful claim of fraud in severance of joint tenancy_duncan - edited', '-', '2022-02-08 00:00:00', '2022-02-09 00:00:00', 'Manus-Medium', 'NL', 'Task 1', '1900-01-01 00:00:00', 'Kim Hodge', '-', 'Mark Grande', '2022-02-09 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '2022-02-28 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 1, 0, '-', 'Z:EdProcAPLBplbVolume 3737.1ManuscriptEditedTask 1', '07_For XML Edit', 'Newsletter', '2022-02-09 00:00:00', '-', 0, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(58, 'Newsletter', 'APLB 37.1_Task 1_NL', 'APLB', '37.1', 'APLB 37_1_REIQ Contract January 2022 - edited', '-', '2022-02-08 00:00:00', '2022-02-09 00:00:00', 'Manus-Heavy', 'NL', 'Task 1', '1900-01-01 00:00:00', 'Kim Hodge', '-', 'Mark Grande', '2022-02-09 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '2022-02-28 00:00:00', '1900-01-01 00:00:00', '2022-03-14 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-16 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 1, 0, '-', 'Z:EdProcAPLBplbVolume 3737.1ManuscriptEditedTask 1', '07_For XML Edit', 'Newsletter', '2022-02-09 00:00:00', '-', 0, '-', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(59, 'Tier 3', 'ASC 243_Task 72_INFO', 'ASC', '243', 'INFO 267 Tips for giving limited advice', 'N/A', '1900-01-01 00:00:00', '2021-12-02 00:00:00', 'Prac Mat', 'INFO', 'Task 72', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-02 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-02 00:00:00', '2021-12-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-28 00:00:00', '2021-12-04 00:00:00', 10, '2021-12-30 00:00:00', '2021-12-09 00:00:00', '1900-01-01 00:00:00', 9, 1, 5, 'Y', 'Z:EdProcASCServicesService 2433. Information SheetsDecember TrackingNew', '07_For XML Edit', 'Commentary', '2021-12-03 00:00:00', '-', 864332, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1);
INSERT INTO `coversheet_mt` (`CoversheetID`, `CoversheetTier`, `CoversheetName`, `BPSProductID`, `ServiceNumber`, `ManuscriptFile`, `LatupAttribution`, `DateReceivedFromAuthor`, `DateEnteredIntoTracker`, `UpdateType`, `GuideCard`, `TaskNumber`, `RevisedOnlineDueDate`, `DepositedBy`, `LEInstructions`, `PickUpBy`, `PickUpDate`, `QABy`, `QADate`, `QACompletionDate`, `QueryLog`, `QueryForApprovalStartDate`, `QueryForApprovalEndDate`, `QueryForApprovalAge`, `Process`, `PETargetCompletion`, `LatupTargetCompletion`, `EndingDueDate`, `PEActualCompletion`, `CodingDueDate`, `CodingActualCompletion`, `ActualPages`, `OnlineDueDate`, `OnlineActualCompletion`, `LNRedCheckingActualCompletion`, `AffectedPages`, `NoOfMSSFile`, `ActualTAT`, `BenchmarkMET`, `FilePath`, `PEStatus`, `TaskType`, `TaskReadyDate`, `PDFQA_PE`, `QMSID`, `CodingStatus`, `CoversheetRemarks`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(60, 'Tier 3', 'ASC 243_Task 73_REP', 'ASC', '243', 'REPORTS - NEW', 'N/A', '1900-01-01 00:00:00', '2021-12-02 00:00:00', 'Prac Mat', 'REP', 'Task 73', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-02 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-02 00:00:00', '2021-12-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-28 00:00:00', '2022-01-05 00:00:00', 117, '2021-12-30 00:00:00', '2022-01-17 00:00:00', '1900-01-01 00:00:00', 136, 9, 32, 'N', 'Z:EdProcASCServicesService 2434. Reports1 Dec 2021New', '07_For XML Edit', 'Commentary', '2021-12-03 00:00:00', '-', 882197, '27_Completed – QA Online', 'Non-straive: with Technical Issue', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(61, 'Tier 3', 'ASC 243_Task 74_CO', 'ASC', '243', 'ASIC Corporations (Amendment) Instrument 2021/976', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'CO', 'Task 74', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-13 00:00:00', 0, '2022-01-07 00:00:00', '2021-12-29 00:00:00', '1900-01-01 00:00:00', 0, 1, 13, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 866483, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(62, 'Tier 3', 'ASC 243_Task 74_CO', 'ASC', '243', 'ASIC Corporations (Amendment) Instrument 2021/976', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'CO', 'Task 74', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-13 00:00:00', 0, '2022-01-07 00:00:00', '2021-12-29 00:00:00', '1900-01-01 00:00:00', 0, 1, 13, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 866483, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(63, 'Tier 3', 'ASC 243_Task 74_CO', 'ASC', '243', 'ASIC Corporations (Amendment) Instrument 2021/976', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'CO', 'Task 74', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-13 00:00:00', 12, '2022-01-07 00:00:00', '2021-12-29 00:00:00', '1900-01-01 00:00:00', 0, 1, 13, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 866483, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(64, 'Tier 3', 'ASC 243_Task 75_REP', 'ASC', '243', 'rep716-published-6-december-2021', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'REP', 'Task 75', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-21 00:00:00', 15, '2022-01-07 00:00:00', '2022-01-17 00:00:00', '1900-01-01 00:00:00', 0, 1, 26, 'N', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 871703, '27_Completed – QA Online', 'Non-straive: with technical issue', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(65, 'Tier 3', 'ASC 243_Task 76_CO', 'ASC', '243', 'ASIC Corporations (Amendment) Instrument 2021_895', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'CO', 'Task 76', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-16 00:00:00', 23, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 890157, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(66, 'Tier 3', 'ASC 243_Task 76_CO', 'ASC', '243', 'ASIC Corporations (Definition of Approved Foreign Market) Instrument 2017_669', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'CO', 'Task 76', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-16 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 890157, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(67, 'Tier 3', 'ASC 243_Task 76_CO', 'ASC', '243', 'ASIC Corporations (Extended Reporting and Lodgment Deadlines—Unlisted Entities) Instrument 2020_395', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'CO', 'Task 76', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-16 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 890157, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(68, 'Tier 3', 'ASC 243_Task 76_CO', 'ASC', '243', 'ASIC Corporations (Wholly-owned Companies) Instrument 2016_785', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'CO', 'Task 76', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-16 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 890157, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(69, 'Tier 3', 'ASC 243_Task 77_RG', 'ASC', '243', 'rg72-published-2-september-2015-20211203', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'RG', 'Task 77', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 366, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 882198, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(70, 'Tier 3', 'ASC 243_Task 77_RG', 'ASC', '243', 'rg121-published-30-july-2013-20211208', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'RG', 'Task 77', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 882198, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(71, 'Tier 3', 'ASC 243_Task 77_RG', 'ASC', '243', 'rg166-published-29-april-2021-20211208', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'RG', 'Task 77', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 882198, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(72, 'Tier 3', 'ASC 243_Task 77_RG', 'ASC', '243', 'rg175-published-15-june-2021-20211208', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'RG', 'Task 77', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 882198, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(73, 'Tier 3', 'ASC 243_Task 77_RG', 'ASC', '243', 'rg244-published-13-december-2012-20211208', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'RG', 'Task 77', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 882198, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(74, 'Tier 3', 'ASC 243_Task 78_INFO', 'ASC', '243', 'Disputes about life insurance _ ASIC - Australian Securities and Investments Commission', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'INFO', 'Task 78', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-20 00:00:00', 17, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 890158, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(75, 'Tier 3', 'ASC 243_Task 78_INFO', 'ASC', '243', 'FAQs_ Dealing with consumers and credit _ ASIC - Australian Securities and Investments Commission', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'INFO', 'Task 78', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-20 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 890158, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(76, 'Tier 3', 'ASC 243_Task 78_INFO', 'ASC', '243', 'Licensing requirements for providers of funeral expenses facilities _ ASIC - Australian Securities and Investments Commission', '-', '1900-01-01 00:00:00', '2021-12-10 00:00:00', 'Prac Mat', 'INFO', 'Task 78', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-10 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-10 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-05 00:00:00', '2021-12-20 00:00:00', 0, '2022-01-07 00:00:00', '2022-01-07 00:00:00', '1900-01-01 00:00:00', 0, 1, 20, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-12-13 00:00:00', '-', 890158, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(77, 'Tier 3', 'ASC 243_Task 79_INFO', 'ASC', '243', 'Giving AFS and credit licensees information about their representatives _ ASIC - Australian Securities and Investments Commission', '-', '1900-01-01 00:00:00', '2021-12-22 00:00:00', 'Prac Mat', 'INFO', 'Task 79', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-23 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-23 00:00:00', '2021-12-23 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-17 00:00:00', '2021-12-27 00:00:00', 6, '2022-01-19 00:00:00', '2021-12-30 00:00:00', '1900-01-01 00:00:00', 5, 1, 6, 'Y', 'Z:EdProcASCServicesService 2433. Information SheetsDecember TrackingOutdated21 Dec 2021', '07_For XML Edit', 'Commentary', '2021-12-23 00:00:00', '-', 890160, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(78, 'Tier 3', 'ASC 243_Task 80_RG', 'ASC', '243', 'rg1-published-21-december-2021', '-', '1900-01-01 00:00:00', '2021-12-22 00:00:00', 'Prac Mat', 'RG', 'Task 80', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-23 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-23 00:00:00', '2021-12-23 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-17 00:00:00', '2022-01-18 00:00:00', 100, '2022-01-19 00:00:00', '2022-01-19 00:00:00', '1900-01-01 00:00:00', 41, 1, 20, 'Y', 'Z:EdProcASCServicesService 2432. Regulatory GuidesDecember 2021 trackingOUTDATED21 Dec  2021', '07_For XML Edit', 'Commentary', '2021-12-23 00:00:00', '-', 886070, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(79, 'Tier 3', 'ASC 243_Task 80_RG', 'ASC', '243', 'rg2-published-21-december-2021', '-', '1900-01-01 00:00:00', '2021-12-22 00:00:00', 'Prac Mat', 'RG', 'Task 80', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-23 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-23 00:00:00', '2021-12-23 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-17 00:00:00', '2022-01-18 00:00:00', 0, '2022-01-19 00:00:00', '2022-01-19 00:00:00', '1900-01-01 00:00:00', 101, 1, 20, 'Y', 'Z:EdProcASCServicesService 2432. Regulatory GuidesDecember 2021 trackingOUTDATED21 Dec  2021', '07_For XML Edit', 'Commentary', '2021-12-23 00:00:00', '-', 886070, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(80, 'Tier 3', 'ASC 244_Task 1_INFO', 'ASC', '244', 'FAQs_ Regulation and registration of relevant providers who provide tax (financial) advice services _ ASIC - Australian Securities and Investments Commission', '-', '1900-01-01 00:00:00', '2021-12-28 00:00:00', 'Prac Mat', 'INFO', 'Task 1', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-28 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-28 00:00:00', '2021-12-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-21 00:00:00', '2022-01-10 00:00:00', 10, '2022-01-25 00:00:00', '2022-01-15 00:00:00', '1900-01-01 00:00:00', 7, 1, 13, 'Y', 'Z:EdProcASCServicesService 2443. Information SheetsNew28 Dec 2021Task 1', '07_For XML Edit', 'Commentary', '2021-12-29 00:00:00', '-', 882199, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(81, 'Tier 3', 'ASC 244_Task 2_INFO', 'ASC', '244', 'How do RSE and AFS licensing application processes work together _ ASIC - Australian Securities and Investments Commission', '-', '1900-01-01 00:00:00', '2021-12-28 00:00:00', 'Prac Mat', 'INFO', 'Task 2', '1900-01-01 00:00:00', 'Ae Cabansag', '-', 'Ae Cabansag', '2021-12-28 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-28 00:00:00', '2021-12-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-21 00:00:00', '2022-01-10 00:00:00', 4, '2022-01-25 00:00:00', '2022-01-17 00:00:00', '1900-01-01 00:00:00', 3, 1, 14, 'Y', 'Z:EdProcASCServicesService 2443. Information SheetsOutdated28 Dec 2021Task 2', '07_For XML Edit', 'Commentary', '2021-12-29 00:00:00', '-', 882200, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(82, 'Tier 3', 'ASC 244_Task 3_INFO, LATUP', 'ASC', '244', 'Information Sheet 230 Exchange traded products: Admission guidelines', '-', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Prac Mat', 'INFO, LATUP', 'Task 3', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-01-27 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-27 00:00:00', '2022-01-27 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-22 00:00:00', '2022-02-08 00:00:00', 4, '2022-02-24 00:00:00', '2022-02-14 00:00:00', '1900-01-01 00:00:00', 4, 1, 12, 'Y', 'Y:EdProcASCServicesService 2443. Information SheetsOutdatedTask 3', '07_For XML Edit', 'Commentary', '2022-01-27 00:00:00', '-', 898485, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(83, 'Tier 3', 'ASC 244_Task 4_CO, LATUP', 'ASC', '244', 'ASIC Market Integrity Rules (Securities Markets) Class Waiver (Amendment) Instrument 2022/25', '-', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Prac Mat', 'CO, LATUP', 'Task 4', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-01-27 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-27 00:00:00', '2022-01-27 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-22 00:00:00', '2022-02-24 00:00:00', 0, '2022-02-24 00:00:00', '2022-03-01 00:00:00', '2022-03-01 00:00:00', 7, 1, 23, 'N', 'Y:EdProcASCServicesService 2441. Legislative InstrumentsTask 4', '07_For XML Edit', 'Commentary', '2022-01-27 00:00:00', '-', 906867, '27_Completed – QA Online', '7 Feb: Filed JIRA ticket EPMS-65988 due to a technical issue; 24 Feb: Ticket solved; 24 Feb: Received notification of completion from coding; 28 Feb: Approved by PE', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(84, 'Tier 3', 'ASC 244_Task 5_REP, LATUP', 'ASC', '244', 'REP 717 ASIC quarterly update: October to December 2021', '-', '1900-01-01 00:00:00', '2022-02-09 00:00:00', 'Prac Mat', 'REP, LATUP', 'Task 5', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-02-09 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-07 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-09 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 11, 1, 0, '-', 'Y:EdProcASCServicesService 2444. ReportsTask 5', '07_For XML Edit', 'Commentary', '2022-02-09 00:00:00', '-', 909669, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(85, 'Tier 3', 'ASC 244_Task 6_CO, LATUP', 'ASC', '244', 'ASIC Corporations (Amendment) Instrument 2022/20', '-', '1900-01-01 00:00:00', '2022-02-16 00:00:00', 'Prac Mat', 'CO, LATUP', 'Task 6', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-02-16 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-16 00:00:00', '2022-02-16 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-14 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-16 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 4, 1, 0, '-', 'Y:EdProcASCServicesService 2441. Legislative InstrumentsTask 6', '07_For XML Edit', 'Commentary', '2022-02-17 00:00:00', '-', 0, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(86, 'Tier 3', 'ASC 244_Task 6_CO, LATUP', 'ASC', '244', 'ASIC Corporations (Cash Settlement Fact Sheet) Instrument 2022/59', '-', '1900-01-01 00:00:00', '2022-02-16 00:00:00', 'Prac Mat', 'CO, LATUP', 'Task 6', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-02-16 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-16 00:00:00', '2022-02-16 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-14 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-16 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 6, 1, 0, '-', 'Y:EdProcASCServicesService 2441. Legislative InstrumentsTask 6', '07_For XML Edit', 'Commentary', '2022-02-17 00:00:00', '-', 0, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(87, 'Tier 3', 'ASC 244_Task 6_CO, LATUP', 'ASC', '244', 'ASIC Corporations (Financial Counselling Agencies) Instrument 2017/792', '-', '1900-01-01 00:00:00', '2022-02-16 00:00:00', 'Prac Mat', 'CO, LATUP', 'Task 6', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-02-16 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-16 00:00:00', '2022-02-16 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-14 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-16 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 6, 1, 0, '-', 'Y:EdProcASCServicesService 2441. Legislative InstrumentsTask 6', '07_For XML Edit', 'Commentary', '2022-02-17 00:00:00', '-', 0, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(88, 'Tier 3', 'ASC 244_Task 7_CO, LATUP', 'ASC', '244', 'ASIC Corporations (Repeal) Instrument 2022/65', '-', '1900-01-01 00:00:00', '2022-02-23 00:00:00', 'Prac Mat', 'CO, LATUP', 'Task 7', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-02-23 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-23 00:00:00', '2022-02-23 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-21 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-23 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 1, 1, 0, '-', 'Y:EdProcASCServicesService 2441. Legislative InstrumentsTask 7', '07_For XML Edit', 'Commentary', '2022-02-23 00:00:00', '-', 909673, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(89, 'Tier 3', 'ASC 244_Task 7_CO, LATUP', 'ASC', '244', 'ASIC Corporations (PDS Requirements for General Insurance Quotes) Instrument 2022/66', '-', '1900-01-01 00:00:00', '2022-02-23 00:00:00', 'Prac Mat', 'CO, LATUP', 'Task 7', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-02-23 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-23 00:00:00', '2022-02-23 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-21 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-23 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 1, 1, 0, '-', 'Y:EdProcASCServicesService 2441. Legislative InstrumentsTask 7', '07_For XML Edit', 'Commentary', '2022-02-23 00:00:00', '-', 909673, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(90, 'Tier 3', 'ASC 244_Task 8_CO, LATUP', 'ASC', '244', 'ASIC Credit (Amendment) Instrument 2022/81', '-', '1900-01-01 00:00:00', '2022-03-02 00:00:00', 'Prac Mat', 'CO, LATUP', 'Task 8', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-03-02 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-03-02 00:00:00', '2022-03-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-28 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-30 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 9, 1, 0, '-', 'Y:EdProcASCServicesService 2441. Legislative InstrumentsTask 8', '07_For XML Edit', 'Commentary', '2022-03-02 00:00:00', '-', 0, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(91, 'Tier 3', 'ASC 244_Task 9_INFO, LATUP', 'ASC', '244', 'INFO 29 External administration, controller appointments and schemes of arrangement: Most commonly lodged forms', '-', '1900-01-01 00:00:00', '2022-03-02 00:00:00', 'Prac Mat', 'INFO, LATUP', 'Task 9', '1900-01-01 00:00:00', 'Patricia Artajo', '-', 'Patricia Artajo', '2022-03-02 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-03-02 00:00:00', '2022-03-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-03-28 00:00:00', '1900-01-01 00:00:00', 0, '2022-03-30 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 6, 1, 0, '-', 'Y:EdProcASCServicesService 2443. Information SheetsTask 9', '07_For XML Edit', 'Commentary', '2022-03-02 00:00:00', '-', 911101, '01_For XML edit', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(92, 'Tier 2', 'ASDL 115_Task 1_VICRUL, QLDRUL, SACIRC, WARUL, NTPN, ACTRUL', 'ASDL', '115', 'Practice Material', '-', '1900-01-01 00:00:00', '2021-12-03 00:00:00', 'Prac Mat', 'VICRUL, QLDRUL, SACIRC, WARUL, NTPN, ACTRUL', 'Task 1', '2022-01-10 00:00:00', 'Ren Masu-ay', '-', 'Ren Masu-ay', '2021-12-03 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-29 00:00:00', '2021-12-29 00:00:00', 287, '2021-12-31 00:00:00', '2022-01-06 00:00:00', '2022-02-14 00:00:00', 250, 58, 24, 'Y', 'Z:EdProcasdlASDL 115Practice materialTask 1', '07_For XML Edit', 'Commentary', '2021-12-06 00:00:00', '-', 874762, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(93, 'Tier 1', 'ASXACH hist2021_Aug_16', 'ASXACH', 'hist2021', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-08 00:00:00', 'Ed Mns-Lgt', '16', 'Aug', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-08 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-08 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-11 00:00:00', '2022-02-11 00:00:00', 3, '2022-02-15 00:00:00', '2022-02-15 00:00:00', '1900-01-01 00:00:00', 1, 1, 5, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-08 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(94, 'Tier 1', 'ASXACH hist2020_Nov_23', 'ASXACH', 'hist2020', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-14 00:00:00', 'Ed Mns-Lgt', '23', 'Nov', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-14 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-14 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-17 00:00:00', '2022-02-14 00:00:00', 3, '2022-02-21 00:00:00', '2022-02-15 00:00:00', '1900-01-01 00:00:00', 1, 1, 1, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-14 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(95, 'Tier 1', 'ASXACH hist2021_Dec_03', 'ASXACH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', '03', 'Dec', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-23 00:00:00', 3, '2022-03-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 2, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(96, 'Tier 1', 'ASXACR 81_Task 1_ANX', 'ASXACR', '81', 'ASXACR Word audit', '-', '1900-01-01 00:00:00', '2022-01-24 00:00:00', 'Ed Mns-Lgt', 'ANX', 'Task 1', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-24 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-27 00:00:00', '2022-01-25 00:00:00', 1, '2022-01-31 00:00:00', '2022-01-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 2, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-24 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(97, 'Tier 1', 'ASXACR 81_1st amndmnt_CUR, RUL, PROC', 'ASXACR', '81', 'ASX Clear Operating Rules', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'CUR, RUL, PROC', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Ren Masu-ay', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '1900-01-01 00:00:00', 0, '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 1, 1, 0, '-', 'Z:EdProcasxacrService 81Manuscripts1st amendment', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '08_Cancelled', 'ASX supplied wrong files', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(98, 'Tier 1', 'ASXACR 81_1st amndmnt_CUR, RUL, PROC', 'ASXACR', '81', 'Mark Up asx_clear_futures_procedures_and_determinations', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'CUR, RUL, PROC', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Ren Masu-ay', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '1900-01-01 00:00:00', 0, '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 6, 1, 0, '-', 'Z:EdProcasxacrService 81Manuscripts1st amendment', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '08_Cancelled', 'ASX supplied wrong files', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(99, 'Tier 1', 'ASXACR 81_1st amndmnt_CUR, RUL, PROC', 'ASXACR', '81', 'Mark Up asx_clear_procedures', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'CUR, RUL, PROC', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Ren Masu-ay', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '1900-01-01 00:00:00', 0, '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 4, 1, 0, '-', 'Z:EdProcasxacrService 81Manuscripts1st amendment', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '08_Cancelled', 'ASX supplied wrong files', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(100, 'Tier 1', 'ASXACR 81_1st amndmnt_ GN, CUR', 'ASXACR', '81', 'markup_asx_clear_guidance_note_13', 'N/A', '1900-01-01 00:00:00', '2022-02-02 00:00:00', 'Ed Mns-Lgt', 'GN, CUR', '1st amndmnt', '2022-02-17 00:00:00', 'Vida Long', ' ', 'Patricia Artajo', '2022-02-02 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-07 00:00:00', '2022-02-07 00:00:00', 6, '2022-02-09 00:00:00', '2022-02-17 00:00:00', '1900-01-01 00:00:00', 5, 1, 11, 'Y', 'Y:EdProcasxacrService 81Manuscripts1st amendment', '07_For XML Edit', 'Commentary', '2022-02-03 00:00:00', '-', 0, '27_Completed – QA Online', '7 Feb: received additional updates for Procedures guidecard, 15 Feb: STP', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(101, 'Tier 1', 'ASXASR 72_1st amndmnt_PROC, CUR', 'ASXASR', '72', 'ASX Settlement Operating Rules, Mark up - e-Statements ASXSOR procedure changes - Final 2021 (watermark removed) (1001362v1)', 'N/A', '1900-01-01 00:00:00', '2021-12-15 00:00:00', 'Other', 'PROC, CUR', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2021-12-15 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-15 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-12-22 00:00:00', '2021-12-28 00:00:00', 6, '2021-12-24 00:00:00', '2022-01-03 00:00:00', '1900-01-01 00:00:00', 6, 1, 13, 'N', '-', '07_For XML Edit', 'Commentary', '2021-12-15 00:00:00', '-', 0, '27_Completed – QA Online', 'Straive: unable to deliver on-time due to Typhoon Odette', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(102, 'Tier 1', 'ASXASR 73_Task 1_SCH', 'ASXASR', '73', 'ASXASR Word Audit', 'N/A', '1900-01-01 00:00:00', '2022-01-24 00:00:00', 'Ed Mns-Lgt', 'SCH', 'Task 1', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-24 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-27 00:00:00', '2022-01-26 00:00:00', 1, '2022-01-31 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-24 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(103, 'Tier 1', 'ASXASR 73_1st amndmnt_PROC, CUR', 'ASXASR', '73', 'ASX Settlement Operating Rules, Mark up', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'PROC, CUR', '1st amndmnt', '2022-02-09 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '2022-02-01 00:00:00', 0, '2022-02-03 00:00:00', '2022-02-09 00:00:00', '1900-01-01 00:00:00', 6, 2, 9, 'Y', 'Z:EdProcasxasrService 73ManuscriptTask 2', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '27_Completed – QA Online', '24 Feb: Received notification of completion from coding', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(104, 'Tier 1', 'ASXAUH hist2020_Oct_29', 'ASXAUH', 'hist2020', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-03 00:00:00', 'Ed Mns-Lgt', '29', 'Oct', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-03 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-08 00:00:00', '2022-02-04 00:00:00', 3, '2022-02-10 00:00:00', '2022-02-10 00:00:00', '1900-01-01 00:00:00', 1, 1, 5, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-03 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(105, 'Tier 1', 'ASXAUH hist2021_Mar_01', 'ASXAUH', 'hist2021', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-03 00:00:00', 'Ed Mns-Lgt', '01', 'Mar', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-03 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-08 00:00:00', '2022-02-04 00:00:00', 3, '2022-02-10 00:00:00', '2022-02-10 00:00:00', '1900-01-01 00:00:00', 1, 1, 5, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-03 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(106, 'Tier 1', 'ASXAUH hist2021_Jul_01', 'ASXAUH', 'hist2021', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-03 00:00:00', 'Ed Mns-Lgt', '01', 'Jul', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-03 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-08 00:00:00', '2022-02-04 00:00:00', 3, '2022-02-10 00:00:00', '2022-02-10 00:00:00', '1900-01-01 00:00:00', 1, 1, 5, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-03 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(107, 'Tier 1', 'ASXAUH hist2021_Sept_15', 'ASXAUH', 'hist2021', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-03 00:00:00', 'Ed Mns-Lgt', '15', 'Sept', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-03 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-08 00:00:00', '2022-02-04 00:00:00', 3, '2022-02-10 00:00:00', '2022-02-10 00:00:00', '1900-01-01 00:00:00', 1, 1, 5, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-03 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(108, 'Tier 1', 'ASXAUH hist2021_Dec_03', 'ASXAUH', 'hist2021', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-03 00:00:00', 'Ed Mns-Lgt', '03', 'Dec', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-03 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-08 00:00:00', '2022-02-04 00:00:00', 3, '2022-02-10 00:00:00', '2022-02-10 00:00:00', '1900-01-01 00:00:00', 1, 1, 5, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-03 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(109, 'Tier 1', 'ASXAUH hist2020_Jul_06', 'ASXAUH', 'hist2020', 'N/A', 'N/A', '1900-01-01 00:00:00', '2022-02-04 00:00:00', 'Ed Mns-Lgt', '06', 'Jul', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-04 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-04 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-09 00:00:00', '2022-02-04 00:00:00', 3, '2022-02-11 00:00:00', '2022-02-10 00:00:00', '1900-01-01 00:00:00', 1, 1, 4, 'Y', 'T:\repositoryasxauhgraphicspdf', '07_For XML Edit', 'Commentary', '2022-02-04 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(110, 'Tier 1', 'ASXAUS 31_Task 1_PROC', 'ASXAUS', '31', 'ASXAUS Word audit', '-', '1900-01-01 00:00:00', '2022-01-24 00:00:00', 'Ed Mns-Lgt', 'PROC', 'Task 1', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-24 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-27 00:00:00', '2022-01-25 00:00:00', 1, '2022-01-31 00:00:00', '2022-01-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 2, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-24 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(111, 'Tier 1', 'ASXAUS 31_1st amndmnt_PROC, CUR', 'ASXAUS', '31', 'Austraclear Regulations, Mark up', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'PROC, CUR', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '2022-02-01 00:00:00', 0, '2022-02-03 00:00:00', '2022-02-03 00:00:00', '1900-01-01 00:00:00', 2, 2, 5, 'Y', 'Z:EdProcasxausService 31ManuscriptsTask 2', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '27_Completed – QA Online', '28 Feb: Approved by PE', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(112, 'Tier 1', 'ASXLRH hist2021_Jul_1', 'ASXLRH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', '1', 'Jul', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-23 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(113, 'Tier 1', 'ASXLRH hist2021_Oct_8', 'ASXLRH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', '8', 'Oct', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-23 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(114, 'Tier 1', 'ASXLRH hist2021_Nov_12', 'ASXLRH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', '12', 'Nov', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-23 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(115, 'Tier 1', 'ASXLRN 70_1st amndmnt_GN, CUR', 'ASXLRN', '70', 'GN, CUR', '-', '1900-01-01 00:00:00', '2021-12-27 00:00:00', 'Other', 'GN, CUR', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2021-12-27 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-12-27 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-03 00:00:00', '2022-01-06 00:00:00', 3, '2022-01-05 00:00:00', '2022-01-06 00:00:00', '1900-01-01 00:00:00', 3, 1, 8, 'N', '-', '07_For XML Edit', 'Commentary', '2021-12-27 00:00:00', '-', 0, '27_Completed – QA Online', 'Straive: task mistakenly tagged as cancelled', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(116, 'Tier 1', 'ASXLRW November_2021_update 1', 'ASXLRW', 'November', 'ASX Listing Rules Waivers_1-15 November 2021', '-', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 'Ed Mns-Lgt', 'update 1', '2021', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-05 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-05 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-10 00:00:00', '2022-01-07 00:00:00', 32, '2022-01-12 00:00:00', '2022-01-10 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-05 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(117, 'Tier 1', 'ASXLRW November_2021_update 2', 'ASXLRW', 'November', 'ASX Listing Rules Waivers_16-30 November 2021', '-', '2022-01-05 00:00:00', '2022-01-05 00:00:00', 'Ed Mns-Lgt', 'update 2', '2021', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-05 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-05 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-10 00:00:00', '2022-01-07 00:00:00', 36, '2022-01-12 00:00:00', '2022-01-10 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-05 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(118, 'Tier 1', 'ASXLRW December_2021_update 1', 'ASXLRW', 'December', 'ASX Listing Rules Waivers_1-15 December 2021', '-', '2022-01-24 00:00:00', '2022-01-24 00:00:00', 'Ed Mns-Lgt', 'update 1', '2021', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-24 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-27 00:00:00', '2022-01-27 00:00:00', 30, '2022-01-31 00:00:00', '2022-01-31 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-24 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(119, 'Tier 1', 'ASXLRW December_2021_update 2', 'ASXLRW', 'December', 'ASX Listing Rules Waivers_16-31 December 2021', 'N/A', '1900-01-01 00:00:00', '2022-01-31 00:00:00', 'Ed Mns-Lgt', 'update 2', '2021', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-31 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-31 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-03 00:00:00', '2022-02-03 00:00:00', 80, '2022-02-07 00:00:00', '2022-02-07 00:00:00', '1900-01-01 00:00:00', 44, 1, 5, 'Y', 'Z:EdProcasxlrw2021Manuscripts', '07_For XML Edit', 'Commentary', '2022-01-31 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1);
INSERT INTO `coversheet_mt` (`CoversheetID`, `CoversheetTier`, `CoversheetName`, `BPSProductID`, `ServiceNumber`, `ManuscriptFile`, `LatupAttribution`, `DateReceivedFromAuthor`, `DateEnteredIntoTracker`, `UpdateType`, `GuideCard`, `TaskNumber`, `RevisedOnlineDueDate`, `DepositedBy`, `LEInstructions`, `PickUpBy`, `PickUpDate`, `QABy`, `QADate`, `QACompletionDate`, `QueryLog`, `QueryForApprovalStartDate`, `QueryForApprovalEndDate`, `QueryForApprovalAge`, `Process`, `PETargetCompletion`, `LatupTargetCompletion`, `EndingDueDate`, `PEActualCompletion`, `CodingDueDate`, `CodingActualCompletion`, `ActualPages`, `OnlineDueDate`, `OnlineActualCompletion`, `LNRedCheckingActualCompletion`, `AffectedPages`, `NoOfMSSFile`, `ActualTAT`, `BenchmarkMET`, `FilePath`, `PEStatus`, `TaskType`, `TaskReadyDate`, `PDFQA_PE`, `QMSID`, `CodingStatus`, `CoversheetRemarks`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(120, 'Tier 1', 'ASXLRW January_2022_update 1', 'ASXLRW', 'January', 'ASX Listing Rules Waivers_1-15 January 2022', '-', '1900-01-01 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', 'update 1', '2022', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-24 00:00:00', 13, '2022-03-01 00:00:00', '2022-02-28 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(121, 'Tier 1', 'ASXLRW January_2022_update 2', 'ASXLRW', 'January', 'ASX Listing Rules Waivers_16-31 January 2022', '-', '1900-01-01 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', 'update 2', '2022', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-24 00:00:00', 17, '2022-03-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(122, 'Tier 1', 'ASXMR 71_1st amndmnt_ORAPP, PRNEW, CUR', 'ASXMR', '71', 'Mark Up asx_or_appendices, Mark Up asx_or_procedures, Currency', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'ORAPP, PRNEW, CUR', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Patricia Artajo', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '1900-01-01 00:00:00', 0, '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 30, 3, 0, '-', 'Y:EdProcasxmrService 71Manuscript1st amendment', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '08_Cancelled', 'ASX supplied wrong files', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(123, 'Tier 1', 'ASXMR 71_Task 3_CURR, ORAPP, PRNEW', 'ASXMR', '71', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-15 00:00:00', 'ASX', 'CURR, ORAPP, PRNEW', 'Task 3', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-15 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-15 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-18 00:00:00', '2022-02-18 00:00:00', 25, '2022-02-22 00:00:00', '2022-02-21 00:00:00', '1900-01-01 00:00:00', 20, 3, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-15 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(124, '-', 'ASXMRH hist2020_Sept_29', 'ASXMRH', 'hist2020', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', '29', 'Sept', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-23 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(125, '-', 'ASXMRH hist2020_Dec_3', 'ASXMRH', 'hist2020', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', '3', 'Dec', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-23 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(126, '-', 'ASXMRH hist2021_May_7', 'ASXMRH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', '7', 'May', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-23 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(127, '-', 'ASXMRH hist2021_Sept_22', 'ASXMRH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-02-21 00:00:00', 'Ed Mns-Lgt', '22', 'Sept', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-21 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-21 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-24 00:00:00', '2022-02-23 00:00:00', 3, '2022-02-28 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 4, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-21 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(128, 'Tier 1', 'ASXSC 63_Task 1_Schedules', 'ASXSC', '63', 'ASXSC Word audit', 'N/A', '1900-01-01 00:00:00', '2022-01-24 00:00:00', 'Ed Mns-Lgt', 'Schedules', 'Task 1', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-24 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-24 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-27 00:00:00', '2022-01-25 00:00:00', 1, '2022-01-31 00:00:00', '2022-01-26 00:00:00', '1900-01-01 00:00:00', 1, 1, 2, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-24 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(129, 'Tier 1', 'ASXSC 63_1st amndmnt_RUL, PROC, OTCRULES, CUR', 'ASXSC', '63', 'ASX Clear (Futures) Operating Rules, Procedures Determinations and Practice Notes, ASX OTC RULEBOOK, Currency', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'RUL, PROC, OTCRULES, CUR', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Patricia Artajo', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '1900-01-01 00:00:00', 0, '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 33, 6, 0, '-', 'Y:EdProcasxscService 63Manuscript1st amendment', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '08_Cancelled', 'ASX supplied wrong files', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(130, '-', 'ASXSCH hist2020_Jul_06', 'ASXSCH', 'hist2020', '-', 'N/A', '2022-02-22 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', '06', 'Jul', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-23 00:00:00', 3, '2022-03-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(131, '-', 'ASXSCH hist2020_Oct_29', 'ASXSCH', 'hist2020', '-', 'N/A', '2022-02-22 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', '29', 'Oct', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-23 00:00:00', 3, '2022-03-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(132, '-', 'ASXSCH hist2021_Apr_12', 'ASXSCH', 'hist2021', '-', 'N/A', '2022-02-22 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', '12', 'Apr', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-23 00:00:00', 3, '2022-03-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(133, '-', 'ASXSCH hist2021_Oct_04', 'ASXSCH', 'hist2021', '-', 'N/A', '2022-02-22 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', '04', 'Oct', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-23 00:00:00', 3, '2022-03-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(134, '-', 'ASXSCH hist2021_Nov_29', 'ASXSCH', 'hist2021', '-', 'N/A', '2022-02-22 00:00:00', '2022-02-22 00:00:00', 'Ed Mns-Lgt', '29', 'Nov', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-22 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-22 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-25 00:00:00', '2022-02-23 00:00:00', 3, '2022-03-01 00:00:00', '2022-02-26 00:00:00', '1900-01-01 00:00:00', 0, 1, 3, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-22 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(135, 'Tier 1', 'ASXSOH hist-2020_Aug_18', 'ASXSOH', 'hist-2020', '-', 'N/A', '1900-01-01 00:00:00', '2022-01-26 00:00:00', 'Ed Mns-Lgt', '18', 'Aug', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-26 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(136, 'Tier 1', 'ASXSOH hist-2020_Nov_30', 'ASXSOH', 'hist-2020', '-', 'N/A', '1900-01-01 00:00:00', '2022-01-26 00:00:00', 'Ed Mns-Lgt', '30', 'Nov', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-26 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(137, 'Tier 1', 'ASXSOH hist2021_Mar_22', 'ASXSOH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-01-26 00:00:00', 'Ed Mns-Lgt', '22', 'Mar', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-26 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(138, 'Tier 1', 'ASXSOH hist2021_Apr_09', 'ASXSOH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-01-26 00:00:00', 'Ed Mns-Lgt', '09', 'Apr', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-26 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(139, 'Tier 1', 'ASXSOH hist2021_Jun_07', 'ASXSOH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-01-26 00:00:00', 'Ed Mns-Lgt', '07', 'Jun', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-26 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(140, 'Tier 1', 'ASXSOH hist2021_Oct_01', 'ASXSOH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-01-26 00:00:00', 'Ed Mns-Lgt', '01', 'Oct', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-26 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(141, 'Tier 1', 'ASXSOH hist2021_Oct_15', 'ASXSOH', 'hist2021', '-', 'N/A', '1900-01-01 00:00:00', '2022-01-26 00:00:00', 'Ed Mns-Lgt', '15', 'Oct', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-26 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-01-31 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-02 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 0, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(142, 'Tier 1', 'ASXSOH hist2021_Aug_correction', 'ASXSOH', 'hist2021', 'Correction', 'N/A', '1900-01-01 00:00:00', '2022-01-31 00:00:00', 'Ed Mns-Lgt', 'correction', 'Aug', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-31 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-31 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-03 00:00:00', '2022-01-31 00:00:00', 3, '2022-02-07 00:00:00', '2022-02-02 00:00:00', '1900-01-01 00:00:00', 1, 1, 2, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-01-31 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(143, 'Tier 1', 'ASXSOR 99_1st amdnmt_S4, Currency', 'ASXSOR', '99', 'mark_up_asx_24_section_04', '-', '2021-11-15 00:00:00', '2021-11-16 00:00:00', 'Manus-Light', 'S4, Currency', '1st amdnmt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Ren Masu-ay', '2021-11-16 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-11-16 00:00:00', '2021-11-16 00:00:00', '2021-11-22 00:00:00', '1900-01-01 00:00:00', '2021-11-25 00:00:00', '2021-11-23 00:00:00', 0, '2021-11-29 00:00:00', '2021-11-26 00:00:00', '1900-01-01 00:00:00', 2, 1, 8, 'Y', 'Z:EdProcasxsorService_99Manuscript1st amendment', '07_For XML Edit', 'Commentary', '2021-11-16 00:00:00', 'not included in QMS', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(144, 'Tier 1', 'ASXSOR 99_2nd amdnmt_S3, Currency', 'ASXSOR', '99', 'mark_up_asx_24_section_3', '-', '2021-11-17 00:00:00', '2021-11-17 00:00:00', 'Other', 'S3, Currency', '2nd amdnmt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Patricia Artajo', '2021-11-17 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2021-11-17 00:00:00', '2021-11-17 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-11-24 00:00:00', '2021-11-23 00:00:00', 0, '2021-11-26 00:00:00', '2021-11-26 00:00:00', '1900-01-01 00:00:00', 4, 2, 7, 'Y', 'Y:EdProcasxsorService_99Manuscript2nd amendment', '07_For XML Edit', 'Commentary', '2021-11-18 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(145, 'Tier 1', 'ASXSOR 100_1st amndmnt_PRNEW, CUR', 'ASXSOR', '100', 'ASX 24 Operating Rules, mark up', 'N/A', '1900-01-01 00:00:00', '2022-01-27 00:00:00', 'Ed Mns-Lgt', 'PRNEW, CUR', '1st amndmnt', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-01-28 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 'N/A', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-01-28 00:00:00', '2022-01-28 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-01 00:00:00', '1900-01-01 00:00:00', 0, '2022-02-03 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 20, 5, 0, '-', 'Z:EdProcasxsorService_100ManuscriptTask 1', '07_For XML Edit', 'Commentary', '2022-01-28 00:00:00', '-', 0, '08_Cancelled', 'ASX supplied wrong files', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(146, 'Tier 1', 'ASXSOR 100_Task 2_PRNEW, CUR', 'ASXSOR', '100', 'ASX 24 Operating Rules', 'N/A', '1900-01-01 00:00:00', '2022-02-09 00:00:00', 'ASX', 'PRNEW, CUR', 'Task 2', '1900-01-01 00:00:00', 'Vida Long', '-', 'Chelsea Mercado', '2022-02-09 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For tasking', '2022-02-09 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2022-02-14 00:00:00', '2022-02-14 00:00:00', 20, '2022-02-16 00:00:00', '2022-02-16 00:00:00', '1900-01-01 00:00:00', 0, 5, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2022-02-09 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(147, 'Tier 3', 'AUE 15_Task 7_Australian Uniform Evidence', 'AUE', '15', 'correction aue', '-', '2021-05-26 00:00:00', '2021-05-26 00:00:00', 'Other', 'Australian Uniform Evidence', 'Task 7', '1900-01-01 00:00:00', 'Andrew Badaoui', '-', 'Laiza Remotin', '2021-05-26 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For Tasking', '2021-05-26 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '2021-06-02 00:00:00', '2021-06-01 00:00:00', 7, '2021-06-04 00:00:00', '2021-06-02 00:00:00', '1900-01-01 00:00:00', 2, 1, 5, 'Y', '-', '07_For XML Edit', 'Commentary', '2021-05-26 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(148, 'Tier 3', 'AUE 15_Task 8_Australian Uniform Evidence', 'AUE', '15', 'Chapter 1', 'John K. Arthur', '2021-04-18 00:00:00', '2021-05-24 00:00:00', 'Manus-Heavy', 'Australian Uniform Evidence', 'Task 8', '1900-01-01 00:00:00', 'Andrew Badaoui', '-', 'Laiza Remotin', '2021-06-07 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For Tasking', '2021-06-07 00:00:00', '2021-06-07 00:00:00', '2021-06-10 00:00:00', '1900-01-01 00:00:00', '2021-06-24 00:00:00', '2021-06-26 00:00:00', 15, '2021-06-28 00:00:00', '2021-06-28 00:00:00', '1900-01-01 00:00:00', 50, 7, 25, 'Y', 'Y:EdProcaueServicesService 15ManuscriptsRawTask 8', '07_For XML Edit', 'Commentary', '2021-06-07 00:00:00', '-', 0, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(149, 'Tier 3', 'AUE 15_Task 10_CML, LATUP', 'AUE', '15', 'Pt 2.1', 'John K. Arthur', '2021-08-30 00:00:00', '2021-08-30 00:00:00', 'Manus-Light', 'CML, LATUP', 'Task 10', '1900-01-01 00:00:00', 'Andrew Badaoui', '-', 'Patricia Artajo', '2021-09-03 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-09-01 00:00:00', '2021-09-03 00:00:00', '2021-09-03 00:00:00', '2021-09-03 00:00:00', '2021-09-08 00:00:00', '2021-09-09 00:00:00', 0, '2021-09-10 00:00:00', '2021-09-10 00:00:00', '1900-01-01 00:00:00', 12, 1, 9, 'Y', 'Y:EdProcaueServicesService 15ManuscriptsEditedTask 10', '07_For XML Edit', 'Commentary', '2021-09-06 00:00:00', '-', 802859, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(150, 'Tier 3', 'AUE 15_Task 11_CML, LATUP', 'AUE', '15', 'Part 2.1', 'John K. Arthur', '2021-11-01 00:00:00', '2021-11-01 00:00:00', 'Manus-Medium', 'CML, LATUP', 'Task 11', '2021-11-25 00:00:00', 'Andrew Badaoui', '-', 'Patricia Artajo', '2021-11-09 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2021-11-10 00:00:00', '2021-11-10 00:00:00', '2021-11-11 00:00:00', '2021-11-10 00:00:00', '2021-11-18 00:00:00', '2021-11-20 00:00:00', 11, '2021-11-22 00:00:00', '2021-11-24 00:00:00', '1900-01-01 00:00:00', 13, 1, 17, 'Y', 'Y:EdProcaueServicesService 15ManuscriptsEditedTask 11', '07_For XML Edit', 'Commentary', '2021-11-10 00:00:00', '-', 852891, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(151, 'Tier 3', 'AUE 15_Task 12_CML, LATUP', 'AUE', '15', 'Various', 'John K. Arthur', '2022-01-04 00:00:00', '2022-01-04 00:00:00', 'Manus-Medium', 'CML, LATUP', 'Task 12', '1900-01-01 00:00:00', 'Andrew Badaoui', 'N/A', 'Mark Grande', '2022-01-04 00:00:00', 'Laiza Remotin', '2022-01-07 00:00:00', '1900-01-01 00:00:00', '-', '1900-01-01 00:00:00', '1900-01-01 00:00:00', 0, 'For copyediting', '2022-01-14 00:00:00', '2022-01-14 00:00:00', '2022-01-14 00:00:00', '2022-01-14 00:00:00', '2022-01-21 00:00:00', '2022-01-21 00:00:00', 40, '2022-01-25 00:00:00', '2022-01-24 00:00:00', '1900-01-01 00:00:00', 87, 1, 14, 'Y', 'Y:EdProcaueServicesService 15ManuscriptsEditedTask 12', '07_For XML Edit', 'Commentary', '2022-01-14 00:00:00', '-', 885452, '27_Completed – QA Online', '-', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `descriptiontb`
--

CREATE TABLE `descriptiontb` (
  `DescriptionID` int(11) NOT NULL,
  `Description` longtext DEFAULT NULL,
  `ProjectID` int(11) DEFAULT NULL,
  `TimeSheetMasterID` int(11) DEFAULT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `UserID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `DocumentID` int(11) NOT NULL,
  `DocumentName` longtext DEFAULT NULL,
  `DocumentBytes` longblob DEFAULT NULL,
  `UserID` int(11) NOT NULL,
  `CreatedOn` datetime(3) NOT NULL,
  `ExpenseID` int(11) NOT NULL,
  `DocumentType` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `EmployeeID` int(11) NOT NULL,
  `UserAccessID` int(11) NOT NULL,
  `CreatedDate` datetime NOT NULL,
  `UserName` varchar(45) NOT NULL,
  `Password` varchar(200) NOT NULL,
  `FirstName` varchar(150) NOT NULL,
  `LastName` varchar(150) NOT NULL,
  `EmailAddress` varchar(100) NOT NULL,
  `IsManager` smallint(6) NOT NULL DEFAULT 0,
  `IsEditorialContact` smallint(6) NOT NULL DEFAULT 0,
  `IsEmailList` smallint(6) NOT NULL DEFAULT 0,
  `IsMandatoryRecepient` smallint(6) NOT NULL DEFAULT 0,
  `IsShowUser` smallint(6) NOT NULL DEFAULT 0,
  `PasswordUpdateDate` datetime NOT NULL,
  `FullName` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`EmployeeID`, `UserAccessID`, `CreatedDate`, `UserName`, `Password`, `FirstName`, `LastName`, `EmailAddress`, `IsManager`, `IsEditorialContact`, `IsEmailList`, `IsMandatoryRecepient`, `IsShowUser`, `PasswordUpdateDate`, `FullName`) VALUES
(1, 1, '2022-02-25 00:00:00', 'admin', 'admin', 'Admin', 'Admin', 'Admin@sample.com', 1, 1, 1, 1, 1, '2022-02-25 00:00:00', 'Admin, Admin'),
(2, 2, '2021-12-15 00:00:00', 'LE', 'LE', 'LE', 'LE', 'LE@sample.com', 0, 1, 1, 1, 1, '2021-12-15 00:00:00', 'LE, LE'),
(3, 3, '2021-12-15 00:00:00', 'PE', 'PE', 'PE', 'PE', 'PE@sample.com', 0, 1, 1, 1, 1, '2021-12-15 00:00:00', 'PE, PE'),
(4, 5, '2022-03-04 08:23:23', 'Coding', 'Coding', 'Coding', 'Coding', 'Coding@sample.com', 0, 1, 1, 1, 1, '2022-03-04 08:23:23', 'Coding, Coding'),
(5, 7, '2022-03-04 09:16:00', 'CodingSTP', 'CodingSTP', 'CodingSTP', 'CodingSTP', 'CodingSTP@sample.com', 0, 1, 1, 1, 1, '2022-03-04 09:16:00', 'CodingSTP, CodingSTP'),
(6, 2, '2021-12-15 00:00:00', 'LE1', 'LE1', 'LE1', 'LE1', 'LE1@sample.com', 0, 1, 1, 1, 1, '2021-12-15 00:00:00', 'LE1, LE1'),
(7, 4, '2022-02-25 00:00:00', 'CodingTL', 'CodingTL', 'CodingTL', 'CodingTL', 'CodingTL@sample.com', 0, 1, 1, 1, 1, '2022-02-25 00:00:00', 'CodingTL, CodingTL');

-- --------------------------------------------------------

--
-- Table structure for table `expense`
--

CREATE TABLE `expense` (
  `ExpenseID` int(11) NOT NULL,
  `ProjectID` int(11) NOT NULL,
  `PurposeorReason` longtext NOT NULL,
  `ExpenseStatus` int(11) NOT NULL,
  `FromDate` datetime(3) NOT NULL,
  `ToDate` datetime(3) NOT NULL,
  `UserID` int(11) NOT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `VoucherID` longtext DEFAULT NULL,
  `HotelBills` int(11) DEFAULT NULL,
  `TravelBills` int(11) DEFAULT NULL,
  `MealsBills` int(11) DEFAULT NULL,
  `LandLineBills` int(11) DEFAULT NULL,
  `TransportBills` int(11) DEFAULT NULL,
  `MobileBills` int(11) DEFAULT NULL,
  `Miscellaneous` int(11) DEFAULT NULL,
  `TotalAmount` int(11) DEFAULT NULL,
  `Comment` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expenseaudittb`
--

CREATE TABLE `expenseaudittb` (
  `ApprovaExpenselLogID` int(11) NOT NULL,
  `ApprovalUser` int(11) NOT NULL,
  `ProcessedDate` datetime(3) DEFAULT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `Comment` longtext DEFAULT NULL,
  `Status` int(11) NOT NULL,
  `ExpenseID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job`
--

CREATE TABLE `job` (
  `ID` int(11) NOT NULL,
  `JobStatusID` int(11) NOT NULL,
  `OwnerUserID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `UpdateTypeID` int(11) NOT NULL,
  `ServiceNo` int(11) NOT NULL,
  `DateCreated` datetime NOT NULL,
  `DateReceivedFromAuthor` datetime NOT NULL,
  `ManuscriptTitle` varchar(45) NOT NULL,
  `LatupAttribution` varchar(45) NOT NULL,
  `JobSpecificInstruction` varchar(150) NOT NULL,
  `JobSpecificInstructionPath` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobcoversheetdata`
--

CREATE TABLE `jobcoversheetdata` (
  `JobCoversheetID` int(11) NOT NULL,
  `CoversheetTier` varchar(50) DEFAULT NULL,
  `BPSProductID` varchar(10) NOT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `TargetPressDate` datetime DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `LatestTaskNumber` varchar(100) DEFAULT NULL,
  `CodingStatus` varchar(500) DEFAULT NULL,
  `PDFQAStatus` varchar(500) DEFAULT NULL,
  `OnlineStatus` varchar(500) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `jobcoversheetdata`
--

INSERT INTO `jobcoversheetdata` (`JobCoversheetID`, `CoversheetTier`, `BPSProductID`, `ServiceNumber`, `TargetPressDate`, `ActualPressDate`, `LatestTaskNumber`, `CodingStatus`, `PDFQAStatus`, `OnlineStatus`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 'Tier 2', 'ABCA', '37', '2022-03-10 00:00:00', NULL, '1', 'Completed', 'Completed', 'New', '2022-07-28 18:31:15', 3, '2022-12-14 07:06:11', 28),
(2, 'Tier 3', 'ABCE', '71', '2022-03-25 00:00:00', NULL, '1', 'Completed', 'On-Going', 'New', '2022-07-28 20:13:15', 3, '2022-09-30 22:33:36', 7),
(3, 'Tier 3', 'BC', '61', '2022-02-16 00:00:00', NULL, '1', 'Completed', 'Completed', 'Completed', '2022-07-29 14:58:52', 3, '2022-09-30 22:33:36', 7),
(4, 'Tier 3', 'BC', '62', '2022-07-13 00:00:00', NULL, '1', 'Completed', 'Completed', 'New', '2022-07-29 16:37:36', 3, '2022-09-30 22:33:36', 7),
(9, 'Tier 2', 'DEF', '91', '2021-05-13 00:00:00', NULL, 'Task3', 'Completed', 'Completed', 'Completed', '2022-08-08 14:30:34', 28, '2022-10-03 00:13:17', 28),
(10, 'Tier 2', 'DEF', '92', '2021-08-12 00:00:00', NULL, '2', 'New', 'New', 'New', '2022-08-08 14:57:54', 28, '2022-08-08 14:57:54', 28),
(11, 'Tier 3', 'PL', '91', '2021-07-15 00:00:00', NULL, 'Task2', 'New', 'New', 'New', '2022-08-23 15:50:10', 28, '2022-08-23 15:50:10', 28),
(12, 'Tier 1', 'IPC', '160', '2021-06-29 00:00:00', NULL, 'Task2', 'New', 'New', 'New', '2022-09-19 17:38:49', 28, '2022-09-19 17:38:49', 28),
(13, 'Tier 3', 'PL', '92', '2021-10-14 00:00:00', NULL, 'Task2', 'New', 'New', 'New', '2022-09-23 16:36:28', 28, '2022-09-23 16:36:28', 28),
(14, 'Tier 3', 'CIV', '51', '2021-11-27 00:00:00', NULL, 'Task3', 'Completed', 'Completed', 'Completed', '2022-10-24 02:32:10', 27, '2022-10-24 14:32:04', 27),
(15, 'Tier 1', 'PEV', '241', '2021-11-26 00:00:00', NULL, 'Task8', 'Completed', 'Completed', 'Completed', '2022-10-24 20:30:29', 26, '2022-11-04 14:29:48', 26),
(16, 'Tier 3', 'FRAN', '68', '2021-10-25 00:00:00', NULL, 'Task3', 'Completed', 'On-Going', 'New', '2022-11-22 00:13:54', 28, '2023-02-17 15:02:13', 32),
(17, 'Tier 1', 'CLSA', '192', '2021-12-06 00:00:00', NULL, 'Task1', 'New', 'New', 'New', '2022-11-28 13:21:09', 23, '2022-11-28 13:21:09', 23),
(18, 'Tier 3', 'BC', '60', '2021-10-01 00:00:00', NULL, 'Task3', 'On-Going', 'New', 'New', '2022-12-09 19:13:29', 30, '2022-12-09 20:38:52', 7),
(19, 'Tier 2', 'MTN', '183', '2021-11-24 00:00:00', NULL, 'Task1', 'New', 'New', 'New', '2022-12-12 15:37:49', 28, '2022-12-12 15:37:49', 28),
(20, 'Tier 2', 'CPACT', '132', '2021-11-05 00:00:00', NULL, 'Task1', 'New', 'New', 'New', '2022-12-13 13:57:16', 28, '2022-12-13 13:57:16', 28),
(21, 'Tier 1', 'IPC', '159', '2021-03-30 00:00:00', NULL, 'Task1', 'New', 'New', 'New', '2022-12-13 14:03:52', 28, '2022-12-13 14:03:52', 28),
(22, 'Tier 2', 'ACTD', '85', '2021-10-29 00:00:00', NULL, 'Task1', 'New', 'New', 'New', '2023-01-05 07:21:19', 28, '2023-01-05 07:21:19', 28),
(23, 'Tier 3', 'CIV', '49', '2021-05-28 00:00:00', NULL, 'Task1', 'Completed', 'Completed', 'Completed', '2023-01-10 16:06:56', 27, '2023-03-01 15:39:02', 27),
(24, 'Tier 3', 'ABCE', '68', '2021-02-26 00:00:00', NULL, 'Task1', 'Completed', 'Completed', 'Completed', '2023-03-01 20:51:09', 24, '2023-03-01 21:02:16', 24);

-- --------------------------------------------------------

--
-- Table structure for table `jobdata`
--

CREATE TABLE `jobdata` (
  `JobID` int(11) NOT NULL,
  `JobNumber` int(8) UNSIGNED ZEROFILL DEFAULT NULL,
  `ManuscriptTier` varchar(50) DEFAULT NULL,
  `BPSProductID` varchar(10) NOT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `TargetPressDate` datetime DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `CopyEditStatus` varchar(500) DEFAULT NULL,
  `CodingStatus` varchar(500) DEFAULT NULL,
  `OnlineStatus` varchar(500) DEFAULT NULL,
  `STPStatus` varchar(500) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `jobdata`
--

INSERT INTO `jobdata` (`JobID`, `JobNumber`, `ManuscriptTier`, `BPSProductID`, `ServiceNumber`, `TargetPressDate`, `ActualPressDate`, `CopyEditStatus`, `CodingStatus`, `OnlineStatus`, `STPStatus`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 00000001, 'Tier 2', 'ABCA', '37', '2022-03-10 00:00:00', NULL, 'Completed', 'Completed', 'New', 'New', '2022-07-28 18:24:34', 8, '2022-08-01 13:02:21', 4),
(2, 00000002, 'Tier 3', 'ABCE', '71', '2022-03-25 00:00:00', NULL, 'Completed', 'Completed', 'New', 'New', '2022-07-28 20:03:48', 2, '2022-08-01 13:02:21', 4),
(3, 00000003, 'Tier 3', 'BC', '61', '2022-02-16 00:00:00', NULL, 'Completed', 'Completed', 'Completed', 'New', '2022-07-29 14:54:51', 2, '2022-09-30 22:33:36', 7),
(4, 00000004, 'Tier 3', 'BC', '62', '2022-07-13 00:00:00', NULL, 'Completed', 'Completed', 'New', 'New', '2022-07-29 16:35:57', 2, '2022-08-01 13:02:21', 5),
(5, 00000005, 'Tier 3', 'BC', '63', '2022-09-28 00:00:00', NULL, 'New', 'New', 'New', 'New', '2022-08-03 09:22:00', 2, '2022-08-03 09:22:00', 2),
(6, 00000006, 'Tier 2', 'DEF', '91', '2021-05-13 00:00:00', NULL, 'On-Going', 'Completed', 'Completed', 'Completed', '2022-08-03 19:26:14', 8, '2022-10-21 19:56:00', 33),
(7, 00000007, 'Tier 2', 'DEF', '92', '2021-08-12 00:00:00', NULL, 'Completed', 'New', 'New', 'New', '2022-08-08 14:53:13', 8, '2022-08-08 15:12:46', 28),
(8, 00000008, 'Tier 3', 'PL', '90', '2021-05-04 00:00:00', NULL, 'Completed', 'New', 'New', 'New', '2022-08-16 15:25:12', 8, '2022-08-30 16:04:36', 28),
(9, 00000009, 'Tier 3', 'PL', '91', '2021-07-15 00:00:00', NULL, 'Completed', 'New', 'New', 'New', '2022-08-16 15:48:03', 8, '2022-09-22 06:46:35', 28),
(12, 00000012, 'Tier 1', 'IPC', '158', '2021-03-30 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2022-08-30 15:34:05', 8, '2022-08-30 15:34:05', 8),
(13, 00000013, 'Tier 1', 'IPC', '159', '2021-03-30 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2022-08-30 15:42:20', 8, '2022-08-30 15:42:20', 8),
(14, 00000014, 'Tier 1', 'IPC', '160', '2021-06-29 00:00:00', NULL, 'Completed', 'New', 'New', 'New', '2022-08-30 15:43:15', 8, '2022-09-22 06:30:26', 28),
(15, 00000015, 'Tier 3', 'PL', '92', '2021-10-14 00:00:00', NULL, 'Completed', 'New', 'New', 'New', '2022-09-23 16:34:28', 8, '2022-09-23 16:41:01', 28),
(16, 00000016, 'Tier 3', 'CIV', '51', '2021-11-27 00:00:00', NULL, 'New', 'Completed', 'Completed', 'On-Going', '2022-10-24 02:14:38', 10, '2022-10-24 17:16:19', 27),
(17, 00000017, 'Tier 3', 'CIV', '50', '2021-08-20 00:00:00', NULL, 'New', 'New', 'New', 'New', '2022-10-24 02:15:23', 10, '2022-10-24 02:15:23', 10),
(18, 00000018, 'Tier 1', 'PEV', '241', '2021-11-26 00:00:00', NULL, 'New', 'Completed', 'Completed', 'Completed', '2022-10-24 19:20:36', 14, '2023-01-10 16:25:55', 42),
(19, 00000019, 'Tier 1', 'CLSA', '192', '2021-12-06 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2022-11-18 15:37:31', 17, '2022-11-28 11:36:27', 17),
(20, 00000020, 'Newsletter', 'AER', '36.7', '2021-12-13 00:00:00', NULL, 'New', 'New', 'New', 'New', '2022-11-21 13:52:32', 17, '2022-11-21 13:52:37', 17),
(21, 00000021, 'Tier 3', 'FRAN', '68', '2021-10-25 00:00:00', NULL, 'New', 'Completed', 'New', 'New', '2022-11-21 16:22:30', 10, '2023-02-17 15:01:31', 32),
(22, 00000022, 'Tier 3', 'BC', '60', '2021-10-01 00:00:00', NULL, 'New', 'On-Going', 'New', 'New', '2022-12-09 17:59:59', 13, '2022-12-09 20:38:52', 7),
(23, 00000023, 'Newsletter', 'HLB', '29.9', '2021-10-08 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2022-12-12 14:00:49', 17, '2022-12-12 14:00:52', 17),
(24, 00000024, 'Tier 2', 'MTN', '183', '2021-11-24 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2022-12-12 14:04:47', 9, '2022-12-12 14:04:47', 9),
(25, 00000025, 'Tier 3', 'PIC', '28', '2021-11-04 00:00:00', NULL, 'New', 'New', 'New', 'New', '2022-12-12 15:12:09', 15, '2022-12-12 15:12:38', 15),
(26, 00000026, 'Tier 2', 'CFN', '162', '2021-10-15 00:00:00', NULL, 'New', 'New', 'New', 'New', '2022-12-12 15:22:16', 15, '2022-12-12 15:22:16', 15),
(27, 00000027, 'Tier 2', 'CPACT', '132', '2021-11-05 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2022-12-13 13:50:24', 9, '2022-12-13 13:50:24', 9),
(28, 00000028, 'Tier 2', 'ACTD', '85', '2021-10-29 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2023-01-05 07:08:03', 9, '2023-01-05 07:08:03', 9),
(29, 00000029, 'Tier 1', 'CLWA', '213', '2021-11-25 00:00:00', NULL, 'Not Applicable', 'New', 'New', 'New', '2023-01-05 07:17:21', 9, '2023-01-05 07:17:44', 9),
(30, 00000030, 'Tier 3', 'CIV', '49', '2021-05-28 00:00:00', NULL, 'New', 'Completed', 'Completed', 'New', '2023-01-10 15:58:44', 10, '2023-03-01 15:39:02', 27),
(31, 00000031, 'Tier 3', 'ABCE', '68', '2021-02-26 00:00:00', NULL, 'New', 'Completed', 'Completed', 'New', '2023-03-01 20:42:01', 16, '2023-03-01 21:02:16', 24);

-- --------------------------------------------------------

--
-- Table structure for table `jobhistory`
--

CREATE TABLE `jobhistory` (
  `ID` int(11) NOT NULL,
  `JobID` int(11) NOT NULL,
  `TransactionDetail` varchar(200) NOT NULL,
  `OldValuesDetail` varchar(200) NOT NULL,
  `TransactionDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobstatus_mt`
--

CREATE TABLE `jobstatus_mt` (
  `ID` int(11) NOT NULL,
  `StatusTitle` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `jobstatus_mt`
--

INSERT INTO `jobstatus_mt` (`ID`, `StatusTitle`) VALUES
(1, 'New'),
(2, 'Ongoing'),
(3, 'Completed'),
(4, 'Closed');

-- --------------------------------------------------------

--
-- Table structure for table `legislation`
--

CREATE TABLE `legislation` (
  `ID` int(11) NOT NULL,
  `UpdateTypeID` int(11) NOT NULL,
  `PrincipalLegislation` varchar(100) NOT NULL,
  `CommencementDate` datetime NOT NULL,
  `Publication` varchar(100) NOT NULL,
  `ServiceNo` int(11) NOT NULL,
  `GuideCard` varchar(100) NOT NULL,
  `TotalOutput` int(11) NOT NULL,
  `EditActualDate` datetime NOT NULL,
  `OnlineActualDueDate` datetime NOT NULL,
  `Status` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `legislationdata`
--

CREATE TABLE `legislationdata` (
  `LegislationID` int(11) NOT NULL,
  `LLE2E` varchar(1000) DEFAULT NULL,
  `DateEntered` datetime DEFAULT NULL,
  `Editor` varchar(1000) DEFAULT NULL,
  `QAEditor` varchar(1000) DEFAULT NULL,
  `PrincipalLegislation` varchar(1000) DEFAULT NULL,
  `AmendingLegislation` varchar(1000) DEFAULT NULL,
  `CommencementDate` date DEFAULT NULL,
  `LegislationComment` varchar(1000) DEFAULT NULL,
  `AssentDate` date DEFAULT NULL,
  `AffectedProvisions` varchar(1000) DEFAULT NULL,
  `UpdateType` varchar(1000) DEFAULT NULL,
  `Tier` varchar(1000) DEFAULT NULL,
  `Publication` varchar(1000) DEFAULT NULL,
  `ServiceNumber` varchar(1000) DEFAULT NULL,
  `GuideCard` varchar(1000) DEFAULT NULL,
  `Jurisdiction` varchar(1000) DEFAULT NULL,
  `TotalOutput` int(11) DEFAULT NULL,
  `ActualEDTOutput` int(11) DEFAULT NULL,
  `Latup` int(11) DEFAULT NULL,
  `CNTsAlpha` int(11) DEFAULT NULL,
  `GraphicsWord` int(11) DEFAULT NULL,
  `GraphicsPDF` int(11) DEFAULT NULL,
  `GraphicsOTP` int(11) DEFAULT NULL,
  `ActualOnlineOutput` int(11) DEFAULT NULL,
  `JobIDs` varchar(1000) DEFAULT NULL,
  `EDTTargetCompletionDate` date DEFAULT NULL,
  `EDTActualDate` date DEFAULT NULL,
  `QCDate` date DEFAULT NULL,
  `DateInitiatedOnline` date DEFAULT NULL,
  `OnlineCheckingDate` date DEFAULT NULL,
  `RevisedOnlineDueDate` date DEFAULT NULL,
  `OnlineActualDueDate` date DEFAULT NULL,
  `BenchmarkMet` varchar(1000) DEFAULT NULL,
  `ProposedDate` date DEFAULT NULL,
  `ActualQAOnlineDate` date DEFAULT NULL,
  `LegislationStatus` varchar(1000) DEFAULT NULL,
  `Stage` varchar(1000) DEFAULT NULL,
  `StatusCategory` varchar(1000) DEFAULT NULL,
  `OnTrackOffTrack` varchar(1000) DEFAULT NULL,
  `ReasonForDelay` varchar(1000) DEFAULT NULL,
  `StartDateOnHold` varchar(1000) DEFAULT NULL,
  `PostbackToStableDate` date DEFAULT NULL,
  `TargetPressDate` date DEFAULT NULL,
  `SSLRServices` varchar(1000) DEFAULT NULL,
  `JiraTickets` varchar(1000) DEFAULT NULL,
  `LegislationRemarks` varchar(1000) DEFAULT NULL,
  `isBilled` varchar(100) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `legislationdata`
--

INSERT INTO `legislationdata` (`LegislationID`, `LLE2E`, `DateEntered`, `Editor`, `QAEditor`, `PrincipalLegislation`, `AmendingLegislation`, `CommencementDate`, `LegislationComment`, `AssentDate`, `AffectedProvisions`, `UpdateType`, `Tier`, `Publication`, `ServiceNumber`, `GuideCard`, `Jurisdiction`, `TotalOutput`, `ActualEDTOutput`, `Latup`, `CNTsAlpha`, `GraphicsWord`, `GraphicsPDF`, `GraphicsOTP`, `ActualOnlineOutput`, `JobIDs`, `EDTTargetCompletionDate`, `EDTActualDate`, `QCDate`, `DateInitiatedOnline`, `OnlineCheckingDate`, `RevisedOnlineDueDate`, `OnlineActualDueDate`, `BenchmarkMet`, `ProposedDate`, `ActualQAOnlineDate`, `LegislationStatus`, `Stage`, `StatusCategory`, `OnTrackOffTrack`, `ReasonForDelay`, `StartDateOnHold`, `PostbackToStableDate`, `TargetPressDate`, `SSLRServices`, `JiraTickets`, `LegislationRemarks`, `isBilled`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 'Copied', '2021-02-19 00:00:00', 'Jenny', 'none', 'CRIMINAL CODE ACT 1995', 'CRIMES LEGISLATION AMENDMENT (ECONOMIC DISRUPTION) ACT 2021', '2021-02-17', 'none', '2021-02-16', 'Division 1 of Part 1, Schedule 1, Division 1 of Part 2, Schedule 1', 'Sec Leg', 'Tier 1', 'CLSA', '188', 'CTHL', 'CTH', 32, 32, 1, 0, 0, 0, 11, 2, '66862, 66863', '2021-03-12', '2021-04-12', '2021-03-15', '2021-04-12', '2021-04-15', '1900-01-01', '2021-03-17', 'N', '1900-01-01', '2021-04-15', '18_Completed LA Online Checking (Returned)', 'LA Online Checking', 'Completed', 'OFF-TRACK', 'none', '1900-01-01', '1900-01-01', '1900-01-01', 'none', 'none', 'LE requested to continue updating of legislation for CLSA 188 since he is not yet done with other STP process. 4/12/2021', 'Y', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(2, 'none', '2021-02-26 00:00:00', 'Niño Jose', 'none', 'MAGISTRATES COURT (CIVIL PROCEEDINGS) RULES 2005', 'MAGISTRATES COURT RULES AMENDMENT RULES 2021', '2021-02-27', 'none', '2021-02-10', 'Part 2', 'Sec Leg', 'Tier 2', 'MCWA', '117', 'mcr', 'WA', 18, 18, 1, 0, 0, 0, 0, 2, '66757, 66758', '2021-03-23', '2021-04-07', '1900-01-01', '2021-04-08', '2021-04-09', '1900-01-01', '2021-03-26', 'N', '2021-04-12', '2021-04-09', '18_Completed LA Online Checking (Returned)', 'LA Online Checking', 'Completed', 'OFF-TRACK', 'none', '1900-01-01', '1900-01-01', '1900-01-01', 'Service 5', 'none', '5 April: received the ready to print notification Gazette G. 37, 26/2/2021, p.816', 'Y', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(3, 'none', '2021-02-26 00:00:00', 'Niño Jose', 'none', 'MAGISTRATES COURT (GENERAL) RULES 2005', 'MAGISTRATES COURT RULES AMENDMENT RULES 2021', '2021-02-27', 'none', '2021-02-10', 'Part 3', 'Sec Leg', 'Tier 2', 'MCWA', '117', 'mcr', 'WA', 12, 12, 1, 0, 0, 0, 0, 2, '66757, 66758', '2021-03-23', '2021-04-08', '1900-01-01', '2021-04-08', '2021-04-09', '1900-01-01', '2021-03-26', 'N', '2021-04-12', '2021-04-09', '18_Completed LA Online Checking (Returned)', 'LA Online Checking', 'Completed', 'OFF-TRACK', 'none', '1900-01-01', '1900-01-01', '1900-01-01', 'Service 5', 'none', '5 April: received the ready to print notification Gazette G. 37, 26/2/2021, p.816', 'Y', '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `legislationnewdata`
--

CREATE TABLE `legislationnewdata` (
  `LegislationID` int(11) NOT NULL,
  `BPSProductID` varchar(100) DEFAULT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `PrincipalLegislation` varchar(2000) DEFAULT NULL,
  `AmendingLegislation` varchar(2000) DEFAULT NULL,
  `CommencementDate` datetime DEFAULT NULL,
  `UpdateType` varchar(100) DEFAULT NULL,
  `GuideCard` varchar(100) DEFAULT NULL,
  `TaskNumber` varchar(2000) DEFAULT NULL,
  `OnlineActualDueDate` datetime DEFAULT NULL,
  `CodingActualDate` datetime DEFAULT NULL,
  `OnlineActualDate` datetime DEFAULT NULL,
  `TotalOutput` int(11) DEFAULT NULL,
  `LegislationMaterialStatus` varchar(2000) DEFAULT NULL,
  `SendToPrintID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `legislationnewdata`
--

INSERT INTO `legislationnewdata` (`LegislationID`, `BPSProductID`, `ServiceNumber`, `PrincipalLegislation`, `AmendingLegislation`, `CommencementDate`, `UpdateType`, `GuideCard`, `TaskNumber`, `OnlineActualDueDate`, `CodingActualDate`, `OnlineActualDate`, `TotalOutput`, `LegislationMaterialStatus`, `SendToPrintID`) VALUES
(1, 'DEF', '92', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 3),
(2, 'DEF', '92', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 3),
(3, 'DEF', '92', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 3),
(4, 'DEF', '92', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 3),
(5, 'DEF', '92', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 3),
(6, 'DEF', '92', 'CUSTOMS ACT 1901', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 3),
(7, 'DEF', '92', 'JUDICIARY ACT 1903', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'APP', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 3),
(8, 'DEF', '92', 'PROCEEDS OF CRIME ACT 2002', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CF', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 3),
(9, 'DEF', '92', 'CRIMINAL CODE ACT 1995', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 3),
(10, 'DEF', '92', 'CRIMES ACT 1914', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 3),
(11, 'DEF', '92', 'TELECOMMUNICATIONS (INTERCEPTION AND ACCESS) ACT 1979', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 22, '18_Completed LA Online Checking (Returned)', 3),
(12, 'DEF', '92', 'CRIMES ACT 1914', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 38, '18_Completed LA Online Checking (Returned)', 3),
(13, 'DEF', '92', 'CHILDREN (COMMUNITY SERVICE ORDERS) REGULATION 2020', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 3),
(14, 'DEF', '92', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 3),
(15, 'DEF', '92', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'PR', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 3),
(16, 'DEF', '92', 'CRIMINAL PROCEDURE REGULATION 2017', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Key leg', 'CA', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 3),
(17, 'DEF', '92', 'ROYAL COMMISSIONS ACT 1902', 'ROYAL COMMISSIONS AMENDMENT (PROTECTION OF INFORMATION) ACT 2021', '2021-09-11 00:00:00', 'Sec leg', 'IC', 'LEG', '2021-10-08 00:00:00', '2021-10-08 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 3),
(18, 'DEF', '92', 'INTERPRETATION ACT 1987 NO 15', 'INTERPRETATION ACT 1987 NO 15', '2021-03-27 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-11-12 00:00:00', '2021-11-10 00:00:00', '2021-11-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 3),
(19, 'DEF', '92', 'COURT SECURITY REGULATION 2021', 'COURT SECURITY AMENDMENT REGULATION 2021', '2021-09-24 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-10-22 00:00:00', '2021-10-21 00:00:00', '2021-10-22 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 3),
(20, 'DEF', '92', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 4),
(21, 'DEF', '92', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 4),
(22, 'DEF', '92', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 4),
(23, 'DEF', '92', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 4),
(24, 'DEF', '92', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 4),
(25, 'DEF', '92', 'CUSTOMS ACT 1901', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 4),
(26, 'DEF', '92', 'JUDICIARY ACT 1903', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'APP', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 4),
(27, 'DEF', '92', 'PROCEEDS OF CRIME ACT 2002', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CF', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 4),
(28, 'DEF', '92', 'CRIMINAL CODE ACT 1995', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 4),
(29, 'DEF', '92', 'CRIMES ACT 1914', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 4),
(30, 'DEF', '92', 'TELECOMMUNICATIONS (INTERCEPTION AND ACCESS) ACT 1979', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 22, '18_Completed LA Online Checking (Returned)', 4),
(31, 'DEF', '92', 'CRIMES ACT 1914', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 38, '18_Completed LA Online Checking (Returned)', 4),
(32, 'DEF', '92', 'CHILDREN (COMMUNITY SERVICE ORDERS) REGULATION 2020', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 4),
(33, 'DEF', '92', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 4),
(34, 'DEF', '92', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'PR', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 4),
(35, 'DEF', '92', 'CRIMINAL PROCEDURE REGULATION 2017', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Key leg', 'CA', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 4),
(36, 'DEF', '92', 'ROYAL COMMISSIONS ACT 1902', 'ROYAL COMMISSIONS AMENDMENT (PROTECTION OF INFORMATION) ACT 2021', '2021-09-11 00:00:00', 'Sec leg', 'IC', 'LEG', '2021-10-08 00:00:00', '2021-10-08 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 4),
(37, 'DEF', '92', 'INTERPRETATION ACT 1987 NO 15', 'INTERPRETATION ACT 1987 NO 15', '2021-03-27 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-11-12 00:00:00', '2021-11-10 00:00:00', '2021-11-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 4),
(38, 'DEF', '92', 'COURT SECURITY REGULATION 2021', 'COURT SECURITY AMENDMENT REGULATION 2021', '2021-09-24 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-10-22 00:00:00', '2021-10-21 00:00:00', '2021-10-22 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 4),
(39, 'PL', '91', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 6),
(40, 'PL', '91', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 6),
(41, 'PL', '91', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 6),
(42, 'PL', '91', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 6),
(43, 'PL', '92', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 9),
(44, 'DEF', '91', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 12),
(45, 'DEF', '91', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 12),
(46, 'DEF', '91', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 12),
(47, 'DEF', '91', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 13),
(48, 'DEF', '91', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 13),
(49, 'DEF', '91', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 13),
(50, 'DEF', '91', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 14),
(51, 'DEF', '91', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 14),
(52, 'DEF', '91', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 14),
(53, 'DEF', '91', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 14),
(54, 'DEF', '91', 'new', 'new', '2021-09-01 00:00:00', 'new', 'new', 'new', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 1, 'new', 14),
(55, 'DEF', '91', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 124, '18_Completed LA Online Checking (Returned)', 15),
(56, 'DEF', '91', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 15),
(57, 'DEF', '91', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 15),
(58, 'DEF', '91', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 15),
(59, 'DEF', '91', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 15),
(60, 'CIV', '51', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 125, '18_Completed LA Online Checking (Returned)', 16),
(61, 'CIV', '51', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 16),
(62, 'CIV', '51', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 16),
(63, 'CIV', '51', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 16),
(64, 'CIV', '51', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 16),
(65, 'CIV', '51', 'CUSTOMS ACT 1901', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 16),
(66, 'CIV', '51', 'JUDICIARY ACT 1903', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'APP', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 16),
(67, 'CIV', '51', 'PROCEEDS OF CRIME ACT 2002', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CF', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 16),
(68, 'CIV', '51', 'CRIMINAL CODE ACT 1995', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 16),
(69, 'CIV', '51', 'CRIMES ACT 1914', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 16),
(70, 'CIV', '51', 'TELECOMMUNICATIONS (INTERCEPTION AND ACCESS) ACT 1979', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 22, '18_Completed LA Online Checking (Returned)', 16),
(71, 'CIV', '51', 'CRIMES ACT 1914', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 38, '18_Completed LA Online Checking (Returned)', 16),
(72, 'CIV', '51', 'CHILDREN (COMMUNITY SERVICE ORDERS) REGULATION 2020', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 16),
(73, 'CIV', '51', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 16),
(74, 'CIV', '51', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'PR', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 16),
(75, 'CIV', '51', 'CRIMINAL PROCEDURE REGULATION 2017', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Key leg', 'CA', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 16),
(76, 'CIV', '51', 'ROYAL COMMISSIONS ACT 1902', 'ROYAL COMMISSIONS AMENDMENT (PROTECTION OF INFORMATION) ACT 2021', '2021-09-11 00:00:00', 'Sec leg', 'IC', 'LEG', '2021-10-08 00:00:00', '2021-10-08 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 16),
(77, 'CIV', '51', 'INTERPRETATION ACT 1987 NO 15', 'INTERPRETATION ACT 1987 NO 15', '2021-03-27 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-11-12 00:00:00', '2021-11-10 00:00:00', '2021-11-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 16),
(78, 'CIV', '51', 'COURT SECURITY REGULATION 2021', 'COURT SECURITY AMENDMENT REGULATION 2021', '2021-09-24 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-10-22 00:00:00', '2021-10-21 00:00:00', '2021-10-22 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 16),
(79, 'PEV', '241', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 125, '18_Completed LA Online Checking (Returned)', 17),
(80, 'PEV', '241', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 17),
(81, 'PEV', '241', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 17),
(82, 'PEV', '241', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 17),
(83, 'PEV', '241', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 17),
(84, 'PEV', '241', 'CUSTOMS ACT 1901', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 17),
(85, 'PEV', '241', 'JUDICIARY ACT 1903', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'APP', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 17),
(86, 'PEV', '241', 'PROCEEDS OF CRIME ACT 2002', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CF', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 17),
(87, 'PEV', '241', 'CRIMINAL CODE ACT 1995', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 17),
(88, 'PEV', '241', 'CRIMES ACT 1914', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 17),
(89, 'PEV', '241', 'TELECOMMUNICATIONS (INTERCEPTION AND ACCESS) ACT 1979', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 22, '18_Completed LA Online Checking (Returned)', 17),
(90, 'PEV', '241', 'CRIMES ACT 1914', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 38, '18_Completed LA Online Checking (Returned)', 17),
(91, 'PEV', '241', 'CHILDREN (COMMUNITY SERVICE ORDERS) REGULATION 2020', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 17),
(92, 'PEV', '241', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 17),
(93, 'PEV', '241', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'PR', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 17),
(94, 'PEV', '241', 'CRIMINAL PROCEDURE REGULATION 2017', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Key leg', 'CA', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 17),
(95, 'PEV', '241', 'ROYAL COMMISSIONS ACT 1902', 'ROYAL COMMISSIONS AMENDMENT (PROTECTION OF INFORMATION) ACT 2021', '2021-09-11 00:00:00', 'Sec leg', 'IC', 'LEG', '2021-10-08 00:00:00', '2021-10-08 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 17),
(96, 'PEV', '241', 'INTERPRETATION ACT 1987 NO 15', 'INTERPRETATION ACT 1987 NO 15', '2021-03-27 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-11-12 00:00:00', '2021-11-10 00:00:00', '2021-11-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 17),
(97, 'PEV', '241', 'COURT SECURITY REGULATION 2021', 'COURT SECURITY AMENDMENT REGULATION 2021', '2021-09-24 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-10-22 00:00:00', '2021-10-21 00:00:00', '2021-10-22 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 17),
(98, 'CIV', '49', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 125, '18_Completed LA Online Checking (Returned)', 18),
(99, 'CIV', '49', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 18),
(100, 'CIV', '49', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 18),
(101, 'CIV', '49', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 18),
(102, 'CIV', '49', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 18),
(103, 'CIV', '49', 'CUSTOMS ACT 1901', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 18),
(104, 'CIV', '49', 'JUDICIARY ACT 1903', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'APP', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 18),
(105, 'CIV', '49', 'PROCEEDS OF CRIME ACT 2002', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CF', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 18),
(106, 'CIV', '49', 'CRIMINAL CODE ACT 1995', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 18),
(107, 'CIV', '49', 'CRIMES ACT 1914', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 18),
(108, 'CIV', '49', 'TELECOMMUNICATIONS (INTERCEPTION AND ACCESS) ACT 1979', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 22, '18_Completed LA Online Checking (Returned)', 18),
(109, 'CIV', '49', 'CRIMES ACT 1914', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 38, '18_Completed LA Online Checking (Returned)', 18),
(110, 'CIV', '49', 'CHILDREN (COMMUNITY SERVICE ORDERS) REGULATION 2020', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 18),
(111, 'CIV', '49', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 18),
(112, 'CIV', '49', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'PR', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 18),
(113, 'CIV', '49', 'CRIMINAL PROCEDURE REGULATION 2017', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Key leg', 'CA', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 18),
(114, 'CIV', '49', 'ROYAL COMMISSIONS ACT 1902', 'ROYAL COMMISSIONS AMENDMENT (PROTECTION OF INFORMATION) ACT 2021', '2021-09-11 00:00:00', 'Sec leg', 'IC', 'LEG', '2021-10-08 00:00:00', '2021-10-08 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 18),
(115, 'CIV', '49', 'INTERPRETATION ACT 1987 NO 15', 'INTERPRETATION ACT 1987 NO 15', '2021-03-27 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-11-12 00:00:00', '2021-11-10 00:00:00', '2021-11-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 18),
(116, 'CIV', '49', 'COURT SECURITY REGULATION 2021', 'COURT SECURITY AMENDMENT REGULATION 2021', '2021-09-24 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-10-22 00:00:00', '2021-10-21 00:00:00', '2021-10-22 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 18),
(117, 'ABCE', '68', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', 'repeal the Road Transport (General) Regulation 2013', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-08 00:00:00', '2021-10-11 00:00:00', 125, '18_Completed LA Online Checking (Returned)', 19),
(118, 'ABCE', '68', 'ROAD TRANSPORT (DRIVER LICENSING) REGULATION 2017', 'ROAD TRANSPORT (GENERAL) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'RT', 'LEG', '2021-10-11 00:00:00', '2021-10-10 00:00:00', '2021-10-11 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 19),
(119, 'ABCE', '68', 'POISONS AND THERAPEUTIC GOODS REGULATION 2008', 'POISONS AND THERAPEUTIC GOODS AMENDMENT (COSMETIC USE) REGULATION 2021', '2021-09-01 00:00:00', 'Sec leg', 'dr', 'LEG', '2021-10-11 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 8, '18_Completed LA Online Checking (Returned)', 19),
(120, 'ABCE', '68', 'CRIMES ACT 1914', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-11 00:00:00', '2021-10-09 00:00:00', '2021-10-11 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 19),
(121, 'ABCE', '68', 'CRIMINAL CODE ACT 1995', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 12, '18_Completed LA Online Checking (Returned)', 19),
(122, 'ABCE', '68', 'CUSTOMS ACT 1901', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 19),
(123, 'ABCE', '68', 'JUDICIARY ACT 1903', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'APP', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 19),
(124, 'ABCE', '68', 'PROCEEDS OF CRIME ACT 2002', 'FEDERAL CIRCUIT AND FAMILY COURT OF AUSTRALIA (CONSEQUENTIAL AMENDMENTS AND TRANSITIONAL PROVISIONS) ACT 2021', '2021-09-01 00:00:00', 'Sec leg', 'CF', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 19),
(125, 'ABCE', '68', 'CRIMINAL CODE ACT 1995', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CODE', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 19),
(126, 'ABCE', '68', 'CRIMES ACT 1914', 'COUNTER-TERRORISM LEGISLATION AMENDMENT (SUNSETTING REVIEW AND OTHER MEASURES) ACT 2021', '2021-09-03 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 19),
(127, 'ABCE', '68', 'TELECOMMUNICATIONS (INTERCEPTION AND ACCESS) ACT 1979', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'IN', 'LEG', '2021-10-13 00:00:00', '2021-10-12 00:00:00', '2021-10-13 00:00:00', 22, '18_Completed LA Online Checking (Returned)', 19),
(128, 'ABCE', '68', 'CRIMES ACT 1914', 'SURVEILLANCE LEGISLATION AMENDMENT (IDENTIFY AND DISRUPT) ACT 2021', '2021-09-04 00:00:00', 'Sec leg', 'CTHCRIM', 'LEG', '2021-10-12 00:00:00', '2021-10-09 00:00:00', '2021-10-12 00:00:00', 38, '18_Completed LA Online Checking (Returned)', 19),
(129, 'ABCE', '68', 'CHILDREN (COMMUNITY SERVICE ORDERS) REGULATION 2020', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 19),
(130, 'ABCE', '68', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'CL', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 19),
(131, 'ABCE', '68', 'CHILDREN (DETENTION CENTRES) REGULATION 2015', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Sec leg', 'PR', 'LEG', '2021-10-13 00:00:00', '2021-10-06 00:00:00', '2021-10-08 00:00:00', 4, '18_Completed LA Online Checking (Returned)', 19),
(132, 'ABCE', '68', 'CRIMINAL PROCEDURE REGULATION 2017', 'STRONGER COMMUNITIES LEGISLATION AMENDMENT (COVID-19) REGULATION 2021', '2021-09-15 00:00:00', 'Key leg', 'CA', 'LEG', '2021-10-12 00:00:00', '2021-10-11 00:00:00', '2021-10-12 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 19),
(133, 'ABCE', '68', 'ROYAL COMMISSIONS ACT 1902', 'ROYAL COMMISSIONS AMENDMENT (PROTECTION OF INFORMATION) ACT 2021', '2021-09-11 00:00:00', 'Sec leg', 'IC', 'LEG', '2021-10-08 00:00:00', '2021-10-08 00:00:00', '2021-10-08 00:00:00', 5, '18_Completed LA Online Checking (Returned)', 19),
(134, 'ABCE', '68', 'INTERPRETATION ACT 1987 NO 15', 'INTERPRETATION ACT 1987 NO 15', '2021-03-27 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-11-12 00:00:00', '2021-11-10 00:00:00', '2021-11-12 00:00:00', 2, '18_Completed LA Online Checking (Returned)', 19),
(135, 'ABCE', '68', 'COURT SECURITY REGULATION 2021', 'COURT SECURITY AMENDMENT REGULATION 2021', '2021-09-24 00:00:00', 'Sec leg', 'OLNSW', 'LEG', '2021-10-22 00:00:00', '2021-10-21 00:00:00', '2021-10-22 00:00:00', 3, '18_Completed LA Online Checking (Returned)', 19);

-- --------------------------------------------------------

--
-- Table structure for table `manuscriptdata`
--

CREATE TABLE `manuscriptdata` (
  `ManuscriptID` int(11) NOT NULL,
  `JobNumber` int(8) UNSIGNED ZEROFILL DEFAULT NULL,
  `ManuscriptTier` varchar(50) DEFAULT NULL,
  `BPSProductID` varchar(10) NOT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `ManuscriptLegTitle` varchar(1000) DEFAULT NULL,
  `ManuscriptStatus` varchar(100) DEFAULT NULL,
  `TargetPressDate` datetime DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `LatupAttribution` varchar(1000) DEFAULT NULL,
  `DateReceivedFromAuthor` datetime DEFAULT NULL,
  `UpdateType` varchar(50) DEFAULT NULL,
  `JobSpecificInstruction` varchar(500) DEFAULT NULL,
  `TaskType` varchar(50) DEFAULT NULL,
  `PEGuideCard` varchar(500) DEFAULT NULL,
  `PECheckbox` varchar(20) DEFAULT NULL,
  `PETaskNumber` varchar(20) DEFAULT NULL,
  `RevisedOnlineDueDate` datetime DEFAULT NULL,
  `CopyEditDueDate` datetime DEFAULT NULL,
  `CopyEditStartDate` datetime DEFAULT NULL,
  `CopyEditDoneDate` datetime DEFAULT NULL,
  `CopyEditStatus` varchar(500) DEFAULT NULL,
  `CodingDueDate` datetime DEFAULT NULL,
  `CodingStartDate` datetime DEFAULT NULL,
  `CodingDoneDate` datetime DEFAULT NULL,
  `CodingStatus` varchar(500) DEFAULT NULL,
  `OnlineDueDate` datetime DEFAULT NULL,
  `OnlineStartDate` datetime DEFAULT NULL,
  `OnlineDoneDate` datetime DEFAULT NULL,
  `OnlineStatus` varchar(500) DEFAULT NULL,
  `PESTPStatus` varchar(500) DEFAULT NULL,
  `EstimatedPages` int(11) DEFAULT NULL,
  `ActualTurnAroundTime` int(11) DEFAULT NULL,
  `OnlineTimeliness` varchar(100) DEFAULT NULL,
  `ReasonIfLate` varchar(100) DEFAULT NULL,
  `PECoversheetNumber` varchar(100) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `manuscriptdata`
--

INSERT INTO `manuscriptdata` (`ManuscriptID`, `JobNumber`, `ManuscriptTier`, `BPSProductID`, `ServiceNumber`, `ManuscriptLegTitle`, `ManuscriptStatus`, `TargetPressDate`, `ActualPressDate`, `LatupAttribution`, `DateReceivedFromAuthor`, `UpdateType`, `JobSpecificInstruction`, `TaskType`, `PEGuideCard`, `PECheckbox`, `PETaskNumber`, `RevisedOnlineDueDate`, `CopyEditDueDate`, `CopyEditStartDate`, `CopyEditDoneDate`, `CopyEditStatus`, `CodingDueDate`, `CodingStartDate`, `CodingDoneDate`, `CodingStatus`, `OnlineDueDate`, `OnlineStartDate`, `OnlineDoneDate`, `OnlineStatus`, `PESTPStatus`, `EstimatedPages`, `ActualTurnAroundTime`, `OnlineTimeliness`, `ReasonIfLate`, `PECoversheetNumber`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 00000001, 'Tier 2', 'ABCA', '37', 'example', 'On-Going', '2022-03-10 00:00:00', NULL, 'example', '2022-07-27 00:00:00', 'Manus-Light', 'example', 'COMMENTARY', 'example', 'Checked', '1', NULL, '2022-08-03 00:00:00', '2022-07-28 18:25:00', '2022-07-28 18:30:00', 'Completed', '2022-08-08 00:00:00', '2022-07-28 18:53:00', '2022-07-28 19:42:00', 'Completed', '2022-08-10 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'ABCA_37_1', '2022-07-28 18:24:34', 2, '2022-07-28 19:42:57', 4),
(2, 00000002, 'Tier 3', 'ABCE', '71', 'example', 'On-Going', '2022-03-25 00:00:00', NULL, 'example', '2022-07-27 00:00:00', 'Manus-Light', 'example', 'COMMENTARY', 'example', 'Checked', '1', NULL, '2022-08-03 00:00:00', '2022-07-28 20:04:00', '2022-07-28 20:05:00', 'Completed', '2022-08-08 00:00:00', '2022-07-28 20:16:00', '2022-07-28 20:19:00', 'Completed', '2022-08-10 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'ABCE_71_1', '2022-07-28 20:03:48', 2, '2022-07-28 20:19:41', 4),
(3, 00000003, 'Tier 3', 'BC', '61', 'new example', 'On-Going', '2022-02-16 00:00:00', NULL, 'new example', '2022-07-28 00:00:00', 'Manus-Medium', 'new example', 'COMMENTARY', 'new example', 'Checked', '1', NULL, '2022-08-10 00:00:00', '2022-07-29 14:57:00', '2022-07-29 14:58:00', 'Completed', '2022-08-17 00:00:00', '2022-07-29 15:37:00', '2022-07-29 15:39:00', 'Completed', '2022-08-19 00:00:00', '2022-08-01 14:58:00', '2022-08-01 16:18:00', 'Completed', 'New', NULL, NULL, 'Ahead', NULL, 'BC_61_1', '2022-07-29 14:54:51', 2, '2022-08-01 16:18:11', 5),
(4, 00000004, 'Tier 3', 'BC', '62', 'example today', 'On-Going', '2022-07-13 00:00:00', NULL, 'example today', '2022-07-28 00:00:00', 'Manus-Heavy', 'example today', 'COMMENTARY', 'example today', 'Checked', '1', NULL, '2022-08-17 00:00:00', '2022-07-29 16:36:00', '2022-07-29 16:36:00', 'Completed', '2022-08-31 00:00:00', '2022-07-29 16:39:00', '2022-07-29 16:41:00', 'Completed', '2022-09-02 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'BC_62_1', '2022-07-29 16:35:57', 2, '2022-07-29 16:41:37', 5),
(5, 00000005, 'Tier 3', 'BC', '63', 'example part 5', 'New', '2022-09-28 00:00:00', NULL, 'example part 5', '2022-08-02 00:00:00', 'Manus-Heavy', 'example part 5', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-08-22 00:00:00', NULL, NULL, 'New', '2022-09-05 00:00:00', NULL, NULL, 'New', '2022-09-07 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-08-03 09:22:00', 2, '2022-08-03 09:22:00', 2),
(8, 00000006, 'Tier 2', 'DEF', '91', 'third manuscript', 'New', '2021-05-13 00:00:00', NULL, 'third laptup', '2022-08-04 00:00:00', 'Manus-Medium', 'third job', 'COMMENTARY', 'second guide card', 'Checked', '1', NULL, '2022-08-17 00:00:00', NULL, NULL, 'New', '2022-09-07 00:00:00', NULL, NULL, 'New', '2022-09-09 00:00:00', NULL, NULL, 'New', 'Completed', NULL, NULL, 'TBD', NULL, 'DEF_91_1', '2022-08-05 14:30:27', 8, '2022-08-05 22:54:12', 28),
(9, 00000006, 'Tier 2', 'DEF', '91', 'fourth manuscript', 'New', '2021-05-13 00:00:00', NULL, 'fouth latup', '2022-08-03 00:00:00', 'Key Leg', 'fourth job', 'LEGISLATION', 'fourth guide card', 'Checked', '2', NULL, NULL, NULL, NULL, 'New', '2022-08-17 00:00:00', NULL, NULL, 'New', '2022-08-19 00:00:00', NULL, NULL, 'New', 'Completed', NULL, NULL, 'TBD', NULL, 'DEF_91_2', '2022-08-05 14:43:26', 8, '2022-08-09 02:43:04', 28),
(10, 00000007, 'Tier 2', 'DEF', '92', 'dump manuscript', 'On-Going', '2021-08-12 00:00:00', NULL, 'dump manuscript', '2022-08-05 00:00:00', 'Manus-Heavy', 'dump manuscript', 'COMMENTARY', '\"dump guidecard\"', 'Checked', '1', NULL, '2022-08-25 00:00:00', '2022-08-08 14:54:00', '2022-08-08 14:54:00', 'Completed', '2022-09-08 00:00:00', NULL, NULL, 'New', '2022-09-12 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'DEF_92_1', '2022-08-08 14:53:13', 8, '2022-08-08 14:57:54', 28),
(11, 00000007, 'Tier 2', 'DEF', '92', 'dump manuscript', 'On-Going', '2021-08-12 00:00:00', NULL, 'dump manuscript', '2022-08-05 00:00:00', 'Manus-Medium', 'dump manuscript', 'COMMENTARY', '\"dump guidecard\"', 'Checked', '1', NULL, '2022-08-18 00:00:00', '2022-08-08 14:55:00', '2022-08-08 14:55:00', 'Completed', '2022-09-08 00:00:00', NULL, NULL, 'New', '2022-09-12 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, 'TBD', NULL, 'DEF_92_1', '2022-08-08 14:53:32', 8, '2022-08-08 14:57:54', 28),
(12, 00000007, 'Tier 2', 'DEF', '92', 'dump manuscript', 'On-Going', '2021-08-12 00:00:00', NULL, 'dump manuscript', '2022-08-05 00:00:00', 'Manus-Heavy', 'dump manuscript', 'COMMENTARY', '\"new guide\"\n\'card\'', 'Checked', '2', NULL, '2022-08-25 00:00:00', '2022-08-08 14:55:00', '2022-08-08 14:55:00', 'Completed', '2022-09-08 00:00:00', NULL, NULL, 'New', '2022-09-12 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, 'TBD', NULL, 'DEF_92_2', '2022-08-08 14:53:50', 8, '2022-08-08 15:12:46', 28),
(13, 00000008, 'Tier 3', 'PL', '90', 'job reassignment log', 'On-Going', '2021-05-04 00:00:00', NULL, 'job reassignment log', '2022-08-15 00:00:00', 'Manus-Light', 'job reassignment log', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-08-22 00:00:00', '2022-08-30 16:04:00', '2022-08-30 16:04:00', 'Completed', '2022-08-25 00:00:00', NULL, NULL, 'New', '2022-08-29 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-08-16 15:25:12', 8, '2022-08-30 16:04:36', 28),
(14, 00000008, 'Tier 3', 'PL', '90', 'test reassignment', 'New', '2021-05-04 00:00:00', NULL, 'test reassignment', '2022-08-15 00:00:00', 'Manus-Light', 'test reassignment', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-08-22 00:00:00', NULL, NULL, 'New', '2022-08-25 00:00:00', NULL, NULL, 'New', '2022-08-29 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-08-16 15:46:45', 8, '2022-08-16 15:46:45', 8),
(15, 00000009, 'Tier 3', 'PL', '91', 'test reassignment part 2', 'On-Going', '2021-07-15 00:00:00', NULL, 'test reassignment part 2', '2022-08-15 00:00:00', 'Manus-Medium', 'test reassignment part 2', 'COMMENTARY', 'N12345', 'Checked', 'Task1', NULL, '2022-08-26 00:00:00', '2022-08-26 14:51:00', '2022-08-26 14:50:00', 'Completed', '2022-09-02 00:00:00', NULL, NULL, 'New', '2022-09-06 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PL_91_Task1_N12345', '2022-08-16 15:48:03', 8, '2022-08-26 14:51:21', 28),
(16, 00000009, 'Tier 3', 'PL', '91', 'example 3', 'On-Going', '2021-07-15 00:00:00', NULL, 'example 3', '2022-08-15 00:00:00', 'Manus-Light', 'example 3', 'COMMENTARY', 'new guidecard', 'Checked', 'Task2', NULL, '2022-08-22 00:00:00', '2022-08-26 14:52:00', '2022-08-26 14:52:00', 'Completed', '2022-08-25 00:00:00', NULL, NULL, 'New', '2022-08-29 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PL_91_Task2_new guidecard', '2022-08-16 15:54:40', 8, '2022-09-22 06:46:35', 28),
(17, 00000009, 'Tier 3', 'PL', '91', 'example4', 'On-Going', '2021-07-15 00:00:00', NULL, 'example4', '2022-08-15 00:00:00', 'Manus-Light', 'example4', 'COMMENTARY', 'new guidecard', 'Checked', 'Task2', NULL, '2022-08-22 00:00:00', '2022-08-26 15:35:00', '2022-08-26 15:35:00', 'Completed', '2022-08-25 00:00:00', NULL, NULL, 'New', '2022-08-29 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PL_91_Task2_new guidecard', '2022-08-16 15:55:58', 8, '2022-09-22 06:46:35', 28),
(21, 00000012, 'Tier 1', 'IPC', '158', 'not applicable', 'New', '2021-03-30 00:00:00', NULL, 'not applicable', '2022-08-29 00:00:00', 'Key Leg', 'not applicable', 'LEGISLATION', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Not Applicable', '2022-09-09 00:00:00', NULL, NULL, 'New', '2022-09-13 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-08-30 15:34:05', 8, '2022-08-30 15:34:05', 8),
(22, 00000013, 'Tier 1', 'IPC', '159', 'not applicable', 'New', '2021-03-30 00:00:00', NULL, 'not applicable', '2022-08-29 00:00:00', 'Key Leg', 'not applicable', 'LEGISLATION', 'GRFFG', 'Checked', 'Task1', NULL, NULL, NULL, NULL, 'Not Applicable', '2022-09-13 00:00:00', NULL, NULL, 'New', '2022-09-15 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'IPC_159_Task1_GRFFG', '2022-08-30 15:42:20', 8, '2022-12-13 14:03:52', 28),
(23, 00000014, 'Tier 1', 'IPC', '160', 'applicable', 'On-Going', '2021-06-29 00:00:00', NULL, 'applicable', '2022-08-29 00:00:00', 'Manus-Heavy', 'applicable', 'COMMENTARY', 'guidecard', 'Checked', 'Task1', NULL, '2022-09-16 00:00:00', '2022-09-19 17:38:00', '2022-09-19 17:38:00', 'Completed', '2022-09-30 00:00:00', NULL, NULL, 'New', '2022-10-04 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'IPC_160_Task1_guidecard', '2022-08-30 15:43:15', 8, '2022-09-19 17:38:49', 28),
(27, 00000014, 'Tier 1', 'IPC', '160', 'new1', 'On-Going', '2021-06-29 00:00:00', NULL, 'new1', '2022-09-21 00:00:00', 'Manus-Heavy', 'new1', 'COMMENTARY', 'guidecard', 'Checked', 'Task2', NULL, '2022-10-11 00:00:00', '2022-09-22 06:17:00', '2022-09-22 06:17:00', 'Completed', '2022-10-25 00:00:00', NULL, NULL, 'New', '2022-10-27 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'IPC_160_Task2_guidecard', '2022-09-22 06:16:12', 8, '2022-09-22 06:30:26', 28),
(28, 00000014, 'Tier 1', 'IPC', '160', 'new2', 'On-Going', '2021-06-29 00:00:00', NULL, 'new2', '2022-09-21 00:00:00', 'Manus-Heavy', 'new2', 'COMMENTARY', 'guidecard', 'Checked', 'Task2', NULL, '2022-10-11 00:00:00', '2022-09-22 06:17:00', '2022-09-22 06:18:00', 'Completed', '2022-10-25 00:00:00', NULL, NULL, 'New', '2022-10-27 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'IPC_160_Task2_guidecard', '2022-09-22 06:16:55', 8, '2022-09-22 06:30:26', 28),
(29, 00000015, 'Tier 3', 'PL', '92', 'example', 'On-Going', '2021-10-14 00:00:00', NULL, 'example', '2022-09-22 00:00:00', 'Manus-Light', 'example', 'COMMENTARY', 'example', 'Checked', 'Task1', NULL, '2022-09-29 00:00:00', '2022-09-23 16:35:00', '2022-09-23 16:35:00', 'Completed', '2022-10-04 00:00:00', NULL, NULL, 'New', '2022-10-06 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PL_92_Task1_example', '2022-09-23 16:34:28', 8, '2022-09-23 16:36:28', 28),
(30, 00000015, 'Tier 3', 'PL', '92', 'example 2', 'On-Going', '2021-10-14 00:00:00', NULL, 'example 2', '2022-09-22 00:00:00', 'Manus-Medium', 'example 2', 'COMMENTARY', 'example 2', 'Checked', 'Task2', NULL, '2022-10-05 00:00:00', '2022-09-23 16:39:00', '2022-09-23 16:39:00', 'Completed', '2022-10-26 00:00:00', NULL, NULL, 'New', '2022-10-28 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PL_92_Task2_example 2', '2022-09-23 16:37:22', 8, '2022-09-23 16:41:01', 28),
(31, 00000015, 'Tier 3', 'PL', '92', 'example 3', 'On-Going', '2021-10-14 00:00:00', NULL, 'example 3', '2022-09-22 00:00:00', 'Manus-Heavy', 'example 3', 'COMMENTARY', 'example 2', 'Checked', 'Task2', NULL, '2022-10-12 00:00:00', '2022-09-23 16:39:00', '2022-09-23 16:39:00', 'Completed', '2022-10-26 00:00:00', NULL, NULL, 'New', '2022-10-28 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PL_92_Task2_example 2', '2022-09-23 16:38:01', 8, '2022-09-23 16:41:01', 28),
(32, 00000006, 'Tier 2', 'DEF', '91', 'fifth', 'On-Going', '2021-05-13 00:00:00', NULL, 'fifth', '2022-09-29 00:00:00', 'Manus-Heavy', 'fifth', 'COMMENTARY', 'third', 'Checked', 'Task3', NULL, '2022-10-19 00:00:00', '2022-09-30 22:27:00', '2022-09-30 22:28:00', 'Completed', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'Completed', NULL, NULL, NULL, NULL, 'DEF_91_Task3_third', '2022-09-30 22:26:28', 8, '2022-09-30 22:34:08', 28),
(33, 00000016, 'Tier 3', 'CIV', '51', '[53,050]\n', 'On-Going', '2021-11-27 00:00:00', NULL, 'Richard Douglas\n', '2022-06-09 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'LPA, Latup', 'Checked', 'Task1', NULL, '2022-10-28 00:00:00', '2022-10-24 02:22:00', '2022-10-24 02:29:00', 'Completed', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'Completed', NULL, NULL, NULL, NULL, 'CIV_51_Task1_LPA, Latup', '2022-10-24 02:14:38', 10, '2022-10-24 02:32:10', 27),
(34, 00000017, 'Tier 3', 'CIV', '50', '[53,058]\n', 'New', '2021-08-20 00:00:00', NULL, 'Richard Douglas\n', '2022-06-09 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-10-28 00:00:00', NULL, NULL, 'New', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-10-24 02:15:23', 10, '2022-10-24 02:15:23', 10),
(35, 00000016, 'Tier 3', 'CIV', '51', '[15,055.1]\n', 'On-Going', '2021-11-27 00:00:00', NULL, 'Richard Douglas\n', '2022-07-11 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'GENPRINC, Latup\n', 'Checked', 'Task2', NULL, '2022-10-28 00:00:00', '2022-10-24 02:22:00', '2022-10-24 02:29:00', 'Completed', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'Completed', NULL, NULL, NULL, NULL, 'CIV_51_Task2_GENPRINC, Latup\n', '2022-10-24 02:15:52', 10, '2022-10-24 02:33:07', 27),
(36, 00000016, 'Tier 3', 'CIV', '51', '[53,058]', 'On-Going', '2021-11-27 00:00:00', NULL, 'Richard Douglas\n', '2022-06-09 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'LPA, Latup', 'Checked', 'Task1', NULL, '2022-10-28 00:00:00', '2022-10-24 02:21:00', '2022-10-24 02:29:00', 'Completed', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'Completed', NULL, NULL, NULL, NULL, 'CIV_51_Task1_LPA, Latup', '2022-10-24 02:16:25', 10, '2022-10-24 02:32:10', 27),
(37, 00000016, 'Tier 3', 'CIV', '51', '[19,095]\n', 'On-Going', '2021-11-27 00:00:00', NULL, 'Richard Douglas\n', '2022-06-09 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'GENPRINC, Latup\n', 'Checked', 'Task2', NULL, '2022-10-28 00:00:00', '2022-10-24 02:21:00', '2022-10-24 02:29:00', 'Completed', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'Completed', NULL, NULL, NULL, NULL, 'CIV_51_Task2_GENPRINC, Latup\n', '2022-10-24 02:17:00', 10, '2022-10-24 02:33:07', 27),
(38, 00000016, 'Tier 3', 'CIV', '51', '[10,087]\n', 'On-Going', '2021-11-27 00:00:00', NULL, 'Richard Douglas\n', '2022-07-15 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'GENPRINC, Latup\n', 'Checked', 'Task3', NULL, '2022-10-28 00:00:00', '2022-10-24 02:21:00', '2022-10-24 02:28:00', 'Completed', '2022-11-02 00:00:00', '2022-10-24 14:20:00', '2022-10-24 14:21:00', 'Completed', '2022-11-04 00:00:00', '2022-10-24 14:29:00', '2022-10-24 14:29:00', 'Completed', 'Completed', NULL, NULL, 'Ahead', NULL, 'CIV_51_Task3_GENPRINC, Latup\n', '2022-10-24 02:18:09', 10, '2022-10-24 14:29:05', 36),
(39, 00000018, 'Tier 1', 'PEV', '241', 'GC39 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'n/a', '2021-11-15 00:00:00', 'Manus-Medium', 'n/a', 'COMMENTARY', 'PL, PC, PAC, WPA, EOL, LATUP\n', 'Checked', 'Task8', NULL, '2022-11-03 00:00:00', '2022-10-24 20:14:00', '2022-10-24 20:19:00', 'Completed', '2022-11-10 00:00:00', NULL, NULL, 'New', '2022-11-14 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PEV_241_Task8_PL, PC, PAC, WPA, EOL, LATUP\n', '2022-10-24 19:20:36', 14, '2022-10-24 20:41:14', 26),
(40, 00000018, 'Tier 1', 'PEV', '241', 'GC41 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'n/a', '2021-11-13 00:00:00', 'Manus-Heavy', 'n/a', 'COMMENTARY', 'PL, PC, PAC, WPA, EOL, LATUP\n', 'Checked', 'Task7', NULL, '2022-11-10 00:00:00', '2022-10-24 20:14:00', '2022-10-24 20:19:00', 'Completed', '2022-11-24 00:00:00', NULL, NULL, 'New', '2022-11-28 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PEV_241_Task7_PL, PC, PAC, WPA, EOL, LATUP\n', '2022-10-24 19:21:14', 14, '2022-10-24 20:40:28', 26),
(41, 00000018, 'Tier 1', 'PEV', '241', 'GC42 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'n/a', '2021-11-15 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'PL, PC, PAC, WPA, EOL, LATUP\n', 'Checked', 'Task6', NULL, '2022-10-28 00:00:00', '2022-10-24 20:14:00', '2022-10-24 20:19:00', 'Completed', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PEV_241_Task6_PL, PC, PAC, WPA, EOL, LATUP\n', '2022-10-24 19:21:48', 14, '2022-10-24 20:38:31', 26),
(42, 00000018, 'Tier 1', 'PEV', '241', 'GC43 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'n/a', '2021-11-29 00:00:00', 'Manus-Medium', 'n/a', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Checked', 'Task5', NULL, '2022-11-03 00:00:00', '2022-10-24 20:14:00', '2022-10-24 20:19:00', 'Completed', '2022-11-10 00:00:00', NULL, NULL, 'New', '2022-11-14 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PEV_241_Task5_PL, PAC, VPP, PC, WPA, LATUP\n', '2022-10-24 19:22:25', 14, '2022-10-24 20:38:08', 26),
(43, 00000018, 'Tier 1', 'PEV', '241', 'GC44 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'n/a', '2021-11-29 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Checked', 'Task4', NULL, '2022-10-28 00:00:00', '2022-10-24 20:13:00', '2022-10-24 20:19:00', 'Completed', '2022-11-02 00:00:00', '2022-11-04 14:16:00', '2022-11-04 14:17:00', 'Completed', '2022-11-04 00:00:00', '2022-11-04 14:18:00', '2022-11-04 14:19:00', 'Completed', 'On-Going', NULL, NULL, 'Delay', NULL, 'PEV_241_Task4_PL, PAC, VPP, PC, WPA, LATUP\n', '2022-10-24 19:23:17', 14, '2022-11-04 14:19:04', 32),
(44, 00000018, 'Tier 1', 'PEV', '241', 'GC45 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'n/a', '2021-12-06 00:00:00', 'Manus-Heavy', 'n/a', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Checked', 'Task3', NULL, '2022-11-10 00:00:00', '2022-10-24 20:13:00', '2022-10-24 20:19:00', 'Completed', '2022-11-24 00:00:00', NULL, NULL, 'New', '2022-11-28 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PEV_241_Task3_PL, PAC, VPP, PC, WPA, LATUP\n', '2022-10-24 19:26:09', 14, '2022-10-24 20:37:00', 26),
(45, 00000018, 'Tier 1', 'PEV', '241', 'GC46 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'n/a', '2021-11-21 00:00:00', 'Manus-Light', 'n/a', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP', 'Checked', 'Task2', NULL, '2022-10-28 00:00:00', '2022-10-24 20:13:00', '2022-10-24 20:18:00', 'Completed', '2022-11-02 00:00:00', NULL, NULL, 'New', '2022-11-04 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'PEV_241_Task2_PL, PAC, VPP, PC, WPA, LATUP', '2022-10-24 19:26:44', 14, '2022-10-24 20:31:51', 26),
(46, 00000018, 'Tier 1', 'PEV', '241', 'GC48 of 2021\n', 'On-Going', '2021-11-26 00:00:00', NULL, 'with edit_with edit PE', '2021-12-06 00:00:00', 'Manus-Medium', 'n/a', 'COMMENTARY', 'PL, PAC, VPP, PC, WPA, LATUP\n', 'Checked', 'Task1', NULL, '2022-11-03 00:00:00', '2022-10-24 20:11:00', '2022-10-24 20:18:00', 'Completed', '2022-11-10 00:00:00', '2022-10-26 16:53:00', '2022-10-26 16:54:00', 'Completed', '2022-11-14 00:00:00', NULL, NULL, 'New', 'On-Going', 44, NULL, NULL, 'sample_with edit', 'PEV_241_Task1_PL, PAC, VPP, PC, WPA, LATUP\n', '2022-10-24 19:27:49', 14, '2022-10-26 16:54:08', 32),
(47, 00000019, 'Tier 1', 'CLSA', '192', 'TRY 1', 'New', '2021-12-06 00:00:00', NULL, 'test_1', '2022-11-18 00:00:00', 'Ed Mns-Lgt', 'test 1', 'COMMENTARY', 'DFDF', 'Checked', 'Task1', NULL, NULL, NULL, NULL, 'Not Applicable', '2022-12-01 00:00:00', NULL, NULL, 'New', '2022-12-05 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'CLSA_192_Task1_DFDF', '2022-11-18 15:37:31', 17, '2022-11-28 13:21:09', 23),
(48, 00000020, 'Newsletter', 'AER', '36.7', 'try_11', 'New', '2021-12-13 00:00:00', NULL, 'LATUP_1', '2022-11-16 00:00:00', 'Manus-Heavy', 'TEST', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-12-08 00:00:00', NULL, NULL, 'New', '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-26 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-11-21 13:52:32', 17, '2022-11-21 13:52:32', 17),
(49, 00000020, 'Newsletter', 'AER', '36.7', 'try_11', 'New', '2021-12-13 00:00:00', NULL, 'LATUP_1', '2022-11-16 00:00:00', 'Manus-Heavy', 'TEST', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-12-08 00:00:00', NULL, NULL, 'New', '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-26 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-11-21 13:52:35', 17, '2022-11-21 13:52:35', 17),
(50, 00000020, 'Newsletter', 'AER', '36.7', 'try_11', 'New', '2021-12-13 00:00:00', NULL, 'LATUP_1', '2022-11-16 00:00:00', 'Manus-Heavy', 'TEST', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-12-08 00:00:00', NULL, NULL, 'New', '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-26 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-11-21 13:52:37', 17, '2022-11-21 13:52:37', 17),
(51, 00000021, 'Tier 3', 'FRAN', '68', 'sample 1', 'On-Going', '2021-10-25 00:00:00', NULL, 'latup 1', NULL, 'Manus-Heavy', 'sample 1', 'COMMENTARY', 'gc 2', 'Checked', 'Task2', NULL, '2022-12-08 00:00:00', '2022-11-21 23:55:00', '2022-11-22 00:05:00', 'Completed', '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-26 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'FRAN_68_Task2_gc 2', '2022-11-21 16:22:30', 10, '2022-11-22 00:14:24', 28),
(52, 00000021, 'Tier 3', 'FRAN', '68', 'sample 2', 'On-Going', '2021-10-25 00:00:00', NULL, 'latup 2', '2022-11-24 00:00:00', 'Manus-Medium', 'JBI 2', 'COMMENTARY', 'gc 2', 'Checked', 'Task2', NULL, '2022-12-01 00:00:00', '2022-11-21 23:55:00', '2022-11-22 00:05:00', 'Completed', '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-26 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'FRAN_68_Task2_gc 2', '2022-11-21 16:24:36', 10, '2022-11-22 00:14:24', 28),
(53, 00000021, 'Tier 3', 'FRAN', '68', 'sample 3', 'On-Going', '2021-10-25 00:00:00', NULL, 'latup 3', '2022-11-30 00:00:00', 'Manus-Medium', 'jbi 3', 'COMMENTARY', 'gc1', 'Checked', 'Task1', NULL, '2022-12-01 00:00:00', '2022-11-21 23:55:00', '2022-11-22 00:05:00', 'Completed', '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-26 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'FRAN_68_Task1_gc1', '2022-11-21 16:37:33', 10, '2022-11-22 00:13:54', 28),
(54, 00000021, 'Tier 3', 'FRAN', '68', 'manus 4', 'On-Going', '2021-10-25 00:00:00', NULL, 'latup 3', NULL, 'Manus-Heavy', 'jbi 4', 'COMMENTARY', 'gc1', 'Checked', 'Task1', NULL, '2022-12-08 00:00:00', '2022-11-21 23:54:00', '2022-11-22 00:05:00', 'Completed', '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-26 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'FRAN_68_Task1_gc1', '2022-11-21 16:38:00', 10, '2022-11-22 00:13:54', 28),
(55, 00000019, 'Tier 1', 'CLSA', '192', 'FVBG', 'New', '2021-12-06 00:00:00', NULL, 'GH', '2022-11-15 00:00:00', 'Index', 'GVBHNGH', 'COMMENTARY', 'DFDF', 'Checked', 'Task1', NULL, NULL, NULL, NULL, 'Not Applicable', '2022-12-01 00:00:00', NULL, NULL, 'New', '2022-12-05 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'CLSA_192_Task1_DFDF', '2022-11-28 11:36:27', 17, '2022-11-28 13:21:09', 23),
(56, 00000022, 'Tier 3', 'BC', '60', 'BC [202,726] Termination for delay 1806021', 'On-Going', '2021-10-01 00:00:00', NULL, 'Alan Cullen', '2022-12-09 00:00:00', 'Manus-Light', 'No special instruction', 'COMMENTARY', 'Handbook', 'Checked', 'Task3', NULL, '2022-12-15 00:00:00', '2022-12-09 19:21:00', '2022-12-09 19:21:00', 'Completed', '2022-12-20 00:00:00', '2022-12-09 19:36:00', NULL, 'On-Going', '2022-12-22 00:00:00', NULL, NULL, 'New', 'New', 12, NULL, NULL, 'Task 3', 'BC_60_Task3_Handbook', '2022-12-09 17:59:59', 13, '2022-12-09 19:36:49', 4),
(57, 00000022, 'Tier 3', 'BC', '60', 'BC [200,014] Direction on drafting arbitration agreements ARBITRATION 100721; BC [201,585] LITIGATION 090721; BC [202,452] Contracting out of statutory limits STATUTE OF LIMITATIONS 140721; BC [202,803] Unconscionable time bars_080721 (For online only)', 'New', '2021-10-01 00:00:00', NULL, 'Not applicable', NULL, 'Manus-Light', 'ONLINE ONLY Task 2', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-12-15 00:00:00', NULL, NULL, 'New', '2022-12-20 00:00:00', NULL, NULL, 'New', '2022-12-22 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-12-09 18:02:18', 13, '2022-12-09 18:02:18', 13),
(58, 00000022, 'Tier 3', 'BC', '60', 'BC [200,014] Direction on drafting arbitration agreements ARBITRATION 100721; BC [201,585] LITIGATION 090721; BC [202,452] Contracting out of statutory limits STATUTE OF LIMITATIONS 140721; BC [202,803] Unconscionable time bars_080721 (For online only)', 'On-Going', '2021-10-01 00:00:00', NULL, 'Not applicable', NULL, 'Manus-Light', 'ONLINE ONLY Task 2', 'COMMENTARY', 'Handbook', 'Checked', 'Task1', NULL, '2022-12-15 00:00:00', '2022-12-09 19:01:00', '2022-12-09 19:01:00', 'Completed', '2022-12-28 00:00:00', NULL, NULL, 'New', '2022-12-30 00:00:00', NULL, NULL, 'New', 'New', 34, NULL, NULL, 'Task 1', 'BC_60_Task1_Handbook', '2022-12-09 18:04:18', 13, '2022-12-09 19:13:29', 30),
(59, 00000022, 'Tier 3', 'BC', '60', 'Index', 'New', '2021-10-01 00:00:00', NULL, 'Not applicable', '2022-12-09 00:00:00', 'Index', 'INDEX Task 2', 'COMMENTARY', 'INDEX', 'Checked', 'Task2', NULL, NULL, NULL, NULL, 'Not Applicable', '2022-12-14 00:00:00', '2022-12-09 20:30:00', '2022-12-09 20:31:00', 'Completed', '2022-12-16 00:00:00', NULL, NULL, 'New', 'New', 98, NULL, NULL, NULL, 'BC_60_Task2_INDEX', '2022-12-09 18:22:54', 13, '2022-12-09 20:31:18', 5),
(60, 00000022, 'Tier 3', 'BC', '60', 'BC [201,585] LITIGATION 090721', 'On-Going', '2021-10-01 00:00:00', NULL, 'Alan Cullen', '2022-12-09 00:00:00', 'Manus-Light', 'BC Task 2 Handbook', 'COMMENTARY', 'Handbook', 'Checked', 'Task1', NULL, '2022-12-15 00:00:00', '2022-12-09 18:50:00', '2022-12-09 18:50:00', 'Completed', '2022-12-28 00:00:00', NULL, NULL, 'New', '2022-12-30 00:00:00', NULL, NULL, 'New', 'New', 8, NULL, NULL, 'Task 1', 'BC_60_Task1_Handbook', '2022-12-09 18:33:59', 13, '2022-12-09 19:13:29', 30),
(61, 00000023, 'Newsletter', 'HLB', '29.9', 'FDDF', 'New', '2021-10-08 00:00:00', NULL, 'FESDF', '2022-12-01 00:00:00', 'Ed Mns-Hvy', 'FEDFDF', 'COMMENTARY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Not Applicable', '2022-12-26 00:00:00', NULL, NULL, 'New', '2022-12-28 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-12-12 14:00:49', 17, '2022-12-12 14:00:49', 17),
(62, 00000023, 'Newsletter', 'HLB', '29.9', 'FDDF', 'New', '2021-10-08 00:00:00', NULL, 'FESDF', '2022-12-01 00:00:00', 'Ed Mns-Hvy', 'FEDFDF', 'COMMENTARY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Not Applicable', '2022-12-26 00:00:00', NULL, NULL, 'New', '2022-12-28 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-12-12 14:00:52', 17, '2022-12-12 14:00:52', 17),
(63, 00000024, 'Tier 2', 'MTN', '183', 'TEST 1', 'New', '2021-11-24 00:00:00', NULL, 'TEST 1', '2022-11-29 00:00:00', 'Ed Mns-Med', 'TEST 1', 'COMMENTARY', 'TRI', 'Checked', 'Task1', NULL, NULL, NULL, NULL, 'Not Applicable', '2022-12-19 00:00:00', NULL, NULL, 'New', '2022-12-21 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'MTN_183_Task1_TRI', '2022-12-12 14:04:47', 9, '2022-12-12 15:37:49', 28),
(64, 00000025, 'Tier 3', 'PIC', '28', 'sample1', 'New', '2021-11-04 00:00:00', NULL, 'sample1', '2022-11-28 00:00:00', 'Manus-Medium', '1.	All repealed LEGISLATION (as opposed to Commentary) will be stored together in a new Tab/guidecard called “Repealed Legislation” which will be positioned at the end of the table of contents – so it will be after ‘Building Energy Efficiency Disclosure Legislation’.', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-29 00:00:00', NULL, NULL, 'New', '2023-01-02 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-12-12 15:12:09', 15, '2022-12-12 15:12:09', 15),
(65, 00000025, 'Tier 3', 'PIC', '28', 'sample 2', 'New', '2021-11-04 00:00:00', NULL, 'latup 2', '2022-12-12 00:00:00', 'Manus-Medium', '2.	Use the existing para0 numbers without changing the number BUT add “REP” to the front of each para0. Please let the code that is printed “[Repealed]”\nExample for the first para0 of the Clean Energy Act 2011 becomes [REP 400,100] 1 Short title [Repealed]\n[This means when customers search online they see REP in the search list, and it links all the numbers to the ‘Repealed Legislation’ tab on the table of cases]', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-29 00:00:00', NULL, NULL, 'New', '2023-01-02 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-12-12 15:12:38', 15, '2022-12-12 15:12:38', 15),
(66, 00000026, 'Tier 2', 'CFN', '162', 'Arbitration', 'New', '2021-10-15 00:00:00', NULL, 'Lishan Ang', '2022-12-09 00:00:00', 'Manus-Medium', 'CFN Task 1 ARB', 'COMMENTARY', NULL, NULL, NULL, NULL, '2022-12-22 00:00:00', NULL, NULL, 'New', '2022-12-29 00:00:00', NULL, NULL, 'New', '2023-01-02 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2022-12-12 15:22:16', 15, '2022-12-12 15:22:16', 15),
(67, 00000027, 'Tier 2', 'CPACT', '132', 'test!', 'New', '2021-11-05 00:00:00', NULL, 'Test 1', '2022-12-07 00:00:00', 'Ed Mns-Hvy', 'Test 2', 'COMMENTARY', 'CHILD', 'Checked', 'Task1', NULL, NULL, NULL, NULL, 'Not Applicable', '2022-12-27 00:00:00', NULL, NULL, 'New', '2022-12-29 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'CPACT_132_Task1_CHILD', '2022-12-13 13:50:24', 9, '2022-12-13 13:57:16', 28),
(68, 00000028, 'Tier 2', 'ACTD', '85', 'Index', 'New', '2021-10-29 00:00:00', NULL, 'Ulala has updated the following commentary to:\n\n', '2023-01-05 00:00:00', 'Index', 'N/A', 'COMMENTARY', 'FOLLOW', 'Checked', 'Task1', NULL, NULL, NULL, NULL, 'Not Applicable', '2023-01-10 00:00:00', NULL, NULL, 'New', '2023-01-12 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'ACTD_85_Task1_FOLLOW', '2023-01-05 07:08:03', 9, '2023-01-05 07:21:19', 28),
(69, 00000029, 'Tier 1', 'CLWA', '213', 'Try manuscript', 'New', '2021-11-25 00:00:00', NULL, 'Try manuscript', '2023-01-05 00:00:00', 'Index', 'N/A', 'COMMENTARY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Not Applicable', '2023-01-10 00:00:00', NULL, NULL, 'New', '2023-01-12 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2023-01-05 07:17:21', 9, '2023-01-05 07:17:21', 9),
(70, 00000029, 'Tier 1', 'CLWA', '213', 'Try manuscript', 'New', '2021-11-25 00:00:00', NULL, 'Try manuscript', '2023-01-05 00:00:00', 'Index', 'N/A', 'COMMENTARY', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Not Applicable', '2023-01-10 00:00:00', NULL, NULL, 'New', '2023-01-12 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, NULL, '2023-01-05 07:17:44', 9, '2023-01-05 07:17:44', 9),
(71, 00000030, 'Tier 3', 'CIV', '49', 'Test1', 'On-Going', '2021-05-28 00:00:00', NULL, 'Test 1_edit', '2022-12-05 00:00:00', 'Manus-Medium', 'testing 1', 'COMMENTARY', 'Sample Guide', 'Checked', 'Task1', NULL, '2023-01-20 00:00:00', '2023-01-10 16:03:00', '2023-01-10 16:03:00', 'Completed', '2023-01-27 00:00:00', NULL, NULL, 'New', '2023-01-31 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'CIV_49_Task1_Sample Guide', '2023-01-10 15:58:44', 10, '2023-01-10 16:06:56', 27),
(72, 00000030, 'Tier 3', 'CIV', '49', 'test 2', 'On-Going', '2021-05-28 00:00:00', NULL, 'test2', '2023-01-01 00:00:00', 'Manus-Light', 'test 2', 'COMMENTARY', 'Sample Guide', 'Checked', 'Task1', NULL, '2023-01-16 00:00:00', '2023-01-10 16:01:00', '2023-01-10 16:01:00', 'Completed', '2023-01-27 00:00:00', NULL, NULL, 'New', '2023-01-31 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'CIV_49_Task1_Sample Guide', '2023-01-10 15:59:26', 10, '2023-01-10 16:06:56', 27),
(73, 00000021, 'Tier 3', 'FRAN', '68', 'Sample title', 'On-Going', '2021-10-25 00:00:00', NULL, 'latup_edit 1', '2022-11-07 00:00:00', 'Manus-Medium', 'Sample instructions', 'COMMENTARY', 'Guide card_1', 'Checked', 'Task3', NULL, '2023-03-01 00:00:00', '2023-02-17 14:55:00', '2023-02-17 14:55:00', 'Completed', '2023-03-08 00:00:00', NULL, NULL, 'New', '2023-03-10 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'FRAN_68_Task3_Guide card_1', '2023-02-17 14:53:07', 10, '2023-02-17 14:57:19', 28),
(74, 00000021, 'Tier 3', 'FRAN', '68', 'sample title 2', 'On-Going', '2021-10-25 00:00:00', NULL, 'latup_1', '2022-12-07 00:00:00', 'Manus-Medium', 'sample', 'COMMENTARY', 'Guide card_1', 'Checked', 'Task3', NULL, '2023-03-01 00:00:00', '2023-02-17 14:55:00', '2023-02-17 14:55:00', 'Completed', '2023-03-08 00:00:00', NULL, NULL, 'New', '2023-03-10 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'FRAN_68_Task3_Guide card_1', '2023-02-17 14:53:34', 10, '2023-02-17 14:57:19', 28),
(75, 00000031, 'Tier 3', 'ABCE', '68', 'manus1', 'New', '2021-02-26 00:00:00', NULL, 'latup 1', '2023-03-09 00:00:00', 'Ed Mns-Lgt', 'Sepciel!@#@$%^&^*&()', 'COMMENTARY', 'guide 1', 'Checked', 'Task1', NULL, NULL, NULL, NULL, 'Not Applicable', '2023-03-15 00:00:00', NULL, NULL, 'New', '2023-03-17 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'ABCE_68_Task1_guide 1', '2023-03-01 20:42:01', 16, '2023-03-01 20:51:09', 24),
(76, 00000031, 'Tier 3', 'ABCE', '68', 'manusc _2', 'On-Going', '2021-02-26 00:00:00', NULL, 'latup_2', NULL, 'Manus-Medium', 'sAFAFGRETQERTWERTEWRTREW', 'COMMENTARY', 'guide 1', 'Checked', 'Task1', NULL, '2023-03-13 00:00:00', '2023-03-01 20:48:00', '2023-03-01 20:49:00', 'Completed', '2023-03-15 00:00:00', NULL, NULL, 'New', '2023-03-17 00:00:00', NULL, NULL, 'New', 'New', NULL, NULL, NULL, NULL, 'ABCE_68_Task1_guide 1', '2023-03-01 20:43:02', 16, '2023-03-01 20:51:09', 24);

-- --------------------------------------------------------

--
-- Table structure for table `manuscriptquery`
--

CREATE TABLE `manuscriptquery` (
  `JobID` int(11) NOT NULL,
  `QueryID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notificationstb`
--

CREATE TABLE `notificationstb` (
  `NotificationsID` int(11) NOT NULL,
  `Status` longtext DEFAULT NULL,
  `Message` longtext NOT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `FromDate` datetime(3) NOT NULL,
  `ToDate` datetime(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `producthistory`
--

CREATE TABLE `producthistory` (
  `ID` int(11) NOT NULL,
  `Details` varchar(250) NOT NULL,
  `TransactionDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `productlevel`
--

CREATE TABLE `productlevel` (
  `ProductLevelID` int(11) NOT NULL,
  `JobNumber` int(11) NOT NULL,
  `Tier` varchar(20) NOT NULL,
  `BPSProductID` varchar(20) NOT NULL,
  `ServiceNumber` varchar(100) NOT NULL,
  `TargetPressDate` datetime DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `CopyEditingStatus` varchar(200) DEFAULT NULL,
  `CodingStatus` varchar(200) DEFAULT NULL,
  `OnlineStatus` varchar(200) DEFAULT NULL,
  `STPStatus` varchar(200) DEFAULT NULL,
  `DateCreated` datetime DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `productlevel`
--

INSERT INTO `productlevel` (`ProductLevelID`, `JobNumber`, `Tier`, `BPSProductID`, `ServiceNumber`, `TargetPressDate`, `ActualPressDate`, `CopyEditingStatus`, `CodingStatus`, `OnlineStatus`, `STPStatus`, `DateCreated`, `DateUpdated`) VALUES
(1, 123, 'Tier 1', 'ABCA', '33', NULL, NULL, 'OnGoing', 'OnGoing', 'OnGoing', 'OnGoing', '2022-02-12 00:00:00', '2022-03-01 00:00:00'),
(2, 124, 'Tier 1', 'ABCE', '12', NULL, NULL, 'OnGoing', 'OnGoing', 'OnGoing', 'OnGoing', '2022-02-12 00:00:00', '2022-02-12 00:00:00'),
(3, 125, 'Tier 2', 'ABCA', '34', NULL, NULL, 'OnGoing', 'OnGoing', 'OnGoing', 'OnGoing', '2022-02-12 00:00:00', '2022-02-12 00:00:00'),
(4, 126, 'Tier 3', 'ABCE', '13', NULL, NULL, 'OnGoing', 'OnGoing', 'OnGoing', 'OnGoing', '2022-02-12 00:00:00', '2022-02-12 00:00:00'),
(5, 127, 'Newsletter', 'ACTD', '68', NULL, NULL, 'OnGoing', 'OnGoing', 'OnGoing', 'OnGoing', '2022-02-12 00:00:00', '2022-02-12 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `product_mt`
--

CREATE TABLE `product_mt` (
  `ID` int(11) NOT NULL,
  `OwnerUserID` int(11) NOT NULL,
  `LegalEditor` varchar(100) NOT NULL,
  `OriginalID` int(11) NOT NULL,
  `BPSProductID` int(11) NOT NULL,
  `ProductName` varchar(45) NOT NULL,
  `ChargeCode` varchar(45) NOT NULL,
  `TargetPressDate` datetime NOT NULL,
  `RevisedPressDate` datetime DEFAULT NULL,
  `Month` int(11) DEFAULT NULL,
  `Tier` varchar(100) DEFAULT NULL,
  `Team` varchar(50) DEFAULT NULL,
  `ServiceNo` varchar(45) NOT NULL,
  `ChargeType` varchar(100) NOT NULL,
  `BPSSublist` varchar(100) DEFAULT NULL,
  `ReasonForRevisedPressDate` varchar(200) DEFAULT NULL,
  `isSPI` smallint(6) DEFAULT NULL,
  `ServiceUpdate` varchar(45) NOT NULL,
  `ForecastPages` int(11) NOT NULL,
  `ActualPages` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `product_mt`
--

INSERT INTO `product_mt` (`ID`, `OwnerUserID`, `LegalEditor`, `OriginalID`, `BPSProductID`, `ProductName`, `ChargeCode`, `TargetPressDate`, `RevisedPressDate`, `Month`, `Tier`, `Team`, `ServiceNo`, `ChargeType`, `BPSSublist`, `ReasonForRevisedPressDate`, `isSPI`, `ServiceUpdate`, `ForecastPages`, `ActualPages`) VALUES
(1, 2, 'Masangkay, Katherine', 7, 9018123, 'ACLL', 'CLL', '2021-01-29 00:00:00', '1900-01-01 00:00:00', 1, 'Tier 2', 'Commentaries', '203', 'Annual', '9005223', NULL, 0, 'ACLL 203', 500, 500),
(2, 2, 'Masangkay, Katherine', 11, 9018100, 'ACLPP', 'LPP', '2021-03-17 00:00:00', '1900-01-01 00:00:00', 3, 'Tier 1', 'Commentaries', '212', 'Annual', '9005224', NULL, 0, 'ACLPP 212', 440, 440),
(3, 2, 'Mason, Edward', 21, 9018113, 'AEFP', 'EFP', '2021-01-04 00:00:00', '1900-01-01 00:00:00', 1, 'Tier 3', 'Commentaries', '346', 'Annual', '9005316', NULL, 0, 'AEFP 346', 440, 440);

-- --------------------------------------------------------

--
-- Table structure for table `projectmaster`
--

CREATE TABLE `projectmaster` (
  `ProjectID` int(11) NOT NULL,
  `ProjectCode` longtext NOT NULL,
  `NatureofIndustry` longtext NOT NULL,
  `ProjectName` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `publicationassignment`
--

CREATE TABLE `publicationassignment` (
  `PublicationAssignmentID` int(11) NOT NULL,
  `BPSProductID` varchar(50) NOT NULL,
  `CompleteNameOfPublication` varchar(500) DEFAULT NULL,
  `PublicationTier` varchar(50) NOT NULL,
  `PEName` varchar(200) DEFAULT NULL,
  `PEEmail` varchar(200) DEFAULT NULL,
  `PEUserName` varchar(45) NOT NULL,
  `PEStatus` varchar(50) DEFAULT NULL,
  `LEName` varchar(200) DEFAULT NULL,
  `LEEmail` varchar(200) DEFAULT NULL,
  `LEUserName` varchar(45) NOT NULL,
  `LEStatus` varchar(50) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `publicationassignment`
--

INSERT INTO `publicationassignment` (`PublicationAssignmentID`, `BPSProductID`, `CompleteNameOfPublication`, `PublicationTier`, `PEName`, `PEEmail`, `PEUserName`, `PEStatus`, `LEName`, `LEEmail`, `LEUserName`, `LEStatus`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 'ABCA', 'Austin and Black\'s Annotations to the Corporations Act', 'Tier 2', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(2, 'ABCE', 'ABC of Evidence ', 'Tier 3', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(3, 'ACLL', 'Australian Corporation Law Legislation', 'Tier 2', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(4, 'ACLPP', 'Australian Corporation Law Principles & Practices', 'Tier 1', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(5, 'ACP', 'Australian Corporation Practice', 'Tier 2', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(6, 'ACTD', 'Australian Criminal Trial Directions', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(7, 'ACV', 'Accident Compensation Victoria', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(8, 'ACVBULL', 'Accident Compensation Victoria Bulletin', 'Bulletin', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(9, 'AER', 'Australian Environment Review', 'Newsletter', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(10, 'AL', 'Australian Administrative Law', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(11, 'ALB', 'Australian Administrative Law Bulletin', 'Bulletin', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(12, 'AML', 'Anti-Money Laundering and Financial Crime', 'Tier 3', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Mannah, Johnny', 'Johnny.Mannah@Lexisnexis.Com.Au', 'Johnny.Mannah', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(13, 'ANNLR', NULL, 'Tier 3', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(14, 'ASC', 'Australian Corporations Law - ASIC Releases', 'Tier 3', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(15, 'ASDL', 'Australian Stamp Duties Law', 'Tier 2', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(16, 'ASX', NULL, 'Tier 1', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(17, 'AUE', 'Australian Uniform Evidence', 'Tier 3', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(18, 'BANK', 'Bankruptcy Law and Practice', 'Tier 2', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Mcdermott, Margaret', 'Margaret.Mcdermott@Lexisnexis.Com.Au', 'Margaret.Mcdermott', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(19, 'BC', 'Building Contracts Australia', 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Thomsen, Rose', 'Rose.Thomsen@Lexisnexis.Com.Au', 'Rose.Thomsen', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(20, 'BFL', 'Banking and Finance Laws of Australia', 'Tier 3', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Mannah, Johnny', 'Johnny.Mannah@Lexisnexis.Com.Au', 'Johnny.Mannah', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(21, 'BLA', 'Business Law of Australia', 'Tier 3', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(22, 'BRA', 'Building Regulation Australia', 'Tier 2', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Thomsen, Rose', 'Rose.Thomsen@Lexisnexis.Com.Au', 'Rose.Thomsen', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(23, 'CCL', 'Australian Consumer Credit Law', 'Tier 3', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Mcdermott, Margaret', 'Margaret.Mcdermott@Lexisnexis.Com.Au', 'Margaret.Mcdermott', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(24, 'CE', 'Cross on Evidence', 'Tier 1', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Lam, Katharine', 'Katharine.Lam@Lexisnexis.Com.Au', 'Katharine.Lam', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(25, 'CELA', 'Clean Energy Law in Australia', 'Tier 3', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(26, 'CF', 'Legal Costs - Federal Companion', 'Tier 2', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(27, 'CFL', 'Australian Corporate Finance Law', 'Tier 3', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(28, 'CFN', 'Court Forms Precedents & Pleadings NSW', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(29, 'CFQ', 'Court Forms Precedents & Pleadings Qld', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(30, 'CFV', 'Court Forms Precedents & Pleadings Vic', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(31, 'CIV', 'Civil Liability Australia', 'Tier 3', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(32, 'CL', NULL, 'Newsletter', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(33, 'CLF', 'Federal Criminal Law', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(34, 'CLP', 'Communications Law & Policy in Australia', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(35, 'CLQ', 'Carter\'s Criminal Law of Queensland', 'Tier 1', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(36, 'CLSA', 'Criminal Law South Australia', 'Tier 1', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(37, 'CLV', 'Bourke\'s Criminal Law Victoria', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(38, 'CLWA', 'Criminal Law WA', 'Tier 1', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(39, 'CN', 'Legal Costs NSW (incl. ACT)', 'Tier 2', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(40, 'COMARB', 'Australian Commercial Arbitration', 'Tier 3', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(41, 'CONN', 'Conveyancing Service NSW', 'Tier 2', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(42, 'CONT', 'Carter on Contract', 'Tier 1', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Long, Vida', 'Vida.Long@Lexisnexis.Com.Au', 'Vida.Long', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(43, 'CPACT', 'Civil Procedure ACT', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(44, 'CPPN', 'Criminal Practice and Procedure NSW', 'Tier 1', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(45, 'CPQ', 'Civil Procedure Qld', 'Tier 1', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(46, 'CPSA', 'Civil Procedure South Australia (formerly Lunn\'s)', 'Tier 1', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(47, 'CPTAS', 'Civil Procedure Tasmania', 'Tier 2', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(48, 'CPV', 'Civil Procedure Victoria', 'Tier 1', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(49, 'CPWA', 'Civil Procedure WA', 'Tier 1', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(50, 'CSA', 'Legal Costs SA', 'Tier 2', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(51, 'CV', 'Legal Costs Victoria', 'Tier 2', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(52, 'DEF', 'Australian Defamation Law and Practice', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(53, 'DEF', 'Australian Defamation Law and Practice', 'Bulletin', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(54, 'DI', 'Discovery and Interrogatories Australia', 'Tier 3', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(55, 'EP', 'Estate Planning', 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Thomsen, Rose', 'Rose.Thomsen@Lexisnexis.Com.Au', 'Rose.Thomsen', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(56, 'ERL/IRL', 'Energy and Resources Law', 'Tier 3', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(57, 'FCL', 'Australian Family Court Legislation', 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Thomsen, Rose', 'Rose.Thomsen@Lexisnexis.Com.Au', 'Rose.Thomsen', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(58, 'FCLP', 'Federal Civil Litigation Precedents', 'Tier 3', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(59, 'FIR', 'Foreign Investment Regulation in Australia', 'Tier 3', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Mcdermott, Margaret', 'Margaret.Mcdermott@Lexisnexis.Com.Au', 'Margaret.Mcdermott', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(60, 'FL', 'Australian Family Law', 'Tier 1', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Thomsen, Rose', 'Rose.Thomsen@Lexisnexis.Com.Au', 'Rose.Thomsen', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(61, 'FLSL', 'Australian Family Law State Legislation', 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Thomsen, Rose', 'Rose.Thomsen@Lexisnexis.Com.Au', 'Rose.Thomsen', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(62, 'FORD', 'Ford, Austin & Ramsay\'s Principles of Corporations Law', 'Tier 1', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(63, 'FRAN', 'Franchising Law & Practice', 'Tier 3', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(64, 'FS', 'Financial Services', 'Tier 2', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Mannah, Johnny', 'Johnny.Mannah@Lexisnexis.Com.Au', 'Johnny.Mannah', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(65, 'HCFCP', 'High Court & Federal Court Practice & Procedure', 'Tier 1', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Mcdermott, Margaret', 'Margaret.Mcdermott@Lexisnexis.Com.Au', 'Margaret.Mcdermott', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(66, 'HLB', 'Health Law Bulletin', 'Newsletter', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(67, 'ILEC', NULL, 'Tier 3', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Long, Vida', 'Vida.Long@Lexisnexis.Com.Au', 'Vida.Long', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(68, 'ILF/WFW', 'Workplace Fair Law', 'Tier 1', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(69, 'IMM', 'Australian Immigration Law', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(70, 'IN', 'Industrial Law NSW', 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(71, 'INC', NULL, 'Newsletter', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(72, 'IPC', 'Copyright and Designs', 'Tier 1', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(73, 'IPC', 'Copyright and Designs', 'Bulletin', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(74, 'IPP', 'Patents Trade Marks & Related Rights', 'Tier 1', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(75, 'IPP', 'Patents Trade Marks & Related Rights', 'Bulletin', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(76, 'IPPR', 'Intellectual Property Precedents', 'Tier 3', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(77, 'IQ', 'Industrial Law Qld', 'Tier 2', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(78, 'ISB', 'Insolvency Law Bulletin', 'Newsletter', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Patrick, Tim', 'Timothy.Patrick@Lexisnexis.Com.Au', 'Timothy.Patrick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(79, 'LAS', 'Law of Superannuation Law of Australia', 'Tier 3', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Mannah, Johnny', 'Johnny.Mannah@Lexisnexis.Com.Au', 'Johnny.Mannah', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(80, 'LGNA', 'Local Government Planning and Environment NSW (A, B, B1, C, D)', 'Tier 1', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(81, 'LGNB', 'Local Government Planning and Environment NSW (A, B, B1, C, D)', 'Tier 1', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(82, 'LGNC', 'Local Government Planning and Environment NSW (A, B, B1, C, D)', 'Tier 1', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(83, 'LGND', 'Local Government Planning and Environment NSW (A, B, B1, C, D)', 'Tier 1', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(84, 'LGR', NULL, 'Newsletter', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(85, 'LN', 'McDonald\'s Licensing and Gaming Laws NSW', 'Tier 3', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(86, 'LV', 'Bourke\'s Liquor Laws Victoria', 'Tier 3', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(87, 'MCWA', 'Magistrates Court Civil Procedure WA', 'Tier 2', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(88, 'MSL', 'Mining Safety Law in Australia', 'Tier 3', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Worswick, David', 'David.Worswick@Lexisnexis.Com.Au', 'David.Worswick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(89, 'MTN', 'Motor and Traffic Law NSW', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(90, 'MTV', 'Motor and Traffic Law Vic', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(91, 'NOHS', 'National Work Health and Safety Law', 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(92, 'NT', 'Native Title', 'Tier 2', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Mannah, Johnny', 'Johnny.Mannah@Lexisnexis.Com.Au', 'Johnny.Mannah', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(93, 'OHSN', 'Occupational Health and Safety Law NSW', 'Tier 2', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(94, 'OHSN', 'Occupational Health and Safety Law NSW', 'Bulletin', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(95, 'OSHWA', NULL, 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(96, 'PAM', 'Australian Immigration Law Procedure Advice Manuals', 'Tier 1', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(97, 'PEV', 'Planning and Environment Victoria', 'Tier 1', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(98, 'PFI/AIL', 'Australian Insurance Law Annotated', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(99, 'PIC', 'Privacy, Confidentiality and Data Security', 'Tier 3', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Nakhla, Monica', 'Monica.Nakhla@Lexisnexis.Com.Au', 'Monica.Nakhla', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(100, 'PIL', 'Kelly & Ball Principles of Insurance Law', 'Tier 2', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(101, 'PIN', 'Personal Injury Litigation NSW', 'Tier 3', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(102, 'PIQ', 'Personal Injury Litigation QLD', 'Tier 3', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(103, 'PL', 'Product Liability in Australia', 'Tier 3', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Corish, Genevieve', 'Genevieve.Corish@Lexisnexis.Com.Au', 'Genevieve.Corish', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(104, 'PLB', 'Australian Property Law Bulletin', 'Newsletter', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Patrick, Tim', 'Timothy.Patrick@Lexisnexis.Com.Au', 'Timothy.Patrick', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(105, 'PPSA', 'Personal Property Securities in Australia', 'Tier 2', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Mcdermott, Margaret', 'Margaret.Mcdermott@Lexisnexis.Com.Au', 'Margaret.Mcdermott', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(106, 'QCAT', 'Queensland Civil and Administrative Tribunal Practice & Procedure', 'Tier 3', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(107, 'REP', 'Retirement and Estate Planning Bulletin', 'Newsletter', 'Masu-ay, Renalyn', 'Renalyn.Masu-ay@straive.com', 'Renalyn.Masu-ay', 'ACTIVE', 'Thomsen, Rose', 'Rose.Thomsen@Lexisnexis.Com.Au', 'Rose.Thomsen', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(108, 'RLV', 'Retail Leases Vic', 'Tier 3', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(109, 'SENN', 'Sentencing Law NSW', 'Tier 3', 'Mercado, Chelsea Nichole', 'Chelsea.Mercado@straive.com', 'Chelsea.Mercado', 'ACTIVE', 'Ommanney, Ragnii', 'Ragnii.Ommanney@Lexisnexis.Com.Au', 'Ragnii.Ommanney', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(110, 'SMN', 'Solicitors Manual', 'Tier 2', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(111, 'TPA', 'Competition and Consumer Act Annotated', 'Tier 3', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Mcdermott, Margaret', 'Margaret.Mcdermott@Lexisnexis.Com.Au', 'Margaret.Mcdermott', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(112, 'TPP', 'Australian Tenancy Law and Practice', 'Tier 2', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(113, 'TPP', 'Australian Tenancy Law and Practice', 'Bulletin', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Hodge, Kim', 'Kim.Hodge@Lexisnexis.Com.Au', 'Kim.Hodge', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(114, 'TR', 'Takeovers and Reconstructions in Australia', 'Tier 3', 'Artajo, Patricia', 'Patricia.Artajo@straive.com', 'Patricia.Artajo', 'ACTIVE', 'Murray, Jennifer', 'Jennifer.Murray@Lexisnexis.Com.Au', 'Jennifer.Murray', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(115, 'UCPN', 'Ritchie\'s Uniform Civil Procedure NSW', 'Tier 1', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(116, 'WCN', 'Workers Compensation NSW', 'Tier 2', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(117, 'WCWA', 'Workers Compensation WA', 'Tier 2', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(118, 'WPN', 'Mason & Handler Succession Law and Practice NSW', 'Tier 1', 'Remotin, Ma. Alaiza Jane', 'AlaizaJane.Remotin@straive.com', 'AlaizaJane.Remotin', 'ACTIVE', 'Mannah, Johnny', 'Johnny.Mannah@Lexisnexis.Com.Au', 'Johnny.Mannah', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(119, 'WPV', 'Wills Probate and Administration Service Vic', 'Tier 2', 'Grande, Mark Anthony', 'MarkAnthony.Grande@straive.com', 'MarkAnthony.Grande', 'ACTIVE', 'Ernst, Reem', 'Reem.Ernst@Lexisnexis.Com.Au', 'Reem.Ernst', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(120, 'WPWA', 'Wills Probate & Administration WA', 'Tier 2', 'Antivola, Margot', 'Margot.Antivola@straive.com', 'Margot.Antivola', 'ACTIVE', 'Rogers, Kynan', 'Kynan.Rogers@Lexisnexis.Com.Au', 'Kynan.Rogers', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1),
(121, 'WRL/FIL', 'Workplace Relations Legislation', 'Tier 3', 'Reyes, Eleanor Anne', 'EleanorAnne.Reyes@straive.com', 'EleanorAnne.Reyes', 'ACTIVE', 'Hodges, Karen', 'Karen.Hodges@Lexisnexis.Com.Au', 'Karen.Hodges', 'ACTIVE', '2008-01-22 00:00:00', 1, '2008-01-22 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `pubsched_mt`
--

CREATE TABLE `pubsched_mt` (
  `PubSchedID` int(11) NOT NULL,
  `isSPI` varchar(50) NOT NULL,
  `OrderNumber` int(20) DEFAULT NULL,
  `BudgetPressMonth` varchar(50) DEFAULT NULL,
  `PubSchedTier` varchar(50) DEFAULT NULL,
  `PubSchedTeam` varchar(100) DEFAULT NULL,
  `BPSProductID` varchar(10) DEFAULT NULL,
  `LegalEditor` varchar(100) DEFAULT NULL,
  `ChargeType` varchar(20) DEFAULT NULL,
  `ProductChargeCode` varchar(20) DEFAULT NULL,
  `BPSProductIDMaster` varchar(100) DEFAULT NULL,
  `BPSSublist` varchar(100) DEFAULT NULL,
  `ServiceUpdate` varchar(1000) DEFAULT NULL,
  `BudgetPressDate` datetime DEFAULT NULL,
  `RevisedPressDate` datetime DEFAULT NULL,
  `ReasonForRevisedPressDate` varchar(1000) DEFAULT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `ForecastPages` int(50) DEFAULT NULL,
  `ActualPages` int(50) DEFAULT NULL,
  `DataFromLE` datetime DEFAULT NULL,
  `DataFromLEG` datetime DEFAULT NULL,
  `DataFromCoding` datetime DEFAULT NULL,
  `isReceived` varchar(50) DEFAULT NULL,
  `isCompleted` varchar(50) DEFAULT NULL,
  `WithRevisedPressDate` varchar(50) DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `ServiceAndBPSProductID` varchar(100) DEFAULT NULL,
  `PubSchedRemarks` varchar(1000) DEFAULT NULL,
  `YearAdded` varchar(50) DEFAULT NULL,
  `DateCreated` datetime DEFAULT NULL,
  `CreatedEmployeeID` int(11) DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `UpdatedEmployeeID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `pubsched_mt`
--

INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(1, '1', 1, 'March', 'Tier 3', 'Commentaries', 'ABCE', 'Andrew Badaoui', 'Annual', 'ABC', '9029778', '9005225', 'ABCE 68', '2021-02-26 00:00:00', '2021-03-12 00:00:00', NULL, '68', 206, 148, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '1', '2021-03-12 00:00:00', 'ABCE_68', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(2, '1', 2, 'June', 'Tier 3', 'Commentaries', 'ABCE', 'Andrew Badaoui', 'Annual', 'ABC', '9029779', '9005225', 'ABCE 69', '2021-06-25 00:00:00', NULL, NULL, '69', 206, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'ABCE_69', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(3, '1', 3, 'October', 'Tier 3', 'Commentaries', 'ABCE', 'Andrew Badaoui', 'Annual', 'ABC', '9029780', '9005225', 'ABCE 70', '2021-10-29 00:00:00', NULL, NULL, '70', 206, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'ABCE_70', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(4, '1', 4, 'April', 'Tier 2', 'Commentaries', 'ABCA', 'Olivia Zhang', 'Annual', 'ABCA', '9018120', '9005267', 'ABCA 34', '2021-04-09 00:00:00', NULL, NULL, '34', 510, 546, '2021-03-19 00:00:00', '2021-03-26 00:00:00', '2021-04-02 00:00:00', '1', '0', '0', '2021-03-16 00:00:00', 'ABCA_34', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(5, '1', 5, 'July', 'Tier 2', 'Commentaries', 'ABCA', 'Olivia Zhang', 'Annual', 'ABCA', '9018121', '9005267', 'ABCA 35', '2021-07-09 00:00:00', NULL, NULL, '35', 510, 0, '2021-06-18 00:00:00', '2021-06-25 00:00:00', '2021-07-02 00:00:00', '0', '0', '0', NULL, 'ABCA_35', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(6, '1', 6, 'October', 'Tier 2', 'Commentaries', 'ABCA', 'Olivia Zhang', 'Annual', 'ABCA', '9029782', '9005267', 'ABCA 36', '2021-10-15 00:00:00', NULL, NULL, '36', 510, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'ABCA_36', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(7, '0', 7, 'January', 'Tier 2', 'Commentaries', 'ACLL', 'Olivia Zhang', 'Annual', 'CLL', '9018123', '9005223', 'ACLL 203', '2021-01-29 00:00:00', NULL, NULL, '203', 500, 0, '2021-01-08 00:00:00', '2021-01-15 00:00:00', '2021-01-22 00:00:00', '0', '0', '0', NULL, 'ACLL_203', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(8, '1', 8, 'February', 'Tier 2', 'Commentaries', 'ACLL', 'Olivia Zhang', 'Annual', 'CLL', '9018124', '9005223', 'ACLL 204', '2021-02-08 00:00:00', NULL, NULL, '204', 500, 1060, '2021-01-18 00:00:00', '2021-01-25 00:00:00', '2021-02-01 00:00:00', '1', '0', '0', '2021-02-07 00:00:00', 'ACLL_204', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(9, '1', 9, 'June', 'Tier 2', 'Commentaries', 'ACLL', 'Olivia Zhang', 'Annual', 'CLL', '9018125', '9005223', 'ACLL 205', '2021-05-21 00:00:00', '2021-06-11 00:00:00', 'Inclusion of two leg updates', '205', 500, 0, '2021-04-30 00:00:00', '2021-05-07 00:00:00', '2021-05-14 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'ACLL_205', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(10, '1', 10, 'September', 'Tier 2', 'Commentaries', 'ACLL', 'Olivia Zhang', 'Annual', 'CLL', '9018097', '9005223', 'ACLL 206', '2021-09-24 00:00:00', NULL, NULL, '206', 500, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'ACLL_206', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(11, '0', 11, 'March', 'Tier 1', 'Commentaries', 'ACLPP', 'Olivia Zhang', 'Annual', 'LPP', '9018100', '9005224', 'ACLPP 212', '2021-03-17 00:00:00', NULL, NULL, '212', 440, 0, '2021-02-24 00:00:00', '2021-03-03 00:00:00', '2021-03-10 00:00:00', '0', '0', '0', NULL, 'ACLPP_212', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(12, '0', 12, 'July', 'Tier 1', 'Commentaries', 'ACLPP', 'Olivia Zhang', 'Annual', 'LPP', '9018101', '9005224', 'ACLPP 213', '2021-07-14 00:00:00', NULL, NULL, '213', 440, 0, '2021-06-23 00:00:00', '2021-06-30 00:00:00', '2021-07-07 00:00:00', '0', '0', '0', NULL, 'ACLPP_213', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(13, '0', 13, 'November', 'Tier 1', 'Commentaries', 'ACLPP', 'Olivia Zhang', 'Annual', 'LPP', '9029787', '9005224', 'ACLPP 214', '2021-11-17 00:00:00', NULL, NULL, '214', 440, 0, '2021-10-27 00:00:00', '2021-11-03 00:00:00', '2021-11-10 00:00:00', '0', '0', '0', NULL, 'ACLPP_214', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(14, '1', 14, 'May', 'Tier 2', 'Commentaries', 'ACP', 'Olivia Zhang', 'Annual', 'ACP', '9029790', '9005227', 'ACP 129', '2021-05-07 00:00:00', NULL, NULL, '129', 280, 0, '2021-04-16 00:00:00', '2021-04-23 00:00:00', '2021-04-30 00:00:00', '0', '0', '0', NULL, 'ACP_129', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(15, '1', 15, 'October', 'Tier 2', 'Commentaries', 'ACP', 'Olivia Zhang', 'Annual', 'ACP', '9029791', '9005227', 'ACP 130', '2021-10-15 00:00:00', NULL, NULL, '130', 280, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'ACP_130', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(16, '1', 16, 'January', 'Tier 2', 'Commentaries', 'ACV', 'Andrew Badaoui', 'Annual', 'ACV', '9018105', '9005193', 'ACV 163', '2021-01-15 00:00:00', NULL, NULL, '163', 144, 314, '2020-12-25 00:00:00', '2021-01-01 00:00:00', '2021-01-08 00:00:00', '1', '0', '0', '2021-01-13 00:00:00', 'ACV_163', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(17, '1', 17, 'June', 'Tier 2', 'Commentaries', 'ACV', 'Andrew Badaoui', 'Annual', 'ACV', '9018106', '9005193', 'ACV 164', '2021-03-26 00:00:00', '2021-06-04 00:00:00', 'As per Nina this should not be sent to press yet', '164', 144, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '1', NULL, 'ACV_164', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(18, '1', 18, 'May', 'Tier 2', 'Commentaries', 'ACV', 'Andrew Badaoui', 'Annual', 'ACV', '9018107', '9005193', 'ACV 165', '2021-05-28 00:00:00', NULL, NULL, '165', 144, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'ACV_165', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(19, '1', 19, 'August', 'Tier 2', 'Commentaries', 'ACV', 'Andrew Badaoui', 'Annual', 'ACV', '9029792', '9005193', 'ACV 166', '2021-08-20 00:00:00', NULL, NULL, '166', 144, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'ACV_166', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(20, '1', 20, 'November', 'Tier 2', 'Commentaries', 'ACV', 'Andrew Badaoui', 'Annual', 'ACV', '9029793', '9005193', 'ACV 167', '2021-11-19 00:00:00', NULL, NULL, '167', 144, 0, '2021-10-29 00:00:00', '2021-11-05 00:00:00', '2021-11-12 00:00:00', '0', '0', '0', NULL, 'ACV_167', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(21, '0', 21, 'January', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9018113', '9005316', 'AEFP 346', '2021-01-04 00:00:00', NULL, NULL, '346', 600, 0, '2020-12-14 00:00:00', '2020-12-21 00:00:00', '2020-12-28 00:00:00', '0', '0', '0', NULL, 'AEFP_346', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(22, '0', 22, 'February', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9018114', '9005316', 'AEFP 347', '2021-02-02 00:00:00', NULL, NULL, '347', 600, 0, '2021-01-12 00:00:00', '2021-01-19 00:00:00', '2021-01-26 00:00:00', '0', '0', '0', NULL, 'AEFP_347', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(23, '0', 23, 'February', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9018126', '9005316', 'AEFP 348', '2021-02-12 00:00:00', NULL, NULL, '348', 600, 0, '2021-01-22 00:00:00', '2021-01-29 00:00:00', '2021-02-05 00:00:00', '0', '0', '0', NULL, 'AEFP_348', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(24, '0', 24, 'February', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9018127', '9005316', 'AEFP 349', '2021-02-12 00:00:00', NULL, NULL, '349', 600, 0, '2021-01-22 00:00:00', '2021-01-29 00:00:00', '2021-02-05 00:00:00', '0', '0', '0', NULL, 'AEFP_349', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(25, '0', 25, 'February', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9018128', '9005316', 'AEFP 350', '2021-02-12 00:00:00', NULL, NULL, '350', 600, 0, '2021-01-22 00:00:00', '2021-01-29 00:00:00', '2021-02-05 00:00:00', '0', '0', '0', NULL, 'AEFP_350', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(26, '0', 26, 'April', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9029795', '9005316', 'AEFP 351', '2021-04-12 00:00:00', NULL, NULL, '351', 600, 0, '2021-03-22 00:00:00', '2021-03-29 00:00:00', '2021-04-05 00:00:00', '0', '0', '0', NULL, 'AEFP_351', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(27, '0', 27, 'June', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9029796', '9005316', 'AEFP 352', '2021-06-11 00:00:00', NULL, NULL, '352', 600, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'AEFP_352', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(28, '0', 28, 'August', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9029568', '9005316', 'AEFP 353', '2021-08-13 00:00:00', NULL, NULL, '353', 600, 0, '2021-07-23 00:00:00', '2021-07-30 00:00:00', '2021-08-06 00:00:00', '0', '0', '0', NULL, 'AEFP_353', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(29, '0', 29, 'October', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9029569', '9005316', 'AEFP 354', '2021-10-14 00:00:00', NULL, NULL, '354', 600, 0, '2021-09-23 00:00:00', '2021-09-30 00:00:00', '2021-10-07 00:00:00', '0', '0', '0', NULL, 'AEFP_354', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(30, '0', 30, 'November', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9029635', '9005316', 'AEFP 355', '2021-11-11 00:00:00', NULL, NULL, '355', 600, 0, '2021-10-21 00:00:00', '2021-10-28 00:00:00', '2021-11-04 00:00:00', '0', '0', '0', NULL, 'AEFP_355', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(31, '0', 31, 'December', NULL, 'Commentaries', 'AEFP', 'Edward Mason', 'Annual', 'EFP', '9029636', '9005316', 'AEFP 356', '2021-12-03 00:00:00', NULL, NULL, '356', 600, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'AEFP_356', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(32, '1', 32, 'March', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9018740', '9005301', 'AER 35.7&8', '2021-03-05 00:00:00', NULL, NULL, '35.7&8', 20, 44, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '1', '0', '0', '2021-02-26 00:00:00', 'AER_35.7&8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(33, '1', 34, 'May', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', NULL, '9031387', 'AER 35.9&10', '2021-04-05 00:00:00', '2021-05-17 00:00:00', 'waiting for updates from authors', '35.9&10', 20, 0, '2021-03-15 00:00:00', '2021-03-22 00:00:00', '2021-03-29 00:00:00', '0', '0', '1', NULL, 'AER_35.9&10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(34, '1', 35, 'May', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9030068', '9005301', 'AER 36.1', '2021-05-14 00:00:00', NULL, NULL, '36.1', 20, 0, '2021-04-23 00:00:00', '2021-04-30 00:00:00', '2021-05-07 00:00:00', '0', '0', '0', NULL, 'AER_36.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(35, '1', 36, 'June', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9030069', '9005301', 'AER 36.2', '2021-06-25 00:00:00', NULL, NULL, '36.2', 20, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'AER_36.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(36, '1', 37, 'July', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9030070', '9005301', 'AER 36.3', '2021-07-30 00:00:00', NULL, NULL, '36.3', 20, 0, '2021-07-09 00:00:00', '2021-07-16 00:00:00', '2021-07-23 00:00:00', '0', '0', '0', NULL, 'AER_36.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(37, '1', 38, 'September', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9030071', '9005301', 'AER 36.4', '2021-09-07 00:00:00', NULL, NULL, '36.4', 20, 0, '2021-08-17 00:00:00', '2021-08-24 00:00:00', '2021-08-31 00:00:00', '0', '0', '0', NULL, 'AER_36.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(38, '1', 39, 'October', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9030072', '9005301', 'AER 36.5', '2021-10-18 00:00:00', NULL, NULL, '36.5', 20, 0, '2021-09-27 00:00:00', '2021-10-04 00:00:00', '2021-10-11 00:00:00', '0', '0', '0', NULL, 'AER_36.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(39, '1', 40, 'December', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9030073', '9005301', 'AER 36.6', '2021-12-01 00:00:00', NULL, NULL, '36.6', 20, 0, '2021-11-10 00:00:00', '2021-11-17 00:00:00', '2021-11-24 00:00:00', '0', '0', '0', NULL, 'AER_36.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(40, '1', 41, 'December', 'Newsletter', 'Commentaries', 'AER', 'David Worswick', 'Annual', 'AER', '9030074', '9005301', 'AER 36.7', '2021-12-13 00:00:00', NULL, NULL, '36.7', 20, 0, '2021-11-22 00:00:00', '2021-11-29 00:00:00', '2021-12-06 00:00:00', '0', '0', '0', NULL, 'AER_36.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(41, '1', 42, 'March', 'Tier 2', 'Commentaries', 'AL', 'Ragnii Ommanney', 'Annual', 'AL', '9018131', '9005258', 'AL 184', '2021-03-19 00:00:00', NULL, NULL, '184', 222, 390, '2021-02-26 00:00:00', '2021-03-05 00:00:00', '2021-03-12 00:00:00', '1', '0', '0', '2021-03-11 00:00:00', 'AL_184', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(42, '1', 43, 'June', 'Tier 2', 'Commentaries', 'AL', 'Ragnii Ommanney', 'Annual', 'AL', '9029638', '9005258', 'AL 185', '2021-06-18 00:00:00', NULL, NULL, '185', 222, 0, '2021-05-28 00:00:00', '2021-06-04 00:00:00', '2021-06-11 00:00:00', '0', '0', '0', NULL, 'AL_185', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(43, '1', 44, 'September', 'Tier 2', 'Commentaries', 'AL', 'Ragnii Ommanney', 'Annual', 'AL', '9029639', '9005258', 'AL 186', '2021-09-17 00:00:00', NULL, NULL, '186', 222, 0, '2021-08-27 00:00:00', '2021-09-03 00:00:00', '2021-09-10 00:00:00', '0', '0', '0', NULL, 'AL_186', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(44, '0', 45, 'February', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', NULL, '9005323', 'ARM 30.10', '2021-02-24 00:00:00', NULL, NULL, '30.10', 16, 0, '2021-02-03 00:00:00', '2021-02-10 00:00:00', '2021-02-17 00:00:00', '0', '0', '0', NULL, 'ARM_30.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(45, '0', 46, 'March', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030078', '9005323', 'ARM 31.1', '2021-03-08 00:00:00', NULL, NULL, '31.1', 16, 0, '2021-02-15 00:00:00', '2021-02-22 00:00:00', '2021-03-01 00:00:00', '0', '0', '0', NULL, 'ARM_31.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(46, '0', 47, 'March', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030079', '9005323', 'ARM 31.2', '2021-03-22 00:00:00', NULL, NULL, '31.2', 16, 0, '2021-03-01 00:00:00', '2021-03-08 00:00:00', '2021-03-15 00:00:00', '0', '0', '0', NULL, 'ARM_31.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(47, '0', 48, 'April', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030080', '9005323', 'ARM 31.3', '2021-04-26 00:00:00', NULL, NULL, '31.3', 16, 0, '2021-04-05 00:00:00', '2021-04-12 00:00:00', '2021-04-19 00:00:00', '0', '0', '0', NULL, 'ARM_31.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(48, '0', 49, 'May', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030081', '9005323', 'ARM 31.4', '2021-05-24 00:00:00', NULL, NULL, '31.4', 16, 0, '2021-05-03 00:00:00', '2021-05-10 00:00:00', '2021-05-17 00:00:00', '0', '0', '0', NULL, 'ARM_31.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(49, '0', 50, 'June', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030082', '9005323', 'ARM 31.5', '2021-06-21 00:00:00', NULL, NULL, '31.5', 16, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '0', NULL, 'ARM_31.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(50, '0', 51, 'July', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030083', '9005323', 'ARM 31.6', '2021-07-26 00:00:00', NULL, NULL, '31.6', 16, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'ARM_31.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(51, '0', 52, 'August', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030084', '9005323', 'ARM 31.7', '2021-08-23 00:00:00', NULL, NULL, '31.7', 16, 0, '2021-08-02 00:00:00', '2021-08-09 00:00:00', '2021-08-16 00:00:00', '0', '0', '0', NULL, 'ARM_31.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(52, '0', 53, 'September', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030085', '9005323', 'ARM 31.8', '2021-09-20 00:00:00', NULL, NULL, '31.8', 16, 0, '2021-08-30 00:00:00', '2021-09-06 00:00:00', '2021-09-13 00:00:00', '0', '0', '0', NULL, 'ARM_31.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(53, '0', 54, 'October', NULL, 'Commentaries', 'ARM', 'Marcus Frajman', 'Annual', 'ARM', '9030086', '9005323', 'ARM 31.9', '2021-10-25 00:00:00', NULL, NULL, '31.9', 16, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'ARM_31.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(54, '1', 55, 'May', 'Tier 2', 'Commentaries', 'ASDL', 'Kim Hodge', 'Annual', 'SDL', '9018135', '9005256', 'ASDL 113', '2021-05-14 00:00:00', NULL, NULL, '113', 356, 0, '2021-04-23 00:00:00', '2021-04-30 00:00:00', '2021-05-07 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'ASDL_113', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(55, '1', 56, 'August', 'Tier 2', 'Commentaries', 'ASDL', 'Kim Hodge', 'Annual', 'SDL', '9018136', '9005256', 'ASDL 114', '2021-08-16 00:00:00', NULL, NULL, '114', 357, 0, '2021-07-26 00:00:00', '2021-08-02 00:00:00', '2021-08-09 00:00:00', '0', '0', '0', NULL, 'ASDL_114', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(56, '1', 57, 'November', 'Tier 2', 'Commentaries', 'ASDL', 'Kim Hodge', 'Annual', 'SDL', '9029642', '9005256', 'ASDL 115', '2021-11-15 00:00:00', NULL, NULL, '115', 357, 0, '2021-10-25 00:00:00', '2021-11-01 00:00:00', '2021-11-08 00:00:00', '0', '0', '0', NULL, 'ASDL_115', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(57, '0', 58, 'February', 'Tier 1', 'Commentaries', 'ASXACR', 'Vida Long', 'Annual', 'AST', '9018141', '9005270', 'ASX Clear Operating Rules 78', '2021-02-09 00:00:00', NULL, NULL, '78', 52, 0, '2021-01-19 00:00:00', '2021-01-26 00:00:00', '2021-02-02 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'ASXACR_78', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(58, '0', 59, 'August', 'Tier 1', 'Commentaries', 'ASXACR', 'Vida Long', 'Annual', 'AST', '9018142', '9005270', 'ASX Clear Operating Rules 79', '2021-08-20 00:00:00', NULL, NULL, '79', 52, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'ASXACR_79', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(59, '0', 60, 'September', 'Tier 1', 'Commentaries', 'ASXACR', 'Vida Long', 'Annual', 'AST', '9018143', '9005270', 'ASX Clear Operating Rules 80', '2021-09-09 00:00:00', NULL, NULL, '80', 52, 0, '2021-08-19 00:00:00', '2021-08-26 00:00:00', '2021-09-02 00:00:00', '0', '0', '0', NULL, 'ASXACR_80', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(60, '0', 61, 'September', 'Tier 1', 'Commentaries', 'ASXACR', 'Vida Long', 'Annual', 'AST', '9030475', '9005270', 'ASX Clear Operating Rules 81', '2021-09-23 00:00:00', NULL, NULL, '81', 52, 0, '2021-09-02 00:00:00', '2021-09-09 00:00:00', '2021-09-16 00:00:00', '0', '0', '0', NULL, 'ASXACR_81', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(61, '0', 62, 'October', 'Tier 1', 'Commentaries', 'ASXACR', 'Vida Long', 'Annual', 'AST', '9030447', '9005270', 'ASX Clear Operating Rules 82', '2021-10-07 00:00:00', NULL, NULL, '82', 52, 0, '2021-09-16 00:00:00', '2021-09-23 00:00:00', '2021-09-30 00:00:00', '0', '0', '0', NULL, 'ASXACR_82', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(62, '0', 63, 'October', 'Tier 1', 'Commentaries', 'ASXACR', 'Vida Long', 'Annual', 'AST', '9030448', '9005270', 'ASX Clear Operating Rules 83', '2021-10-21 00:00:00', NULL, NULL, '83', 52, 0, '2021-09-30 00:00:00', '2021-10-07 00:00:00', '2021-10-14 00:00:00', '0', '0', '0', NULL, 'ASXACR_83', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(63, '0', 64, 'November', 'Tier 1', 'Commentaries', 'ASXACR', 'Vida Long', 'Annual', 'AST', '9030449', '9005270', 'ASX Clear Operating Rules 84', '2021-11-18 00:00:00', NULL, NULL, '84', 52, 0, '2021-10-28 00:00:00', '2021-11-04 00:00:00', '2021-11-11 00:00:00', '0', '0', '0', NULL, 'ASXACR_84', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(64, '0', 65, 'January', 'Tier 1', 'Commentaries', 'ASXASR', 'Vida Long', 'Annual', 'AST', '9018148', '9005271', 'ASX Settlement Operating Rules 67', '2021-01-14 00:00:00', NULL, NULL, '67', 114, 0, '2020-12-24 00:00:00', '2020-12-31 00:00:00', '2021-01-07 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'ASXASR_67', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(65, '0', 66, 'July', 'Tier 1', 'Commentaries', 'ASXASR', 'Vida Long', 'Annual', 'AST', '9018149', '9005271', 'ASX Settlement Operating Rules 68', '2021-07-12 00:00:00', NULL, NULL, '68', 114, 0, '2021-06-21 00:00:00', '2021-06-28 00:00:00', '2021-07-05 00:00:00', '0', '0', '0', NULL, 'ASXASR_68', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(66, '0', 67, 'September', 'Tier 1', 'Commentaries', 'ASXASR', 'Vida Long', 'Annual', 'AST', '9018150', '9005271', 'ASX Settlement Operating Rules 69', '2021-09-03 00:00:00', NULL, NULL, '69', 114, 0, '2021-08-13 00:00:00', '2021-08-20 00:00:00', '2021-08-27 00:00:00', '0', '0', '0', NULL, 'ASXASR_69', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(67, '0', 68, 'August', 'Tier 1', 'Commentaries', 'ASXASR', 'Vida Long', 'Annual', 'AST', '9030450', '9005271', 'ASX Settlement Operating Rules 70', '2021-08-09 00:00:00', NULL, NULL, '70', 114, 0, '2021-07-19 00:00:00', '2021-07-26 00:00:00', '2021-08-02 00:00:00', '0', '0', '0', NULL, 'ASXASR_70', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(68, '0', 69, 'October', 'Tier 1', 'Commentaries', 'ASXASR', 'Vida Long', 'Annual', 'AST', '9030451', '9005271', 'ASX Settlement Operating Rules 71', '2021-10-01 00:00:00', NULL, NULL, '71', 114, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'ASXASR_71', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(69, '0', 70, 'November', 'Tier 1', 'Commentaries', 'ASXASR', 'Vida Long', 'Annual', 'AST', '9030452', '9005271', 'ASX Settlement Operating Rules 72', '2021-11-12 00:00:00', NULL, NULL, '72', 114, 0, '2021-10-22 00:00:00', '2021-10-29 00:00:00', '2021-11-05 00:00:00', '0', '0', '0', NULL, 'ASXASR_72', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(70, '0', 71, 'December', 'Tier 1', 'Commentaries', 'ASXASR', 'Vida Long', 'Annual', 'AST', '9030453', '9005271', 'ASX Settlement Operating Rules 73', '2021-12-03 00:00:00', NULL, NULL, '73', 114, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'ASXASR_73', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(71, '0', 72, 'August', 'Tier 1', 'Commentaries', 'ASXAUS', 'Vida Long', 'Annual', 'AST', NULL, '9005265', 'Austraclear Regulations 27', '2021-08-27 00:00:00', NULL, NULL, '27', 12, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'ASXAUS_27', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(72, '0', 73, 'October', 'Tier 1', 'Commentaries', 'ASXAUS', 'Vida Long', 'Annual', 'AST', NULL, '9005265', 'Austraclear Regulations 28', '2021-10-22 00:00:00', NULL, NULL, '28', 12, 0, '2021-10-01 00:00:00', '2021-10-08 00:00:00', '2021-10-15 00:00:00', '0', '0', '0', NULL, 'ASXAUS_28', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(73, '0', 74, 'November', 'Tier 1', 'Commentaries', 'ASXAUS', 'Vida Long', 'Annual', 'AST', NULL, '9005265', 'Austraclear Regulations 29', '2021-11-26 00:00:00', NULL, NULL, '29', 12, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'ASXAUS_29', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(74, '0', 75, 'October', 'Tier 1', 'Commentaries', 'ASXDMR', 'Vida Long', 'Annual', 'AST', '9018155', '9005268', 'ASX Enforcement & Appeals 8', '2021-10-21 00:00:00', NULL, NULL, '8', 6, 0, '2021-09-30 00:00:00', '2021-10-07 00:00:00', '2021-10-14 00:00:00', '0', '0', '0', NULL, 'ASXDMR_8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(75, '0', 76, 'November', 'Tier 1', 'Commentaries', 'ASXDMR', 'Vida Long', 'Annual', 'AST', '9018156', '9005268', 'ASX Enforcement & Appeals 9', '2021-11-16 00:00:00', NULL, NULL, '9', 6, 0, '2021-10-26 00:00:00', '2021-11-02 00:00:00', '2021-11-09 00:00:00', '0', '0', '0', NULL, 'ASXDMR_9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(76, '0', 77, 'November', 'Tier 1', 'Commentaries', 'ASXDMR', 'Vida Long', 'Annual', 'AST', '9030457', '9005268', 'ASX Enforcement & Appeals 10', '2021-11-26 00:00:00', NULL, NULL, '10', 6, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'ASXDMR_10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(77, '0', 78, 'August', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9018160', '9005246', 'ASX Listing Rules 66', '2021-08-13 00:00:00', NULL, NULL, '66', 258, 0, '2021-07-23 00:00:00', '2021-07-30 00:00:00', '2021-08-06 00:00:00', '0', '0', '0', NULL, 'ASXLRN_66', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(78, '0', 79, 'August', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9018161', '9005246', 'ASX Listing Rules 67', '2021-08-27 00:00:00', NULL, NULL, '67', 258, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'ASXLRN_67', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(79, '0', 80, 'September', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9018162', '9005246', 'ASX Listing Rules 68', '2021-09-06 00:00:00', NULL, NULL, '68', 258, 0, '2021-08-16 00:00:00', '2021-08-23 00:00:00', '2021-08-30 00:00:00', '0', '0', '0', NULL, 'ASXLRN_68', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(80, '0', 81, 'October', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9018163', '9005246', 'ASX Listing Rules 69', '2021-10-21 00:00:00', NULL, NULL, '69', 258, 0, '2021-09-30 00:00:00', '2021-10-07 00:00:00', '2021-10-14 00:00:00', '0', '0', '0', NULL, 'ASXLRN_69', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(81, '0', 82, 'October', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9018164', '9005246', 'ASX Listing Rules 70', '2021-10-28 00:00:00', NULL, NULL, '70', 258, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'ASXLRN_70', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(82, '0', 83, 'November', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9018165', '9005246', 'ASX Listing Rules 71', '2021-11-04 00:00:00', NULL, NULL, '71', 258, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'ASXLRN_71', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(83, '0', 84, 'November', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9018166', '9005246', 'ASX Listing Rules 72', '2021-11-11 00:00:00', NULL, NULL, '72', 258, 0, '2021-10-21 00:00:00', '2021-10-28 00:00:00', '2021-11-04 00:00:00', '0', '0', '0', NULL, 'ASXLRN_72', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(84, '0', 85, 'November', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9030459', '9005246', 'ASX Listing Rules 73', '2021-11-18 00:00:00', NULL, NULL, '73', 258, 0, '2021-10-28 00:00:00', '2021-11-04 00:00:00', '2021-11-11 00:00:00', '0', '0', '0', NULL, 'ASXLRN_73', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(85, '0', 86, 'December', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9030460', '9005246', 'ASX Listing Rules 74', '2021-12-02 00:00:00', NULL, NULL, '74', 258, 0, '2021-11-11 00:00:00', '2021-11-18 00:00:00', '2021-11-25 00:00:00', '0', '0', '0', NULL, 'ASXLRN_74', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(86, '0', 87, 'December', 'Tier 1', 'Commentaries', 'ASXLRN', 'Vida Long', 'Annual', 'AST', '9030461', '9005246', 'ASX Listing Rules 75', '2021-12-09 00:00:00', NULL, NULL, '75', 258, 0, '2021-11-18 00:00:00', '2021-11-25 00:00:00', '2021-12-02 00:00:00', '0', '0', '0', NULL, 'ASXLRN_75', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(87, '0', 88, 'September', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018168', '9005269', 'ASX Operating Rules 69', '2021-09-07 00:00:00', NULL, NULL, '69', 170, 0, '2021-08-17 00:00:00', '2021-08-24 00:00:00', '2021-08-31 00:00:00', '0', '0', '0', NULL, 'ASXMR_69', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(88, '0', 89, 'September', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018169', '9005269', 'ASX Operating Rules 70', '2021-09-21 00:00:00', NULL, NULL, '70', 170, 0, '2021-08-31 00:00:00', '2021-09-07 00:00:00', '2021-09-14 00:00:00', '0', '0', '0', NULL, 'ASXMR_70', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(89, '0', 90, 'October', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018170', '9005269', 'ASX Operating Rules 71', '2021-10-05 00:00:00', NULL, NULL, '71', 170, 0, '2021-09-14 00:00:00', '2021-09-21 00:00:00', '2021-09-28 00:00:00', '0', '0', '0', NULL, 'ASXMR_71', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(90, '0', 91, 'November', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018171', '9005269', 'ASX Operating Rules 72', '2021-11-11 00:00:00', NULL, NULL, '72', 170, 0, '2021-10-21 00:00:00', '2021-10-28 00:00:00', '2021-11-04 00:00:00', '0', '0', '0', NULL, 'ASXMR_72', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(91, '0', 92, 'November', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018172', '9005269', 'ASX Operating Rules 73', '2021-11-16 00:00:00', NULL, NULL, '73', 170, 0, '2021-10-26 00:00:00', '2021-11-02 00:00:00', '2021-11-09 00:00:00', '0', '0', '0', NULL, 'ASXMR_73', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(92, '0', 93, 'November', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018173', '9005269', 'ASX Operating Rules 74', '2021-11-25 00:00:00', NULL, NULL, '74', 170, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'ASXMR_74', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(93, '0', 94, 'December', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018174', '9005269', 'ASX Operating Rules 75', '2021-12-02 00:00:00', NULL, NULL, '75', 170, 0, '2021-11-11 00:00:00', '2021-11-18 00:00:00', '2021-11-25 00:00:00', '0', '0', '0', NULL, 'ASXMR_75', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(94, '0', 95, 'December', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018175', '9005269', 'ASX Operating Rules 76', '2021-12-06 00:00:00', NULL, NULL, '76', 170, 0, '2021-11-15 00:00:00', '2021-11-22 00:00:00', '2021-11-29 00:00:00', '0', '0', '0', NULL, 'ASXMR_76', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(95, '0', 96, 'December', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9018176', '9005269', 'ASX Operating Rules 77', '2021-12-13 00:00:00', NULL, NULL, '77', 170, 0, '2021-11-22 00:00:00', '2021-11-29 00:00:00', '2021-12-06 00:00:00', '0', '0', '0', NULL, 'ASXMR_77', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(96, '0', 97, 'December', 'Tier 1', 'Commentaries', 'ASXMR', 'Vida Long', 'Annual', 'AST', '9030463', '9005269', 'ASX Operating Rules 78', '2021-12-15 00:00:00', NULL, NULL, '78', 170, 0, '2021-11-24 00:00:00', '2021-12-01 00:00:00', '2021-12-08 00:00:00', '0', '0', '0', NULL, 'ASXMR_78', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(97, '0', 98, 'September', 'Tier 1', 'Commentaries', 'ASXR', 'Vida Long', 'Annual', 'AST', '9018177', '9005274/9005269', 'ASIC Market Integrity Rules (Securities Markets) 2', '2021-09-24 00:00:00', NULL, NULL, '2', 80, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'ASXR_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(98, '0', 99, 'September', 'Tier 1', 'Commentaries', 'ASXR2', 'Vida Long', 'Annual', 'AST', '9018178', '9005275/9005272', 'ASIC Market Integrity Rules (Futures Markets) 2', '2021-09-24 00:00:00', NULL, NULL, '2', 80, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'ASXR2_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(99, '0', 100, 'October', 'Tier 1', 'Commentaries', 'ASXREC', 'Vida Long', 'Annual', 'AST', '9018179', '9005273/9005270/9005288', 'ASX Recovery Rules 3', '2021-10-04 00:00:00', NULL, NULL, '3', 6, 0, '2021-09-13 00:00:00', '2021-09-20 00:00:00', '2021-09-27 00:00:00', '0', '0', '0', NULL, 'ASXREC_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(100, '0', 101, 'October', 'Tier 1', 'Commentaries', 'ASXREC', 'Vida Long', 'Annual', 'AST', '9018180', '9005273/9005270/9005288', 'ASX Recovery Rules 4', '2021-10-04 00:00:00', NULL, NULL, '4', 6, 0, '2021-09-13 00:00:00', '2021-09-20 00:00:00', '2021-09-27 00:00:00', '0', '0', '0', NULL, 'ASXREC_4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(101, '0', 102, 'October', 'Tier 1', 'Commentaries', 'ASXREC', 'Vida Long', 'Annual', 'AST', '9018181', '9005273/9005270/9005288', 'ASX Recovery Rules 5', '2021-10-07 00:00:00', NULL, NULL, '5', 6, 0, '2021-09-16 00:00:00', '2021-09-23 00:00:00', '2021-09-30 00:00:00', '0', '0', '0', NULL, 'ASXREC_5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(102, '0', 103, 'October', 'Tier 1', 'Commentaries', 'ASXREC', 'Vida Long', 'Annual', 'AST', '9018182', '9005273/9005270/9005288', 'ASX Recovery Rules 6', '2021-10-11 00:00:00', NULL, NULL, '6', 6, 0, '2021-09-20 00:00:00', '2021-09-27 00:00:00', '2021-10-04 00:00:00', '0', '0', '0', NULL, 'ASXREC_6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(103, '0', 104, 'October', 'Tier 1', 'Commentaries', 'ASXREC', 'Vida Long', 'Annual', 'AST', '9030467', '9005273/9005270/9005288', 'ASX Recovery Rules 7', '2021-10-14 00:00:00', NULL, NULL, '7', 6, 0, '2021-09-23 00:00:00', '2021-09-30 00:00:00', '2021-10-07 00:00:00', '0', '0', '0', NULL, 'ASXREC_7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(104, '0', 105, 'August', 'Tier 1', 'Commentaries', 'ASXSC', 'Vida Long', 'Annual', 'AST', '9018186', '9005273', 'ASX Clear (Futures) Operating Rules 59', '2021-08-05 00:00:00', NULL, NULL, '59', 128, 0, '2021-07-15 00:00:00', '2021-07-22 00:00:00', '2021-07-29 00:00:00', '0', '0', '0', NULL, 'ASXSC_59', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(105, '0', 106, 'August', 'Tier 1', 'Commentaries', 'ASXSC', 'Vida Long', 'Annual', 'AST', '9018187', '9005273', 'ASX Clear (Futures) Operating Rules 60', '2021-08-20 00:00:00', NULL, NULL, '60', 128, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'ASXSC_60', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(106, '0', 107, 'August', 'Tier 1', 'Commentaries', 'ASXSC', 'Vida Long', 'Annual', 'AST', '9018188', '9005273', 'ASX Clear (Futures) Operating Rules 61', '2021-08-27 00:00:00', NULL, NULL, '61', 128, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'ASXSC_61', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(107, '0', 108, 'September', 'Tier 1', 'Commentaries', 'ASXSC', 'Vida Long', 'Annual', 'AST', '9018189', '9005273', 'ASX Clear (Futures) Operating Rules 62', '2021-09-03 00:00:00', NULL, NULL, '62', 128, 0, '2021-08-13 00:00:00', '2021-08-20 00:00:00', '2021-08-27 00:00:00', '0', '0', '0', NULL, 'ASXSC_62', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(108, '0', 109, 'September', 'Tier 1', 'Commentaries', 'ASXSC', 'Vida Long', 'Annual', 'AST', '9030468', '9005273', 'ASX Clear (Futures) Operating Rules 63', '2021-09-14 00:00:00', NULL, NULL, '63', 128, 0, '2021-08-24 00:00:00', '2021-08-31 00:00:00', '2021-09-07 00:00:00', '0', '0', '0', NULL, 'ASXSC_63', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(109, '0', 110, 'September', 'Tier 1', 'Commentaries', 'ASXSC', 'Vida Long', 'Annual', 'AST', '9030469', '9005273', 'ASX Clear (Futures) Operating Rules 64', '2021-09-21 00:00:00', NULL, NULL, '64', 128, 0, '2021-08-31 00:00:00', '2021-09-07 00:00:00', '2021-09-14 00:00:00', '0', '0', '0', NULL, 'ASXSC_64', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(110, '0', 111, 'November', 'Tier 1', 'Commentaries', 'ASXSC', 'Vida Long', 'Annual', 'AST', '9030470', '9005273', 'ASX Clear (Futures) Operating Rules 65', '2021-11-15 00:00:00', NULL, NULL, '65', 128, 0, '2021-10-25 00:00:00', '2021-11-01 00:00:00', '2021-11-08 00:00:00', '0', '0', '0', NULL, 'ASXSC_65', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(111, '0', 112, 'April', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018194', '9005272', 'ASX 24 Operating Rules 94', '2021-04-20 00:00:00', NULL, NULL, '94', 114, 0, '2021-03-30 00:00:00', '2021-04-06 00:00:00', '2021-04-13 00:00:00', '0', '0', '0', NULL, 'ASXSOR_94', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(112, '0', 113, 'May', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018195', '9005272', 'ASX 24 Operating Rules 95', '2021-05-20 00:00:00', NULL, NULL, '95', 114, 0, '2021-04-29 00:00:00', '2021-05-06 00:00:00', '2021-05-13 00:00:00', '0', '0', '0', NULL, 'ASXSOR_95', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(113, '0', 114, 'May', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018196', '9005272', 'ASX 24 Operating Rules 96', '2021-05-28 00:00:00', NULL, NULL, '96', 114, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'ASXSOR_96', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(114, '0', 115, 'June', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018197', '9005272', 'ASX 24 Operating Rules 97', '2021-06-16 00:00:00', NULL, NULL, '97', 114, 0, '2021-05-26 00:00:00', '2021-06-02 00:00:00', '2021-06-09 00:00:00', '0', '0', '0', NULL, 'ASXSOR_97', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(115, '0', 116, 'June', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018198', '9005272', 'ASX 24 Operating Rules 98', '2021-06-24 00:00:00', NULL, NULL, '98', 114, 0, '2021-06-03 00:00:00', '2021-06-10 00:00:00', '2021-06-17 00:00:00', '0', '0', '0', NULL, 'ASXSOR_98', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(116, '0', 117, 'July', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018199', '9005272', 'ASX 24 Operating Rules 99', '2021-07-02 00:00:00', NULL, NULL, '99', 114, 0, '2021-06-11 00:00:00', '2021-06-18 00:00:00', '2021-06-25 00:00:00', '0', '0', '0', NULL, 'ASXSOR_99', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(117, '0', 118, 'July', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018200', '9005272', 'ASX 24 Operating Rules 100', '2021-07-09 00:00:00', NULL, NULL, '100', 114, 0, '2021-06-18 00:00:00', '2021-06-25 00:00:00', '2021-07-02 00:00:00', '0', '0', '0', NULL, 'ASXSOR_100', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(118, '0', 119, 'July', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9018201', '9005272', 'ASX 24 Operating Rules 101', '2021-07-27 00:00:00', NULL, NULL, '101', 114, 0, '2021-07-06 00:00:00', '2021-07-13 00:00:00', '2021-07-20 00:00:00', '0', '0', '0', NULL, 'ASXSOR_101', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(119, '0', 120, 'August', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9030471', '9005272', 'ASX 24 Operating Rules 102', '2021-08-04 00:00:00', NULL, NULL, '102', 114, 0, '2021-07-14 00:00:00', '2021-07-21 00:00:00', '2021-07-28 00:00:00', '0', '0', '0', NULL, 'ASXSOR_102', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(120, '0', 121, 'October', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9030472', '9005272', 'ASX 24 Operating Rules 103', '2021-10-14 00:00:00', NULL, NULL, '103', 114, 0, '2021-09-23 00:00:00', '2021-09-30 00:00:00', '2021-10-07 00:00:00', '0', '0', '0', NULL, 'ASXSOR_103', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(121, '0', 122, 'October', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9030473', '9005272', 'ASX 24 Operating Rules 104', '2021-10-28 00:00:00', NULL, NULL, '104', 114, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'ASXSOR_104', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(122, '0', 123, 'November', 'Tier 1', 'Commentaries', 'ASXSOR', 'Vida Long', 'Annual', 'AST', '9030474', '9005272', 'ASX 24 Operating Rules 105', '2021-11-24 00:00:00', NULL, NULL, '105', 114, 0, '2021-11-03 00:00:00', '2021-11-10 00:00:00', '2021-11-17 00:00:00', '0', '0', '0', NULL, 'ASXSOR_105', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(123, '1', 124, 'March', 'Tier 2', 'Commentaries', 'ACTD', 'Ragnii Ommanney', 'Annual', 'ATD', '9018204', '9005230', 'ACTD 82', '2021-02-26 00:00:00', '2021-03-26 00:00:00', 'the files were reviewed by the author', '82', 212, 456, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '1', '2021-03-25 00:00:00', 'ACTD_82', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(124, '1', 125, 'May', 'Tier 2', 'Commentaries', 'ACTD', 'Ragnii Ommanney', 'Annual', 'ATD', '9018205', '9005230', 'ACTD 83', '2021-05-28 00:00:00', NULL, NULL, '83', 212, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'ACTD_83', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(125, '1', 126, 'August', 'Tier 2', 'Commentaries', 'ACTD', 'Ragnii Ommanney', 'Annual', 'ATD', '9018206', '9005230', 'ACTD 84', '2021-08-13 00:00:00', NULL, NULL, '84', 212, 0, '2021-07-23 00:00:00', '2021-07-30 00:00:00', '2021-08-06 00:00:00', '0', '0', '0', NULL, 'ACTD_84', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(126, '1', 127, 'October', 'Tier 2', 'Commentaries', 'ACTD', 'Ragnii Ommanney', 'Annual', 'ATD', '9029644', '9005230', 'ACTD 85', '2021-10-29 00:00:00', NULL, NULL, '85', 212, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'ACTD_85', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(127, '1', 128, 'February', 'Tier 3', 'Commentaries', 'BC', 'Rose Thomsen', 'Annual', 'BC', '9018418', '9005180', 'BC 58', '2021-02-15 00:00:00', NULL, NULL, '58', 150, 320, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '1', '0', '0', '2021-02-15 00:00:00', 'BC_58', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(128, '1', 129, 'June', 'Tier 3', 'Commentaries', 'BC', 'Rose Thomsen', 'Annual', 'BC', '9029645', '9005180', 'BC 59', '2021-06-04 00:00:00', NULL, NULL, '59', 150, 0, '2021-05-14 00:00:00', '2021-05-21 00:00:00', '2021-05-28 00:00:00', '0', '0', '0', NULL, 'BC_59', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(129, '1', 130, 'October', 'Tier 3', 'Commentaries', 'BC', 'Rose Thomsen', 'Annual', 'BC', '9029646', '9005180', 'BC 60', '2021-10-01 00:00:00', NULL, NULL, '60', 150, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'BC_60', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(130, '0', 131, 'February', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9018260', '9005314', 'BCLB 2020 17 & 18', '2021-02-01 00:00:00', NULL, NULL, '17&18', 24, 0, '2021-01-11 00:00:00', '2021-01-18 00:00:00', '2021-01-25 00:00:00', '0', '0', '0', NULL, 'BCLB_17&18', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(131, '0', 132, 'February', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9018262', '9005314', 'BCLB 2020 19 & 20', '2021-02-25 00:00:00', NULL, NULL, '19&20', 24, 0, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '0', '0', '0', NULL, 'BCLB_19&20', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(132, '0', 133, 'March', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9018264', '9005314', 'BCLB 2020 21 & 22', '2021-03-01 00:00:00', NULL, NULL, '21&22', 24, 0, '2021-02-08 00:00:00', '2021-02-15 00:00:00', '2021-02-22 00:00:00', '0', '0', '0', NULL, 'BCLB_21&22', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(133, '0', 134, 'March', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9018266', '9005314', 'BCLB 2020 23 & 24', '2021-03-15 00:00:00', NULL, NULL, '23&24', 24, 0, '2021-02-22 00:00:00', '2021-03-01 00:00:00', '2021-03-08 00:00:00', '0', '0', '0', NULL, 'BCLB_23&24', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(134, '0', 135, 'March', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029648', '9005314', 'BCLB 2021 1 & 2', '2021-03-29 00:00:00', NULL, NULL, '1&2', 24, 0, '2021-03-08 00:00:00', '2021-03-15 00:00:00', '2021-03-22 00:00:00', '0', '0', '0', NULL, 'BCLB_1&2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(135, '0', 136, 'April', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029650', '9005314', 'BCLB 2021 3 & 4', '2021-04-12 00:00:00', NULL, NULL, '3&4', 24, 0, '2021-03-22 00:00:00', '2021-03-29 00:00:00', '2021-04-05 00:00:00', '0', '0', '0', NULL, 'BCLB_3&4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(136, '0', 137, 'April', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029652', '9005314', 'BCLB 2021 5 & 6', '2021-04-26 00:00:00', NULL, NULL, '5&6', 24, 0, '2021-04-05 00:00:00', '2021-04-12 00:00:00', '2021-04-19 00:00:00', '0', '0', '0', NULL, 'BCLB_5&6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(137, '0', 138, 'May', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029654', '9005314', 'BCLB 2021 7 & 8', '2021-05-10 00:00:00', NULL, NULL, '7&8', 24, 0, '2021-04-19 00:00:00', '2021-04-26 00:00:00', '2021-05-03 00:00:00', '0', '0', '0', NULL, 'BCLB_7&8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(138, '0', 139, 'May', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029656', '9005314', 'BCLB 2021 9 & 10', '2021-05-24 00:00:00', NULL, NULL, '9&10', 24, 0, '2021-05-03 00:00:00', '2021-05-10 00:00:00', '2021-05-17 00:00:00', '0', '0', '0', NULL, 'BCLB_9&10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(139, '0', 140, 'June', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029658', '9005314', 'BCLB 2021 11', '2021-06-07 00:00:00', NULL, NULL, '11', 24, 0, '2021-05-17 00:00:00', '2021-05-24 00:00:00', '2021-05-31 00:00:00', '0', '0', '0', NULL, 'BCLB_11', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);
INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(140, '0', 141, 'June', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029659', '9005314', 'BCLB 2021 12', '2021-06-21 00:00:00', NULL, NULL, '12', 24, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '0', NULL, 'BCLB_12', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(141, '0', 142, 'July', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029660', '9005314', 'BCLB 2021 13', '2021-07-05 00:00:00', NULL, NULL, '13', 24, 0, '2021-06-14 00:00:00', '2021-06-21 00:00:00', '2021-06-28 00:00:00', '0', '0', '0', NULL, 'BCLB_13', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(142, '0', 143, 'July', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029661', '9005314', 'BCLB 2021 14', '2021-07-19 00:00:00', NULL, NULL, '14', 24, 0, '2021-06-28 00:00:00', '2021-07-05 00:00:00', '2021-07-12 00:00:00', '0', '0', '0', NULL, 'BCLB_14', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(143, '0', 144, 'August', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', '9029662', '9005314', 'BCLB 2021 15', '2021-08-02 00:00:00', NULL, NULL, '15', 24, 0, '2021-07-12 00:00:00', '2021-07-19 00:00:00', '2021-07-26 00:00:00', '0', '0', '0', NULL, 'BCLB_15', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(144, '0', 145, 'August', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 16', '2021-08-16 00:00:00', NULL, NULL, '16', 24, 0, '2021-07-26 00:00:00', '2021-08-02 00:00:00', '2021-08-09 00:00:00', '0', '0', '0', NULL, 'BCLB_16', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(145, '0', 146, 'August', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 17', '2021-08-30 00:00:00', NULL, NULL, '17', 24, 0, '2021-08-09 00:00:00', '2021-08-16 00:00:00', '2021-08-23 00:00:00', '0', '0', '0', NULL, 'BCLB_17', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(146, '0', 147, 'September', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 18', '2021-09-13 00:00:00', NULL, NULL, '18', 24, 0, '2021-08-23 00:00:00', '2021-08-30 00:00:00', '2021-09-06 00:00:00', '0', '0', '0', NULL, 'BCLB_18', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(147, '0', 148, 'September', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 19', '2021-09-27 00:00:00', NULL, NULL, '19', 24, 0, '2021-09-06 00:00:00', '2021-09-13 00:00:00', '2021-09-20 00:00:00', '0', '0', '0', NULL, 'BCLB_19', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(148, '0', 149, 'October', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 20', '2021-10-11 00:00:00', NULL, NULL, '20', 24, 0, '2021-09-20 00:00:00', '2021-09-27 00:00:00', '2021-10-04 00:00:00', '0', '0', '0', NULL, 'BCLB_20', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(149, '0', 150, 'October', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 21', '2021-10-25 00:00:00', NULL, NULL, '21', 24, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'BCLB_21', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(150, '0', 151, 'November', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 22', '2021-11-08 00:00:00', NULL, NULL, '22', 24, 0, '2021-10-18 00:00:00', '2021-10-25 00:00:00', '2021-11-01 00:00:00', '0', '0', '0', NULL, 'BCLB_22', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(151, '0', 152, 'November', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 23', '2021-11-22 00:00:00', NULL, NULL, '23', 24, 0, '2021-11-01 00:00:00', '2021-11-08 00:00:00', '2021-11-15 00:00:00', '0', '0', '0', NULL, 'BCLB_23', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(152, '0', 153, 'December', NULL, 'Commentaries', 'BCLB', 'Olivia Zhang', 'Annual', 'BLB', NULL, '9005314', 'BCLB 2021 24', '2021-12-06 00:00:00', NULL, NULL, '24', 24, 0, '2021-11-15 00:00:00', '2021-11-22 00:00:00', '2021-11-29 00:00:00', '0', '0', '0', NULL, 'BCLB_24', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(153, '0', 154, 'February', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', NULL, '9005299', 'BFB 36.10', '2021-02-17 00:00:00', NULL, NULL, '36.10', 24, 0, '2021-01-27 00:00:00', '2021-02-03 00:00:00', '2021-02-10 00:00:00', '0', '0', '0', NULL, 'BFB_36.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(154, '0', 155, 'March', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030088', '9005299', 'BFB 37.1', '2021-03-10 00:00:00', NULL, NULL, '37.1', 24, 0, '2021-02-17 00:00:00', '2021-02-24 00:00:00', '2021-03-03 00:00:00', '0', '0', '0', NULL, 'BFB_37.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(155, '0', 156, 'April', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030089', '9005299', 'BFB 37.2', '2021-04-14 00:00:00', NULL, NULL, '37.2', 24, 0, '2021-03-24 00:00:00', '2021-03-31 00:00:00', '2021-04-07 00:00:00', '0', '0', '0', NULL, 'BFB_37.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(156, '0', 157, 'May', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030090', '9005299', 'BFB 37.3', '2021-05-12 00:00:00', NULL, NULL, '37.3', 24, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '0', NULL, 'BFB_37.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(157, '0', 158, 'June', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030091', '9005299', 'BFB 37.4', '2021-06-09 00:00:00', NULL, NULL, '37.4', 24, 0, '2021-05-19 00:00:00', '2021-05-26 00:00:00', '2021-06-02 00:00:00', '0', '0', '0', NULL, 'BFB_37.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(158, '0', 159, 'July', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030092', '9005299', 'BFB 37.5', '2021-07-14 00:00:00', NULL, NULL, '37.5', 24, 0, '2021-06-23 00:00:00', '2021-06-30 00:00:00', '2021-07-07 00:00:00', '0', '0', '0', NULL, 'BFB_37.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(159, '0', 160, 'August', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030093', '9005299', 'BFB 37.6', '2021-08-11 00:00:00', NULL, NULL, '37.6', 24, 0, '2021-07-21 00:00:00', '2021-07-28 00:00:00', '2021-08-04 00:00:00', '0', '0', '0', NULL, 'BFB_37.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(160, '0', 161, 'September', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030094', '9005299', 'BFB 37.7', '2021-09-15 00:00:00', NULL, NULL, '37.7', 24, 0, '2021-08-25 00:00:00', '2021-09-01 00:00:00', '2021-09-08 00:00:00', '0', '0', '0', NULL, 'BFB_37.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(161, '0', 162, 'October', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030095', '9005299', 'BFB 37.8', '2021-10-13 00:00:00', NULL, NULL, '37.8', 24, 0, '2021-09-22 00:00:00', '2021-09-29 00:00:00', '2021-10-06 00:00:00', '0', '0', '0', NULL, 'BFB_37.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(162, '0', 163, 'November', NULL, 'Commentaries', 'BFB', 'Shomal Prasad', 'Annual', 'BFB', '9030096', '9005299', 'BFB 37.9', '2021-11-17 00:00:00', NULL, NULL, '37.9', 24, 0, '2021-10-27 00:00:00', '2021-11-03 00:00:00', '2021-11-10 00:00:00', '0', '0', '0', NULL, 'BFB_37.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(163, '1', 164, 'May', 'Tier 2', 'Commentaries', 'BANK', 'Meg McDermott', 'Annual', 'BNK', '9018271', '9005237', 'BANK 66', '2021-03-11 00:00:00', '2021-05-18 00:00:00', 'insufficient content', '66', 152, 0, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '0', '0', '1', NULL, 'BANK_66', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(164, '1', 165, 'July', 'Tier 2', 'Commentaries', 'BANK', 'Meg McDermott', 'Annual', 'BNK', '9018272', '9005237', 'BANK 67', '2021-07-15 00:00:00', NULL, NULL, '67', 152, 0, '2021-06-24 00:00:00', '2021-07-01 00:00:00', '2021-07-08 00:00:00', '0', '0', '0', NULL, 'BANK_67', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(165, '1', 166, 'October', 'Tier 2', 'Commentaries', 'BANK', 'Meg McDermott', 'Annual', 'BNK', '9018273', '9005237', 'BANK 68', '2021-10-28 00:00:00', NULL, NULL, '68', 152, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'BANK_68', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(166, '1', 167, 'January', 'Tier 2', 'Commentaries', 'BRA', 'Rose Thomsen', 'Annual', 'BRA', '9018277', '9005173/9005210/9005211/9005212', 'BRA 150 (volume 1)  with 1x Non-Conforming and Non-Complying Building Products guidecard', '2021-01-29 00:00:00', NULL, NULL, '150', 350, 378, '2021-01-08 00:00:00', '2021-01-15 00:00:00', '2021-01-22 00:00:00', '1', '0', '0', '2021-01-28 00:00:00', 'BRA_150', '(volume 1)  with 1x Non-Conforming and Non-Complying Building Products guidecard', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(167, '1', 168, 'February', 'Tier 2', 'Commentaries', 'BRA', 'Rose Thomsen', 'Annual', 'BRA', '9029663', '9005173/9005211', 'BRA 151 (Volume 2)', '2021-02-19 00:00:00', NULL, NULL, '151', 350, 402, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '1', '0', '0', '2021-02-10 00:00:00', 'BRA_151', '(volume 1)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(168, '1', 169, 'May', 'Tier 2', 'Commentaries', 'BRA', 'Rose Thomsen', 'Annual', 'BRA', '9029664', '9005173/9005212', 'BRA 152 (Volume 3)', '2021-05-21 00:00:00', NULL, NULL, '152', 350, 520, '2021-04-30 00:00:00', '2021-05-07 00:00:00', '2021-05-14 00:00:00', '1', '0', '0', '2021-04-14 00:00:00', 'BRA_152', '(volume 1)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(169, '1', 170, 'August', 'Tier 2', 'Commentaries', 'BRA', 'Rose Thomsen', 'Annual', 'BRA', '9029665', '9005173/9005210/9005211/9005212', 'BRA 153 (Volume 1)', '2021-08-20 00:00:00', NULL, NULL, '153', 350, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'BRA_153', '(volume 1)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(170, '1', 171, 'November', 'Tier 2', 'Commentaries', 'BRA', 'Rose Thomsen', 'Annual', 'BRA', '9029666', '9005173/9005211', 'BRA 154 (volume 2)', '2021-11-19 00:00:00', NULL, NULL, '154', 350, 0, '2021-10-29 00:00:00', '2021-11-05 00:00:00', '2021-11-12 00:00:00', '0', '0', '0', NULL, 'BRA_154', '(volume 1)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(171, '1', 172, 'March', 'Tier 3', 'Commentaries', 'CCL', 'Meg McDermott', 'Annual', 'CCL', '9029667', '9005228', 'CCL 93', '2021-03-04 00:00:00', NULL, NULL, '93', 185, 286, '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2021-02-25 00:00:00', '1', '0', '0', '2021-02-19 00:00:00', 'CCL_93', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(172, '1', 173, 'September', 'Tier 3', 'Commentaries', 'CCL', 'Meg McDermott', 'Annual', 'CCL', '9029668', '9005228', 'CCL 94', '2021-09-30 00:00:00', NULL, NULL, '94', 185, 0, '2021-09-09 00:00:00', '2021-09-16 00:00:00', '2021-09-23 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'CCL_94', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(173, '0', 174, 'February', 'Tier 1', 'Commentaries', 'CE', 'Andrew Badaoui', 'Annual', 'CE', '9018283', '9005217', 'CE 214', '2021-02-26 00:00:00', NULL, NULL, '214', 320, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '0', '0', '0', NULL, 'CE_214', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(174, '0', 175, 'February', 'Tier 1', 'Commentaries', 'CE', 'Andrew Badaoui', 'Annual', 'CE', '9018284', '9005217', 'CE 215', '2021-02-26 00:00:00', NULL, NULL, '215', 320, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'CE_215', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(175, '0', 176, 'April', 'Tier 1', 'Commentaries', 'CE', 'Andrew Badaoui', 'Annual', 'CE', '9018285', '9005217', 'CE 216', '2021-04-23 00:00:00', NULL, NULL, '216', 320, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '0', '0', '0', NULL, 'CE_216', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(176, '0', 177, 'June', 'Tier 1', 'Commentaries', 'CE', 'Andrew Badaoui', 'Annual', 'CE', '9029669', '9005217', 'CE 217', '2021-06-18 00:00:00', NULL, NULL, '217', 320, 0, '2021-05-28 00:00:00', '2021-06-04 00:00:00', '2021-06-11 00:00:00', '0', '0', '0', NULL, 'CE_217', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(177, '0', 178, 'August', 'Tier 1', 'Commentaries', 'CE', 'Andrew Badaoui', 'Annual', 'CE', '9029670', '9005217', 'CE 218', '2021-08-20 00:00:00', NULL, NULL, '218', 320, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'CE_218', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(178, '0', 179, 'October', 'Tier 1', 'Commentaries', 'CE', 'Andrew Badaoui', 'Annual', 'CE', '9029671', '9005217', 'CE 219', '2021-10-15 00:00:00', NULL, NULL, '219', 320, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'CE_219', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(179, '0', 180, 'December', 'Tier 1', 'Commentaries', 'CE', 'Andrew Badaoui', 'Annual', 'CE', '9029672', '9005217', 'CE 220', '2021-12-10 00:00:00', NULL, NULL, '220', 320, 0, '2021-11-19 00:00:00', '2021-11-26 00:00:00', '2021-12-03 00:00:00', '0', '0', '0', NULL, 'CE_220', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(180, '1', 181, 'April', 'Tier 3', 'Commentaries', 'CFL', 'Olivia Zhang', 'Annual', 'CFL', '9018288', '9005209', 'CFL 80', '2021-03-24 00:00:00', '2021-04-09 00:00:00', 'Additional content', '80', 202, 139, '2021-03-03 00:00:00', '2021-03-10 00:00:00', '2021-03-17 00:00:00', '1', '0', '1', '2021-04-08 00:00:00', 'CFL_80', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(181, '1', 182, 'June', 'Tier 3', 'Commentaries', 'CFL', 'Olivia Zhang', 'Annual', 'CFL', '9029673', '9005209', 'CFL 81', '2021-06-23 00:00:00', NULL, NULL, '81', 202, 0, '2021-06-02 00:00:00', '2021-06-09 00:00:00', '2021-06-16 00:00:00', '0', '0', '0', NULL, 'CFL_81', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(182, '1', 183, 'September', 'Tier 3', 'Commentaries', 'CFL', 'Olivia Zhang', 'Annual', 'CFL', '9029674', '9005209', 'CFL 82', '2021-09-22 00:00:00', NULL, NULL, '82', 202, 0, '2021-09-01 00:00:00', '2021-09-08 00:00:00', '2021-09-15 00:00:00', '0', '0', '0', NULL, 'CFL_82', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(183, '1', 184, 'May', 'Tier 2', 'Commentaries', 'CFN', 'Edward Mason', 'Annual', 'CFN', '9018290', '9005196', 'CFN 159', '2021-03-12 00:00:00', '2021-05-26 00:00:00', 'Insufficient content', '159', 194, 0, '2021-02-19 00:00:00', '2021-02-26 00:00:00', '2021-03-05 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'CFN_159', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(184, '1', 185, 'June', 'Tier 2', 'Commentaries', 'CFN', 'Edward Mason', 'Annual', 'CFN', '9018291', '9005196', 'CFN 160', '2021-06-11 00:00:00', NULL, NULL, '160', 194, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'CFN_160', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(185, '1', 186, 'August', 'Tier 2', 'Commentaries', 'CFN', 'Edward Mason', 'Annual', 'CFN', '9018292', '9005196', 'CFN 161', '2021-08-20 00:00:00', NULL, NULL, '161', 194, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'CFN_161', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(186, '1', 187, 'October', 'Tier 2', 'Commentaries', 'CFN', 'Edward Mason', 'Annual', 'CFN', '9018293', '9005196', 'CFN 162', '2021-10-15 00:00:00', NULL, NULL, '162', 194, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'CFN_162', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(187, '1', 188, 'June', 'Tier 2', 'Commentaries', 'CFQ', 'Edward Mason', 'Annual', 'CFQ', '9018299', '9005197', 'CFQ 167', '2021-03-05 00:00:00', '2021-06-30 00:00:00', 'Insufficient content', '167', 228, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '1', NULL, 'CFQ_167', '3 Mar: Sent an email to LE to vary  press date, 30 Mar: sent a variance request to Production', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(188, '1', 189, 'July', 'Tier 2', 'Commentaries', 'CFQ', 'Edward Mason', 'Annual', 'CFQ', '9018300', '9005197', 'CFQ 168', '2021-04-22 00:00:00', '2021-07-30 00:00:00', 'Insufficient content', '168', 228, 0, '2021-04-01 00:00:00', '2021-04-08 00:00:00', '2021-04-15 00:00:00', '0', '0', '1', NULL, 'CFQ_168', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(189, '1', 190, 'June', 'Tier 2', 'Commentaries', 'CFQ', 'Edward Mason', 'Annual', 'CFQ', '9029677', '9005197', 'CFQ 169', '2021-06-24 00:00:00', NULL, NULL, '169', 228, 0, '2021-06-03 00:00:00', '2021-06-10 00:00:00', '2021-06-17 00:00:00', '0', '0', '0', NULL, 'CFQ_169', '6 Apr: sent an email to LE for varyign press date.', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(190, '1', 191, 'September', 'Tier 2', 'Commentaries', 'CFQ', 'Edward Mason', 'Annual', 'CFQ', '9029678', '9005197', 'CFQ 170', '2021-09-16 00:00:00', NULL, NULL, '170', 228, 0, '2021-08-26 00:00:00', '2021-09-02 00:00:00', '2021-09-09 00:00:00', '0', '0', '0', NULL, 'CFQ_170', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(191, '1', 192, 'November', 'Tier 2', 'Commentaries', 'CFQ', 'Edward Mason', 'Annual', 'CFQ', '9029679', '9005197', 'CFQ 171', '2021-11-18 00:00:00', NULL, NULL, '171', 228, 0, '2021-10-28 00:00:00', '2021-11-04 00:00:00', '2021-11-11 00:00:00', '0', '0', '0', NULL, 'CFQ_171', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(192, '1', 193, 'February', 'Tier 2', 'Commentaries', 'CFV', 'Edward Mason', 'Annual', 'CFV', '9018303', '9005226', 'CFV 148', '2021-02-25 00:00:00', NULL, NULL, '148', 204, 514, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '1', '0', '0', '2021-02-24 00:00:00', 'CFV_148', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(193, '1', 194, 'May', 'Tier 2', 'Commentaries', 'CFV', 'Edward Mason', 'Annual', 'CFV', '9018304', '9005226', 'CFV 149', '2021-04-23 00:00:00', '2021-05-14 00:00:00', 'delayed manuscripts', '149', 204, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'CFV_149', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(194, '1', 195, 'September', 'Tier 2', 'Commentaries', 'CFV', 'Edward Mason', 'Annual', 'CFV', '9018305', '9005226', 'CFV 150', '2021-09-23 00:00:00', NULL, NULL, '150', 204, 0, '2021-09-02 00:00:00', '2021-09-09 00:00:00', '2021-09-16 00:00:00', '0', '0', '0', NULL, 'CFV_150', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(195, '1', 196, 'November', 'Tier 2', 'Commentaries', 'CFV', 'Edward Mason', 'Annual', 'CFV', '9018306', '9005226', 'CFV 151', '2021-11-25 00:00:00', NULL, NULL, '151', 204, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'CFV_151', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(196, '1', 197, 'February', 'Tier 3', 'Commentaries', 'CIV', 'Andrew Badaoui', 'Annual', 'CIV', '9018309', '9005248', 'CIV 48', '2021-02-26 00:00:00', NULL, NULL, '48', 230, 216, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '0', '2021-02-24 00:00:00', 'CIV_48', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(197, '1', 198, 'May', 'Tier 3', 'Commentaries', 'CIV', 'Andrew Badaoui', 'Annual', 'CIV', NULL, '9005248', 'CIV 49', '2021-05-28 00:00:00', NULL, NULL, '49', 230, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'CIV_49', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(198, '1', 199, 'August', 'Tier 3', 'Commentaries', 'CIV', 'Andrew Badaoui', 'Annual', 'CIV', '9029684', '9005248', 'CIV 50', '2021-08-20 00:00:00', NULL, NULL, '50', 230, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'CIV_50', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(199, '1', 200, 'November', 'Tier 3', 'Commentaries', 'CIV', 'Andrew Badaoui', 'Annual', 'CIV', '9029685', '9005248', 'CIV 51', '2021-11-27 00:00:00', NULL, NULL, '51', 230, 0, '2021-11-08 00:00:00', '2021-11-15 00:00:00', '2021-11-22 00:00:00', '0', '0', '0', NULL, 'CIV_51', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(200, '0', 201, 'May', 'Newsletter', 'Commentaries', 'CL', 'Andrew Badaoui', 'Annual', 'CL', '9018784', '9005313', 'CL 16.6', '2021-05-12 00:00:00', NULL, NULL, '16.6', 16, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '0', NULL, 'CL_16.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(201, '1', 202, 'May', 'Newsletter', 'Commentaries', 'CL', 'Andrew Badaoui', 'Annual', 'CL', '9030098', '9005313', 'CL 17.1', '2021-05-12 00:00:00', NULL, NULL, '17.1', 16, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '0', NULL, 'CL_17.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(202, '1', 203, 'June', 'Newsletter', 'Commentaries', 'CL', 'Andrew Badaoui', 'Annual', 'CL', '9030099', '9005313', 'CL 17.2', '2021-06-25 00:00:00', NULL, NULL, '17.2', 16, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'CL_17.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(203, '1', 204, 'September', 'Newsletter', 'Commentaries', 'CL', 'Andrew Badaoui', 'Annual', 'CL', '9030100', '9005313', 'CL 17.3', '2021-09-17 00:00:00', NULL, NULL, '17.3', 16, 0, '2021-08-27 00:00:00', '2021-09-03 00:00:00', '2021-09-10 00:00:00', '0', '0', '0', NULL, 'CL_17.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(204, '1', 205, 'November', 'Newsletter', 'Commentaries', 'CL', 'Andrew Badaoui', 'Annual', 'CL', '9030101', '9005313', 'CL 17.4', '2021-11-12 00:00:00', NULL, NULL, '17.4', 16, 0, '2021-10-22 00:00:00', '2021-10-29 00:00:00', '2021-11-05 00:00:00', '0', '0', '0', NULL, 'CL_17.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(205, '0', 206, 'February', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9018791', '9005300', 'CLB  31.8', '2021-02-22 00:00:00', NULL, NULL, '31.8', 12, 0, '2021-02-01 00:00:00', '2021-02-08 00:00:00', '2021-02-15 00:00:00', '0', '0', '0', NULL, 'CLB_31.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(206, '0', 207, 'February', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9018792', '9005300', 'CLB  31.9', '2021-02-22 00:00:00', NULL, NULL, '31.9', 12, 0, '2021-02-01 00:00:00', '2021-02-08 00:00:00', '2021-02-15 00:00:00', '0', '0', '0', NULL, 'CLB_31.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(207, '0', 208, 'January', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9018793', '9005300', 'CLB  31.10', '2021-03-15 00:00:00', '2021-01-19 00:00:00', NULL, '31.10', 12, 0, '2021-02-22 00:00:00', '2021-03-01 00:00:00', '2021-03-08 00:00:00', '0', '0', '1', NULL, 'CLB_31.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(208, '0', 209, 'April', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9018794', '9005300', 'CLB  32.1', '2021-04-19 00:00:00', NULL, NULL, '32.1', 12, 0, '2021-03-29 00:00:00', '2021-04-05 00:00:00', '2021-04-12 00:00:00', '0', '0', '0', NULL, 'CLB_32.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(209, '0', 210, 'May', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9018795', '9005300', 'CLB  32.2', '2021-05-24 00:00:00', NULL, NULL, '32.2', 12, 0, '2021-05-03 00:00:00', '2021-05-10 00:00:00', '2021-05-17 00:00:00', '0', '0', '0', NULL, 'CLB_32.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(210, '0', 211, 'June', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9030102', '9005300', 'CLB  32.3', '2021-06-28 00:00:00', NULL, NULL, '32.3', 12, 0, '2021-06-07 00:00:00', '2021-06-14 00:00:00', '2021-06-21 00:00:00', '0', '0', '0', NULL, 'CLB_32.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(211, '0', 212, 'August', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9030103', '9005300', 'CLB  32.4', '2021-08-02 00:00:00', NULL, NULL, '32.4', 12, 0, '2021-07-12 00:00:00', '2021-07-19 00:00:00', '2021-07-26 00:00:00', '0', '0', '0', NULL, 'CLB_32.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(212, '0', 213, 'September', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9030104', '9005300', 'CLB  32.5', '2021-09-06 00:00:00', NULL, NULL, '32.5', 12, 0, '2021-08-16 00:00:00', '2021-08-23 00:00:00', '2021-08-30 00:00:00', '0', '0', '0', NULL, 'CLB_32.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(213, '0', 214, 'October', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9030105', '9005300', 'CLB  32.6', '2021-10-11 00:00:00', NULL, NULL, '32.6', 12, 0, '2021-09-20 00:00:00', '2021-09-27 00:00:00', '2021-10-04 00:00:00', '0', '0', '0', NULL, 'CLB_32.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(214, '0', 215, 'November', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9030106', '9005300', 'CLB  32.7', '2021-11-15 00:00:00', NULL, NULL, '32.7', 12, 0, '2021-10-25 00:00:00', '2021-11-01 00:00:00', '2021-11-08 00:00:00', '0', '0', '0', NULL, 'CLB_32.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(215, '0', 216, 'December', NULL, 'Commentaries', 'CLB', 'Rose Thomsen', 'Annual', 'CLB', '9030107', '9005300', 'CLB  32.8', '2021-12-06 00:00:00', NULL, NULL, '32.8', 12, 0, '2021-11-15 00:00:00', '2021-11-22 00:00:00', '2021-11-29 00:00:00', '0', '0', '0', NULL, 'CLB_32.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(216, '1', 217, 'January', 'Tier 2', 'Commentaries', 'CLF', 'Ragnii Ommanney', 'Annual', 'CLF', '9018313', '9005178', 'CLF 138', '2021-01-21 00:00:00', '2021-01-22 00:00:00', NULL, '138', 456, 938, '2020-12-31 00:00:00', '2021-01-07 00:00:00', '2021-01-14 00:00:00', '1', '0', '1', '2021-01-21 00:00:00', 'CLF_138', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(217, '1', 218, 'April', 'Tier 2', 'Commentaries', 'CLF', 'Ragnii Ommanney', 'Annual', 'CLF', '9018314', '9005178', 'CLF 139', '2021-04-16 00:00:00', NULL, NULL, '139', 456, 780, '2021-03-26 00:00:00', '2021-04-02 00:00:00', '2021-04-09 00:00:00', '1', '0', '0', '2021-04-13 00:00:00', 'CLF_139', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(218, '1', 219, 'July', 'Tier 2', 'Commentaries', 'CLF', 'Ragnii Ommanney', 'Annual', 'CLF', '9018315', '9005178', 'CLF 140', '2021-07-16 00:00:00', NULL, NULL, '140', 456, 0, '2021-06-25 00:00:00', '2021-07-02 00:00:00', '2021-07-09 00:00:00', '0', '0', '0', NULL, 'CLF_140', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(219, '1', 220, 'October', 'Tier 2', 'Commentaries', 'CLF', 'Ragnii Ommanney', 'Annual', 'CLF', '9029688', '9005178', 'CLF 141', '2021-10-15 00:00:00', NULL, NULL, '141', 456, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'CLF_141', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(220, '0', 221, 'February', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030110', '9005287/9005292', 'CLN 28/1', '2021-02-05 00:00:00', NULL, NULL, '28/1', 16, 0, '2021-01-15 00:00:00', '2021-01-22 00:00:00', '2021-01-29 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(221, '0', 222, 'March', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030111', '9005287/9005292', 'CLN 28/2', '2021-03-01 00:00:00', NULL, NULL, '28/2', 16, 0, '2021-02-08 00:00:00', '2021-02-15 00:00:00', '2021-02-22 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(222, '0', 223, 'April', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030112', '9005287/9005292', 'CLN 28/3', '2021-04-01 00:00:00', NULL, NULL, '28/3', 16, 0, '2021-03-11 00:00:00', '2021-03-18 00:00:00', '2021-03-25 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(223, '0', 224, 'May', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030113', '9005287/9005292', 'CLN 28/4', '2021-05-03 00:00:00', NULL, NULL, '28/4', 16, 0, '2021-04-12 00:00:00', '2021-04-19 00:00:00', '2021-04-26 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(224, '0', 225, 'June', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030114', '9005287/9005292', 'CLN 28/5', '2021-06-01 00:00:00', NULL, NULL, '28/5', 16, 0, '2021-05-11 00:00:00', '2021-05-18 00:00:00', '2021-05-25 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(225, '0', 226, 'July', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030115', '9005287/9005292', 'CLN 28/6', '2021-07-01 00:00:00', NULL, NULL, '28/6', 16, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(226, '0', 227, 'August', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030116', '9005287/9005292', 'CLN 28/7', '2021-08-02 00:00:00', NULL, NULL, '28/7', 16, 0, '2021-07-12 00:00:00', '2021-07-19 00:00:00', '2021-07-26 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(227, '0', 228, 'September', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030117', '9005287/9005292', 'CLN 28/8', '2021-09-01 00:00:00', NULL, NULL, '28/8', 16, 0, '2021-08-11 00:00:00', '2021-08-18 00:00:00', '2021-08-25 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(228, '0', 229, 'October', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030118', '9005287/9005292', 'CLN 28/9', '2021-10-01 00:00:00', NULL, NULL, '28/9', 16, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(229, '0', 230, 'November', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030119', '9005287/9005292', 'CLN 28/10', '2021-11-01 00:00:00', NULL, NULL, '28/10', 16, 0, '2021-10-11 00:00:00', '2021-10-18 00:00:00', '2021-10-25 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(230, '0', 231, 'December', NULL, 'Commentaries', 'CLN / CPP', 'Ragnii Ommanney', 'Annual', 'CPP', '9030120', '9005287/9005292', 'CLN 28/11', '2021-12-01 00:00:00', NULL, NULL, '28/11', 16, 0, '2021-11-10 00:00:00', '2021-11-17 00:00:00', '2021-11-24 00:00:00', '0', '0', '0', NULL, 'CLN / CPP_28/11', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(231, '0', 232, 'February', NULL, 'Commentaries', 'CLNQ / CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9030121', '9005260', 'CLNQ 25/1 (No Binder until 2022)', '2021-02-10 00:00:00', NULL, NULL, '25/1', 12, 0, '2021-01-20 00:00:00', '2021-01-27 00:00:00', '2021-02-03 00:00:00', '0', '0', '0', NULL, 'CLNQ / CLQ_25/1', '(No Binder until 2022)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(232, '0', 233, 'April', NULL, 'Commentaries', 'CLNQ / CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9030122', '9005260', 'CLNQ 25/2', '2021-04-23 00:00:00', NULL, NULL, '25/2', 12, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '0', '0', '0', NULL, 'CLNQ / CLQ_25/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(233, '0', 234, 'June', NULL, 'Commentaries', 'CLNQ / CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9030123', '9005260', 'CLNQ 25/3', '2021-06-01 00:00:00', NULL, NULL, '25/3', 12, 0, '2021-05-11 00:00:00', '2021-05-18 00:00:00', '2021-05-25 00:00:00', '0', '0', '0', NULL, 'CLNQ / CLQ_25/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(234, '0', 235, 'August', NULL, 'Commentaries', 'CLNQ / CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9030124', '9005260', 'CLNQ 25/4', '2021-08-09 00:00:00', NULL, NULL, '25/4', 12, 0, '2021-07-19 00:00:00', '2021-07-26 00:00:00', '2021-08-02 00:00:00', '0', '0', '0', NULL, 'CLNQ / CLQ_25/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(235, '0', 236, 'October', NULL, 'Commentaries', 'CLNQ / CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9029967', '9005260', 'CLNQ 25/5', '2021-10-29 00:00:00', NULL, NULL, '25/5', 12, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'CLNQ / CLQ_25/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(236, '0', 237, 'February', NULL, 'Commentaries', 'CLNV / CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9018325', '9005252', 'CLNV 20/5 (No Binder until 2022)', '2021-02-19 00:00:00', NULL, NULL, '20/5', 12, 0, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '0', '0', '0', NULL, 'CLNV / CLV_20/5', '(No Binder until 2022)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(237, '0', 238, 'February', NULL, 'Commentaries', 'CLNV / CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9029968', '9005252', 'CLNV 21/1 (No Binder until 2022)', '2021-02-19 00:00:00', NULL, NULL, '21/1', 12, 0, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '0', '0', '0', NULL, 'CLNV / CLV_21/1', '(No Binder until 2022)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(238, '0', 239, 'May', NULL, 'Commentaries', 'CLNV / CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9029969', '9005252', 'CLNV 21/2', '2021-05-07 00:00:00', NULL, NULL, '21/2', 12, 0, '2021-04-16 00:00:00', '2021-04-23 00:00:00', '2021-04-30 00:00:00', '0', '0', '0', NULL, 'CLNV / CLV_21/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(239, '0', 240, 'July', NULL, 'Commentaries', 'CLNV / CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9029970', '9005252', 'CLNV 21/3', '2021-07-16 00:00:00', NULL, NULL, '21/3', 12, 0, '2021-06-25 00:00:00', '2021-07-02 00:00:00', '2021-07-09 00:00:00', '0', '0', '0', NULL, 'CLNV / CLV_21/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(240, '0', 241, 'October', NULL, 'Commentaries', 'CLNV / CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9029971', '9005252', 'CLNV 21/4', '2021-10-01 00:00:00', NULL, NULL, '21/4', 12, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'CLNV / CLV_21/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(241, '1', 242, 'May', 'Tier 2', 'Commentaries', 'CLP', 'Genevieve Corish', 'Annual', 'CLP', '9018329', '9005261', 'CLP 210', '2021-03-30 00:00:00', '2021-05-06 00:00:00', 'EPMS-62955: CLP 210: errors in CNTNT3 and TL guidecards\' hardcopies', '210', 400, 936, '2021-03-09 00:00:00', '2021-03-16 00:00:00', '2021-03-23 00:00:00', '1', '0', '1', '2021-05-06 00:00:00', 'CLP_210', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(242, '1', 243, 'June', 'Tier 2', 'Commentaries', 'CLP', 'Genevieve Corish', 'Annual', 'CLP', '9018330', '9005261', 'CLP 211', '2021-06-29 00:00:00', NULL, NULL, '211', 400, 0, '2021-06-08 00:00:00', '2021-06-15 00:00:00', '2021-06-22 00:00:00', '0', '0', '0', NULL, 'CLP_211', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(243, '1', 244, 'August', 'Tier 2', 'Commentaries', 'CLP', 'Genevieve Corish', 'Annual', 'CLP', '9018331', '9005261', 'CLP 212', '2021-08-26 00:00:00', NULL, NULL, '212', 400, 0, '2021-08-05 00:00:00', '2021-08-12 00:00:00', '2021-08-19 00:00:00', '0', '0', '0', NULL, 'CLP_212', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(244, '1', 245, 'October', 'Tier 2', 'Commentaries', 'CLP', 'Genevieve Corish', 'Annual', 'CLP', '9029689', '9005261', 'CLP 213', '2021-10-28 00:00:00', NULL, NULL, '213', 400, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'CLP_213', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(245, '0', 246, 'February', 'Tier 1', 'Commentaries', 'CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9018335', '9005260', 'CLQ 201', '2021-02-12 00:00:00', NULL, NULL, '201', 450, 426, '2021-01-22 00:00:00', '2021-01-29 00:00:00', '2021-02-05 00:00:00', '1', '0', '0', '2021-02-08 00:00:00', 'CLQ_201', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(246, '0', 247, 'April', 'Tier 1', 'Commentaries', 'CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9018336', '9005260', 'CLQ 202', '2021-04-12 00:00:00', NULL, NULL, '202', 450, 0, '2021-03-22 00:00:00', '2021-03-29 00:00:00', '2021-04-05 00:00:00', '0', '0', '0', NULL, 'CLQ_202', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(247, '0', 248, 'June', 'Tier 1', 'Commentaries', 'CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9018337', '9005260', 'CLQ 203', '2021-06-09 00:00:00', NULL, NULL, '203', 450, 0, '2021-05-19 00:00:00', '2021-05-26 00:00:00', '2021-06-02 00:00:00', '0', '0', '0', NULL, 'CLQ_203', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(248, '0', 249, 'August', 'Tier 1', 'Commentaries', 'CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9018338', '9005260', 'CLQ 204', '2021-08-03 00:00:00', NULL, NULL, '204', 450, 0, '2021-07-13 00:00:00', '2021-07-20 00:00:00', '2021-07-27 00:00:00', '0', '0', '0', NULL, 'CLQ_204', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(249, '0', 250, 'September', 'Tier 1', 'Commentaries', 'CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9018339', '9005260', 'CLQ 205', '2021-09-20 00:00:00', NULL, NULL, '205', 450, 0, '2021-08-30 00:00:00', '2021-09-06 00:00:00', '2021-09-13 00:00:00', '0', '0', '0', NULL, 'CLQ_205', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(250, '0', 251, 'November', 'Tier 1', 'Commentaries', 'CLQ', 'Kim Hodge', 'Annual', 'CLQ', '9029690', '9005260', 'CLQ 206', '2021-11-10 00:00:00', NULL, NULL, '206', 450, 0, '2021-10-20 00:00:00', '2021-10-27 00:00:00', '2021-11-03 00:00:00', '0', '0', '0', NULL, 'CLQ_206', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(251, '0', 252, 'March', 'Tier 1', 'Commentaries', 'CLSA', 'David Worswick', 'Annual', 'CLS', '9018342', '9005221', 'CLSA 188', '2021-03-08 00:00:00', NULL, NULL, '188', 416, 0, '2021-02-15 00:00:00', '2021-02-22 00:00:00', '2021-03-01 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'CLSA_188', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(252, '0', 253, 'May', 'Tier 1', 'Commentaries', 'CLSA', 'David Worswick', 'Annual', 'CLS', '9018343', '9005221', 'CLSA 189', '2021-05-18 00:00:00', NULL, NULL, '189', 416, 0, '2021-04-27 00:00:00', '2021-05-04 00:00:00', '2021-05-11 00:00:00', '0', '0', '0', NULL, 'CLSA_189', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(253, '0', 254, 'August', 'Tier 1', 'Commentaries', 'CLSA', 'David Worswick', 'Annual', 'CLS', '9018344', '9005221', 'CLSA 190', '2021-08-16 00:00:00', NULL, NULL, '190', 416, 0, '2021-07-26 00:00:00', '2021-08-02 00:00:00', '2021-08-09 00:00:00', '0', '0', '0', NULL, 'CLSA_190', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(254, '0', 255, 'October', 'Tier 1', 'Commentaries', 'CLSA', 'David Worswick', 'Annual', 'CLS', '9018345', '9005221', 'CLSA 191', '2021-10-04 00:00:00', NULL, NULL, '191', 416, 0, '2021-09-13 00:00:00', '2021-09-20 00:00:00', '2021-09-27 00:00:00', '0', '0', '0', NULL, 'CLSA_191', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(255, '0', 256, 'December', 'Tier 1', 'Commentaries', 'CLSA', 'David Worswick', 'Annual', 'CLS', '9018346', '9005221', 'CLSA 192', '2021-12-06 00:00:00', NULL, NULL, '192', 416, 0, '2021-11-15 00:00:00', '2021-11-22 00:00:00', '2021-11-29 00:00:00', '0', '0', '0', NULL, 'CLSA_192', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(256, '1', 257, 'March', 'Tier 2', 'Commentaries', 'CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9018351', '9005252', 'CLV 188 1 x GUIDECARD “Sex Work”', '2021-02-12 00:00:00', '2021-03-29 00:00:00', 'waiting for final approval from LE', '188', 620, 1004, '2021-01-22 00:00:00', '2021-01-29 00:00:00', '2021-02-05 00:00:00', '1', '0', '1', '2021-03-29 00:00:00', 'CLV_188', '1 x GUIDECARD “Sex Work”', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(257, '1', 258, 'May', 'Tier 2', 'Commentaries', 'CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9018352', '9005252', 'CLV 189', '2021-04-30 00:00:00', '2021-05-17 00:00:00', 'will be varied due to previous service has been recently sent to press (29 March) and LE confirmed to vary the service to 2nd or 3rd week of May', '189', 620, 0, '2021-04-09 00:00:00', '2021-04-16 00:00:00', '2021-04-23 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'CLV_189', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(258, '1', 259, 'June', 'Tier 2', 'Commentaries', 'CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9018353', '9005252', 'CLV 190', '2021-06-25 00:00:00', NULL, NULL, '190', 620, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'CLV_190', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(259, '1', 260, 'August', 'Tier 2', 'Commentaries', 'CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9029697', '9005252', 'CLV 191', '2021-08-20 00:00:00', NULL, NULL, '191', 620, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'CLV_191', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(260, '1', 261, 'October', 'Tier 2', 'Commentaries', 'CLV', 'Ragnii Ommanney', 'Annual', 'CLV', '9029698', '9005252', 'CLV 192', '2021-10-22 00:00:00', NULL, NULL, '192', 620, 0, '2021-10-01 00:00:00', '2021-10-08 00:00:00', '2021-10-15 00:00:00', '0', '0', '0', NULL, 'CLV_192', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(261, '0', 262, 'February', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9018357', '9005194', 'CLWA 206', '2021-01-28 00:00:00', '2021-02-09 00:00:00', NULL, '206', 500, 1092, '2021-01-07 00:00:00', '2021-01-14 00:00:00', '2021-01-21 00:00:00', '1', '0', '1', '2021-02-08 00:00:00', 'CLWA_206', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(262, '0', 263, 'March', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9018358', '9005194', 'CLWA 207', '2021-03-18 00:00:00', NULL, NULL, '207', 500, 0, '2021-02-25 00:00:00', '2021-03-04 00:00:00', '2021-03-11 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'CLWA_207', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(263, '0', 264, 'April', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9018359', '9005194', 'CLWA 208', '2021-04-29 00:00:00', NULL, NULL, '208', 500, 0, '2021-04-08 00:00:00', '2021-04-15 00:00:00', '2021-04-22 00:00:00', '0', '0', '0', NULL, 'CLWA_208', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(264, '0', 265, 'May', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9018360', '9005194', 'CLWA 209', '2021-05-27 00:00:00', NULL, NULL, '209', 500, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'CLWA_209', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(265, '0', 266, 'July', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9018361', '9005194', 'CLWA 210', '2021-07-01 00:00:00', NULL, NULL, '210', 500, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'CLWA_210', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(266, '0', 267, 'August', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9029699', '9005194', 'CLWA 211', '2021-08-19 00:00:00', NULL, NULL, '211', 500, 0, '2021-07-29 00:00:00', '2021-08-05 00:00:00', '2021-08-12 00:00:00', '0', '0', '0', NULL, 'CLWA_211', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(267, '0', 268, 'October', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9029700', '9005194', 'CLWA 212', '2021-10-07 00:00:00', NULL, NULL, '212', 500, 0, '2021-09-16 00:00:00', '2021-09-23 00:00:00', '2021-09-30 00:00:00', '0', '0', '0', NULL, 'CLWA_212', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(268, '0', 269, 'November', 'Tier 1', 'Commentaries', 'CLWA', 'Ragnii Ommanney', 'Annual', 'CLW', '9029701', '9005194', 'CLWA 213', '2021-11-25 00:00:00', NULL, NULL, '213', 500, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'CLWA_213', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(269, '1', 270, 'February', 'Tier 2', 'Commentaries', 'CN', 'Katharine Lam', 'Annual', 'CN', '9018363', '9005254', 'CN 125', '2021-02-15 00:00:00', '2021-02-15 00:00:00', NULL, '125', 100, 316, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '1', '0', '1', '2021-02-15 00:00:00', 'CN_125', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(270, '1', 271, 'June', 'Tier 2', 'Commentaries', 'CN', 'Katharine Lam', 'Annual', 'CN', '9018364', '9005254', 'CN 126', '2021-06-02 00:00:00', NULL, NULL, '126', 100, 0, '2021-05-12 00:00:00', '2021-05-19 00:00:00', '2021-05-26 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'CN_126', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(271, '1', 272, 'September', 'Tier 2', 'Commentaries', 'CN', 'Katharine Lam', 'Annual', 'CN', '9029702', '9005254', 'CN 127', '2021-09-01 00:00:00', NULL, NULL, '127', 100, 0, '2021-08-11 00:00:00', '2021-08-18 00:00:00', '2021-08-25 00:00:00', '0', '0', '0', NULL, 'CN_127', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(272, '1', 273, 'April', 'Tier 2', 'Commentaries', 'CONN', 'Kim Hodge', 'Annual', 'CNN', '9018367', '9005259', 'CONN 198', '2021-04-09 00:00:00', '2021-04-16 00:00:00', 'Waiting for email of LE if the tasks are ready for consolidation', '198', 240, 196, '2021-03-19 00:00:00', '2021-03-26 00:00:00', '2021-04-02 00:00:00', '1', '0', '1', '2021-04-16 00:00:00', 'CONN_198', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(273, '1', 274, 'July', 'Tier 2', 'Commentaries', 'CONN', 'Kim Hodge', 'Annual', 'CNN', '9018368', '9005259', 'CONN 199', '2021-07-15 00:00:00', NULL, NULL, '199', 240, 0, '2021-06-24 00:00:00', '2021-07-01 00:00:00', '2021-07-08 00:00:00', '0', '0', '0', NULL, 'CONN_199', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(274, '1', 275, 'October', 'Tier 2', 'Commentaries', 'CONN', 'Kim Hodge', 'Annual', 'CNN', '9029705', '9005259', 'CONN 200', '2021-10-15 00:00:00', NULL, NULL, '200', 240, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'CONN_200', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(275, '0', 276, 'February', 'Tier 1', 'Commentaries', 'CONT', 'Vida Long', 'Annual', 'CONT', '9018370', '9005213', 'CONT 53', '2021-02-01 00:00:00', '2021-02-03 00:00:00', NULL, '53', 224, 252, '2021-01-11 00:00:00', '2021-01-18 00:00:00', '2021-01-25 00:00:00', '1', '0', '1', '2021-02-03 00:00:00', 'CONT_53', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(276, '0', 277, 'April', 'Tier 1', 'Commentaries', 'CONT', 'Vida Long', 'Annual', 'CONT', '9018371', '9005213', 'CONT 54', '2021-04-22 00:00:00', NULL, NULL, '54', 224, 0, '2021-04-01 00:00:00', '2021-04-08 00:00:00', '2021-04-15 00:00:00', '0', '0', '0', NULL, 'CONT_54', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(277, '0', 278, 'August', 'Tier 1', 'Commentaries', 'CONT', 'Vida Long', 'Annual', 'CONT', '9029707', '9005213', 'CONT 55', '2021-08-26 00:00:00', NULL, NULL, '55', 224, 0, '2021-08-05 00:00:00', '2021-08-12 00:00:00', '2021-08-19 00:00:00', '0', '0', '0', NULL, 'CONT_55', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);
INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(278, '0', 279, 'November', 'Tier 1', 'Commentaries', 'CONT', 'Vida Long', 'Annual', 'CONT', '9029708', '9005213', 'CONT 56', '2021-11-18 00:00:00', NULL, NULL, '56', 224, 0, '2021-10-28 00:00:00', '2021-11-04 00:00:00', '2021-11-11 00:00:00', '0', '0', '0', NULL, 'CONT_56', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(279, '1', 280, 'February', 'Tier 2', 'Commentaries', 'CPACT', 'Ragnii Ommanney', 'Annual', 'CPA', '9018375', '9005216', 'CPACT 129', '2021-02-19 00:00:00', '2021-02-26 00:00:00', NULL, '129', 254, 192, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '1', '0', '1', '2021-02-26 00:00:00', 'CPACT_129', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(280, '1', 281, 'May', 'Tier 2', 'Commentaries', 'CPACT', 'Ragnii Ommanney', 'Annual', 'CPA', '9029710', '9005216', 'CPACT 130', '2021-05-13 00:00:00', NULL, NULL, '130', 254, 0, '2021-04-22 00:00:00', '2021-04-29 00:00:00', '2021-05-06 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'CPACT_130', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(281, '1', 282, 'August', 'Tier 2', 'Commentaries', 'CPACT', 'Ragnii Ommanney', 'Annual', 'CPA', '9029711', '9005216', 'CPACT 131', '2021-08-06 00:00:00', NULL, NULL, '131', 254, 0, '2021-07-16 00:00:00', '2021-07-23 00:00:00', '2021-07-30 00:00:00', '0', '0', '0', NULL, 'CPACT_131', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(282, '1', 283, 'November', 'Tier 2', 'Commentaries', 'CPACT', 'Ragnii Ommanney', 'Annual', 'CPA', '9029712', '9005216', 'CPACT 132', '2021-11-05 00:00:00', NULL, NULL, '132', 254, 0, '2021-10-15 00:00:00', '2021-10-22 00:00:00', '2021-10-29 00:00:00', '0', '0', '0', NULL, 'CPACT_132', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(283, '0', 284, 'January', 'Tier 1', 'Commentaries', 'CPPN', 'Ragnii Ommanney', 'Annual', 'CPP', '9018810', '9005287', 'CPPN 174', '2021-01-21 00:00:00', '2021-01-19 00:00:00', NULL, '174', 700, 696, '2020-12-31 00:00:00', '2021-01-07 00:00:00', '2021-01-14 00:00:00', '1', '0', '1', '2021-01-19 00:00:00', 'CPPN_174', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(284, '0', 285, 'March', 'Tier 1', 'Commentaries', 'CPPN', 'Ragnii Ommanney', 'Annual', 'CPP', '9018811', '9005287', 'CPPN 175', '2021-03-22 00:00:00', NULL, NULL, '175', 490, 1160, '2021-03-01 00:00:00', '2021-03-08 00:00:00', '2021-03-15 00:00:00', '1', '0', '0', '2021-03-18 00:00:00', 'CPPN_175', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(285, '0', 286, 'May', 'Tier 1', 'Commentaries', 'CPPN', 'Ragnii Ommanney', 'Annual', 'CPP', '9018812', '9005287', 'CPPN 176', '2021-05-20 00:00:00', NULL, NULL, '176', 486, 0, '2021-04-29 00:00:00', '2021-05-06 00:00:00', '2021-05-13 00:00:00', '0', '0', '0', NULL, 'CPPN_176', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(286, '0', 287, 'July', 'Tier 1', 'Commentaries', 'CPPN', 'Ragnii Ommanney', 'Annual', 'CPP', '9018813', '9005287', 'CPPN 177', '2021-07-08 00:00:00', NULL, NULL, '177', 486, 0, '2021-06-17 00:00:00', '2021-06-24 00:00:00', '2021-07-01 00:00:00', '0', '0', '0', NULL, 'CPPN_177', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(287, '0', 288, 'August', 'Tier 1', 'Commentaries', 'CPPN', 'Ragnii Ommanney', 'Annual', 'CPP', '9018814', '9005287', 'CPPN 178', '2021-08-12 00:00:00', NULL, NULL, '178', 486, 0, '2021-07-22 00:00:00', '2021-07-29 00:00:00', '2021-08-05 00:00:00', '0', '0', '0', NULL, 'CPPN_178', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(288, '0', 289, 'September', 'Tier 1', 'Commentaries', 'CPPN', 'Ragnii Ommanney', 'Annual', 'CPP', '9018815', '9005287', 'CPPN 179', '2021-09-23 00:00:00', NULL, NULL, '179', 486, 0, '2021-09-02 00:00:00', '2021-09-09 00:00:00', '2021-09-16 00:00:00', '0', '0', '0', NULL, 'CPPN_179', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(289, '0', 290, 'November', 'Tier 1', 'Commentaries', 'CPPN', 'Ragnii Ommanney', 'Annual', 'CPP', '9018816', '9005287', 'CPPN 180', '2021-11-04 00:00:00', NULL, NULL, '180', 486, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'CPPN_180', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(290, '0', 291, 'March', 'Tier 1', 'Commentaries', 'CPQ', 'Kim Hodge', 'Annual', 'CPQ', '9018378', '9005241', 'CPQ 107 (with Title card Vol 1 & 2)', '2021-03-03 00:00:00', NULL, NULL, '107', 284, 320, '2021-02-10 00:00:00', '2021-02-17 00:00:00', '2021-02-24 00:00:00', '1', '0', '0', '2021-03-03 00:00:00', 'CPQ_107', '(with Title card Vol 1&2)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(291, '0', 292, 'May', 'Tier 1', 'Commentaries', 'CPQ', 'Kim Hodge', 'Annual', 'CPQ', '9018379', '9005241', 'CPQ 108', '2021-05-03 00:00:00', NULL, NULL, '108', 284, 0, '2021-04-12 00:00:00', '2021-04-19 00:00:00', '2021-04-26 00:00:00', '0', '0', '0', NULL, 'CPQ_108', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(292, '0', 293, 'July', 'Tier 1', 'Commentaries', 'CPQ', 'Kim Hodge', 'Annual', 'CPQ', '9018380', '9005241', 'CPQ 109', '2021-07-06 00:00:00', NULL, NULL, '109', 284, 0, '2021-06-15 00:00:00', '2021-06-22 00:00:00', '2021-06-29 00:00:00', '0', '0', '0', NULL, 'CPQ_109', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(293, '0', 294, 'September', 'Tier 1', 'Commentaries', 'CPQ', 'Kim Hodge', 'Annual', 'CPQ', '9018381', '9005241', 'CPQ 110', '2021-09-08 00:00:00', NULL, NULL, '110', 284, 0, '2021-08-18 00:00:00', '2021-08-25 00:00:00', '2021-09-01 00:00:00', '0', '0', '0', NULL, 'CPQ_110', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(294, '0', 295, 'November', 'Tier 1', 'Commentaries', 'CPQ', 'Kim Hodge', 'Annual', 'CPQ', '9018382', '9005241', 'CPQ 111', '2021-11-10 00:00:00', NULL, NULL, '111', 284, 0, '2021-10-20 00:00:00', '2021-10-27 00:00:00', '2021-11-03 00:00:00', '0', '0', '0', NULL, 'CPQ_111', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(295, '0', 296, 'February', 'Tier 1', 'Commentaries', 'CPSA', 'David Worswick', 'Annual', 'CPS', '9018385', '9005190', 'CPSA 182', '2021-02-16 00:00:00', NULL, NULL, '182', 342, 0, '2021-01-26 00:00:00', '2021-02-02 00:00:00', '2021-02-09 00:00:00', '0', '0', '0', NULL, 'CPSA_182', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(296, '0', 297, 'April', 'Tier 1', 'Commentaries', 'CPSA', 'David Worswick', 'Annual', 'CPS', '9018386', '9005190', 'CPSA 183', '2021-04-16 00:00:00', NULL, NULL, '183', 342, 0, '2021-03-26 00:00:00', '2021-04-02 00:00:00', '2021-04-09 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'CPSA_183', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(297, '0', 298, 'July', 'Tier 1', 'Commentaries', 'CPSA', 'David Worswick', 'Annual', 'CPS', '9018387', '9005190', 'CPSA 184', '2021-07-16 00:00:00', NULL, NULL, '184', 342, 0, '2021-06-25 00:00:00', '2021-07-02 00:00:00', '2021-07-09 00:00:00', '0', '0', '0', NULL, 'CPSA_184', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(298, '0', 299, 'September', 'Tier 1', 'Commentaries', 'CPSA', 'David Worswick', 'Annual', 'CPS', '9018388', '9005190', 'CPSA 185', '2021-09-16 00:00:00', NULL, NULL, '185', 342, 0, '2021-08-26 00:00:00', '2021-09-02 00:00:00', '2021-09-09 00:00:00', '0', '0', '0', NULL, 'CPSA_185', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(299, '0', 300, 'November', 'Tier 1', 'Commentaries', 'CPSA', 'David Worswick', 'Annual', 'CPS', '9018389', '9005190', 'CPSA 186', '2021-11-25 00:00:00', NULL, NULL, '186', 342, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'CPSA_186', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(300, '1', 301, 'May', 'Tier 2', 'Commentaries', 'CPT', 'David Worswick', 'Annual', 'CPT', '9018675', '9005249', 'CPT 60', '2021-03-26 00:00:00', '2021-05-21 00:00:00', 'Query to author', '60', 104, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'CPT_60', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(301, '1', 302, 'May', 'Tier 2', 'Commentaries', 'CPT', 'David Worswick', 'Annual', 'CPT', '9018676', '9005249', 'CPT 61', '2021-05-17 00:00:00', NULL, NULL, '61', 104, 0, '2021-04-26 00:00:00', '2021-05-03 00:00:00', '2021-05-10 00:00:00', '0', '0', '0', NULL, 'CPT_61', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(302, '1', 303, 'August', 'Tier 2', 'Commentaries', 'CPT', 'David Worswick', 'Annual', 'CPT', '9029722', '9005249', 'CPT 62', '2021-08-20 00:00:00', NULL, NULL, '62', 104, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'CPT_62', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(303, '1', 304, 'November', 'Tier 2', 'Commentaries', 'CPT', 'David Worswick', 'Annual', 'CPT', '9029723', '9005249', 'CPT 63', '2021-11-30 00:00:00', NULL, NULL, '63', 104, 0, '2021-11-09 00:00:00', '2021-11-16 00:00:00', '2021-11-23 00:00:00', '0', '0', '0', NULL, 'CPT_63', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(304, '0', 305, 'February', 'Tier 1', 'Commentaries', 'CPV', 'Tim Patrick', 'Annual', 'CPV', '9018394', '9005285', 'CPV 320', '2021-02-26 00:00:00', NULL, NULL, '320', 450, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '0', '0', '0', NULL, 'CPV_320', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(305, '1', 306, 'March', 'Tier 1', 'Commentaries', 'CPV', 'Tim Patrick', 'Annual', 'CPV', '9018395', '9005285', 'CPV 321', '2021-02-26 00:00:00', '2021-03-18 00:00:00', 'Additional content to be included in the service', '321', 450, 190, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '1', '2021-03-17 00:00:00', 'CPV_321', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(306, '1', 307, 'May', 'Tier 1', 'Commentaries', 'CPV', 'Tim Patrick', 'Annual', 'CPV', '9018396', '9005285', 'CPV 322', '2021-04-23 00:00:00', '2021-05-07 00:00:00', 'Inclusion of pracmats', '322', 450, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'CPV_322', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(307, '1', 308, 'June', 'Tier 1', 'Commentaries', 'CPV', 'Tim Patrick', 'Annual', 'CPV', '9018397', '9005285', 'CPV 323', '2021-06-25 00:00:00', NULL, NULL, '323', 450, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'CPV_323', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(308, '1', 309, 'August', 'Tier 1', 'Commentaries', 'CPV', 'Tim Patrick', 'Annual', 'CPV', '9018398', '9005285', 'CPV 324', '2021-08-20 00:00:00', NULL, NULL, '324', 450, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'CPV_324', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(309, '1', 310, 'October', 'Tier 1', 'Commentaries', 'CPV', 'Tim Patrick', 'Annual', 'CPV', '9018399', '9005285', 'CPV 325', '2021-10-22 00:00:00', NULL, NULL, '325', 450, 0, '2021-10-01 00:00:00', '2021-10-08 00:00:00', '2021-10-15 00:00:00', '0', '0', '0', NULL, 'CPV_325', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(310, '1', 311, 'November', 'Tier 1', 'Commentaries', 'CPV', 'Tim Patrick', 'Annual', 'CPV', '9029724', '9005285', 'CPV 326', '2021-11-26 00:00:00', NULL, NULL, '326', 450, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'CPV_326', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(311, '0', 312, 'February', 'Tier 1', 'Commentaries', 'CPWA', 'Marcus Frajman', 'Annual', 'CPW', '9018403', '9005219', 'CPWA 189', '2021-02-15 00:00:00', NULL, NULL, '189', 250, 374, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '1', '0', '0', '2021-02-05 00:00:00', 'CPWA_189', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(312, '0', 313, 'April', 'Tier 1', 'Commentaries', 'CPWA', 'Marcus Frajman', 'Annual', 'CPW', '9018404', '9005219', 'CPWA 190 with 1 x guidecard \"Supreme Court (Arbitration) Rules', '2021-04-05 00:00:00', '2021-04-15 00:00:00', 'xml tasks incomplete', '190', 250, 576, '2021-03-15 00:00:00', '2021-03-22 00:00:00', '2021-03-29 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'CPWA_190', 'with 1 x guidecard \"Supreme Court (Arbitration) Rules', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(313, '0', 314, 'May', 'Tier 1', 'Commentaries', 'CPWA', 'Marcus Frajman', 'Annual', 'CPW', '9018405', '9005219', 'CPWA 191', '2021-05-24 00:00:00', NULL, NULL, '191', 250, 0, '2021-05-03 00:00:00', '2021-05-10 00:00:00', '2021-05-17 00:00:00', '0', '0', '0', NULL, 'CPWA_191', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(314, '0', 315, 'July', 'Tier 1', 'Commentaries', 'CPWA', 'Marcus Frajman', 'Annual', 'CPW', '9018406', '9005219', 'CPWA 192', '2021-07-19 00:00:00', NULL, NULL, '192', 250, 0, '2021-06-28 00:00:00', '2021-07-05 00:00:00', '2021-07-12 00:00:00', '0', '0', '0', NULL, 'CPWA_192', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(315, '0', 316, 'September', 'Tier 1', 'Commentaries', 'CPWA', 'Marcus Frajman', 'Annual', 'CPW', '9029728', '9005219', 'CPWA 193', '2021-09-13 00:00:00', NULL, NULL, '193', 250, 0, '2021-08-23 00:00:00', '2021-08-30 00:00:00', '2021-09-06 00:00:00', '0', '0', '0', NULL, 'CPWA_193', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(316, '0', 317, 'November', 'Tier 1', 'Commentaries', 'CPWA', 'Marcus Frajman', 'Annual', 'CPW', '9029729', '9005219', 'CPWA 194', '2021-11-22 00:00:00', NULL, NULL, '194', 250, 0, '2021-11-01 00:00:00', '2021-11-08 00:00:00', '2021-11-15 00:00:00', '0', '0', '0', NULL, 'CPWA_194', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(317, '1', 318, 'February', 'Tier 2', 'Commentaries', 'CSA', 'David Worswick', 'Annual', 'CSA', '9018407', '9005179', 'CSA 162', '2021-02-15 00:00:00', '2021-02-15 00:00:00', NULL, '162', 250, 594, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '1', '0', '1', '2021-02-15 00:00:00', 'CSA_162', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(318, '1', 319, 'May', 'Tier 2', 'Commentaries', 'CSA', 'David Worswick', 'Annual', 'CSA', '9018408', '9005179', 'CSA 163', '2021-03-15 00:00:00', '2021-05-12 00:00:00', 'delayed manuscripts; volume and complexity', '163', 250, 0, '2021-02-22 00:00:00', '2021-03-01 00:00:00', '2021-03-08 00:00:00', '0', '0', '1', NULL, 'CSA_163', '16 Mar: Sent an email to LE to vary press date and still waiiting for his reply.', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(319, '1', 320, 'May', 'Tier 2', 'Commentaries', 'CSA', 'David Worswick', 'Annual', 'CSA', '9018409', '9005179', 'CSA 164', '2021-04-30 00:00:00', '2021-05-21 00:00:00', 'issue gapping', '164', 250, 0, '2021-04-09 00:00:00', '2021-04-16 00:00:00', '2021-04-23 00:00:00', '0', '0', '1', NULL, 'CSA_164', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(320, '1', 321, 'July', 'Tier 2', 'Commentaries', 'CSA', 'David Worswick', 'Annual', 'CSA', '9018410', '9005179', 'CSA 165', '2021-07-20 00:00:00', NULL, NULL, '165', 250, 0, '2021-06-29 00:00:00', '2021-07-06 00:00:00', '2021-07-13 00:00:00', '0', '0', '0', NULL, 'CSA_165', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(321, '1', 322, 'October', 'Tier 2', 'Commentaries', 'CSA', 'David Worswick', 'Annual', 'CSA', '9029733', '9005179', 'CSA 166', '2021-10-12 00:00:00', NULL, NULL, '166', 250, 0, '2021-09-21 00:00:00', '2021-09-28 00:00:00', '2021-10-05 00:00:00', '0', '0', '0', NULL, 'CSA_166', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(322, '1', 323, 'May', 'Tier 2', 'Commentaries', 'CV/CF', 'Nina Packman', 'Annual', 'CV', '9029735', '9005186', 'CV 135/CF 127', '2021-02-22 00:00:00', '2021-05-17 00:00:00', 'awaiting for additional manuscripts', '135/127', 234, 0, '2021-02-01 00:00:00', '2021-02-08 00:00:00', '2021-02-15 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'CV/CF_135/127', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(323, '1', 324, 'August', 'Tier 2', 'Commentaries', 'CV/CF', 'Nina Packman', 'Annual', 'CV', '9029736', '9005186', 'CV 136/CF 128', '2021-08-27 00:00:00', NULL, NULL, '135/128', 234, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'CV/CF_135/128', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(324, '1', 325, 'February', 'Tier 2', 'Commentaries', 'DEF', 'Genevieve Corish', 'Annual', 'DEF', '9018207', '9005177', 'DEF 91', '2021-05-13 00:00:00', '2021-02-23 00:00:00', NULL, '91', 266, 170, '2021-04-22 00:00:00', '2021-04-29 00:00:00', '2021-05-06 00:00:00', '1', '0', '1', '2021-02-18 00:00:00', 'DEF_91', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(325, '1', 326, 'August', 'Tier 2', 'Commentaries', 'DEF', 'Genevieve Corish', 'Annual', 'DEF', '9029737', '9005177', 'DEF 92', '2021-08-12 00:00:00', NULL, NULL, '92', 266, 0, '2021-07-22 00:00:00', '2021-07-29 00:00:00', '2021-08-05 00:00:00', '0', '0', '0', NULL, 'DEF_92', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(326, '1', 327, 'November', 'Tier 2', 'Commentaries', 'DEF', 'Genevieve Corish', 'Annual', 'DEF', '9029738', '9005177', 'DEF 93', '2021-11-11 00:00:00', NULL, NULL, '93', 266, 0, '2021-10-21 00:00:00', '2021-10-28 00:00:00', '2021-11-04 00:00:00', '0', '0', '0', NULL, 'DEF_93', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(327, '0', 328, 'February', 'Tier 3', 'Commentaries', 'DI', 'Andrew Badaoui', 'Annual', 'DI', '9019182', '9005204', 'DI 73', '2021-02-26 00:00:00', NULL, NULL, '73', 200, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '0', '0', '0', NULL, 'DI_73', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(328, '1', 329, 'April', 'Tier 3', 'Commentaries', 'DI', 'Andrew Badaoui', 'Annual', 'DI', '9029739', '9005204', 'DI 74', '2021-06-25 00:00:00', '2021-04-16 00:00:00', 'LE is on leave', '74', 200, 396, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '1', '0', '1', '2021-04-16 00:00:00', 'DI_74', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(329, '1', 330, 'October', 'Tier 3', 'Commentaries', 'DI', 'Andrew Badaoui', 'Annual', 'DI', '9029740', '9005204', 'DI 75', '2021-10-29 00:00:00', NULL, NULL, '75', 200, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'DI_75', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(330, '0', 331, 'February', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', '9018822', '9005306', 'ELB 26.1', '2021-02-17 00:00:00', NULL, NULL, '26.1', 16, 0, '2021-01-27 00:00:00', '2021-02-03 00:00:00', '2021-02-10 00:00:00', '0', '0', '0', NULL, 'ELB_26.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(331, '0', 332, 'March', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', '9018823', '9005306', 'ELB 26.2', '2021-03-03 00:00:00', NULL, NULL, '26.2', 16, 0, '2021-02-10 00:00:00', '2021-02-17 00:00:00', '2021-02-24 00:00:00', '0', '0', '0', NULL, 'ELB_26.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(332, '0', 333, 'April', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', '9018824', '9005306', 'ELB 26.3', '2021-04-07 00:00:00', NULL, NULL, '26.3', 16, 0, '2021-03-17 00:00:00', '2021-03-24 00:00:00', '2021-03-31 00:00:00', '0', '0', '0', NULL, 'ELB_26.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(333, '0', 334, 'May', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', '9018825', '9005306', 'ELB 26.4', '2021-05-05 00:00:00', NULL, NULL, '26.4', 16, 0, '2021-04-14 00:00:00', '2021-04-21 00:00:00', '2021-04-28 00:00:00', '0', '0', '0', NULL, 'ELB_26.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(334, '0', 335, 'June', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', '9018826', '9005306', 'ELB 26.5', '2021-06-02 00:00:00', NULL, NULL, '26.5', 16, 0, '2021-05-12 00:00:00', '2021-05-19 00:00:00', '2021-05-26 00:00:00', '0', '0', '0', NULL, 'ELB_26.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(335, '0', 336, 'July', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', NULL, '9005306', 'ELB 26.6', '2021-07-07 00:00:00', NULL, NULL, '26.6', 16, 0, '2021-06-16 00:00:00', '2021-06-23 00:00:00', '2021-06-30 00:00:00', '0', '0', '0', NULL, 'ELB_26.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(336, '0', 337, 'August', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', NULL, '9005306', 'ELB 26.7', '2021-08-04 00:00:00', NULL, NULL, '26.7', 16, 0, '2021-07-14 00:00:00', '2021-07-21 00:00:00', '2021-07-28 00:00:00', '0', '0', '0', NULL, 'ELB_26.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(337, '0', 338, 'September', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', NULL, '9005306', 'ELB 26.8', '2021-09-01 00:00:00', NULL, NULL, '26.8', 16, 0, '2021-08-11 00:00:00', '2021-08-18 00:00:00', '2021-08-25 00:00:00', '0', '0', '0', NULL, 'ELB_26.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(338, '0', 339, 'October', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', NULL, '9005306', 'ELB 26.9', '2021-10-06 00:00:00', NULL, NULL, '26.9', 16, 0, '2021-09-15 00:00:00', '2021-09-22 00:00:00', '2021-09-29 00:00:00', '0', '0', '0', NULL, 'ELB_26.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(339, '0', 340, 'November', NULL, 'Commentaries', 'ELB', 'Katharine Lam', 'Annual', 'ELB', NULL, '9005306', 'ELB 26.10', '2021-11-03 00:00:00', NULL, NULL, '26.10', 16, 0, '2021-10-13 00:00:00', '2021-10-20 00:00:00', '2021-10-27 00:00:00', '0', '0', '0', NULL, 'ELB_26.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(340, '1', 341, 'March', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'IRL', '9018210', '9005276', 'IRL 17', '2021-03-01 00:00:00', '2021-03-01 00:00:00', NULL, '17', 100, 152, '2021-02-08 00:00:00', '2021-02-15 00:00:00', '2021-02-22 00:00:00', '1', '0', '1', '2021-02-23 00:00:00', 'ERL_17', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(341, '1', 342, 'May', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'IRL', '9018211', '9005276', 'IRL 18', '2021-04-08 00:00:00', '2021-05-31 00:00:00', 'insufficient content', '18', 100, 0, '2021-03-18 00:00:00', '2021-03-25 00:00:00', '2021-04-01 00:00:00', '0', '0', '1', NULL, 'ERL_18', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(342, '1', 343, 'July', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'IRL', '9018212', '9005276', 'IRL 19', '2021-07-02 00:00:00', NULL, NULL, '19', 100, 0, '2021-06-11 00:00:00', '2021-06-18 00:00:00', '2021-06-25 00:00:00', '0', '0', '0', NULL, 'ERL_19', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(343, '1', 344, 'October', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'IRL', '9018213', '9005276', 'IRL 20', '2021-10-01 00:00:00', NULL, NULL, '20', 100, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'ERL_20', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(344, '1', 345, 'December', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'IRL', '9018214', '9005276', 'IRL 21', '2021-12-15 00:00:00', NULL, NULL, '21', 100, 0, '2021-11-24 00:00:00', '2021-12-01 00:00:00', '2021-12-08 00:00:00', '0', '0', '0', NULL, 'ERL_21', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(345, '1', 346, 'June', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'ERL', '9018219', '9005452', 'ERLB 3.6', '2021-03-22 00:00:00', '2021-06-11 00:00:00', 'no content', '3.6', 16, 0, '2021-03-01 00:00:00', '2021-03-08 00:00:00', '2021-03-15 00:00:00', '0', '0', '1', NULL, 'ERL_3.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(346, '1', 347, 'May', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'ERL', '9018220', '9005452', 'ERLB 3.7', '2021-04-15 00:00:00', '2021-05-27 00:00:00', 'no content', '3.7', 16, 0, '2021-03-25 00:00:00', '2021-04-01 00:00:00', '2021-04-08 00:00:00', '0', '0', '1', NULL, 'ERL_3.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(347, '1', 348, 'August', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'ERL', '9018221', '9005452', 'ERLB 3.8', '2021-08-02 00:00:00', NULL, NULL, '3.8', 16, 0, '2021-07-12 00:00:00', '2021-07-19 00:00:00', '2021-07-26 00:00:00', '0', '0', '0', NULL, 'ERL_3.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(348, '1', 349, 'November', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'ERL', '9018222', '9005452', 'ERLB 3.9', '2021-11-15 00:00:00', NULL, NULL, '3.9', 16, 0, '2021-10-25 00:00:00', '2021-11-01 00:00:00', '2021-11-08 00:00:00', '0', '0', '0', NULL, 'ERL_3.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(349, '1', 350, 'December', 'Tier 3', 'Commentaries', 'ERL', 'David Worswick', 'Annual', 'ERL', '9018223', '9005452', 'ERLB 3.10', '2021-12-12 00:00:00', NULL, NULL, '3.10', 16, 0, '2021-11-22 00:00:00', '2021-11-29 00:00:00', '2021-12-06 00:00:00', '0', '0', '0', NULL, 'ERL_3.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(350, '0', 351, 'March', 'Tier 3', 'Commentaries', 'FCL', 'Rose Thomsen', 'Annual', 'FCL', '9018227', '9005198', 'FCL 204', '2021-03-05 00:00:00', NULL, NULL, '204', 200, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '0', NULL, 'FCL_204', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(351, '1', 352, 'May', 'Tier 3', 'Commentaries', 'FCL', 'Rose Thomsen', 'Annual', 'FCL', '9018228', '9005198', 'FCL 205', '2021-03-05 00:00:00', '2021-05-15 00:00:00', 'Insufficient content', '205', 200, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'FCL_205', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(352, '1', 353, 'July', 'Tier 3', 'Commentaries', 'FCL', 'Rose Thomsen', 'Annual', 'FCL', '9018229', '9005198', 'FCL 206', '2021-07-02 00:00:00', NULL, NULL, '206', 200, 0, '2021-06-11 00:00:00', '2021-06-18 00:00:00', '2021-06-25 00:00:00', '0', '0', '0', NULL, 'FCL_206', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(353, '1', 354, 'November', 'Tier 3', 'Commentaries', 'FCL', 'Rose Thomsen', 'Annual', 'FCL', '9029743', '9005198', 'FCL 207', '2021-11-04 00:00:00', NULL, NULL, '207', 200, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'FCL_207', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(354, '1', 355, 'May', 'Tier 3', 'Commentaries', 'FCLP', 'Edward Mason', 'Annual', 'FCP', '9029746', '9005231', 'FCLP 33', '2021-04-23 00:00:00', '2021-05-24 00:00:00', 'no materials yet', '33', 134, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '0', '0', '1', NULL, 'FCLP_33', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(355, '1', 356, 'October', 'Tier 3', 'Commentaries', 'FCLP', 'Edward Mason', 'Annual', 'FCP', NULL, '9005231', 'FCLP 34', '2021-10-08 00:00:00', NULL, NULL, '34', 134, 0, '2021-09-17 00:00:00', '2021-09-24 00:00:00', '2021-10-01 00:00:00', '0', '0', '0', NULL, 'FCLP_34', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(356, '1', 357, 'March', 'Tier 3', 'Commentaries', 'FIR', 'Meg McDermott', 'Annual', 'FIR', '9018233', '9005289', 'FIR 91', '2021-03-11 00:00:00', '2021-03-19 00:00:00', 'current no longer feasible', '91', 166, 358, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '1', '0', '1', '2021-03-17 00:00:00', 'FIR_91', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(357, '1', 358, 'June', 'Tier 3', 'Commentaries', 'FIR', 'Meg McDermott', 'Annual', 'FIR', '9029747', '9005289', 'FIR 92', '2021-06-24 00:00:00', NULL, NULL, '92', 166, 0, '2021-06-03 00:00:00', '2021-06-10 00:00:00', '2021-06-17 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'FIR_92', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(358, '1', 359, 'September', 'Tier 3', 'Commentaries', 'FIR', 'Meg McDermott', 'Annual', 'FIR', '9029748', '9005289', 'FIR 93', '2021-09-30 00:00:00', NULL, NULL, '93', 166, 0, '2021-09-09 00:00:00', '2021-09-16 00:00:00', '2021-09-23 00:00:00', '0', '0', '0', NULL, 'FIR_93', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(359, '0', 360, 'March', 'Tier 1', 'Commentaries', 'FL', 'Rose Thomsen', 'Annual', 'FL', '9018237', '9005199/9005200', 'FL 303', '2021-02-26 00:00:00', '2021-03-06 00:00:00', NULL, '303', 474, 1198, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '1', '2021-03-18 00:00:00', 'FL_303', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(360, '0', 361, 'March', 'Tier 1', 'Commentaries', 'FL', 'Rose Thomsen', 'Annual', 'FL', '9018238', '9005199/9005200', 'FL 304', '2021-03-26 00:00:00', NULL, NULL, '304', 474, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'FL_304', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(361, '0', 362, 'May', 'Tier 1', 'Commentaries', 'FL', 'Rose Thomsen', 'Annual', 'FL', '9029749', '9005199/9005200', 'FL 305', '2021-05-28 00:00:00', NULL, NULL, '305', 474, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'FL_305', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(362, '0', 363, 'August', 'Tier 1', 'Commentaries', 'FL', 'Rose Thomsen', 'Annual', 'FL', '9029750', '9005199/9005200', 'FL 306', '2021-08-06 00:00:00', NULL, NULL, '306', 474, 0, '2021-07-16 00:00:00', '2021-07-23 00:00:00', '2021-07-30 00:00:00', '0', '0', '0', NULL, 'FL_306', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(363, '0', 364, 'October', 'Tier 1', 'Commentaries', 'FL', 'Rose Thomsen', 'Annual', 'FL', '9029751', '9005199/9005200', 'FL 307', '2021-10-29 00:00:00', NULL, NULL, '307', 474, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'FL_307', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(364, '1', 365, 'May', 'Tier 3', 'Commentaries', 'FLSL', 'Rose Thomsen', 'Annual', 'FLS', '9018242', '9005195', 'FLSL 182', '2021-03-19 00:00:00', '2021-05-24 00:00:00', 'insufficient content - 15 pages', '182', 436, 0, '2021-02-26 00:00:00', '2021-03-05 00:00:00', '2021-03-12 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'FLSL_182', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(365, '1', 366, 'June', 'Tier 3', 'Commentaries', 'FLSL', 'Rose Thomsen', 'Annual', 'FLS', '9029754', '9005195', 'FLSL 183', '2021-06-18 00:00:00', NULL, NULL, '183', 436, 0, '2021-05-28 00:00:00', '2021-06-04 00:00:00', '2021-06-11 00:00:00', '0', '0', '0', NULL, 'FLSL_183', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(366, '1', 367, 'September', 'Tier 3', 'Commentaries', 'FLSL', 'Rose Thomsen', 'Annual', 'FLS', '9029755', '9005195', 'FLSL 184', '2021-09-17 00:00:00', NULL, NULL, '184', 436, 0, '2021-08-27 00:00:00', '2021-09-03 00:00:00', '2021-09-10 00:00:00', '0', '0', '0', NULL, 'FLSL_184', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(367, '0', 368, 'January', 'Tier 1', 'Commentaries', 'FORD', 'Olivia Zhang', 'Annual', 'FRD', '9018245', '9005215', 'FORD 145', '2021-01-15 00:00:00', '2021-01-28 00:00:00', NULL, '145', 446, 386, '2020-12-25 00:00:00', '2021-01-01 00:00:00', '2021-01-08 00:00:00', '1', '0', '1', '2021-01-20 00:00:00', 'FORD_145', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(368, '0', 369, 'April', 'Tier 1', 'Commentaries', 'FORD', 'Olivia Zhang', 'Annual', 'FRD', '9018246', '9005215', 'FORD 146', '2021-04-30 00:00:00', NULL, NULL, '146', 446, 0, '2021-04-09 00:00:00', '2021-04-16 00:00:00', '2021-04-23 00:00:00', '0', '0', '0', NULL, 'FORD_146', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(369, '0', 370, 'August', 'Tier 1', 'Commentaries', 'FORD', 'Olivia Zhang', 'Annual', 'FRD', '9018247', '9005215', 'FORD 147', '2021-08-13 00:00:00', NULL, NULL, '147', 446, 0, '2021-07-23 00:00:00', '2021-07-30 00:00:00', '2021-08-06 00:00:00', '0', '0', '0', NULL, 'FORD_147', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(370, '0', 371, 'November', 'Tier 1', 'Commentaries', 'FORD', 'Olivia Zhang', 'Annual', 'FRD', '9029757', '9005215', 'FORD 148', '2021-11-26 00:00:00', NULL, NULL, '148', 446, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'FORD_148', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(371, '1', 372, 'May', 'Tier 3', 'Commentaries', 'FRAN', 'Marcus Frajman', 'Annual', 'FRN', '9018250', '9005235', 'FRAN 66', '2021-04-26 00:00:00', '2021-05-21 00:00:00', 'Insufficient content', '66', 136, 0, '2021-04-05 00:00:00', '2021-04-12 00:00:00', '2021-04-19 00:00:00', '0', '0', '1', NULL, 'FRAN_66', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(372, '1', 373, 'July', 'Tier 3', 'Commentaries', 'FRAN', 'Marcus Frajman', 'Annual', 'FRN', '9018251', '9005235', 'FRAN 67', '2021-07-26 00:00:00', NULL, NULL, '67', 136, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'FRAN_67', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(373, '1', 374, 'October', 'Tier 3', 'Commentaries', 'FRAN', 'Marcus Frajman', 'Annual', 'FRN', '9029762', '9005235', 'FRAN 68', '2021-10-25 00:00:00', NULL, NULL, '68', 136, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'FRAN_68', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(374, '1', 375, 'May', 'Tier 2', 'Commentaries', 'FS', 'Nina Packman', 'Annual', 'FS', '9018254', '9005244', 'FS 64', '2021-03-26 00:00:00', '2021-05-13 00:00:00', 'waiting for LE\'s final approval', '64', 152, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'FS_64', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(375, '1', 376, 'August', 'Tier 2', 'Commentaries', 'FS', 'Nina Packman', 'Annual', 'FS', '9018255', '9005244', 'FS 65', '2021-08-20 00:00:00', NULL, NULL, '65', 152, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'FS_65', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(376, '1', 377, 'November', 'Tier 2', 'Commentaries', 'FS', 'Nina Packman', 'Annual', 'FS', '9029765', '9005244', 'FS 66', '2021-11-26 00:00:00', NULL, NULL, '66', 152, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'FS_66', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(377, '0', 378, 'February', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', NULL, '9005311', 'FSN 19.10', '2021-02-17 00:00:00', NULL, NULL, '19.10', 16, 0, '2021-01-27 00:00:00', '2021-02-03 00:00:00', '2021-02-10 00:00:00', '0', '0', '0', NULL, 'FSR_19.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(378, '0', 379, 'March', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030046', '9005311', 'FSN 20.1', '2021-03-10 00:00:00', NULL, NULL, '20.1', 16, 0, '2021-02-17 00:00:00', '2021-02-24 00:00:00', '2021-03-03 00:00:00', '0', '0', '0', NULL, 'FSR_20.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(379, '0', 380, 'April', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030047', '9005311', 'FSN 20.2', '2021-04-14 00:00:00', NULL, NULL, '20.2', 16, 0, '2021-03-24 00:00:00', '2021-03-31 00:00:00', '2021-04-07 00:00:00', '0', '0', '0', NULL, 'FSR_20.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(380, '0', 381, 'May', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030048', '9005311', 'FSN 20.3', '2021-05-12 00:00:00', NULL, NULL, '20.3', 16, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '0', NULL, 'FSR_20.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(381, '0', 382, 'June', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030049', '9005311', 'FSN 20.4', '2021-06-09 00:00:00', NULL, NULL, '20.4', 16, 0, '2021-05-19 00:00:00', '2021-05-26 00:00:00', '2021-06-02 00:00:00', '0', '0', '0', NULL, 'FSR_20.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(382, '0', 383, 'July', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030050', '9005311', 'FSN 20.5', '2021-07-14 00:00:00', NULL, NULL, '20.5', 16, 0, '2021-06-23 00:00:00', '2021-06-30 00:00:00', '2021-07-07 00:00:00', '0', '0', '0', NULL, 'FSR_20.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(383, '0', 384, 'August', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030051', '9005311', 'FSN 20.6', '2021-08-11 00:00:00', NULL, NULL, '20.6', 16, 0, '2021-07-21 00:00:00', '2021-07-28 00:00:00', '2021-08-04 00:00:00', '0', '0', '0', NULL, 'FSR_20.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(384, '0', 385, 'September', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030052', '9005311', 'FSN 20.7', '2021-09-15 00:00:00', NULL, NULL, '20.7', 16, 0, '2021-08-25 00:00:00', '2021-09-01 00:00:00', '2021-09-08 00:00:00', '0', '0', '0', NULL, 'FSR_20.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(385, '0', 386, 'October', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030053', '9005311', 'FSN 20.8', '2021-10-13 00:00:00', NULL, NULL, '20.8', 16, 0, '2021-09-22 00:00:00', '2021-09-29 00:00:00', '2021-10-06 00:00:00', '0', '0', '0', NULL, 'FSR_20.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(386, '0', 387, 'November', NULL, 'Commentaries', 'FSR', 'Shomal Prasad', 'Annual', 'FSR', '9030054', '9005311', 'FSN 20.9', '2021-11-17 00:00:00', NULL, NULL, '20.9', 16, 0, '2021-10-27 00:00:00', '2021-11-03 00:00:00', '2021-11-10 00:00:00', '0', '0', '0', NULL, 'FSR_20.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(387, '0', 388, 'February', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018258', '9005253', 'HCFCP 288', '2021-02-11 00:00:00', NULL, NULL, '288', 444, 0, '2021-01-21 00:00:00', '2021-01-28 00:00:00', '2021-02-04 00:00:00', '0', '0', '0', NULL, 'HCFCP_288', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(388, '0', 389, 'February', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018433', '9005253', 'HCFCP 289', '2021-02-11 00:00:00', '2021-02-18 00:00:00', NULL, '289', 444, 940, '2021-01-21 00:00:00', '2021-01-28 00:00:00', '2021-02-04 00:00:00', '1', '0', '1', '2021-03-11 00:00:00', 'HCFCP_289', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(389, '0', 390, 'April', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018434', '9005253', 'HCFCP 290', '2021-03-18 00:00:00', '2021-04-30 00:00:00', 'waiting for outstanding legislation to complete', '290', 444, 0, '2021-02-25 00:00:00', '2021-03-04 00:00:00', '2021-03-11 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'HCFCP_290', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(390, '0', 391, 'April', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018435', '9005253', 'HCFCP 291', '2021-04-22 00:00:00', NULL, NULL, '291', 444, 0, '2021-04-01 00:00:00', '2021-04-08 00:00:00', '2021-04-15 00:00:00', '0', '0', '0', NULL, 'HCFCP_291', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(391, '0', 392, 'May', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018436', '9005253', 'HCFCP 292', '2021-05-27 00:00:00', NULL, NULL, '292', 444, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'HCFCP_292', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(392, '0', 393, 'July', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018437', '9005253', 'HCFCP 293', '2021-07-01 00:00:00', NULL, NULL, '293', 444, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'HCFCP_293', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(393, '0', 394, 'August', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018438', '9005253', 'HCFCP 294', '2021-08-05 00:00:00', NULL, NULL, '294', 444, 0, '2021-07-15 00:00:00', '2021-07-22 00:00:00', '2021-07-29 00:00:00', '0', '0', '0', NULL, 'HCFCP_294', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(394, '0', 395, 'September', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9018439', '9005253', 'HCFCP 295', '2021-09-16 00:00:00', NULL, NULL, '295', 444, 0, '2021-08-26 00:00:00', '2021-09-02 00:00:00', '2021-09-09 00:00:00', '0', '0', '0', NULL, 'HCFCP_295', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(395, '0', 396, 'October', 'Tier 1', 'Commentaries', 'HCFCP', 'Meg McDermott', 'Annual', 'HFC', '9029768', '9005253', 'HCFCP 296', '2021-10-21 00:00:00', NULL, NULL, '296', 444, 0, '2021-09-30 00:00:00', '2021-10-07 00:00:00', '2021-10-14 00:00:00', '0', '0', '0', NULL, 'HCFCP_296', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(396, '0', 397, 'January', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA546', '9029769', '9005172', 'HLA 546', '2021-01-06 00:00:00', NULL, NULL, '546', 330, 0, '2020-12-16 00:00:00', '2020-12-23 00:00:00', '2020-12-30 00:00:00', '0', '0', '0', NULL, 'HLA_546', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(397, '0', 398, 'January', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA547', '9029770', '9005172', 'HLA 547', '2021-01-18 00:00:00', NULL, NULL, '547', 330, 0, '2020-12-28 00:00:00', '2021-01-04 00:00:00', '2021-01-11 00:00:00', '0', '0', '0', NULL, 'HLA_547', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(398, '0', 399, 'February', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA548', '9029771', '9005172', 'HLA 548', '2021-02-02 00:00:00', NULL, NULL, '548', 330, 0, '2021-01-12 00:00:00', '2021-01-19 00:00:00', '2021-01-26 00:00:00', '0', '0', '0', NULL, 'HLA_548', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(399, '0', 400, 'February', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA549', '9029772', '9005172', 'HLA 549', '2021-02-15 00:00:00', NULL, NULL, '549', 330, 0, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '0', '0', '0', NULL, 'HLA_549', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(400, '0', 401, 'February', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA550', '9029773', '9005172', 'HLA 550', '2021-02-26 00:00:00', NULL, NULL, '550', 330, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '0', '0', '0', NULL, 'HLA_550', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(401, '0', 402, 'March', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA551', '9029774', '9005172', 'HLA 551', '2021-03-12 00:00:00', NULL, NULL, '551', 330, 0, '2021-02-19 00:00:00', '2021-02-26 00:00:00', '2021-03-05 00:00:00', '0', '0', '0', NULL, 'HLA_551', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(402, '0', 403, 'March', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA552', '9029775', '9005172', 'HLA 552', '2021-03-26 00:00:00', NULL, NULL, '552', 330, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'HLA_552', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(403, '0', 404, 'April', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA553', '9029776', '9005172', 'HLA 553', '2021-04-08 00:00:00', NULL, NULL, '553', 330, 0, '2021-03-18 00:00:00', '2021-03-25 00:00:00', '2021-04-01 00:00:00', '0', '0', '0', NULL, 'HLA_553', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(404, '0', 405, 'April', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA554', '9029777', '9005172', 'HLA 554', '2021-04-22 00:00:00', NULL, NULL, '554', 330, 0, '2021-04-01 00:00:00', '2021-04-08 00:00:00', '2021-04-15 00:00:00', '0', '0', '0', NULL, 'HLA_554', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(405, '0', 406, 'May', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA555', '9029570', '9005172', 'HLA 555', '2021-05-12 00:00:00', NULL, NULL, '555', 330, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '0', NULL, 'HLA_555', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(406, '0', 407, 'May', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA556', '9029571', '9005172', 'HLA 556', '2021-05-26 00:00:00', NULL, NULL, '556', 330, 0, '2021-05-05 00:00:00', '2021-05-12 00:00:00', '2021-05-19 00:00:00', '0', '0', '0', NULL, 'HLA_556', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(407, '0', 408, 'June', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA557', '9029572', '9005172', 'HLA 557', '2021-06-10 00:00:00', NULL, NULL, '557', 330, 0, '2021-05-20 00:00:00', '2021-05-27 00:00:00', '2021-06-03 00:00:00', '0', '0', '0', NULL, 'HLA_557', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(408, '0', 409, 'June', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA558', '9029573', '9005172', 'HLA 558', '2021-06-24 00:00:00', NULL, NULL, '558', 330, 0, '2021-06-03 00:00:00', '2021-06-10 00:00:00', '2021-06-17 00:00:00', '0', '0', '0', NULL, 'HLA_558', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(409, '0', 410, 'July', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA559', '9029574', '9005172', 'HLA 559', '2021-07-13 00:00:00', NULL, NULL, '559', 330, 0, '2021-06-22 00:00:00', '2021-06-29 00:00:00', '2021-07-06 00:00:00', '0', '0', '0', NULL, 'HLA_559', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(410, '0', 411, 'July', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA560', '9029575', '9005172', 'HLA 560', '2021-07-27 00:00:00', NULL, NULL, '560', 330, 0, '2021-07-06 00:00:00', '2021-07-13 00:00:00', '2021-07-20 00:00:00', '0', '0', '0', NULL, 'HLA_560', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(411, '0', 412, 'August', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA561', '9029576', '9005172', 'HLA 561', '2021-08-13 00:00:00', NULL, NULL, '561', 330, 0, '2021-07-23 00:00:00', '2021-07-30 00:00:00', '2021-08-06 00:00:00', '0', '0', '0', NULL, 'HLA_561', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(412, '0', 413, 'August', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA562', '9029577', '9005172', 'HLA 562', '2021-08-27 00:00:00', NULL, NULL, '562', 330, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'HLA_562', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(413, '0', 414, 'September', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA563', '9029578', '9005172', 'HLA 563', '2021-09-10 00:00:00', NULL, NULL, '563', 330, 0, '2021-08-20 00:00:00', '2021-08-27 00:00:00', '2021-09-03 00:00:00', '0', '0', '0', NULL, 'HLA_563', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(414, '0', 415, 'September', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA564', '9029579', '9005172', 'HLA 564', '2021-09-24 00:00:00', NULL, NULL, '564', 330, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'HLA_564', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(415, '0', 416, 'October', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA565', '9029580', '9005172', 'HLA 565', '2021-10-13 00:00:00', NULL, NULL, '565', 330, 0, '2021-09-22 00:00:00', '2021-09-29 00:00:00', '2021-10-06 00:00:00', '0', '0', '0', NULL, 'HLA_565', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(416, '0', 417, 'October', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA566', '9029581', '9005172', 'HLA 566', '2021-10-27 00:00:00', NULL, NULL, '566', 330, 0, '2021-10-06 00:00:00', '2021-10-13 00:00:00', '2021-10-20 00:00:00', '0', '0', '0', NULL, 'HLA_566', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(417, '0', 418, 'November', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA567', '9029582', '9005172', 'HLA 567', '2021-11-12 00:00:00', NULL, NULL, '567', 330, 0, '2021-10-22 00:00:00', '2021-10-29 00:00:00', '2021-11-05 00:00:00', '0', '0', '0', NULL, 'HLA_567', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);
INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(418, '0', 419, 'November', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA568', '9029583', '9005172', 'HLA 568', '2021-11-26 00:00:00', NULL, NULL, '568', 330, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'HLA_568', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(419, '0', 420, 'December', NULL, 'Commentaries', 'HLA', 'Edward Mason', 'CPI', 'HLA569', '9029584', '9005172', 'HLA 569', '2021-12-10 00:00:00', NULL, NULL, '569', 330, 0, '2021-11-19 00:00:00', '2021-11-26 00:00:00', '2021-12-03 00:00:00', '0', '0', '0', NULL, 'HLA_569', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(420, '0', 421, 'February', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9018844', '9005295', 'HLB 28.8', '2021-02-01 00:00:00', NULL, NULL, '28.8', 20, 0, '2021-01-11 00:00:00', '2021-01-18 00:00:00', '2021-01-25 00:00:00', '0', '0', '0', NULL, 'HLB_28.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(421, '1', 422, 'February', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9018845', '9005295', 'HLB 28.9', '2021-02-01 00:00:00', NULL, NULL, '28.9', 20, 24, '2021-01-11 00:00:00', '2021-01-18 00:00:00', '2021-01-25 00:00:00', '1', '0', '0', '2021-01-11 00:00:00', 'HLB_28.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(422, '1', 423, 'February', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9018846', '9005295', 'HLB 28.10', '2021-02-10 00:00:00', '2021-02-12 00:00:00', NULL, '28.10', 20, 0, '2021-01-20 00:00:00', '2021-01-27 00:00:00', '2021-02-03 00:00:00', '1', '0', '1', '2021-02-11 00:00:00', 'HLB_28.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(423, '1', 424, 'March', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030056', '9005295', 'HLB 29.1', '2021-02-08 00:00:00', '2021-03-04 00:00:00', 'delayed manuscripts', '29.1', 20, 20, '2021-01-18 00:00:00', '2021-01-25 00:00:00', '2021-02-01 00:00:00', '1', '0', '1', '2021-03-04 00:00:00', 'HLB_29.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(424, '1', 425, 'April', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030057', '9005295', 'HLB 29.2', '2021-03-08 00:00:00', '2021-04-19 00:00:00', 'waiting for LE\'s remark', '29.2', 20, 16, '2021-02-15 00:00:00', '2021-02-22 00:00:00', '2021-03-01 00:00:00', '1', '0', '1', '2021-04-19 00:00:00', 'HLB_29.2', '4 Mar: For variance request as HLB_29.1 was sent to press last 4 Mar', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(425, '1', 426, 'May', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030058', '9005295', 'HLB 29.3', '2021-04-05 00:00:00', '2021-05-12 00:00:00', 'delayed manuscripts', '29.3', 20, 0, '2021-03-15 00:00:00', '2021-03-22 00:00:00', '2021-03-29 00:00:00', '0', '0', '1', NULL, 'HLB_29.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(426, '1', 427, 'May', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030059', '9005295', 'HLB 29.4', '2021-05-10 00:00:00', NULL, NULL, '29.4', 20, 0, '2021-04-19 00:00:00', '2021-04-26 00:00:00', '2021-05-03 00:00:00', '0', '0', '0', NULL, 'HLB_29.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(427, '1', 428, 'June', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030060', '9005295', 'HLB 29.5&6', '2021-06-25 00:00:00', NULL, NULL, '29.5&6', 20, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'HLB_29.5&6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(428, '1', 429, 'July', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030061', '9005295', 'HLB 29.7', '2021-07-30 00:00:00', NULL, NULL, '29.7', 20, 0, '2021-07-09 00:00:00', '2021-07-16 00:00:00', '2021-07-23 00:00:00', '0', '0', '0', NULL, 'HLB_29.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(429, '1', 430, 'August', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030062', '9005295', 'HLB 29.8', '2021-08-27 00:00:00', NULL, NULL, '29.8', 20, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'HLB_29.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(430, '1', 431, 'October', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', '9030063', '9005295', 'HLB 29.9', '2021-10-08 00:00:00', NULL, NULL, '29.9', 20, 0, '2021-09-17 00:00:00', '2021-09-24 00:00:00', '2021-10-01 00:00:00', '0', '0', '0', NULL, 'HLB_29.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(431, '1', 432, 'November', 'Newsletter', 'Commentaries', 'HLB', 'David Worswick', 'Annual', 'HLB', NULL, '9005295', 'HLB 29.10', '2021-11-26 00:00:00', NULL, NULL, '29.10', 20, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'HLB_29.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(432, '0', 433, 'January', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', NULL, '9005302', 'ILB 36.7 & 8', '2021-01-21 00:00:00', NULL, NULL, '36.7&8', 32, 0, '2020-12-31 00:00:00', '2021-01-07 00:00:00', '2021-01-14 00:00:00', '0', '0', '0', NULL, 'ILB_36.7&8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(433, '0', 434, 'March', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', NULL, '9005302', 'ILB 36.9', '2021-03-22 00:00:00', NULL, NULL, '36.9', 16, 0, '2021-03-01 00:00:00', '2021-03-08 00:00:00', '2021-03-15 00:00:00', '0', '0', '0', NULL, 'ILB_36.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(434, '0', 435, 'April', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', NULL, '9005302', 'ILB 36.10', '2021-04-26 00:00:00', NULL, NULL, '36.10', 16, 0, '2021-04-05 00:00:00', '2021-04-12 00:00:00', '2021-04-19 00:00:00', '0', '0', '0', NULL, 'ILB_36.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(435, '0', 436, 'May', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', '9030066', '9005302', 'ILB 37.1', '2021-05-24 00:00:00', NULL, NULL, '37.1', 16, 0, '2021-05-03 00:00:00', '2021-05-10 00:00:00', '2021-05-17 00:00:00', '0', '0', '0', NULL, 'ILB_37.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(436, '0', 437, 'June', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', '9030067', '9005302', 'ILB 37.2', '2021-06-21 00:00:00', NULL, NULL, '37.2', 16, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '0', NULL, 'ILB_37.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(437, '0', 438, 'July', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', '9029974', '9005302', 'ILB 37.3', '2021-07-26 00:00:00', NULL, NULL, '37.3', 16, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'ILB_37.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(438, '0', 439, 'August', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', '9029975', '9005302', 'ILB 37.4', '2021-08-23 00:00:00', NULL, NULL, '37.4', 16, 0, '2021-08-02 00:00:00', '2021-08-09 00:00:00', '2021-08-16 00:00:00', '0', '0', '0', NULL, 'ILB_37.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(439, '0', 440, 'September', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', '9029976', '9005302', 'ILB 37.5', '2021-09-20 00:00:00', NULL, NULL, '37.5', 16, 0, '2021-08-30 00:00:00', '2021-09-06 00:00:00', '2021-09-13 00:00:00', '0', '0', '0', NULL, 'ILB_37.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(440, '0', 441, 'October', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', '9030025', '9005302', 'ILB 37.6', '2021-10-18 00:00:00', NULL, NULL, '37.6', 16, 0, '2021-09-27 00:00:00', '2021-10-04 00:00:00', '2021-10-11 00:00:00', '0', '0', '0', NULL, 'ILB_37.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(441, '0', 442, 'November', NULL, 'Commentaries', 'ILB', 'Marcus Frajman', 'Annual', 'ILB', '9030026', '9005302', 'ILB 37.7', '2021-11-22 00:00:00', NULL, NULL, '37.7', 16, 0, '2021-11-01 00:00:00', '2021-11-08 00:00:00', '2021-11-15 00:00:00', '0', '0', '0', NULL, 'ILB_37.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(442, '0', 443, 'February', 'Tier 2', 'Commentaries', 'IMM', 'Marcus Frajman', 'Annual', 'IMM', '9018460', '9005218/9005319', 'IMM 264', '2021-02-15 00:00:00', NULL, NULL, '264', 500, 284, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '1', '0', '0', '2020-12-15 00:00:00', 'IMM_264', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(443, '1', 444, 'March', 'Tier 2', 'Commentaries', 'IMM', 'Marcus Frajman', 'Annual', 'IMM', '9018461', '9005218/9005319', 'IMM 265', '2021-03-01 00:00:00', '2021-03-01 00:00:00', 'Insufficient content', '265', 500, 390, '2021-02-08 00:00:00', '2021-02-15 00:00:00', '2021-02-22 00:00:00', '1', '0', '1', '2021-03-01 00:00:00', 'IMM_265', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(444, '1', 445, 'May', 'Tier 2', 'Commentaries', 'IMM', 'Marcus Frajman', 'Annual', 'IMM', '9018462', '9005218/9005319', 'IMM 266', '2021-04-05 00:00:00', '2021-05-24 00:00:00', 'Insufficient content', '266', 500, 0, '2021-03-15 00:00:00', '2021-03-22 00:00:00', '2021-03-29 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'IMM_266', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(445, '1', 446, 'May', 'Tier 2', 'Commentaries', 'IMM', 'Marcus Frajman', 'Annual', 'IMM', '9018463', '9005218/9005319', 'IMM 267', '2021-05-24 00:00:00', NULL, NULL, '267', 500, 0, '2021-05-03 00:00:00', '2021-05-10 00:00:00', '2021-05-17 00:00:00', '0', '0', '0', NULL, 'IMM_267', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(446, '1', 447, 'July', 'Tier 2', 'Commentaries', 'IMM', 'Marcus Frajman', 'Annual', 'IMM', '9018463', '9005218/9005319', 'IMM 268', '2021-07-19 00:00:00', NULL, NULL, '268', 500, 0, '2021-06-28 00:00:00', '2021-07-05 00:00:00', '2021-07-12 00:00:00', '0', '0', '0', NULL, 'IMM_268', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(447, '1', 448, 'September', 'Tier 2', 'Commentaries', 'IMM', 'Marcus Frajman', 'Annual', 'IMM', '9029585', '9005218/9005319', 'IMM 269', '2021-09-13 00:00:00', NULL, NULL, '269', 500, 0, '2021-08-23 00:00:00', '2021-08-30 00:00:00', '2021-09-06 00:00:00', '0', '0', '0', NULL, 'IMM_269', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(448, '1', 449, 'November', 'Tier 2', 'Commentaries', 'IMM', 'Marcus Frajman', 'Annual', 'IMM', '9029586', '9005218/9005319', 'IMM 270', '2021-11-22 00:00:00', NULL, NULL, '270', 500, 0, '2021-11-01 00:00:00', '2021-11-08 00:00:00', '2021-11-15 00:00:00', '0', '0', '0', NULL, 'IMM_270', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(449, '1', 451, 'August', 'Tier 3', 'Commentaries', 'IN', 'Katharine Lam', 'Annual', 'IN', '9018466', '9005262', 'IN 92', '2021-08-04 00:00:00', NULL, NULL, '92', 150, 0, '2021-07-14 00:00:00', '2021-07-21 00:00:00', '2021-07-28 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'IN_92', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(450, '1', 452, 'January', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9018866', '9005307', 'INC 24.7 & 8', '2021-01-07 00:00:00', NULL, NULL, '24.7&8', 24, 20, '2020-12-17 00:00:00', '2020-12-24 00:00:00', '2020-12-31 00:00:00', '1', '0', '0', '2021-01-11 00:00:00', 'INC_24.7&8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(451, '1', 453, 'January', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029977', '9005307', 'INC 24.9 & 10 combined', '2021-01-21 00:00:00', NULL, NULL, '24.9&10', 24, 16, '2020-12-31 00:00:00', '2021-01-07 00:00:00', '2021-01-14 00:00:00', '1', '0', '0', '2021-01-20 00:00:00', 'INC_24.9&10', 'combined', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(452, '0', 454, 'February', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029978', '9005307', 'INC 24.10', '2021-02-11 00:00:00', NULL, NULL, '24.10', 24, 0, '2021-01-21 00:00:00', '2021-01-28 00:00:00', '2021-02-04 00:00:00', '0', '0', '0', NULL, 'INC_24.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(453, '1', 455, 'March', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029979', '9005307', 'INC 25.1', '2021-03-04 00:00:00', '2021-03-24 00:00:00', 'Insufficient content', '25.1', 24, 16, '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2021-02-25 00:00:00', '1', '0', '1', '2021-02-22 00:00:00', 'INC_25.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(454, '1', 456, 'May', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029980', '9005307', 'INC 25.2', '2021-04-01 00:00:00', '2021-05-06 00:00:00', 'No articles yet', '25.2', 24, 0, '2021-03-11 00:00:00', '2021-03-18 00:00:00', '2021-03-25 00:00:00', '0', '0', '1', NULL, 'INC_25.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(455, '1', 457, 'May', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029981', '9005307', 'INC 25.3', '2021-05-06 00:00:00', NULL, NULL, '25.3', 24, 0, '2021-04-15 00:00:00', '2021-04-22 00:00:00', '2021-04-29 00:00:00', '0', '0', '0', NULL, 'INC_25.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(456, '1', 458, 'June', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029982', '9005307', 'INC 25.4', '2021-06-03 00:00:00', NULL, NULL, '25.4', 24, 0, '2021-05-13 00:00:00', '2021-05-20 00:00:00', '2021-05-27 00:00:00', '0', '0', '0', NULL, 'INC_25.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(457, '1', 459, 'July', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029983', '9005307', 'INC 25.5', '2021-07-01 00:00:00', NULL, NULL, '25.5', 24, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'INC_25.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(458, '1', 460, 'August', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029984', '9005307', 'INC 25.6', '2021-08-05 00:00:00', NULL, NULL, '25.6', 24, 0, '2021-07-15 00:00:00', '2021-07-22 00:00:00', '2021-07-29 00:00:00', '0', '0', '0', NULL, 'INC_25.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(459, '1', 461, 'September', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029985', '9005307', 'INC 25.7', '2021-09-02 00:00:00', NULL, NULL, '25.7', 24, 0, '2021-08-12 00:00:00', '2021-08-19 00:00:00', '2021-08-26 00:00:00', '0', '0', '0', NULL, 'INC_25.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(460, '1', 462, 'October', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029986', '9005307', 'INC 25.8', '2021-10-07 00:00:00', NULL, NULL, '25.8', 24, 0, '2021-09-16 00:00:00', '2021-09-23 00:00:00', '2021-09-30 00:00:00', '0', '0', '0', NULL, 'INC_25.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(461, '1', 463, 'November', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029987', '9005307', 'INC 25.9', '2021-11-04 00:00:00', NULL, NULL, '25.9', 24, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'INC_25.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(462, '1', 464, 'December', 'Newsletter', 'Commentaries', 'INC', 'Olivia Zhang', 'Annual', 'INC', '9029988', '9005307', 'INC 25.10', '2021-12-02 00:00:00', NULL, NULL, '25.10', 24, 0, '2021-11-11 00:00:00', '2021-11-18 00:00:00', '2021-11-25 00:00:00', '0', '0', '0', NULL, 'INC_25.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(463, '0', 465, 'March', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029990', '9005309', 'INT 23.7', '2021-03-04 00:00:00', NULL, NULL, '23.7', 20, 0, '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2021-02-25 00:00:00', '0', '0', '0', NULL, 'INT_23.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(464, '0', 466, 'April', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029991', '9005309', 'INT 23.8', '2021-04-01 00:00:00', NULL, NULL, '23.8', 20, 0, '2021-03-11 00:00:00', '2021-03-18 00:00:00', '2021-03-25 00:00:00', '0', '0', '0', NULL, 'INT_23.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(465, '0', 467, 'May', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029992', '9005309', 'INT 23.9', '2021-05-06 00:00:00', NULL, NULL, '23.9', 20, 0, '2021-04-15 00:00:00', '2021-04-22 00:00:00', '2021-04-29 00:00:00', '0', '0', '0', NULL, 'INT_23.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(466, '0', 468, 'June', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029993', '9005309', 'INT 23.10', '2021-06-03 00:00:00', NULL, NULL, '23.10', 20, 0, '2021-05-13 00:00:00', '2021-05-20 00:00:00', '2021-05-27 00:00:00', '0', '0', '0', NULL, 'INT_23.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(467, '0', 469, 'July', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029994', '9005309', 'INT 24.1', '2021-07-01 00:00:00', NULL, NULL, '24.1', 20, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'INT_24.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(468, '0', 470, 'August', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029995', '9005309', 'INT 24.2', '2021-08-05 00:00:00', NULL, NULL, '24.2', 20, 0, '2021-07-15 00:00:00', '2021-07-22 00:00:00', '2021-07-29 00:00:00', '0', '0', '0', NULL, 'INT_24.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(469, '0', 471, 'September', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029996', '9005309', 'INT 24.3', '2021-09-02 00:00:00', NULL, NULL, '24.3', 20, 0, '2021-08-12 00:00:00', '2021-08-19 00:00:00', '2021-08-26 00:00:00', '0', '0', '0', NULL, 'INT_24.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(470, '0', 472, 'October', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029997', '9005309', 'INT 24.4', '2021-10-01 00:00:00', NULL, NULL, '24.4', 20, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'INT_24.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(471, '0', 473, 'November', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029998', '9005309', 'INT 24.5', '2021-11-04 00:00:00', NULL, NULL, '24.5', 20, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'INT_24.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(472, '0', 474, 'December', NULL, 'Commentaries', 'INT', 'Genevieve Corish', 'Annual', 'INT', '9029999', '9005309', 'INT 24.6', '2021-12-02 00:00:00', NULL, NULL, '24.6', 20, 0, '2021-11-11 00:00:00', '2021-11-18 00:00:00', '2021-11-25 00:00:00', '0', '0', '0', NULL, 'INT_24.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(473, '0', 475, 'March', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030001', '9005303', 'IPLB 33.9', '2021-03-04 00:00:00', NULL, NULL, '33.9', 24, 0, '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2021-02-25 00:00:00', '0', '0', '0', NULL, 'IPB_33.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(474, '0', 476, 'April', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030002', '9005303', 'IPLB 33.10', '2021-04-01 00:00:00', NULL, NULL, '33.10', 24, 0, '2021-03-11 00:00:00', '2021-03-18 00:00:00', '2021-03-25 00:00:00', '0', '0', '0', NULL, 'IPB_33.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(475, '0', 477, 'May', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030003', '9005303', 'IPLB 34.1', '2021-05-06 00:00:00', NULL, NULL, '34.1', 24, 0, '2021-04-15 00:00:00', '2021-04-22 00:00:00', '2021-04-29 00:00:00', '0', '0', '0', NULL, 'IPB_34.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(476, '0', 478, 'June', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030004', '9005303', 'IPLB 34.2', '2021-06-03 00:00:00', NULL, NULL, '34.2', 24, 0, '2021-05-13 00:00:00', '2021-05-20 00:00:00', '2021-05-27 00:00:00', '0', '0', '0', NULL, 'IPB_34.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(477, '0', 479, 'July', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030005', '9005303', 'IPLB 34.3', '2021-07-01 00:00:00', NULL, NULL, '34.3', 24, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'IPB_34.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(478, '0', 480, 'August', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030006', '9005303', 'IPLB 34.4', '2021-08-05 00:00:00', NULL, NULL, '34.4', 24, 0, '2021-07-15 00:00:00', '2021-07-22 00:00:00', '2021-07-29 00:00:00', '0', '0', '0', NULL, 'IPB_34.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(479, '0', 481, 'September', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030007', '9005303', 'IPLB 34.5', '2021-09-02 00:00:00', NULL, NULL, '34.5', 24, 0, '2021-08-12 00:00:00', '2021-08-19 00:00:00', '2021-08-26 00:00:00', '0', '0', '0', NULL, 'IPB_34.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(480, '0', 482, 'October', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030008', '9005303', 'IPLB 34.6', '2021-10-01 00:00:00', NULL, NULL, '34.6', 24, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'IPB_34.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(481, '0', 483, 'November', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030009', '9005303', 'IPLB 34.7', '2021-11-04 00:00:00', NULL, NULL, '34.7', 24, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'IPB_34.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(482, '0', 484, 'December', NULL, 'Commentaries', 'IPB', 'Genevieve Corish', 'Annual', 'IPB', '9030010', '9005303', 'IPLB 34.8', '2021-12-02 00:00:00', NULL, NULL, '34.8', 24, 0, '2021-11-11 00:00:00', '2021-11-18 00:00:00', '2021-11-25 00:00:00', '0', '0', '0', NULL, 'IPB_34.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(483, '0', 485, 'March', 'Tier 1', 'Commentaries', 'IPC', 'Genevieve Corish', 'Annual', 'IPC', '9018482', '9005234', 'IPC 158', '2021-03-30 00:00:00', NULL, NULL, '158', 250, 0, '2021-03-09 00:00:00', '2021-03-16 00:00:00', '2021-03-23 00:00:00', '0', '0', '0', NULL, 'IPC_158', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(484, '0', 486, 'March', 'Tier 1', 'Commentaries', 'IPC', 'Genevieve Corish', 'Annual', 'IPC', '9018483', '9005234', 'IPC 159', '2021-03-30 00:00:00', NULL, NULL, '159', 250, 316, '2021-03-09 00:00:00', '2021-03-16 00:00:00', '2021-03-23 00:00:00', '1', '0', '0', '2021-03-30 00:00:00', 'IPC_159', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(485, '0', 487, 'June', 'Tier 1', 'Commentaries', 'IPC', 'Genevieve Corish', 'Annual', 'IPC', '9018484', '9005234', 'IPC 160', '2021-06-29 00:00:00', NULL, NULL, '160', 250, 0, '2021-06-08 00:00:00', '2021-06-15 00:00:00', '2021-06-22 00:00:00', '0', '0', '0', NULL, 'IPC_160', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(486, '0', 488, 'August', 'Tier 1', 'Commentaries', 'IPC', 'Genevieve Corish', 'Annual', 'IPC', '9029591', '9005234', 'IPC 161', '2021-08-26 00:00:00', NULL, NULL, '161', 250, 0, '2021-08-05 00:00:00', '2021-08-12 00:00:00', '2021-08-19 00:00:00', '0', '0', '0', NULL, 'IPC_161', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(487, '0', 489, 'October', 'Tier 1', 'Commentaries', 'IPC', 'Genevieve Corish', 'Annual', 'IPC', NULL, '9005234', 'IPC 162', '2021-10-28 00:00:00', NULL, NULL, '162', 250, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'IPC _162', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(488, '0', 490, 'February', 'Tier 1', 'Commentaries', 'IPP', 'Genevieve Corish', 'Annual', 'IPP', '9018489', '9005233', 'IPP 213 (with BULL 232)', '2021-02-11 00:00:00', NULL, NULL, '213', 306, 654, '2021-01-21 00:00:00', '2021-01-28 00:00:00', '2021-02-04 00:00:00', '1', '0', '0', '2021-02-09 00:00:00', 'IPP_213', '(with BULL 232)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(489, '0', 491, 'April', 'Tier 1', 'Commentaries', 'IPP', 'Genevieve Corish', 'Annual', 'IPP', '9018490', '9005233', 'IPP 214', '2021-04-15 00:00:00', NULL, NULL, '214', 306, 544, '2021-03-25 00:00:00', '2021-04-01 00:00:00', '2021-04-08 00:00:00', '1', '0', '0', '2021-04-14 00:00:00', 'IPP_214', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(490, '0', 492, 'June', 'Tier 1', 'Commentaries', 'IPP', 'Genevieve Corish', 'Annual', 'IPP', '9029592', '9005233', 'IPP 215', '2021-06-17 00:00:00', NULL, NULL, '215', 306, 0, '2021-05-27 00:00:00', '2021-06-03 00:00:00', '2021-06-10 00:00:00', '0', '0', '0', NULL, 'IPP_215', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(491, '0', 493, 'August', 'Tier 1', 'Commentaries', 'IPP', 'Genevieve Corish', 'Annual', 'IPP', '9029593', '9005233', 'IPP 216', '2021-08-19 00:00:00', NULL, NULL, '216', 306, 0, '2021-07-29 00:00:00', '2021-08-05 00:00:00', '2021-08-12 00:00:00', '0', '0', '0', NULL, 'IPP_216', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(492, '0', 494, 'October', 'Tier 1', 'Commentaries', 'IPP', 'Genevieve Corish', 'Annual', 'IPP', '9029594', '9005233', 'IPP 217', '2021-10-21 00:00:00', NULL, NULL, '217', 306, 0, '2021-09-30 00:00:00', '2021-10-07 00:00:00', '2021-10-14 00:00:00', '0', '0', '0', NULL, 'IPP_217', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(493, '0', 495, 'November', 'Tier 1', 'Commentaries', 'IPP', 'Genevieve Corish', 'Annual', 'IPP', NULL, '9005233', 'IPP 218', '2021-11-02 00:00:00', NULL, NULL, '218', 306, 0, '2021-10-12 00:00:00', '2021-10-19 00:00:00', '2021-10-26 00:00:00', '0', '0', '0', NULL, 'IPP_218', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(494, '1', 496, 'February', 'Tier 3', 'Commentaries', 'IPPR', 'Genevieve Corish', 'Annual', 'IPPR0', '9018518', '9005247', 'IPPR 37', '2021-02-16 00:00:00', NULL, NULL, '37', 224, 340, '2021-01-26 00:00:00', '2021-02-02 00:00:00', '2021-02-09 00:00:00', '1', '0', '0', '2021-02-09 00:00:00', 'IPPR_37', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(495, '1', 497, 'May', 'Tier 3', 'Commentaries', 'IPPR', 'Genevieve Corish', 'Annual', 'IPPR0', '9018519', '9005247', 'IPPR 38', '2021-05-04 00:00:00', NULL, NULL, '38', 224, 358, '2021-04-13 00:00:00', '2021-04-20 00:00:00', '2021-04-27 00:00:00', '1', '0', '0', '2021-05-04 00:00:00', 'IPPR_38', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(496, '1', 498, 'August', 'Tier 2', 'Commentaries', 'IQ', 'Katharine Lam', 'Annual', 'IQ', '9018522', '9005203', 'IQ 118', '2021-08-04 00:00:00', NULL, NULL, '118', 185, 0, '2021-07-14 00:00:00', '2021-07-21 00:00:00', '2021-07-28 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'IQ_118', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(497, '0', 499, 'March', NULL, 'Commentaries', 'IR', 'Marcus Frajman', 'Annual', 'IR', '9029610', '9005310', 'IR 86', '2021-03-22 00:00:00', NULL, NULL, '86', 16, 0, '2021-03-01 00:00:00', '2021-03-08 00:00:00', '2021-03-15 00:00:00', '0', '0', '0', NULL, 'IR_86', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(498, '0', 500, 'May', NULL, 'Commentaries', 'IR', 'Marcus Frajman', 'Annual', 'IR', '9029611', '9005310', 'IR 87', '2021-05-24 00:00:00', NULL, NULL, '87', 16, 0, '2021-05-03 00:00:00', '2021-05-10 00:00:00', '2021-05-17 00:00:00', '0', '0', '0', NULL, 'IR_87', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(499, '0', 501, 'July', NULL, 'Commentaries', 'IR', 'Marcus Frajman', 'Annual', 'IR', '9029612', '9005310', 'IR 88', '2021-07-26 00:00:00', NULL, NULL, '88', 16, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'IR_88', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(500, '0', 502, 'October', NULL, 'Commentaries', 'IR', 'Marcus Frajman', 'Annual', 'IR', '9029613', '9005310', 'IR 89', '2021-10-11 00:00:00', NULL, NULL, '89', 16, 0, '2021-09-20 00:00:00', '2021-09-27 00:00:00', '2021-10-04 00:00:00', '0', '0', '0', NULL, 'IR_89', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(501, '1', 503, 'February', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9018893', '9005308', 'ISB 21.1 & 2', '2021-01-22 00:00:00', '2021-02-09 00:00:00', NULL, '21.1&2', 48, 32, '2021-01-01 00:00:00', '2021-01-08 00:00:00', '2021-01-15 00:00:00', '1', '0', '1', '2021-02-09 00:00:00', 'ISB_21.1&2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(502, '1', 504, 'April', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9018895', '9005308', 'ISB 21.3&4', '2021-03-25 00:00:00', '2021-04-30 00:00:00', 'awaiting for additional manuscripts', '21.3&4', 24, 20, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '1', '0', '1', '2021-04-29 00:00:00', 'ISB_21.3&4', '11 Mar: From LE: We are still waiting on content for this issue, expected in the next 2 weeks. Please push back the press date a couple of weeks.', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(503, '0', 505, NULL, 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9018896', '9005308', 'ISB 21.4', NULL, NULL, NULL, '21.4', 24, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'ISB_21.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(504, '1', 506, 'May', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9030011', '9005308', 'ISB 21.5', '2021-05-27 00:00:00', NULL, NULL, '21.5', 24, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'ISB_21.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(505, '1', 507, 'June', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9030012', '9005308', 'ISB 21.6', '2021-06-25 00:00:00', NULL, NULL, '21.6', 24, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'ISB_21.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(506, '1', 508, 'July', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9030013', '9005308', 'ISB 21.7', '2021-07-26 00:00:00', NULL, NULL, '21.7', 24, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'ISB_21.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(507, '1', 509, 'August', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9030014', '9005308', 'ISB 21.8', '2021-08-26 00:00:00', NULL, NULL, '21.8', 24, 0, '2021-08-05 00:00:00', '2021-08-12 00:00:00', '2021-08-19 00:00:00', '0', '0', '0', NULL, 'ISB_21.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(508, '1', 510, 'September', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9030015', '9005308', 'ISB 21.9', '2021-09-24 00:00:00', NULL, NULL, '21.9', 24, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'ISB_21.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(509, '1', 511, 'October', 'Tier 3', 'Commentaries', 'ISB', 'Meg McDermott', 'Annual', 'ISB', '9030016', '9005308', 'ISB 21.10', '2021-10-25 00:00:00', NULL, NULL, '21.10', 24, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'ISB_21.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(510, '0', 512, 'January', NULL, 'Commentaries', 'LOF', 'Geraldine MacLurcan', 'Annual', 'LOF', '9018556', '9005320', 'LOF 12', NULL, NULL, NULL, '12', 250, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'LOF_12', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(511, '0', 513, 'January', NULL, 'Commentaries', 'LOF', 'Geraldine MacLurcan', 'Annual', 'LOF', '9018557', '9005320', 'LOF 13 x 2 kinds guidecard \" Adoption Act 2020” “Subsidiary Legislation”', NULL, NULL, NULL, '13', 250, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'LOF_13', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(512, '0', 514, 'January', NULL, 'Commentaries', 'LOF', 'Geraldine MacLurcan', 'Annual', 'LOF', '9029614', '9005320', 'LOF 14', NULL, NULL, NULL, '14', 250, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'LOF_14', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(513, '0', 515, 'January', NULL, 'Commentaries', 'LOF', 'Geraldine MacLurcan', 'Annual', 'LOF', '9029615', '9005320', 'LOF 15', NULL, NULL, NULL, '15', 250, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'LOF_15', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(514, '0', 516, 'January', NULL, 'Commentaries', 'LOF', 'Geraldine MacLurcan', 'Annual', 'LOF', '9029616', '9005320', 'LOF 16', NULL, NULL, NULL, '16', 250, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'LOF_16', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(515, '0', 517, 'January', NULL, 'Commentaries', 'LOF', 'Geraldine MacLurcan', 'Annual', 'LOF', '9029617', '9005320', 'LOF 17', NULL, NULL, NULL, '17', 250, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'LOF_17', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(516, '0', 518, 'March', 'Tier 3', 'Commentaries', 'LAS', 'Nina Packman', 'Annual', 'LAS', '9018560', '9005208', 'LAS 41', '2021-03-19 00:00:00', NULL, NULL, '41', 310, 0, '2021-02-26 00:00:00', '2021-03-05 00:00:00', '2021-03-12 00:00:00', '0', '0', '0', NULL, 'LAS_41', 'Sent to press last year', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(517, '1', 519, 'May', 'Tier 3', 'Commentaries', 'LAS', 'Nina Packman', 'Annual', 'LAS', '9029618', '9005208', 'LAS 42', '2021-03-19 00:00:00', '2021-05-13 00:00:00', 'waiting for LE\'s final approval', '42', 310, 0, '2021-02-26 00:00:00', '2021-03-05 00:00:00', '2021-03-12 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'LAS_42', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(518, '1', 520, 'September', 'Tier 3', 'Commentaries', 'LAS', 'Nina Packman', 'Annual', 'LAS', '9029619', '9005208', 'LAS 43', '2021-09-24 00:00:00', NULL, NULL, '43', 310, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'LAS_43', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(519, '0', 521, 'February', 'Tier 1', 'Commentaries', 'LGNA', 'Andrew Badaoui', 'Annual', 'LGNA', '9018564', 'Filter', 'LGNA 116', '2021-02-26 00:00:00', NULL, NULL, '116', 108, 220, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '0', '2021-01-27 00:00:00', 'LGNA_116', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(520, '0', 522, 'May', 'Tier 1', 'Commentaries', 'LGNA', 'Andrew Badaoui', 'Annual', 'LGNA', '9018565', 'Filter', 'LGNA 117', '2021-05-07 00:00:00', NULL, NULL, '117', 108, 222, '2021-04-16 00:00:00', '2021-04-23 00:00:00', '2021-04-30 00:00:00', '1', '0', '0', '2021-03-18 00:00:00', 'LGNA_117', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(521, '0', 523, 'July', 'Tier 1', 'Commentaries', 'LGNA', 'Andrew Badaoui', 'Annual', 'LGNA', '9029621', 'Filter', 'LGNA 118', '2021-07-30 00:00:00', NULL, NULL, '118', 108, 0, '2021-07-09 00:00:00', '2021-07-16 00:00:00', '2021-07-23 00:00:00', '0', '0', '0', NULL, 'LGNA_118', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(522, '0', 524, 'September', 'Tier 1', 'Commentaries', 'LGNA', 'Andrew Badaoui', 'Annual', 'LGNA', '9029622', 'Filter', 'LGNA 119', '2021-09-24 00:00:00', NULL, NULL, '119', 108, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'LGNA_119', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(523, '0', 525, 'December', 'Tier 1', 'Commentaries', 'LGNA', 'Andrew Badaoui', 'Annual', 'LGNA', '9029623', 'Filter', 'LGNA 120', '2021-12-03 00:00:00', NULL, NULL, '120', 108, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'LGNA_120', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(524, '0', 526, 'February', 'Tier 1', 'Commentaries', 'LGNB', 'Andrew Badaoui', 'Annual', 'LGNB', '9018594', 'Filter', 'LGNB 157', '2021-02-26 00:00:00', NULL, NULL, '157', 210, 1342, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '0', '2021-02-21 00:00:00', 'LGNB_157', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(525, '0', 527, 'April', 'Tier 1', 'Commentaries', 'LGNB', 'Andrew Badaoui', 'Annual', 'LGNB', '9018595', 'Filter', 'LGNB 158', '2021-04-23 00:00:00', NULL, NULL, '158', 210, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '0', '0', '0', NULL, 'LGNB_158', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(526, '0', 528, 'June', 'Tier 1', 'Commentaries', 'LGNB', 'Andrew Badaoui', 'Annual', 'LGNB', '9018596', 'Filter', 'LGNB 159', '2021-06-25 00:00:00', NULL, NULL, '159', 210, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'LGNB_159', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(527, '0', 529, 'August', 'Tier 1', 'Commentaries', 'LGNB', 'Andrew Badaoui', 'Annual', 'LGNB', '9029624', 'Filter', 'LGNB 160', '2021-08-20 00:00:00', NULL, NULL, '160', 210, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'LGNB_160', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(528, '0', 530, 'October', 'Tier 1', 'Commentaries', 'LGNB', 'Andrew Badaoui', 'Annual', 'LGNB', '9029625', 'Filter', 'LGNB 161', '2021-10-22 00:00:00', NULL, NULL, '161', 210, 0, '2021-10-01 00:00:00', '2021-10-08 00:00:00', '2021-10-15 00:00:00', '0', '0', '0', NULL, 'LGNB_161', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(529, '0', 531, 'December', 'Tier 1', 'Commentaries', 'LGNB', 'Andrew Badaoui', 'Annual', 'LGNB', '9029626', 'Filter', 'LGNB 162', '2021-12-10 00:00:00', NULL, NULL, '162', 210, 0, '2021-11-19 00:00:00', '2021-11-26 00:00:00', '2021-12-03 00:00:00', '0', '0', '0', NULL, 'LGNB_162', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(530, '0', 532, 'February', 'Tier 1', 'Commentaries', 'LGNC', 'Andrew Badaoui', 'Annual', 'LGNC', '9018599', 'Filter', 'LGNC 97', '2021-02-17 00:00:00', NULL, NULL, '97', 166, 244, '2021-01-27 00:00:00', '2021-02-03 00:00:00', '2021-02-10 00:00:00', '1', '0', '0', '2021-02-17 00:00:00', 'LGNC_97', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(531, '0', 533, 'June', 'Tier 1', 'Commentaries', 'LGNC', 'Andrew Badaoui', 'Annual', 'LGNC', '9018600', 'Filter', 'LGNC 98', '2021-06-25 00:00:00', NULL, NULL, '98', 166, 230, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '1', '0', '0', '2021-03-15 00:00:00', 'LGNC_98', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(532, '0', 534, 'October', 'Tier 1', 'Commentaries', 'LGNC', 'Andrew Badaoui', 'Annual', 'LGNC', NULL, 'Filter', 'LGNC 99', '2021-10-29 00:00:00', NULL, NULL, '99', 166, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'LGNC_99', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(533, '0', 535, 'February', 'Tier 1', 'Commentaries', 'LGND', 'Andrew Badaoui', 'Annual', 'LGND', '9018604', 'Filter', 'LGND 50', '2021-02-26 00:00:00', NULL, NULL, '50', 142, 304, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '0', '2021-02-23 00:00:00', 'LGND_50', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(534, '0', 536, 'May', 'Tier 1', 'Commentaries', 'LGND', 'Andrew Badaoui', 'Annual', 'LGND', '9029628', 'Filter', 'LGND 51', '2021-05-28 00:00:00', NULL, NULL, '51', 142, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'LGND_51', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(535, '0', 537, 'August', 'Tier 1', 'Commentaries', 'LGND', 'Andrew Badaoui', 'Annual', 'LGND', '9029629', 'Filter', 'LGND 52', '2021-08-20 00:00:00', NULL, NULL, '52', 142, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'LGND_52', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(536, '0', 538, 'November', 'Tier 1', 'Commentaries', 'LGND', 'Andrew Badaoui', 'Annual', 'LGND', '9029630', 'Filter', 'LGND 53', '2021-11-27 00:00:00', NULL, NULL, '53', 142, 0, '2021-11-08 00:00:00', '2021-11-15 00:00:00', '2021-11-22 00:00:00', '0', '0', '0', NULL, 'LGND_53', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(537, '0', 539, 'January', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9018903', '9005312', 'LGR 19.7', '2021-01-21 00:00:00', NULL, NULL, '19.7', 24, 0, '2020-12-31 00:00:00', '2021-01-07 00:00:00', '2021-01-14 00:00:00', '0', '0', '0', NULL, 'LGR_19.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(538, '1', 540, 'January', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9018904', '9005312', 'LGR 19.8', '2021-01-21 00:00:00', NULL, NULL, '19.8', 24, 16, '2020-12-31 00:00:00', '2021-01-07 00:00:00', '2021-01-14 00:00:00', '1', '0', '0', '2021-01-19 00:00:00', 'LGR_19.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(539, '1', 541, 'January', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9018905', '9005312', 'LGR 19.9', '2021-01-15 00:00:00', '2021-01-30 00:00:00', NULL, '19.9', 24, 12, '2020-12-25 00:00:00', '2021-01-01 00:00:00', '2021-01-08 00:00:00', '1', '0', '1', '2021-01-21 00:00:00', 'LGR_19.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(540, '1', 542, 'February', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9018906', '9005312', 'LGR 19.10', '2021-02-15 00:00:00', NULL, NULL, '19.10', 24, 16, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '1', '0', '0', '2021-02-11 00:00:00', 'LGR_19.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(541, '1', 543, 'March', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9029899', '9005312', 'LGR 20.1', '2021-03-15 00:00:00', '2021-03-26 00:00:00', 'No content yet', '20.1', 24, 16, '2021-02-22 00:00:00', '2021-03-01 00:00:00', '2021-03-08 00:00:00', '1', '0', '1', '2021-03-24 00:00:00', 'LGR_20.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(542, '1', 544, 'May', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9029900', '9005312', 'LGR 20.2', '2021-04-15 00:00:00', '2021-05-07 00:00:00', 'late manuscripts received; Late approval of the edited manuscripts from LE', '20.2', 24, 16, '2021-03-25 00:00:00', '2021-04-01 00:00:00', '2021-04-08 00:00:00', '1', '0', '1', '2021-05-03 00:00:00', 'LGR_20.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(543, '1', 545, 'May', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9029901', '9005312', 'LGR 20.3', '2021-05-18 00:00:00', NULL, NULL, '20.3', 24, 0, '2021-04-27 00:00:00', '2021-05-04 00:00:00', '2021-05-11 00:00:00', '0', '0', '0', NULL, 'LGR_20.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(544, '1', 546, 'June', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9029902', '9005312', 'LGR 20.4', '2021-06-21 00:00:00', NULL, NULL, '20.4', 24, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '0', NULL, 'LGR_20.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(545, '1', 547, 'July', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9029903', '9005312', 'LGR 20.5', '2021-07-27 00:00:00', NULL, NULL, '20.5', 24, 0, '2021-07-06 00:00:00', '2021-07-13 00:00:00', '2021-07-20 00:00:00', '0', '0', '0', NULL, 'LGR_20.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(546, '1', 548, 'August', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', NULL, '9005312', 'LGR 20.6', '2021-08-27 00:00:00', NULL, NULL, '20.6', 24, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'LGR_20.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(547, '1', 549, 'September', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', NULL, '9005312', 'LGR 20.7', '2021-09-25 00:00:00', NULL, NULL, '20.7', 24, 0, '2021-09-06 00:00:00', '2021-09-13 00:00:00', '2021-09-20 00:00:00', '0', '0', '0', NULL, 'LGR_20.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(548, '1', 550, 'October', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9029904', '9005312', 'LGR 20.8', '2021-10-25 00:00:00', NULL, NULL, '20.8', 24, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'LGR_20.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(549, '1', 551, 'November', 'Newsletter', 'Commentaries', 'LGR', 'David Worswick', 'Annual', 'LGR', '9029905', '9005312', 'LGR 20.9', '2021-11-29 00:00:00', NULL, NULL, '20.9', 24, 0, '2021-11-08 00:00:00', '2021-11-15 00:00:00', '2021-11-22 00:00:00', '0', '0', '0', NULL, 'LGR_20.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(550, '0', 552, 'March', 'Tier 3', 'Commentaries', 'LN', 'Nina Packman', 'Annual', 'LN', '9018606', '9005257', 'LN 148', '2021-03-26 00:00:00', NULL, NULL, '148', 250, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'LN_148', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(551, '1', 553, 'April', 'Tier 3', 'Commentaries', 'LN', 'Nina Packman', 'Annual', 'LN', '9029906', '9005257', 'LN 149', '2021-03-26 00:00:00', '2021-04-30 00:00:00', 'Additional Task from LE; waiting for the approval of LE', '149', 250, 390, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '1', '0', '1', '2021-04-30 00:00:00', 'LN_149', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(552, '1', 554, 'June', 'Tier 3', 'Commentaries', 'LN', 'Nina Packman', 'Annual', 'LN', '9029907', '9005257', 'LN 150', '2021-06-25 00:00:00', NULL, NULL, '150', 250, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'LN_150', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(553, '1', 555, 'September', 'Tier 3', 'Commentaries', 'LN', 'Nina Packman', 'Annual', 'LN', '9029632', '9005257', 'LN 151', '2021-09-24 00:00:00', NULL, NULL, '151', 250, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'LN_151', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(554, '0', 556, 'March', 'Tier 3', 'Commentaries', 'LV', 'Nina Packman', 'Annual', 'LV', '9018623', '9005240', 'LV 122 with 1x  guidecard \"Planning Legislation\"', '2021-03-26 00:00:00', NULL, NULL, '122', 152, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'LV_122', 'with 1x  guidecard \"Planning Legislation\"', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(555, '1', 557, 'May', 'Tier 3', 'Commentaries', 'LV', 'Nina Packman', 'Annual', 'LV', '9018624', '9005240', 'LV 123', '2021-03-26 00:00:00', '2021-05-26 00:00:00', 'no materials yet', '123', 152, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'LV_123', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(556, '1', 558, 'June', 'Tier 3', 'Commentaries', 'LV', 'Nina Packman', 'Annual', 'LV', '9018625', '9005240', 'LV 124', '2021-06-25 00:00:00', NULL, NULL, '124', 152, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'LV_124', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(557, '1', 559, 'September', 'Tier 3', 'Commentaries', 'LV', 'Nina Packman', 'Annual', 'LV', '9029634', '9005240', 'LV 125', '2021-09-24 00:00:00', NULL, NULL, '125', 152, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'LV_125', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);
INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(558, '0', 560, 'March', 'Tier 2', 'Commentaries', 'MCWA', 'Marcus Frajman', 'Annual', 'MCW', '9018628', '9005232', 'MCWA 115', '2021-03-01 00:00:00', NULL, NULL, '115', 250, 0, '2021-02-08 00:00:00', '2021-02-15 00:00:00', '2021-02-22 00:00:00', '0', '0', '0', NULL, 'MCWA_115', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(559, '1', 561, 'April', 'Tier 2', 'Commentaries', 'MCWA', 'Marcus Frajman', 'Annual', 'MCW', '9018629', '9005232', 'MCWA 116', '2021-03-01 00:00:00', '2021-04-06 00:00:00', 'tech issue', '116', 250, 760, '2021-02-08 00:00:00', '2021-02-15 00:00:00', '2021-02-22 00:00:00', '1', '0', '1', '2021-04-01 00:00:00', 'MCWA_116', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(560, '1', 562, 'May', 'Tier 2', 'Commentaries', 'MCWA', 'Marcus Frajman', 'Annual', 'MCW', '9018630', '9005232', 'MCWA 117', '2021-04-19 00:00:00', '2021-05-28 00:00:00', 'additional tasks from author', '117', 250, 0, '2021-03-29 00:00:00', '2021-04-05 00:00:00', '2021-04-12 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'MCWA_117', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(561, '1', 563, 'June', 'Tier 2', 'Commentaries', 'MCWA', 'Marcus Frajman', 'Annual', 'MCW', '9029597', '9005232', 'MCWA 118', '2021-06-21 00:00:00', NULL, NULL, '118', 250, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '0', NULL, 'MCWA_118', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(562, '1', 564, 'August', 'Tier 2', 'Commentaries', 'MCWA', 'Marcus Frajman', 'Annual', 'MCW', '9029598', '9005232', 'MCWA 119', '2021-08-16 00:00:00', NULL, NULL, '119', 250, 0, '2021-07-26 00:00:00', '2021-08-02 00:00:00', '2021-08-09 00:00:00', '0', '0', '0', NULL, 'MCWA_119', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(563, '1', 565, 'October', 'Tier 2', 'Commentaries', 'MCWA', 'Marcus Frajman', 'Annual', 'MCW', '9029599', '9005232', 'MCWA 120', '2021-10-11 00:00:00', NULL, NULL, '120', 250, 0, '2021-09-20 00:00:00', '2021-09-27 00:00:00', '2021-10-04 00:00:00', '0', '0', '0', NULL, 'MCWA_120', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(564, '1', 566, 'November', 'Tier 2', 'Commentaries', 'MCWA', 'Marcus Frajman', 'Annual', 'MCW', NULL, '9005232', 'MCWA 121', '2021-11-22 00:00:00', NULL, NULL, '121', 250, 0, '2021-11-01 00:00:00', '2021-11-08 00:00:00', '2021-11-15 00:00:00', '0', '0', '0', NULL, 'MCWA_121', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(565, '0', 567, 'March', 'Tier 3', 'Commentaries', 'MSL', 'David Worswick', 'Annual', 'MSL', '9018447', '9005284', 'MSL 14', '2021-03-31 00:00:00', NULL, NULL, '14', 152, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '0', '0', '0', NULL, 'MSL_14', 'Sent to press last year', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(566, '1', 568, 'May', 'Tier 3', 'Commentaries', 'MSL', 'David Worswick', 'Annual', 'MSL', '9018448', '9005284', 'MSL 15', '2021-03-31 00:00:00', '2021-05-21 00:00:00', 'Insufficient content', '15', 152, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'MSL_15', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(567, '1', 569, 'July', 'Tier 3', 'Commentaries', 'MSL', 'David Worswick', 'Annual', 'MSL', '9029600', '9005284', 'MSL 16', '2021-07-30 00:00:00', NULL, NULL, '16', 152, 0, '2021-07-09 00:00:00', '2021-07-16 00:00:00', '2021-07-23 00:00:00', '0', '0', '0', NULL, 'MSL_16', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(568, '1', 570, 'October', 'Tier 3', 'Commentaries', 'MSL', 'David Worswick', 'Annual', 'MSL', '9029601', '9005284', 'MSL 17', '2021-10-28 00:00:00', NULL, NULL, '17', 152, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'MSL_17', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(569, '1', 571, 'April', 'Tier 2', 'Commentaries', 'MTN', 'Ragnii Ommanney', 'Annual', 'MTN', '9018452', '9005175', 'MTN 178', '2021-02-24 00:00:00', '2021-04-09 00:00:00', 'More updates should be incorporated', '178', 352, 1410, '2021-02-03 00:00:00', '2021-02-10 00:00:00', '2021-02-17 00:00:00', '1', '0', '1', '2021-04-06 00:00:00', 'MTN_178', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(570, '1', 572, 'June', 'Tier 2', 'Commentaries', 'MTN', 'Ragnii Ommanney', 'Annual', 'MTN', '9018453', '9005175', 'MTN 179 with 1x kind guidecard \"Personal Injury Commission”', '2021-04-21 00:00:00', '2021-06-25 00:00:00', 'LE requested to vary the press date', '179', 352, 0, '2021-03-31 00:00:00', '2021-04-07 00:00:00', '2021-04-14 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'MTN_179', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(571, '1', 573, 'August', 'Tier 2', 'Commentaries', 'MTN', 'Ragnii Ommanney', 'Annual', 'MTN', '9018454', '9005175', 'MTN 180', '2021-06-23 00:00:00', '2021-08-27 00:00:00', 'LE requested to vary the press date', '180', 352, 0, '2021-06-02 00:00:00', '2021-06-09 00:00:00', '2021-06-16 00:00:00', '0', '0', '1', NULL, 'MTN_180', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(572, '1', 574, 'October', 'Tier 2', 'Commentaries', 'MTN', 'Ragnii Ommanney', 'Annual', 'MTN', '9029602', '9005175', 'MTN 181', '2021-08-18 00:00:00', '2021-10-15 00:00:00', 'LE requested to vary the press date', '181', 352, 0, '2021-07-28 00:00:00', '2021-08-04 00:00:00', '2021-08-11 00:00:00', '0', '0', '1', NULL, 'MTN_181', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(573, '1', 575, 'October', 'Tier 2', 'Commentaries', 'MTN', 'Ragnii Ommanney', 'Annual', 'MTN', '9029603', '9005175', 'MTN 182', '2021-10-20 00:00:00', NULL, 'Most likely will not be sent to press this year', '182', 352, 0, '2021-09-29 00:00:00', '2021-10-06 00:00:00', '2021-10-13 00:00:00', '0', '0', '0', NULL, 'MTN_182', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(574, '1', 576, 'November', 'Tier 2', 'Commentaries', 'MTN', 'Ragnii Ommanney', 'Annual', 'MTN', NULL, '9005175', 'MTN 183', '2021-11-24 00:00:00', NULL, 'Most likely will not be sent to press this year', '183', 352, 0, '2021-11-03 00:00:00', '2021-11-10 00:00:00', '2021-11-17 00:00:00', '0', '0', '0', NULL, 'MTN_183', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(575, '1', 577, 'February', 'Tier 2', 'Commentaries', 'MTV', 'Tim Patrick', 'Annual', 'MTV', '9018458', '9005242', 'MTV 130', '2021-02-23 00:00:00', NULL, NULL, '130', 360, 850, '2021-02-02 00:00:00', '2021-02-09 00:00:00', '2021-02-16 00:00:00', '1', '0', '0', '2021-02-22 00:00:00', 'MTV_130', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(576, '1', 578, 'May', 'Tier 2', 'Commentaries', 'MTV', 'Tim Patrick', 'Annual', 'MTV', '9018467', '9005242', 'MTV 131', '2021-04-20 00:00:00', '2021-05-07 00:00:00', 'Inconsistency in binder', '131', 360, 0, '2021-03-30 00:00:00', '2021-04-06 00:00:00', '2021-04-13 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'MTV_131', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(577, '1', 579, 'June', 'Tier 2', 'Commentaries', 'MTV', 'Tim Patrick', 'Annual', 'MTV', '9029604', '9005242', 'MTV 132', '2021-06-22 00:00:00', NULL, NULL, '132', 360, 0, '2021-06-01 00:00:00', '2021-06-08 00:00:00', '2021-06-15 00:00:00', '0', '0', '0', NULL, 'MTV_132', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(578, '1', 580, 'August', 'Tier 2', 'Commentaries', 'MTV', 'Tim Patrick', 'Annual', 'MTV', '9029605', '9005242', 'MTV 133', '2021-08-17 00:00:00', NULL, NULL, '133', 360, 0, '2021-07-27 00:00:00', '2021-08-03 00:00:00', '2021-08-10 00:00:00', '0', '0', '0', NULL, 'MTV_133', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(579, '1', 581, 'October', 'Tier 2', 'Commentaries', 'MTV', 'Tim Patrick', 'Annual', 'MTV', '9029606', '9005242', 'MTV 134', '2021-10-19 00:00:00', NULL, NULL, '134', 360, 0, '2021-09-28 00:00:00', '2021-10-05 00:00:00', '2021-10-12 00:00:00', '0', '0', '0', NULL, 'MTV_134', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(580, '1', 582, 'March', 'Tier 3', 'Commentaries', 'NOHS', 'Katharine Lam', 'Annual', 'OHSN', '9018469', '9005279', 'NOHS 26', '2021-03-24 00:00:00', '2021-03-24 00:00:00', NULL, '26', 170, 210, '2021-03-03 00:00:00', '2021-03-10 00:00:00', '2021-03-17 00:00:00', '1', '0', '1', '2021-03-12 00:00:00', 'NOHS_26', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(581, '1', 583, 'July', 'Tier 3', 'Commentaries', 'NOHS', 'Katharine Lam', 'Annual', 'OHSN', '9018470', '9005279', 'NOHS 27', '2021-05-12 00:00:00', '2021-07-23 00:00:00', 'No contents', '27', 170, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '1', NULL, 'NOHS_27', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(582, '1', 584, 'August', 'Tier 3', 'Commentaries', 'NOHS', 'Katharine Lam', 'Annual', 'OHSN', '9018471', '9005279', 'NOHS 28', '2021-08-04 00:00:00', NULL, NULL, '28', 170, 0, '2021-07-14 00:00:00', '2021-07-21 00:00:00', '2021-07-28 00:00:00', '0', '0', '0', NULL, 'NOHS_28', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(583, '1', 585, 'May', 'Tier 2', 'Commentaries', 'NT', 'Nina Packman', 'Annual', 'NT', '9018473', '9005181', 'NT 121', '2021-03-26 00:00:00', '2021-05-14 00:00:00', 'pending query to author', '121', 262, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'NT_121', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(584, '1', 586, 'May', 'Tier 2', 'Commentaries', 'NT', 'Nina Packman', 'Annual', 'NT', '9018474', '9005181', 'NT 122', '2021-05-28 00:00:00', NULL, NULL, '122', 262, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'NT_122', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(585, '1', 587, 'August', 'Tier 2', 'Commentaries', 'NT', 'Nina Packman', 'Annual', 'NT', '9018475', '9005181', 'NT 123', '2021-08-20 00:00:00', NULL, NULL, '123', 262, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'NT_123', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(586, '1', 588, 'November', 'Tier 2', 'Commentaries', 'NT', 'Nina Packman', 'Annual', 'NT', '9029798', '9005181', 'NT 124', '2021-11-26 00:00:00', NULL, NULL, '124', 262, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'NT_124', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(587, '0', 589, 'April', NULL, 'Commentaries', 'NTN / NT', 'Nina Packman', 'Annual', 'NT', '9029909', '9005181/9005293', 'NTN 14.1', '2021-03-26 00:00:00', '2021-04-26 00:00:00', 'Insufficient content', '14.1', 20, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '1', NULL, 'NTN / NT_14.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(588, '0', 590, 'May', NULL, 'Commentaries', 'NTN / NT', 'Nina Packman', 'Annual', 'NT', '9029910', '9005181/9005293', 'NTN 14.2', '2021-05-28 00:00:00', NULL, NULL, '14.2', 20, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'NTN / NT_14.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(589, '0', 591, 'August', NULL, 'Commentaries', 'NTN / NT', 'Nina Packman', 'Annual', 'NT', '9029911', '9005181/9005293', 'NTN 14.3', '2021-08-20 00:00:00', NULL, NULL, '14.3', 20, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'NTN / NT_14.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(590, '0', 592, 'November', NULL, 'Commentaries', 'NTN / NT', 'Nina Packman', 'Annual', 'NT', '9029912', '9005181/9005293', 'NTN 14.4', '2021-11-26 00:00:00', NULL, NULL, '14.4', 20, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'NTN / NT_14.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(591, '0', 593, 'March', 'Tier 2', 'Commentaries', 'OHSN', 'Katharine Lam', 'Annual', 'OHN', '9018494', '9005255', 'OHN 93', '2021-03-17 00:00:00', NULL, NULL, '93', 160, 0, '2021-02-24 00:00:00', '2021-03-03 00:00:00', '2021-03-10 00:00:00', '0', '0', '0', NULL, 'OHSN_93', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(592, '1', 594, 'March', 'Tier 2', 'Commentaries', 'OHSN', 'Katharine Lam', 'Annual', 'OHN', '9018495', '9005255', 'OHN 94 with Vol 1 & 2 Titlecards', '2021-03-17 00:00:00', NULL, NULL, '94', 160, 484, '2021-02-24 00:00:00', '2021-03-03 00:00:00', '2021-03-10 00:00:00', '1', '0', '0', '2021-03-16 00:00:00', 'OHSN_94', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(593, '1', 595, 'August', 'Tier 2', 'Commentaries', 'OHSN', 'Katharine Lam', 'Annual', 'OHN', '9018496', '9005255', 'OHN 95', '2021-08-04 00:00:00', NULL, NULL, '95', 160, 0, '2021-07-14 00:00:00', '2021-07-21 00:00:00', '2021-07-28 00:00:00', '0', '0', '0', NULL, 'OHSN_95', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(594, '1', 596, 'May', 'Tier 3', 'Commentaries', 'OHSWA', 'Katharine Lam', 'Annual', 'OHW', '9018498', '9005229', 'OHSWA 65', '2021-03-31 00:00:00', '2021-05-21 00:00:00', 'waiting for additional mansucript from the author', '65', 95, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'OHSWA_65', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(595, '1', 597, 'August', 'Tier 3', 'Commentaries', 'OHSWA', 'Katharine Lam', 'Annual', 'OHW', '9029803', '9005229', 'OHSWA 66', '2021-08-18 00:00:00', NULL, NULL, '66', 95, 0, '2021-07-28 00:00:00', '2021-08-04 00:00:00', '2021-08-11 00:00:00', '0', '0', '0', NULL, 'OHSWA_66', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(596, '0', 598, 'February', 'Tier 3', 'Small Law', 'PAM', 'Marcus Frajman', 'Annual', 'PAM', '9023084', '9005319', 'PAM 156', '2021-02-26 00:00:00', NULL, NULL, '156', 800, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '0', '0', '0', NULL, 'PAM_156', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(597, '1', 599, 'February', 'Tier 3', 'Small Law', 'PAM', 'Marcus Frajman', 'Annual', 'PAM', '9018499', '9005319', 'PAM 157', '2021-02-26 00:00:00', NULL, NULL, '157', 800, 314, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '0', '2021-02-09 00:00:00', 'PAM_157', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(598, '1', 600, 'April', 'Tier 3', 'Small Law', 'PAM', 'Marcus Frajman', 'Annual', 'PAM', '9018500', '9005319', 'PAM 158', '2021-04-12 00:00:00', NULL, NULL, '158', 800, 864, '2021-03-22 00:00:00', '2021-03-29 00:00:00', '2021-04-05 00:00:00', '1', '0', '0', '2021-04-06 00:00:00', 'PAM_158', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(599, '1', 601, 'June', 'Tier 3', 'Small Law', 'PAM', 'Marcus Frajman', 'Annual', 'PAM', '9018501', '9005319', 'PAM 159', '2021-06-14 00:00:00', NULL, NULL, '159', 800, 0, '2021-05-24 00:00:00', '2021-05-31 00:00:00', '2021-06-07 00:00:00', '0', '0', '0', NULL, 'PAM_159', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(600, '1', 602, 'August', 'Tier 3', 'Commentaries', 'PAM', 'Marcus Frajman', 'Annual', 'PAM', '9018502', '9005319', 'PAM 160', '2021-08-09 00:00:00', NULL, NULL, '160', 800, 0, '2021-07-19 00:00:00', '2021-07-26 00:00:00', '2021-08-02 00:00:00', '0', '0', '0', NULL, 'PAM_160', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(601, '1', 603, 'October', 'Tier 3', 'Commentaries', 'PAM', 'Marcus Frajman', 'Annual', 'PAM', '9018503', '9005319', 'PAM 161', '2021-10-04 00:00:00', NULL, NULL, '161', 800, 0, '2021-09-13 00:00:00', '2021-09-20 00:00:00', '2021-09-27 00:00:00', '0', '0', '0', NULL, 'PAM_161', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(602, '1', 604, 'November', 'Tier 3', 'Commentaries', 'PAM', 'Marcus Frajman', 'Annual', 'PAM', '9018530', '9005319', 'PAM 162', '2021-11-22 00:00:00', NULL, NULL, '162', 800, 0, '2021-11-01 00:00:00', '2021-11-08 00:00:00', '2021-11-15 00:00:00', '0', '0', '0', NULL, 'PAM_162', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(603, '0', 605, 'February', 'Tier 1', 'Commentaries', 'PEV', 'Nina Packman', 'Annual', 'PEV', '9018534', '9005189', 'PEV 235', '2021-02-26 00:00:00', NULL, NULL, '235', 360, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '0', '0', '0', NULL, 'PEV_235', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(604, '1', 606, 'April', 'Tier 1', 'Commentaries', 'PEV', 'Nina Packman', 'Annual', 'PEV', '9018535', '9005189', 'PEV 236', '2021-02-26 00:00:00', '2021-04-23 00:00:00', 'Waiting for LE\'s approval', '236', 360, 826, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '1', '2021-04-23 00:00:00', 'PEV_236', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(605, '1', 607, 'May', 'Tier 1', 'Commentaries', 'PEV', 'Nina Packman', 'Annual', 'PEV', '9018536', '9005189', 'PEV 237', '2021-04-23 00:00:00', '2021-05-24 00:00:00', 'service 236 to be sent to press 23 April', '237', 360, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'PEV_237', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(606, '1', 608, 'June', 'Tier 1', 'Commentaries', 'PEV', 'Nina Packman', 'Annual', 'PEV', '9018537', '9005189', 'PEV 238', '2021-06-25 00:00:00', NULL, NULL, '238', 360, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'PEV_238', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(607, '1', 609, 'August', 'Tier 1', 'Commentaries', 'PEV', 'Nina Packman', 'Annual', 'PEV', '9018538', '9005189', 'PEV 239', '2021-08-20 00:00:00', NULL, NULL, '239', 360, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'PEV_239', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(608, '1', 610, 'October', 'Tier 1', 'Commentaries', 'PEV', 'Nina Packman', 'Annual', 'PEV', '9029810', '9005189', 'PEV 240', '2021-10-22 00:00:00', NULL, NULL, '240', 360, 0, '2021-10-01 00:00:00', '2021-10-08 00:00:00', '2021-10-15 00:00:00', '0', '0', '0', NULL, 'PEV_240', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(609, '1', 611, 'November', 'Tier 1', 'Commentaries', 'PEV', 'Nina Packman', 'Annual', 'PEV', '9029811', '9005189', 'PEV 241', '2021-11-26 00:00:00', NULL, NULL, '241', 360, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'PEV_241', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(610, '1', 612, 'June', 'Tier 2', 'Commentaries', 'PFI (AIL)', 'Marcus Frajman', 'Annual', 'PFI', '9018540', '9005207', 'PFI 49 with 1 x Guidecard \"Life Insurance Act\"', '2021-04-30 00:00:00', '2021-06-25 00:00:00', 'Waiting for additional content', '49', 200, 0, '2021-04-09 00:00:00', '2021-04-16 00:00:00', '2021-04-23 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'PFI (AIL)_49', 'with 1 x Guidecard \"Life Insurance Act\"', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(611, '1', 613, 'July', 'Tier 2', 'Commentaries', 'PFI (AIL)', 'Marcus Frajman', 'Annual', 'PFI', '9018541', '9005207', 'PFI 50', '2021-07-05 00:00:00', NULL, NULL, '50', 200, 0, '2021-06-14 00:00:00', '2021-06-21 00:00:00', '2021-06-28 00:00:00', '0', '0', '0', NULL, 'PFI (AIL)_50', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(612, '1', 614, 'October', 'Tier 2', 'Commentaries', 'PFI (AIL)', 'Marcus Frajman', 'Annual', 'PFI', '9029815', '9005207', 'PFI 51', '2021-10-04 00:00:00', NULL, NULL, '51', 200, 0, '2021-09-13 00:00:00', '2021-09-20 00:00:00', '2021-09-27 00:00:00', '0', '0', '0', NULL, 'PFI (AIL)_51', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(613, '1', 615, 'June', 'Tier 3', 'Commentaries', 'PIC', 'Genevieve Corish', 'Annual', 'PIC', '9018570', '9005277', 'PIC 27', '2021-06-03 00:00:00', NULL, NULL, '27', 250, 0, '2021-05-13 00:00:00', '2021-05-20 00:00:00', '2021-05-27 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'PIC_27', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(614, '1', 616, 'November', 'Tier 3', 'Commentaries', 'PIC', 'Genevieve Corish', 'Annual', 'PIC', '9029818', '9005277', 'PIC 28', '2021-11-04 00:00:00', NULL, NULL, '28', 250, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'PIC_28', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(615, '0', 617, 'April', 'Tier 2', 'Commentaries', 'PIL', 'Marcus Frajman', 'Annual', 'PIL01', '9018573', '9005243', 'PIL 61', '2021-04-05 00:00:00', NULL, NULL, '61', 182, 0, '2021-03-15 00:00:00', '2021-03-22 00:00:00', '2021-03-29 00:00:00', '0', '0', '0', NULL, 'PIL _61', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(616, '1', 618, 'May', 'Tier 2', 'Commentaries', 'PIL', 'Marcus Frajman', 'Annual', 'PIL01', '9029819', '9005243', 'PIL 62', '2021-04-05 00:00:00', '2021-05-17 00:00:00', 'delayed manuscripts', '62', 182, 0, '2021-03-15 00:00:00', '2021-03-22 00:00:00', '2021-03-29 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'PIL_62', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(617, '1', 619, 'July', 'Tier 2', 'Commentaries', 'PIL', 'Marcus Frajman', 'Annual', 'PIL01', '9029820', '9005243', 'PIL 63', '2021-07-05 00:00:00', NULL, NULL, '63', 182, 0, '2021-06-14 00:00:00', '2021-06-21 00:00:00', '2021-06-28 00:00:00', '0', '0', '0', NULL, 'PIL_63', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(618, '1', 620, 'October', 'Tier 2', 'Commentaries', 'PIL', 'Marcus Frajman', 'Annual', 'PIL01', '9029821', '9005243', 'PIL 64', '2021-10-04 00:00:00', NULL, NULL, '64', 182, 0, '2021-09-13 00:00:00', '2021-09-20 00:00:00', '2021-09-27 00:00:00', '0', '0', '0', NULL, 'PIL_64', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(619, '1', 621, 'February', 'Tier 3', 'Commentaries', 'PIN', 'Andrew Badaoui', 'Annual', 'PIN', '9018576', '9005182', 'PIN 107', '2021-02-26 00:00:00', NULL, NULL, '107', 204, 154, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '0', '2021-02-22 00:00:00', 'PIN_107', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(620, '1', 622, 'May', 'Tier 3', 'Commentaries', 'PIN', 'Andrew Badaoui', 'Annual', 'PIN', '9018577', '9005182', 'PIN 108', '2021-05-28 00:00:00', NULL, NULL, '108', 204, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'PIN_108', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(621, '1', 623, 'August', 'Tier 3', 'Commentaries', 'PIN', 'Andrew Badaoui', 'Annual', 'PIN', '9018578', '9005182', 'PIN 109', '2021-08-20 00:00:00', NULL, NULL, '109', 204, 0, '2021-07-30 00:00:00', '2021-08-06 00:00:00', '2021-08-13 00:00:00', '0', '0', '0', NULL, 'PIN_109', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(622, '1', 624, 'November', 'Tier 3', 'Commentaries', 'PIN', 'Andrew Badaoui', 'Annual', 'PIN', '9029822', '9005182', 'PIN 110', '2021-11-27 00:00:00', NULL, NULL, '110', 204, 0, '2021-11-08 00:00:00', '2021-11-15 00:00:00', '2021-11-22 00:00:00', '0', '0', '0', NULL, 'PIN_110', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(623, '0', 625, 'April', 'Tier 3', 'Commentaries', 'PIQ', 'Andrew Badaoui', 'Annual', 'PIQ', '9018581', '9005315', 'PIQ 81', '2021-02-26 00:00:00', '2021-04-26 00:00:00', 'Insufficient content', '81', 140, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '0', '0', '1', NULL, 'PIQ_81', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(624, '1', 626, 'May', 'Tier 3', 'Commentaries', 'PIQ', 'Andrew Badaoui', 'Annual', 'PIQ', '9029823', '9005315', 'PIQ 82', '2021-02-26 00:00:00', '2021-05-31 00:00:00', 'Insufficient content', '82', 140, 0, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'PIQ_82', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(625, '1', 627, 'June', 'Tier 3', 'Commentaries', 'PIQ', 'Andrew Badaoui', 'Annual', 'PIQ', '9029824', '9005315', 'PIQ 83', '2021-06-25 00:00:00', NULL, NULL, '83', 140, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'PIQ_83', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(626, '1', 628, 'October', 'Tier 3', 'Commentaries', 'PIQ', 'Andrew Badaoui', 'Annual', 'PIQ', '9029825', '9005315', 'PIQ 84', '2021-10-29 00:00:00', NULL, NULL, '84', 140, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'PIQ_84', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(627, '1', 629, 'May', 'Tier 3', 'Commentaries', 'PL', 'Genevieve Corish', 'Annual', 'PL', '9018607', '9005174/9005174', 'PL 90', '2021-05-04 00:00:00', '2021-05-31 00:00:00', NULL, '90', 216, 0, '2021-04-13 00:00:00', '2021-04-20 00:00:00', '2021-04-27 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'PL_90', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(628, '1', 630, 'July', 'Tier 3', 'Commentaries', 'PL', 'Genevieve Corish', 'Annual', 'PL', '9018608', '9005174/9005174', 'PL 91', '2021-07-15 00:00:00', NULL, NULL, '91', 216, 0, '2021-06-24 00:00:00', '2021-07-01 00:00:00', '2021-07-08 00:00:00', '0', '0', '0', NULL, 'PL_91', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(629, '1', 631, 'October', 'Tier 3', 'Commentaries', 'PL', 'Genevieve Corish', 'Annual', 'PL', '9018609', '9005174/9005174', 'PL 92', '2021-10-14 00:00:00', NULL, NULL, '92', 216, 0, '2021-09-23 00:00:00', '2021-09-30 00:00:00', '2021-10-07 00:00:00', '0', '0', '0', NULL, 'PL_92', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(630, '1', 632, 'February', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029913', '9005304', 'PLB 36.1', '2021-02-25 00:00:00', NULL, NULL, '36.1', 20, 12, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '1', '0', '0', '2021-02-25 00:00:00', 'PLB_36.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(631, '1', 633, 'April', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029914', '9005304', 'PLB 36.2', '2021-03-25 00:00:00', '2021-04-05 00:00:00', 'delayed manuscripts', '36.2', 20, 12, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '1', '0', '1', '2021-03-31 00:00:00', 'PLB_36.2', '11 Mar: From LE: I will need to chase the General Editor – the due date for submission of articles was 8 March.', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(632, '1', 634, 'May', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029915', '9005304', 'PLB 36.3', '2021-04-27 00:00:00', '2021-05-10 00:00:00', 'delayed manuscripts', '36.3', 20, 0, '2021-04-06 00:00:00', '2021-04-13 00:00:00', '2021-04-20 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'PLB_36.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(633, '1', 635, 'May', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029916', '9005304', 'PLB 36.4', '2021-05-27 00:00:00', NULL, NULL, '36.4', 20, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'PLB_36.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(634, '1', 636, 'June', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029917', '9005304', 'PLB 36.5', '2021-06-25 00:00:00', NULL, NULL, '36.5', 20, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'PLB_36.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(635, '1', 637, 'July', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029918', '9005304', 'PLB 36.6', '2021-07-26 00:00:00', NULL, NULL, '36.6', 20, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'PLB_36.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(636, '1', 638, 'August', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029919', '9005304', 'PLB 36.7', '2021-08-26 00:00:00', NULL, NULL, '36.7', 20, 0, '2021-08-05 00:00:00', '2021-08-12 00:00:00', '2021-08-19 00:00:00', '0', '0', '0', NULL, 'PLB_36.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(637, '1', 639, 'September', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029920', '9005304', 'PLB 36.8', '2021-09-24 00:00:00', NULL, NULL, '36.8', 20, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'PLB_36.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(638, '1', 640, 'October', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029921', '9005304', 'PLB 36.9', '2021-10-25 00:00:00', NULL, NULL, '36.9', 20, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'PLB_36.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(639, '1', 641, 'November', 'Newsletter', 'Commentaries', 'PLB', 'Kim Hodge', 'Annual', 'PLB', '9029922', '9005304', 'PLB 36.10', '2021-11-25 00:00:00', NULL, NULL, '36.10', 20, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'PLB_36.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(640, '0', 642, 'March', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029923', '9005297', 'PLP 17.9', '2021-03-04 00:00:00', NULL, NULL, '17.9', 20, 0, '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2021-02-25 00:00:00', '0', '0', '0', NULL, 'PLP_17.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(641, '0', 643, 'April', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029924', '9005297', 'PLP 17.10', '2021-04-01 00:00:00', NULL, NULL, '17.10', 20, 0, '2021-03-11 00:00:00', '2021-03-18 00:00:00', '2021-03-25 00:00:00', '0', '0', '0', NULL, 'PLP_17.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(642, '0', 644, 'May', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029925', '9005297', 'PLP 18.1', '2021-05-06 00:00:00', NULL, NULL, '18.1', 20, 0, '2021-04-15 00:00:00', '2021-04-22 00:00:00', '2021-04-29 00:00:00', '0', '0', '0', NULL, 'PLP_18.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(643, '0', 645, 'June', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029926', '9005297', 'PLP 18.2', '2021-06-03 00:00:00', NULL, NULL, '18.2', 20, 0, '2021-05-13 00:00:00', '2021-05-20 00:00:00', '2021-05-27 00:00:00', '0', '0', '0', NULL, 'PLP_18.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(644, '0', 646, 'July', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029927', '9005297', 'PLP 18.3', '2021-07-01 00:00:00', NULL, NULL, '18.3', 20, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'PLP_18.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(645, '0', 647, 'August', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029928', '9005297', 'PLP 18.4', '2021-08-05 00:00:00', NULL, NULL, '18.4', 20, 0, '2021-07-15 00:00:00', '2021-07-22 00:00:00', '2021-07-29 00:00:00', '0', '0', '0', NULL, 'PLP_18.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(646, '0', 648, 'September', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029929', '9005297', 'PLP 18.5', '2021-09-02 00:00:00', NULL, NULL, '18.5', 20, 0, '2021-08-12 00:00:00', '2021-08-19 00:00:00', '2021-08-26 00:00:00', '0', '0', '0', NULL, 'PLP_18.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(647, '0', 649, 'October', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029930', '9005297', 'PLP 18.6', '2021-10-01 00:00:00', NULL, NULL, '18.6', 20, 0, '2021-09-10 00:00:00', '2021-09-17 00:00:00', '2021-09-24 00:00:00', '0', '0', '0', NULL, 'PLP_18.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(648, '0', 650, 'November', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029931', '9005297', 'PLP 18.7', '2021-11-04 00:00:00', NULL, NULL, '18.7', 20, 0, '2021-10-14 00:00:00', '2021-10-21 00:00:00', '2021-10-28 00:00:00', '0', '0', '0', NULL, 'PLP_18.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(649, '0', 651, 'December', NULL, 'Commentaries', 'PLP', 'Genevieve Corish', 'Annual', 'PLP', '9029932', '9005297', 'PLP 18.8', '2021-12-02 00:00:00', NULL, NULL, '18.8', 20, 0, '2021-11-11 00:00:00', '2021-11-18 00:00:00', '2021-11-25 00:00:00', '0', '0', '0', NULL, 'PLP_18.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(650, '0', 652, 'March', NULL, 'Commentaries', 'PLR', 'Meg McDermott', 'Annual', 'PLR', NULL, '9005294', 'PLR 28.5 & 6', '2021-03-25 00:00:00', NULL, NULL, '28.5&6', 16, 0, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '0', '0', '0', NULL, 'PLR_28.5&6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(651, '0', 653, 'April', NULL, 'Commentaries', 'PLR', 'Meg McDermott', 'Annual', 'PLR', '9018927', '9005294', 'PLR 28.7', '2021-04-27 00:00:00', NULL, NULL, '28.7', 16, 0, '2021-04-06 00:00:00', '2021-04-13 00:00:00', '2021-04-20 00:00:00', '0', '0', '0', NULL, 'PLR_28.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(652, '0', 654, 'May', NULL, 'Commentaries', 'PLR', 'Meg McDermott', 'Annual', 'PLR', '9018928', '9005294', 'PLR 28.8', '2021-05-27 00:00:00', NULL, NULL, '28.8', 16, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'PLR_28.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(653, '0', 655, 'June', NULL, 'Commentaries', 'PLR', 'Meg McDermott', 'Annual', 'PLR', '9018929', '9005294', 'PLR 28.9', '2021-06-25 00:00:00', NULL, NULL, '28.9', 16, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'PLR_28.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(654, '0', 656, 'July', NULL, 'Commentaries', 'PLR', 'Meg McDermott', 'Annual', 'PLR', '9018930', '9005294', 'PLR 29.1', '2021-07-26 00:00:00', NULL, NULL, '29.1', 16, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'PLR_29.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(655, '0', 657, 'August', NULL, 'Commentaries', 'PLR', 'Meg McDermott', 'Annual', 'PLR', '9018931', '9005294', 'PLR 29.2', '2021-08-26 00:00:00', NULL, NULL, '29.2', 16, 0, '2021-08-05 00:00:00', '2021-08-12 00:00:00', '2021-08-19 00:00:00', '0', '0', '0', NULL, 'PLR_29.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(656, '1', 658, 'September', 'Tier 2', 'Commentaries', 'PPSA', 'Meg McDermott', 'Annual', 'PPSA', '9018614', '9005266', 'PPSA 34', '2021-09-24 00:00:00', NULL, NULL, '34', 190, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'PPSA_34', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(657, '1', 659, 'September', 'Tier 2', 'Commentaries', 'PPSA', 'Meg McDermott', 'Annual', 'PPSA', '9029826', '9005266', 'PPSA 35', '2021-09-23 00:00:00', NULL, NULL, '35', 190, 0, '2021-09-02 00:00:00', '2021-09-09 00:00:00', '2021-09-16 00:00:00', '0', '0', '0', NULL, 'PPSA_35', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(658, '1', 660, 'April', 'Tier 3', 'Commentaries', 'QCAT', 'Kim Hodge', 'Annual', 'QCAT', '29-Apr', '9005286/9005286', 'QCAT 19', '2021-04-20 00:00:00', '2021-04-29 00:00:00', 'EPMS-62927: format issue on the generated PDF file on the list — explicit label tagging — in QCATMT guidecard', '19', 160, 192, '2021-03-30 00:00:00', '2021-04-06 00:00:00', '2021-04-13 00:00:00', '1', '0', '1', '2021-04-29 00:00:00', 'QCAT_19', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(659, '1', 661, 'September', 'Tier 3', 'Commentaries', 'QCAT', 'Kim Hodge', 'Annual', 'QCAT', '9018617', '9005286/9005286', 'QCAT 20', '2021-09-20 00:00:00', NULL, NULL, '20', 160, 0, '2021-08-30 00:00:00', '2021-09-06 00:00:00', '2021-09-13 00:00:00', '0', '0', '0', NULL, 'QCAT_20', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(660, '1', 662, 'February', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9018935', '9005296', 'REP 22.3', '2021-02-26 00:00:00', '2021-02-26 00:00:00', 'insufficient content', '22.3', 16, 12, '2021-02-05 00:00:00', '2021-02-12 00:00:00', '2021-02-19 00:00:00', '1', '0', '1', '2021-02-22 00:00:00', 'REP_22.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(661, '1', 663, 'May', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9018936', '9005296', 'REP 22.4', '2021-03-26 00:00:00', '2021-05-21 00:00:00', 'insufficient content; requested to combine 22.4 and 22.5', '22.4', 16, 12, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '1', '0', '1', '2021-05-06 00:00:00', 'REP_22.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(662, '1', 664, 'June', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9018937', '9005296', 'REP 22.5', '2021-04-16 00:00:00', '2021-06-29 00:00:00', 'No contents', '22.5', 16, 0, '2021-03-26 00:00:00', '2021-04-02 00:00:00', '2021-04-09 00:00:00', '0', '0', '1', NULL, 'REP_22.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(663, '1', 665, 'July', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9018938', '9005296', 'REP 22.6', '2021-05-07 00:00:00', '2021-07-29 00:00:00', 'No contents', '22.6', 16, 0, '2021-04-16 00:00:00', '2021-04-23 00:00:00', '2021-04-30 00:00:00', '0', '0', '1', NULL, 'REP_22.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(664, '1', 666, 'August', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9018939', '9005296', 'REP 22.7', '2021-05-28 00:00:00', '2021-08-27 00:00:00', 'No contents', '22.7', 16, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '1', NULL, 'REP_22.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(665, '1', 667, 'September', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9018940', '9005296', 'REP 22.8', '2021-06-21 00:00:00', '2021-09-22 00:00:00', 'No contents', '22.8', 16, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '1', NULL, 'REP_22.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(666, '1', 668, 'October', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9018941', '9005296', 'REP 22.9', '2021-07-19 00:00:00', '2021-10-15 00:00:00', 'No contents', '22.9', 16, 0, '2021-06-28 00:00:00', '2021-07-05 00:00:00', '2021-07-12 00:00:00', '0', '0', '1', NULL, 'REP_22.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(667, '1', 669, 'November', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', NULL, '9005296', 'REP 22.10', '2021-08-23 00:00:00', '2021-11-12 00:00:00', 'No contents', '22.10', 16, 0, '2021-08-02 00:00:00', '2021-08-09 00:00:00', '2021-08-16 00:00:00', '0', '0', '1', NULL, 'REP_22.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(668, '1', 670, 'September', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9029933', '9005296', 'REP 23.1', '2021-09-27 00:00:00', NULL, NULL, '23.1', 16, 0, '2021-09-06 00:00:00', '2021-09-13 00:00:00', '2021-09-20 00:00:00', '0', '0', '0', NULL, 'REP_23.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(669, '1', 671, 'November', 'Newsletter', 'Commentaries', 'REP', 'Rose Thomsen', 'Annual', 'REP', '9029934', '9005296', 'REP 23.2', '2021-11-01 00:00:00', NULL, NULL, '23.2', 16, 0, '2021-10-11 00:00:00', '2021-10-18 00:00:00', '2021-10-25 00:00:00', '0', '0', '0', NULL, 'REP_23.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(670, '1', 680, 'January', 'Tier 3', 'Commentaries', 'RLV', 'Tim Patrick', 'Annual', 'RLV', '9018619', '9005263', 'RLV 38', '2021-01-19 00:00:00', NULL, NULL, '38', 210, 132, '2020-12-29 00:00:00', '2021-01-05 00:00:00', '2021-01-12 00:00:00', '1', '0', '0', '2021-01-14 00:00:00', 'RLV_38', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(671, '1', 681, 'May', 'Tier 3', 'Commentaries', 'RLV', 'Tim Patrick', 'Annual', 'RLV', '9018443', '9005263', 'RLV 39', '2021-05-14 00:00:00', NULL, NULL, '39', 210, 0, '2021-04-23 00:00:00', '2021-04-30 00:00:00', '2021-05-07 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'RLV_39', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(672, '1', 682, 'October', 'Tier 3', 'Commentaries', 'RLV', 'Tim Patrick', 'Annual', 'RLV', '9029829', '9005263', 'RLV 40', '2021-10-15 00:00:00', NULL, NULL, '40', 210, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'RLV_40', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(673, '1', 683, 'June', 'Tier 3', 'Commentaries', 'SENN', 'Ragnii Ommanney', 'Annual', 'SENN', '9029831', '9005214', 'SENN 38', '2021-04-02 00:00:00', '2021-06-15 00:00:00', 'insufficient content', '38', 174, 0, '2021-03-12 00:00:00', '2021-03-19 00:00:00', '2021-03-26 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'SENN_38', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(674, '1', 684, 'September', 'Tier 3', 'Commentaries', 'SENN', 'Ragnii Ommanney', 'Annual', 'SENN', '9029832', '9005214', 'SENN 39', '2021-09-17 00:00:00', NULL, NULL, '39', 174, 0, '2021-08-27 00:00:00', '2021-09-03 00:00:00', '2021-09-10 00:00:00', '0', '0', '0', NULL, 'SENN_39', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(675, '0', 685, 'February', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9018764', '9005305', 'SLB 32.6', '2021-02-22 00:00:00', NULL, NULL, '32.6', 24, 0, '2021-02-01 00:00:00', '2021-02-08 00:00:00', '2021-02-15 00:00:00', '0', '0', '0', NULL, 'SLB_32.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(676, '0', 686, 'March', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029943', '9005305', 'SLB 32.7', '2021-03-10 00:00:00', NULL, NULL, '32.7', 24, 0, '2021-02-17 00:00:00', '2021-02-24 00:00:00', '2021-03-03 00:00:00', '0', '0', '0', NULL, 'SLB_32.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(677, '0', 687, 'April', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029944', '9005305', 'SLB 32.8', '2021-04-14 00:00:00', NULL, NULL, '32.8', 24, 0, '2021-03-24 00:00:00', '2021-03-31 00:00:00', '2021-04-07 00:00:00', '0', '0', '0', NULL, 'SLB_32.8', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(678, '0', 688, 'May', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029945', '9005305', 'SLB 32.9', '2021-05-12 00:00:00', NULL, NULL, '32.9', 24, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '0', NULL, 'SLB_32.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(679, '0', 689, 'June', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029946', '9005305', 'SLB 32.10', '2021-06-09 00:00:00', NULL, NULL, '32.10', 24, 0, '2021-05-19 00:00:00', '2021-05-26 00:00:00', '2021-06-02 00:00:00', '0', '0', '0', NULL, 'SLB_32.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(680, '0', 690, 'July', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029947', '9005305', 'SLB 33.1', '2021-07-14 00:00:00', NULL, NULL, '33.1', 24, 0, '2021-06-23 00:00:00', '2021-06-30 00:00:00', '2021-07-07 00:00:00', '0', '0', '0', NULL, 'SLB_33.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(681, '0', 691, 'August', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029948', '9005305', 'SLB 33.2', '2021-08-11 00:00:00', NULL, NULL, '33.2', 24, 0, '2021-07-21 00:00:00', '2021-07-28 00:00:00', '2021-08-04 00:00:00', '0', '0', '0', NULL, 'SLB_33.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(682, '0', 692, 'September', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029949', '9005305', 'SLB 33.3', '2021-09-15 00:00:00', NULL, NULL, '33.3', 24, 0, '2021-08-25 00:00:00', '2021-09-01 00:00:00', '2021-09-08 00:00:00', '0', '0', '0', NULL, 'SLB_33.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(683, '0', 693, 'October', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029950', '9005305', 'SLB 33.4', '2021-10-13 00:00:00', NULL, NULL, '33.4', 24, 0, '2021-09-22 00:00:00', '2021-09-29 00:00:00', '2021-10-06 00:00:00', '0', '0', '0', NULL, 'SLB_33.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(684, '0', 694, 'November', NULL, 'Commentaries', 'SLB', 'Shomal Prasad', 'Annual', 'SLB', '9029951', '9005305', 'SLB 33.5', '2021-11-17 00:00:00', NULL, NULL, '33.5', 24, 0, '2021-10-27 00:00:00', '2021-11-03 00:00:00', '2021-11-10 00:00:00', '0', '0', '0', NULL, 'SLB_33.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(685, '1', 695, 'June', 'Tier 2', 'Commentaries', 'SMN', 'Kim Hodge', 'Annual', 'SMN', '9018585', '9005206', 'SMN 74', '2021-05-07 00:00:00', '2021-06-25 00:00:00', 'insufficient content', '74', 383, 0, '2021-04-16 00:00:00', '2021-04-23 00:00:00', '2021-04-30 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'SMN_74', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(686, '1', 696, 'August', 'Tier 2', 'Commentaries', 'SMN', 'Kim Hodge', 'Annual', 'SMN', '9029833', '9005206', 'SMN 75', '2021-08-09 00:00:00', NULL, NULL, '75', 383, 0, '2021-07-19 00:00:00', '2021-07-26 00:00:00', '2021-08-02 00:00:00', '0', '0', '0', NULL, 'SMN_75', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(687, '1', 697, 'November', 'Tier 2', 'Commentaries', 'SMN', 'Kim Hodge', 'Annual', 'SMN', '9029834', '9005206', 'SMN 76', '2021-11-11 00:00:00', NULL, NULL, '76', 384, 0, '2021-10-21 00:00:00', '2021-10-28 00:00:00', '2021-11-04 00:00:00', '0', '0', '0', NULL, 'SMN_76', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(688, '0', 698, 'March', NULL, 'Commentaries', 'TAX', 'Kim Hodge', 'Annual', 'TAX', '9018765', '9005453', 'ATLB 5.9', '2021-03-10 00:00:00', NULL, NULL, '5.9', 16, 0, '2021-02-17 00:00:00', '2021-02-24 00:00:00', '2021-03-03 00:00:00', '0', '0', '0', NULL, 'TAX_5.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(689, '0', 699, 'May', NULL, 'Commentaries', 'TAX', 'Kim Hodge', 'Annual', 'TAX', '9018766', '9005453', 'ATLB 5.10', '2021-05-10 00:00:00', NULL, NULL, '5.10', 16, 0, '2021-04-19 00:00:00', '2021-04-26 00:00:00', '2021-05-03 00:00:00', '0', '0', '0', NULL, 'TAX_5.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(690, '0', 700, 'July', NULL, 'Commentaries', 'TAX', 'Kim Hodge', 'Annual', 'TAX', '9018767', '9005453', 'ATLB 6.1', '2021-07-12 00:00:00', NULL, NULL, '6.1', 16, 0, '2021-06-21 00:00:00', '2021-06-28 00:00:00', '2021-07-05 00:00:00', '0', '0', '0', NULL, 'TAX_6.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(691, '0', 701, 'September', NULL, 'Commentaries', 'TAX', 'Kim Hodge', 'Annual', 'TAX', '9018768', '9005453', 'ATLB 6.2', '2021-09-10 00:00:00', NULL, NULL, '6.2', 16, 0, '2021-08-20 00:00:00', '2021-08-27 00:00:00', '2021-09-03 00:00:00', '0', '0', '0', NULL, 'TAX_6.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(692, '0', 702, 'October', NULL, 'Commentaries', 'TAX', 'Kim Hodge', 'Annual', 'TAX', '9018769', '9005453', 'ATLB 6.3', '2021-10-11 00:00:00', NULL, NULL, '6.3', 16, 0, '2021-09-20 00:00:00', '2021-09-27 00:00:00', '2021-10-04 00:00:00', '0', '0', '0', NULL, 'TAX_6.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(693, '0', 703, 'November', NULL, 'Commentaries', 'TAX', 'Kim Hodge', 'Annual', 'TAX', '9018770', '9005453', 'ATLB 6.4', '2021-11-10 00:00:00', NULL, NULL, '6.4', 16, 0, '2021-10-20 00:00:00', '2021-10-27 00:00:00', '2021-11-03 00:00:00', '0', '0', '0', NULL, 'TAX_6.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(694, '1', 704, 'March', 'Tier 3', 'Commentaries', 'TPA', 'Meg McDermott', 'Annual', 'TPA', '9018588', '9005250', 'TPA 52', '2021-03-18 00:00:00', NULL, NULL, '52', 350, 588, '2021-02-25 00:00:00', '2021-03-04 00:00:00', '2021-03-11 00:00:00', '1', '0', '0', '2021-02-26 00:00:00', 'TPA_52', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);
INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(695, '1', 705, 'September', 'Tier 3', 'Commentaries', 'TPA', 'Meg McDermott', 'Annual', 'TPA', '9029837', '9005250', 'TPA 53', '2021-09-23 00:00:00', NULL, NULL, '53', 350, 0, '2021-09-02 00:00:00', '2021-09-09 00:00:00', '2021-09-16 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'TPA_53', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(696, '0', 706, 'February', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9018780', '9005305', 'TPL 36.8 & 9 Combined', '2021-02-15 00:00:00', NULL, NULL, '36.8&9', 16, 0, '2021-01-25 00:00:00', '2021-02-01 00:00:00', '2021-02-08 00:00:00', '0', '0', '0', NULL, 'TPL_36.8&9', 'Combined', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(697, '0', 707, 'March', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', NULL, '9005305', 'TPL 36.9', '2021-03-25 00:00:00', NULL, NULL, '36.9', 16, 0, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '0', '0', '0', NULL, 'TPL_36.9', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(698, '0', 708, 'April', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', NULL, '9005305', 'TPL 36.10', '2021-04-27 00:00:00', NULL, NULL, '36.10', 16, 0, '2021-04-06 00:00:00', '2021-04-13 00:00:00', '2021-04-20 00:00:00', '0', '0', '0', NULL, 'TPL_36.10', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(699, '0', 709, 'May', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9029957', '9005305', 'TPL 37.1', '2021-05-27 00:00:00', NULL, NULL, '37.1', 16, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'TPL_37.1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(700, '0', 710, 'June', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9029958', '9005305', 'TPL 37.2', '2021-06-25 00:00:00', NULL, NULL, '37.2', 16, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'TPL_37.2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(701, '0', 711, 'July', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9029959', '9005305', 'TPL 37.3', '2021-07-26 00:00:00', NULL, NULL, '37.3', 16, 0, '2021-07-05 00:00:00', '2021-07-12 00:00:00', '2021-07-19 00:00:00', '0', '0', '0', NULL, 'TPL_37.3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(702, '0', 712, 'August', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9029960', '9005305', 'TPL 37.4', '2021-08-26 00:00:00', NULL, NULL, '37.4', 16, 0, '2021-08-05 00:00:00', '2021-08-12 00:00:00', '2021-08-19 00:00:00', '0', '0', '0', NULL, 'TPL_37.4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(703, '0', 713, 'September', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9029961', '9005305', 'TPL 37.5', '2021-09-24 00:00:00', NULL, NULL, '37.5', 16, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'TPL_37.5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(704, '0', 714, 'October', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9029962', '9005305', 'TPL 37.6', '2021-10-25 00:00:00', NULL, NULL, '37.6', 16, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'TPL_37.6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(705, '0', 715, 'November', NULL, 'Commentaries', 'TPL', 'Meg McDermott', 'Annual', 'TPL', '9029963', '9005305', 'TPL 37.7', '2021-11-24 00:00:00', NULL, NULL, '37.7', 16, 0, '2021-11-03 00:00:00', '2021-11-10 00:00:00', '2021-11-17 00:00:00', '0', '0', '0', NULL, 'TPL_37.7', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(706, '1', 716, 'March', 'Tier 2', 'Commentaries', 'TPP', 'Kim Hodge', 'Annual', 'TPP', '9018507', '9005192/9005192', 'TPP 171 (with Bulletin 126)', '2021-02-16 00:00:00', '2021-03-30 00:00:00', 'complexity of Task 1 with 10 manuscripts', '171', 332, 326, '2021-01-26 00:00:00', '2021-02-02 00:00:00', '2021-02-09 00:00:00', '1', '0', '1', '2021-03-30 00:00:00', 'TPP_171', '(with Bulletin 126)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(707, '1', 717, 'May', 'Tier 2', 'Commentaries', 'TPP', 'Kim Hodge', 'Annual', 'TPP', '9018508', '9005192/9005192', 'TPP 172 (with Bulletin 127)', '2021-04-16 00:00:00', '2021-05-21 00:00:00', 'insufficient content', '172', 332, 0, '2021-03-26 00:00:00', '2021-04-02 00:00:00', '2021-04-09 00:00:00', '0', '0', '1', NULL, 'TPP_172', '(with Bulletin 127)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(708, '1', 718, 'June', 'Tier 2', 'Commentaries', 'TPP', 'Kim Hodge', 'Annual', 'TPP', '9029839', '9005192/9005192', 'TPP 173 (with Bulletin 128)', '2021-06-16 00:00:00', NULL, NULL, '173', 332, 0, '2021-05-26 00:00:00', '2021-06-02 00:00:00', '2021-06-09 00:00:00', '0', '0', '0', NULL, 'TPP_173', '(with Bulletin 128)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(709, '1', 719, 'August', 'Tier 2', 'Commentaries', 'TPP', 'Kim Hodge', 'Annual', 'TPP', '9029840', '9005192/9005192', 'TPP 174 (with Bulletin 129)', '2021-08-16 00:00:00', NULL, NULL, '174', 332, 0, '2021-07-26 00:00:00', '2021-08-02 00:00:00', '2021-08-09 00:00:00', '0', '0', '0', NULL, 'TPP_174', '(with Bulletin 129)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(710, '1', 720, 'November', 'Tier 2', 'Commentaries', 'TPP', 'Kim Hodge', 'Annual', 'TPP', '9029841', '9005192/9005192', 'TPP 175 (with Bulletin 130)', '2021-11-16 00:00:00', NULL, NULL, '175', 332, 0, '2021-10-26 00:00:00', '2021-11-02 00:00:00', '2021-11-09 00:00:00', '0', '0', '0', NULL, 'TPP_175', '(with Bulletin 130)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(711, '1', 721, 'June', 'Tier 3', 'Commentaries', 'TR', 'Shomal Prasad', 'Annual', 'TR', '9029844', '9005222/9005222', 'TR 115', '2021-06-14 00:00:00', NULL, NULL, '115', 210, 0, '2021-05-24 00:00:00', '2021-05-31 00:00:00', '2021-06-07 00:00:00', '0', '0', '0', NULL, 'TR_115', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(712, '1', 722, 'October', 'Tier 3', 'Commentaries', 'TR', 'Shomal Prasad', 'Annual', 'TR', '9029845', '9005222/9005222', 'TR 116', '2021-10-18 00:00:00', NULL, NULL, '116', 210, 0, '2021-09-27 00:00:00', '2021-10-04 00:00:00', '2021-10-11 00:00:00', '0', '0', '0', NULL, 'TR_116', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(713, '0', 723, 'April', 'Tier 1', 'Commentaries', 'UCPN', 'Katharine Lam', 'Annual', 'UCPN', '9018514', '9005251', 'UCPN 127', '2021-02-25 00:00:00', '2021-04-30 00:00:00', 'LE still finalizing materials for the service', '127', 380, 0, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2', '0', '1', '1900-01-00 00:00:00', 'UCPN_127', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(714, '0', 724, 'April', 'Tier 1', 'Commentaries', 'UCPN', 'Katharine Lam', 'Annual', 'UCPN', '9018515', '9005251', 'UCPN 128', '2021-04-22 00:00:00', NULL, NULL, '128', 380, 0, '2021-04-01 00:00:00', '2021-04-08 00:00:00', '2021-04-15 00:00:00', '0', '0', '0', NULL, 'UCPN_128', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(715, '0', 725, 'June', 'Tier 1', 'Commentaries', 'UCPN', 'Katharine Lam', 'Annual', 'UCPN', '9018516', '9005251', 'UCPN 129', '2021-06-24 00:00:00', NULL, NULL, '129', 380, 0, '2021-06-03 00:00:00', '2021-06-10 00:00:00', '2021-06-17 00:00:00', '0', '0', '0', NULL, 'UCPN_129', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(716, '0', 726, 'August', 'Tier 1', 'Commentaries', 'UCPN', 'Katharine Lam', 'Annual', 'UCPN', '9018543', '9005251', 'UCPN 130', '2021-08-19 00:00:00', NULL, NULL, '130', 380, 0, '2021-07-29 00:00:00', '2021-08-05 00:00:00', '2021-08-12 00:00:00', '0', '0', '0', NULL, 'UCPN_130', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(717, '0', 727, 'October', 'Tier 1', 'Commentaries', 'UCPN', 'Katharine Lam', 'Annual', 'UCPN', '9018544', '9005251', 'UCPN 131', '2021-10-21 00:00:00', NULL, NULL, '131', 380, 0, '2021-09-30 00:00:00', '2021-10-07 00:00:00', '2021-10-14 00:00:00', '0', '0', '0', NULL, 'UCPN_131', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(718, '0', 728, 'November', 'Tier 1', 'Commentaries', 'UCPN', 'Katharine Lam', 'Annual', 'UCPN', '9029846', '9005251', 'UCPN 132', '2021-11-25 00:00:00', NULL, NULL, '132', 380, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'UCPN_132', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(719, '1', 729, 'May', 'Tier 2', 'Commentaries', 'WCN', 'Katharine Lam', 'Annual', 'WCN', '9018546', '9005188', 'WCN 155', '2002-03-12 00:00:00', '2021-05-31 00:00:00', 'insufficient materials', '155', 180, 0, '2002-02-19 00:00:00', '2002-02-26 00:00:00', '2002-03-05 00:00:00', '1', '0', '1', '1900-01-00 00:00:00', 'WCN_155', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(720, '1', 730, 'June', 'Tier 2', 'Commentaries', 'WCN', 'Katharine Lam', 'Annual', 'WCN', '9018547', '9005188', 'WCN 156', '2021-05-19 00:00:00', '2021-06-09 00:00:00', 'gapping issue with WCN155', '156', 180, 0, '2021-04-28 00:00:00', '2021-05-05 00:00:00', '2021-05-12 00:00:00', '0', '0', '1', NULL, 'WCN_156', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(721, '1', 731, 'September', 'Tier 2', 'Commentaries', 'WCN', 'Katharine Lam', 'Annual', 'WCN', '9018548', '9005188', 'WCN 157', '2021-09-08 00:00:00', NULL, NULL, '157', 180, 0, '2021-08-18 00:00:00', '2021-08-25 00:00:00', '2021-09-01 00:00:00', '0', '0', '0', NULL, 'WCN_157', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(722, '1', 732, 'October', 'Tier 2', 'Commentaries', 'WCN', 'Katharine Lam', 'Annual', 'WCN', '9029851', '9005188', 'WCN 158', '2021-10-27 00:00:00', NULL, NULL, '158', 180, 0, '2021-10-06 00:00:00', '2021-10-13 00:00:00', '2021-10-20 00:00:00', '0', '0', '0', NULL, 'WCN_158', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(723, '1', 733, 'May', 'Tier 2', 'Commentaries', 'WCWA', 'Katharine Lam', 'Annual', 'WCW', '9018551', '9005236/9005236', 'WCWA 78', '2021-05-19 00:00:00', NULL, NULL, '78', 180, 0, '2021-04-28 00:00:00', '2021-05-05 00:00:00', '2021-05-12 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'WCWA_78', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(724, '1', 734, 'September', 'Tier 2', 'Commentaries', 'WCWA', 'Katharine Lam', 'Annual', 'WCW', '9029853', '9005236/9005236', 'WCWA 79', '2021-09-18 00:00:00', NULL, NULL, '79', 180, 0, '2021-08-30 00:00:00', '2021-09-06 00:00:00', '2021-09-13 00:00:00', '0', '0', '0', NULL, 'WCWA_79', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(725, '0', 735, 'April', 'Tier 1', 'Commentaries', 'WFW', 'Katharine Lam', 'Annual', 'WFW', '9018553', '9005318', 'WFW 79', '2021-02-24 00:00:00', '2021-04-30 00:00:00', 'Tasks not all completed yet. Varied by LE', '79', 339, 0, '2021-02-03 00:00:00', '2021-02-10 00:00:00', '2021-02-17 00:00:00', '2', '0', '1', '1900-01-00 00:00:00', 'WFW_79', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(726, '0', 736, 'May', 'Tier 1', 'Commentaries', 'WFW', 'Katharine Lam', 'Annual', 'WFW', '9018554', '9005318', 'WFW 80', '2021-03-10 00:00:00', '2021-05-21 00:00:00', 'service 79 has not been sent to press yet', '80', 339, 0, '2021-02-17 00:00:00', '2021-02-24 00:00:00', '2021-03-03 00:00:00', '0', '0', '1', NULL, 'WFW_80', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(727, '0', 737, 'June', 'Tier 1', 'Commentaries', 'WFW', 'Katharine Lam', 'Annual', 'WFW', '9018555', '9005318', 'WFW 81', '2021-05-19 00:00:00', '2021-06-14 00:00:00', 'gapping issue with service 80', '81', 339, 0, '2021-04-28 00:00:00', '2021-05-05 00:00:00', '2021-05-12 00:00:00', '0', '0', '1', NULL, 'WFW_81', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(728, '0', 738, 'September', 'Tier 1', 'Commentaries', 'WFW', 'Katharine Lam', 'Annual', 'WFW', '9029855', '9005318', 'WFW 82', '2021-09-08 00:00:00', NULL, NULL, '82', 339, 0, '2021-08-18 00:00:00', '2021-08-25 00:00:00', '2021-09-01 00:00:00', '0', '0', '0', NULL, 'WFW_82', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(729, '0', 739, 'October', 'Tier 1', 'Commentaries', 'WFW', 'Katharine Lam', 'Annual', 'WFW', '9029856', '9005318', 'WFW 83', '2021-10-27 00:00:00', NULL, NULL, '83', 339, 0, '2021-10-06 00:00:00', '2021-10-13 00:00:00', '2021-10-20 00:00:00', '0', '0', '0', NULL, 'WFW_83', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(730, '0', 740, 'January', 'Tier 1', 'Commentaries', 'WPN', 'Shomal Prasad', 'Annual', 'WPN', '9018633', '9005191', 'WPN 134', '2021-01-29 00:00:00', NULL, NULL, '134', 432, 0, '2021-01-08 00:00:00', '2021-01-15 00:00:00', '2021-01-22 00:00:00', '0', '0', '0', NULL, 'WPN_134', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(731, '1', 741, 'February', 'Tier 1', 'Commentaries', 'WPN', 'Shomal Prasad', 'Annual', 'WPN', '9018634', '9005191', 'WPN 135', '2021-01-29 00:00:00', '2021-02-11 00:00:00', NULL, '135', 432, 516, '2021-01-08 00:00:00', '2021-01-15 00:00:00', '2021-01-22 00:00:00', '1', '0', '1', '2021-02-10 00:00:00', 'WPN_135', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(732, '1', 742, 'June', 'Tier 1', 'Commentaries', 'WPN', 'Shomal Prasad', 'Annual', 'WPN', '9029858', '9005191', 'WPN 136', '2021-06-14 00:00:00', NULL, NULL, '136', 432, 0, '2021-05-24 00:00:00', '2021-05-31 00:00:00', '2021-06-07 00:00:00', '0', '0', '0', NULL, 'WPN_136', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(733, '1', 743, 'September', 'Tier 1', 'Commentaries', 'WPN', 'Shomal Prasad', 'Annual', 'WPN', '9029859', '9005191', 'WPN 137', '2021-09-13 00:00:00', NULL, NULL, '137', 432, 0, '2021-08-23 00:00:00', '2021-08-30 00:00:00', '2021-09-06 00:00:00', '0', '0', '0', NULL, 'WPN_137', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(734, '0', 744, 'March', 'Tier 2', 'Commentaries', 'WPV', 'Tim Patrick', 'Annual', 'WPV', '9018636', '9005220', 'WPV 70', '2021-03-26 00:00:00', NULL, NULL, '70', 200, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'WPV_70', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(735, '1', 745, 'March', 'Tier 2', 'Commentaries', 'WPV', 'Tim Patrick', 'Annual', 'WPV', '9018637', '9005220', 'WPV 71', '2021-03-26 00:00:00', NULL, NULL, '71', 200, 130, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '1', '0', '0', '2021-03-24 00:00:00', 'WPV_71', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(736, '1', 746, 'June', 'Tier 2', 'Commentaries', 'WPV', 'Tim Patrick', 'Annual', 'WPV', '9029862', '9005220', 'WPV 72', '2021-06-25 00:00:00', NULL, NULL, '72', 200, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'WPV_72', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(737, '1', 747, 'September', 'Tier 2', 'Commentaries', 'WPV', 'Tim Patrick', 'Annual', 'WPV', '9029863', '9005220', 'WPV 73', '2021-09-24 00:00:00', NULL, NULL, '73', 200, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'WPV_73', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(738, '0', 748, 'November', 'Tier 2', 'Commentaries', 'WPWA', 'Shomal Prasad', 'Annual', 'WPW', '9018641', '9005238', 'WPWA 66', '2020-11-27 00:00:00', NULL, NULL, '66', 175, 0, '2020-11-06 00:00:00', '2020-11-13 00:00:00', '2020-11-20 00:00:00', '0', '0', '0', NULL, 'WPWA_66', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(739, '1', 749, 'April', 'Tier 2', 'Commentaries', 'WPWA', 'Shomal Prasad', 'Annual', 'WPW', '9029865', '9005238', 'WPWA 67', '2021-03-08 00:00:00', '2021-04-19 00:00:00', 'Insufficient content', '67', 175, 0, '2021-02-15 00:00:00', '2021-02-22 00:00:00', '2021-03-01 00:00:00', '1', '0', '1', '2021-04-19 00:00:00', 'WPWA_67', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(740, '1', 750, 'June', 'Tier 2', 'Commentaries', 'WPWA', 'Shomal Prasad', 'Annual', 'WPW', '9029866', '9005238', 'WPWA 68', '2021-06-07 00:00:00', NULL, NULL, '68', 175, 0, '2021-05-17 00:00:00', '2021-05-24 00:00:00', '2021-05-31 00:00:00', '0', '0', '0', NULL, 'WPWA_68', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(741, '1', 751, 'September', 'Tier 2', 'Commentaries', 'WPWA', 'Shomal Prasad', 'Annual', 'WPW', '9029867', '9005238', 'WPWA 69', '2021-09-06 00:00:00', NULL, NULL, '69', 175, 0, '2021-08-16 00:00:00', '2021-08-23 00:00:00', '2021-08-30 00:00:00', '0', '0', '0', NULL, 'WPWA_69', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(742, '1', 752, 'November', 'Tier 2', 'Commentaries', 'WPWA', 'Shomal Prasad', 'Annual', 'WPW', NULL, '9005238', 'WPWA 70', '2021-11-15 00:00:00', NULL, NULL, '70', 175, 0, '2021-10-25 00:00:00', '2021-11-01 00:00:00', '2021-11-08 00:00:00', '0', '0', '0', NULL, 'WPWA_70', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(743, '1', 753, 'May', 'Tier 3', 'Commentaries', 'WRL', 'Katharine Lam', 'Annual', 'WRL', '9029868', '9005264', 'WRL 40', '2021-05-26 00:00:00', NULL, NULL, '40', 174, 0, '2021-05-05 00:00:00', '2021-05-12 00:00:00', '2021-05-19 00:00:00', '1', '0', '0', '1900-01-00 00:00:00', 'WRL_40', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(744, '1', 754, 'October', 'Tier 3', 'Commentaries', 'WRL', 'Katharine Lam', 'Annual', 'WRL', '9029869', '9005264', 'WRL 41', '2021-10-06 00:00:00', NULL, NULL, '41', 174, 0, '2021-09-15 00:00:00', '2021-09-22 00:00:00', '2021-09-29 00:00:00', '0', '0', '0', NULL, 'WRL_41', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(745, '0', 755, 'December', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', '9018655', '9005187', 'ACLLeg Iss 12 (2020)', '2020-12-18 00:00:00', NULL, NULL, '(2020)', 80, 0, '2020-11-27 00:00:00', '2020-12-04 00:00:00', '2020-12-11 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2020)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(746, '0', 756, 'January', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', '9030421', '9005187', 'ACLLeg Iss 1 (2021)', '2021-01-27 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-01-06 00:00:00', '2021-01-13 00:00:00', '2021-01-20 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(747, '0', 757, 'February', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 2 (2021)', '2021-02-24 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-02-03 00:00:00', '2021-02-10 00:00:00', '2021-02-17 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(748, '0', 758, 'March', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 3 (2021)', '2021-03-31 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(749, '0', 759, 'March', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACL Leg Consolidated Tables Issues 1-3 (2021)', '2021-03-31 00:00:00', NULL, NULL, '(2021)', 88, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(750, '0', 760, 'April', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 4 (2021)', '2021-04-28 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-04-07 00:00:00', '2021-04-14 00:00:00', '2021-04-21 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(751, '0', 761, 'May', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 5 (2021)', '2021-05-26 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-05-05 00:00:00', '2021-05-12 00:00:00', '2021-05-19 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(752, '0', 762, 'June', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 6 (2021)', '2021-06-30 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-06-09 00:00:00', '2021-06-16 00:00:00', '2021-06-23 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(753, '0', 763, 'June', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACL Leg Consolidated Tables Issues 1-6 (2021)', '2021-06-30 00:00:00', NULL, NULL, '(2021)', 88, 0, '2021-06-09 00:00:00', '2021-06-16 00:00:00', '2021-06-23 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(754, '0', 764, 'July', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 7 (2021)', '2021-07-28 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-07-07 00:00:00', '2021-07-14 00:00:00', '2021-07-21 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(755, '0', 765, 'August', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 8 (2021)', '2021-08-25 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-08-04 00:00:00', '2021-08-11 00:00:00', '2021-08-18 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(756, '0', 766, 'September', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 9 (2021)', '2021-09-29 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-09-08 00:00:00', '2021-09-15 00:00:00', '2021-09-22 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(757, '0', 767, 'September', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACL Leg Consolidated Tables Issues 1-9 (2021)', '2021-09-29 00:00:00', NULL, NULL, '(2021)', 88, 0, '2021-09-08 00:00:00', '2021-09-15 00:00:00', '2021-09-22 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(758, '0', 768, 'October', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 10 (2021)', '2021-10-27 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-10-06 00:00:00', '2021-10-13 00:00:00', '2021-10-20 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(759, '0', 769, 'November', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 11 (2021)', '2021-11-24 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-11-03 00:00:00', '2021-11-10 00:00:00', '2021-11-17 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(760, '0', 770, 'December', NULL, 'Cases', 'ALG / ACL', 'Kristin Scollay', 'Annual', 'ALG', NULL, '9005187', 'ACLLeg Iss 12 (2021)', '2021-12-15 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-11-24 00:00:00', '2021-12-01 00:00:00', '2021-12-08 00:00:00', '0', '0', '0', NULL, 'ALG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(761, '0', 771, 'February', NULL, 'Cases', 'ALY / ACL', 'Kristin Scollay', 'Annual', 'ALY20', NULL, 'Filter', 'ACLYrbk Leg 2020', '2021-02-09 00:00:00', NULL, NULL, '2020', 560, 0, '2021-01-19 00:00:00', '2021-01-26 00:00:00', '2021-02-02 00:00:00', '0', '0', '0', NULL, 'ALY / ACL_2020', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(762, '0', 772, 'February', NULL, 'Cases', 'ALY / ACL', 'Kristin Scollay', 'Annual', 'ARY20', NULL, 'Filter', 'ACLYrbk Reg 2020', '2021-02-09 00:00:00', NULL, NULL, '2020', 1200, 0, '2021-01-19 00:00:00', '2021-01-26 00:00:00', '2021-02-02 00:00:00', '0', '0', '0', NULL, 'ALY / ACL_2020', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(763, '0', 773, 'March', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACL Consolidated Tables and Index 2017-2020', '2021-03-03 00:00:00', NULL, NULL, '2017-2020', 80, 0, '2021-02-10 00:00:00', '2021-02-17 00:00:00', '2021-02-24 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_2017-2020', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(764, '0', 774, 'December', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', '9018667', '9005187', 'ACLRep Iss 12 (2020)', '2020-12-18 00:00:00', NULL, NULL, '(2020)', 80, 0, '2020-11-27 00:00:00', '2020-12-04 00:00:00', '2020-12-11 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2020)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(765, '0', 775, 'January', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', '9030416', '9005187', 'ACLRep Iss 1 (2021)', '2021-01-27 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-01-06 00:00:00', '2021-01-13 00:00:00', '2021-01-20 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(766, '0', 776, 'February', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 2 (2021)', '2021-02-24 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-02-03 00:00:00', '2021-02-10 00:00:00', '2021-02-17 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(767, '0', 777, 'March', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 3 (2021)', '2021-03-31 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(768, '0', 778, 'March', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACL Rep Consolidated Tables Issues 1-3 (2021)', '2021-03-31 00:00:00', NULL, NULL, '(2021)', 88, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(769, '0', 779, 'April', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 4 (2021)', '2021-04-28 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-04-07 00:00:00', '2021-04-14 00:00:00', '2021-04-21 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(770, '0', 780, 'May', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 5 (2021)', '2021-05-26 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-05-05 00:00:00', '2021-05-12 00:00:00', '2021-05-19 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(771, '0', 781, 'June', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 6 (2021)', '2021-06-30 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-06-09 00:00:00', '2021-06-16 00:00:00', '2021-06-23 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(772, '0', 782, 'June', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACL Rep Consolidated Tables Issues 1-6  (2021)', '2021-06-30 00:00:00', NULL, NULL, '(2021)', 88, 0, '2021-06-09 00:00:00', '2021-06-16 00:00:00', '2021-06-23 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(773, '0', 783, 'July', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 7 (2021)', '2021-07-28 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-07-07 00:00:00', '2021-07-14 00:00:00', '2021-07-21 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(774, '0', 784, 'August', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 8 (2021)', '2021-08-25 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-08-04 00:00:00', '2021-08-11 00:00:00', '2021-08-18 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(775, '0', 785, 'September', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 9 (2021)', '2021-09-29 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-09-08 00:00:00', '2021-09-15 00:00:00', '2021-09-22 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(776, '0', 786, 'September', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACL Rep Consolidated Tables Issues 1-9  (2021)', '2021-09-29 00:00:00', NULL, NULL, '(2021)', 88, 0, '2021-09-08 00:00:00', '2021-09-15 00:00:00', '2021-09-22 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(777, '0', 787, 'October', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 10 (2021)', '2021-10-27 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-10-06 00:00:00', '2021-10-13 00:00:00', '2021-10-20 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(778, '0', 788, 'November', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 11 (2021)', '2021-11-24 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-11-03 00:00:00', '2021-11-10 00:00:00', '2021-11-17 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(779, '0', 789, 'December', NULL, 'Cases', 'ARG / ACL', 'Kristin Scollay', 'Annual', 'ARG', NULL, '9005187', 'ACLRep Iss 12 (2021)', '2021-12-15 00:00:00', NULL, NULL, '(2021)', 80, 0, '2021-11-24 00:00:00', '2021-12-01 00:00:00', '2021-12-08 00:00:00', '0', '0', '0', NULL, 'ARG / ACL_(2021)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(780, '0', 790, 'November', NULL, 'Cases', 'CIT', 'Jennifer Williams', 'CPI', 'CIT21', NULL, '9005149', 'CIT BV 2021', '2021-11-19 00:00:00', NULL, NULL, '2021', 2400, 0, '2021-10-29 00:00:00', '2021-11-05 00:00:00', '2021-11-12 00:00:00', '0', '0', '0', NULL, 'CIT_2021', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(781, '0', 791, 'March', NULL, 'Journals', 'ABR', 'Catherine Zemann', 'Part', '50ABR1', ' 0001237109', '9005153/9005154', 'ABR Vol 50 Part 1', '2021-03-05 00:00:00', NULL, NULL, '1', 150, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '0', NULL, 'ABR_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(782, '0', 792, 'April', NULL, 'Journals', 'ABR', 'Catherine Zemann', 'Part', '50ABR2', NULL, '9005153/9005154', 'ABR Vol 50 Part 2', '2021-04-30 00:00:00', NULL, NULL, '2', 150, 0, '2021-04-09 00:00:00', '2021-04-16 00:00:00', '2021-04-23 00:00:00', '0', '0', '0', NULL, 'ABR_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(783, '0', 793, 'July', NULL, 'Journals', 'ABR', 'Catherine Zemann', 'Part', '50ABR3', NULL, '9005153/9005154', 'ABR Vol 50 Part 3', '2021-07-23 00:00:00', NULL, NULL, '3', 250, 0, '2021-07-02 00:00:00', '2021-07-09 00:00:00', '2021-07-16 00:00:00', '0', '0', '0', NULL, 'ABR_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(784, '0', 794, 'March', NULL, 'Journals', 'ABR', 'Catherine Zemann', 'Binder', '50ABR1', ' 0001237109', '9005153/9005154', 'ABR Vol 50 Part 1 + Binder + Sticker', '2021-03-05 00:00:00', NULL, NULL, 'Sticker', 0, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '0', NULL, 'ABR_Sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(785, '0', 795, 'March', NULL, 'Journals', 'ABR', 'Catherine Zemann', 'Index', '50ABR1', '1237208', '9005153/9005154', 'ABR Vol 49 Index', '2021-03-05 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '0', NULL, 'ABR_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(786, '0', 796, 'May', NULL, 'Journals', 'AJCL', 'Catherine Zemann', 'Part', '36CLJ2', NULL, '9005159', 'AJCL Vol 36 Part 2', '2021-05-14 00:00:00', NULL, NULL, '2', 150, 0, '2021-04-23 00:00:00', '2021-04-30 00:00:00', '2021-05-07 00:00:00', '0', '0', '0', NULL, 'AJCL_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(787, '0', 797, 'August', NULL, 'Journals', 'AJCL', 'Catherine Zemann', 'Part', '36CLJ3', NULL, '9005159', 'AJCL Vol 36 Part 3', '2021-08-27 00:00:00', NULL, NULL, '3', 150, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'AJCL_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(788, '0', 798, 'November', NULL, 'Journals', 'AJCL', 'Catherine Zemann', 'Part', '37CLJ1', NULL, '9005159', 'AJCL Vol 37 Part 1', '2021-11-26 00:00:00', NULL, NULL, '1', 150, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'AJCL_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(789, '0', 799, 'May', NULL, 'Journals', 'AJCL', 'Catherine Zemann', 'Index', '37CLJ1', NULL, '9005159', 'AJCL Vol 36 Index', '2021-05-14 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-04-23 00:00:00', '2021-04-30 00:00:00', '2021-05-07 00:00:00', '0', '0', '0', NULL, 'AJCL_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(790, '0', 800, 'May', NULL, 'Journals', 'AJCL', 'Catherine Zemann', 'Binder', '37CLJ1', NULL, '9005159', 'AJCL Vol 37 Part 1 + Binder + Sticker', '2021-05-14 00:00:00', NULL, NULL, 'Sticker', 0, 0, '2021-04-23 00:00:00', '2021-04-30 00:00:00', '2021-05-07 00:00:00', '0', '0', '0', NULL, 'AJCL_Sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(791, '0', 801, 'May', NULL, 'Journals', 'AJFL', 'Catherine Zemann', 'Index', '34JFL1', '1135768', '9005160/9005161', 'AJFL Vol 33 Index', '2021-05-05 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-04-14 00:00:00', '2021-04-21 00:00:00', '2021-04-28 00:00:00', '0', '0', '0', NULL, 'AJFL_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(792, '0', 802, 'May', NULL, 'Journals', 'AJFL', 'Catherine Zemann', 'Binder', '34JFL1', '1135768', '9005159', 'AJFL Vol 34 Part 1 + binder + sticker', '2021-05-05 00:00:00', NULL, NULL, 'sticker', 0, 0, '2021-04-14 00:00:00', '2021-04-21 00:00:00', '2021-04-28 00:00:00', '0', '0', '0', NULL, 'AJFL_sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(793, '0', 803, 'May', NULL, 'Journals', 'AJFL', 'Catherine Zemann', 'Part', '34JFL1', '1135782', '9005160/9005161', 'AJFL Vol 34 Pt 1', '2021-05-05 00:00:00', NULL, NULL, '1', 150, 0, '2021-04-14 00:00:00', '2021-04-21 00:00:00', '2021-04-28 00:00:00', '0', '0', '0', NULL, 'AJFL_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(794, '0', 804, 'August', NULL, 'Journals', 'AJFL', 'Catherine Zemann', 'Part', '34JFL2', NULL, '9005160/9005161', 'AJFL Vol 34 Pt 2', '2021-08-18 00:00:00', NULL, NULL, '2', 150, 0, '2021-07-28 00:00:00', '2021-08-04 00:00:00', '2021-08-11 00:00:00', '0', '0', '0', NULL, 'AJFL_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(795, '0', 805, 'November', NULL, 'Journals', 'AJFL', 'Catherine Zemann', 'Part', '34JFL3', NULL, '9005160/9005161', 'AJFL Vol 34 Pt 3', '2021-11-05 00:00:00', NULL, NULL, '3', 150, 0, '2021-10-15 00:00:00', '2021-10-22 00:00:00', '2021-10-29 00:00:00', '0', '0', '0', NULL, 'AJFL_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(796, '0', 806, 'March', NULL, 'Journals', 'AJLL', 'Catherine Zemann', 'Part', '33LL3', '1232159', '9005162/9005163', 'AJLL Vol 33 Part 3', '2021-03-05 00:00:00', NULL, NULL, '3', 150, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '0', NULL, 'AJLL_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(797, '0', 807, 'June', NULL, 'Journals', 'AJLL', 'Catherine Zemann', 'Part', '34LL1', NULL, '9005162/9005163', 'AJLL Vol 34 Part 1', '2021-06-29 00:00:00', NULL, NULL, '1', 150, 0, '2021-06-08 00:00:00', '2021-06-15 00:00:00', '2021-06-22 00:00:00', '0', '0', '0', NULL, 'AJLL_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(798, '0', 808, 'June', NULL, 'Journals', 'AJLL', 'Catherine Zemann', 'Index', '34LL1', NULL, '9005162/9005163', 'AJLL Vol 33 Index', '2021-06-29 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-06-08 00:00:00', '2021-06-15 00:00:00', '2021-06-22 00:00:00', '0', '0', '0', NULL, 'AJLL_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(799, '0', 809, 'June', NULL, 'Journals', 'AJLL', 'Catherine Zemann', 'Binder', '34LL1', NULL, '9005162/9005163', 'AJLL Vol 34 Part 1 + binder + sticker', '2021-06-29 00:00:00', NULL, NULL, 'sticker', 0, 0, '2021-06-08 00:00:00', '2021-06-15 00:00:00', '2021-06-22 00:00:00', '0', '0', '0', NULL, 'AJLL_sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(800, '0', 810, 'September', NULL, 'Journals', 'AJLL', 'Catherine Zemann', 'Part', '34LL2', NULL, '9005162/9005163', 'AJLL Vol 34 Part 2', '2021-09-17 00:00:00', NULL, NULL, '2', 150, 0, '2021-08-27 00:00:00', '2021-09-03 00:00:00', '2021-09-10 00:00:00', '0', '0', '0', NULL, 'AJLL_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(801, '0', 811, 'December', NULL, 'Journals', 'AJLL', 'Catherine Zemann', 'Part', '34LL3', NULL, '9005162/9005163', 'AJLL Vol 34 Part 3', '2021-12-03 00:00:00', NULL, NULL, '3', 150, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'AJLL_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(802, '0', 812, 'April', NULL, 'Journals', 'APLJ', 'Catherine Zemann', 'Part', '29PLJ1', NULL, '9005164/9005165', 'APLJ Vol 29 Pt 1', '2021-04-09 00:00:00', NULL, NULL, '1', 150, 0, '2021-03-19 00:00:00', '2021-03-26 00:00:00', '2021-04-02 00:00:00', '0', '0', '0', NULL, 'APLJ_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(803, '0', 813, 'July', NULL, 'Journals', 'APLJ', 'Catherine Zemann', 'Part', '29PLJ2', NULL, '9005164/9005165', 'APLJ Vol 29 Pt 2', '2021-07-16 00:00:00', NULL, NULL, '2', 150, 0, '2021-06-25 00:00:00', '2021-07-02 00:00:00', '2021-07-09 00:00:00', '0', '0', '0', NULL, 'APLJ_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(804, '0', 814, 'April', NULL, 'Journals', 'APLJ', 'Catherine Zemann', 'Index', '29PLJ1', NULL, '9005164/9005165', 'APLJ Vol 28 Index', '2021-04-09 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-03-19 00:00:00', '2021-03-26 00:00:00', '2021-04-02 00:00:00', '0', '0', '0', NULL, 'APLJ_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(805, '0', 815, 'October', NULL, 'Journals', 'APLJ', 'Catherine Zemann', 'Part', '29PLJ3', NULL, '9005164/9005165', 'APLJ Vol 29 Pt 3', '2021-10-15 00:00:00', NULL, NULL, '3', 150, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'APLJ_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(806, '0', 816, 'April', NULL, 'Journals', 'APLJ', 'Catherine Zemann', 'Binder', '29PLJ1', NULL, '9005164/9005165', 'APLJ Vol 29 Part 1 + Binders + sticker', '2021-04-09 00:00:00', NULL, NULL, 'sticker', 0, 0, '2021-03-19 00:00:00', '2021-03-26 00:00:00', '2021-04-02 00:00:00', '0', '0', '0', NULL, 'APLJ_sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(807, '0', 817, 'February', NULL, 'Journals', 'CCLJ', 'Catherine Zemann', 'Part', '28CC1', '1237307', '9005166/9005167', 'CCLJ Vol 28 Pt 1', '2021-02-19 00:00:00', NULL, NULL, '1', 150, 0, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '0', '0', '0', NULL, 'CCLJ_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(808, '0', 818, 'February', NULL, 'Journals', 'CCLJ', 'Catherine Zemann', 'Index', '28CC1', '1237406', '9005166/9005167', 'CCLJ Vol 27 Index', '2021-02-19 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '0', '0', '0', NULL, 'CCLJ_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(809, '0', 819, 'February', NULL, 'Journals', 'CCLJ', 'Catherine Zemann', 'Binder', '28CC1', '1237307', '9005166/9005167', 'CCLJ Vol 28 Pt 1  + Binders + sticker', '2021-02-19 00:00:00', NULL, NULL, 'sticker', 0, 0, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '0', '0', '0', NULL, 'CCLJ_sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(810, '0', 820, 'June', NULL, 'Journals', 'CCLJ', 'Catherine Zemann', 'Part', '28CC2', NULL, '9005166/9005167', 'CCLJ Vol 28 Pt 2', '2021-06-18 00:00:00', NULL, NULL, '2', 150, 0, '2021-05-28 00:00:00', '2021-06-04 00:00:00', '2021-06-11 00:00:00', '0', '0', '0', NULL, 'CCLJ_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(811, '0', 821, 'October', NULL, 'Journals', 'CCLJ', 'Catherine Zemann', 'Part', '28CC3', NULL, '9005166/9005167', 'CCLJ Vol 28 Pt 3', '2021-10-08 00:00:00', NULL, NULL, '3', 150, 0, '2021-09-17 00:00:00', '2021-09-24 00:00:00', '2021-10-01 00:00:00', '0', '0', '0', NULL, 'CCLJ_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(812, '0', 822, 'April', NULL, 'Journals', 'ILJ', 'Catherine Zemann', 'Part', '31ILJ2', NULL, '9005168', 'ILJ Vol 31 Part 2', '2021-04-23 00:00:00', NULL, NULL, '2', 150, 0, '2021-04-02 00:00:00', '2021-04-09 00:00:00', '2021-04-16 00:00:00', '0', '0', '0', NULL, 'ILJ_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(813, '0', 823, 'August', NULL, 'Journals', 'ILJ', 'Catherine Zemann', 'Part', '31ILJ3', NULL, '9005168', 'ILJ Vol 31 Part 3', '2021-08-06 00:00:00', NULL, NULL, '3', 150, 0, '2021-07-16 00:00:00', '2021-07-23 00:00:00', '2021-07-30 00:00:00', '0', '0', '0', NULL, 'ILJ_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(814, '0', 824, 'November', NULL, 'Journals', 'ILJ', 'Catherine Zemann', 'Part', '32ILJ1', NULL, '9005168', 'ILJ Vol 32 Part 1', '2021-11-17 00:00:00', NULL, NULL, '1', 150, 0, '2021-10-27 00:00:00', '2021-11-03 00:00:00', '2021-11-10 00:00:00', '0', '0', '0', NULL, 'ILJ_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(815, '0', 825, 'November', NULL, 'Journals', 'ILJ', 'Catherine Zemann', 'Index', '32ILJ1', NULL, '9005168', 'ILJ Vol 31 Index', '2021-11-17 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-10-27 00:00:00', '2021-11-03 00:00:00', '2021-11-10 00:00:00', '0', '0', '0', NULL, 'ILJ_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(816, '0', 826, 'February', NULL, 'Journals', 'JCL', 'Catherine Zemann', 'Part', '37JCL1', '1237010', '9005155/9005156', 'JCL Vol 37 Part 1', '2021-02-04 00:00:00', NULL, NULL, '1', 150, 0, '2021-01-14 00:00:00', '2021-01-21 00:00:00', '2021-01-28 00:00:00', '0', '0', '0', NULL, 'JCL_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(817, '0', 827, 'February', NULL, 'Journals', 'JCL', 'Catherine Zemann', 'Index', '37JCL1', NULL, '9005155/9005156', 'JCL Vol 36 Index', '2021-02-04 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-01-14 00:00:00', '2021-01-21 00:00:00', '2021-01-28 00:00:00', '0', '0', '0', NULL, 'JCL_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(818, '0', 828, 'February', NULL, 'Journals', 'JCL', 'Catherine Zemann', 'Binder', '37JCL1', '1237010', '9005155/9005156', 'JCL Vol 37 Part 1 & 2 + Binder + sticker', '2021-02-04 00:00:00', NULL, NULL, 'sticker', 0, 0, '2021-01-14 00:00:00', '2021-01-21 00:00:00', '2021-01-28 00:00:00', '0', '0', '0', NULL, 'JCL_sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(819, '0', 829, 'June', NULL, 'Journals', 'JCL', 'Catherine Zemann', 'Part', '37JCL2', NULL, '9005155/9005156', 'JCL Vol 37 Part 2 (cancel)', '2021-06-30 00:00:00', NULL, NULL, '(cancel)', 150, 0, '2021-06-09 00:00:00', '2021-06-16 00:00:00', '2021-06-23 00:00:00', '0', '0', '0', NULL, 'JCL_(cancel)', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(820, '0', 830, 'July', NULL, 'Journals', 'JCL', 'Catherine Zemann', 'Part', '37JCL3', NULL, '9005155/9005156', 'JCL Vol 37 Part 3', '2021-07-30 00:00:00', NULL, NULL, '3', 150, 0, '2021-07-09 00:00:00', '2021-07-16 00:00:00', '2021-07-23 00:00:00', '0', '0', '0', NULL, 'JCL_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(821, '0', 831, 'March', NULL, 'Journals', 'JOE', 'Catherine Zemann', 'Part', '15JOE1', NULL, '9005157/9005158', 'JOE Vol 15 Pt 1', '2021-03-26 00:00:00', NULL, NULL, '1', 150, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'JOE_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(822, '0', 832, 'March', NULL, 'Journals', 'JOE', 'Catherine Zemann', 'Index', '15JOE1', NULL, '9005157/9005158', 'JOE Vol 14 Index', '2021-03-26 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'JOE_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(823, '0', 833, 'March', NULL, 'Journals', 'JOE', 'Catherine Zemann', 'Binder', '15JOE1', NULL, '9005157/9005158', 'JOE Vol 15 Part 1 + Binders + sticker', '2021-03-26 00:00:00', NULL, NULL, 'sticker', 0, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'JOE_sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(824, '0', 834, 'August', NULL, 'Journals', 'JOE', 'Catherine Zemann', 'Part', '15JOE2', NULL, '9005157/9005158', 'JOE Vol 15 Part 2', '2021-08-13 00:00:00', NULL, NULL, '2', 150, 0, '2021-07-23 00:00:00', '2021-07-30 00:00:00', '2021-08-06 00:00:00', '0', '0', '0', NULL, 'JOE_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(825, '0', 835, 'November', NULL, 'Journals', 'JOE', 'Catherine Zemann', 'Part', '15JOE3', NULL, '9005157/9005158', 'JOE Vol 15 Pt 3', '2021-11-26 00:00:00', NULL, NULL, '3', 150, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'JOE_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(826, '0', 836, 'June', NULL, 'Journals', 'MED', 'Catherine Zemann', 'Annual', 'MED', '1135814', '9005171', 'MED Vol 24 Pt 2', '2021-06-21 00:00:00', NULL, NULL, '2', 150, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '0', NULL, 'MED_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(827, '0', 837, 'September', NULL, 'Journals', 'MED', 'Catherine Zemann', 'Annual', 'MED', NULL, '9005171', 'MED Vol 24 Pt 3', '2021-09-13 00:00:00', NULL, NULL, '3', 150, 0, '2021-08-23 00:00:00', '2021-08-30 00:00:00', '2021-09-06 00:00:00', '0', '0', '0', NULL, 'MED_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(828, '0', 838, 'November', NULL, 'Journals', 'MED', 'Catherine Zemann', 'Annual', 'MED', NULL, '9005171', 'MED Vol 24 Pt 4', '2021-11-29 00:00:00', NULL, NULL, '4', 150, 0, '2021-11-08 00:00:00', '2021-11-15 00:00:00', '2021-11-22 00:00:00', '0', '0', '0', NULL, 'MED_4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(829, '0', 839, 'February', NULL, 'Journals', 'TLJ', 'Catherine Zemann', 'Part', '26TLJ3', '1369293', '9005169/9005170', 'TLJ Vol 26 Pt 3', '2021-02-19 00:00:00', NULL, NULL, '3', 150, 0, '2021-01-29 00:00:00', '2021-02-05 00:00:00', '2021-02-12 00:00:00', '0', '0', '0', NULL, 'TLJ_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(830, '0', 840, 'June', NULL, 'Journals', 'TLJ', 'Catherine Zemann', 'Part', '27TLJ1', NULL, '9005169/9005170', 'TLJ Vol 27 Pt 1', '2021-06-11 00:00:00', NULL, NULL, '1', 150, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'TLJ_1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(831, '0', 841, 'June', NULL, 'Journals', 'TLJ', 'Catherine Zemann', 'Binder', '27TLJ1', NULL, '9005169/9005170', 'TLJ Vol 27 Pt 1 + Binder + sticker', '2021-06-11 00:00:00', NULL, NULL, 'sticker', 0, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'TLJ_sticker', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(832, '0', 842, 'June', NULL, 'Journals', 'TLJ', 'Catherine Zemann', 'Index', '27TLJ1', NULL, '9005169/9005170', 'TLJ Vol 26 Index', '2021-06-11 00:00:00', NULL, NULL, 'Index', 12, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'TLJ_Index', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);
INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(833, '0', 843, 'September', NULL, 'Journals', 'TLJ', 'Catherine Zemann', 'Part', '27TLJ2', NULL, '9005169/9005170', 'TLJ Vol 27 Pt 2', '2021-09-24 00:00:00', NULL, NULL, '2', 150, 0, '2021-09-03 00:00:00', '2021-09-10 00:00:00', '2021-09-17 00:00:00', '0', '0', '0', NULL, 'TLJ_2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(834, '0', 844, 'December', NULL, 'Journals', 'TLJ', 'Catherine Zemann', 'Part', '27TLJ3', NULL, '9005169/9005170', 'TLJ Vol 27 Pt 3', '2021-12-01 00:00:00', NULL, NULL, '3', 150, 0, '2021-11-10 00:00:00', '2021-11-17 00:00:00', '2021-11-24 00:00:00', '0', '0', '0', NULL, 'TLJ_3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(835, '0', 845, 'January', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '148CR1', '1234436', '9005124/9005125', 'ACSR 148/1', '2021-01-14 00:00:00', NULL, NULL, '148/1', 116, 0, '2020-12-24 00:00:00', '2020-12-31 00:00:00', '2021-01-07 00:00:00', '0', '0', '0', NULL, 'ACSR_148/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(836, '0', 846, 'January', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '148CR2', ' 0001234931', '9005124/9005125', 'ACSR 148/2', '2021-01-28 00:00:00', NULL, NULL, '148/2', 116, 0, '2021-01-07 00:00:00', '2021-01-14 00:00:00', '2021-01-21 00:00:00', '0', '0', '0', NULL, 'ACSR_148/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(837, '0', 847, 'February', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '148CR3', ' 0001235030', '9005124/9005125', 'ACSR 148/3', '2021-02-03 00:00:00', NULL, NULL, '148/3', 116, 0, '2021-01-13 00:00:00', '2021-01-20 00:00:00', '2021-01-27 00:00:00', '0', '0', '0', NULL, 'ACSR_148/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(838, '0', 848, 'February', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '148CR4', ' 0001235129', '9005124/9005125', 'ACSR 148/4', '2021-02-08 00:00:00', NULL, NULL, '148/4', 116, 0, '2021-01-18 00:00:00', '2021-01-25 00:00:00', '2021-02-01 00:00:00', '0', '0', '0', NULL, 'ACSR_148/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(839, '0', 849, 'February', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '148CR5', ' 0001235228', '9005124/9005125', 'ACSR 148/5', '2021-02-10 00:00:00', NULL, NULL, '148/5', 116, 0, '2021-01-20 00:00:00', '2021-01-27 00:00:00', '2021-02-03 00:00:00', '0', '0', '0', NULL, 'ACSR_148/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(840, '0', 850, 'February', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '148CR6', ' 0001235327', '9005124/9005125', 'ACSR 148/6', '2021-02-17 00:00:00', NULL, NULL, '148/6', 116, 0, '2021-01-27 00:00:00', '2021-02-03 00:00:00', '2021-02-10 00:00:00', '0', '0', '0', NULL, 'ACSR_148/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(841, '0', 851, 'February', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'CPI', 'CSR148', '1236614', '9005123/9005124/9005125', 'ACSR BV 148', '2021-02-25 00:00:00', NULL, NULL, '148', 800, 0, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '0', '0', '0', NULL, 'ACSR_148', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(842, '0', 852, 'March', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '149CR1', ' 0001235426', '9005124/9005125', 'ACSR 149/1', '2021-03-04 00:00:00', NULL, NULL, '149/1', 116, 0, '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2021-02-25 00:00:00', '0', '0', '0', NULL, 'ACSR_149/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(843, '0', 853, 'March', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '149CR2', ' 0001235525', '9005124/9005125', 'ACSR 149/2', '2021-03-11 00:00:00', NULL, NULL, '149/2', 116, 0, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '0', '0', '0', NULL, 'ACSR_149/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(844, '0', 854, 'May', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '149CR3', ' 0001235624', '9005124/9005125', 'ACSR 149/3', '2021-05-19 00:00:00', NULL, NULL, '149/3', 116, 0, '2021-04-28 00:00:00', '2021-05-05 00:00:00', '2021-05-12 00:00:00', '0', '0', '0', NULL, 'ACSR_149/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(845, '0', 855, 'May', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '149CR4', '0001235723 ', '9005124/9005125', 'ACSR 149/4', '2021-05-28 00:00:00', NULL, NULL, '149/4', 116, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'ACSR_149/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(846, '0', 856, 'June', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '149CR5', ' 0001235822', '9005124/9005125', 'ACSR 149/5', '2021-06-09 00:00:00', NULL, NULL, '149/5', 116, 0, '2021-05-19 00:00:00', '2021-05-26 00:00:00', '2021-06-02 00:00:00', '0', '0', '0', NULL, 'ACSR_149/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(847, '0', 857, 'June', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '149CR6', ' 0001235921', '9005124/9005125', 'ACSR 149/6', '2021-06-16 00:00:00', NULL, NULL, '149/6', 116, 0, '2021-05-26 00:00:00', '2021-06-02 00:00:00', '2021-06-09 00:00:00', '0', '0', '0', NULL, 'ACSR_149/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(848, '0', 858, 'June', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'CPI', 'CSR149', ' 0001236713', '9005123/9005124/9005125', 'ACSR BV 149', '2021-06-25 00:00:00', NULL, NULL, '149', 800, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'ACSR_149', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(849, '0', 859, 'June', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '150CR1', '0001236020 ', '9005124/9005125', 'ACSR 150/1', '2021-06-29 00:00:00', NULL, NULL, '150/1', 116, 0, '2021-06-08 00:00:00', '2021-06-15 00:00:00', '2021-06-22 00:00:00', '0', '0', '0', NULL, 'ACSR_150/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(850, '0', 860, 'July', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '150CR2', ' 0001236119', '9005124/9005125', 'ACSR 150/2', '2021-07-05 00:00:00', NULL, NULL, '150/2', 116, 0, '2021-06-14 00:00:00', '2021-06-21 00:00:00', '2021-06-28 00:00:00', '0', '0', '0', NULL, 'ACSR_150/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(851, '0', 861, 'July', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '150CR3', '0001236218 ', '9005124/9005125', 'ACSR 150/3', '2021-07-09 00:00:00', NULL, NULL, '150/3', 116, 0, '2021-06-18 00:00:00', '2021-06-25 00:00:00', '2021-07-02 00:00:00', '0', '0', '0', NULL, 'ACSR_150/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(852, '0', 862, 'July', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '150CR4', ' 0001236317', '9005124/9005125', 'ACSR 150/4', '2021-07-14 00:00:00', NULL, NULL, '150/4', 116, 0, '2021-06-23 00:00:00', '2021-06-30 00:00:00', '2021-07-07 00:00:00', '0', '0', '0', NULL, 'ACSR_150/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(853, '0', 863, 'July', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '150CR5', ' 0001236416', '9005124/9005125', 'ACSR 150/5', '2021-07-15 00:00:00', NULL, NULL, '150/5', 116, 0, '2021-06-24 00:00:00', '2021-07-01 00:00:00', '2021-07-08 00:00:00', '0', '0', '0', NULL, 'ACSR_150/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(854, '0', 864, 'July', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '150CR6', ' 0001236515', '9005124/9005125', 'ACSR 150/6', '2021-07-23 00:00:00', NULL, NULL, '150/6', 116, 0, '2021-07-02 00:00:00', '2021-07-09 00:00:00', '2021-07-16 00:00:00', '0', '0', '0', NULL, 'ACSR_150/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(855, '0', 865, 'July', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'CPI', 'CSR150', ' 0001236812', '9005123/9005124/9005125', 'ACSR BV 150', '2021-07-28 00:00:00', NULL, NULL, '150', 800, 0, '2021-07-07 00:00:00', '2021-07-14 00:00:00', '2021-07-21 00:00:00', '0', '0', '0', NULL, 'ACSR_150', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(856, '0', 866, 'July', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '151CR1', NULL, '9005124/9005125', 'ACSR 151/1', '2021-07-28 00:00:00', NULL, NULL, '151/1', 116, 0, '2021-07-07 00:00:00', '2021-07-14 00:00:00', '2021-07-21 00:00:00', '0', '0', '0', NULL, 'ACSR_151/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(857, '0', 867, 'August', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '151CR2', NULL, '9005124/9005125', 'ACSR 151/2', '2021-08-06 00:00:00', NULL, NULL, '151/2', 116, 0, '2021-07-16 00:00:00', '2021-07-23 00:00:00', '2021-07-30 00:00:00', '0', '0', '0', NULL, 'ACSR_151/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(858, '0', 868, 'August', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '151CR3', NULL, '9005124/9005125', 'ACSR 151/3', '2021-08-12 00:00:00', NULL, NULL, '151/3', 116, 0, '2021-07-22 00:00:00', '2021-07-29 00:00:00', '2021-08-05 00:00:00', '0', '0', '0', NULL, 'ACSR_151/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(859, '0', 869, 'August', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '151CR4', NULL, '9005124/9005125', 'ACSR 151/4', '2021-08-25 00:00:00', NULL, NULL, '151/4', 116, 0, '2021-08-04 00:00:00', '2021-08-11 00:00:00', '2021-08-18 00:00:00', '0', '0', '0', NULL, 'ACSR_151/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(860, '0', 870, 'September', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '151CR5', NULL, '9005124/9005125', 'ACSR 151/5', '2021-09-06 00:00:00', NULL, NULL, '151/5', 116, 0, '2021-08-16 00:00:00', '2021-08-23 00:00:00', '2021-08-30 00:00:00', '0', '0', '0', NULL, 'ACSR_151/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(861, '0', 871, 'September', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '151CR6', NULL, '9005124/9005125', 'ACSR 151/6', '2021-09-15 00:00:00', NULL, NULL, '151/6', 116, 0, '2021-08-25 00:00:00', '2021-09-01 00:00:00', '2021-09-08 00:00:00', '0', '0', '0', NULL, 'ACSR_151/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(862, '0', 872, 'September', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'CPI', 'CSR151', NULL, '9005123/9005124/9005125', 'ACSR BV 151', '2021-09-27 00:00:00', NULL, NULL, '151', 800, 0, '2021-09-06 00:00:00', '2021-09-13 00:00:00', '2021-09-20 00:00:00', '0', '0', '0', NULL, 'ACSR_151', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(863, '0', 873, 'October', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '152CR1', NULL, '9005124/9005125', 'ACSR 152/1', '2021-10-15 00:00:00', NULL, NULL, '152/1', 116, 0, '2021-09-24 00:00:00', '2021-10-01 00:00:00', '2021-10-08 00:00:00', '0', '0', '0', NULL, 'ACSR_152/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(864, '0', 874, 'October', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '152CR2', NULL, '9005124/9005125', 'ACSR 152/2', '2021-10-25 00:00:00', NULL, NULL, '152/2', 116, 0, '2021-10-04 00:00:00', '2021-10-11 00:00:00', '2021-10-18 00:00:00', '0', '0', '0', NULL, 'ACSR_152/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(865, '0', 875, 'November', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '152CR3', NULL, '9005124/9005125', 'ACSR 152/3', '2021-11-05 00:00:00', NULL, NULL, '152/3', 116, 0, '2021-10-15 00:00:00', '2021-10-22 00:00:00', '2021-10-29 00:00:00', '0', '0', '0', NULL, 'ACSR_152/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(866, '0', 876, 'November', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '152CR4', NULL, '9005124/9005125', 'ACSR 152/4', '2021-11-16 00:00:00', NULL, NULL, '152/4', 116, 0, '2021-10-26 00:00:00', '2021-11-02 00:00:00', '2021-11-09 00:00:00', '0', '0', '0', NULL, 'ACSR_152/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(867, '0', 877, 'November', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '152CR5', NULL, '9005124/9005125', 'ACSR 152/5', '2021-11-25 00:00:00', NULL, NULL, '152/5', 116, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'ACSR_152/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(868, '0', 878, 'December', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'Part', '152CR6', NULL, '9005124/9005125', 'ACSR 152/6', '2021-12-02 00:00:00', NULL, NULL, '152/6', 116, 0, '2021-11-11 00:00:00', '2021-11-18 00:00:00', '2021-11-25 00:00:00', '0', '0', '0', NULL, 'ACSR_152/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(869, '0', 879, 'March', NULL, 'Reports', 'ACSR', 'Jasmine Villing', 'CPI', 'SRC150', NULL, '9005125', 'ACSR Consol 1-150', '2021-03-31 00:00:00', NULL, NULL, '1-150', 800, 0, '2021-03-10 00:00:00', '2021-03-17 00:00:00', '2021-03-24 00:00:00', '0', '0', '0', NULL, 'ACSR_1-150', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(870, '0', 880, 'February', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '169AL1', '0001237505 ', '9005121', 'ALD 169/1', '2021-02-23 00:00:00', NULL, NULL, '169/1', 234, 0, '2021-02-02 00:00:00', '2021-02-09 00:00:00', '2021-02-16 00:00:00', '0', '0', '0', NULL, 'ALD_169/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(871, '0', 881, 'March', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '169AL2', ' 0001237604', '9005121', 'ALD 169/2', '2021-03-05 00:00:00', NULL, NULL, '169/2', 234, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '0', NULL, 'ALD_169/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(872, '0', 882, 'March', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '169AL3', ' 0001237703', '9005121', 'ALD 169/3', '2021-03-11 00:00:00', NULL, NULL, '169/3', 234, 0, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '0', '0', '0', NULL, 'ALD_169/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(873, '0', 883, 'March', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'CPI', 'ALD169', NULL, '9005121/9005122/9005119', 'ALD BV 169', '2021-03-24 00:00:00', NULL, NULL, '169', 700, 0, '2021-03-03 00:00:00', '2021-03-10 00:00:00', '2021-03-17 00:00:00', '0', '0', '0', NULL, 'ALD_169', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(874, '0', 884, 'April', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '170AL1', NULL, '9005121', 'ALD 170/1', '2021-04-07 00:00:00', NULL, NULL, '170/1', 234, 0, '2021-03-17 00:00:00', '2021-03-24 00:00:00', '2021-03-31 00:00:00', '0', '0', '0', NULL, 'ALD_170/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(875, '0', 885, 'April', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '170AL2', NULL, '9005121', 'ALD 170/2', '2021-04-12 00:00:00', NULL, NULL, '170/2', 234, 0, '2021-03-22 00:00:00', '2021-03-29 00:00:00', '2021-04-05 00:00:00', '0', '0', '0', NULL, 'ALD_170/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(876, '0', 886, 'May', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '170AL3', NULL, '9005121', 'ALD 170/3', '2021-05-11 00:00:00', NULL, NULL, '170/3', 234, 0, '2021-04-20 00:00:00', '2021-04-27 00:00:00', '2021-05-04 00:00:00', '0', '0', '0', NULL, 'ALD_170/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(877, '0', 887, 'May', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'CPI', 'ALD170', NULL, '9005121/9005122/9005119', 'ALD BV 170', '2021-05-25 00:00:00', NULL, NULL, '170', 700, 0, '2021-05-04 00:00:00', '2021-05-11 00:00:00', '2021-05-18 00:00:00', '0', '0', '0', NULL, 'ALD_170', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(878, '0', 888, 'June', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '171AL1', NULL, '9005121', 'ALD 171/1', '2021-06-11 00:00:00', NULL, NULL, '171/1', 234, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'ALD_171/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(879, '0', 889, 'July', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '171AL2', NULL, '9005121', 'ALD 171/2', '2021-07-13 00:00:00', NULL, NULL, '171/2', 234, 0, '2021-06-22 00:00:00', '2021-06-29 00:00:00', '2021-07-06 00:00:00', '0', '0', '0', NULL, 'ALD_171/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(880, '0', 890, 'August', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '171AL3', NULL, '9005121', 'ALD 171/3', '2021-08-11 00:00:00', NULL, NULL, '171/3', 234, 0, '2021-07-21 00:00:00', '2021-07-28 00:00:00', '2021-08-04 00:00:00', '0', '0', '0', NULL, 'ALD_171/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(881, '0', 891, 'August', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'CPI', 'ALD171', NULL, '9005121/9005122/9005119', 'ALD BV 171', '2021-08-27 00:00:00', NULL, NULL, '171', 700, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'ALD_171', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(882, '0', 892, 'September', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '172AL1', NULL, '9005121', 'ALD 172/1', '2021-09-15 00:00:00', NULL, NULL, '172/1', 234, 0, '2021-08-25 00:00:00', '2021-09-01 00:00:00', '2021-09-08 00:00:00', '0', '0', '0', NULL, 'ALD_172/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(883, '0', 893, 'October', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '172AL2', NULL, '9005121', 'ALD 172/2', '2021-10-12 00:00:00', NULL, NULL, '172/2', 234, 0, '2021-09-21 00:00:00', '2021-09-28 00:00:00', '2021-10-05 00:00:00', '0', '0', '0', NULL, 'ALD_172/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(884, '0', 894, 'November', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'Part', '172AL3', NULL, '9005121', 'ALD 172/3', '2021-11-12 00:00:00', NULL, NULL, '172/3', 234, 0, '2021-10-22 00:00:00', '2021-10-29 00:00:00', '2021-11-05 00:00:00', '0', '0', '0', NULL, 'ALD_172/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(885, '0', 895, 'November', NULL, 'Reports', 'ALD', 'Jasmine Villing', 'CPI', 'ALD172', NULL, '9005121/9005122/9005119', 'ALD BV 172', '2021-11-26 00:00:00', NULL, NULL, '172', 700, 0, '2021-11-05 00:00:00', '2021-11-12 00:00:00', '2021-11-19 00:00:00', '0', '0', '0', NULL, 'ALD_172', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(886, '0', 896, 'February', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR384', '1234040', '9005128/9005126', 'ALR BV 384', '2021-02-25 00:00:00', NULL, NULL, '384', 800, 0, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '0', '0', '0', NULL, 'ALR_384', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(887, '0', 897, 'January', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '385LR1', '1234337', '9005128', 'ALR 385/1', '2021-01-14 00:00:00', NULL, NULL, '385/1', 200, 0, '2020-12-24 00:00:00', '2020-12-31 00:00:00', '2021-01-07 00:00:00', '0', '0', '0', NULL, 'ALR_385/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(888, '0', 898, 'February', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '385LR2', NULL, '9005128', 'ALR 385/2', '2021-02-01 00:00:00', NULL, NULL, '385/2', 200, 0, '2021-01-11 00:00:00', '2021-01-18 00:00:00', '2021-01-25 00:00:00', '0', '0', '0', NULL, 'ALR_385/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(889, '0', 899, 'February', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '385LR3', ' 0001237802', '9005128', 'ALR 385/3', '2021-02-12 00:00:00', NULL, NULL, '385/3', 200, 0, '2021-01-22 00:00:00', '2021-01-29 00:00:00', '2021-02-05 00:00:00', '0', '0', '0', NULL, 'ALR_385/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(890, '0', 900, 'February', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '385LR4', ' 0001237901', '9005128', 'ALR 385/4', '2021-02-16 00:00:00', NULL, NULL, '385/4', 200, 0, '2021-01-26 00:00:00', '2021-02-02 00:00:00', '2021-02-09 00:00:00', '0', '0', '0', NULL, 'ALR_385/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(891, '0', 901, 'February', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR385', ' 0001238000', '9005128/9005126', 'ALR BV 385', '2021-02-25 00:00:00', NULL, NULL, '385', 800, 0, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '0', '0', '0', NULL, 'ALR_385', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(892, '0', 902, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '386LR1', ' 0001238099', '9005128', 'ALR 386/1', '2021-03-03 00:00:00', NULL, NULL, '386/1', 200, 0, '2021-02-10 00:00:00', '2021-02-17 00:00:00', '2021-02-24 00:00:00', '0', '0', '0', NULL, 'ALR_386/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(893, '0', 903, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '386LR2', ' 0001238198', '9005128', 'ALR 386/2', '2021-03-11 00:00:00', NULL, NULL, '386/2', 200, 0, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '0', '0', '0', NULL, 'ALR_386/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(894, '0', 904, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '386LR3', NULL, '9005128', 'ALR 386/3', '2021-03-19 00:00:00', NULL, NULL, '386/3', 200, 0, '2021-02-26 00:00:00', '2021-03-05 00:00:00', '2021-03-12 00:00:00', '0', '0', '0', NULL, 'ALR_386/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(895, '0', 905, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '386LR4', NULL, '9005128', 'ALR 386/4', '2021-03-23 00:00:00', NULL, NULL, '386/4', 200, 0, '2021-03-02 00:00:00', '2021-03-09 00:00:00', '2021-03-16 00:00:00', '0', '0', '0', NULL, 'ALR_386/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(896, '0', 906, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR386', NULL, '9005128/9005126', 'ALR BV 386', '2021-03-25 00:00:00', NULL, NULL, '386', 800, 0, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '0', '0', '0', NULL, 'ALR_386', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(897, '0', 907, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '387LR1', NULL, '9005128', 'ALR 387/1', '2021-03-15 00:00:00', NULL, NULL, '387/1', 200, 0, '2021-02-22 00:00:00', '2021-03-01 00:00:00', '2021-03-08 00:00:00', '0', '0', '0', NULL, 'ALR_387/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(898, '0', 908, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '387LR2', NULL, '9005128', 'ALR 387/2', '2021-03-19 00:00:00', NULL, NULL, '387/2', 200, 0, '2021-02-26 00:00:00', '2021-03-05 00:00:00', '2021-03-12 00:00:00', '0', '0', '0', NULL, 'ALR_387/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(899, '0', 909, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '387LR3', NULL, '9005128', 'ALR 387/3', '2021-03-25 00:00:00', NULL, NULL, '387/3', 200, 0, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '0', '0', '0', NULL, 'ALR_387/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(900, '0', 910, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '387LR4', NULL, '9005128', 'ALR 387/4', '2021-03-29 00:00:00', NULL, NULL, '387/4', 200, 0, '2021-03-08 00:00:00', '2021-03-15 00:00:00', '2021-03-22 00:00:00', '0', '0', '0', NULL, 'ALR_387/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(901, '0', 911, 'March', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR387', NULL, '9005128/9005126', 'ALR BV 387', '2021-03-29 00:00:00', NULL, NULL, '387', 800, 0, '2021-03-08 00:00:00', '2021-03-15 00:00:00', '2021-03-22 00:00:00', '0', '0', '0', NULL, 'ALR_387', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(902, '0', 912, 'April', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '388LR1', NULL, '9005128', 'ALR 388/1', '2021-04-07 00:00:00', NULL, NULL, '388/1', 200, 0, '2021-03-17 00:00:00', '2021-03-24 00:00:00', '2021-03-31 00:00:00', '0', '0', '0', NULL, 'ALR_388/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(903, '0', 913, 'April', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '388LR2', NULL, '9005128', 'ALR 388/2', '2021-04-15 00:00:00', NULL, NULL, '388/2', 200, 0, '2021-03-25 00:00:00', '2021-04-01 00:00:00', '2021-04-08 00:00:00', '0', '0', '0', NULL, 'ALR_388/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(904, '0', 914, 'April', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '388LR3', NULL, '9005128', 'ALR 388/3', '2021-04-27 00:00:00', NULL, NULL, '388/3', 200, 0, '2021-04-06 00:00:00', '2021-04-13 00:00:00', '2021-04-20 00:00:00', '0', '0', '0', NULL, 'ALR_388/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(905, '0', 915, 'May', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '388LR4', NULL, '9005128', 'ALR 388/4', '2021-05-10 00:00:00', NULL, NULL, '388/4', 200, 0, '2021-04-19 00:00:00', '2021-04-26 00:00:00', '2021-05-03 00:00:00', '0', '0', '0', NULL, 'ALR_388/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(906, '0', 916, 'May', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR388', NULL, '9005128/9005126', 'ALR BV 388 + Prelim and Index (384-388)', '2021-05-28 00:00:00', NULL, NULL, '388', 800, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'ALR_388', '+ Prelim and Index (384-388)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(907, '0', 917, 'May', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '389LR1', NULL, '9005128', 'ALR 389/1', '2021-05-19 00:00:00', NULL, NULL, '389/1', 200, 0, '2021-04-28 00:00:00', '2021-05-05 00:00:00', '2021-05-12 00:00:00', '0', '0', '0', NULL, 'ALR_389/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(908, '0', 918, 'May', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '389LR2', NULL, '9005128', 'ALR 389/2', '2021-05-27 00:00:00', NULL, NULL, '389/2', 200, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'ALR_389/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(909, '0', 919, 'June', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '389LR3', NULL, '9005128', 'ALR 389/3', '2021-06-09 00:00:00', NULL, NULL, '389/3', 200, 0, '2021-05-19 00:00:00', '2021-05-26 00:00:00', '2021-06-02 00:00:00', '0', '0', '0', NULL, 'ALR_389/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(910, '0', 920, 'June', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '389LR4', NULL, '9005128', 'ALR 389/4', '2021-06-16 00:00:00', NULL, NULL, '389/4', 200, 0, '2021-05-26 00:00:00', '2021-06-02 00:00:00', '2021-06-09 00:00:00', '0', '0', '0', NULL, 'ALR_389/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(911, '0', 921, 'June', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR389', NULL, '9005128/9005126', 'ALR BV 389', '2021-06-25 00:00:00', NULL, NULL, '389', 800, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'ALR_389', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(912, '0', 922, 'June', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '390LR1', NULL, '9005128', 'ALR 390/1', '2021-06-21 00:00:00', NULL, NULL, '390/1', 200, 0, '2021-05-31 00:00:00', '2021-06-07 00:00:00', '2021-06-14 00:00:00', '0', '0', '0', NULL, 'ALR_390/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(913, '0', 923, 'June', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '390LR2', NULL, '9005128', 'ALR 390/2', '2021-06-29 00:00:00', NULL, NULL, '390/2', 200, 0, '2021-06-08 00:00:00', '2021-06-15 00:00:00', '2021-06-22 00:00:00', '0', '0', '0', NULL, 'ALR_390/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(914, '0', 924, 'July', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '390LR3', NULL, '9005128', 'ALR 390/3', '2021-07-05 00:00:00', NULL, NULL, '390/3', 200, 0, '2021-06-14 00:00:00', '2021-06-21 00:00:00', '2021-06-28 00:00:00', '0', '0', '0', NULL, 'ALR_390/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(915, '0', 925, 'July', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '390LR4', NULL, '9005128', 'ALR 390/4', '2021-07-09 00:00:00', NULL, NULL, '390/4', 200, 0, '2021-06-18 00:00:00', '2021-06-25 00:00:00', '2021-07-02 00:00:00', '0', '0', '0', NULL, 'ALR_390/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(916, '0', 926, 'July', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR390', NULL, '9005128/9005126', 'ALR BV 390', '2021-07-27 00:00:00', NULL, NULL, '390', 800, 0, '2021-07-06 00:00:00', '2021-07-13 00:00:00', '2021-07-20 00:00:00', '0', '0', '0', NULL, 'ALR_390', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(917, '0', 927, 'July', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '391LR1', NULL, '9005128', 'ALR 391/1', '2021-07-15 00:00:00', NULL, NULL, '391/1', 200, 0, '2021-06-24 00:00:00', '2021-07-01 00:00:00', '2021-07-08 00:00:00', '0', '0', '0', NULL, 'ALR_391/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(918, '0', 928, 'July', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '391LR2', NULL, '9005128', 'ALR 391/2', '2021-07-21 00:00:00', NULL, NULL, '391/2', 200, 0, '2021-06-30 00:00:00', '2021-07-07 00:00:00', '2021-07-14 00:00:00', '0', '0', '0', NULL, 'ALR_391/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(919, '0', 929, 'July', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '391LR3', NULL, '9005128', 'ALR 391/3', '2021-07-28 00:00:00', NULL, NULL, '391/3', 200, 0, '2021-07-07 00:00:00', '2021-07-14 00:00:00', '2021-07-21 00:00:00', '0', '0', '0', NULL, 'ALR_391/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(920, '0', 930, 'August', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '391LR4', NULL, '9005128', 'ALR 391/4', '2021-08-06 00:00:00', NULL, NULL, '391/4', 200, 0, '2021-07-16 00:00:00', '2021-07-23 00:00:00', '2021-07-30 00:00:00', '0', '0', '0', NULL, 'ALR_391/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(921, '0', 931, 'August', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR391', NULL, '9005128/9005126', 'ALR BV 391', '2021-08-12 00:00:00', NULL, NULL, '391', 800, 0, '2021-07-22 00:00:00', '2021-07-29 00:00:00', '2021-08-05 00:00:00', '0', '0', '0', NULL, 'ALR_391', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(922, '0', 932, 'August', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '392LR1', NULL, '9005128', 'ALR 392/1', '2021-08-18 00:00:00', NULL, NULL, '392/1', 200, 0, '2021-07-28 00:00:00', '2021-08-04 00:00:00', '2021-08-11 00:00:00', '0', '0', '0', NULL, 'ALR_392/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(923, '0', 933, 'August', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '392LR2', NULL, '9005128', 'ALR 392/2', '2021-08-25 00:00:00', NULL, NULL, '392/2', 200, 0, '2021-08-04 00:00:00', '2021-08-11 00:00:00', '2021-08-18 00:00:00', '0', '0', '0', NULL, 'ALR_392/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(924, '0', 934, 'September', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '392LR3', NULL, '9005128', 'ALR 392/3', '2021-09-03 00:00:00', NULL, NULL, '392/3', 200, 0, '2021-08-13 00:00:00', '2021-08-20 00:00:00', '2021-08-27 00:00:00', '0', '0', '0', NULL, 'ALR_392/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(925, '0', 935, 'September', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '392LR4', NULL, '9005128', 'ALR 392/4', '2021-09-13 00:00:00', NULL, NULL, '392/4', 200, 0, '2021-08-23 00:00:00', '2021-08-30 00:00:00', '2021-09-06 00:00:00', '0', '0', '0', NULL, 'ALR_392/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(926, '0', 936, 'September', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR392', NULL, '9005128/9005126', 'ALR BV 392', '2021-09-27 00:00:00', NULL, NULL, '392', 200, 0, '2021-09-06 00:00:00', '2021-09-13 00:00:00', '2021-09-20 00:00:00', '0', '0', '0', NULL, 'ALR_392', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(927, '0', 937, 'October', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '393LR1', NULL, '9005128', 'ALR 393/1', '2021-10-05 00:00:00', NULL, NULL, '393/1', 200, 0, '2021-09-14 00:00:00', '2021-09-21 00:00:00', '2021-09-28 00:00:00', '0', '0', '0', NULL, 'ALR_393/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(928, '0', 938, 'October', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '393LR2', NULL, '9005128', 'ALR 393/2', '2021-10-13 00:00:00', NULL, NULL, '393/2', 200, 0, '2021-09-22 00:00:00', '2021-09-29 00:00:00', '2021-10-06 00:00:00', '0', '0', '0', NULL, 'ALR_393/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(929, '0', 939, 'October', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '393LR3', NULL, '9005128', 'ALR 393/3', '2021-10-20 00:00:00', NULL, NULL, '393/3', 200, 0, '2021-09-29 00:00:00', '2021-10-06 00:00:00', '2021-10-13 00:00:00', '0', '0', '0', NULL, 'ALR_393/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(930, '0', 940, 'October', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '393LR4', NULL, '9005128', 'ALR 393/4', '2021-10-27 00:00:00', NULL, NULL, '393/4', 200, 0, '2021-10-06 00:00:00', '2021-10-13 00:00:00', '2021-10-20 00:00:00', '0', '0', '0', NULL, 'ALR_393/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(931, '0', 941, 'October', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR393', NULL, '9005128/9005126', 'ALR BV 393 + Prelim and Index (389-393)', '2021-10-28 00:00:00', NULL, NULL, '393', 200, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'ALR_393', '+ Prelim and Index (389-393)', '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(932, '0', 942, 'November', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '394LR1', NULL, '9005128', 'ALR 394/1', '2021-11-09 00:00:00', NULL, NULL, '394/1', 200, 0, '2021-10-19 00:00:00', '2021-10-26 00:00:00', '2021-11-02 00:00:00', '0', '0', '0', NULL, 'ALR_394/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(933, '0', 943, 'November', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '394LR2', NULL, '9005128', 'ALR 394/2', '2021-11-22 00:00:00', NULL, NULL, '394/2', 200, 0, '2021-11-01 00:00:00', '2021-11-08 00:00:00', '2021-11-15 00:00:00', '0', '0', '0', NULL, 'ALR_394/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(934, '0', 944, 'November', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '394LR3', NULL, '9005128', 'ALR 394/3', '2021-11-29 00:00:00', NULL, NULL, '394/3', 200, 0, '2021-11-08 00:00:00', '2021-11-15 00:00:00', '2021-11-22 00:00:00', '0', '0', '0', NULL, 'ALR_394/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(935, '0', 945, 'December', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'Part', '394LR4', NULL, '9005128', 'ALR 394/4', '2021-12-03 00:00:00', NULL, NULL, '394/4', 200, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'ALR_394/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(936, '0', 946, 'October', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALR394', NULL, '9005128/9005126', 'ALR BV 394', '2021-10-28 00:00:00', NULL, NULL, '394', 200, 0, '2021-10-07 00:00:00', '2021-10-14 00:00:00', '2021-10-21 00:00:00', '0', '0', '0', NULL, 'ALR_394', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(937, '0', 947, 'June', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALC385', NULL, '9005127', 'ALR Cum Supp 301-385', '2021-06-11 00:00:00', NULL, NULL, '301-385', 1000, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'ALR_301-385', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(938, '0', 948, 'December', NULL, 'Reports', 'ALR', 'Jasmine Villing', 'CPI', 'ALC390', NULL, '9005127', 'ALR Cum Supp 301-390', '2021-12-03 00:00:00', NULL, NULL, '301-390', 1000, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'ALR_301-390', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(939, '0', 949, 'May', NULL, 'Reports', 'BPR', 'Jasmine Villing', 'CPI', 'BPR271', NULL, '9005130', 'BPR 271', '2021-05-14 00:00:00', NULL, NULL, '271', 192, 0, '2021-04-23 00:00:00', '2021-04-30 00:00:00', '2021-05-07 00:00:00', '0', '0', '0', NULL, 'BPR_271', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(940, '0', 950, 'July', NULL, 'Reports', 'BPR', 'Jasmine Villing', 'CPI', 'BPR272', NULL, '9005130', 'BPR 272', '2021-07-15 00:00:00', NULL, NULL, '272', 192, 0, '2021-06-24 00:00:00', '2021-07-01 00:00:00', '2021-07-08 00:00:00', '0', '0', '0', NULL, 'BPR_272', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(941, '0', 951, 'August', NULL, 'Reports', 'BPR', 'Jasmine Villing', 'CPI', 'BPR273', NULL, '9005130', 'BPR 273', '2021-08-06 00:00:00', NULL, NULL, '273', 192, 0, '2021-07-16 00:00:00', '2021-07-23 00:00:00', '2021-07-30 00:00:00', '0', '0', '0', NULL, 'BPR_273', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(942, '0', 952, 'October', NULL, 'Reports', 'BPR', 'Jasmine Villing', 'CPI', 'BPR274', NULL, '9005130', 'BPR 274', '2021-10-12 00:00:00', NULL, NULL, '274', 192, 0, '2021-09-21 00:00:00', '2021-09-28 00:00:00', '2021-10-05 00:00:00', '0', '0', '0', NULL, 'BPR_274', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(943, '0', 953, 'December', NULL, 'Reports', 'BPR', 'Jasmine Villing', 'CPI', 'BPR275', NULL, '9005130', 'BPR 275', '2021-12-03 00:00:00', NULL, NULL, '275', 192, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'BPR_275', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(944, '0', 954, 'November', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'CPI', 'FLR61', '1231763', '9005199/9005132/9005131', 'FamLR BV 61', '2020-11-20 00:00:00', NULL, NULL, '61', 700, 0, '2020-10-30 00:00:00', '2020-11-06 00:00:00', '2020-11-13 00:00:00', '0', '0', '0', NULL, 'Fam LR_61', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(945, '0', 955, 'March', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '62FLR1', ' 0001238297', '9005199/9005132', 'FAMLR 62/1', '2021-03-04 00:00:00', NULL, NULL, '62/1', 120, 0, '2021-02-11 00:00:00', '2021-02-18 00:00:00', '2021-02-25 00:00:00', '0', '0', '0', NULL, 'Fam LR_62/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(946, '0', 956, 'March', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '62FLR2', ' 0001238396', '9005199/9005132', 'FAMLR 62/2', '2021-03-11 00:00:00', NULL, NULL, '62/2', 120, 0, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '0', '0', '0', NULL, 'Fam LR_62/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(947, '0', 957, 'April', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '62FLR3', NULL, '9005199/9005132', 'FAMLR 62/3', '2021-04-12 00:00:00', NULL, NULL, '62/3', 120, 0, '2021-03-22 00:00:00', '2021-03-29 00:00:00', '2021-04-05 00:00:00', '0', '0', '0', NULL, 'Fam LR_62/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(948, '0', 958, 'April', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '62FLR4', NULL, '9005199/9005132', 'FAMLR 62/4', '2021-04-13 00:00:00', NULL, NULL, '62/4', 120, 0, '2021-03-23 00:00:00', '2021-03-30 00:00:00', '2021-04-06 00:00:00', '0', '0', '0', NULL, 'Fam LR_62/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(949, '0', 959, 'May', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '62FLR5', NULL, '9005199/9005132', 'FAMLR 62/5', '2021-05-11 00:00:00', NULL, NULL, '62/5', 120, 0, '2021-04-20 00:00:00', '2021-04-27 00:00:00', '2021-05-04 00:00:00', '0', '0', '0', NULL, 'Fam LR_62/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(950, '0', 960, 'June', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '62FLR6', NULL, '9005199/9005132', 'FAMLR 62/6', '2021-06-11 00:00:00', NULL, NULL, '62/6', 120, 0, '2021-05-21 00:00:00', '2021-05-28 00:00:00', '2021-06-04 00:00:00', '0', '0', '0', NULL, 'Fam LR_62/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(951, '0', 961, 'June', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'CPI', 'FLR62', NULL, '9005199/9005132/9005131', 'FamLR BV 62', '2021-06-25 00:00:00', NULL, NULL, '62', 700, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'Fam LR_62', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(952, '0', 962, 'July', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '63FLR1', NULL, '9005199/9005132', 'FAMLR 63/1', '2021-07-09 00:00:00', NULL, NULL, '63/1', 120, 0, '2021-06-18 00:00:00', '2021-06-25 00:00:00', '2021-07-02 00:00:00', '0', '0', '0', NULL, 'Fam LR_63/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(953, '0', 963, 'August', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '63FLR2', NULL, '9005199/9005132', 'FAMLR 63/2', '2021-08-10 00:00:00', NULL, NULL, '63/2', 120, 0, '2021-07-20 00:00:00', '2021-07-27 00:00:00', '2021-08-03 00:00:00', '0', '0', '0', NULL, 'Fam LR_63/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(954, '0', 964, 'August', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '63FLR3', NULL, '9005199/9005132', 'FAMLR 63/3', '2021-08-27 00:00:00', NULL, NULL, '63/3', 120, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'Fam LR_63/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(955, '0', 965, 'October', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '63FLR4', NULL, '9005199/9005132', 'FAMLR 63/4', '2021-10-13 00:00:00', NULL, NULL, '63/4', 120, 0, '2021-09-22 00:00:00', '2021-09-29 00:00:00', '2021-10-06 00:00:00', '0', '0', '0', NULL, 'Fam LR_63/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(956, '0', 966, 'October', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '63FLR5', NULL, '9005199/9005132', 'FAMLR 63/5', '2021-10-29 00:00:00', NULL, NULL, '63/5', 120, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'Fam LR_63/5', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(957, '0', 967, 'November', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'Part', '63FLR6', NULL, '9005199/9005132', 'FAMLR 63/6', '2021-11-10 00:00:00', NULL, NULL, '63/6', 120, 0, '2021-10-20 00:00:00', '2021-10-27 00:00:00', '2021-11-03 00:00:00', '0', '0', '0', NULL, 'Fam LR_63/6', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(958, '0', 968, 'November', NULL, 'Reports', 'Fam LR', 'Jasmine Villing', 'CPI', 'FLR63', NULL, '9005199/9005132/9005131', 'FamLR BV 63', '2021-11-25 00:00:00', NULL, NULL, '63', 700, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'Fam LR_63', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(959, '0', 969, 'January', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR155', '1233941', '9005133/9005134', 'IPR BV 155', '2021-01-11 00:00:00', NULL, NULL, '155', 700, 0, '2020-12-21 00:00:00', '2020-12-28 00:00:00', '2021-01-04 00:00:00', '0', '0', '0', NULL, 'IPR_155', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(960, '0', 970, 'February', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', '156IP1', '1238495', '9005134', 'IPR 156/1', '2021-02-10 00:00:00', NULL, NULL, '156/1', 220, 0, '2021-01-20 00:00:00', '2021-01-27 00:00:00', '2021-02-03 00:00:00', '0', '0', '0', NULL, 'IPR_156/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(961, '0', 971, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', '156IP2', ' 0001238495', '9005134', 'IPR 156/2', '2021-03-11 00:00:00', NULL, NULL, '156/2', 220, 0, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '0', '0', '0', NULL, 'IPR_156/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(962, '0', 972, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', '156IP3', ' 0001238594', '9005134', 'IPR 156/3', '2021-03-23 00:00:00', NULL, NULL, '156/3', 220, 0, '2021-03-02 00:00:00', '2021-03-09 00:00:00', '2021-03-16 00:00:00', '0', '0', '0', NULL, 'IPR_156/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(963, '0', 973, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR156', ' 0001238693', '9005133/9005134', 'IPR BV 156', '2021-03-24 00:00:00', NULL, NULL, '156', 700, 0, '2021-03-03 00:00:00', '2021-03-10 00:00:00', '2021-03-17 00:00:00', '0', '0', '0', NULL, 'IPR_156', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(964, '0', 974, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '157IP1', NULL, '9005134', 'IPR 157/1', '2021-03-16 00:00:00', NULL, NULL, '157/1', 220, 0, '2021-02-23 00:00:00', '2021-03-02 00:00:00', '2021-03-09 00:00:00', '0', '0', '0', NULL, 'IPR_157/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(965, '0', 975, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '157IP2', NULL, '9005134', 'IPR 157/2', '2021-03-18 00:00:00', NULL, NULL, '157/2', 220, 0, '2021-02-25 00:00:00', '2021-03-04 00:00:00', '2021-03-11 00:00:00', '0', '0', '0', NULL, 'IPR_157/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(966, '0', 976, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '157IP3', NULL, '9005134', 'IPR 157/3', '2021-03-19 00:00:00', NULL, NULL, '157/3', 220, 0, '2021-02-26 00:00:00', '2021-03-05 00:00:00', '2021-03-12 00:00:00', '0', '0', '0', NULL, 'IPR_157/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(967, '0', 977, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR157', NULL, '9005133/9005134', 'IPR BV 157', '2021-03-25 00:00:00', NULL, NULL, '157', 700, 0, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '0', '0', '0', NULL, 'IPR_157', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(968, '0', 978, 'April', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '158IP1', NULL, '9005134', 'IPR 158/1', '2021-04-07 00:00:00', NULL, NULL, '158/1', 220, 0, '2021-03-17 00:00:00', '2021-03-24 00:00:00', '2021-03-31 00:00:00', '0', '0', '0', NULL, 'IPR_158/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(969, '0', 979, 'April', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '158IP2', NULL, '9005134', 'IPR 158/2', '2021-04-20 00:00:00', NULL, NULL, '158/2', 220, 0, '2021-03-30 00:00:00', '2021-04-06 00:00:00', '2021-04-13 00:00:00', '0', '0', '0', NULL, 'IPR_158/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(970, '0', 980, 'April', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '158IP3', NULL, '9005134', 'IPR 158/3', '2021-04-27 00:00:00', NULL, NULL, '158/3', 220, 0, '2021-04-06 00:00:00', '2021-04-13 00:00:00', '2021-04-20 00:00:00', '0', '0', '0', NULL, 'IPR_158/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(971, '0', 981, 'April', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR158', NULL, '9005133/9005134', 'IPR BV 158', '2021-04-29 00:00:00', NULL, NULL, '158', 700, 0, '2021-04-08 00:00:00', '2021-04-15 00:00:00', '2021-04-22 00:00:00', '0', '0', '0', NULL, 'IPR_158', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(972, '0', 982, 'May', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '159IP1', NULL, '9005134', 'IPR 159/1', '2021-05-07 00:00:00', NULL, NULL, '159/1', 220, 0, '2021-04-16 00:00:00', '2021-04-23 00:00:00', '2021-04-30 00:00:00', '0', '0', '0', NULL, 'IPR_159/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(973, '0', 983, 'May', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '159IP2', NULL, '9005134', 'IPR 159/2', '2021-05-11 00:00:00', NULL, NULL, '159/2', 220, 0, '2021-04-20 00:00:00', '2021-04-27 00:00:00', '2021-05-04 00:00:00', '0', '0', '0', NULL, 'IPR_159/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(974, '0', 984, 'May', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '159IP3', NULL, '9005134', 'IPR 159/3', '2021-05-21 00:00:00', NULL, NULL, '159/3', 220, 0, '2021-04-30 00:00:00', '2021-05-07 00:00:00', '2021-05-14 00:00:00', '0', '0', '0', NULL, 'IPR_159/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(975, '0', 985, 'May', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR159', NULL, '9005133/9005134', 'IPR BV 159', '2021-05-27 00:00:00', NULL, NULL, '159', 700, 0, '2021-05-06 00:00:00', '2021-05-13 00:00:00', '2021-05-20 00:00:00', '0', '0', '0', NULL, 'IPR_159', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);
INSERT INTO `pubsched_mt` (`PubSchedID`, `isSPI`, `OrderNumber`, `BudgetPressMonth`, `PubSchedTier`, `PubSchedTeam`, `BPSProductID`, `LegalEditor`, `ChargeType`, `ProductChargeCode`, `BPSProductIDMaster`, `BPSSublist`, `ServiceUpdate`, `BudgetPressDate`, `RevisedPressDate`, `ReasonForRevisedPressDate`, `ServiceNumber`, `ForecastPages`, `ActualPages`, `DataFromLE`, `DataFromLEG`, `DataFromCoding`, `isReceived`, `isCompleted`, `WithRevisedPressDate`, `ActualPressDate`, `ServiceAndBPSProductID`, `PubSchedRemarks`, `YearAdded`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdatedEmployeeID`) VALUES
(976, '0', 986, 'June', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '160IP1', NULL, '9005134', 'IPR 160/1', '2021-06-09 00:00:00', NULL, NULL, '160/1', 220, 0, '2021-05-19 00:00:00', '2021-05-26 00:00:00', '2021-06-02 00:00:00', '0', '0', '0', NULL, 'IPR_160/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(977, '0', 987, 'June', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '160IP2', NULL, '9005134', 'IPR 160/2', '2021-06-18 00:00:00', NULL, NULL, '160/2', 220, 0, '2021-05-28 00:00:00', '2021-06-04 00:00:00', '2021-06-11 00:00:00', '0', '0', '0', NULL, 'IPR_160/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(978, '0', 988, 'June', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '160IP3', NULL, '9005134', 'IPR 160/3', '2021-06-28 00:00:00', NULL, NULL, '160/3', 220, 0, '2021-06-07 00:00:00', '2021-06-14 00:00:00', '2021-06-21 00:00:00', '0', '0', '0', NULL, 'IPR_160/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(979, '0', 989, 'July', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR160', NULL, '9005133/9005134', 'IPR BV 160', '2021-07-29 00:00:00', NULL, NULL, '160', 700, 0, '2021-07-08 00:00:00', '2021-07-15 00:00:00', '2021-07-22 00:00:00', '0', '0', '0', NULL, 'IPR_160', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(980, '0', 990, 'July', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '161IP1', NULL, '9005134', 'IPR 161/1', '2021-07-15 00:00:00', NULL, NULL, '161/1', 220, 0, '2021-06-24 00:00:00', '2021-07-01 00:00:00', '2021-07-08 00:00:00', '0', '0', '0', NULL, 'IPR_161/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(981, '0', 991, 'August', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '161IP2', NULL, '9005134', 'IPR 161/2', '2021-08-13 00:00:00', NULL, NULL, '161/2', 220, 0, '2021-07-23 00:00:00', '2021-07-30 00:00:00', '2021-08-06 00:00:00', '0', '0', '0', NULL, 'IPR_161/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(982, '0', 992, 'August', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '161IP3', NULL, '9005134', 'IPR 161/3', '2021-08-25 00:00:00', NULL, NULL, '161/3', 220, 0, '2021-08-04 00:00:00', '2021-08-11 00:00:00', '2021-08-18 00:00:00', '0', '0', '0', NULL, 'IPR_161/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(983, '0', 993, 'August', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR161', NULL, '9005133/9005134', 'IPR BV 161', '2021-08-27 00:00:00', NULL, NULL, '161', 700, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'IPR_161', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(984, '0', 994, 'September', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '162IP1', NULL, '9005134', 'IPR 162/1', '2021-09-03 00:00:00', NULL, NULL, '162/1', 220, 0, '2021-08-13 00:00:00', '2021-08-20 00:00:00', '2021-08-27 00:00:00', '0', '0', '0', NULL, 'IPR_162/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(985, '0', 995, 'September', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '162IP2', NULL, '9005134', 'IPR 162/2', '2021-09-15 00:00:00', NULL, NULL, '162/2', 220, 0, '2021-08-25 00:00:00', '2021-09-01 00:00:00', '2021-09-08 00:00:00', '0', '0', '0', NULL, 'IPR_162/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(986, '0', 996, 'September', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '162IP3', NULL, '9005134', 'IPR 162/3', '2021-09-29 00:00:00', NULL, NULL, '162/3', 220, 0, '2021-09-08 00:00:00', '2021-09-15 00:00:00', '2021-09-22 00:00:00', '0', '0', '0', NULL, 'IPR_162/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(987, '0', 997, 'October', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'IPR162', NULL, '9005133/9005134', 'IPR BV 162', '2021-10-20 00:00:00', NULL, NULL, '162', 700, 0, '2021-09-29 00:00:00', '2021-10-06 00:00:00', '2021-10-13 00:00:00', '0', '0', '0', NULL, 'IPR_162', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(988, '0', 998, 'October', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '163IP1', NULL, '9005134', 'IPR 163/1', '2021-10-11 00:00:00', NULL, NULL, '163/1', 220, 0, '2021-09-20 00:00:00', '2021-09-27 00:00:00', '2021-10-04 00:00:00', '0', '0', '0', NULL, 'IPR_163/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(989, '0', 999, 'November', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '163IP2', NULL, '9005134', 'IPR 163/2', '2021-11-15 00:00:00', NULL, NULL, '163/2', 220, 0, '2021-10-25 00:00:00', '2021-11-01 00:00:00', '2021-11-08 00:00:00', '0', '0', '0', NULL, 'IPR_163/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(990, '0', 1000, 'December', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'Part', '163IP3', NULL, '9005134', 'IPR 163/3', '2021-12-03 00:00:00', NULL, NULL, '163/3', 220, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'IPR_163/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(991, '0', 1001, 'March', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'CIP155', NULL, '9005133/9005134', 'IPR Consol 1-155', '2021-03-25 00:00:00', NULL, NULL, '1-155', 1000, 0, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '0', '0', '0', NULL, 'IPR_1-155', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(992, '0', 1002, 'August', NULL, 'Reports', 'IPR', 'Jasmine Villing', 'CPI', 'CIP160', NULL, '9005133/9005134', 'IPR Consol 1-160', '2021-08-27 00:00:00', NULL, NULL, '1-160', 1000, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'IPR_1-160', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(993, '0', 1003, 'January', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '94MV3', '1136408', '9005135/9005137', 'MVR 94/3', '2021-01-20 00:00:00', NULL, NULL, '94/3', 134, 0, '2020-12-30 00:00:00', '2021-01-06 00:00:00', '2021-01-13 00:00:00', '0', '0', '0', NULL, 'MVR_94/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(994, '0', 1004, 'November', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '94MV4', '1136426', '9005135/9005137', 'MVR 94/4', '2021-11-19 00:00:00', NULL, NULL, '94/4', 134, 0, '2021-10-29 00:00:00', '2021-11-05 00:00:00', '2021-11-12 00:00:00', '0', '0', '0', NULL, 'MVR_94/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(995, '0', 1005, 'February', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'CPI', 'MVR94', NULL, '9005135/9005137/9005147/9005136', 'MVR BV 94', '2021-02-25 00:00:00', NULL, NULL, '94', 700, 0, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '0', '0', '0', NULL, 'MVR_94', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(996, '0', 1006, 'March', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '95MV1', ' 0001238891', '9005135/9005137', 'MVR 95/1', '2021-03-03 00:00:00', NULL, NULL, '95/1', 134, 0, '2021-02-10 00:00:00', '2021-02-17 00:00:00', '2021-02-24 00:00:00', '0', '0', '0', NULL, 'MVR_95/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(997, '0', 1007, 'March', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '95MV2', ' 0001238990', '9005135/9005137', 'MVR 95/2', '2021-03-05 00:00:00', NULL, NULL, '95/2', 134, 0, '2021-02-12 00:00:00', '2021-02-19 00:00:00', '2021-02-26 00:00:00', '0', '0', '0', NULL, 'MVR_95/2', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(998, '0', 1008, 'March', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '95MV3', NULL, '9005135/9005137', 'MVR 95/3', '2021-03-11 00:00:00', NULL, NULL, '95/3', 134, 0, '2021-02-18 00:00:00', '2021-02-25 00:00:00', '2021-03-04 00:00:00', '0', '0', '0', NULL, 'MVR_95/3', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(999, '0', 1009, 'March', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '95MV4', NULL, '9005135/9005137', 'MVR 95/4', '2021-03-25 00:00:00', NULL, NULL, '95/4', 134, 0, '2021-03-04 00:00:00', '2021-03-11 00:00:00', '2021-03-18 00:00:00', '0', '0', '0', NULL, 'MVR_95/4', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1000, '0', 1010, 'March', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'CPI', 'MVR95', NULL, '9005135/9005137/9005147/9005136', 'MVR BV 95', '2021-03-29 00:00:00', NULL, NULL, '95', 700, 0, '2021-03-08 00:00:00', '2021-03-15 00:00:00', '2021-03-22 00:00:00', '0', '0', '0', NULL, 'MVR_95', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1001, '0', 1011, 'April', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '96MV1', NULL, '9005135/9005137', 'MVR 96/1', '2021-04-06 00:00:00', NULL, NULL, '96/1', 134, 0, '2021-03-16 00:00:00', '2021-03-23 00:00:00', '2021-03-30 00:00:00', '0', '0', '0', NULL, 'MVR_96/1', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1002, '0', 1012, 'April', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '96MV2', NULL, '9005135/9005137', 'MVR 96/2', '2021-04-12 00:00:00', NULL, NULL, NULL, 134, 0, '2021-03-22 00:00:00', '2021-03-29 00:00:00', '2021-04-05 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1003, '0', 1013, 'April', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '96MV3', NULL, '9005135/9005137', 'MVR 96/3', '2021-04-30 00:00:00', NULL, NULL, NULL, 134, 0, '2021-04-09 00:00:00', '2021-04-16 00:00:00', '2021-04-23 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1004, '0', 1014, 'May', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '96MV4', NULL, '9005135/9005137', 'MVR 96/4', '2021-05-12 00:00:00', NULL, NULL, NULL, 134, 0, '2021-04-21 00:00:00', '2021-04-28 00:00:00', '2021-05-05 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1005, '0', 1015, 'May', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'CPI', 'MVR96', NULL, '9005135/9005137/9005147/9005136', 'MVR BV 96', '2021-05-25 00:00:00', NULL, NULL, NULL, 700, 0, '2021-05-04 00:00:00', '2021-05-11 00:00:00', '2021-05-18 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1006, '0', 1016, 'June', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '97MV1', NULL, '9005135/9005137', 'MVR 97/1', '2021-06-03 00:00:00', NULL, NULL, NULL, 134, 0, '2021-05-13 00:00:00', '2021-05-20 00:00:00', '2021-05-27 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1007, '0', 1017, 'June', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '97MV2', NULL, '9005135/9005137', 'MVR 97/2', '2021-06-10 00:00:00', NULL, NULL, NULL, 134, 0, '2021-05-20 00:00:00', '2021-05-27 00:00:00', '2021-06-03 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1008, '0', 1018, 'June', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '97MV3', NULL, '9005135/9005137', 'MVR 97/3', '2021-06-25 00:00:00', NULL, NULL, NULL, 134, 0, '2021-06-04 00:00:00', '2021-06-11 00:00:00', '2021-06-18 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1009, '0', 1019, 'July', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '97MV4', NULL, '9005135/9005137', 'MVR 97/4', '2021-07-07 00:00:00', NULL, NULL, NULL, 134, 0, '2021-06-16 00:00:00', '2021-06-23 00:00:00', '2021-06-30 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1010, '0', 1020, 'July', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'CPI', 'MVR97', NULL, '9005135/9005137/9005147/9005136', 'MVR BV 97', '2021-07-14 00:00:00', NULL, NULL, NULL, 700, 0, '2021-06-23 00:00:00', '2021-06-30 00:00:00', '2021-07-07 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1011, '0', 1021, 'August', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '98MV1', NULL, '9005135/9005137', 'MVR 98/1', '2021-08-05 00:00:00', NULL, NULL, NULL, 134, 0, '2021-07-15 00:00:00', '2021-07-22 00:00:00', '2021-07-29 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1012, '0', 1022, 'August', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '98MV2', NULL, '9005135/9005137', 'MVR 98/2', '2021-08-27 00:00:00', NULL, NULL, NULL, 134, 0, '2021-08-06 00:00:00', '2021-08-13 00:00:00', '2021-08-20 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1013, '0', 1023, 'September', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '98MV3', NULL, '9005135/9005137', 'MVR 98/3', '2021-09-02 00:00:00', NULL, NULL, NULL, 134, 0, '2021-08-12 00:00:00', '2021-08-19 00:00:00', '2021-08-26 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1014, '0', 1024, 'October', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '98MV4', NULL, '9005135/9005137', 'MVR 98/4', '2021-10-12 00:00:00', NULL, NULL, NULL, 134, 0, '2021-09-21 00:00:00', '2021-09-28 00:00:00', '2021-10-05 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1015, '0', 1025, 'October', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'CPI', 'MVR98', NULL, '9005135/9005137/9005147/9005136', 'MVR BV 98', '2021-10-20 00:00:00', NULL, NULL, NULL, 700, 0, '2021-09-29 00:00:00', '2021-10-06 00:00:00', '2021-10-13 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1016, '0', 1026, 'October', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '99MV1', NULL, '9005135/9005137', 'MVR 99/1', '2021-10-29 00:00:00', NULL, NULL, NULL, 134, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1017, '0', 1027, 'November', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '99MV2', NULL, '9005135/9005137', 'MVR 99/2', '2021-11-10 00:00:00', NULL, NULL, NULL, 134, 0, '2021-10-20 00:00:00', '2021-10-27 00:00:00', '2021-11-03 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1018, '0', 1028, 'November', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '99MV3', NULL, '9005135/9005137', 'MVR 99/3', '2021-11-19 00:00:00', NULL, NULL, NULL, 134, 0, '2021-10-29 00:00:00', '2021-11-05 00:00:00', '2021-11-12 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1019, '0', 1029, 'November', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'Part', '99MV4', NULL, '9005135/9005137', 'MVR 99/4', '2021-11-29 00:00:00', NULL, NULL, NULL, 134, 0, '2021-11-08 00:00:00', '2021-11-15 00:00:00', '2021-11-22 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1020, '0', 1030, 'December', NULL, 'Reports', 'MVR', 'Jasmine Villing', 'CPI', 'MVR99', NULL, '9005135/9005137/9005147/9005136', 'MVR BV 99', '2021-12-03 00:00:00', NULL, NULL, NULL, 700, 0, '2021-11-12 00:00:00', '2021-11-19 00:00:00', '2021-11-26 00:00:00', '0', '0', '0', NULL, 'MVR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1021, '0', 1031, 'February', NULL, 'Reports', 'QPELR', 'Jasmine Villing', 'CPI', 'QPLR20', '1239089', '9005321', 'QPELR BV 2020 & Prelim and Index', '2021-02-25 00:00:00', NULL, NULL, NULL, 1350, 0, '2021-02-04 00:00:00', '2021-02-11 00:00:00', '2021-02-18 00:00:00', '0', '0', '0', NULL, 'QPELR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1022, '0', 1032, 'April', NULL, 'Reports', 'QPELR', 'Jasmine Villing', 'Part', '21QPR1', NULL, '9005321/9005322', 'QPELR 2021/1', '2021-04-08 00:00:00', NULL, NULL, NULL, 350, 0, '2021-03-18 00:00:00', '2021-03-25 00:00:00', '2021-04-01 00:00:00', '0', '0', '0', NULL, 'QPELR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1023, '0', 1033, 'June', NULL, 'Reports', 'QPELR', 'Jasmine Villing', 'Part', '21QPR2', NULL, '9005321/9005322', 'QPELR 2021/2', '2021-06-30 00:00:00', NULL, NULL, NULL, 350, 0, '2021-06-09 00:00:00', '2021-06-16 00:00:00', '2021-06-23 00:00:00', '0', '0', '0', NULL, 'QPELR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1024, '0', 1034, 'October', NULL, 'Reports', 'QPELR', 'Jasmine Villing', 'Part', '21QPR3', NULL, '9005321/9005322', 'QPELR 2021/3', '2021-10-18 00:00:00', NULL, NULL, NULL, 350, 0, '2021-09-27 00:00:00', '2021-10-04 00:00:00', '2021-10-11 00:00:00', '0', '0', '0', NULL, 'QPELR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1025, '0', 1035, 'November', NULL, 'Reports', 'QPELR', 'Jasmine Villing', 'Part', '21QPR4', NULL, '9005321/9005322', 'QPELR 2021/4', '2021-11-25 00:00:00', NULL, NULL, NULL, 350, 0, '2021-11-04 00:00:00', '2021-11-11 00:00:00', '2021-11-18 00:00:00', '0', '0', '0', NULL, 'QPELR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1026, '0', 1036, 'March', NULL, 'Reports', 'FLR', 'Geraldine MacLurcan', 'Annual', '13FJR1', NULL, '9005320', 'Fiji Law Reports BV 2013', '2021-03-26 00:00:00', NULL, NULL, NULL, 500, 0, '2021-03-05 00:00:00', '2021-03-12 00:00:00', '2021-03-19 00:00:00', '0', '0', '0', NULL, 'FLR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1027, '0', 1037, 'May', NULL, 'Reports', 'FLR', 'Geraldine MacLurcan', 'Annual', '14FJR1', NULL, '9005320', 'Fiji Law Reports BV 2014', '2021-05-28 00:00:00', NULL, NULL, NULL, 500, 0, '2021-05-07 00:00:00', '2021-05-14 00:00:00', '2021-05-21 00:00:00', '0', '0', '0', NULL, 'FLR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1028, '0', 1038, 'July', NULL, 'Reports', 'FLR', 'Geraldine MacLurcan', 'Annual', '15FJR1', NULL, '9005320', 'Fiji Law Reports BV 2015', '2021-07-30 00:00:00', NULL, NULL, NULL, 500, 0, '2021-07-09 00:00:00', '2021-07-16 00:00:00', '2021-07-23 00:00:00', '0', '0', '0', NULL, 'FLR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1029, '0', 1039, 'September', NULL, 'Reports', 'FLR', 'Geraldine MacLurcan', 'Annual', '16FJR1', NULL, '9005320', 'Fiji Law Reports BV 2016', '2021-09-30 00:00:00', NULL, NULL, NULL, 500, 0, '2021-09-09 00:00:00', '2021-09-16 00:00:00', '2021-09-23 00:00:00', '0', '0', '0', NULL, 'FLR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1030, '0', 1040, 'October', NULL, 'Reports', 'FLR', 'Geraldine MacLurcan', 'Annual', '17FJR1', NULL, '9005320', 'Fiji Law Reports BV 2017', '2021-10-29 00:00:00', NULL, NULL, NULL, 500, 0, '2021-10-08 00:00:00', '2021-10-15 00:00:00', '2021-10-22 00:00:00', '0', '0', '0', NULL, 'FLR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1031, '0', 1041, 'December', NULL, 'Reports', 'FLR', 'Geraldine MacLurcan', 'Annual', '18FJR1', NULL, '9005320', 'Fiji Law Reports BV 2018', '2021-12-17 00:00:00', NULL, NULL, NULL, 500, 0, '2021-11-26 00:00:00', '2021-12-03 00:00:00', '2021-12-10 00:00:00', '0', '0', '0', NULL, 'FLR_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1032, '0', 1042, 'July', NULL, 'Reports', 'LRUK', 'Jennifer Williams', 'CPI', 'LRUK', 'N/A', NULL, 'URUK - Law Rep UK 2021 4 Vol Set', '2021-07-01 00:00:00', NULL, NULL, NULL, 1, 0, '2021-06-10 00:00:00', '2021-06-17 00:00:00', '2021-06-24 00:00:00', '0', '0', '0', NULL, 'LRUK_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1033, '0', 1043, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1559552', NULL, 'Laws of The Republic of Nauru BV 1', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1034, '0', 1044, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1559651', NULL, 'Laws of The Republic of Nauru BV 2', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1035, '0', 1045, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1559750', NULL, 'Laws of The Republic of Nauru BV 3', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1036, '0', 1046, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1559849', NULL, 'Laws of The Republic of Nauru BV 4', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1037, '0', 1047, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1559948', NULL, 'Laws of The Republic of Nauru BV 5', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1038, '0', 1048, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1560047', NULL, 'Laws of The Republic of Nauru BV 6', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1039, '0', 1049, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1560146', NULL, 'Laws of The Republic of Nauru BV 7', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1040, '0', 1050, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1560245', NULL, 'Laws of The Republic of Nauru BV 8', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1041, '0', 1051, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1560344', NULL, 'Laws of The Republic of Nauru BV 9', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1042, '0', 1052, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1557294', NULL, 'Laws of The Republic of Nauru BV 10', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1043, '0', 1053, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1557393', NULL, 'Laws of The Republic of Nauru BV 11', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1044, '0', 1054, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1557492', NULL, 'Laws of The Republic of Nauru BV 12', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1045, '0', 1055, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1557591', NULL, 'Laws of The Republic of Nauru BV 13', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1046, '0', 1056, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1557690', NULL, 'Laws of The Republic of Nauru BV 14', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1047, '0', 1057, 'January', NULL, 'Reports', 'RONNP', NULL, 'Annual', NULL, '1557789', NULL, 'Laws of The Republic of Nauru BV 15', NULL, NULL, NULL, NULL, 1280, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1),
(1048, '0', 1058, 'January', NULL, 'Commentaries', 'RONNP', NULL, 'Annual', NULL, '9024246', NULL, 'Laws of The Republic of Nauru 0', NULL, NULL, NULL, NULL, 20000, 0, NULL, NULL, NULL, '0', '0', '0', NULL, 'RONNP_', NULL, '2022', '2022-03-07 00:00:00', 1, '2022-08-01 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `querydata`
--

CREATE TABLE `querydata` (
  `QueryID` int(11) NOT NULL,
  `QueryNumber` int(8) UNSIGNED ZEROFILL DEFAULT NULL,
  `QueryJobName` varchar(50) DEFAULT NULL,
  `QueryType` varchar(100) NOT NULL,
  `QueryStatus` varchar(100) NOT NULL,
  `QueryTopicTitle` varchar(1000) DEFAULT NULL,
  `QueryMessage` varchar(1000) DEFAULT NULL,
  `AttachedFileName` varchar(1000) DEFAULT NULL,
  `AttachedContentType` varchar(1000) DEFAULT NULL,
  `AttachedFileLocation` varchar(1000) DEFAULT NULL,
  `AttachedFileExtension` varchar(1000) DEFAULT NULL,
  `AttachedFileSize` varchar(1000) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `queryreplies`
--

CREATE TABLE `queryreplies` (
  `ID` int(11) NOT NULL,
  `QueryID` int(11) NOT NULL,
  `Message` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `DatePosted` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `querystatus_mt`
--

CREATE TABLE `querystatus_mt` (
  `ID` int(11) NOT NULL,
  `Status` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `querystatus_mt`
--

INSERT INTO `querystatus_mt` (`ID`, `Status`) VALUES
(1, 'Open'),
(2, 'Cancelled'),
(3, 'Closed');

-- --------------------------------------------------------

--
-- Table structure for table `querytb`
--

CREATE TABLE `querytb` (
  `ID` int(11) NOT NULL,
  `QueryTopicID` int(11) NOT NULL,
  `QueryStatusID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `querytopic_mt`
--

CREATE TABLE `querytopic_mt` (
  `ID` int(11) NOT NULL,
  `TopicTitle` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `registration`
--

CREATE TABLE `registration` (
  `RegistrationID` int(11) NOT NULL,
  `Name` longtext NOT NULL,
  `Mobileno` longtext NOT NULL,
  `EmailID` longtext NOT NULL,
  `Username` longtext NOT NULL,
  `Password` longtext NOT NULL,
  `ConfirmPassword` longtext DEFAULT NULL,
  `Gender` longtext NOT NULL,
  `Birthdate` datetime(3) DEFAULT NULL,
  `DateofJoining` datetime(3) DEFAULT NULL,
  `RoleID` int(11) DEFAULT NULL,
  `EmployeeID` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `ForceChangePassword` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `RoleID` int(11) NOT NULL,
  `Rolename` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sendtoprintdata`
--

CREATE TABLE `sendtoprintdata` (
  `SendToPrintID` int(11) NOT NULL,
  `SendToPrintNumber` varchar(200) NOT NULL,
  `BPSProductID` varchar(100) NOT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `SendToPrintTier` varchar(50) DEFAULT NULL,
  `TargetPressDate` datetime DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `PathOfInputFiles` varchar(2000) DEFAULT NULL,
  `SpecialInstruction` varchar(2000) DEFAULT NULL,
  `LegislationMaterials` varchar(50) DEFAULT NULL,
  `LegislationID` int(11) DEFAULT NULL,
  `ConsoHighlight` varchar(45) DEFAULT NULL,
  `FilingInstruction` varchar(45) DEFAULT NULL,
  `DummyFiling1` varchar(45) DEFAULT NULL,
  `DummyFiling2` varchar(45) DEFAULT NULL,
  `UECJ` varchar(45) DEFAULT NULL,
  `PC1PC2` varchar(45) DEFAULT NULL,
  `ReadyToPrint` varchar(45) DEFAULT NULL,
  `SendingFinalPagesToPuddingburn` varchar(45) DEFAULT NULL,
  `PostingBackToStableData` varchar(45) DEFAULT NULL,
  `UpdatingOfEBinder` varchar(45) DEFAULT NULL,
  `CurrentTask` varchar(1000) DEFAULT NULL,
  `TaskStatus` varchar(1000) DEFAULT NULL,
  `SendToPrintStatus` varchar(500) DEFAULT NULL,
  `AcceptedDate` datetime DEFAULT NULL,
  `JobOwner` varchar(500) DEFAULT NULL,
  `UpdateEmailCC` varchar(1000) DEFAULT NULL,
  `ConsoHighlightOwner` varchar(500) DEFAULT NULL,
  `ConsoHighlightStartDate` datetime DEFAULT NULL,
  `ConsoHighlightDoneDate` datetime DEFAULT NULL,
  `ConsoHighlightStatus` varchar(100) DEFAULT NULL,
  `FilingInstructionOwner` varchar(500) DEFAULT NULL,
  `FilingInstructionStartDate` datetime DEFAULT NULL,
  `FilingInstructionDoneDate` datetime DEFAULT NULL,
  `FilingInstructionStatus` varchar(100) DEFAULT NULL,
  `DummyFiling1Owner` varchar(500) DEFAULT NULL,
  `DummyFiling1StartDate` datetime DEFAULT NULL,
  `DummyFiling1DoneDate` datetime DEFAULT NULL,
  `DummyFiling1Status` varchar(500) DEFAULT NULL,
  `DummyFiling2Owner` varchar(500) DEFAULT NULL,
  `DummyFiling2StartDate` datetime DEFAULT NULL,
  `DummyFiling2DoneDate` datetime DEFAULT NULL,
  `DummyFiling2Status` varchar(500) DEFAULT NULL,
  `UECJOwner` varchar(500) DEFAULT NULL,
  `UECJStartDate` datetime DEFAULT NULL,
  `UECJDoneDate` datetime DEFAULT NULL,
  `UECJStatus` varchar(500) DEFAULT NULL,
  `PC1PC2Owner` varchar(500) DEFAULT NULL,
  `PC1PC2StartDate` datetime DEFAULT NULL,
  `PC1PC2DoneDate` datetime DEFAULT NULL,
  `PC1PC2Status` varchar(500) DEFAULT NULL,
  `ReadyToPrintAttachmentBody` varchar(1000) DEFAULT NULL,
  `ReadyToPrintAttachmentName` varchar(500) DEFAULT NULL,
  `ReadyToPrintAttachmentSize` varchar(500) DEFAULT NULL,
  `ReadyToPrintStatus` varchar(100) DEFAULT NULL,
  `PuddingburnAttachmentBody` varchar(1000) DEFAULT NULL,
  `PuddingburnAttachmentName` varchar(500) DEFAULT NULL,
  `PuddingburnAttachmentSize` varchar(500) DEFAULT NULL,
  `PuddingburnStatus` varchar(100) DEFAULT NULL,
  `PostingBackToStableDataOwner` varchar(500) DEFAULT NULL,
  `PostingBackToStableDataStartDate` datetime DEFAULT NULL,
  `PostingBackToStableDataDoneDate` datetime DEFAULT NULL,
  `PostingBackToStableDataStatus` varchar(500) DEFAULT NULL,
  `UpdatingOfEBinderOwner` varchar(500) DEFAULT NULL,
  `UpdatingOfEBinderStartDate` datetime DEFAULT NULL,
  `UpdatingOfEBinderDoneDate` datetime DEFAULT NULL,
  `UpdatingOfEBinderStatus` varchar(500) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL,
  `CoversheetID` varchar(50) DEFAULT NULL,
  `RevisedOnlineDueDate` datetime DEFAULT NULL,
  `SendToPrintCheckbox` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `sendtoprintdata`
--

INSERT INTO `sendtoprintdata` (`SendToPrintID`, `SendToPrintNumber`, `BPSProductID`, `ServiceNumber`, `SendToPrintTier`, `TargetPressDate`, `ActualPressDate`, `PathOfInputFiles`, `SpecialInstruction`, `LegislationMaterials`, `LegislationID`, `ConsoHighlight`, `FilingInstruction`, `DummyFiling1`, `DummyFiling2`, `UECJ`, `PC1PC2`, `ReadyToPrint`, `SendingFinalPagesToPuddingburn`, `PostingBackToStableData`, `UpdatingOfEBinder`, `CurrentTask`, `TaskStatus`, `SendToPrintStatus`, `AcceptedDate`, `JobOwner`, `UpdateEmailCC`, `ConsoHighlightOwner`, `ConsoHighlightStartDate`, `ConsoHighlightDoneDate`, `ConsoHighlightStatus`, `FilingInstructionOwner`, `FilingInstructionStartDate`, `FilingInstructionDoneDate`, `FilingInstructionStatus`, `DummyFiling1Owner`, `DummyFiling1StartDate`, `DummyFiling1DoneDate`, `DummyFiling1Status`, `DummyFiling2Owner`, `DummyFiling2StartDate`, `DummyFiling2DoneDate`, `DummyFiling2Status`, `UECJOwner`, `UECJStartDate`, `UECJDoneDate`, `UECJStatus`, `PC1PC2Owner`, `PC1PC2StartDate`, `PC1PC2DoneDate`, `PC1PC2Status`, `ReadyToPrintAttachmentBody`, `ReadyToPrintAttachmentName`, `ReadyToPrintAttachmentSize`, `ReadyToPrintStatus`, `PuddingburnAttachmentBody`, `PuddingburnAttachmentName`, `PuddingburnAttachmentSize`, `PuddingburnStatus`, `PostingBackToStableDataOwner`, `PostingBackToStableDataStartDate`, `PostingBackToStableDataDoneDate`, `PostingBackToStableDataStatus`, `UpdatingOfEBinderOwner`, `UpdatingOfEBinderStartDate`, `UpdatingOfEBinderDoneDate`, `UpdatingOfEBinderStatus`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`, `CoversheetID`, `RevisedOnlineDueDate`, `SendToPrintCheckbox`) VALUES
(3, 'STP00003', 'DEF', '92', 'Tier 2', '2021-08-12 00:00:00', NULL, 'y', 'y', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', '2022-09-22 19:45:01', '34', 'STP2@example.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2022-09-19 15:47:14', 28, '2022-09-22 19:45:01', 32, '24', NULL, NULL),
(4, 'STP00004', 'DEF', '92', 'Tier 2', '2021-08-12 00:00:00', NULL, 'y', 'y', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', '2022-09-26 15:40:12', '34', 'STP2@example.com', '34', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2022-09-19 16:00:24', 28, '2022-09-26 15:40:12', 32, '21', NULL, NULL),
(5, 'STP00005', 'ABCA', '37', 'Tier 2', '2022-03-10 00:00:00', NULL, 'y', 'y', '0', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2022-09-19 16:09:08', 28, '2022-09-19 16:09:08', 28, '1', NULL, NULL),
(7, 'STP00007', 'IPC', '160', 'Tier 1', '2021-06-29 00:00:00', NULL, 'y', 'y', '0', NULL, '0', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2022-09-22 06:32:09', 28, '2022-09-22 06:32:09', 28, '29,27', NULL, NULL),
(8, 'STP00008', 'PL', '91', 'Tier 3', '2021-07-15 00:00:00', NULL, 'new example', 'new example', '0', NULL, '0', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2022-09-22 06:50:50', 28, '2022-09-22 06:50:50', 28, '30,26', NULL, NULL),
(9, 'STP00009', 'PL', '92', 'Tier 3', '2021-10-14 00:00:00', NULL, 'new stp', 'new stp', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2022-09-23 17:04:49', 28, '2022-09-23 17:04:49', 28, '32,31', NULL, NULL),
(14, 'STP00010', 'DEF', '91', 'Tier 2', '2021-05-13 00:00:00', NULL, 'new 2', 'new 2', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', 'Posting Back To Stable Data', 'Completed', 'Completed', '2022-10-11 16:34:47', '33', 'STP1@example.com', '34', '2022-10-03 05:33:00', '2022-10-03 05:41:00', 'Completed', '34', '2022-10-03 05:58:00', '2022-10-03 05:58:00', 'Completed', '34', '2022-10-11 15:14:00', '2022-10-11 15:21:00', 'Completed', '33', '2022-10-11 15:25:00', '2022-10-11 15:29:00', 'Completed', '34', '2022-10-11 15:35:00', '2022-10-11 15:38:00', 'Completed', '33', '2022-10-11 15:55:00', '2022-10-11 15:59:00', 'Completed', 'example ready to print', NULL, NULL, 'Completed', 'example puddingburn', NULL, NULL, 'Completed', '28', '2022-10-20 15:56:00', '2022-10-20 16:03:00', 'Completed', '34', '2022-10-20 15:40:00', '2022-10-20 15:44:00', 'Completed', '2022-09-29 01:28:58', 28, '2022-10-20 16:03:45', 28, '25', NULL, NULL),
(15, 'STP00015', 'DEF', '91', 'Tier 2', '2021-05-13 00:00:00', NULL, 'task 2', 'task 2', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', 'Posting Back To Stable Data', 'Completed', 'Completed', '2022-10-21 19:39:04', '33', 'STP1@example.com', '33', '2022-10-21 19:20:00', '2022-10-21 19:40:00', 'Completed', '33', '2022-10-21 19:40:00', '2022-10-21 19:50:00', 'Completed', '33', '2022-10-21 19:51:00', '2022-10-21 19:51:00', 'Completed', '33', '2022-10-21 19:51:00', '2022-10-21 19:51:00', 'Completed', '33', '2022-10-21 19:51:00', '2022-10-21 19:51:00', 'Completed', '33', '2022-10-21 19:51:00', '2022-10-21 19:51:00', 'Completed', 'new ready to print', NULL, NULL, 'Completed', 'new puddingburn', NULL, NULL, 'Completed', '33', '2022-10-21 19:53:00', '2022-10-21 19:56:00', 'Completed', '33', '2022-10-21 19:53:00', '2022-10-21 19:53:00', 'Completed', '2022-10-03 00:13:17', 28, '2022-10-21 19:56:00', 33, '33,19', NULL, NULL),
(16, 'STP00016', 'CIV', '51', 'Tier 3', '2021-11-27 00:00:00', NULL, 'D:\\Backup2022\\tools\\Jobtrack\\AUNZ', 'This is a reminder to register and use the Self-Service Password Portal by Straive IT.            \n           \nThe Self-Service Password Portal can be used to reset your password or unlock your account by yourself without having to reach out to Straive Service Desk. You can use this portal from the office and while away from the office using your home computer or phone.            \n           \nIt’s easy! Three simple steps!            \n1. Navigate to the portal -  https://spiadselfservice.spi-global.com/authorization.do            \n2. Log in with your Straive account            \n3. Enroll yourself by registering your responses to your selected secret questions (Your registered responses are like passwords, nobody has access to it)            \n', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', 'Posting Back To Stable Data', 'Completed', 'Completed', '2022-10-24 17:14:55', NULL, NULL, '42', '2022-10-24 14:43:00', '2022-10-24 14:43:00', 'Completed', '43', '2022-10-24 14:44:00', '2022-10-24 14:44:00', 'Completed', '44', '2022-10-24 14:44:00', '2022-10-24 14:45:00', 'Completed', '45', '2022-10-24 14:45:00', '2022-10-24 14:45:00', 'Completed', '42', '2022-10-24 14:50:00', '2022-10-24 14:50:00', 'Completed', '43', '2022-10-24 16:27:00', '2022-10-24 16:27:00', 'Completed', 'this is now completed', NULL, NULL, 'Completed', 'Completed.', NULL, NULL, 'Completed', '27', '2022-10-24 17:16:00', '2022-10-24 17:16:00', 'Completed', '44', '2022-10-24 17:15:00', '2022-10-24 17:15:00', 'Completed', '2022-10-24 14:32:04', 27, '2022-10-24 17:16:19', 27, '36,35,34', NULL, NULL),
(17, 'STP00017', 'PEV', '241', 'Tier 1', '2021-11-26 00:00:00', NULL, 'D:\\Backup2022\\tools\\Jobtrack\\AUNZ', 'please include Index', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', 'Conso Highlight', 'On-Going', 'On-Going', '2022-11-04 14:32:49', NULL, NULL, '42', '2023-01-10 16:25:00', NULL, 'On-Going', '43', NULL, NULL, NULL, '44', NULL, NULL, NULL, '45', NULL, NULL, NULL, '42', NULL, NULL, NULL, '43', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '44', NULL, NULL, NULL, '42', NULL, NULL, NULL, '2022-11-04 14:29:48', 26, '2023-01-10 16:25:55', 42, '40,37', NULL, NULL),
(18, 'STP00018', 'CIV', '49', 'Tier 3', '2021-05-28 00:00:00', NULL, 'https://jobtrack.straive.com/JobtrackAUNZ_UAT/PE/MainForm', 'https://jobtrack.straive.com/JobtrackAUNZ_UAT/PE/MainForm', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2023-03-01 15:39:02', 27, '2023-03-01 15:39:02', 27, '55', NULL, NULL),
(19, 'STP00019', 'ABCE', '68', 'Tier 3', '2021-02-26 00:00:00', NULL, 'https://jobtrack.straive.com/JobtrackAUNZ_UAT/PE/MainForm', 'special abbejrtwe', '1', NULL, '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', NULL, NULL, 'New', '2023-03-01 21:12:41', '42', 'katherine.sierra@spi-global.com', '42', NULL, NULL, NULL, '45', NULL, NULL, NULL, '43', NULL, NULL, NULL, '43', NULL, NULL, NULL, '43', NULL, NULL, NULL, '44', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '45', NULL, NULL, NULL, '45', NULL, NULL, NULL, '2023-03-01 21:02:16', 24, '2023-03-01 21:12:41', 41, '57', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `stp`
--

CREATE TABLE `stp` (
  `STPNo` varchar(200) NOT NULL,
  `OwnerUserID` int(11) NOT NULL,
  `PathOfInputFiles` varchar(100) DEFAULT NULL,
  `IsConsoHighlight` smallint(6) NOT NULL DEFAULT 1,
  `ConsoleHighlightStartDate` datetime DEFAULT NULL,
  `ConsoleHighlightEndDate` datetime DEFAULT NULL,
  `IsFilingInstruction` smallint(6) DEFAULT 1,
  `FilingInstructionStartDate` datetime DEFAULT NULL,
  `FilingInstructionEndDate` datetime DEFAULT NULL,
  `IsDummyFiling1` smallint(6) NOT NULL DEFAULT 1,
  `DummyFiling1StartDate` datetime DEFAULT NULL,
  `DummyFiling1EndDate` datetime DEFAULT NULL,
  `IsDummyFiling2` smallint(6) NOT NULL DEFAULT 1,
  `DummyFiling2StartDate` datetime DEFAULT NULL,
  `DummyFiling2EndDate` datetime DEFAULT NULL,
  `IsUECJ` smallint(6) NOT NULL DEFAULT 1,
  `UECJStartDate` datetime DEFAULT NULL,
  `UECJEndDate` datetime DEFAULT NULL,
  `IsPC1PC2` smallint(6) NOT NULL DEFAULT 1,
  `PC1PC2StartDate` datetime DEFAULT NULL,
  `PC1PC2EndDate` datetime DEFAULT NULL,
  `IsReadyToPrint` smallint(6) NOT NULL DEFAULT 1,
  `ReadyToPrintStartDate` datetime DEFAULT NULL,
  `ReadyToPrintEndDate` datetime DEFAULT NULL,
  `ReadyToPrintEmailTemplate` varchar(100) DEFAULT NULL,
  `IsSendingFinalPages` smallint(6) NOT NULL DEFAULT 1,
  `SendingFinalPagesStartDate` datetime DEFAULT NULL,
  `SendingFinalPagesEndDate` datetime DEFAULT NULL,
  `SendingFinalPagesEmailTemplate` varchar(100) DEFAULT NULL,
  `IsPostBack` smallint(6) NOT NULL DEFAULT 1,
  `PostBackStartDate` datetime DEFAULT NULL,
  `PostBackEndDate` datetime DEFAULT NULL,
  `IsUpdateEBinder` smallint(6) NOT NULL DEFAULT 1,
  `UpdateEBinderStartDate` datetime DEFAULT NULL,
  `UpdateEBinderEndDate` datetime DEFAULT NULL,
  `SpecialInstruction` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stplegislation`
--

CREATE TABLE `stplegislation` (
  `LegislationID` int(11) NOT NULL,
  `STPNo` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stpquery`
--

CREATE TABLE `stpquery` (
  `STPNo` varchar(200) NOT NULL,
  `QueryID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subsequentpassdata`
--

CREATE TABLE `subsequentpassdata` (
  `SubsequentPassID` int(11) NOT NULL,
  `CoversheetID` int(11) NOT NULL,
  `CoversheetNumber` varchar(200) DEFAULT NULL,
  `BPSProductID` varchar(10) NOT NULL,
  `ServiceNumber` varchar(100) DEFAULT NULL,
  `SubsequentPassDueDate` datetime DEFAULT NULL,
  `SubsequentPassStartDate` datetime DEFAULT NULL,
  `SubsequentPassCompletionDate` datetime DEFAULT NULL,
  `AttachmentBody` varchar(1000) DEFAULT NULL,
  `AttachmentName` varchar(1000) DEFAULT NULL,
  `AttachmentSize` varchar(500) DEFAULT NULL,
  `ActionType` varchar(500) DEFAULT NULL,
  `ActionStatus` varchar(500) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `subsequentpassdata`
--

INSERT INTO `subsequentpassdata` (`SubsequentPassID`, `CoversheetID`, `CoversheetNumber`, `BPSProductID`, `ServiceNumber`, `SubsequentPassDueDate`, `SubsequentPassStartDate`, `SubsequentPassCompletionDate`, `AttachmentBody`, `AttachmentName`, `AttachmentSize`, `ActionType`, `ActionStatus`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 1, 'ABCA_37_1', 'ABCA', '37', NULL, NULL, NULL, 'XML Editing Completed', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-07-28 19:48:58', 4, '2022-07-28 19:48:58', 4),
(2, 2, 'ABCE_71_1', 'ABCE', '71', NULL, NULL, NULL, 'completed XML Editing', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-07-28 20:23:10', 4, '2022-07-28 20:23:10', 4),
(3, 3, 'BC_61_1', 'BC', '61', NULL, NULL, NULL, 'completed xml editing', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-07-29 15:40:56', 5, '2022-07-29 15:40:56', 5),
(4, 3, 'BC_61_1', 'BC', '61', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-07-29 16:21:40', 3, '2022-07-29 16:21:40', 3),
(5, 4, 'BC_62_1', 'BC', '62', NULL, NULL, NULL, 'completed XML editing', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-07-29 16:42:11', 5, '2022-07-29 16:42:11', 5),
(6, 4, 'BC_62_1', 'BC', '62', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-07-29 16:43:18', 3, '2022-07-29 16:43:18', 3),
(7, 19, 'DEF_91_1', 'DEF', '91', NULL, NULL, NULL, NULL, NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-09-30 22:14:46', 4, '2022-09-30 22:14:46', 4),
(8, 19, 'DEF_91_1', 'DEF', '91', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-09-30 22:15:45', 28, '2022-09-30 22:15:45', 28),
(9, 34, 'CIV_51_Task1_LPA, Latup', 'CIV', '51', NULL, NULL, NULL, 'This is now completed.', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-10-24 02:42:57', 32, '2022-10-24 02:42:57', 32),
(10, 34, 'CIV_51_Task1_LPA, Latup', 'CIV', '51', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-10-24 02:44:50', 27, '2022-10-24 02:44:50', 27),
(11, 34, 'CIV_51_Task1_LPA, Latup', 'CIV', '51', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-10-24 02:44:56', 27, '2022-10-24 02:44:56', 27),
(12, 34, 'CIV_51_Task1_LPA, Latup', 'CIV', '51', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-10-24 02:44:58', 27, '2022-10-24 02:44:58', 27),
(13, 34, 'CIV_51_Task1_LPA, Latup', 'CIV', '51', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-10-24 02:45:00', 27, '2022-10-24 02:45:00', 27),
(14, 35, 'CIV_51_Task2_GENPRINC, Latup\n', 'CIV', '51', NULL, NULL, NULL, 'this is now complete', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-10-24 14:14:25', 35, '2022-10-24 14:14:25', 35),
(15, 35, 'CIV_51_Task2_GENPRINC, Latup\n', 'CIV', '51', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-10-24 14:16:12', 27, '2022-10-24 14:16:12', 27),
(16, 36, 'CIV_51_Task3_GENPRINC, Latup\n', 'CIV', '51', NULL, NULL, NULL, 'This is now complete', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-10-24 14:26:52', 36, '2022-10-24 14:26:52', 36),
(17, 36, 'CIV_51_Task3_GENPRINC, Latup\n', 'CIV', '51', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-10-24 14:27:39', 27, '2022-10-24 14:27:39', 27),
(18, 40, 'PEV_241_Task4_PL, PAC, VPP, PC, WPA, LATUP\n', 'PEV', '241', NULL, NULL, NULL, 'this is now completed', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2022-11-04 14:17:33', 32, '2022-11-04 14:17:33', 32),
(19, 40, 'PEV_241_Task4_PL, PAC, VPP, PC, WPA, LATUP\n', 'PEV', '241', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-11-04 14:18:44', 26, '2022-11-04 14:18:44', 26),
(20, 1, 'ABCA_37_1', 'ABCA', '37', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2022-12-14 07:06:11', 28, '2022-12-14 07:06:11', 28),
(21, 55, 'CIV_49_Task1_Sample Guide', 'CIV', '49', NULL, NULL, NULL, 'This is now completed.', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2023-01-10 16:12:02', 32, '2023-01-10 16:12:02', 32),
(22, 55, 'CIV_49_Task1_Sample Guide', 'CIV', '49', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2023-01-10 16:13:30', 27, '2023-01-10 16:13:30', 27),
(23, 56, 'FRAN_68_Task3_Guide card_1', 'FRAN', '68', NULL, NULL, NULL, 'This is now completed.', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2023-02-17 15:02:13', 32, '2023-02-17 15:02:13', 32),
(24, 57, 'ABCE_68_Task1_guide 1', 'ABCE', '68', NULL, NULL, NULL, 'THIS IS NOW COMPELTED', NULL, NULL, 'Completed XML Editing', 'Email sent to PE', '2023-03-01 20:57:49', 32, '2023-03-01 20:57:49', 32),
(25, 57, 'ABCE_68_Task1_guide 1', 'ABCE', '68', NULL, NULL, NULL, NULL, NULL, NULL, 'Proceed To Online', 'Email sent to assigned Coding', '2023-03-01 20:58:21', 24, '2023-03-01 20:58:21', 24);

-- --------------------------------------------------------

--
-- Table structure for table `tasklevel`
--

CREATE TABLE `tasklevel` (
  `TaskLevelID` int(11) NOT NULL,
  `JobNumber` int(11) NOT NULL,
  `Tier` varchar(20) NOT NULL,
  `BPSProductID` varchar(20) NOT NULL,
  `ServiceNumber` varchar(200) NOT NULL,
  `ManuscriptLegTitle` varchar(1000) NOT NULL,
  `TaskLevelStatus` varchar(20) NOT NULL,
  `TargetPressDate` datetime DEFAULT NULL,
  `ActualPressDate` datetime DEFAULT NULL,
  `LatupAttribution` varchar(200) DEFAULT NULL,
  `DateReceivedFromAuthor` datetime DEFAULT NULL,
  `DateCreated` datetime DEFAULT NULL,
  `UpdateType` varchar(100) DEFAULT NULL,
  `JobSpecificInstruction` varchar(100) DEFAULT NULL,
  `TaskType` varchar(100) DEFAULT NULL,
  `GuideCard` varchar(100) DEFAULT NULL,
  `TaskCheckbox` varchar(100) DEFAULT NULL,
  `TaskNumber` varchar(100) DEFAULT NULL,
  `RevisedOnlineDueDate` datetime DEFAULT NULL,
  `CopyEditDueDate` datetime DEFAULT NULL,
  `CopyEditStart` datetime DEFAULT NULL,
  `CopyEditDone` datetime DEFAULT NULL,
  `CopyEditQCDueDate` datetime DEFAULT NULL,
  `CopyEditQCStart` datetime DEFAULT NULL,
  `CopyEditQCDone` datetime DEFAULT NULL,
  `CopyEditQCDoneStatus` varchar(200) DEFAULT NULL,
  `CodingDueDate` datetime DEFAULT NULL,
  `CodingDone` datetime DEFAULT NULL,
  `CodingDoneStatus` varchar(200) DEFAULT NULL,
  `OnlineDueDate` datetime DEFAULT NULL,
  `OnlineDone` datetime DEFAULT NULL,
  `OnlineDoneStatus` varchar(200) DEFAULT NULL,
  `EstimatedPages` int(11) DEFAULT NULL,
  `ActualTAT` int(11) DEFAULT NULL,
  `OnlineTimeliness` varchar(200) DEFAULT NULL,
  `ReasonIfLate` varchar(200) DEFAULT NULL,
  `CoversheetNumber` varchar(200) DEFAULT NULL,
  `isSTP` varchar(200) DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tasklevel`
--

INSERT INTO `tasklevel` (`TaskLevelID`, `JobNumber`, `Tier`, `BPSProductID`, `ServiceNumber`, `ManuscriptLegTitle`, `TaskLevelStatus`, `TargetPressDate`, `ActualPressDate`, `LatupAttribution`, `DateReceivedFromAuthor`, `DateCreated`, `UpdateType`, `JobSpecificInstruction`, `TaskType`, `GuideCard`, `TaskCheckbox`, `TaskNumber`, `RevisedOnlineDueDate`, `CopyEditDueDate`, `CopyEditStart`, `CopyEditDone`, `CopyEditQCDueDate`, `CopyEditQCStart`, `CopyEditQCDone`, `CopyEditQCDoneStatus`, `CodingDueDate`, `CodingDone`, `CodingDoneStatus`, `OnlineDueDate`, `OnlineDone`, `OnlineDoneStatus`, `EstimatedPages`, `ActualTAT`, `OnlineTimeliness`, `ReasonIfLate`, `CoversheetNumber`, `isSTP`, `DateUpdated`) VALUES
(1, 123479, 'Tier 1', 'ABCA', '40', 'Law of Superannuation Oct 19 Index', 'New', NULL, NULL, NULL, NULL, NULL, 'Manus-Medium', 'EPMS-58454', 'Commentary', NULL, 'Check', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'TBD', NULL, NULL, 'TBD', NULL, NULL, 'TBD', NULL, NULL, NULL, NULL),
(2, 123479, 'Tier 1', 'ABCA', '40', 'Law of Superannuation June 2020 Ch 58', 'New', NULL, NULL, NULL, '2020-05-19 00:00:00', NULL, 'Manus-Medium', NULL, 'Commentary', NULL, 'Check', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'TBD', NULL, NULL, 'TBD', NULL, NULL, 'TBD', NULL, NULL, NULL, NULL),
(3, 123458, 'Tier 1', 'ABCA', '40', 'Law of Superannuation June 2020 ch10 & 60', 'Closed', NULL, NULL, NULL, '2020-05-19 00:00:00', NULL, 'Manus-Medium', NULL, 'Commentary', NULL, NULL, NULL, NULL, NULL, NULL, '2021-05-31 00:00:00', NULL, NULL, '2021-05-31 00:00:00', NULL, NULL, NULL, '2021/06/09', NULL, NULL, '2021/05/21', 45, 49, 'On-Time', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `timesheetaudittb`
--

CREATE TABLE `timesheetaudittb` (
  `ApprovalTimeSheetLogID` int(11) NOT NULL,
  `ApprovalUser` int(11) NOT NULL,
  `ProcessedDate` datetime(3) DEFAULT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `Comment` longtext DEFAULT NULL,
  `Status` int(11) NOT NULL,
  `TimeSheetID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `timesheetdetails`
--

CREATE TABLE `timesheetdetails` (
  `TimeSheetID` int(11) NOT NULL,
  `DaysofWeek` longtext DEFAULT NULL,
  `Hours` int(11) DEFAULT NULL,
  `Period` datetime(3) DEFAULT NULL,
  `ProjectID` int(11) DEFAULT NULL,
  `UserID` int(11) NOT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `TimeSheetMasterID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `timesheetmaster`
--

CREATE TABLE `timesheetmaster` (
  `TimeSheetMasterID` int(11) NOT NULL,
  `FromDate` datetime(3) DEFAULT NULL,
  `ToDate` datetime(3) DEFAULT NULL,
  `TotalHours` int(11) DEFAULT NULL,
  `UserID` int(11) NOT NULL,
  `CreatedOn` datetime(3) DEFAULT NULL,
  `TimeSheetStatus` int(11) NOT NULL,
  `Comment` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transactionlog`
--

CREATE TABLE `transactionlog` (
  `TransactionLogID` int(11) NOT NULL,
  `TransactionLogIdentity` int(11) DEFAULT NULL,
  `TransactionLogName` varchar(100) NOT NULL,
  `BPSProductID` varchar(100) NOT NULL,
  `ServiceNumber` varchar(100) NOT NULL,
  `TransactionType` varchar(100) NOT NULL,
  `ValueBefore` varchar(5000) DEFAULT NULL,
  `ValueAfter` varchar(5000) DEFAULT NULL,
  `DateCreated` datetime NOT NULL,
  `UserName` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `transactionlog`
--

INSERT INTO `transactionlog` (`TransactionLogID`, `TransactionLogIdentity`, `TransactionLogName`, `BPSProductID`, `ServiceNumber`, `TransactionType`, `ValueBefore`, `ValueAfter`, `DateCreated`, `UserName`) VALUES
(1, 7, 'Manuscript', 'DEF', '92', 'JobReassignment LE', NULL, 'Jennifer.Murray', '2022-08-08 14:30:34', 'Corish, Genevieve'),
(2, 7, 'Manuscript', 'DEF', '92', 'JobReassignment LE', 'Jennifer.Murray', 'Ragnii.Ommanney', '2022-08-12 14:53:13', 'Corish, Genevieve'),
(3, 1, 'Manuscript', 'ABCA', '37', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-08-13 14:53:13', 'Corish, Genevieve'),
(4, 13, 'Manuscript', 'PL', '90', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-08-16 15:25:45', 'Genevieve.Corish'),
(5, 13, 'Manuscript', 'PL', '90', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-16 15:25:45', 'Genevieve.Corish'),
(6, 9, 'Manuscript', 'PL', '91', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-08-16 15:55:59', 'Genevieve.Corish'),
(7, 9, 'Manuscript', 'PL', '91', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-16 15:55:59', 'Genevieve.Corish'),
(8, 9, 'Manuscript', 'PL', '91', 'JobReassignment LE', 'Genevieve.Corish', 'Kim.Hodge', '2022-08-18 17:27:58', 'Genevieve.Corish'),
(9, 9, 'Manuscript', 'PL', '91', 'JobReassignment LE', 'Kim.Hodge', 'David.Worswick', '2022-08-18 17:54:42', 'Genevieve.Corish'),
(10, 13, 'Manuscript', 'PL', '90', 'JobReassignment LE', 'Genevieve.Corish', 'Margaret.Mcdermott', '2022-08-18 18:27:56', 'Genevieve.Corish'),
(11, 9, 'Manuscript', 'PL', '91', 'JobReassignment PE', 'Chelsea.Mercado', 'MarkAnthony.Grande', '2022-08-18 18:48:26', 'PEadmin'),
(12, 6, 'Manuscript', 'DEF', '91', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-08-18 17:54:42', 'Corish, Genevieve'),
(13, 7, 'Manuscript', 'DEF', '92', 'JobReassignment LE', 'Ragnii.Ommanney', 'Genevieve.Corish', '2022-08-18 17:54:42', 'Corish, Genevieve'),
(14, 7, 'Manuscript', 'DEF', '92', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-18 17:54:42', 'Corish, Genevieve'),
(15, 1, 'Manuscript', 'ABCA', '37', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-18 17:54:42', 'Corish, Genevieve'),
(16, 6, 'Manuscript', 'DEF', '91', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-18 17:54:42', 'Corish, Genevieve'),
(17, 7, 'Manuscript', 'DEF', '92', 'JobReassignment PE', 'Chelsea.Mercado', 'Patricia.Artajo', '2022-08-18 20:08:29', 'PEadmin'),
(18, 1, 'Coversheet', 'ABCA', '37', 'JobCoversheetReassignment', NULL, 'Coding2', '2022-08-22 15:27:51', 'CodingTL'),
(19, 19, 'Coversheet', 'DEF', '91', 'JobCoversheetReassignment', NULL, 'Coding1', '2022-08-22 15:29:23', 'CodingTL'),
(20, 25, 'Coversheet', 'DEF', '91', 'JobCoversheetReassignment', NULL, 'Coding2', '2022-08-22 15:30:00', 'CodingTL'),
(21, 4, 'Coversheet', 'BC', '62', 'JobCoversheetReassignment', NULL, 'Coding2', '2022-08-22 15:30:31', 'CodingTL'),
(22, 21, 'Coversheet', 'DEF', '92', 'JobCoversheetReassignment', NULL, 'Coding1', '2022-08-22 15:31:14', 'CodingTL'),
(23, 2, 'Coversheet', 'ABCE', '71', 'JobCoversheetReassignment', NULL, 'Coding1', '2022-08-22 15:31:54', 'CodingTL'),
(24, 3, 'Coversheet', 'BC', '61', 'JobCoversheetReassignment', NULL, 'Coding2', '2022-08-22 15:32:30', 'CodingTL'),
(25, 21, 'Coversheet', 'DEF', '92', 'JobCoversheetReassignment', 'Coding1', 'Coding2', '2022-08-24 18:31:14', 'CodingTL'),
(26, 12, 'Manuscript', 'IPC', '158', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-08-30 15:38:52', 'Genevieve.Corish'),
(27, 12, 'Manuscript', 'IPC', '158', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-30 15:38:52', 'Genevieve.Corish'),
(28, 13, 'Manuscript', 'IPC', '159', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-08-30 15:42:20', 'Genevieve.Corish'),
(29, 13, 'Manuscript', 'IPC', '159', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-30 15:42:20', 'Genevieve.Corish'),
(30, 14, 'Manuscript', 'IPC', '160', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-08-30 15:43:15', 'Genevieve.Corish'),
(31, 14, 'Manuscript', 'IPC', '160', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-08-30 15:43:15', 'Genevieve.Corish'),
(33, 3, 'SendToPrint', 'DEF', '92', 'SendToPrintReassignment', NULL, 'STPe2', '2022-09-22 19:45:01', 'STPTL'),
(34, 4, 'SendToPrint', 'DEF', '92', 'SendToPrintReassignment', NULL, 'STPe2', '2022-09-23 15:04:48', 'STPTL'),
(39, 15, 'Manuscript', 'PL', '92', 'JobReassignment LE', NULL, 'Genevieve.Corish', '2022-09-23 16:34:28', 'Genevieve.Corish'),
(40, 15, 'Manuscript', 'PL', '92', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-09-23 16:34:28', 'Genevieve.Corish'),
(41, 4, 'SendToPrint', 'DEF', '92', 'SendToPrintOwnerReassignment - ConsoHighlight', NULL, 'STPe1', '2022-09-26 15:33:16', 'STPTL'),
(43, 4, 'SendToPrint', 'DEF', '92', 'SendToPrintOwnerReassignment - ConsoHighlight', 'STPe1', 'STPe2', '2022-09-26 15:40:12', 'STPTL'),
(44, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintReassignment', NULL, 'STPe1', '2022-09-30 14:47:15', 'STPTL'),
(45, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintReassignment', 'STPe1', 'STPe2', '2022-10-03 00:07:40', 'STPTL'),
(46, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - ConsoHighlight', NULL, 'STPe1', '2022-10-03 00:08:31', 'STPTL'),
(47, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - ConsoHighlight', 'STPe1', 'STPe2', '2022-10-03 00:09:23', 'STPTL'),
(51, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - FilingInstruction', NULL, 'STPe2', '2022-10-03 00:36:47', 'STPTL'),
(52, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - FilingInstruction', 'STPe2', 'STPe1', '2022-10-03 00:40:22', 'STPTL'),
(53, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - DummyFiling1', NULL, 'STPe2', '2022-10-03 01:05:13', 'STPTL'),
(54, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - DummyFiling2', NULL, 'STPe1', '2022-10-03 01:05:45', 'STPTL'),
(55, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - UECJ', NULL, 'STPe2', '2022-10-03 01:07:22', 'STPTL'),
(59, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - PC1PC2', NULL, 'STPe1', '2022-10-03 01:17:59', 'STPTL'),
(62, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - UpdatingOfEBinder', NULL, 'Chelsea.Mercado', '2022-10-03 01:24:44', 'STPTL'),
(64, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - PostingBackToStableData', NULL, 'Chelsea.Mercado', '2022-10-03 01:26:38', 'STPTL'),
(65, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - FilingInstruction', 'STPe1', 'STPe2', '2022-10-03 02:29:25', 'STPTL'),
(66, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - ConsoHighlight', 'STPe2', 'STPe1', '2022-10-03 02:29:53', 'STPTL'),
(67, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - ConsoHighlight', 'STPe1', 'STPe2', '2022-10-03 02:33:22', 'STPTL'),
(68, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintReassignment', 'STPe2', 'STPe1', '2022-10-03 02:38:02', 'STPTL'),
(69, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - UpdatingOfEBinder', 'Chelsea.Mercado', 'STPe2', '2022-10-03 04:09:23', 'STPTL'),
(70, 14, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - ConsoHighlight', 'STPe2', 'STPe2', '2022-10-11 16:34:47', 'STPTL'),
(71, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - ConsoHighlight', NULL, 'STPe1', '2022-10-21 19:15:29', 'STPTL'),
(72, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - FilingInstruction', NULL, 'STPe1', '2022-10-21 19:27:38', 'STPTL'),
(73, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - DummyFiling1', NULL, 'STPe1', '2022-10-21 19:31:29', 'STPTL'),
(74, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - DummyFiling2', NULL, 'STPe1', '2022-10-21 19:32:23', 'STPTL'),
(75, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - UECJ', NULL, 'STPe1', '2022-10-21 19:33:04', 'STPTL'),
(76, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - PC1PC2', NULL, 'STPe1', '2022-10-21 19:33:25', 'STPTL'),
(77, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - UpdatingOfEBinder', NULL, 'STPe1', '2022-10-21 19:33:47', 'STPTL'),
(78, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintOwnerReassignment - PostingBackToStableData', NULL, 'STPe1', '2022-10-21 19:38:28', 'STPTL'),
(79, 15, 'SendToPrint', 'DEF', '91', 'SendToPrintReassignment', NULL, 'STPe1', '2022-10-21 19:39:04', 'STPTL'),
(80, 16, 'Manuscript', 'CIV', '51', 'JobReassignment LE', NULL, 'Kynan.Rogers', '2022-10-24 02:14:38', 'Kynan.Rogers'),
(81, 16, 'Manuscript', 'CIV', '51', 'JobReassignment PE', NULL, 'Renalyn.Masu-ay', '2022-10-24 02:14:38', 'Kynan.Rogers'),
(82, 17, 'Manuscript', 'CIV', '50', 'JobReassignment LE', NULL, 'Kynan.Rogers', '2022-10-24 02:15:23', 'Kynan.Rogers'),
(83, 17, 'Manuscript', 'CIV', '50', 'JobReassignment PE', NULL, 'Renalyn.Masu-ay', '2022-10-24 02:15:23', 'Kynan.Rogers'),
(84, 34, 'Coversheet', 'CIV', '51', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2022-10-24 02:38:23', 'sierrakx.tl'),
(85, 35, 'Coversheet', 'CIV', '51', 'JobCoversheetReassignment', NULL, 'sierrakx.coding2', '2022-10-24 02:38:59', 'sierrakx.tl'),
(86, 36, 'Coversheet', 'CIV', '51', 'JobCoversheetReassignment', NULL, 'sierrak.coding3', '2022-10-24 02:39:40', 'sierrakx.tl'),
(87, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - ConsoHighlight', NULL, 'sierrakx.stp1', '2022-10-24 14:41:00', 'sierrakxstp.tl'),
(88, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - FilingInstruction', NULL, 'sierrakx.stp2', '2022-10-24 14:41:01', 'sierrakxstp.tl'),
(89, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - DummyFiling1', NULL, 'sierrakx.stp3', '2022-10-24 14:41:03', 'sierrakxstp.tl'),
(90, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - DummyFiling2', NULL, 'sierrakx.stp4', '2022-10-24 14:41:04', 'sierrakxstp.tl'),
(91, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - UECJ', NULL, 'sierrakx.stp1', '2022-10-24 14:41:05', 'sierrakxstp.tl'),
(92, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - PC1PC2', NULL, 'sierrakx.stp2', '2022-10-24 14:41:05', 'sierrakxstp.tl'),
(93, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - UpdatingOfEBinder', NULL, 'sierrakx.stp3', '2022-10-24 14:41:05', 'sierrakxstp.tl'),
(94, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - PostingBackToStableData', NULL, 'sierrakx.stp4', '2022-10-24 14:41:06', 'sierrakxstp.tl'),
(95, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - PostingBackToStableData', 'sierrakx.stp4', 'Renalyn.Masu-ay', '2022-10-24 14:52:03', 'sierrakxstp.tl'),
(96, 16, 'SendToPrint', 'CIV', '51', 'SendToPrintOwnerReassignment - PostingBackToStableData', 'Renalyn.Masu-ay', 'Renalyn.Masu-ay', '2022-10-24 17:14:55', 'sierrakxstp.tl'),
(97, 18, 'Manuscript', 'PEV', '241', 'JobReassignment LE', NULL, 'Reem.Ernst', '2022-10-24 19:20:36', 'Reem.Ernst'),
(98, 18, 'Manuscript', 'PEV', '241', 'JobReassignment PE', NULL, 'MarkAnthony.Grande', '2022-10-24 19:20:36', 'Reem.Ernst'),
(99, 18, 'Manuscript', 'PEV', '241', 'JobReassignment LE', 'Reem.Ernst', 'Kynan.Rogers', '2022-10-24 19:33:33', 'Reem.Ernst'),
(100, 18, 'Manuscript', 'PEV', '241', 'JobReassignment LE', 'Kynan.Rogers', 'Reem.Ernst', '2022-10-24 19:33:58', 'Reem.Ernst'),
(101, 37, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2022-10-24 20:51:45', 'sierrakx.tl'),
(102, 38, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrakx.coding2', '2022-10-24 20:52:02', 'sierrakx.tl'),
(103, 39, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrak.coding3', '2022-10-24 20:52:20', 'sierrakx.tl'),
(104, 40, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2022-10-24 20:52:34', 'sierrakx.tl'),
(105, 41, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2022-10-24 20:53:30', 'sierrakx.tl'),
(106, 42, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrakx.coding2', '2022-10-24 20:53:52', 'sierrakx.tl'),
(107, 43, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrak.coding3', '2022-10-24 20:54:07', 'sierrakx.tl'),
(108, 44, 'Coversheet', 'PEV', '241', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2022-10-24 20:54:19', 'sierrakx.tl'),
(109, 27, 'Coversheet', 'IPC', '160', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2022-11-04 14:06:09', 'sierrakx.tl'),
(110, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - ConsoHighlight', NULL, 'sierrakx.stp1', '2022-11-04 14:32:45', 'sierrakxstp.tl'),
(111, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - FilingInstruction', NULL, 'sierrakx.stp2', '2022-11-04 14:32:45', 'sierrakxstp.tl'),
(112, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - DummyFiling1', NULL, 'sierrakx.stp3', '2022-11-04 14:32:46', 'sierrakxstp.tl'),
(113, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - DummyFiling2', NULL, 'sierrakx.stp4', '2022-11-04 14:32:46', 'sierrakxstp.tl'),
(114, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - UECJ', NULL, 'sierrakx.stp1', '2022-11-04 14:32:47', 'sierrakxstp.tl'),
(115, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - PC1PC2', NULL, 'sierrakx.stp2', '2022-11-04 14:32:47', 'sierrakxstp.tl'),
(116, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - UpdatingOfEBinder', NULL, 'sierrakx.stp1', '2022-11-04 14:32:48', 'sierrakxstp.tl'),
(117, 17, 'SendToPrint', 'PEV', '241', 'SendToPrintOwnerReassignment - PostingBackToStableData', NULL, 'sierrakx.stp3', '2022-11-04 14:32:49', 'sierrakxstp.tl'),
(118, 19, 'Manuscript', 'CLSA', '192', 'JobReassignment LE', NULL, 'David.Worswick', '2022-11-18 15:37:31', 'David.Worswick'),
(119, 19, 'Manuscript', 'CLSA', '192', 'JobReassignment PE', NULL, 'Margot.Antivola', '2022-11-18 15:37:31', 'David.Worswick'),
(120, 20, 'Manuscript', 'AER', '36.7', 'JobReassignment LE', NULL, 'David.Worswick', '2022-11-21 13:52:32', 'David.Worswick'),
(121, 20, 'Manuscript', 'AER', '36.7', 'JobReassignment PE', NULL, 'Margot.Antivola', '2022-11-21 13:52:32', 'David.Worswick'),
(122, 21, 'Manuscript', 'FRAN', '68', 'JobReassignment LE', NULL, 'Kynan.Rogers', '2022-11-21 16:22:30', 'Kynan.Rogers'),
(123, 21, 'Manuscript', 'FRAN', '68', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-11-21 16:22:30', 'Kynan.Rogers'),
(124, 45, 'Coversheet', 'FRAN', '68', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2022-11-22 00:16:25', 'sierrakx.tl'),
(125, 46, 'Coversheet', 'FRAN', '68', 'JobCoversheetReassignment', NULL, 'sierrakx.coding2', '2022-11-22 00:16:52', 'sierrakx.tl'),
(126, 22, 'Manuscript', 'BC', '60', 'JobReassignment LE', NULL, 'Rose.Thomsen', '2022-12-09 17:59:59', 'Rose.Thomsen'),
(127, 22, 'Manuscript', 'BC', '60', 'JobReassignment PE', NULL, 'EleanorAnne.Reyes', '2022-12-09 17:59:59', 'Rose.Thomsen'),
(128, 48, 'Coversheet', 'BC', '60', 'JobCoversheetReassignment', NULL, 'Coding1', '2022-12-09 19:30:56', 'CodingTL'),
(129, 49, 'Coversheet', 'BC', '60', 'JobCoversheetReassignment', NULL, 'Coding2', '2022-12-09 19:32:14', 'CodingTL'),
(130, 50, 'Coversheet', 'BC', '60', 'JobCoversheetReassignment', NULL, 'Coding1', '2022-12-09 19:32:40', 'CodingTL'),
(131, 23, 'Manuscript', 'HLB', '29.9', 'JobReassignment LE', NULL, 'David.Worswick', '2022-12-12 14:00:49', 'David.Worswick'),
(132, 23, 'Manuscript', 'HLB', '29.9', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-12-12 14:00:49', 'David.Worswick'),
(133, 24, 'Manuscript', 'MTN', '183', 'JobReassignment LE', NULL, 'Ragnii.Ommanney', '2022-12-12 14:04:47', 'Ragnii.Ommanney'),
(134, 24, 'Manuscript', 'MTN', '183', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-12-12 14:04:47', 'Ragnii.Ommanney'),
(135, 25, 'Manuscript', 'PIC', '28', 'JobReassignment LE', NULL, 'Monica.Nakhla', '2022-12-12 15:12:09', 'Monica.Nakhla'),
(136, 25, 'Manuscript', 'PIC', '28', 'JobReassignment PE', NULL, 'MarkAnthony.Grande', '2022-12-12 15:12:09', 'Monica.Nakhla'),
(137, 26, 'Manuscript', 'CFN', '162', 'JobReassignment LE', NULL, 'Monica.Nakhla', '2022-12-12 15:22:16', 'Monica.Nakhla'),
(138, 26, 'Manuscript', 'CFN', '162', 'JobReassignment PE', NULL, 'MarkAnthony.Grande', '2022-12-12 15:22:16', 'Monica.Nakhla'),
(139, 27, 'Manuscript', 'CPACT', '132', 'JobReassignment LE', NULL, 'Ragnii.Ommanney', '2022-12-13 13:50:24', 'Ragnii.Ommanney'),
(140, 27, 'Manuscript', 'CPACT', '132', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2022-12-13 13:50:24', 'Ragnii.Ommanney'),
(141, 28, 'Manuscript', 'ACTD', '85', 'JobReassignment LE', NULL, 'Ragnii.Ommanney', '2023-01-05 07:08:03', 'Ragnii.Ommanney'),
(142, 28, 'Manuscript', 'ACTD', '85', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2023-01-05 07:08:03', 'Ragnii.Ommanney'),
(143, 29, 'Manuscript', 'CLWA', '213', 'JobReassignment LE', NULL, 'Ragnii.Ommanney', '2023-01-05 07:17:21', 'Ragnii.Ommanney'),
(144, 29, 'Manuscript', 'CLWA', '213', 'JobReassignment PE', NULL, 'Chelsea.Mercado', '2023-01-05 07:17:21', 'Ragnii.Ommanney'),
(145, 30, 'Manuscript', 'CIV', '49', 'JobReassignment LE', NULL, 'Kynan.Rogers', '2023-01-10 15:58:44', 'Kynan.Rogers'),
(146, 30, 'Manuscript', 'CIV', '49', 'JobReassignment PE', NULL, 'Renalyn.Masu-ay', '2023-01-10 15:58:44', 'Kynan.Rogers'),
(147, 55, 'Coversheet', 'CIV', '49', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2023-01-10 16:10:04', 'sierrakx.tl'),
(148, 56, 'Coversheet', 'FRAN', '68', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2023-02-17 14:59:10', 'sierrakx.tl'),
(149, 31, 'Manuscript', 'ABCE', '68', 'JobReassignment LE', NULL, 'Jennifer.Murray', '2023-03-01 20:42:01', 'Jennifer.Murray'),
(150, 31, 'Manuscript', 'ABCE', '68', 'JobReassignment PE', NULL, 'Patricia.Artajo', '2023-03-01 20:42:01', 'Jennifer.Murray'),
(151, 57, 'Coversheet', 'ABCE', '68', 'JobCoversheetReassignment', NULL, 'sierrakx.coding', '2023-03-01 20:53:29', 'sierrakx.tl'),
(152, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintReassignment', NULL, 'sierrakx.stp1', '2023-03-01 21:12:21', 'sierrakxstp.tl'),
(153, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - ConsoHighlight', NULL, 'sierrakx.stp1', '2023-03-01 21:12:37', 'sierrakxstp.tl'),
(154, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - FilingInstruction', NULL, 'sierrakx.stp4', '2023-03-01 21:12:38', 'sierrakxstp.tl'),
(155, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - DummyFiling1', NULL, 'sierrakx.stp2', '2023-03-01 21:12:39', 'sierrakxstp.tl'),
(156, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - DummyFiling2', NULL, 'sierrakx.stp2', '2023-03-01 21:12:39', 'sierrakxstp.tl'),
(157, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - UECJ', NULL, 'sierrakx.stp2', '2023-03-01 21:12:39', 'sierrakxstp.tl'),
(158, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - PC1PC2', NULL, 'sierrakx.stp3', '2023-03-01 21:12:40', 'sierrakxstp.tl'),
(159, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - UpdatingOfEBinder', NULL, 'sierrakx.stp4', '2023-03-01 21:12:40', 'sierrakxstp.tl'),
(160, 19, 'SendToPrint', 'ABCE', '68', 'SendToPrintOwnerReassignment - PostingBackToStableData', NULL, 'sierrakx.stp4', '2023-03-01 21:12:41', 'sierrakxstp.tl');

-- --------------------------------------------------------

--
-- Table structure for table `turnaroundtime_mt`
--

CREATE TABLE `turnaroundtime_mt` (
  `TurnAroundTimeID` int(11) NOT NULL,
  `ManusType` varchar(100) NOT NULL,
  `DaysPerTaskEdit` int(11) NOT NULL,
  `DaysPerTaskProcess` int(11) NOT NULL,
  `DaysPerTaskApproval` int(11) NOT NULL,
  `DaysPerTaskOnline` int(11) NOT NULL,
  `BenchMarkDays` int(11) NOT NULL,
  `DateCreated` datetime NOT NULL,
  `CreatedEmployeeID` int(11) NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `UpdateEmployeeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `turnaroundtime_mt`
--

INSERT INTO `turnaroundtime_mt` (`TurnAroundTimeID`, `ManusType`, `DaysPerTaskEdit`, `DaysPerTaskProcess`, `DaysPerTaskApproval`, `DaysPerTaskOnline`, `BenchMarkDays`, `DateCreated`, `CreatedEmployeeID`, `DateUpdated`, `UpdateEmployeeID`) VALUES
(1, 'Manus-Light', 4, 7, 0, 9, 9, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(2, 'Manus-Medium', 8, 13, 0, 15, 15, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(3, 'Manus-Heavy', 13, 23, 0, 25, 25, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(4, 'Key Leg', 0, 8, 0, 10, 10, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(5, 'Sec Leg', 0, 18, 0, 20, 20, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(6, 'Prac Mat', 0, 18, 0, 20, 20, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(7, 'Ed Mns-Lgt', 0, 3, 0, 5, 5, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(8, 'Ed Mns-Med', 0, 5, 0, 7, 7, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(9, 'Ed Mns-Hvy', 0, 10, 0, 12, 12, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(10, 'Index', 0, 3, 0, 5, 5, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(11, 'TOC', 0, 5, 0, 0, 5, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(12, 'TOS', 0, 5, 0, 0, 5, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(13, 'Other', 0, 5, 0, 7, 7, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(14, 'Light (<1k words)', 1, 4, 6, 8, 8, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(15, 'Medium (1k-3k words)', 1, 6, 8, 10, 10, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(16, 'Heavy (3k-5k words)', 1, 11, 13, 15, 15, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(17, 'Super Heavy (>5k words)', 1, 16, 18, 20, 20, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1),
(18, 'ASX', 0, 3, 0, 5, 5, '2022-03-07 00:00:00', 1, '2022-03-07 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `updatetypehistory`
--

CREATE TABLE `updatetypehistory` (
  `ID` int(11) NOT NULL,
  `Details` varchar(250) DEFAULT NULL,
  `TransactionDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `updatetype_mt`
--

CREATE TABLE `updatetype_mt` (
  `ID` int(11) NOT NULL,
  `UpdateType` varchar(50) NOT NULL,
  `TaskType` varchar(50) NOT NULL,
  `CopyEditDays` int(11) NOT NULL,
  `ProcessDays` int(11) NOT NULL,
  `OnlineDays` int(11) NOT NULL,
  `PDFQADays` int(11) NOT NULL,
  `BenchMarkDays` int(11) NOT NULL,
  `IsEdit` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `updatetype_mt`
--

INSERT INTO `updatetype_mt` (`ID`, `UpdateType`, `TaskType`, `CopyEditDays`, `ProcessDays`, `OnlineDays`, `PDFQADays`, `BenchMarkDays`, `IsEdit`) VALUES
(1, 'Manus-Light', 'COMMENTARY', 4, 3, 2, 2, 11, 1),
(2, 'Manus-Medium', 'COMMENTARY', 8, 5, 2, 2, 17, 1),
(3, 'Manus-Heavy', 'COMMENTARY', 13, 10, 2, 2, 27, 1),
(4, 'Key Leg', 'LEGISLATION', 0, 8, 2, 2, 12, 0),
(5, 'Sec Leg', 'LEGISLATION', 0, 18, 2, 2, 22, 0),
(6, 'Prac Mat', 'PRAC MAT', 0, 18, 2, 2, 22, 0),
(7, 'Ed Mns-Lgt', 'COMMENTARY', 0, 3, 2, 2, 7, 0),
(8, 'Ed Mns-Med', 'COMMENTARY', 0, 5, 2, 2, 9, 0),
(9, 'Ed Mns-Hvy', 'COMMENTARY', 0, 10, 2, 2, 14, 0),
(10, 'Index', 'COMMENTARY', 0, 3, 2, 2, 7, 0),
(11, 'TOC', 'COMMENTARY', 0, 5, 2, 2, 7, 0),
(12, 'TOS', 'COMMENTARY', 0, 5, 2, 2, 7, 0),
(13, 'Other', 'COMMENTARY', 0, 5, 2, 2, 7, 0);

-- --------------------------------------------------------

--
-- Table structure for table `useraccess_mt`
--

CREATE TABLE `useraccess_mt` (
  `ID` int(11) NOT NULL,
  `UserAccessName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `useraccess_mt`
--

INSERT INTO `useraccess_mt` (`ID`, `UserAccessName`) VALUES
(1, 'Admin'),
(2, 'Client(LE)'),
(3, 'Straive(PE)'),
(4, 'Coding TL'),
(5, 'Coding'),
(6, 'Coding(STP) TL'),
(7, 'Coding(STP)');

-- --------------------------------------------------------

--
-- Table structure for table `userdatahistory`
--

CREATE TABLE `userdatahistory` (
  `ID` int(11) NOT NULL,
  `Details` varchar(250) NOT NULL,
  `TransactionDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `__migrationhistory`
--

CREATE TABLE `__migrationhistory` (
  `MigrationId` varchar(150) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `ContextKey` varchar(300) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Model` longblob NOT NULL,
  `ProductVersion` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assignedroles`
--
ALTER TABLE `assignedroles`
  ADD PRIMARY KEY (`AssignedRolesID`);

--
-- Indexes for table `audittb`
--
ALTER TABLE `audittb`
  ADD PRIMARY KEY (`AuditID`);

--
-- Indexes for table `calltoactiondata`
--
ALTER TABLE `calltoactiondata`
  ADD PRIMARY KEY (`CallToActionID`);

--
-- Indexes for table `completionemaildata`
--
ALTER TABLE `completionemaildata`
  ADD PRIMARY KEY (`CompletionEmailDataID`);

--
-- Indexes for table `completionemail_mt`
--
ALTER TABLE `completionemail_mt`
  ADD PRIMARY KEY (`CompletionEmailID`);

--
-- Indexes for table `coversheetdata`
--
ALTER TABLE `coversheetdata`
  ADD PRIMARY KEY (`CoversheetID`);

--
-- Indexes for table `coversheetquery`
--
ALTER TABLE `coversheetquery`
  ADD PRIMARY KEY (`CoversheetNo`,`QueryID`),
  ADD KEY `QueryID_idx` (`QueryID`);

--
-- Indexes for table `coversheetstp`
--
ALTER TABLE `coversheetstp`
  ADD PRIMARY KEY (`STPNo`,`CoversheetNo`),
  ADD KEY `CoversheetNo_idx` (`CoversheetNo`);

--
-- Indexes for table `coversheet_mt`
--
ALTER TABLE `coversheet_mt`
  ADD PRIMARY KEY (`CoversheetID`);

--
-- Indexes for table `descriptiontb`
--
ALTER TABLE `descriptiontb`
  ADD PRIMARY KEY (`DescriptionID`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`DocumentID`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`EmployeeID`),
  ADD KEY `UserAccessID_idx` (`UserAccessID`);

--
-- Indexes for table `expense`
--
ALTER TABLE `expense`
  ADD PRIMARY KEY (`ExpenseID`);

--
-- Indexes for table `expenseaudittb`
--
ALTER TABLE `expenseaudittb`
  ADD PRIMARY KEY (`ApprovaExpenselLogID`);

--
-- Indexes for table `job`
--
ALTER TABLE `job`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `JobStatusID_idx` (`JobStatusID`),
  ADD KEY `OwnerUserID_idx` (`OwnerUserID`),
  ADD KEY `ProductID_idx` (`ProductID`),
  ADD KEY `UpdateTypeID_idx` (`UpdateTypeID`);

--
-- Indexes for table `jobcoversheetdata`
--
ALTER TABLE `jobcoversheetdata`
  ADD PRIMARY KEY (`JobCoversheetID`);

--
-- Indexes for table `jobdata`
--
ALTER TABLE `jobdata`
  ADD PRIMARY KEY (`JobID`);

--
-- Indexes for table `jobhistory`
--
ALTER TABLE `jobhistory`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `jobstatus_mt`
--
ALTER TABLE `jobstatus_mt`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `legislation`
--
ALTER TABLE `legislation`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `UpdateTypeID_idx` (`UpdateTypeID`);

--
-- Indexes for table `legislationdata`
--
ALTER TABLE `legislationdata`
  ADD PRIMARY KEY (`LegislationID`);

--
-- Indexes for table `legislationnewdata`
--
ALTER TABLE `legislationnewdata`
  ADD PRIMARY KEY (`LegislationID`);

--
-- Indexes for table `manuscriptdata`
--
ALTER TABLE `manuscriptdata`
  ADD PRIMARY KEY (`ManuscriptID`);

--
-- Indexes for table `manuscriptquery`
--
ALTER TABLE `manuscriptquery`
  ADD PRIMARY KEY (`JobID`,`QueryID`);

--
-- Indexes for table `notificationstb`
--
ALTER TABLE `notificationstb`
  ADD PRIMARY KEY (`NotificationsID`);

--
-- Indexes for table `producthistory`
--
ALTER TABLE `producthistory`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `productlevel`
--
ALTER TABLE `productlevel`
  ADD PRIMARY KEY (`ProductLevelID`);

--
-- Indexes for table `product_mt`
--
ALTER TABLE `product_mt`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `UserID_idx` (`OwnerUserID`);

--
-- Indexes for table `projectmaster`
--
ALTER TABLE `projectmaster`
  ADD PRIMARY KEY (`ProjectID`);

--
-- Indexes for table `publicationassignment`
--
ALTER TABLE `publicationassignment`
  ADD PRIMARY KEY (`PublicationAssignmentID`);

--
-- Indexes for table `pubsched_mt`
--
ALTER TABLE `pubsched_mt`
  ADD PRIMARY KEY (`PubSchedID`);

--
-- Indexes for table `querydata`
--
ALTER TABLE `querydata`
  ADD PRIMARY KEY (`QueryID`);

--
-- Indexes for table `queryreplies`
--
ALTER TABLE `queryreplies`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `QueryID` (`QueryID`);

--
-- Indexes for table `querystatus_mt`
--
ALTER TABLE `querystatus_mt`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `querytb`
--
ALTER TABLE `querytb`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `QueryTopicID_idx` (`QueryTopicID`),
  ADD KEY `QueryStatusID` (`QueryStatusID`);

--
-- Indexes for table `querytopic_mt`
--
ALTER TABLE `querytopic_mt`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`RegistrationID`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`RoleID`);

--
-- Indexes for table `sendtoprintdata`
--
ALTER TABLE `sendtoprintdata`
  ADD PRIMARY KEY (`SendToPrintID`);

--
-- Indexes for table `stp`
--
ALTER TABLE `stp`
  ADD PRIMARY KEY (`STPNo`),
  ADD KEY `STPOwnerUserID` (`OwnerUserID`);

--
-- Indexes for table `stplegislation`
--
ALTER TABLE `stplegislation`
  ADD PRIMARY KEY (`LegislationID`,`STPNo`),
  ADD KEY `STPLegislationSTPNo` (`STPNo`);

--
-- Indexes for table `stpquery`
--
ALTER TABLE `stpquery`
  ADD PRIMARY KEY (`STPNo`,`QueryID`),
  ADD KEY `STPQueryQueryID` (`QueryID`);

--
-- Indexes for table `subsequentpassdata`
--
ALTER TABLE `subsequentpassdata`
  ADD PRIMARY KEY (`SubsequentPassID`);

--
-- Indexes for table `tasklevel`
--
ALTER TABLE `tasklevel`
  ADD PRIMARY KEY (`TaskLevelID`);

--
-- Indexes for table `timesheetaudittb`
--
ALTER TABLE `timesheetaudittb`
  ADD PRIMARY KEY (`ApprovalTimeSheetLogID`);

--
-- Indexes for table `timesheetdetails`
--
ALTER TABLE `timesheetdetails`
  ADD PRIMARY KEY (`TimeSheetID`);

--
-- Indexes for table `timesheetmaster`
--
ALTER TABLE `timesheetmaster`
  ADD PRIMARY KEY (`TimeSheetMasterID`);

--
-- Indexes for table `transactionlog`
--
ALTER TABLE `transactionlog`
  ADD PRIMARY KEY (`TransactionLogID`);

--
-- Indexes for table `turnaroundtime_mt`
--
ALTER TABLE `turnaroundtime_mt`
  ADD PRIMARY KEY (`TurnAroundTimeID`);

--
-- Indexes for table `updatetypehistory`
--
ALTER TABLE `updatetypehistory`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `updatetype_mt`
--
ALTER TABLE `updatetype_mt`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `useraccess_mt`
--
ALTER TABLE `useraccess_mt`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `userdatahistory`
--
ALTER TABLE `userdatahistory`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `__migrationhistory`
--
ALTER TABLE `__migrationhistory`
  ADD PRIMARY KEY (`MigrationId`,`ContextKey`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assignedroles`
--
ALTER TABLE `assignedroles`
  MODIFY `AssignedRolesID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audittb`
--
ALTER TABLE `audittb`
  MODIFY `AuditID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `calltoactiondata`
--
ALTER TABLE `calltoactiondata`
  MODIFY `CallToActionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=210;

--
-- AUTO_INCREMENT for table `completionemaildata`
--
ALTER TABLE `completionemaildata`
  MODIFY `CompletionEmailDataID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `completionemail_mt`
--
ALTER TABLE `completionemail_mt`
  MODIFY `CompletionEmailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `coversheetdata`
--
ALTER TABLE `coversheetdata`
  MODIFY `CoversheetID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `coversheet_mt`
--
ALTER TABLE `coversheet_mt`
  MODIFY `CoversheetID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;

--
-- AUTO_INCREMENT for table `descriptiontb`
--
ALTER TABLE `descriptiontb`
  MODIFY `DescriptionID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `DocumentID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `EmployeeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `expense`
--
ALTER TABLE `expense`
  MODIFY `ExpenseID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expenseaudittb`
--
ALTER TABLE `expenseaudittb`
  MODIFY `ApprovaExpenselLogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `job`
--
ALTER TABLE `job`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobcoversheetdata`
--
ALTER TABLE `jobcoversheetdata`
  MODIFY `JobCoversheetID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `jobdata`
--
ALTER TABLE `jobdata`
  MODIFY `JobID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `jobhistory`
--
ALTER TABLE `jobhistory`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `legislationdata`
--
ALTER TABLE `legislationdata`
  MODIFY `LegislationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `legislationnewdata`
--
ALTER TABLE `legislationnewdata`
  MODIFY `LegislationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

--
-- AUTO_INCREMENT for table `manuscriptdata`
--
ALTER TABLE `manuscriptdata`
  MODIFY `ManuscriptID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT for table `notificationstb`
--
ALTER TABLE `notificationstb`
  MODIFY `NotificationsID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_mt`
--
ALTER TABLE `product_mt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `projectmaster`
--
ALTER TABLE `projectmaster`
  MODIFY `ProjectID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `publicationassignment`
--
ALTER TABLE `publicationassignment`
  MODIFY `PublicationAssignmentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=122;

--
-- AUTO_INCREMENT for table `pubsched_mt`
--
ALTER TABLE `pubsched_mt`
  MODIFY `PubSchedID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1049;

--
-- AUTO_INCREMENT for table `querydata`
--
ALTER TABLE `querydata`
  MODIFY `QueryID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `queryreplies`
--
ALTER TABLE `queryreplies`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `querytb`
--
ALTER TABLE `querytb`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `querytopic_mt`
--
ALTER TABLE `querytopic_mt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `registration`
--
ALTER TABLE `registration`
  MODIFY `RegistrationID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `RoleID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sendtoprintdata`
--
ALTER TABLE `sendtoprintdata`
  MODIFY `SendToPrintID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `subsequentpassdata`
--
ALTER TABLE `subsequentpassdata`
  MODIFY `SubsequentPassID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `timesheetaudittb`
--
ALTER TABLE `timesheetaudittb`
  MODIFY `ApprovalTimeSheetLogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `timesheetdetails`
--
ALTER TABLE `timesheetdetails`
  MODIFY `TimeSheetID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `timesheetmaster`
--
ALTER TABLE `timesheetmaster`
  MODIFY `TimeSheetMasterID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transactionlog`
--
ALTER TABLE `transactionlog`
  MODIFY `TransactionLogID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

--
-- AUTO_INCREMENT for table `turnaroundtime_mt`
--
ALTER TABLE `turnaroundtime_mt`
  MODIFY `TurnAroundTimeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `updatetype_mt`
--
ALTER TABLE `updatetype_mt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `useraccess_mt`
--
ALTER TABLE `useraccess_mt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `userdatahistory`
--
ALTER TABLE `userdatahistory`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `coversheetquery`
--
ALTER TABLE `coversheetquery`
  ADD CONSTRAINT `CoversheetQueryCoversheetNo` FOREIGN KEY (`CoversheetNo`) REFERENCES `coversheet` (`CoversheetNo`);

--
-- Constraints for table `coversheetstp`
--
ALTER TABLE `coversheetstp`
  ADD CONSTRAINT `CoversheetSTPCoversheetNo` FOREIGN KEY (`CoversheetNo`) REFERENCES `coversheet` (`CoversheetNo`),
  ADD CONSTRAINT `CoversheetSTPSTPNo` FOREIGN KEY (`STPNo`) REFERENCES `stp` (`STPNo`);

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `UserAccessID` FOREIGN KEY (`UserAccessID`) REFERENCES `useraccess_mt` (`ID`);

--
-- Constraints for table `job`
--
ALTER TABLE `job`
  ADD CONSTRAINT `JobOwnerUserID` FOREIGN KEY (`OwnerUserID`) REFERENCES `employee` (`EmployeeID`),
  ADD CONSTRAINT `JobProductID` FOREIGN KEY (`ProductID`) REFERENCES `product_mt` (`ID`),
  ADD CONSTRAINT `JobStatusID` FOREIGN KEY (`JobStatusID`) REFERENCES `jobstatus_mt` (`ID`),
  ADD CONSTRAINT `JobUpdateTypeID` FOREIGN KEY (`UpdateTypeID`) REFERENCES `updatetype_mt` (`ID`);

--
-- Constraints for table `jobhistory`
--
ALTER TABLE `jobhistory`
  ADD CONSTRAINT `JobHistoryJobID` FOREIGN KEY (`ID`) REFERENCES `job` (`ID`);

--
-- Constraints for table `legislation`
--
ALTER TABLE `legislation`
  ADD CONSTRAINT `LegislationUpdateTypeID` FOREIGN KEY (`UpdateTypeID`) REFERENCES `updatetype_mt` (`ID`);

--
-- Constraints for table `manuscriptquery`
--
ALTER TABLE `manuscriptquery`
  ADD CONSTRAINT `ManuscriptQueryJobID` FOREIGN KEY (`JobID`) REFERENCES `job` (`ID`),
  ADD CONSTRAINT `ManuscriptQueryQueryID` FOREIGN KEY (`JobID`) REFERENCES `querytb` (`ID`);

--
-- Constraints for table `product_mt`
--
ALTER TABLE `product_mt`
  ADD CONSTRAINT `ProductOwnerUserID` FOREIGN KEY (`OwnerUserID`) REFERENCES `employee` (`EmployeeID`);

--
-- Constraints for table `queryreplies`
--
ALTER TABLE `queryreplies`
  ADD CONSTRAINT `QueryID` FOREIGN KEY (`QueryID`) REFERENCES `querytb` (`ID`);

--
-- Constraints for table `querytb`
--
ALTER TABLE `querytb`
  ADD CONSTRAINT `QueryStatusID` FOREIGN KEY (`QueryStatusID`) REFERENCES `querystatus_mt` (`ID`),
  ADD CONSTRAINT `QueryTopicID` FOREIGN KEY (`QueryTopicID`) REFERENCES `querytopic_mt` (`ID`);

--
-- Constraints for table `stp`
--
ALTER TABLE `stp`
  ADD CONSTRAINT `STPOwnerUserID` FOREIGN KEY (`OwnerUserID`) REFERENCES `employee` (`EmployeeID`);

--
-- Constraints for table `stplegislation`
--
ALTER TABLE `stplegislation`
  ADD CONSTRAINT `STPLegislationLegislationID` FOREIGN KEY (`LegislationID`) REFERENCES `legislation` (`ID`),
  ADD CONSTRAINT `STPLegislationSTPNo` FOREIGN KEY (`STPNo`) REFERENCES `stp` (`STPNo`);

--
-- Constraints for table `stpquery`
--
ALTER TABLE `stpquery`
  ADD CONSTRAINT `STPQueryQueryID` FOREIGN KEY (`QueryID`) REFERENCES `querytb` (`ID`),
  ADD CONSTRAINT `STPQuerySTPNo` FOREIGN KEY (`STPNo`) REFERENCES `stp` (`STPNo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
