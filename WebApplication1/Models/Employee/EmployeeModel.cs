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

namespace JobTrack.Models.Employee
{
    public class EmployeeModel
    {
        // CREATE A LIST VARIABLE
        // LIST <CONTENT AS CLASS>
        public List<EmployeeData> Employees { get; set; }

        public List<EmployeeAccessData> EmployeeUserAccessDropdowns { get; set; }

        public List<EmployeeRegister> EmployeeSignUp { get; set; }
    }
    public class EmployeeData
    {
        public int EmployeeID { get; set; }
        [Display(Name = "User Access")]
        public string UserAccessName { get; set; }
        [MinLength(5, ErrorMessage = "UserName must be at least 5 charaters")]
        public string UserName { get; set; }
        public string Password { get; set; }
        [Display(Name = "Confirm Password")]
        public string ConfirmPassword { get; set; }
        [Display(Name = "First Name")]
        public string FirstName { get; set; }
        [Display(Name = "Last Name")]
        public string LastName { get; set; }
        [Display(Name = "Full Name")]
        public string FullName { get; set; }
        [Display(Name = "Email Address")]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        public string EmailAddress { get; set; }
        [Display(Name = "Mobile Number")]
        [MaxLength(11)]
        [MinLength(10)]
        [RegularExpression("^[0-9]*$", ErrorMessage = "Mobile Number must be numeric")]
        public string MobileNumber { get; set; }
        [Display(Name = "Manager?")]
        public bool IsManager { get; set; }
        [Display(Name = "Editorial Contact?")]
        public bool IsEditorialContact { get; set; }
        [Display(Name = "Email List?")]
        public bool IsEmailList { get; set; }
        [Display(Name = "Mandatory Recepient?")]
        public bool IsMandatoryRecepient { get; set; }
        [Display(Name = "Show User?")]
        public bool IsShowUser { get; set; }
        [Display(Name = "Employee Status")]
        public string Status { get; set; }
        [Display(Name = "Password Update")]
        public DateTime? PasswordUpdate { get; set; }

        [Display(Name = "Date Created")]
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class PublicationAssignmentData
    {
        public int PublicationAssignmentID { get; set; }
        public string BPSProductID { get; set; }
        public string CompleteNameOfPublication { get; set; }
        [Display(Name = "Tier")]
        public string PublicationTier { get; set; }
        [Display(Name = "PE Name")]
        public string PEName { get; set; }
        [Display(Name = "PE Email")]
        public string PEEmail { get; set; }
        [Display(Name = "PE Username")]
        public string PEUserName { get; set; }
        [Display(Name = "PE Status")]
        public string PEStatus { get; set; }
        [Display(Name = "LE Name")]
        public string LEName { get; set; }
        [Display(Name = "LE Email")]
        public string LEEmail { get; set; }
        [Display(Name = "LE Username")]
        public string LEUserName { get; set; }
        [Display(Name = "LE Status")]
        public string LEStatus { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Created")]
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Updated")]
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class EmployeeAccessData
    {
        public int UserAccessID { get; set; }
        public string UserAccessName { get; set; }

    }

    public class EmployeeValidate
    {
        public string UserName { get; set; }
        public string EmailAddress { get; set; }
    }

    public class EmployeeRegister
    {
        public int EmployeeID { get; set; }

        [Display(Name = "User Access")]
        [Required(ErrorMessage = "Please select atleast one option")]
        public string UserAccess { get; set; }

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

        [Display(Name = "Username")]
        [Required(ErrorMessage = "Username required.")]
        public string UserName { get; set; }

        [Display(Name = "Password")]
        [Required(ErrorMessage = "Password required.")]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [Display(Name = "Confirm Password")]
        [Required(ErrorMessage = "Password required.")]
        [DataType(DataType.Password)]
        [System.ComponentModel.DataAnnotations.Compare("Password", ErrorMessage = "Passwords do not match.")]
        public string ConfirmPassword { get; set; }
    }

    public class JobReassignmentData
    {
        public int rowNumber { get; set; }
        public int TransactionLogID { get; set; }
        [Display(Name = "Job Number:")]
        public string JobNumber { get; set; }
        [Display(Name = "Product:")]
        public string BPSProductID { get; set; }
        [Display(Name = "Service Number:")]
        public int ServiceNumber { get; set; }
        [Display(Name = "Previous Owner:")]
        public string PreviousOwner { get; set; }
        [Display(Name = "Current Owner:")]
        public string CurrentOwner { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Updated:")]
        public DateTime DateUpdated { get; set; }
        [Display(Name = "Updated By:")]
        public string UpdatedBy { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
    }
    public class JobReassignmentDataCoding
    {
        public int rowNumber { get; set; }
        public int TransactionLogID { get; set; }
        public int CoversheetID { get; set; }
        [Display(Name = "Coversheet Number:")]
        public string CoversheetNumber { get; set; }
        [Display(Name = "Task Number:")]
        public string TaskNumber { get; set; }
        [Display(Name = "Product:")]
        public string BPSProductID { get; set; }
        [Display(Name = "Service Number:")]
        public int ServiceNumber { get; set; }
        [Display(Name = "Previous Owner:")]
        public string PreviousOwner { get; set; }
        [Display(Name = "Current Owner:")]
        public string CurrentOwner { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Updated:")]
        public DateTime DateUpdated { get; set; }
        [Display(Name = "Updated By:")]
        public string UpdatedBy { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
    }
}