﻿using System;
using System.Linq;
using System.Web.Mvc;
using LibiadaCore.Classes.Root;
using LibiadaCore.Classes.Root.SimpleTypes;
using LibiadaCore.Classes.TheoryOfSet;
using LibiadaWeb.Models;
using PhantomChains.Classes.PhantomChains;

namespace LibiadaWeb.Controllers
{
    public class TransformationController : Controller
    {
        private readonly LibiadaWebEntities db = new LibiadaWebEntities();
        private readonly ChainRepository chainRepository;

        public TransformationController()
        {
            chainRepository = new ChainRepository(db);
        }

        //
        // GET: /Transformation/

        public ActionResult Index()
        {
            ViewBag.chains = db.chain.Include("building_type").Include("matter").Include("notation").ToList();
            ViewBag.chainsList = chainRepository.GetSelectListItems(null);
            return View();
        }

        [HttpPost]
        public ActionResult Index(long[] chainIds)
        {
            int notationId = 2;
            foreach (var chainId in chainIds)
            {
                Alphabet tempAlphabet = new Alphabet();
                tempAlphabet.Add(NullValue.Instance());
                element[] elements =
                    db.alphabet.Where(a => a.chain_id == chainId).OrderBy(a => a.number).Select(a => a.element).ToArray();
                for (int j = 0; j < elements.Count(); j++)
                {
                    tempAlphabet.Add(new ValueString(elements[j].value));
                }
                chain dbChain = db.chain.Single(c => c.id == chainId);
                Chain tempChain = new Chain(dbChain.building.OrderBy(b => b.index).Select(b => b.number).ToArray(), tempAlphabet);
                BaseChain tempTripletChain = Coder.EncodeTriplets(tempChain);
                chain result = new chain();
                int[] build = tempTripletChain.Building;
                for (int i = 0; i < build.Length; i++)
                {
                    building buildingElement = new building();
                    buildingElement.chain = result;
                    buildingElement.index = i;
                    buildingElement.number = build[i];
                    db.building.AddObject(buildingElement);
                }

                for (int i = 0; i < tempTripletChain.Alphabet.Power; i++)
                {
                    String strElem = tempTripletChain.Alphabet[i].ToString();
                    element elem;
                    if (db.element.Any(e => e.notation_id == notationId && e.value.Equals(strElem)))
                    {
                        elem = db.element.Single(e => e.notation_id == notationId && e.value.Equals(strElem));
                    }
                    else
                    {
                        elem = new element();
                        elem.name = strElem;
                        elem.value = strElem;
                        elem.notation_id = notationId;
                        elem.creation_date = new DateTimeOffset(DateTime.Now);
                        db.element.AddObject(elem);
                    }
                    alphabet alphabetElement = new alphabet();
                    alphabetElement.chain = result;
                    alphabetElement.number = i + 1;
                    alphabetElement.element = elem;
                    db.alphabet.AddObject(alphabetElement);
                }
                result.matter = dbChain.matter;
                result.building_type = dbChain.building_type;
                result.dissimilar = false;
                result.notation_id = notationId;
                result.creation_date = new DateTimeOffset(DateTime.Now);
                db.chain.AddObject(result);
                db.SaveChanges();
            }
            return RedirectToAction("Index", "Chain");
        }
    }
}