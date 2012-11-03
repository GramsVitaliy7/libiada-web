﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Web.Mvc;
using LibiadaCore.Classes.Root;
using LibiadaCore.Classes.Root.SimpleTypes;
using LibiadaCore.Classes.TheoryOfSet;
using LibiadaWeb.Helpers;
using LibiadaWeb.Models;

namespace LibiadaWeb.Controllers
{ 
    public class ChainController : Controller
    {
        private readonly LibiadaWebEntities db = new LibiadaWebEntities();
        private readonly DnaChainRepository dnaChainRepository;
        private readonly LiteratureChainRepository literatureChainRepository;

        public ChainController()
        {
            dnaChainRepository = new DnaChainRepository(db);
            literatureChainRepository = new LiteratureChainRepository(db);
        }

        //
        // GET: /Chain/

        public ViewResult Index()
        {
            var chain = db.chain.OrderBy(c => c.creation_date).Include("building_type").Include("matter").Include("notation");
            return View(chain.ToList());
        }

        //
        // GET: /Chain/Details/5

        public ViewResult Details(long id)
        {
            chain chain = db.chain.Single(c => c.id == id);
            Alphabet alpha = new Alphabet();
            alpha.Add(NullValue.Instance());
            IEnumerable<element> elements =
                db.alphabet.Where(a => a.chain_id == id).Select(a => a.element);
            foreach (var element in elements)
            {
                alpha.Add(new ValueString(element.value));
            }

            ViewBag.stringChain = new Chain(chain.building.OrderBy(b => b.index).Select(b => b.number).ToArray(), alpha).ToString();
            return View(chain);
        }

        //
        // GET: /Chain/Create

        public ActionResult Create()
        {
            ViewBag.building_type_id = new SelectList(db.building_type, "id", "name");
            ViewBag.matter_id = new SelectList(db.matter, "id", "name");
            ViewBag.notation_id = new SelectList(db.notation, "id", "name");
            ViewBag.language_id = new SelectList(db.language, "id", "name");
            ViewBag.piece_type_id = new SelectList(db.piece_type, "id", "name");
            return View();
        } 

        //
        // POST: /Chain/Create

