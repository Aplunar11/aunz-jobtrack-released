using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace JobTrack_AUNZ.Models.User
{
    public class UserLoginModel
    {
        public int ID { get; set; }

        [Display(Name = "Username")]
        public string Username { get; set; }

        [Display(Name = "Password")]
        [DataType(DataType.Password)]
        public string Password { get; set; }
        public string PasswordSalt { get; set; }
        public string UserAccess { get; set; }
        public int UserAccess_id { get; set; }
    }
}