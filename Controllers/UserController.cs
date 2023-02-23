using System.Linq;
using System.Web.Mvc;
using JobTrack_AUNZ.Models.User;
using System.Web.Security;

namespace JobTrack_AUNZ.Controllers
{
    public class UserController : Controller
    {
        UserModel um = new UserModel();
        private static string _useraccess;
        private static int _id;
        // GET: User
        public ActionResult Index()
        {
            return View();
        }
        [HttpGet]
        public ActionResult Login(string username)
        {
            var row = um.GetUsers().Where(model => model.Username == username).FirstOrDefault();
            return View("Login");
        }
        [HttpPost]
        public ActionResult Login(UserLoginModel ulm)
        {
            if (IsValid(ulm.Username, ulm.Password))
            {
                FormsAuthentication.SetAuthCookie(ulm.Username, false);

                if (_useraccess == "Client(LE)")
                {
                    //LE
                    return RedirectToAction("LEIndex", "LE", new { id = _id });
                }
                else if (_useraccess == "Straive(PE)")
                {
                    //PE
                    return RedirectToAction("PEIndex", "PE", new { id = _id });
                }
                else if (_useraccess == "Coding")
                {
                    //Coding 
                    return RedirectToAction("CodingIndex", "Coding", new { id = _id });
                }
                else if (_useraccess == "Coding(STP)")
                {
                    //STP
                    return RedirectToAction("CodingSTPIndex", "CodingSTP", new { id = _id });
                }

                return RedirectToAction("Index", "Home");
            }
            else
            {
                ModelState.AddModelError("", "Login details are wrong.");
            }
            return View();
        }
        [HttpGet]
        public ActionResult Register()
        {
            this.ViewBag.UserAccess = new SelectList(um.GetUserLevel(), "UserlevelValue", "UserlevelText");
            return View();
        }
        [HttpPost]
        public ActionResult Register(UserRegisterModel urm)
        {
            this.ViewBag.UserAccess = new SelectList(um.GetUserLevel(), "UserlevelValue", "UserlevelText");
            var user = um.GetUsers().FirstOrDefault(u => u.Username == urm.UserName);
            if (user != null)
            {
                ModelState.AddModelError("", "Username exists.");
            } else
            {
                if (ModelState.IsValid)
                {
                    if (um.Register(urm))
                    {
                        return RedirectToAction("Login");
                    }
                }
                else
                {
                    ModelState.AddModelError("", "Data is not correct");
                }
            }

            return View();
        }
        private bool IsValid(string username, string password)
        {
            var crypto = new SimpleCrypto.PBKDF2();
            bool IsValid = false;

            var user = um.GetUsers().FirstOrDefault(model => model.Username == username && model.Password == password);
            if (user != null)
            {
                if (user.Password == password)
                {
                    Session["id"] = user.ID;
                    Session["uid"] = user.Username;
                    Session["uaccess"] = user.UserAccess;

                    _useraccess = user.UserAccess;
                    _id = user.ID;

                    IsValid = true;
                }
            }
            else
            {
                ViewBag.Showmsg = "Invalid Username or Password!  ";
                ModelState.Clear();
            }

            return IsValid;
        }
        public ActionResult LogOut()
        {
            FormsAuthentication.SignOut();
            return RedirectToAction("Login", "User");
        }
    }
}