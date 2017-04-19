﻿using LibiadaCore.Core;
using LibiadaCore.Core.Characteristics.Calculators.FullCalculators;
using LibiadaCore.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LibiadaWeb.Models.Repositories.Catalogs
{
    public class FullCharacteristicRepository : IDisposable
    {
        /// <summary>
        /// The characteristic type links.
        /// </summary>
        private readonly List<FullCharacteristicLink> fullCharacteristicLinks;

        /// <summary>
        /// Initializes a new instance of the <see cref="CharacteristicLinkRepository"/> class.
        /// </summary>
        /// <param name="db">
        /// The db.
        /// </param>
        public FullCharacteristicRepository(LibiadaWebEntities db)
        {
            fullCharacteristicLinks = db.FullCharacteristicLink.ToList();
        }

        /// <summary>
        /// Gets the characteristic type links.
        /// </summary>
        public IEnumerable<FullCharacteristicLink> FullCharacteristicLinks
        {
            get
            {
                return fullCharacteristicLinks.ToArray();
            }
        }

        /// <summary>
        /// The get libiada link.
        /// </summary>
        /// <param name="characteristicLinkId">
        /// The characteristic type link id.
        /// </param>
        /// <returns>
        /// The <see cref="Link"/>.
        /// </returns>
        public Link GetLinkForFullCharacteristic(int characteristicLinkId)
        {
            return fullCharacteristicLinks.Single(c => c.Id == characteristicLinkId).Link;
        }
        
        /// <summary>
        /// The get characteristic type.
        /// </summary>
        /// <param name="characteristicLinkId">
        /// The characteristic type link id.
        /// </param>
        /// <returns>
        /// The <see cref="CharacteristicType"/>.
        /// </returns>
        public FullCharacteristic GetFullCharacteristic(int characteristicLinkId)
        {
            return fullCharacteristicLinks.Single(c => c.Id == characteristicLinkId).FullCharacteristic;
        }
        
        /// <summary>
        /// The get characteristic name.
        /// </summary>
        /// <param name="characteristicLinkId">
        /// The characteristic type and link id.
        /// </param>
        /// <param name="notation">
        /// The notation id.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        public string GetFullCharacteristicName(int characteristicLinkId, Notation notation)
        {
            return string.Join("  ", GetFullCharacteristicName(characteristicLinkId), notation.GetDisplayValue());
        }

        /// <summary>
        /// The get characteristic name.
        /// </summary>
        /// <param name="characteristicLinkId">
        /// The characteristic type and link id.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        public string GetFullCharacteristicName(int characteristicLinkId)
        {
            var characteristicType = GetFullCharacteristic(characteristicLinkId).GetDisplayValue();

            var databaseLink = GetLinkForFullCharacteristic(characteristicLinkId);
            var link = databaseLink == Link.NotApplied ? string.Empty : databaseLink.GetDisplayValue();

            return string.Join("  ", characteristicType, link);
        }

        /// <summary>
        /// The dispose.
        /// </summary>
        public void Dispose()
        {
        }
    }
}