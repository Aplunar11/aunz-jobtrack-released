using System;
using System.Web.Mvc;
using System.Collections.Generic;
using JobTrack.Models.Employee;
using JobTrack.Models.Admin;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;
using System.Linq;
using System.Net.Mail;
using System.Net;

namespace JobTrack.Controllers
{
    public class AdminController : Controller
    {
        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        // CONNECTION STRING FOR USER
        public MySqlConnection dbConnection_User = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn_User"].ConnectionString);
        public MySqlCommand cmd_User = new MySqlCommand();
        public MySqlDataAdapter adp_User = new MySqlDataAdapter();

        public ActionResult TopMenu()
        {
            return PartialView("_Topbar");
        }

        public ActionResult SideMenu()
        {
            return PartialView("_SidebarAdmin");
        }
        public ActionResult AllJob()
        {
            #region Check Session
            if (Session["UserName"] == null)
            {
                TempData["alertMessage"] = "You must log in to continue";
                return RedirectToAction("Login", "Login");
            }
            #endregion
            return View();
        }
        public ActionResult Employees()
        {
            #region Check Session
            if (Session["UserName"] == null)
            {
                TempData["alertMessage"] = "You must log in to continue";
                return RedirectToAction("Login", "Login");
            }
            #endregion
            return View();
        }
        public ActionResult ProductDatabase()
        {
            #region Check Session
            if (Session["UserName"] == null)
            {
                TempData["alertMessage"] = "You must log in to continue";
                return RedirectToAction("Login", "Login");
            }
            #endregion
            return View();
        }

