﻿namespace LibiadaWeb.Models.Repositories.Catalogs
{
    using System.Collections.Generic;
    using System.Linq;

    using LibiadaCore.Core;
    using LibiadaCore.Core.Characteristics.Calculators.FullCalculators;
    using LibiadaCore.Extensions;

    using LibiadaWeb.Helpers;
    using LibiadaWeb.Models.CalculatorsData;

    /// <summary>
    /// The full characteristic repository.
    /// </summary>
    public class FullCharacteristicRepository
    {
        /// <summary>
        /// The sync root.
        /// </summary>
        private static readonly object SyncRoot = new object();

        /// <summary>
        /// The instance.
        /// </summary>
        private static FullCharacteristicRepository instance;

        /// <summary>
        /// The characteristic type links.
        /// </summary>
        private readonly FullCharacteristicLink[] characteristicsLinks;

        /// <summary>
        /// Initializes a new instance of the <see cref="FullCharacteristicRepository"/> class.
        /// </summary>
        /// <param name="db">
        /// The db.
        /// </param>
        private FullCharacteristicRepository(LibiadaWebEntities db)
        {
            characteristicsLinks = db.FullCharacteristicLink.ToArray();
        }

        /// <summary>
        /// Gets the instance.
        /// </summary>
        public static FullCharacteristicRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    lock (SyncRoot)
                    {
                        if (instance == null)
                        {
                            using (var db = new LibiadaWebEntities())
                            {
                                instance = new FullCharacteristicRepository(db);
                            }
                        }
                    }
                }

                return instance;
            }
        }

        /// <summary>
        /// Gets the characteristic type links.
        /// </summary>
        public IEnumerable<FullCharacteristicLink> CharacteristicLinks => characteristicsLinks.ToArray();

        /// <summary>
        /// The get libiada link.
        /// </summary>
        /// <param name="characteristicLinkId">
        /// The characteristic type link id.
        /// </param>
        /// <returns>
        /// The <see cref="Link"/>.
        /// </returns>
        public Link GetLinkForCharacteristic(int characteristicLinkId)
        {
            return characteristicsLinks.Single(c => c.Id == characteristicLinkId).Link;
        }

        /// <summary>
        /// The get characteristic type.
        /// </summary>
        /// <param name="characteristicLinkId">
        /// The characteristic type link id.
        /// </param>
        /// <returns>
        /// The <see cref="FullCharacteristic"/>.
        /// </returns>
        public FullCharacteristic GetCharacteristic(int characteristicLinkId)
        {
            return characteristicsLinks.Single(c => c.Id == characteristicLinkId).FullCharacteristic;
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
        public string GetCharacteristicName(int characteristicLinkId, Notation notation)
        {
            return string.Join("  ", GetCharacteristicName(characteristicLinkId), notation.GetDisplayValue());
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
        public string GetCharacteristicName(int characteristicLinkId)
        {
            string characteristicTypeName = GetCharacteristic(characteristicLinkId).GetDisplayValue();

            Link link = GetLinkForCharacteristic(characteristicLinkId);
            string linkName = link == Link.NotApplied ? string.Empty : link.GetDisplayValue();

            return string.Join("  ", characteristicTypeName, linkName);
        }


        /// <summary>
        /// Gets characteristics types.
        /// </summary>
        /// <returns>
        /// The <see cref="List{CharacteristicData}"/>.
        /// </returns>
        public List<CharacteristicData> GetCharacteristicTypes()
        {
            Link[] links;
            FullCharacteristic[] characteristics;
            if (AccountHelper.IsAdmin())
            {
                links = ArrayExtensions.ToArray<Link>();
                characteristics = ArrayExtensions.ToArray<FullCharacteristic>();
            }
            else
            {
                links = Aliases.UserAvailableLinks.ToArray();
                characteristics = Aliases.UserAvailableFullCharacteristics.ToArray();
            }

            var result = new List<CharacteristicData>();

            foreach (FullCharacteristic characteristic in characteristics)
            {
                List<LinkSelectListItem> linkSelectListItems = characteristicsLinks
                    .Where(cl => cl.FullCharacteristic == characteristic && links.Contains(cl.Link))
                    .Select(ctl => new LinkSelectListItem(ctl.Id, ctl.Link.ToString(), ctl.Link.GetDisplayValue()))
                    .ToList();

                result.Add(new CharacteristicData((byte)characteristic, characteristic.GetDisplayValue(), linkSelectListItems));
            }

            return result;
        }
    }
}