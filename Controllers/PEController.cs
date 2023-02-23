using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using JobTrack_AUNZ.Models.PE;
using JobTrack_AUNZ.Models;

namespace JobTrack_AUNZ.Controllers
{
    public class PEController : Controller
    {
        PEModel PEModel = new PEModel();
        BaseModel BM = new BaseModel();
        private int int_owner = 0;
        private int int_job = 0;
        // GET: PE
        public ActionResult PEIndex(string page)
        {
            //var row = PEModel.GetPEManusrcipt(0, 0, ((int)Session["id"]));
            var row = PEModel.GetPEManusrcipt(0, 0, 0);
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            return View(row);
        }
        public ActionResult PEManuScript()
        {
            //var row = PEModel.GetPEManusrcipt(0, 0, ((int)Session["id"]));
            var row = PEModel.GetPEManusrcipt(0, 0, 0);
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
            return PartialView(row);
        }
        public ActionResult PESTPIndex(string page)
        {
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            return View();
        }
        public ActionResult PEAllIndex()
        {
            var row = PEModel.GetPEManusrcipt(0, 0, ((int)Session["id"]));
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
            this.ViewBag.View = 1;
            return PartialView(row);
        }
        public ActionResult PEAllManuScript()
        {
            var row = PEModel.GetPEManusrcipt(0, 0, ((int)Session["id"]));
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
            return PartialView(row);
        }
        public ActionResult PartialToView(string page_id)
        {
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            if (page_id == "PEAllJob")
            {

            }
            else if (page_id == "PEMyJob")
            {
                var row = PEModel.GetPEManusrcipt(0, 0, int_owner);
                return PartialView("PEMyJob", row);
            }
            else if (page_id == "PESTP")
            {
                var row = PEModel.GetPEManusrcipt(0, 0, int_owner);
                return PartialView("PESTP", row);
            }
            return PartialView();

        }
        public ActionResult GetPartialView(int selectedItem)
        {
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");


            if (selectedItem.ToString() == "2")
            {
                var row = PEModel.GetPEManusrcipt(0, 0, 0);
                return PartialView("PEManuScript", row);
            }
            else if (selectedItem.ToString() == "3")
            {
                var row = PEModel.GetPECoverSheet(0, 0, 0);
                return PartialView("PECoverSheet", row);
            }
            else if (selectedItem.ToString() == "4")
            {
                var row = PEModel.GetPESTP(0, 0, 1);
                return PartialView("PESTP", row);
            }


            return Content("Your selected value: " + selectedItem.ToString());
        }
        public ActionResult GetPartialViewAll(int selectedItem)
        {
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            if (selectedItem.ToString() == "2")
            {
                var row = PEModel.GetPEManusrcipt(0, 0, 0);
                return PartialView("PEAllManuScript", row);
            }
            else if (selectedItem.ToString() == "3")
            {
                var row = PEModel.GetPECoverSheet(0, 0, 0);
                return PartialView("PEAllCoverSheet", row);
            }
            else if (selectedItem.ToString() == "4")
            {
                var row = PEModel.GetPESTP(0, 0, 0);
                return PartialView("PEAllSTP", row);
            }
            return Content("Your selected value: " + selectedItem.ToString());
        }
        public JsonResult PEUpdateJob(PECoverSheetModel PEC)
        {
            if (PEModel.PEUpdateJob(PEC, 1, 1))
            {
                return Json("Coversheet updated.", JsonRequestBehavior.AllowGet);
            }
            return Json(PEC, JsonRequestBehavior.AllowGet);
        }
        public JsonResult PEUpdateJobStp(PESTPModel pSTP)
        {
            if (PEModel.PEUpdateJobStp(pSTP, 1, 1))
            {
                return Json("STP updated.", JsonRequestBehavior.AllowGet);
            }

            return Json(pSTP, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetTask(PEManuscriptModel PEm)
        {
            var data_task = PEModel.GetSubTaskPEManusrcipt(Convert.ToInt32(PEm.Id));
            var data_product = BM.GetProduct().Where(model => model.product == data_task[0].t_Product).FirstOrDefault();

            data_task[0].t_ChargeCode = data_product.charge_code;
            data_task[0].t_Editor = data_product.editor;

            return Json(data_task, JsonRequestBehavior.AllowGet);
        }
        public JsonResult PEAddTask(PEManuscriptModel PEm)
        {
            var row = PEModel.GetTasksNo().Where(model => model.task_no == "").FirstOrDefault();

            if (row != null)
            {
                return Json("Task No. exists.", JsonRequestBehavior.AllowGet);
            }
            else
            {
                if (PEModel.PEInsertTask(PEm))
                {
                    return Json("Task saved.", JsonRequestBehavior.AllowGet);
                }
            }

            return Json("", JsonRequestBehavior.AllowGet);

        }
        public JsonResult PEAddStp(PESTPCreateModel PEc)
        {
            if (PEModel.PEInsertStp(PEc))
            {
                return Json("STP saved.", JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json("", JsonRequestBehavior.AllowGet);
            }

        }
        public ActionResult PESearchJob(int selectedItem, int product, int service, int uid)
        {
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            if (selectedItem.ToString() == "2")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product).ToList();
                    return PartialView("PEManuScript", row);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PEManuScript", row);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product && model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PEManuScript", row);
                }
                else
                {
                    var row = PEModel.GetPEManusrcipt(0, 0, uid);
                    return PartialView("PEManuScript", row);
                }

            }
            else if (selectedItem.ToString() == "3")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_sc = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product).ToList();
                    return PartialView("PECoverSheet", row_sc);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_sc = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PECoverSheet", row_sc);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_sc = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product && model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PECoverSheet", row_sc);
                }
                else
                {
                    var row_sc = PEModel.GetPECoverSheet(0, 0, uid);
                    return PartialView("PECoverSheet", row_sc);
                }


            }
            else if (selectedItem.ToString() == "4")
            {

                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTP(0, 0, uid).Where(model => model.Product == row_product.product).ToList();
                    return PartialView("PESTP", row_stp);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_stp = PEModel.GetPESTP(0, 0, uid).Where(model => model.Product == row_service.service_no).ToList();
                    return PartialView("PESTP", row_stp);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTP(0, 0, uid).Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("PESTP", row_stp);
                }
                else
                {
                    var row_stp = PEModel.GetPECoverSheet(0, 0, 0);
                    return PartialView("PESTP", row_stp);
                }
            }
            else if (selectedItem.ToString() == "5")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner).Where(model => model.Product == row_product.product).ToList();
                    return PartialView("PESTPList", row_stp);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner).Where(model => model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("PESTPList", row_stp);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner).Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("PESTPList", row_stp);
                }
                else
                {
                    this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
                    this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner);
                    return PartialView("PESTPList", row_stp);
                }

            }

            return Content("Your selected value: " + selectedItem.ToString());
        }
        public ActionResult PEAllSearchJob(int selectedItem, int product, int service, int uid)
        {
            this.ViewBag.JobType = new SelectList(BM.GetJobType(2), "JobType_id", "JobType");
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            if (selectedItem.ToString() == "2")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product).ToList();
                    return PartialView("PEAllManuScript", row);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PEAllManuScript", row);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product && model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PEAllManuScript", row);
                }
                else
                {
                    var row = PEModel.GetPEManusrcipt(0, 0, uid);
                    return PartialView("PEAllManuScript", row);
                }

            }
            else if (selectedItem.ToString() == "3")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_sc = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product).ToList();
                    return PartialView("PEAllCoverSheet", row_sc);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_sc = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PEAllCoverSheet", row_sc);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_sc = PEModel.GetPEManusrcipt(0, 0, uid).Where(model => model.m_Product == row_product.product && model.m_ServiceNo == row_service.service_no).ToList();
                    return PartialView("PEAllCoverSheet", row_sc);
                }
                else
                {
                    var row_sc = PEModel.GetPECoverSheet(0, 0, uid);
                    return PartialView("PEAllCoverSheet", row_sc);
                }


            }
            else if (selectedItem.ToString() == "4")
            {

                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTP(0, 0, uid).Where(model => model.Product == row_product.product).ToList();
                    return PartialView("PEAllSTP", row_stp);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_stp = PEModel.GetPESTP(0, 0, uid).Where(model => model.Product == row_service.service_no).ToList();
                    return PartialView("PEAllSTP", row_stp);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTP(0, 0, uid).Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("PEAllSTP", row_stp);
                }
                else
                {
                    var row_stp = PEModel.GetPECoverSheet(0, 0, 0);
                    return PartialView("PEAllSTP", row_stp);
                }
            }
            else if (selectedItem.ToString() == "5")
            {
                if ((product > 0) && (service <= 0))
                {
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner).Where(model => model.Product == row_product.product).ToList();
                    return PartialView("PESTPList", row_stp);
                }
                else if ((product <= 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner).Where(model => model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("PESTPList", row_stp);
                }
                else if ((product > 0) && (service > 0))
                {
                    var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                    var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner).Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                    return PartialView("PESTPList", row_stp);
                }
                else
                {
                    this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
                    this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
                    var row_stp = PEModel.GetPESTPList(0, 0, int_owner);
                    return PartialView("PESTPList", row_stp);
                }

            }

            return Content("Your selected value: " + selectedItem.ToString());
        }

    }
}