using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;

namespace JobTrack.Services
{
    public class AuthenticationWrapper
    {
        //retrieve connection string
        SqlConnection dbConnection = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConn"].ConnectionString);


        //declare properties
        const string EmployeeID_KEY = "EmployeeID";

        public static string EmployeeID
        {
            get { return HttpContext.Current.Session[EmployeeID_KEY] != null ? (string)HttpContext.Current.Session[EmployeeID_KEY] : null; }
            set { HttpContext.Current.Session[EmployeeID_KEY] = value; }
        }

        //const string AccessLevel_KEY = "AccessLevel";
        //public static string AccessLevel
        //{
        //    get { return HttpContext.Current.Session[AccessLevel_KEY] != null ? (string)HttpContext.Current.Session[AccessLevel_KEY] : null; }
        //    set { HttpContext.Current.Session[AccessLevel_KEY] = value; }
        //}

        const string UserName_KEY = "UserName";
        public static string UserName
        {
            get { return HttpContext.Current.Session[UserName_KEY] != null ? (string)HttpContext.Current.Session[UserName_KEY] : null; }
            set { HttpContext.Current.Session[UserName_KEY] = value; }
        }

        const string Password_KEY = "Password";
        public static string Password
        {
            get { return HttpContext.Current.Session[Password_KEY] != null ? (string)HttpContext.Current.Session[Password_KEY] : null; }
            set { HttpContext.Current.Session[Password_KEY] = value; }
        }

        const string FirstName_KEY = "FirstName";
        public static string FirstName
        {
            get { return HttpContext.Current.Session[FirstName_KEY] != null ? (string)HttpContext.Current.Session[FirstName_KEY] : null; }
            set { HttpContext.Current.Session[FirstName_KEY] = value; }
        }
        const string LastName_KEY = "LastName";
        public static string LastName
        {
            get { return HttpContext.Current.Session[LastName_KEY] != null ? (string)HttpContext.Current.Session[LastName_KEY] : null; }
            set { HttpContext.Current.Session[LastName_KEY] = value; }
        }
        const string UserAccess_KEY = "UserAccess";
        public static string UserAccess
        {
            get { return HttpContext.Current.Session[UserAccess_KEY] != null ? (string)HttpContext.Current.Session[UserAccess_KEY] : null; }
            set { HttpContext.Current.Session[UserAccess_KEY] = value; }
        }

        //const string UserImagePath_KEY = "UserImagePath";
        //public static string UserImagePath
        //{
        //    get { return HttpContext.Current.Session[UserImagePath_KEY] != null ? (string)HttpContext.Current.Session[UserImagePath_KEY] : null; }
        //    set { HttpContext.Current.Session[UserImagePath_KEY] = value; }
        //}

        //check ID in database
        public bool IsUserValid(string UserName, string Password)
        {
            var authWrapper = new AuthenticationWrapper();

            dbConnection.Open();

            using (SqlCommand command = new SqlCommand("GetUserByUserName", dbConnection))
            {
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pUserName", UserName);
                command.Parameters.AddWithValue("@pPassword", Password);
                SqlDataReader reader = command.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        AuthenticationWrapper.EmployeeID = reader["EmployeeID"].ToString();
                        AuthenticationWrapper.UserName = UserName;
                        AuthenticationWrapper.Password = Password;
                        AuthenticationWrapper.FirstName = reader["FirstName"].ToString();
                        AuthenticationWrapper.LastName = reader["LastName"].ToString();
                        AuthenticationWrapper.UserAccess = reader["UserAccess"].ToString();
                        //AuthenticationWrapper.UserImagePath = reader["IMAGE PATH"].ToString();
                        //AuthenticationWrapper.AccessLevel = reader["ACCESS LEVEL"].ToString();
                    }
                    reader.Close();
                    dbConnection.Close();
                    return true;
                }
                else
                {
                    AuthenticationWrapper.EmployeeID = "";
                    reader.Close();
                    dbConnection.Close();
                    return false;
                }
            }

        }
    }
}
