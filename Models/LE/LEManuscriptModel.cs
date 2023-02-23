using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace JobTrack_AUNZ.Models.LE
{
    public class LEManuscriptModel
    {
        public int Id { get; set; }
        public int JobOwner { get; set; }
        public int JobType { get; set; }

        [Display(Name = "Job Number")]
        public string JobNumber { get; set; }

        [Display(Name = "Tier")]
        public string Tier { get; set; }

        [Display(Name = "Product")]
        public string Product { get; set; }

        [Display(Name = "Service No.")]
        public string ServiceNo { get; set; }

        [Display(Name = "Manuscrip/Leg Title.")]
        public string Manuscript { get; set; }

        [Display(Name = "Status")]
        public string Status { get; set; }

        [Display(Name = "Target Press Date")]
        public string TargetDate { get; set; }

        [Display(Name = "Actual Press Date")]
        public string PressDate { get; set; }

        [Display(Name = "LATUP Attribution")]
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

        [Display(Name = "Revised Online Due Date")]
        public string RevisedDate { get; set; }

        [Display(Name = "Copyedit Due Date")]
        public string CopyeditDue { get; set; }

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
        //public List<SelectListItem> LEJob { get; set; }
        public List<LEManuscriptModel> LEJob { get; set; }


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


    }
}