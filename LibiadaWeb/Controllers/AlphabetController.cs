﻿using System.Data;
using System.Linq;
using System.Web.Mvc;

namespace LibiadaWeb.Controllers
{ 
    public class AlphabetController : Controller
    {
        private readonly LibiadaWebEntities db = new LibiadaWebEntities();

        //
        // GET: /Alphabet/

        public ActionResult Index()
        {
            var alphabet = db.alphabet.Include("chain").Include("element");
            return View(alphabet.ToList());
        }

        //
        // GET: /Alphabet/Details/5

        public ActionResult Details(long id)
        {
            alphabet alphabet = db.alphabet.Single(a => a.chain_id == id);
            if (alphabet == null)
            {
                return HttpNotFound();
            }
            return View(alphabet);
        }

        //
        // GET: /Alphabet/Create

        public ActionResult Create()
        {
            ViewBag.chain_id = new SelectList(db.chain, "id", "building");
            ViewBag.element_id = new SelectList(db.element, "id", "value");
            return View();
        }

        //
        // POST: /Alphabet/Create

        [HttpPost]
        public ActionResult Create(alphabet alphabet)
        {
            if (ModelState.IsValid)
            {
                db.alphabet.AddObject(alphabet);
                db.SaveChanges();
                return RedirectToAction("Index");  
            }

            ViewBag.chain_id = new SelectList(db.chain, "id", "building", alphabet.chain_id);
            ViewBag.element_id = new SelectList(db.element, "id", "value", alphabet.element_id);
            return View(alphabet);
        }
        
        //
        // GET: /Alphabet/Edit/5
 
        public ActionResult Edit(long id)
        {
            alphabet alphabet = db.alphabet.Single(a => a.chain_id == id);
            if (alphabet == null)
            {
                return HttpNotFound();
            }
            ViewBag.chain_id = new SelectList(db.chain, "id", "building", alphabet.chain_id);
            ViewBag.element_id = new SelectList(db.element, "id", "value", alphabet.element_id);
            return View(alphabet);
        }

        //
        // POST: /Alphabet/Edit/5

        [HttpPost]
        public ActionResult Edit(alphabet alphabet)
        {
            if (ModelState.IsValid)
            {
                db.alphabet.Attach(alphabet);
                db.ObjectStateManager.ChangeObjectState(alphabet, EntityState.Modified);
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.chain_id = new SelectList(db.chain, "id", "building", alphabet.chain_id);
            ViewBag.element_id = new SelectList(db.element, "id", "value", alphabet.element_id);
            return View(alphabet);
        }

        //
        // GET: /Alphabet/Delete/5
 
        public ActionResult Delete(long id)
        {
            alphabet alphabet = db.alphabet.Single(a => a.chain_id == id);
            if (alphabet == null)
            {
                return HttpNotFound();
            }
            return View(alphabet);
        }

        //
        // POST: /Alphabet/Delete/5

        [HttpPost, ActionName("Delete")]
        public ActionResult DeleteConfirmed(long id)
        {            
            alphabet alphabet = db.alphabet.Single(a => a.chain_id == id);
            db.alphabet.DeleteObject(alphabet);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            db.Dispose();
            base.Dispose(disposing);
        }
    }
}