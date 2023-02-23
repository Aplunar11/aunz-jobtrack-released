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

namespace JobTrack.Models.Profile
{
    public class ProfileData
    {
        public int EmployeeID { get; set; }
        [Display(Name = "User Access")]
        public string UserAccessName { get; set; }
        [MinLength(5, ErrorMessage = "UserName must be at least 5 charaters")]
        public string UserName { get; set; }
        public string Password { get; set; }
        [Display(Name = "New Password:")]
        public string NewPassword { get; set; }
        [Display(Name = "Confirm New Password:")]
        public string ConfirmNewPassword { get; set; }
        [Display(Name = "First Name:")]
        public string FirstName { get; set; }
        [Display(Name = "Last Name:")]
        public string LastName { get; set; }
        [Display(Name = "Full Name:")]
        public string FullName { get; set; }
        [Display(Name = "Email Address:")]
        public string EmailAddress { get; set; }
        [Display(Name = "Mobile Number")]
        [MaxLength(11)]
        [MinLength(10)]
        [RegularExpression("^[0-9]*$", ErrorMessage = "Mobile Number must be numeric")]
        public string MobileNumber { get; set; }
        [Display(Name = "Manager?:")]
        public bool IsManager { get; set; }
        [Display(Name = "Editorial Contact?:")]
        public bool IsEditorialContact { get; set; }
        [Display(Name = "Email List?:")]
        public bool IsEmailList { get; set; }
        [Display(Name = "Mandatory Recepient?:")]
        public bool IsMandatoryRecepient { get; set; }
        [Display(Name = "Show User?:")]
        public bool IsShowUser { get; set; }
        [Display(Name = "Employee Status:")]
        public string Status { get; set; }
        [Display(Name = "Password Update:")]
        public DateTime? PasswordUpdate { get; set; }

        [Display(Name = "Date Created:")]
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
    }
}