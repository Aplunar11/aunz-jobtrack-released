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

namespace JobTrack.Models.Job
{
    public class JobViewModel
    {
        public int JobID { get; set; }
        public string ManuscriptTier { get; set; }
        public string BPSProductID { get; set; }
        public string ServiceNumber { get; set; }
        public DateTime? TargetPressDate { get; set; }
        public DateTime? ActualPressDate { get; set; }
        public string CopyEditStatus { get; set; }
        public string CodingStatus { get; set; }
        public string OnlineStatus { get; set; }

        public string PESTPStatus { get; set; }
        public List<ManuscriptViewModel> ManuscriptDetails { get; set; }
    }
    public class ManuscriptViewModel
    {
        public int ManuscriptID { get; set; }
        public string ManuscriptTier { get; set; }

        public string BPSProductID { get; set; }
        public string ServiceNumber { get; set; }
        public DateTime? TargetPressDate { get; set; }
        public DateTime? ActualPressDate { get; set; }

        public string LatupAttribution { get; set; }
        public DateTime? DateReceivedFromAuthor { get; set; }
        public string UpdateType { get; set; }
        public string JobSpecificInstruction { get; set; }
        public string TaskType { get; set; }
    }

    public class JobModel
    {
        public List<JobData> ListJob { get; set; }
        public string ErrorMessage { get; set; }
    }
    public class JobData
    {
        public int JobID { get; set; }
        [Display(Name = "Job Number")]
        //[Required(ErrorMessage = "Please select job number")]
        public string JobNumber { get; set; }

        [Display(Name = "Tier")]
        [Required(ErrorMessage = "Please select tier")]
        public string ManuscriptTier { get; set; }

        [Display(Name = "Product")]
        [Required(ErrorMessage = "Please select product")]
        public string BPSProductID { get; set; }

        [Display(Name = "Service Number")]
        [Required(ErrorMessage = "Please enter service number")]
        public string ServiceNumber { get; set; }

        [Display(Name = "Manuscript/Leg Title")]
        [Required(ErrorMessage = "Please enter title")]
        public string ManuscriptLegTitle { get; set; }

        [Display(Name = "Target Press Date")]
        [Required(ErrorMessage = "Please select target press date")]
        public DateTime? TargetPressDate { get; set; }

        [Display(Name = "Actual Press Date")]
        //[Required(ErrorMessage = "Please select actual press date")]
        public DateTime? ActualPressDate { get; set; }

        [Display(Name = "Copyediting")]
        //[Required(ErrorMessage = "Please enter Copyediting")]
        public string CopyEditStatus { get; set; }
        [Display(Name = "Coding")]
        //[Required(ErrorMessage = "Please enter Coding")]
        public string CodingStatus { get; set; }
        [Display(Name = "Online")]
        //[Required(ErrorMessage = "Please enter Online")]
        public string OnlineStatus { get; set; }
        [Display(Name = "STP")]
        //[Required(ErrorMessage = "Please enter STP")]
        public string STPStatus { get; set; }
        [Display(Name = "Date Created")]
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        [Display(Name = "Date Updated")]
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }

    }

}