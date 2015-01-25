﻿namespace LibiadaWeb.Helpers
{
    using System;
    using System.Collections.Generic;
    using System.Linq;

    using Npgsql;

    /// <summary>
    /// The helper for database functions.
    /// </summary>
    public static class DbHelper
    {
        /// <summary>
        /// The db name.
        /// </summary>
        public static string DbName;

        /// <summary>
        /// Initializes static members of the <see cref="DbHelper"/> class.
        /// </summary>
        static DbHelper()
        {
            try
            {
                using (var db = new LibiadaWebEntities())
                {
                    DbName = db.Database.SqlQuery<string>("SELECT current_database()").First();
                } 
            }
            catch (Exception e)
            {
                DbName = "No connection to db. Reason: " + e.Message;
            } 
        }

        /// <summary>
        /// Gets new element id from database.
        /// </summary>
        /// <param name="db">
        /// Database connection.
        /// </param>
        /// <returns>
        /// The <see cref="long"/> value of new id.
        /// </returns>
        public static long GetNewElementId(LibiadaWebEntities db)
        {
            return db.Database.SqlQuery<long>("SELECT nextval('elements_id_seq');").First();
        }

        /// <summary>
        /// The get element ids.
        /// </summary>
        /// <param name="db">
        /// Database connection.
        /// </param>
        /// <param name="sequenceId">
        /// The sequence id.
        /// </param>
        /// <returns>
        /// The <see cref="List{Int64}"/>.
        /// </returns>
        public static List<long> GetElementIds(LibiadaWebEntities db, long sequenceId)
        {
            const string Query = "SELECT unnest(alphabet) FROM chain WHERE id = @id";
            return db.Database.SqlQuery<long>(Query, new NpgsqlParameter("@id", sequenceId)).ToList();
        }

        /// <summary>
        /// Gets building of sequence by id..
        /// </summary>
        /// <param name="db">
        /// Database connection.
        /// </param>
        /// <param name="sequenceId">
        /// The sequence id.
        /// </param>
        /// <returns>
        /// The <see cref="int[]"/>.
        /// </returns>
        public static int[] GetBuilding(LibiadaWebEntities db, long sequenceId)
        {
            const string Query = "SELECT unnest(building) FROM chain WHERE id = @id";
            return db.Database.SqlQuery<int>(Query, new NpgsqlParameter("@id", sequenceId)).ToArray();
        }

        /// <summary>
        /// The execute custom sql command with parameters.
        /// </summary>
        /// <param name="db">
        /// The db.
        /// </param>
        /// <param name="query">
        /// The query.
        /// </param>
        /// <param name="parameters">
        /// The parameters.
        /// </param>
        public static void ExecuteCommand(LibiadaWebEntities db, string query, object[] parameters)
        {
            db.Database.ExecuteSqlCommand(query, parameters);
        }
    }
}
