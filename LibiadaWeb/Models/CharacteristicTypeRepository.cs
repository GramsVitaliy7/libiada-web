using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Web.Mvc;

namespace LibiadaWeb.Models
{ 
    public class CharacteristicTypeRepository : ICharacteristicTypeRepository
    {
        LibiadaWebEntities db = new LibiadaWebEntities();

        public CharacteristicTypeRepository(LibiadaWebEntities db)
        {
            this.db = db;
        }

        public IQueryable<characteristic_type> All
        {
            get { return db.characteristic_type; }
        }

        public IQueryable<characteristic_type> AllIncluding(params Expression<Func<characteristic_type, object>>[] includeProperties)
        {
            IQueryable<characteristic_type> query = db.characteristic_type;
            foreach (var includeProperty in includeProperties) {
                query = query.Include(includeProperty);
            }
            return query;
        }

        public characteristic_type Find(int id)
        {
            return db.characteristic_type.Single(x => x.id == id);
        }

        public void InsertOrUpdate(characteristic_type characteristic_type)
        {
            if (characteristic_type.id == default(int)) {
                // New entity
                db.characteristic_type.AddObject(characteristic_type);
            } else {
                // Existing entity
                db.characteristic_type.Attach(characteristic_type);
                db.ObjectStateManager.ChangeObjectState(characteristic_type, EntityState.Modified);
            }
        }

        public void Delete(int id)
        {
            var characteristic_type = db.characteristic_type.Single(x => x.id == id);
            db.characteristic_type.DeleteObject(characteristic_type);
        }

        public void Save()
        {
            db.SaveChanges();
        }

        public List<SelectListItem> GetSelectListItems(IEnumerable<characteristic_type> characteristicTypes)
        {
            HashSet<int> characteristicTypeIds;
            if (characteristicTypes != null)
            {
                characteristicTypeIds = new HashSet<int>(characteristicTypes.Select(c => c.id));
            }
            else
            {
                characteristicTypeIds = new HashSet<int>();
            }
            var allCharacteristicTypes = db.characteristic_type;
            var characteristicTypesList = new List<SelectListItem>();
            foreach (var characteristicType in allCharacteristicTypes)
            {
                characteristicTypesList.Add(new SelectListItem
                {
                    Value = characteristicType.id.ToString(),
                    Text = characteristicType.name,
                    Selected = characteristicTypeIds.Contains(characteristicType.id)
                });
            }
            return characteristicTypesList;
        }

        public void Dispose() 
        {
            db.Dispose();
        }
    }
}