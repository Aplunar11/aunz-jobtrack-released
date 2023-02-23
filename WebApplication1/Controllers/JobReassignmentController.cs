using System;
using System.Web.Mvc;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;
using JobTrack.Models.Employee;
using Newtonsoft.Json;
using System.Linq;

namespace JobTrack.Controllers
{
    public class JobReassignmentController : Controller
    {
        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();
        // CONNECTION STRING FOR USER
        public MySqlConnection dbConnection_User = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn_User"].ConnectionString);
        public MySqlCommand cmd_User = new MySqlCommand();
        public MySqlDataAdapter adp_User = new MySqlDataAdapter();

        [HttpGet]
        public ActionResult UpdateJobReassignmentLE(JobReassignmentData mdata)
        {
            try
            {
                TempData["CurrentOwner"] = new SelectList(GetAllLEUsers(), "CurrentOwner", "CurrentOwner", mdata.CurrentOwner);
                //GetJobReassignmentDetails().Where(model => model.ServiceNumber == model.ServiceNumber);
                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }
        public List<Models.Employee.JobReassignmentData> GetAllLEUsers()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllPublicationAssignmentLEUsers", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<Models.Employee.JobReassignmentData> lst = new List<Models.Employee.JobReassignmentData>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new Models.Employee.JobReassignmentData
                {
                    CurrentOwner = Convert.ToString(dr[0])
                });
            }
            dbConnection.Close();
            return lst;
        }
        [HttpGet]
        public ActionResult GetReassignmentDataLE(string bpsproductid,string servicenumber)
        {
            List<JobReassignmentData> lst = new List<JobReassignmentData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllActiveJobDataLELog", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_BPSProductID", bpsproductid);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new JobReassignmentData
                {
                    rowNumber = Convert.ToInt32(dr["rowNumber"].ToString()),
                    TransactionLogID = Convert.ToInt32(dr["TransactionLogID"].ToString()),
                    JobNumber = dr["JobNumber"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = Convert.ToInt32(dr["ServiceNumber"].ToString()),
                    PreviousOwner = dr["ValueBefore"].ToString(),
                    CurrentOwner = dr["ValueAfter"].ToString(),
                    DateUpdated = Convert.ToDateTime(dr["DateCreated"].ToString()),
                    UpdatedBy = dr["UserName"].ToString()
                });
            }
            dbConnection.Close();
            return Json(lst, JsonRequestBehavior.AllowGet);

        }
        [HttpPost]
        public JsonResult UpdateJobReassignmentDataLE(JobReassignmentData mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var Username = Session["UserName"];
                    MySqlCommand com = new MySqlCommand("InsertTransactionLogJobReassignmentLE", dbConnection);
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.AddWithValue("@p_JobNumber", mdata.JobNumber);
                    com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
                    com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
                    com.Parameters.AddWithValue("@p_LEUserName", mdata.CurrentOwner);
                    com.Parameters.AddWithValue("@p_Username", Username);
                    if (dbConnection.State == ConnectionState.Closed)
                        dbConnection.Open();
                    int Count = com.ExecuteNonQuery();

                    if (Count > 0)
                    {
                        mdata.Response = "Y";
                    }
                    else
                    {
                        mdata.Response = "N";
                        mdata.ErrorMessage = "Reassignment data could not be added";
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
        // PE TL
        [HttpGet]
        public ActionResult UpdateJobReassignmentPE(JobReassignmentData mdata)
        {
            try
            {
                TempData["CurrentOwner"] = new SelectList(GetAllPEUsers(), "CurrentOwner", "CurrentOwner", mdata.CurrentOwner);
                //GetJobReassignmentDetails().Where(model => model.ServiceNumber == model.ServiceNumber);
                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }
        public List<Models.Employee.JobReassignmentData> GetAllPEUsers()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllPublicationAssignmentPEUsers", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<Models.Employee.JobReassignmentData> lst = new List<Models.Employee.JobReassignmentData>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new Models.Employee.JobReassignmentData
                {
                    CurrentOwner = Convert.ToString(dr[0])
                });
            }
            dbConnection.Close();
            return lst;
        }
        [HttpGet]
        public ActionResult GetReassignmentDataPE(string bpsproductid, string servicenumber)
        {
            List<JobReassignmentData> lst = new List<JobReassignmentData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllActiveJobDataPELog", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_BPSProductID", bpsproductid);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new JobReassignmentData
                {
                    rowNumber = Convert.ToInt32(dr["rowNumber"].ToString()),
                    TransactionLogID = Convert.ToInt32(dr["TransactionLogID"].ToString()),
                    JobNumber = dr["JobNumber"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = Convert.ToInt32(dr["ServiceNumber"].ToString()),
                    PreviousOwner = dr["ValueBefore"].ToString(),
                    CurrentOwner = dr["ValueAfter"].ToString(),
                    DateUpdated = Convert.ToDateTime(dr["DateCreated"].ToString()),
                    UpdatedBy = dr["UserName"].ToString()
                });
            }
            dbConnection.Close();
            return Json(lst, JsonRequestBehavior.AllowGet);

        }
        [HttpPost]
        public JsonResult UpdateJobReassignmentDataPE(JobReassignmentData mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var Username = Session["UserName"];
                    MySqlCommand com = new MySqlCommand("InsertTransactionLogJobReassignmentPE", dbConnection);
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.AddWithValue("@p_JobNumber", mdata.JobNumber);
                    com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
                    com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
                    com.Parameters.AddWithValue("@p_PEUserName", mdata.CurrentOwner);
                    com.Parameters.AddWithValue("@p_Username", Username);
                    if (dbConnection.State == ConnectionState.Closed)
                        dbConnection.Open();
                    int Count = com.ExecuteNonQuery();

                    if (Count > 0)
                    {
                        mdata.Response = "Y";
                    }
                    else
                    {
                        mdata.Response = "N";
                        mdata.ErrorMessage = "Reassignment data could not be added";
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
        //Coding TL
        [HttpGet]
        public ActionResult UpdateJobReassignmentCoding(JobReassignmentDataCoding mdata)
        {
            try
            {
                TempData["CurrentOwner"] = new SelectList(GetAllUser().Where(model => model.UserAccessName == "Coding"), "UserName", "UserName", mdata.CurrentOwner);
                //GetJobReassignmentDetails().Where(model => model.ServiceNumber == model.ServiceNumber);
                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }
        public List<EmployeeData> GetAllUser()
        {
            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            DataTable dt = new DataTable();

            cmd_User = new MySqlCommand("GetAllEmployee", dbConnection_User);
            cmd_User.CommandType = CommandType.StoredProcedure;
            adp_User = new MySqlDataAdapter(cmd_User);
            adp_User.Fill(dt);

            List<Models.Employee.EmployeeData> lst = new List<Models.Employee.EmployeeData>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new Models.Employee.EmployeeData
                {
                    EmployeeID = Convert.ToInt32(dr[0]),
                    UserAccessName = Convert.ToString(dr[1]),
                    UserName = Convert.ToString(dr[3]),
                    FullName = Convert.ToString(dr[6]),
                    EmailAddress = Convert.ToString(dr[7])
                });
            }
            dbConnection_User.Close();
            return lst;
        }
        [HttpGet]
        public ActionResult GetReassignmentDataCoding(string bpsproductid, string servicenumber, int coversheetID)
        {
            List<JobReassignmentDataCoding> lst = new List<JobReassignmentDataCoding>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllActiveJobDataCodingLog", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_CoversheetID", coversheetID);
            cmd.Parameters.AddWithValue("@p_BPSProductID", bpsproductid);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new JobReassignmentDataCoding
                {
                    rowNumber = Convert.ToInt32(dr["rowNumber"].ToString()),
                    TransactionLogID = Convert.ToInt32(dr["TransactionLogID"].ToString()),
                    CoversheetID = Convert.ToInt32(dr["CoversheetID"].ToString()),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = Convert.ToInt32(dr["ServiceNumber"].ToString()),
                    PreviousOwner = dr["ValueBefore"].ToString(),
                    CurrentOwner = dr["ValueAfter"].ToString(),
                    DateUpdated = Convert.ToDateTime(dr["DateCreated"].ToString()),
                    UpdatedBy = dr["UserName"].ToString()
                });
            }
            dbConnection.Close();
            return Json(lst, JsonRequestBehavior.AllowGet);

        }
        [HttpPost]
        public JsonResult UpdateJobReassignmentDataCoding(JobReassignmentDataCoding mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var Username = Session["UserName"];
                    MySqlCommand com = new MySqlCommand("InsertTransactionLogJobReassignmentCoding", dbConnection);
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.AddWithValue("@p_CoversheetID", mdata.CoversheetID);
                    com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
                    com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
                    com.Parameters.AddWithValue("@p_CodingUserName", mdata.CurrentOwner);
                    com.Parameters.AddWithValue("@p_Username", Username);
                    if (dbConnection.State == ConnectionState.Closed)
                        dbConnection.Open();
                    int Count = com.ExecuteNonQuery();

                    if (Count > 0)
                    {
                        mdata.Response = "Y";
                    }
                    else
                    {
                        mdata.Response = "N";
                        mdata.ErrorMessage = "Reassignment data could not be added";
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
    }
}