        [HttpPost]
        public ActionResult Create(chain chain, int languageId, bool original)
        {
            if (ModelState.IsValid)
            {
                var file = Request.Files[0];

                int fileLen = file.ContentLength;
                byte[] input = new byte[fileLen];

                // Initialize the stream
                var fileStream = file.InputStream;

                // Read the file into the byte array
                fileStream.Read(input, 0, fileLen);
                int natureId = db.matter.Single(m => m.id == chain.matter_id).nature_id;
                // Copy the byte array into a string
                String stringChain;
                if (natureId == 1)
                {
                    stringChain = Encoding.ASCII.GetString(input);
                }
                else
                {
                    stringChain = Encoding.UTF8.GetString(input);
                }

                BaseChain libiadaChain;// = new BaseChain(stringChain);
                int[] libiadaBuilding;
                switch (natureId)
                {
                    //генетическая цепочка
                    case 1:
                        //отделяем заголовок fasta файла от цепочки
                        string[] splittedFasta = stringChain.Split('\n');
                        stringChain = "";
                        String fastaHeader = splittedFasta[0];
                        for (int j = 1; j < splittedFasta.Length; j++)
                        {
                            stringChain += splittedFasta[j];
                        }

                        stringChain = DataTransformators.CleanFastaFile(stringChain);

                        libiadaChain = new BaseChain(stringChain);

                        dna_chain dbDnaChain;
                        bool continueImport =
                            db.dna_chain.Any(
                                d =>
                                d.notation_id == chain.notation_id && d.matter_id == chain.matter_id &&
                                d.fasta_header == fastaHeader); 
                        if (!continueImport)
                        {
                            dbDnaChain = new dna_chain()
                            {
                                id = db.ExecuteStoreQuery<long>("SELECT seq_next_value('chains_id_seq')").First(),
                                dissimilar = chain.dissimilar,
                                building_type_id = chain.building_type_id,
                                notation_id = chain.notation_id,
                                fasta_header = fastaHeader,
                                piece_type_id = chain.piece_type_id,
                                creation_date = new DateTimeOffset(DateTime.Now)
                            };

                            db.matter.Single(m => m.id == chain.matter_id).dna_chain.Add(dbDnaChain); //TODO: проверить, возможно одно из действий лишнее
                            db.dna_chain.AddObject(dbDnaChain);

                            dnaChainRepository.FromLibiadaAlphabetToDbAlphabet(libiadaChain.Alphabet, dbDnaChain, chain.notation_id);
                        }
                        else
                        {
                            dbDnaChain = db.dna_chain.Single(c => c.matter_id == chain.matter_id && c.notation_id == chain.notation_id && c.fasta_header == fastaHeader);
                        }


                        libiadaBuilding = libiadaChain.Building;

                        dnaChainRepository.FromLibiadaBuildingToDbBuilding(dbDnaChain, libiadaBuilding);

                        db.SaveChanges();
                        break;
                    //музыкальная цепочка
                    case 2:
                        break;
                    //литературная цепочка
                    case 3:
                        string[] text = stringChain.Split('\n');
                        for (int l = 0; l < text.Length - 1; l++)
                        {
                            // убираем \r
                            text[l] = text[l].Substring(0, text[l].Length - 1);
                        }

                        libiadaChain = new BaseChain(text.Length - 1);
                        // в конце файла всегда пустая строка поэтому последний элемент не считаем
                        for (int i = 0; i < text.Length - 1; i++)
                        {
                            libiadaChain.Add(new ValueString(text[i]), i);
                        }
                        literature_chain dbLiteratureChain;
                        continueImport =
                            db.literature_chain.Any(
                                d =>
                                d.notation_id == chain.notation_id && d.matter_id == chain.matter_id &&
                                d.language_id == languageId); 
                        if (!continueImport)
                        {

                            dbLiteratureChain = new literature_chain()
                            {
                                id = db.ExecuteStoreQuery<long>("SELECT seq_next_value('chains_id_seq')").First(),
                                dissimilar = chain.dissimilar,
                                building_type_id = chain.building_type_id,
                                notation_id = chain.notation_id,
                                language_id = languageId,
                                original = original,
                                piece_type_id = chain.piece_type_id,
                                creation_date = new DateTimeOffset(DateTime.Now)
                            };

                            db.matter.Single(m => m.id == chain.matter_id).literature_chain.Add(dbLiteratureChain); //TODO: проверить, возможно одно из действий лишнее
                            db.literature_chain.AddObject(dbLiteratureChain);

                            literatureChainRepository.FromLibiadaAlphabetToDbAlphabet(libiadaChain.Alphabet, dbLiteratureChain, chain.notation_id);
                        }
                        else
                        {
                            dbLiteratureChain = db.literature_chain.Single(c => c.matter_id == chain.matter_id && c.notation_id == chain.notation_id && c.language_id == languageId);
                        }

                        libiadaBuilding = libiadaChain.Building;

                        literatureChainRepository.FromLibiadaBuildingToDbBuilding(dbLiteratureChain, libiadaBuilding);

                        db.SaveChanges();
                        break;
                }

                return RedirectToAction("Index");  
            }

            ViewBag.building_type_id = new SelectList(db.building_type, "id", "name", chain.building_type_id);
            ViewBag.matter_id = new SelectList(db.matter, "id", "name", chain.matter_id);
            ViewBag.notation_id = new SelectList(db.notation, "id", "name", chain.notation_id);
            return View(chain);
        }
        
        //
        // GET: /Chain/Edit/5
 
        public ActionResult Edit(long id)
        {
            chain chain = db.chain.Single(c => c.id == id);
            ViewBag.building_type_id = new SelectList(db.building_type, "id", "name", chain.building_type_id);
            ViewBag.matter_id = new SelectList(db.matter, "id", "name", chain.matter_id);
            ViewBag.notation_id = new SelectList(db.notation, "id", "name", chain.notation_id);
            return View(chain);
        }

        //
        // POST: /Chain/Edit/5

        [HttpPost]
        public ActionResult Edit(chain chain)
        {
            if (ModelState.IsValid)
            {
                db.chain.Attach(chain);
                db.ObjectStateManager.ChangeObjectState(chain, EntityState.Modified);
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.building_type_id = new SelectList(db.building_type, "id", "name", chain.building_type_id);
            ViewBag.matter_id = new SelectList(db.matter, "id", "name", chain.matter_id);
            ViewBag.notation_id = new SelectList(db.notation, "id", "name", chain.notation_id);
            return View(chain);
        }

        //
        // GET: /Chain/Delete/5
 
        public ActionResult Delete(long id)
        {
            chain chain = db.chain.Single(c => c.id == id);
            return View(chain);
        }

        //
        // POST: /Chain/Delete/5

        [HttpPost, ActionName("Delete")]
        public ActionResult DeleteConfirmed(long id)
        {            
            chain chain = db.chain.Single(c => c.id == id);
            db.chain.DeleteObject(chain);
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