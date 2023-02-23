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

namespace JobTrack.Models.Coversheet
{
    public class CoversheetViewModel
    {
        public List<CoversheetData> ListCoversheet { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class CoversheetData
    {
        public int CoversheetID { get; set; }
        public int ManuscriptID { get; set; }

        [Display(Name = "Job Number")]
        [Required(ErrorMessage = "Please enter job number")]
        public int JobNumber { get; set; }

        [Display(Name = "Product")]
        [Required(ErrorMessage = "Please select product")]
        public string BPSProductID { get; set; }

        [Display(Name = "Service Number")]
        [Required(ErrorMessage = "Please enter service number")]
        public string ServiceNumber { get; set; }

        [Display(Name = "Manuscript/Leg Title")]
        [Required(ErrorMessage = "Please enter title")]
        public string ManuscriptLegTitle { get; set; }

        [Display(Name = "Status")]
        [Required(ErrorMessage = "Please select status")]
        public string ManusciptLegTitleStatus { get; set; }

        [Display(Name = "Target Press Date")]
        [Required(ErrorMessage = "Please select target press date")]
        public DateTime TargetPressDate { get; set; }

        [Display(Name = "Actual Press Date")]
        [Required(ErrorMessage = "Please select actual press date")]
        public DateTime ActualPressDate { get; set; }

        [Display(Name = "Latup Attribution")]
        public string LatupAttribution { get; set; }

        [Display(Name = "Date Received From Author")]
        public DateTime DateReceivedFromAuthor { get; set; }

        [Display(Name = "Update Type")]
        [Required(ErrorMessage = "Please select update type")]
        public string UpdateType { get; set; }

        [Display(Name = "Job Specific Instruction")]
        public string JobSpecificInstruction { get; set; }

        [Display(Name = "Task Type")]
        public string TaskType { get; set; }

        [Display(Name = "Guide Card")]
        public string GuideCard { get; set; }

        [Display(Name = "Checkbox")]
        public string CoversheetCheckbox { get; set; }

        [Display(Name = "Task Number")]
        public string TaskNumber { get; set; }

        [Display(Name = "Revised Online Due Date")]
        public DateTime RevisedOnlineDueDate { get; set; }

        [Display(Name = "Copy Edit - Due Date")]
        public DateTime CopyEditDueDate { get; set; }

        [Display(Name = "Copy Edit - Start Date")]
        public DateTime CopyEditStartDate { get; set; }

        [Display(Name = "Copy Edit - Done Date")]
        public DateTime CopyEditDoneDate { get; set; }

        [Display(Name = "Copy Edit - QC Due Date")]
        public DateTime CopyEditQCDueDate { get; set; }

        [Display(Name = "Copy Edit - QC Start Date")]
        public DateTime CopyEditQCStartDate { get; set; }

        [Display(Name = "Copy Edit - QC Done Date")]
        public DateTime CopyEditQCDoneDate { get; set; }

        [Display(Name = "Coding - Due Date")]
        public DateTime CodingDueDate { get; set; }

        [Display(Name = "Coding - Done Date")]
        public DateTime CodingDoneDate { get; set; }

        [Display(Name = "Online - Due Date")]
        public DateTime OnlineDueDate { get; set; }

        [Display(Name = "Online - Done Date")]
        public DateTime OnlineDoneDate { get; set; }

        [Display(Name = "Estimated Pages")]
        public int EstimatedPages { get; set; }

        [Display(Name = "Actual Turn Around Time")]
        public int ActualTAT { get; set; }

        [Display(Name = "Online - Done Date")]
        public string OnlineTimeliness { get; set; }

        [Display(Name = "Reason if Late")]
        public string ReasonIfLate { get; set; }

        [Display(Name = "Coversheet Number")]
        public string CoversheetNumber { get; set; }

        [Display(Name = "STP?")]
        public string isSTP { get; set; }

        [Display(Name = "Coversheet Editor")]
        public string CoversheetEditor { get; set; }

        [Display(Name = "Charge Code")]
        public string ChargeCode { get; set; }

        [Display(Name = "Further Instructions")]
        public string FurtherInstruction { get; set; }

        [Display(Name = "General")]
        public string CoversheetGeneral { get; set; }

        [Display(Name = "Special Instruction")]
        public string SpecialInstruction { get; set; }

        [Display(Name = "XML Editing")]
        public string XMLEditing { get; set; }

        [Display(Name = "Correction Due Date")]
        public string CorrectionsDueDate { get; set; }
        public string Corrections { get; set; }
        public string DateCreated { get; set; }
        public string CreatedEmployeeID { get; set; }
        public string DateUpdated { get; set; }
        public string UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
    }
}