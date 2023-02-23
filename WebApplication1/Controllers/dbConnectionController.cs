using System;
using System.IO;
using System.Net;
using System.Text;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using JobTrack.Models;

namespace JobTrack.Controllers
{
    public class dbConnectionController : Controller
    {
        // CONNECTION STRING
        SqlConnection dbConnection = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConn"].ConnectionString);

        // DECLARE MODEL
        public Models.dbConnection dbConnModel = new Models.dbConnection();

        public ActionResult dbConnView()
        {

            // return RedirectToAction
            return View();
        }

        [HttpPost]
        public JsonResult KeepSessionAlive()
        {
            return new JsonResult { Data = "Success" };
        }
        public ActionResult verifyIfLoggedIn(string user_ID)
        {
            string userID = user_ID;
            userID = Session["EmployeeID"].ToString();

            dbConnection.Open();
            string storedProcName;
            storedProcName = "CHECK_USER_LOGIN";
            using (SqlCommand command = new SqlCommand(storedProcName, dbConnection))
            {
                command.CommandType = System.Data.CommandType.StoredProcedure;

                command.Parameters.AddWithValue("@pEmployeeID", userID);
                SqlDataReader reader = command.ExecuteReader();


                if (reader.HasRows)
                {
                    while (reader.Read())
                    {

                        dbConnModel.LoginDate = reader[1].ToString();
                    }
                }
                else
                {
                    dbConnModel.LoginDate = "";
                }
                reader.Close();

            }
            dbConnection.Close();

            return Json(dbConnModel.LoginDate, JsonRequestBehavior.AllowGet);

        }

        [HttpPost]
        public ActionResult AddLogIn(string user_ID, string Remarks)
        {
            string userID = user_ID;
            userID = Session["EmployeeID"].ToString();

            dbConnection.Open();
            string storedProcName;
            storedProcName = "INSERT_USER_LOGIN";
            using (SqlCommand command = new SqlCommand(storedProcName, dbConnection))
            {
                command.CommandType = System.Data.CommandType.StoredProcedure;

                command.Parameters.AddWithValue("@pUserID", userID);
                command.Parameters.AddWithValue("@pRemarks", Remarks);
                SqlDataReader reader = command.ExecuteReader();


                if (reader.HasRows)
                {
                    while (reader.Read())
                    {

                        dbConnModel.LoginDate = reader[1].ToString();
                    }
                }
                else
                {
                    dbConnModel.LoginDate = "";
                }
                reader.Close();

            }
            dbConnection.Close();

            return Json(dbConnModel.LoginDate, JsonRequestBehavior.AllowGet);
        }

        public ActionResult LogOutUser(string user_ID)
        {
            dbConnModel.listLogOutInfo = new List<logoutInfo>();
            string userID = user_ID;

            try
            {
                userID = Session["EmployeeID"].ToString();


                //userID = 
                dbConnection.Open();
                string storedProcName;
                storedProcName = "USER_LOGOUT";
                using (SqlCommand command = new SqlCommand(storedProcName, dbConnection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@pEmployeeID", userID);
                    SqlDataReader reader = command.ExecuteReader();

                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {

                            dbConnModel.listLogOutInfo.Add(new logoutInfo()
                            {
                                transactionID = reader[0].ToString(),
                                loginDate = reader[1].ToString(),
                                logoutDate = reader[2].ToString(),
                                loginTime = reader[3].ToString()

                            });
                        }
                    }
                    // CLOSE READER
                    reader.Close();

                }
                dbConnection.Close();

                return Json(dbConnModel.listLogOutInfo, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                dbConnModel.listLogOutInfo.Add(new logoutInfo()
                {
                    transactionID = ex.ToString(),
                    loginDate = "error404",
                    logoutDate = "error404",
                    loginTime = "error404"

                });

                return Json(dbConnModel.listLogOutInfo, JsonRequestBehavior.AllowGet);

            }
        }
    }

}