        public ActionResult GetEmployeeData()
        {
            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            List<EmployeeData> mdata = new List<EmployeeData>();
            DataTable dt = new DataTable();

            cmd_User = new MySqlCommand("GetAllEmployee", dbConnection_User);
            cmd_User.CommandType = CommandType.StoredProcedure;
            cmd_User.Parameters.Clear();
            adp_User = new MySqlDataAdapter(cmd_User);
            adp_User.Fill(dt);
            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new EmployeeData
                {


                    EmployeeID = Convert.ToInt32(dr["EmployeeID"].ToString()),
                    UserAccessName = dr["UserAccessName"].ToString(),
                    Status = dr["Status"].ToString(),
                    UserName = dr["UserName"].ToString(),
                    FirstName = dr["FirstName"].ToString(),
                    LastName = dr["LastName"].ToString(),
                    FullName = dr["FullName"].ToString(),
                    EmailAddress = dr["EmailAddress"].ToString(),
                    MobileNumber = dr["MobileNumber"].ToString(),
                    IsManager = Convert.ToBoolean(Convert.ToInt32(dr["IsManager"])),
                    IsEditorialContact = Convert.ToBoolean(Convert.ToInt32(dr["IsEditorialContact"])),
                    IsEmailList = Convert.ToBoolean(Convert.ToInt32(dr["IsEmailList"])),
                    IsMandatoryRecepient = Convert.ToBoolean(Convert.ToInt32(dr["IsMandatoryRecepient"])),
                    IsShowUser = Convert.ToBoolean(Convert.ToInt32(dr["IsShowUser"])),
                    DateCreated = Convert.ToDateTime(dr["DateCreated"]),
                    PasswordUpdate = dr.Field<DateTime?>("PasswordUpdate")

                });
            }
            dbConnection_User.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult EditEmployeeData(int employeeid, string username)
        {
            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            EmployeeData mdata = new EmployeeData();
            try
            {
                DataTable dt = new DataTable();

                cmd_User = new MySqlCommand("GetEmployeeByUserName", dbConnection_User);
                cmd_User.CommandType = CommandType.StoredProcedure;

                cmd_User.Parameters.Clear();
                cmd_User.Parameters.AddWithValue("@p_EmployeeID", employeeid);
                cmd_User.Parameters.AddWithValue("@p_UserName", username);
                adp_User = new MySqlDataAdapter(cmd_User);
                adp_User.Fill(dt);

                foreach (DataRow dr in dt.Rows)
                {
                    mdata.EmployeeID = Convert.ToInt32(dr["EmployeeID"].ToString());
                    mdata.UserAccessName = dr["UserAccessName"].ToString();
                    mdata.Status = dr["Status"].ToString();
                    mdata.UserName = dr["UserName"].ToString();
                    mdata.FirstName = dr["FirstName"].ToString();
                    mdata.LastName = dr["LastName"].ToString();
                    mdata.FullName = dr["FullName"].ToString();
                    mdata.EmailAddress = dr["EmailAddress"].ToString();
                    mdata.MobileNumber = dr["MobileNumber"].ToString();
                    mdata.IsManager = Convert.ToBoolean(Convert.ToInt32(dr["IsManager"]));
                    mdata.IsEditorialContact = Convert.ToBoolean(Convert.ToInt32(dr["IsEditorialContact"]));
                    mdata.IsEmailList = Convert.ToBoolean(Convert.ToInt32(dr["IsEmailList"]));
                    mdata.IsMandatoryRecepient = Convert.ToBoolean(Convert.ToInt32(dr["IsMandatoryRecepient"]));
                    mdata.IsShowUser = Convert.ToBoolean(Convert.ToInt32(dr["IsShowUser"]));
                    mdata.DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString());
                    mdata.PasswordUpdate = Convert.ToDateTime(dr["PasswordUpdate"].ToString());

                }
                dbConnection_User.Close();
                return PartialView(mdata);
            }



            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                dbConnection_User.Close();
                return PartialView(mdata);
            }
        }

        public ActionResult AddNewEmployee()
        {
            EmployeeData mdata = new EmployeeData();
            try
            {
                TempData["UserAccess"] = new SelectList(GetAllUserAccess(), "UserAccessID", "UserAccessName");
                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }

        public ActionResult GetPublicationAssignmentData()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<PublicationAssignmentData> mdata = new List<PublicationAssignmentData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllPublicationAssignmentData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);
            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new PublicationAssignmentData
                {


                    PublicationAssignmentID = Convert.ToInt32(dr["PublicationAssignmentID"].ToString()),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    CompleteNameOfPublication = dr["CompleteNameOfPublication"].ToString(),
                    PublicationTier = dr["PublicationTier"].ToString(),
                    PEName = dr["PEName"].ToString(),
                    PEEmail = dr["PEEmail"].ToString(),
                    PEUserName = dr["PEUserName"].ToString(),
                    PEStatus = dr["PEStatus"].ToString(),
                    LEName = dr["LEName"].ToString(),
                    LEEmail = dr["LEEmail"].ToString(),
                    LEUserName = dr["LEUserName"].ToString(),
                    LEStatus = dr["LEStatus"].ToString(),
                    DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString()),
                    DateUpdated = Convert.ToDateTime(dr["DateUpdated"].ToString())

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetProductDatabase()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<ProductDatabaseData> mdata = new List<ProductDatabaseData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllPubSched_MT", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new ProductDatabaseData
                {


                    PubSchedID = Convert.ToInt32(dr["PubSchedID"].ToString()),
                    isSPI = Convert.ToBoolean(Convert.ToInt32(dr["isSPI"])),
                    OrderNumber = Convert.ToInt32(dr["OrderNumber"].ToString()),
                    BudgetPressMonth = dr["BudgetPressMonth"].ToString(),
                    PubSchedTier = dr["PubSchedTier"].ToString(),
                    PubSchedTeam = dr["PubSchedTeam"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    LegalEditor = dr["LegalEditor"].ToString(),
                    ChargeType = dr["ChargeType"].ToString(),
                    ProductChargeCode = dr["ProductChargeCode"].ToString(),
                    BPSProductIDMaster = dr["BPSProductIDMaster"].ToString(),
                    BPSSublist = dr["BPSSublist"].ToString(),
                    ServiceUpdate = dr["ServiceUpdate"].ToString(),
                    //LastManuscriptHandover = Convert.ToDateTime(dr["LastManuscriptHandover"].ToString()),
                    BudgetPressDate = dr.Field<DateTime?>("BudgetPressDate"),
                    RevisedPressDate = dr.Field<DateTime?>("RevisedPressDate"),
                    ReasonForRevisedPressDate = dr["ReasonForRevisedPressDate"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    ForecastPages = Convert.ToInt32(dr["ForecastPages"].ToString()),
                    ActualPages = Convert.ToInt32(dr["ActualPages"].ToString()),
                    DataFromLE = dr.Field<DateTime?>("DataFromLE"),
                    DataFromLEG = dr.Field<DateTime?>("DataFromLEG"),
                    DataFromCoding = dr.Field<DateTime?>("DataFromCoding"),
                    isReceived = Convert.ToBoolean(Convert.ToInt32(dr["isReceived"])),
                    isCompleted = Convert.ToBoolean(Convert.ToInt32(dr["isCompleted"])),
                    //AheadOnTime = Convert.ToInt32(dr["AheadOnTime"].ToString()),
                    WithRevisedPressDate = Convert.ToBoolean(Convert.ToInt32(dr["WithRevisedPressDate"])),
                    ActualPressDate = dr.Field<DateTime?>("ActualPressDate"),
                    ServiceAndBPSProductID = dr["ServiceAndBPSProductID"].ToString(),
                    PubSchedRemarks = dr["PubSchedRemarks"].ToString(),
                    YearAdded = dr["YearAdded"].ToString(),
                    DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString()),
                    DateUpdated = Convert.ToDateTime(dr["DateUpdated"].ToString())
                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }

        public List<Models.Employee.EmployeeAccessData> GetAllUserAccess()
        {
            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            DataTable dt = new DataTable();

            cmd_User = new MySqlCommand("GetAllUserAccess", dbConnection_User);
            cmd_User.CommandType = CommandType.StoredProcedure;
            adp_User = new MySqlDataAdapter(cmd_User);
            adp_User.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<Models.Employee.EmployeeAccessData> lst = new List<Models.Employee.EmployeeAccessData>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new Models.Employee.EmployeeAccessData
                {
                    UserAccessID = Convert.ToInt32(dr[0]),
                    UserAccessName = Convert.ToString(dr[1])
                });
            }
            dbConnection_User.Close();
            return lst;
        }

        [HttpPost]
        public JsonResult AddNewEmployee(EmployeeData mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {

                    var result = IsEmployeeExists(mdata.UserName);

                    if (result != null)
                    {
                        mdata.Response = "N";
                        mdata.ErrorMessage = "UserName already exist, please choose another";
                    }
                    else
                    {

                        var Username = Session["UserName"];
                        MySqlCommand com_User = new MySqlCommand("InsertEmployee", dbConnection_User);
                        com_User.CommandType = CommandType.StoredProcedure;
                        com_User.Parameters.AddWithValue("@p_UserCreated", Username);
                        com_User.Parameters.AddWithValue("@p_UserAccessName", mdata.UserAccessName);
                        com_User.Parameters.AddWithValue("@p_UserName", mdata.UserName);
                        com_User.Parameters.AddWithValue("@p_Password", Base64Encode(mdata.UserName));
                        com_User.Parameters.AddWithValue("@p_ConfirmPassword", Base64Encode(mdata.UserName));
                        com_User.Parameters.AddWithValue("@p_FirstName", mdata.FirstName);
                        com_User.Parameters.AddWithValue("@p_LastName", mdata.LastName);
                        com_User.Parameters.AddWithValue("@p_FullName", (mdata.LastName + ", " + mdata.FirstName));
                        com_User.Parameters.AddWithValue("@p_EmailAddress", mdata.EmailAddress);
                        com_User.Parameters.AddWithValue("@p_MobileNumber", mdata.MobileNumber);
                        com_User.Parameters.AddWithValue("@p_IsManager", mdata.IsManager);
                        com_User.Parameters.AddWithValue("@p_IsEditorialContact", mdata.IsEditorialContact);
                        com_User.Parameters.AddWithValue("@p_IsEmailList", mdata.IsEmailList);
                        com_User.Parameters.AddWithValue("@p_IsMandatoryRecepient", mdata.IsMandatoryRecepient);
                        com_User.Parameters.AddWithValue("@p_IsShowUser", mdata.IsShowUser);
                        com_User.Parameters.AddWithValue("@p_Status", mdata.Status);
                        if (dbConnection_User.State == ConnectionState.Closed)
                            dbConnection_User.Open();
                        int Count = com_User.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.Response = "Y";
                            SendNewEmployeeEmail(mdata);
                        }
                        else
                        {
                            mdata.Response = "N";
                            mdata.ErrorMessage = "Employee data could not be added";
                        }

                    }

                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.Response = "N";
                            mdata.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;

                            //return Json(new { success = false, responseText = "registration failed, please check", JsonRequestBehavior.AllowGet);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.Response = "N";
                mdata.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }

        public EmployeeData IsEmployeeExists(string username)
        {
            try
            {
                var employee = GetEmployeeDetails().FirstOrDefault(model => model.UserName.ToUpper() == username.ToUpper());
                return employee;
            }
            catch (Exception)
            {

                throw;
            }
        }
        public List<EmployeeData> GetEmployeeDetails()
        {
            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            List<EmployeeData> mdata = new List<EmployeeData>();
            DataTable dt = new DataTable();

            cmd_User = new MySqlCommand("GetAllEmployee", dbConnection_User);
            cmd_User.CommandType = CommandType.StoredProcedure;
            adp_User = new MySqlDataAdapter(cmd_User);
            adp_User.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new EmployeeData
                {
                    EmployeeID = Convert.ToInt32(dr[0]),
                    UserName = Convert.ToString(dr[1])
                });
            }
            dbConnection_User.Close();
            return mdata;
        }
        public static string Base64Encode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }
        public static string Base64Decode(string base64EncodedData)
        {
            var base64EncodedBytes = System.Convert.FromBase64String(base64EncodedData);
            return System.Text.Encoding.UTF8.GetString(base64EncodedBytes);
        }

        public void SendNewEmployeeEmail(EmployeeData mdata)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (var mail = new MailMessage())
                    {
                        //const string password = "2544Joey9067!";


                        mail.From = new MailAddress("JobTrack_AUNZ-NoReply@spi-global.com", "JobTrack_AUNZ-NoReply@spi-global.com");
                        mail.To.Add(new MailAddress(mdata.EmailAddress));
                        mail.CC.Add(new MailAddress("jeffrey.danque@spi-global.com"));
                        mail.CC.Add(new MailAddress("mark.mendoza@straive.com"));
                        mail.CC.Add(new MailAddress("katherine.masangkay@straive.com"));
                        mail.Subject = "[JobTrack AUNZ] New Employee registration";

                        string body = "<div>" +
                        "<table border=0 cellspacing=1 cellpadding=0 width='100%'" +
                        "style='width:100.0%;mso-cellspacing:.7pt;mso-padding-alt:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<tr>" +
                        "<td valign=top style='background:whitesmoke;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'>JobTrack AUNZ Employee Data</span>" +
                        "</b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'></span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Date Created: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + DateTime.Now.ToString("yyyy-MM-dd") + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Created By : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + Session["UserName"] + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> User Name : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.UserName + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> User Access : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.UserAccessName + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Full Name : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.LastName + ", " + mdata.FirstName + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Email Address : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.EmailAddress + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Mobile Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.MobileNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Manager? : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.IsManager + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Editorial Contact? :</span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.IsEditorialContact + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Email List? : </span>" +
                        "</b>" +
                        "<span>" +
                        "<span style='font-size:8.0pt;font-family: Verdana'> " + mdata.IsEmailList + " </span>" +
                        "</span>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Mandatory Receipient? : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.IsMandatoryRecepient + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Show User? : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.IsShowUser + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Status : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.Status + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                            "<tr>" +
                            "<td width=581 style='width:435.8pt;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                            "<p>" +
                            "<span style='font-size:7.0pt;font-family:Verdana'> This is an auto-generated e-mail. No need to reply to this e-mail. </span>" +
                            "</p>" +
                            "</td>" +
                            "</tr>" +
                            "<tr>" +
                            "<td width=581 style='width:435.8pt;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                            "<p>" +
                            "<span style='font-size:7.0pt;font-family:Verdana'> The content of this e-mail message may be privileged and confidential." +
                            "Therefore, if this message has been received in error, please delete it without reading it." +
                            "Your receipt of this message is not intended to waive any applicable privilege." +
                            "Please do not disseminate this message without the permission of the author </span>" +
                            "</p>" +
                            "</td>" +
                            "</tr>" +
                            "</table>" +
                            "</div>";

                        mail.Body = body;
                        mail.IsBodyHtml = true;

                        try
                        {
                            //comment for local
                            //using (var smtpClient = new SmtpClient("smtp.gmail.com", 587))
                            //{
                            //    smtpClient.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
                            //    smtpClient.EnableSsl = true;
                            //    smtpClient.UseDefaultCredentials = false;
                            //    smtpClient.Credentials = new NetworkCredential("jeffrey.b.danque@gmail.com", "xqksmfjgdwjrhqds");


                            //    smtpClient.Send(mail);
                            //}
                            //comment for live
                            SmtpClient objSmtp = new SmtpClient(ConfigurationManager.AppSettings["smtp_server"].ToString());

                            mail.DeliveryNotificationOptions =
                               DeliveryNotificationOptions.OnSuccess |
                               DeliveryNotificationOptions.OnFailure |
                               DeliveryNotificationOptions.Delay;

                            //SmtpClient objSmtp = new SmtpClient("MySMPTHost");
                            //objSmtp.DeliveryMethod = SmtpDeliveryMethod.SpecifiedPickupDirectory;
                            objSmtp.Timeout = 30000;

                            objSmtp.Send(mail);
                        }

                        finally
                        {
                            //dispose the client
                            mail.Dispose();
                        }

                    }
                }
                catch (SmtpFailedRecipientsException ex)
                {
                    foreach (SmtpFailedRecipientException t in ex.InnerExceptions)
                    {
                        var status = t.StatusCode;
                        if (status == SmtpStatusCode.MailboxBusy ||
                            status == SmtpStatusCode.MailboxUnavailable)
                        {
                            Response.Write("Delivery failed - retrying in 5 seconds.");
                            System.Threading.Thread.Sleep(5000);
                            //resend
                            //smtpClient.Send(message);
                        }
                        else
                        {
                            //Response.Write("Failed to deliver message to {0}",
                            //                  t.FailedRecipient);
                        }
                    }
                }
                catch (SmtpException Se)
                {
                    // handle exception here
                    Response.Write(Se.ToString());
                }

                catch (Exception ex)
                {
                    Response.Write(ex.ToString());
                }
            }
        }
    }
}