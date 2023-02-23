using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace JobTrack_AUNZ.Models.PE
{
    public class PEManuscriptModel
    {
        public int Id { get; set; }
        public int JobOwner { get; set; }
        public int JobType { get; set; }
        public int task_id { get; set; }
        public string task_no { get; set; }

        [Display(Name = "Job No. ")]
        public string JobNo { get; set; }

        [Display(Name = "Tier")]
        public string Tier { get; set; }

        [Display(Name = "Product")]
        public string Product { get; set; }

        [Display(Name = "Service No.")]
        public string ServiceNo { get; set; }

        [Display(Name = "Manuscript/Leg Title")]
        public string ManuscriptTitle { get; set; }

        [Display(Name = "Status")]
        public string Status { get; set; }

        [Display(Name = "Target Press Date")]
        public string TargetDate { get; set; }

        [Display(Name = "Actual Press Date")]
        public string PressDate { get; set; }

        [Display(Name = "Latup Attribution")]
        public string LatupAttribution { get; set; }

        [Display(Name = "Date Received from Author")]
        public string DateFromAuthor { get; set; }

        [Display(Name = "Date Created")]
        public string DateCreated { get; set; }

        [Display(Name = "Update Type")]
        public string UpdateType { get; set; }

        [Display(Name = "Job Specific Instruction")]
        public string Instruction { get; set; }

        [Display(Name = "Task Type")]
        public string TaskType { get; set; }

        [Display(Name = "GuideCard")]
        public string GuideCard { get; set; }

        //[Display(Name = "Task Number")]
        //public string TaskNumber{ get; set; }

        [Display(Name = "Revised Online Due Date")]
        public string RevisedDate { get; set; }

        [Display(Name = "Copyedit Due Date")]
        public string CopyeditDue { get; set; }

        [Display(Name = "Copyedit Start")]
        public string CopyeditStart { get; set; }

        [Display(Name = "Copyedit Done")]
        public string CopyeditDone { get; set; }

        [Display(Name = "Coding Due Date")]
        public string CodingDue { get; set; }

        [Display(Name = "Coding Done")]
        public string CodingDone { get; set; }

        [Display(Name = "Online Due Date")]
        public string OnlineDue { get; set; }

        [Display(Name = "Online Done")]
        public string OnlineDone { get; set; }

        [Display(Name = "Est Pages")]
        public string EstPages { get; set; }

        [Display(Name = "Actual TAT")]
        public string ActualTtat { get; set; }

        [Display(Name = "Online Timelines")]
        public string OnlineTimelines { get; set; }

        [Display(Name = "Reasons if late")]
        public string Reason { get; set; }

        [Display(Name = "Coversheet No.")]
        public string CoversheetNo { get; set; }

        [Display(Name = "STP?")]
        public string Stp { get; set; }


        public List<PEManuscriptModel> PEJob { get; set; }

        [Display(Name = "Job Number")]
        public string m_JobNumber { get; set; }

        [Display(Name = "Tier")]
        public string m_Tier { get; set; }

        [Display(Name = "Product")]
        public string m_Product { get; set; }

        [Display(Name = "Service No.")]
        public string m_ServiceNo { get; set; }

        [Display(Name = "Target Press Date")]
        public string m_TargetDate { get; set; }

        [Display(Name = "Actual Press Date")]
        public string m_PressDate { get; set; }

        [Display(Name = "Copyedit")]
        public string m_Copyedit { get; set; }

        [Display(Name = "Coding")]
        public string m_Coding { get; set; }

        [Display(Name = "Online Due Date")]
        public string m_Online { get; set; }

        [Display(Name = "Online Due Date")]
        public string m_STP { get; set; }
        public IEnumerable<SelectListItem> GetTask { get; set; }

        public int t_jobid { get; set; }

        [Display(Name = "Coversheet No.")]
        public string t_CoversheetNo { get; set; }

        [Display(Name = "Service No.")]
        public string t_ServiceNo { get; set; }

        [Display(Name = "Task No.")]
        [Required(ErrorMessage = "Task No. required.")]
        public string t_TaskNo { get; set; }

        [Display(Name = "Product")]
        public string t_Product { get; set; }

        [Display(Name = "Editor")]
        public string t_Editor { get; set; }

        [Display(Name = "Charge Code")]
        [Required(ErrorMessage = "Charge Code required.")]
        public string t_ChargeCode { get; set; }

        [Display(Name = "Target Date")]
        public string t_TargetDate { get; set; }

        [Display(Name = "Task Date")]
        public string t_TaskType { get; set; }

        [Display(Name = "Guide Cards")]
        [Required(ErrorMessage = "Guide Cards required.")]
        public string t_GuideCards { get; set; }

        [Display(Name = "Manuscipt Location/Legislation/Further Instruction")]
        public string t_ManusciptLocation { get; set; }

        [Display(Name = "Update Type")]
        public string t_UpdateType { get; set; }

        [Display(Name = "General")]
        [Required(ErrorMessage = "General required.")]
        public bool t_General { get; set; }

        [Display(Name = "Special Instruction")]
        public string t_specialInstruction { get; set; }
        [Display(Name = "Coding Due Date")]
        public string t_CodingDue { get; set; }
        [Display(Name = "XML Editing")]
        public bool t_XML { get; set; }
        [Display(Name = "Online Due Date")]
        public string t_OnlineDue { get; set; }
        [Display(Name = "Online")]
        public bool t_Online { get; set; }
        [Display(Name = "Correction Due Date")]
        public string t_CorrectionDue { get; set; }
        [Display(Name = "Correction")]
        public string t_Correction { get; set; }
    }
}