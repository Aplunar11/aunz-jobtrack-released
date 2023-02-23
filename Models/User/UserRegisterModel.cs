using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace JobTrack_AUNZ.Models.User
{
    public class UserRegisterModel
    {
        public int ProjectID { get; set; }
        public int ID { get; set; }

        [Display(Name = "First Name")]
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

        [Display(Name = "User level")]
        [Required(ErrorMessage = "Please select atleast one option")]
        public string UserLevel { get; set; }
        public IEnumerable<SelectListItem> GetUserLevel { get; set; }


        //[Display(Name = "Poject")]
        //[Required(ErrorMessage = "Please select atleast one option")]
        //public string Project { get; set; }
        //public IEnumerable<SelectListItem> GetProject { get; set; }


        [Display(Name = "Manager")]
        public bool BoolManager { get; set; }

        [Display(Name = "Editorial Contact")]
        public bool BoolEditorialContact { get; set; }

        [Display(Name = "Email List")]
        public bool BoolEmailList { get; set; }

        [Display(Name = "Mandatory Recipient")]
        public bool BoolMandatoryRecipient { get; set; }

        public int UserlevelValue { get; set; }
        public string UserlevelText { get; set; }
    }
}