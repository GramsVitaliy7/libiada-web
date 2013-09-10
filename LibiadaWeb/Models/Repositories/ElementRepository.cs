using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Web.Mvc;
using LibiadaCore.Classes.Root;
using LibiadaCore.Classes.TheoryOfSet;

namespace LibiadaWeb.Models.Repositories
{
    public class ElementRepository : IElementRepository
    {
        private readonly LibiadaWebEntities db;

        public ElementRepository(LibiadaWebEntities db)
        {
            this.db = db;
        }

        public IQueryable<element> All
        {
            get { return db.element; }
        }

        public IQueryable<element> AllIncluding(params Expression<Func<element, object>>[] includeProperties)
        {
            IQueryable<element> query = db.element;
            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }
            return query;
        }

        public element Find(long id)
        {
            return db.element.Single(x => x.id == id);
        }

        public void InsertOrUpdate(element element)
        {
            if (element.id == default(long))
            {
                // New entity
                db.element.AddObject(element);
            }
            else
            {
                // Existing entity
                db.element.Attach(element);
                db.ObjectStateManager.ChangeObjectState(element, EntityState.Modified);
            }
        }

        public void Delete(long id)
        {
            var element = Find(id);
            db.element.DeleteObject(element);
        }

        public void Save()
        {
            db.SaveChanges();
        }

        public void Dispose()
        {
            db.Dispose();
        }

        public bool ElementInDb(IBaseObject element, int notationId)
        {
            String stringElement = element.ToString();
            return db.element.Any(e => e.notation_id == notationId && e.value.Equals(stringElement));
        }

        public bool ElementsInDb(Alphabet alphabet, int notationId)
        {
            for (int i = 0; i < alphabet.Power; i++)
            {
                if (!ElementInDb(alphabet[i], notationId))
                {
                    return false;
                }
            }
            return true;
        }

        public void CreateLackingElements(Alphabet libiadaAlphabet, int notationId)
        {
            for (int j = 0; j < libiadaAlphabet.Power; j++)
            {
                String strElem = libiadaAlphabet[j].ToString();

                if (!ElementInDb(libiadaAlphabet[j], notationId))
                {
                    element newElement = new element
                    {
                        value = strElem,
                        name = strElem,
                        notation_id = notationId,
                        creation_date = DateTime.Now
                    };
                    db.element.AddObject(newElement);
                }
            }
            db.SaveChanges();
        }

        public IEnumerable<SelectListItem> GetSelectListItems(IEnumerable<element> allElements,
                                                              IEnumerable<element> selectedElements)
        {
            HashSet<long> elementIds = selectedElements != null
                                     ? new HashSet<long>(selectedElements.Select(c => c.id))
                                     : new HashSet<long>();
            if (allElements == null)
            {
                allElements = db.element;
            }
            var elementsList = new List<SelectListItem>();
            foreach (var element in allElements)
            {
                elementsList.Add(new SelectListItem
                    {
                        Value = element.id.ToString(),
                        Text = element.name,
                        Selected = elementIds.Contains(element.id)
                    });
            }
            return elementsList;
        }

        public List<SelectListItem> GetSelectListItems(IEnumerable<element> elements)
        {
            HashSet<long> elementIds = elements != null
                                           ? new HashSet<long>(elements.Select(c => c.id))
                                           : new HashSet<long>();
            var allElements = db.element;
            var elementsList = new List<SelectListItem>();
            foreach (var element in allElements)
            {
                elementsList.Add(new SelectListItem
                    {
                        Value = element.id.ToString(),
                        Text = element.name,
                        Selected = elementIds.Contains(element.id)
                    });
            }
            return elementsList;
        }
    }
}