using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using JobTrack_AUNZ.Models.LE;
using JobTrack_AUNZ.Models;

namespace JobTrack_AUNZ.Controllers
{
    public class LEController : Controller
    {
        LEModel LEModel = new LEModel();
        BaseModel bm = new BaseModel();
        // GET: LE
        public ActionResult LEIndex()
        {
            var row = LEModel.GetLEManusrcipt(((int)Session["id"]),0 );
            this.ViewBag.UpdateType = new SelectList(bm.GetUpdateType(), "UpdateType_id", "UpdateType");

            this.ViewBag.Product = new SelectList(bm.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(bm.GetService(), "service_id", "service_no");

            return View(row);
        }
        public PartialViewResult LEManuscriptLevel()
        {
            var row = LEModel.GetLEManusrcipt(((int)Session["id"]), 0);
            return PartialView("LEManuscriptLevel");
        }
        public JsonResult LEUpdateJob(LEManuscriptModel LEm)
        {
            if (LEModel.LEUpdateJob(LEm, 1,1))
            {
                return Json("Job Updated", JsonRequestBehavior.AllowGet);
            }

            return Json(LEm, JsonRequestBehavior.AllowGet);
        }
        public ActionResult LESearchJob(int selectedItem, int product, int service, int uid)
        {
            this.ViewBag.UpdateType = new SelectList(bm.GetUpdateType(), "UpdateType_id", "UpdateType");
            this.ViewBag.Product = new SelectList(bm.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(bm.GetService(), "service_id", "service_no");

            if (selectedItem.ToString() == "2")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_manu = LEModel.GetLEManusrcipt(0, 0).Where(model => model.m_Product == row_product.product).ToList();

                    return PartialView("LEAllManuScript", row_manu);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_manu = LEModel.GetLEManusrcipt(0, 0).Where(model => model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("LEAllManuScript", row_manu);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_manu = LEModel.GetLEManusrcipt(0, 0).Where(model => model.m_Product == row_product.product && model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("LEAllManuScript", row_manu);
                }
                else
                {
                    var row_manu = LEModel.GetLEManusrcipt(0, 0);
                    return PartialView("LEAllManuScript", row_manu);
                }

            }
            else if (selectedItem.ToString() == "3")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_sc = LEModel.GetLECoverSheet(0, 0, 0).Where(model => model.Product == row_product.product).ToList();
                    return PartialView("LEAllCoverSheet", row_sc);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_sc = LEModel.GetLECoverSheet(0, 0, 0).Where(model => model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("LEAllCoverSheet", row_sc);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_sc = LEModel.GetLECoverSheet(0, 0, 0).Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("LEAllCoverSheet", row_sc);
                }
                else
                {
                    var row_sc = LEModel.GetLECoverSheet(0, 0, 0);
                    return PartialView("LEAllCoverSheet", row_sc);
                }


            }
            else if (selectedItem.ToString() == "4")
            {

                if ((product > 0) && (service <= 0))
                {
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = LEModel.GetLESTP(0, 0, 0).Where(model => model.Product == row_product.product).ToList();
                    return PartialView("LEAllSTP", row_stp);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_stp = LEModel.GetLESTP(0, 0, 0).Where(model => model.Product == row_service.service_no).ToList();
                    return PartialView("LEAllSTP", row_stp);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = LEModel.GetLESTP(0, 0, 0).Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("LEAllSTP", row_stp);
                }
                else
                {
                    var row_stp = LEModel.GetLESTP(0, 0, 0);
                    return PartialView("LEAllSTP", row_stp);
                }
            }
            else if (selectedItem.ToString() == "5")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_manu = LEModel.GetLEManusrcipt(uid, 0).Where(model => model.m_Product == row_product.product).ToList();
                    return PartialView("LEManuscriptLevel", row_manu);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_manu = LEModel.GetLEManusrcipt(uid, 0).Where(model => model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("LEManuscriptLevel", row_manu);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = bm.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = bm.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_manu = LEModel.GetLEManusrcipt(uid, 0).Where(model => model.m_Product == row_product.product && model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("LEManuscriptLevel", row_manu);
                }
                else
                {
                    var row_manu = LEModel.GetLEManusrcipt(uid, 0);
                    return PartialView("LEManuscriptLevel", row_manu);
                }
            }

            return Content("Your selected value: " + selectedItem.ToString());
        }
        public ActionResult GetTasks(int selectedItem)
        {
            var data = bm.GetUpdateType().Where(model => model.UpdateType_id == selectedItem).FirstOrDefault();

            return Json(data.TaskType, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetCopyedit(int selectedItem)
        {
            var data = bm.GetUpdateType().Where(model => model.UpdateType_id == selectedItem).FirstOrDefault();
            DateTime d = DateTime.Now.AddDays(data.CopyEdit);
            return Json(d.ToString("dd/MM/yyyy"), JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetCoding(int selectedItem)
        {
            var data = bm.GetUpdateType().Where(model => model.UpdateType_id == selectedItem).FirstOrDefault();
            DateTime d = DateTime.Now.AddDays(data.CopyEdit);
            return Json(d.ToString("dd/MM/yyyy"), JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetOnline(int selectedItem)
        {
            var data = bm.GetUpdateType().Where(model => model.UpdateType_id == selectedItem).FirstOrDefault();
            DateTime d = DateTime.Now.AddDays(data.Online);
            return Json(d.ToString("dd/MM/yyyy"), JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult LEAddJob(LECreateJobModel LEc)
        {
            var row_product = bm.GetProduct().Where(model => model.product_id == LEc.Product_id).FirstOrDefault();
            var row_update = bm.GetUpdateType().Where(model => model.UpdateType_id == LEc.UpdateType_id).FirstOrDefault();

            LEc.UpdateType = row_update.UpdateType;
            LEc.Product = row_product.product;
            if (LEModel.LEAddJob(LEc, ((int)Session["id"]), 1))
            {
                return Json("", JsonRequestBehavior.AllowGet);
            }

            return Json("error", JsonRequestBehavior.AllowGet);


        }
        public ActionResult LEDashboard()
        {
            return View();
        }
        public ActionResult LEAllIndex()
        {
            var row = LEModel.GetLEManusrcipt(1, 1);
            this.ViewBag.Product = new SelectList(bm.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(bm.GetService(), "service_id", "service_no");

            return View(row);
        }
        public ActionResult LEAllManuScript()
        {
            var row = LEModel.GetLEManusrcipt(1, 1);
            this.ViewBag.Product = new SelectList(bm.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(bm.GetService(), "service_id", "service_no");
            return PartialView(row);
        }
        public ActionResult GetPartialView(int selectedItem)
        {
            this.ViewBag.Product = new SelectList(bm.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(bm.GetService(), "service_id", "service_no");

            if (selectedItem.ToString() == "2")
            {
                var row = LEModel.GetLEManusrcipt(0, 0);
                return PartialView("LEAllManuScript", row);
            }
            else if (selectedItem.ToString() == "3")
            {
                var row = LEModel.GetLECoverSheet(0, 0, 0);
                return PartialView("LEAllCoverSheet", row);
            }
            else if (selectedItem.ToString() == "4")
            {
                var row = LEModel.GetLESTP(0, 0, 0);
                return PartialView("LEAllSTP", row);
            }
            return Content("Your selected value: " + selectedItem.ToString());
        }
        public ActionResult GetPartialQuery(int selectedItem)
        {
            return RedirectToAction("QueryIndex", "Query", new { id = selectedItem });
          
        }

    }
}