using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Configuration;
using MySql.Data;
using MySql.Data.MySqlClient;
using System.Data.SqlClient;
using System.Web.Mvc;
using JobTrack.Models;
using System.ComponentModel.DataAnnotations;

namespace JobTrack.Models.Legislation
{
    public class LegislationModel
    {
        public List<LegislationData> ListLegislation { get; set; }
        public string ErrorMessage { get; set; }
    }
    public class LegislationData
    {
        public int LegislationID { get; set; }
        public string LLE2E { get; set; }
        public DateTime? DateEntered { get; set; }
        public string Editor { get; set; }
        public string QAEditor { get; set; }
        public string PrincipalLegislation { get; set; }
        public string AmendingLegislation { get; set; }
        public DateTime? CommencementDate { get; set; }
        public string LegislationComment { get; set; }
        public DateTime? AssentDate { get; set; }
        public string AffectedProvisions { get; set; }
        public string UpdateType { get; set; }
        public string Tier { get; set; }
        public string Publication { get; set; }
        public string ServiceNumber { get; set; }
        public string GuideCard { get; set; }
        public string Jurisdiction { get; set; }
        public int TotalOutput { get; set; }
        public int ActualEDTOutput { get; set; }
        public int Latup { get; set; }
        public int CNTsAlpha { get; set; }
        public int GraphicsWord { get; set; }
        public int GraphicsPDF { get; set; }
        public int GraphicsOTP { get; set; }
        public int ActualOnlineOutput { get; set; }
        public string JobIDs { get; set; }
        public DateTime? EDTTargetCompletionDate { get; set; }
        public DateTime? EDTActualDate { get; set; }
        public DateTime? QCDate { get; set; }
        public DateTime? DateInitiatedOnline { get; set; }
        public DateTime? OnlineCheckingDate { get; set; }
        public DateTime? RevisedOnlineDueDate { get; set; }
        public DateTime? OnlineActualDueDate { get; set; }
        public string BenchmarkMet { get; set; }
        public DateTime? ProposedDate { get; set; }
        public DateTime? ActualQAOnlineDate { get; set; }
        public string LegislationStatus { get; set; }
        public string Stage { get; set; }
        public string StatusCategory { get; set; }
        public string OnTrackOffTrack { get; set; }
        public string ReasonForDelay { get; set; }
        public DateTime? StartDateOnHold { get; set; }
        public DateTime? PostbackToStableDate { get; set; }
        public DateTime? TargetPressDate { get; set; }
        public string SSLRServices { get; set; }
        public string JiraTickets { get; set; }
        public string LegislationRemarks { get; set; }
        public string isBilled { get; set; }
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
    }
}