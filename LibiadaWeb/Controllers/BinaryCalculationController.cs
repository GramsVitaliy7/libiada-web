﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using LibiadaCore.Classes.Root;
using LibiadaCore.Classes.Root.Characteristics;
using LibiadaCore.Classes.Root.Characteristics.BinaryCalculators;
using LibiadaCore.Classes.TheoryOfSet;
using LibiadaWeb.Models;

namespace LibiadaWeb.Controllers
{
    public class Coordinates
    {
        public int i = 0;
        public int j = 0;

        public Coordinates(int a, int b)
        {
            i = a;
            j = b;
        }
    }

    public class BinaryCalculationController : Controller
    {
        private readonly LibiadaWebEntities db = new LibiadaWebEntities();
        private readonly MatterRepository matterRepository;
        private readonly CharacteristicTypeRepository characteristicsRepository;
        private readonly LinkUpRepository linkUpRepository;
        private readonly NotationRepository notationRepository;
        private readonly ChainRepository chainRepository;

        public BinaryCalculationController()
        {
            matterRepository = new MatterRepository(db);
            characteristicsRepository = new CharacteristicTypeRepository(db);
            linkUpRepository = new LinkUpRepository(db);
            notationRepository = new NotationRepository(db);
            chainRepository = new ChainRepository(db);
        }

        //
        // GET: /Calculation/

        public ActionResult Index()
        {
            ViewBag.matters = db.matter.ToList();
            ViewBag.language_id = new SelectList(db.language, "id", "name");
            ViewBag.mattersList = matterRepository.GetSelectListItems(null);
            ViewBag.characteristicsList = characteristicsRepository.GetSelectListItems(null);
            ViewBag.linkUpsList = linkUpRepository.GetSelectListItems(null);
            ViewBag.notationsList = notationRepository.GetSelectListItems(null);
            return View();
        }

        [HttpPost]
        public ActionResult Index(long matterId, int characteristicId, int linkUpId, int notationId, int languageId, int filtersize, bool filter)
        {
            List<List<Double>> characteristics = new List<List<Double>>();

            List<KeyValuePair<Coordinates, double>> filterDictionary = new List<KeyValuePair<Coordinates, double>>();

            chain dbChain;
            if (db.matter.Single(m => m.id == matterId).nature_id == 3)
            {
                long chainId = db.literature_chain.Single(l => l.matter_id == matterId && l.notation_id == notationId && l.language_id == languageId).id;
                dbChain = db.chain.Single(c => c.id == chainId);
            }
            else
            {
                dbChain = db.chain.Single(c => c.matter_id == matterId && c.notation_id == notationId);
            }
            
            Chain currentChain = chainRepository.FromDbChainToLibiadaChain(dbChain.id);
            String className = db.characteristic_type.Single(c => c.id == characteristicId).class_name;

            IBinaryCharacteristicCalculator calculator = BinaryCharacteristicsFactory.Create(className);
            LinkUp linkUp = (LinkUp)linkUpId;
            for (int i = 0; i < currentChain.Alphabet.Power; i++)
            {
                characteristics.Add(new List<double>());
                for (int j = 0; j < currentChain.Alphabet.Power; j++)
                {
                    long firstElementId = dbChain.alphabet.Single(a => a.number == i+1).element_id;
                    long secondElementId = dbChain.alphabet.Single(a => a.number == j+1).element_id;
                    if (
                        db.binary_characteristic.Any(b =>
                            b.chain_id == dbChain.id && b.characteristic_type_id == characteristicId &&
                            b.first_element_id == firstElementId && b.second_element_id == secondElementId &&
                            b.link_up_id == linkUpId))
                    {
                        characteristics[i].Add((double)db.binary_characteristic.Single(b =>
                            b.chain_id == dbChain.id && b.characteristic_type_id == characteristicId &&
                            b.first_element_id == firstElementId && b.second_element_id == secondElementId &&
                            b.link_up_id == linkUpId).value);
                    }
                    else
                    {
                        characteristics[i].Add(calculator.Calculate(currentChain, currentChain.Alphabet[i],
                                                                    currentChain.Alphabet[j], linkUp));
                        binary_characteristic currentCharacteristic = new binary_characteristic();
                        currentCharacteristic.id = db.ExecuteStoreQuery<long>("SELECT seq_next_value('characteristics_id_seq')").First();
                        currentCharacteristic.chain_id = dbChain.id;
                        currentCharacteristic.characteristic_type_id = characteristicId;
                        currentCharacteristic.link_up_id = linkUpId;
                        currentCharacteristic.first_element_id = firstElementId;
                        currentCharacteristic.second_element_id = secondElementId;
                        currentCharacteristic.value = characteristics[i][j];
                        currentCharacteristic.value_string = characteristics[i][j].ToString();
                        currentCharacteristic.creation_date = DateTime.Now;
                        db.binary_characteristic.AddObject(currentCharacteristic);
                        db.SaveChanges();
                    }
                }
            }

            if (filter)
            {
                for (int i = 0; i < filtersize; i++)
                {
                    filterDictionary.Add(new KeyValuePair<Coordinates, double>(new Coordinates(i, 0), characteristics[i][0]));
                }


                for (int i = 0; i < currentChain.Alphabet.Power; i++)
                {
                    for (int j = 0; j < currentChain.Alphabet.Power; j++)
                    {

                        if (characteristics[i][j] > filterDictionary[filtersize - 1].Value)
                        {
                            filterDictionary[filtersize - 1] = new KeyValuePair<Coordinates, double>(filterDictionary[filtersize - 1].Key, characteristics[i][j]);
                            SortCharacteristicsFilter(filterDictionary);
                        }
                    }
                }    
            }

            TempData["filter"] = filter;
            TempData["filterDictionary"] = filterDictionary;
            TempData["filtersize"] = filtersize;
            TempData["characteristics"] = characteristics;
            TempData["characteristicName"] = db.characteristic_type.Single(charact => charact.id == characteristicId).name;
            TempData["chainName"] = db.matter.Single(m => m.id == matterId).name;
            TempData["notationId"] = notationId;
            TempData["alphabet"] = currentChain.Alphabet;

            return RedirectToAction("Result");
        }

        private void SortCharacteristicsFilter(List<KeyValuePair<Coordinates, double>> arrayForSort)
        {
            arrayForSort.Sort(
                delegate(KeyValuePair<Coordinates, double> firstPair,
                         KeyValuePair<Coordinates, double> nextPair)
                {
                    return nextPair.Value.CompareTo(firstPair.Value);
                }
                );
        }

        public ActionResult Result()
        {
            List<String> elementNames = new List<string>();

            Alphabet alpha = TempData["alphabet"] as Alphabet;
            int notationId = (int)TempData["notationId"];

            foreach (var element in alpha)
            {
                string el = element.ToString();
                elementNames.Add(db.element.Single(e => e.value == el && e.notation_id == notationId).name);
            }
            ViewBag.elementNames = elementNames;
            ViewBag.chainName = TempData["chainName"] as String;
            ViewBag.characteristicName = TempData["characteristicName"] as String;
            ViewBag.elementNames = elementNames;
            ViewBag.notationName = db.notation.Single(n => n.id == notationId).name;
            ViewBag.isFilter = TempData["filter"];

            if ((bool)TempData["filter"])
            {
                ViewBag.alphabet = alpha;
                ViewBag.filtersize = TempData["filtersize"];
                ViewBag.characteristics = TempData["filterDictionary"] as List<KeyValuePair<Coordinates, double>>;
            }
            else
            {
                ViewBag.characteristics = TempData["characteristics"] as List<List<double>>;
            }
            return View();
        }
    }
}
