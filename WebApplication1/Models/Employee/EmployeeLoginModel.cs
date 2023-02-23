using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace JobTrack.Models.Employee
{
    public class EmployeeLogin
    {
        //public int ID { get; set; }

        //[Required]
        //[StringLength(30)]

        //[Display(Name = "Username")]
        //public string Username { get; set; }

        //[Required]
        //[StringLength(30, MinimumLength = 8)]
        //[Display(Name = "Password")]
        //[DataType(DataType.Password)]
        //public string Password { get; set; }

        //public string EmployeeAccess { get; set; }
        //public int EmployeeAccessID { get; set; }

        public string ID { get; set; }

        public string Password { get; set; }

        public string BrowsertimeZone { get; set; }

        public DateTime? LoginDate { get; set; }

        public bool RememberMe { get; set; }
    }
}