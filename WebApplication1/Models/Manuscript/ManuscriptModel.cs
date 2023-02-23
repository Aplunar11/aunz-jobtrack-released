using System;
using System.Collections.Generic;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;

namespace JobTrack.Models.Manuscript
{
    public class ManuscriptViewModel
    {
        public List<ManuscriptData> ListManuscript { get; set; }
        public string ErrorMessage { get; set; }
        //public ManuscriptViewModel()
        //{
        //    this.BPSProductID = new List<SelectListItem>();
        //    this.ServiceNumber = new List<SelectListItem>();
        //}
        //public List<SelectListItem> BPSProductID { get; set; }
        //public List<SelectListItem> ServiceNumber { get; set; }

        //[Required(ErrorMessage = "BPSProductID Required!")]
        //public string JobID { get; set; }
        //[Required(ErrorMessage = "ServiceNumber Required!")]
        //public int ManuscriptID { get; set; }
        //[Required(ErrorMessage = "ManuscriptLegTitle Required!")]
        //public string ManuscriptLegTitle { get; set; }
        //public DateTime? TargetPressDate { get; set; }
        //public DateTime? ActualPressDate { get; set; }
    }


    public class ManuscriptData
    {
        public int ManuscriptID { get; set; }

        //[Display(Name = "Job Number")]
        //[Required(ErrorMessage = "Please enter job number")]
        //[RegularExpression(@"^[0-9]{5,8}$", ErrorMessage = "minimum of 5 digits and maximum of 8 digits")]
        [Display(Name = "Job Number:")]
        public string JobNumber { get; set; }

        [Display(Name = "Tier:")]
        //[Required(ErrorMessage = "Please select tier")]
        public string ManuscriptTier { get; set; }

        [Display(Name = "Product:")]
        //[Required(ErrorMessage = "Please select product")]
        public string BPSProductID { get; set; }

        [Display(Name = "Service Number:")]
        //[Required(ErrorMessage = "Please enter service number")]
        public string ServiceNumber { get; set; }

        [Display(Name = "Manuscript/Leg Title:")]
        //[Required(ErrorMessage = "Please enter title")]
        public string ManuscriptLegTitle { get; set; }
        [Display(Name = "Status:")]
        public string ManuscriptStatus { get; set; }

        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Target Press Date:")]
        //[Required(ErrorMessage = "Please select target press date")]
        public DateTime? TargetPressDate { get; set; }

        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Actual Press Date:")]
        public DateTime? ActualPressDate { get; set; }

        [Display(Name = "Latup Attribution:")]
        public string LatupAttribution { get; set; }

        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Received From Author:")]
        public DateTime? DateReceivedFromAuthor { get; set; }

        [Display(Name = "Update Type:")]
        //[Required(ErrorMessage = "Please select update type")]
        public string UpdateType { get; set; }

        [Display(Name = "Job Specific Instruction:")]
        public string JobSpecificInstruction { get; set; }

        [Display(Name = "Task Type:")]
        public string TaskType { get; set; }
        [Display(Name = "Guide Card:")]
        public string PEGuideCard { get; set; }
        [Display(Name = "")]
        public string PECheckbox { get; set; }
        [Display(Name = "Task Number:")]
        public string PETaskNumber { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Revised Online Due Date:")]
        public DateTime? RevisedOnlineDueDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Copyedit - Due Date:")]
        public DateTime? CopyEditDueDate { get; set; }
        [Display(Name = "Copyedit - Start:")]
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        public DateTime? CopyEditStartDate { get; set; }
        [Display(Name = "Copyedit - Done:")]
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        public DateTime? CopyEditDoneDate { get; set; }
        [Display(Name = "Copyedit - Status:")]
        public string CopyEditStatus { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Coding - Due Date:")]
        public DateTime? CodingDueDate { get; set; }
        [Display(Name = "Coding - Start:")]
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        public DateTime? CodingStartDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Coding - Done:")]
        public DateTime? CodingDoneDate { get; set; }
        [Display(Name = "Coding - Status:")]
        public string CodingStatus { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Online - Due Date:")]
        public DateTime? OnlineDueDate { get; set; }
        [Display(Name = "Online - Start:")]
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        public DateTime? OnlineStartDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Online - Done:")]
        public DateTime? OnlineDoneDate { get; set; }
        [Display(Name = "Online - Status:")]
        public string OnlineStatus { get; set; }

        [Display(Name = "STP - Status:")]
        public string STPStatus { get; set; }
        [Display(Name = "EST Pages:")]
        public int? EstimatedPages { get; set; }
        [Display(Name = "Actual TAT:")]
        public int? ActualTurnAroundTime { get; set; }
        [Display(Name = "Online Timeliness:")]
        public string OnlineTimeliness { get; set; }
        [Display(Name = "Remarks:")]
        public string ReasonIfLate { get; set; }
        [Display(Name = "Coversheet Number:")]
        public string PECoversheetNumber { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Created:")]
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
        public SelectList ServiceNumberList { get; set; }
    }

    public class GetPubSchedTier
    {
        public string PubSchedTier { get; set; }

    }
    public class GetPubschedBPSProductID
    {
        public string PubschedBPSProductID { get; set; }

    }
    public class GetAllPubschedServiceNumber
    {
        public string PubschedTier { get; set; }
        public string PubschedBPSProductID { get; set; }
        public string PubschedServiceNumber { get; set; }
        //[DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy}")]
        public DateTime PubschedTargetPressDate { get; set; }

    }
    public class GetBPSProductIDJobs
    {
        public string BPSProductIDJobs { get; set; }

    }
    public class GetServiceNumberJobs
    {
        public string ServiceNumberJobs { get; set; }

    }
    public class GetAllTurnAroundTime
    {
        public int TurnAroundTimeID { get; set; }
        public string UpdateType { get; set; }
        public string TaskType { get; set; }
        public int TATCopyEdit { get; set; }
        public int TATCoding { get; set; }
        public int TATOnline { get; set; }
        public int TATPDFQA { get; set; }
        public int BenchMarkDays { get; set; }

    }
}