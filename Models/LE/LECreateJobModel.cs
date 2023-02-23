using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace JobTrack_AUNZ.Models.LE
{
    public class LECreateJobModel
    {
        [Display(Name = "Tier")]
        [Required(ErrorMessage = "Tier required.")]
        public string Tier { get; set; }
        public IEnumerable<SelectListItem> GetTier { get; set; }

        [Display(Name = "Product")]
        [Required(ErrorMessage = "Product required.")]
        public string Product { get; set; }

        public int Product_id { get; set; }

        [Display(Name = "Service Number")]
        [Required(ErrorMessage = "Service number required.")]
        public string ServiceNo { get; set; }

        [Display(Name = "Manuscript/Leg Title")]
        [Required(ErrorMessage = "Manuescript/Leg Title required.")]
        public string Manuscript { get; set; }

        [Display(Name = "Target Press Date")]
        [Required(ErrorMessage = "Enter target press date.")]
        public string TargetDate { get; set; }

        [Display(Name = "Latup Attribution")]
        public string LatupAttribution { get; set; }

        [Display(Name = "Date Received from Author")]
        //[DataType(DataType.Date)]
        public string DateFromAuthor { get; set; }

        [Display(Name = "Update Type")]
        [Required(ErrorMessage = "Please select atleast one option")]
        public string UpdateType { get; set; }
        public int UpdateType_id { get; set; }
        public IEnumerable<SelectListItem> GetUpdateType { get; set; }

        [Display(Name = "Job Specific Instruction")]
        public string JobSpecificInstruction { get; set; }

        [Display(Name = "Task Type")]
        public string TaskType { get; set; }

        [Display(Name = "Copyedit - Due Date")]
        //[DataType(DataType.Date)]
        public string CopyeditDueDate { get; set; }

        [Display(Name = "Coding - Due Date")]
        //[DataType(DataType.Date)]
        public string CodingDueDate { get; set; }

        [Display(Name = "Online - Due Date")]
        //[DataType(DataType.Date)]
        public string OnlineDueDate { get; set; }
    }
}