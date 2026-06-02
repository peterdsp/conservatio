package com.conservatio.db

import app.cash.sqldelight.Query
import app.cash.sqldelight.TransacterImpl
import app.cash.sqldelight.db.QueryResult
import app.cash.sqldelight.db.SqlCursor
import app.cash.sqldelight.db.SqlDriver
import kotlin.Any
import kotlin.Double
import kotlin.Long
import kotlin.String

public class ProjectQueries(
  driver: SqlDriver,
) : TransacterImpl(driver) {
  public fun <T : Any> selectAll(mapper: (
    id: String,
    title: String,
    client_id: String?,
    object_ids: String,
    status: String,
    start_date: Long?,
    end_date: Long?,
    description: String?,
    total_budget: Double?,
    currency: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(-475_796_592, arrayOf("ProjectEntity"), driver, "Project.sq",
      "selectAll",
      "SELECT ProjectEntity.id, ProjectEntity.title, ProjectEntity.client_id, ProjectEntity.object_ids, ProjectEntity.status, ProjectEntity.start_date, ProjectEntity.end_date, ProjectEntity.description, ProjectEntity.total_budget, ProjectEntity.currency, ProjectEntity.created_at, ProjectEntity.updated_at, ProjectEntity.sync_status FROM ProjectEntity ORDER BY updated_at DESC") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2),
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5),
      cursor.getLong(6),
      cursor.getString(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectAll(): Query<ProjectEntity> = selectAll { id, title, client_id, object_ids,
      status, start_date, end_date, description, total_budget, currency, created_at, updated_at,
      sync_status ->
    ProjectEntity(
      id,
      title,
      client_id,
      object_ids,
      status,
      start_date,
      end_date,
      description,
      total_budget,
      currency,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectById(id: String, mapper: (
    id: String,
    title: String,
    client_id: String?,
    object_ids: String,
    status: String,
    start_date: Long?,
    end_date: Long?,
    description: String?,
    total_budget: Double?,
    currency: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = SelectByIdQuery(id) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2),
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5),
      cursor.getLong(6),
      cursor.getString(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectById(id: String): Query<ProjectEntity> = selectById(id) { id_, title, client_id,
      object_ids, status, start_date, end_date, description, total_budget, currency, created_at,
      updated_at, sync_status ->
    ProjectEntity(
      id_,
      title,
      client_id,
      object_ids,
      status,
      start_date,
      end_date,
      description,
      total_budget,
      currency,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectByClient(client_id: String?, mapper: (
    id: String,
    title: String,
    client_id: String?,
    object_ids: String,
    status: String,
    start_date: Long?,
    end_date: Long?,
    description: String?,
    total_budget: Double?,
    currency: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = SelectByClientQuery(client_id) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2),
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5),
      cursor.getLong(6),
      cursor.getString(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectByClient(client_id: String?): Query<ProjectEntity> = selectByClient(client_id) {
      id, title, client_id_, object_ids, status, start_date, end_date, description, total_budget,
      currency, created_at, updated_at, sync_status ->
    ProjectEntity(
      id,
      title,
      client_id_,
      object_ids,
      status,
      start_date,
      end_date,
      description,
      total_budget,
      currency,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectPending(mapper: (
    id: String,
    title: String,
    client_id: String?,
    object_ids: String,
    status: String,
    start_date: Long?,
    end_date: Long?,
    description: String?,
    total_budget: Double?,
    currency: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(1_601_858_566, arrayOf("ProjectEntity"), driver, "Project.sq",
      "selectPending",
      "SELECT ProjectEntity.id, ProjectEntity.title, ProjectEntity.client_id, ProjectEntity.object_ids, ProjectEntity.status, ProjectEntity.start_date, ProjectEntity.end_date, ProjectEntity.description, ProjectEntity.total_budget, ProjectEntity.currency, ProjectEntity.created_at, ProjectEntity.updated_at, ProjectEntity.sync_status FROM ProjectEntity WHERE sync_status = 'PENDING'") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2),
      cursor.getString(3)!!,
      cursor.getString(4)!!,
      cursor.getLong(5),
      cursor.getLong(6),
      cursor.getString(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getLong(10)!!,
      cursor.getLong(11)!!,
      cursor.getString(12)!!
    )
  }

  public fun selectPending(): Query<ProjectEntity> = selectPending { id, title, client_id,
      object_ids, status, start_date, end_date, description, total_budget, currency, created_at,
      updated_at, sync_status ->
    ProjectEntity(
      id,
      title,
      client_id,
      object_ids,
      status,
      start_date,
      end_date,
      description,
      total_budget,
      currency,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun insertProject(
    id: String,
    title: String,
    client_id: String?,
    object_ids: String,
    status: String,
    start_date: Long?,
    end_date: Long?,
    description: String?,
    total_budget: Double?,
    currency: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) {
    driver.execute(740_172_075, """
        |INSERT OR REPLACE INTO ProjectEntity(
        |    id, title, client_id, object_ids, status, start_date, end_date,
        |    description, total_budget, currency, created_at, updated_at, sync_status
        |) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """.trimMargin(), 13) {
          bindString(0, id)
          bindString(1, title)
          bindString(2, client_id)
          bindString(3, object_ids)
          bindString(4, status)
          bindLong(5, start_date)
          bindLong(6, end_date)
          bindString(7, description)
          bindDouble(8, total_budget)
          bindString(9, currency)
          bindLong(10, created_at)
          bindLong(11, updated_at)
          bindString(12, sync_status)
        }
    notifyQueries(740_172_075) { emit ->
      emit("ProjectEntity")
    }
  }

  public fun deleteById(id: String) {
    driver.execute(1_555_794_162, """DELETE FROM ProjectEntity WHERE id = ?""", 1) {
          bindString(0, id)
        }
    notifyQueries(1_555_794_162) { emit ->
      emit("ProjectEntity")
    }
  }

  private inner class SelectByIdQuery<out T : Any>(
    public val id: String,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ProjectEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ProjectEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(-1_864_751_165,
        """SELECT ProjectEntity.id, ProjectEntity.title, ProjectEntity.client_id, ProjectEntity.object_ids, ProjectEntity.status, ProjectEntity.start_date, ProjectEntity.end_date, ProjectEntity.description, ProjectEntity.total_budget, ProjectEntity.currency, ProjectEntity.created_at, ProjectEntity.updated_at, ProjectEntity.sync_status FROM ProjectEntity WHERE id = ?""",
        mapper, 1) {
      bindString(0, id)
    }

    override fun toString(): String = "Project.sq:selectById"
  }

  private inner class SelectByClientQuery<out T : Any>(
    public val client_id: String?,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ProjectEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ProjectEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(null,
        """SELECT ProjectEntity.id, ProjectEntity.title, ProjectEntity.client_id, ProjectEntity.object_ids, ProjectEntity.status, ProjectEntity.start_date, ProjectEntity.end_date, ProjectEntity.description, ProjectEntity.total_budget, ProjectEntity.currency, ProjectEntity.created_at, ProjectEntity.updated_at, ProjectEntity.sync_status FROM ProjectEntity WHERE client_id ${ if (client_id == null) "IS" else "=" } ? ORDER BY updated_at DESC""",
        mapper, 1) {
      bindString(0, client_id)
    }

    override fun toString(): String = "Project.sq:selectByClient"
  }
}
