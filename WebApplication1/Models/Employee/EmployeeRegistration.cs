using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JobTrack.Models.Employee
{
    [Table("EmployeeRegistration")]
    public class EmployeeRegistration
    {
        public int EmployeeID { get; set; }

        [Display(Name = "User Access")]
        [Required(ErrorMessage = "Please select atleast one option")]
        public string UserAccess { get; set; }

        [Display(Name = "Username")]
        [Required(ErrorMessage = "Username required.")]
        public string UserName { get; set; }


        [Display(Prompt = "First Name")]
        [Required(ErrorMessage = "First name required.")]
        public string FirstName { get; set; }

        [Display(Name = "Last Name")]
        [Required(ErrorMessage = "Last name required.")]
        public string LastName { get; set; }

        [Display(Name = "Email Address")]
        [Required(ErrorMessage = "Email Address required.")]
        [EmailAddress(ErrorMessage = "Invalid email address.")]
        public string EmailAddress { get; set; }
        public int IsManager { get; set; }
        public int IsEditorialContact { get; set; }
        public int IsEmailList { get; set; }
        public int IsMandatoryRecepient { get; set; }
        public int IsShowUser { get; set; }

        //[Display(Name = "Password")]
        //[Required(ErrorMessage = "Password required.")]
        //[DataType(DataType.Password)]
        public string Password { get; set; }

        //[Display(Name = "Confirm Password")]
        //[Required(ErrorMessage = "Password required.")]
        //[DataType(DataType.Password)]
        //[System.ComponentModel.DataAnnotations.Compare("Password", ErrorMessage = "Passwords do not match.")]
        //public string ConfirmPassword { get; set; }


    }
}